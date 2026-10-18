package com.xiegongzhu.crab.common.storage;

/**
 * T12 对象存储 5 驱动（后台卡片单选，未选中驱动的参数完全不渲染）
 */
public enum StorageDriver {

    LOCAL("本地磁盘"),
    S3("Amazon S3 / 兼容 S3"),
    OSS("阿里云 OSS"),
    COS("腾讯云 COS"),
    MINIO("MinIO");

    private final String label;

    StorageDriver(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
