package com.xiegongzhu.crab.common.storage;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 5 驱动注册：LOCAL 为 @Service，其余以 Bean 形式注册供 StorageFactory 选择
 */
@Configuration
public class StorageConfig {

    @Bean
    public StorageService s3StorageService() {
        return new RemoteStorageService(StorageDriver.S3, "", "", "");
    }

    @Bean
    public StorageService ossStorageService() {
        return new RemoteStorageService(StorageDriver.OSS, "", "", "");
    }

    @Bean
    public StorageService cosStorageService() {
        return new RemoteStorageService(StorageDriver.COS, "", "", "");
    }

    @Bean
    public StorageService minioStorageService() {
        return new RemoteStorageService(StorageDriver.MINIO, "http://minio:9000", "xiegongzhu", "");
    }
}
