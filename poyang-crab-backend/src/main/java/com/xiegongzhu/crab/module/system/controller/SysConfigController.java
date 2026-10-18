package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.module.system.entity.SysConfig;
import com.xiegongzhu.crab.module.system.service.SysConfigService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * T08 系统参数配置页接口：站点 / ICP / 客服 / 微信 / 支付 / 存储 / 业务比例
 */
@RestController
@RequestMapping("/system/config")
public class SysConfigController extends BaseCrudController<SysConfig, SysConfigService> {

    /** 分组返回，前端按 tab 渲染；密钥字段返回掩码 */
    @GetMapping("/grouped")
    public R<Map<String, List<SysConfig>>> grouped() {
        return R.ok(service.grouped());
    }

    /** 分组保存（密钥字段加密落库） */
    @AuditLog(module = "系统参数", operation = "UPDATE")
    @PostMapping("/save-grouped")
    public R<Void> saveGrouped(@RequestBody Map<String, String> keyValues) {
        service.saveGrouped(keyValues);
        return R.ok();
    }
}
