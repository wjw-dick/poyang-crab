package com.xiegongzhu.crab.module.wechat.service;

import com.xiegongzhu.crab.module.system.service.SysConfigService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * T20 微信支付（JSAPI 下单 / 回调验签 / 退款）
 *
 * TODO(T20) 接入微信支付 APIv3：
 *   1) 商户私钥签名 Authorization（WECHATPAY2-SHA256-RSA2048）
 *   2) 平台证书/公钥验签回调
 *   3) 回调报文 AES-256-GCM 解密
 * 接入时替换本类方法体即可，调用方（OrderService / WxPayNotifyController）无需改动。
 */
@Service
public class WxPayService {

    private static final Logger log = LoggerFactory.getLogger(WxPayService.class);

    private final SysConfigService sysConfigService;

    public WxPayService(SysConfigService sysConfigService) {
        this.sysConfigService = sysConfigService;
    }

    /**
     * JSAPI 统一下单，返回小程序端 wx.requestPayment 所需参数
     */
    public Map<String, String> jsapiPay(String payNo, String openId, long amountFen, String description) {
        String mchid = sysConfigService.getString("wechat.pay.mchid", "");
        log.info("[微信支付-骨架] 下单 payNo={} mchid={} openId={} amount={}分 desc={}",
                payNo, mchid, openId, amountFen, description);

        // TODO(T20) 调用 https://api.mch.weixin.qq.com/v3/pay/transactions/jsapi 并签名
        Map<String, String> params = new LinkedHashMap<>();
        params.put("prepayId", "PREPAY_ID_PLACEHOLDER_" + payNo);
        params.put("nonceStr", "");
        params.put("timeStamp", String.valueOf(System.currentTimeMillis() / 1000));
        params.put("package", "prepay_id=" + params.get("prepayId"));
        params.put("signType", "RSA");
        params.put("paySign", "");
        return params;
    }

    /** 支付回调验签 + 解密，返回业务字段 */
    public Map<String, String> verifyNotify(String body, Map<String, String> headers) {
        log.info("[微信支付-骨架] 回调验签 body 长度={}", body == null ? 0 : body.length());
        // TODO(T20) 验签 + AES-GCM 解密后返回 { out_trade_no, transaction_id, trade_state, amount }
        return Map.of();
    }

    /** 退款 */
    public boolean refund(String payNo, long amountFen, String reason) {
        log.info("[微信支付-骨架] 退款 payNo={} amount={}分 reason={}", payNo, amountFen, reason);
        // TODO(T20) 调用 /v3/refund/domestic/refunds
        return false;
    }
}
