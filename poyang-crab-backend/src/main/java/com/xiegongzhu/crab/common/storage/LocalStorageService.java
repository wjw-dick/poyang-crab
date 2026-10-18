package com.xiegongzhu.crab.common.storage;

import com.baomidou.mybatisplus.core.toolkit.IdWorker;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.storage.dto.StorageResult;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * 本地磁盘驱动（默认兜底可用）
 */
@Service
public class LocalStorageService implements StorageService {

    private static final DateTimeFormatter DATE_DIR = DateTimeFormatter.ofPattern("yyyy/MM/dd");

    @Value("${crab.storage.local.base-path:./data/upload}")
    private String basePath;

    @Value("${crab.storage.local.domain:http://localhost:8080/api/files}")
    private String domain;

    @Override
    public StorageDriver driver() {
        return StorageDriver.LOCAL;
    }

    @Override
    public boolean testConnection() {
        File dir = new File(basePath);
        return dir.exists() || dir.mkdirs();
    }

    @Override
    public StorageResult upload(MultipartFile file, String bizType) {
        if (file == null || file.isEmpty()) {
            throw new BizException("上传文件为空");
        }
        String originName = file.getOriginalFilename() == null ? "unknown" : file.getOriginalFilename();
        String ext = originName.contains(".") ? originName.substring(originName.lastIndexOf('.')) : "";
        String objectKey = (bizType == null ? "common" : bizType) + "/"
                + LocalDate.now().format(DATE_DIR) + "/" + IdWorker.getIdStr() + ext;
        try {
            File target = new File(basePath, objectKey);
            Files.createDirectories(target.getParentFile().toPath());
            try (var in = file.getInputStream()) {
                Files.copy(in, target.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (Exception e) {
            throw new BizException("本地文件写入失败：" + e.getMessage());
        }
        return new StorageResult(objectKey, buildUrl(objectKey), file.getSize(),
                file.getContentType(), originName);
    }

    @Override
    public void delete(String objectKey) {
        try {
            Files.deleteIfExists(new File(basePath, objectKey).toPath());
        } catch (Exception ignored) {
            // 删除失败不阻断业务
        }
    }

    @Override
    public String buildUrl(String objectKey) {
        return domain.endsWith("/") ? domain + objectKey : domain + "/" + objectKey;
    }
}
