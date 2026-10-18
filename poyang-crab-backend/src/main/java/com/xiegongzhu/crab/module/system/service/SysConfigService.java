package com.xiegongzhu.crab.module.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.xiegongzhu.crab.module.system.entity.SysConfig;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * T08 系统全局参数可视化配置（站点/ICP/客服/微信/支付/存储/业务比例）
 * 金额与比例一律从此处读取，禁止写死。
 */
public interface SysConfigService extends IService<SysConfig> {

    /** 按分组返回，供配置页分 tab 渲染 */
    Map<String, List<SysConfig>> grouped();

    /** 分组批量保存（密钥类字段加密落库） */
    void saveGrouped(Map<String, String> keyValues);

    String getString(String configKey, String defaultValue);

    BigDecimal getDecimal(String configKey, BigDecimal defaultValue);

    Integer getInt(String configKey, Integer defaultValue);

    Boolean getBool(String configKey, Boolean defaultValue);
}
