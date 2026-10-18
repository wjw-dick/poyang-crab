package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.common.sensitive.SensitiveWordService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * T31 敏感词词库刷新（新增/导入后立即生效）
 */
@RestController
@RequestMapping("/system/sensitive-word")
public class SensitiveWordController {

    private final SensitiveWordService sensitiveWordService;

    public SensitiveWordController(SensitiveWordService sensitiveWordService) {
        this.sensitiveWordService = sensitiveWordService;
    }

    @AuditLog(module = "敏感词", operation = "UPDATE")
    @PostMapping("/refresh")
    public R<Void> refresh() {
        sensitiveWordService.refresh();
        return R.ok();
    }
}
