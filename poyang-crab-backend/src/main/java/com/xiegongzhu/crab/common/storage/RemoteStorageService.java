package com.xiegongzhu.crab.common.storage;

import com.xiegongzhu.crab.common.storage.dto.StorageResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.multipart.MultipartFile;

/**
 * S3 / OSS / COS / MinIO 远程驱动骨架。
 *
 * TODO(T12) 按部署需要接入官方 SDK：
 *   S3   -> software.amazon.awssdk:s3
 *   OSS  -> com.aliyun.oss:aliyun-sdk-oss
 *   COS  -> com.qcloud:cos_api
 *   MinIO-> io.minio:minio
 * 接入后仅需替换本类方法体，上层 StorageService / StorageFactory 调用方无需改动。
 */
public class RemoteStorageService implements StorageService {

    private static final Logger log = LoggerFactory.getLogger(RemoteStorageService.class);

    private final StorageDriver driver;
    private final String endpoint;
    private final String bucket;
    private final String domain;

    public RemoteStorageService(StorageDriver driver, String endpoint, String bucket, String domain) {
        this.driver = driver;
        this.endpoint = endpoint;
        this.bucket = bucket;
        this.domain = domain;
    }

    @Override
    public StorageDriver driver() {
        return driver;
    }

    @Override
    public boolean testConnection() {
        // TODO(T12) 调用各云厂商 listBuckets / bucketExists 校验
        log.info("[{}] 连接测试（骨架），endpoint={} bucket={}", driver, endpoint, bucket);
        return endpoint != null && !endpoint.isBlank() && bucket != null && !bucket.isBlank();
    }

    @Override
    public StorageResult upload(MultipartFile file, String bizType) {
        throw new UnsupportedOperationException(
                driver + " 驱动尚未接入 SDK，请先在 sys_storage_config 配置并实现 RemoteStorageService");
    }

    @Override
    public void delete(String objectKey) {
        throw new UnsupportedOperationException(driver + " 驱动尚未接入 SDK");
    }

    @Override
    public String buildUrl(String objectKey) {
        if (domain != null && !domain.isBlank()) {
            return domain.endsWith("/") ? domain + objectKey : domain + "/" + objectKey;
        }
        return endpoint + "/" + bucket + "/" + objectKey;
    }
}
