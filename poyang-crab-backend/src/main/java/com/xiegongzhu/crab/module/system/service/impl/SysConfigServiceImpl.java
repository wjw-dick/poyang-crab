package com.xiegongzhu.crab.module.system.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.common.redis.RedisService;
import com.xiegongzhu.crab.common.util.AesUtils;
import com.xiegongzhu.crab.module.system.entity.SysConfig;
import com.xiegongzhu.crab.module.system.mapper.SysConfigMapper;
import com.xiegongzhu.crab.module.system.service.SysConfigService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class SysConfigServiceImpl extends ServiceImpl<SysConfigMapper, SysConfig> implements SysConfigService {

    private static final String CACHE_KEY = "sys:config:";

    private final RedisService redisService;
    private final AesUtils aesUtils;

    public SysConfigServiceImpl(RedisService redisService, AesUtils aesUtils) {
        this.redisService = redisService;
        this.aesUtils = aesUtils;
    }

    @Override
    public Map<String, List<SysConfig>> grouped() {
        List<SysConfig> all = list(Wrappers.<SysConfig>lambdaQuery().orderByAsc(SysConfig::getSort));
        Map<String, List<SysConfig>> result = new LinkedHashMap<>();
        for (SysConfig config : all) {
            String group = config.getConfigGroup() == null ? "OTHER" : config.getConfigGroup();
            result.computeIfAbsent(group, k -> new java.util.ArrayList<>()).add(maskIfNeeded(config));
        }
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveGrouped(Map<String, String> keyValues) {
        if (keyValues == null || keyValues.isEmpty()) {
            return;
        }
        List<SysConfig> existing = list(Wrappers.<SysConfig>lambdaQuery()
                .in(SysConfig::getConfigKey, keyValues.keySet()));
        Map<String, SysConfig> byKey = existing.stream()
                .collect(Collectors.toMap(SysConfig::getConfigKey, config -> config));
        for (Map.Entry<String, String> entry : keyValues.entrySet()) {
            SysConfig config = byKey.get(entry.getKey());
            if (config == null) {
                continue;
            }
            String value = entry.getValue();
            // 脱敏回显值（****开头的掩码）不覆盖原密钥
            if (config.getIsEncrypted() != null && config.getIsEncrypted() == 1
                    && value != null && value.startsWith("****")) {
                continue;
            }
            config.setConfigValue(config.getIsEncrypted() != null && config.getIsEncrypted() == 1
                    ? aesUtils.encrypt(value) : value);
            updateById(config);
            redisService.delete(CACHE_KEY + config.getConfigKey());
        }
    }

    @Override
    public String getString(String configKey, String defaultValue) {
        String value = redisService.getOrLoad(CACHE_KEY + configKey, Duration.ofMinutes(10), () -> {
            SysConfig config = getOne(Wrappers.<SysConfig>lambdaQuery()
                    .eq(SysConfig::getConfigKey, configKey));
            return config == null ? null : config.getConfigValue();
        });
        return value == null ? defaultValue : value;
    }

    @Override
    public BigDecimal getDecimal(String configKey, BigDecimal defaultValue) {
        String value = getString(configKey, null);
        return value == null || value.isBlank() ? defaultValue : new BigDecimal(value);
    }

    @Override
    public Integer getInt(String configKey, Integer defaultValue) {
        String value = getString(configKey, null);
        return value == null || value.isBlank() ? defaultValue : Integer.valueOf(value);
    }

    @Override
    public Boolean getBool(String configKey, Boolean defaultValue) {
        String value = getString(configKey, null);
        return value == null || value.isBlank() ? defaultValue : Boolean.valueOf(value);
    }

    private SysConfig maskIfNeeded(SysConfig config) {
        if (config.getIsEncrypted() != null && config.getIsEncrypted() == 1
                && config.getConfigValue() != null && !config.getConfigValue().isBlank()) {
            try {
                config.setConfigValue(aesUtils.mask(aesUtils.decrypt(config.getConfigValue())));
            } catch (Exception ignored) {
                config.setConfigValue("****");
            }
        }
        return config;
    }
}
