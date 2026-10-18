package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.common.storage.StorageDriver;
import com.xiegongzhu.crab.module.system.dto.StorageDriverVO;
import com.xiegongzhu.crab.module.system.entity.SysStorageConfig;
import com.xiegongzhu.crab.module.system.service.SysStorageConfigService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * T12 对象存储配置页：先选驱动卡片 → 动态滑出参数表单（未选中不渲染）
 * → AK/SK 密码框（眼睛切换）→ 连接测试通过才可「保存并应用」→ 切换驱动二次确认
 */
@RestController
@RequestMapping("/system/storage")
public class SysStorageConfigController extends BaseCrudController<SysStorageConfig, SysStorageConfigService> {

    @GetMapping("/drivers")
    public R<List<StorageDriverVO>> drivers() {
        return R.ok(service.drivers());
    }

    @AuditLog(module = "对象存储", operation = "QUERY")
    @PostMapping("/test")
    public R<Boolean> test(@RequestParam StorageDriver driver,
                           @RequestBody(required = false) Map<String, String> params) {
        return R.ok(service.testConnection(driver, params == null ? Map.of() : params));
    }

    @AuditLog(module = "对象存储", operation = "UPDATE")
    @PostMapping("/apply")
    public R<Void> apply(@RequestParam StorageDriver driver,
                         @RequestBody(required = false) Map<String, String> params) {
        service.saveAndApply(driver, params == null ? Map.of() : params);
        return R.ok();
    }
}
