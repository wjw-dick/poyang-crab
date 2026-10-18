package com.xiegongzhu.crab.module.logistics.controller;

import com.xiegongzhu.crab.common.annotation.RateLimit;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.module.logistics.service.SfExpressService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * T21/T24 物流轨迹查询（小程序 / H5 共用）
 * 与后台发货端写入的 order_delivery.track_json 对应，避免每次直连顺丰。
 */
@RestController
@RequestMapping("/logistics")
public class LogisticsController {

    private final SfExpressService sfExpressService;

    public LogisticsController(SfExpressService sfExpressService) {
        this.sfExpressService = sfExpressService;
    }

    /** 顺丰冷链物流轨迹 */
    @RateLimit(limit = 60, seconds = 60, key = "logistics:track", dimension = "IP")
    @GetMapping("/track")
    public R<List<Map<String, Object>>> track(@RequestParam String expressNo) {
        return R.ok(sfExpressService.queryRoutes(expressNo));
    }

    /** 面单打印地址（发货端调用） */
    @GetMapping("/waybill")
    public R<String> waybill(@RequestParam String expressNo) {
        return R.ok(sfExpressService.printWaybill(expressNo));
    }
}
