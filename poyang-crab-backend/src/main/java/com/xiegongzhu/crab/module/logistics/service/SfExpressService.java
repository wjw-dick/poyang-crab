package com.xiegongzhu.crab.module.logistics.service;

import com.xiegongzhu.crab.module.system.service.SysConfigService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

/**
 * T21/T24 顺丰冷链：电子面单下单 + 物流轨迹查询
 *
 * TODO(T21) 接入顺丰丰桥开放平台：
 *   EXP_RECE_CREATE_ORDER（下单选号）/ EXP_RECE_SEARCH_ROUTES（路由查询）
 *   需要 partnerID + checkword（业务校验码）+ 月结卡号，均从系统参数读取。
 */
@Service
public class SfExpressService {

    private static final Logger log = LoggerFactory.getLogger(SfExpressService.class);

    private final RestTemplate restTemplate;
    private final SysConfigService sysConfigService;

    @Value("${crab.sf.endpoint}")
    private String endpoint;

    public SfExpressService(RestTemplate restTemplate, SysConfigService sysConfigService) {
        this.restTemplate = restTemplate;
        this.sysConfigService = sysConfigService;
    }

    /**
     * 冷链下单：返回运单号（发货端打印面单后回填）
     */
    public String createColdChainOrder(String orderNo, String receiverName, String receiverMobile,
                                       String receiverAddress, int pieceCount) {
        log.info("[顺丰-骨架] 冷链下单 endpoint={} orderNo={} 件数={}", endpoint, orderNo, pieceCount);
        // TODO(T21) POST {endpoint}/std/service  serviceCode=EXP_RECE_CREATE_ORDER
        return "SF" + System.currentTimeMillis();
    }

    /**
     * 物流轨迹查询（小程序「冷链物流轨迹」展示）
     */
    public List<Map<String, Object>> queryRoutes(String expressNo) {
        log.info("[顺丰-骨架] 轨迹查询 expressNo={}", expressNo);
        // TODO(T21) POST {endpoint}/std/service  serviceCode=EXP_RECE_SEARCH_ROUTES
        return List.of(Map.of(
                "acceptTime", "—",
                "remark", "冷链运输中（骨架数据，待接入顺丰接口）"));
    }

    /** 快递单打印（发货端调用，返回面单 PDF/图片地址） */
    public String printWaybill(String expressNo) {
        log.info("[顺丰-骨架] 面单打印 expressNo={}", expressNo);
        return "";
    }
}
