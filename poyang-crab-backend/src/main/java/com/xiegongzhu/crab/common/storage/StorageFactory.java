package com.xiegongzhu.crab.common.storage;

import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.redis.RedisService;
import com.xiegongzhu.crab.common.result.ResultCode;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * 驱动工厂：按「系统参数 - 当前存储驱动」动态返回实现，切换驱动无需重启
 */
@Component
public class StorageFactory {

    private static final String ACTIVE_DRIVER_KEY = "storage:active:driver";

    private final Map<StorageDriver, StorageService> services = new EnumMap<>(StorageDriver.class);
    private final RedisService redisService;

    public StorageFactory(List<StorageService> storageServices, RedisService redisService) {
        this.redisService = redisService;
        for (StorageService service : storageServices) {
            services.put(service.driver(), service);
        }
    }

    public StorageService active() {
        String driverName = redisService.get(ACTIVE_DRIVER_KEY, String.class);
        StorageDriver driver;
        try {
            driver = driverName == null ? StorageDriver.MINIO : StorageDriver.valueOf(driverName);
        } catch (IllegalArgumentException e) {
            driver = StorageDriver.LOCAL;
        }
        StorageService service = services.get(driver);
        if (service == null) {
            throw new BizException("未注册的对象存储驱动：" + driver);
        }
        return service;
    }

    public StorageService of(StorageDriver driver) {
        StorageService service = services.get(driver);
        if (service == null) {
            throw new BizException(ResultCode.STORAGE_NOT_READY, "驱动未注册：" + driver);
        }
        return service;
    }

    public void switchDriver(StorageDriver driver) {
        redisService.set(ACTIVE_DRIVER_KEY, driver.name(), Duration.ofDays(30));
    }

    public Map<StorageDriver, StorageService> all() {
        return services;
    }
}
