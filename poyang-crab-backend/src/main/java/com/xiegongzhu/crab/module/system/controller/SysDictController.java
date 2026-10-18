package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.module.system.entity.SysDict;
import com.xiegongzhu.crab.module.system.service.SysDictService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * 字典类型 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/system/dict")
public class SysDictController extends BaseCrudController<SysDict, SysDictService> {

    /**
     * 全部启用字典项（按 dictType 分组）。
     * 路径为字面量 /options，Spring 优先匹配字面量，不会与基类 /{id} 冲突。
     */
    @GetMapping("/options")
    public R<Map<String, List<Map<String, String>>>> options() {
        return R.ok(service.allOptions());
    }
}
