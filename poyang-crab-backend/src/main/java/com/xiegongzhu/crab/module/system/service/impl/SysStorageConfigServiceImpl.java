package com.xiegongzhu.crab.module.system.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.result.ResultCode;
import com.xiegongzhu.crab.common.storage.RemoteStorageService;
import com.xiegongzhu.crab.common.storage.StorageDriver;
import com.xiegongzhu.crab.common.storage.StorageFactory;
import com.xiegongzhu.crab.common.storage.StorageService;
import com.xiegongzhu.crab.common.util.AesUtils;
import com.xiegongzhu.crab.module.system.dto.StorageDriverVO;
import com.xiegongzhu.crab.module.system.entity.SysStorageConfig;
import com.xiegongzhu.crab.module.system.mapper.SysStorageConfigMapper;
import com.xiegongzhu.crab.module.system.service.SysStorageConfigService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class SysStorageConfigServiceImpl extends ServiceImpl<SysStorageConfigMapper, SysStorageConfig>
        implements SysStorageConfigService {

    private static final String SECRET_MASK = "****";

    private final StorageFactory storageFactory;
    private final AesUtils aesUtils;
    private final ObjectMapper objectMapper;

    public SysStorageConfigServiceImpl(StorageFactory storageFactory, AesUtils aesUtils, ObjectMapper objectMapper) {
        this.storageFactory = storageFactory;
        this.aesUtils = aesUtils;
        this.objectMapper = objectMapper;
    }

    @Override
    public List<StorageDriverVO> drivers() {
        String activeDriver = storageFactory.active().driver().name();
        List<SysStorageConfig> configs = list(Wrappers.<SysStorageConfig>lambdaQuery());
        List<StorageDriverVO> result = new ArrayList<>();
        for (StorageDriver driver : StorageDriver.values()) {
            SysStorageConfig config = configs.stream()
                    .filter(item -> driver.name().equals(item.getDriver()))
                    .findFirst().orElse(null);
            StorageDriverVO vo = new StorageDriverVO();
            vo.setDriver(driver);
            vo.setLabel(driver.getLabel());
            vo.setActive(driver.name().equals(activeDriver));
            vo.setTestPassed(config != null && config.getTestPassed() != null && config.getTestPassed() == 1);
            vo.setParams(maskSecrets(parse(config == null ? null : config.getConfigJson())));
            result.add(vo);
        }
        return result;
    }

    @Override
    public boolean testConnection(StorageDriver driver, Map<String, String> params) {
        if (driver == StorageDriver.LOCAL) {
            // 本地驱动无外部依赖，仅探测磁盘目录；同样需落库测试结果，
            // 否则 saveAndApply 会因 test_passed 恒为 0 而永远无法激活本地驱动
            boolean passed = storageFactory.of(StorageDriver.LOCAL).testConnection();
            markTestResult(driver, params, passed);
            return passed;
        }
        Map<String, String> merged = mergeWithStored(driver, params);
        String endpoint = merged.getOrDefault("endpoint", "");
        String bucket = merged.getOrDefault("bucket", "");
        String domain = merged.getOrDefault("domain", "");
        StorageService probe = new RemoteStorageService(driver, endpoint, bucket, domain);
        boolean passed = probe.testConnection();
        markTestResult(driver, params, passed);
        return passed;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveAndApply(StorageDriver driver, Map<String, String> params) {
        SysStorageConfig config = getOne(Wrappers.<SysStorageConfig>lambdaQuery()
                .eq(SysStorageConfig::getDriver, driver.name()));
        boolean passed = config != null && config.getTestPassed() != null && config.getTestPassed() == 1;
        if (!passed) {
            throw new BizException(ResultCode.STORAGE_NOT_READY);
        }
        String json = toJson(mergeWithStored(driver, params));
        // 逐条按主键更新激活标记：既保证只激活当前驱动，也避免「无主键条件的批量 UPDATE」
        // 被 MyBatis-Plus BlockAttackInnerInterceptor 拦截（防全表更新保护）
        for (SysStorageConfig item : list(Wrappers.<SysStorageConfig>lambdaQuery())) {
            boolean target = driver.name().equals(item.getDriver());
            item.setIsActive(target ? 1 : 0);
            if (target) {
                // AK/SK 加密落库，不明文保存
                item.setConfigJson(encryptSecrets(json));
            }
            updateById(item);
        }

        storageFactory.switchDriver(driver);
    }

    private void markTestResult(StorageDriver driver, Map<String, String> params, boolean passed) {
        SysStorageConfig config = getOne(Wrappers.<SysStorageConfig>lambdaQuery()
                .eq(SysStorageConfig::getDriver, driver.name()));
        if (config == null) {
            config = new SysStorageConfig();
            config.setDriver(driver.name());
            config.setConfigJson(encryptSecrets(toJson(mergeWithStored(driver, params))));
            config.setIsActive(0);
            config.setTestPassed(passed ? 1 : 0);
            config.setTestTime(LocalDateTime.now());
            save(config);
            return;
        }
        if (!passed) {
            update(Wrappers.<SysStorageConfig>lambdaUpdate()
                    .eq(SysStorageConfig::getId, config.getId())
                    .set(SysStorageConfig::getTestPassed, 0)
                    .set(SysStorageConfig::getTestTime, LocalDateTime.now()));
            return;
        }
        config.setConfigJson(encryptSecrets(toJson(mergeWithStored(driver, params))));
        config.setTestPassed(1);
        config.setTestTime(LocalDateTime.now());
        updateById(config);
    }

    /** 前端未改动的密钥（回显为 ****）沿用库中密文 */
    private Map<String, String> mergeWithStored(StorageDriver driver, Map<String, String> params) {
        Map<String, String> merged = new LinkedHashMap<>();
        SysStorageConfig stored = getOne(Wrappers.<SysStorageConfig>lambdaQuery()
                .eq(SysStorageConfig::getDriver, driver.name()));
        if (stored != null) {
            merged.putAll(decryptSecrets(parse(stored.getConfigJson())));
        }
        if (params != null) {
            params.forEach((key, value) -> {
                if (value == null) {
                    return;
                }
                if (value.startsWith(SECRET_MASK) && merged.containsKey(key)) {
                    return;
                }
                merged.put(key, value);
            });
        }
        return merged;
    }

    private Map<String, String> parse(String json) {
        if (json == null || json.isBlank()) {
            return new LinkedHashMap<>();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<LinkedHashMap<String, String>>() {
            });
        } catch (Exception e) {
            return new LinkedHashMap<>();
        }
    }

    private String toJson(Map<String, String> map) {
        try {
            return objectMapper.writeValueAsString(map);
        } catch (Exception e) {
            throw new BizException("存储配置序列化失败");
        }
    }

    private Map<String, String> maskSecrets(Map<String, String> params) {
        Map<String, String> masked = new LinkedHashMap<>();
        params.forEach((key, value) -> masked.put(key, isSecret(key) ? SECRET_MASK : value));
        return masked;
    }

    private String encryptSecrets(String json) {
        Map<String, String> map = parse(json);
        map.replaceAll((key, value) -> isSecret(key) && value != null && !value.isBlank()
                && !value.startsWith(SECRET_MASK) ? aesUtils.encrypt(value) : value);
        return toJson(map);
    }

    private Map<String, String> decryptSecrets(Map<String, String> map) {
        Map<String, String> result = new LinkedHashMap<>();
        map.forEach((key, value) -> {
            if (isSecret(key) && value != null && !value.isBlank()) {
                try {
                    result.put(key, aesUtils.decrypt(value));
                } catch (Exception e) {
                    result.put(key, value);
                }
            } else {
                result.put(key, value);
            }
        });
        return result;
    }

    private boolean isSecret(String key) {
        String lower = key.toLowerCase();
        return lower.contains("secret") || lower.contains("accesskey") || lower.contains("apiv3")
                || lower.contains("privatekey") || lower.contains("secretid");
    }
}
