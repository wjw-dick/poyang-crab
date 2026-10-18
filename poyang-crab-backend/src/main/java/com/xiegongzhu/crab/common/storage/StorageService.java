package com.xiegongzhu.crab.common.storage;

import com.xiegongzhu.crab.common.storage.dto.StorageResult;
import org.springframework.web.multipart.MultipartFile;

/**
 * 对象存储统一接口：驱动实现由 StorageFactory 按系统当前启用驱动选择
 */
public interface StorageService {

    StorageDriver driver();

    /** 连接测试（配置页「连接测试」通过后才允许「保存并应用」） */
    boolean testConnection();

    StorageResult upload(MultipartFile file, String bizType);

    void delete(String objectKey);

    String buildUrl(String objectKey);
}
