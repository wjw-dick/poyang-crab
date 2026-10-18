package com.xiegongzhu.crab.module.system.dto;

import com.xiegongzhu.crab.common.storage.StorageDriver;
import lombok.Data;

/**
 * 对象存储驱动卡片（顶部 5 张等大卡片单选）
 */
@Data
public class StorageDriverVO {

    private StorageDriver driver;
    private String label;
    /** 未被选中的驱动不返回参数，前端完全不渲染 */
    private java.util.Map<String, String> params;
    private Boolean active;
    private Boolean testPassed;
}
