package com.xiegongzhu.crab.module.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.xiegongzhu.crab.module.system.entity.SysDict;

import java.util.List;
import java.util.Map;

public interface SysDictService extends IService<SysDict> {

    /**
     * 一次性返回全部启用字典项，按 dictType 分组：
     * { "order_status": [ { "label": "待支付", "value": "UNPAID" }, ... ], ... }
     * 前端启动时拉一次做本地缓存，列表页/表单直接按字典类型取中文标签。
     */
    Map<String, List<Map<String, String>>> allOptions();
}
