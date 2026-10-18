package com.xiegongzhu.crab.module.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * T12 对象存储配置（AK/SK 以密文写入 configJson）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_storage_config")
public class SysStorageConfig extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /** LOCAL / S3 / OSS / COS / MINIO */
    private String driver;
    private String configJson;
    private Integer isActive;
    /** 连接测试通过才允许启用 */
    private Integer testPassed;
    private LocalDateTime testTime;
}
