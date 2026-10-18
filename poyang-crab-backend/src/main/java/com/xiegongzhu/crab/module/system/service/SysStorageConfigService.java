package com.xiegongzhu.crab.module.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.xiegongzhu.crab.common.storage.StorageDriver;
import com.xiegongzhu.crab.module.system.dto.StorageDriverVO;
import com.xiegongzhu.crab.module.system.entity.SysStorageConfig;

import java.util.List;
import java.util.Map;

/**
 * T12 对象存储配置：5 驱动卡片单选 → 动态参数表单 → AK/SK 密码框 → 连接测试 → 保存并应用
 */
public interface SysStorageConfigService extends IService<SysStorageConfig> {

    /** 5 张等大卡片数据（含当前启用驱动） */
    List<StorageDriverVO> drivers();

    /** 连接测试（不落库，仅校验参数可用性） */
    boolean testConnection(StorageDriver driver, Map<String, String> params);

    /** 保存并应用：必须已通过连接测试，否则拒绝（前端二次确认切换驱动） */
    void saveAndApply(StorageDriver driver, Map<String, String> params);
}
