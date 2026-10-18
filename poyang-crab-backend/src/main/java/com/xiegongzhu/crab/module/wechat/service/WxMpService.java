package com.xiegongzhu.crab.module.wechat.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.xiegongzhu.crab.common.redis.RedisService;
import com.xiegongzhu.crab.module.system.service.SysConfigService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.util.Map;

/**
 * T17 微信服务号：UnionID 会员互通 / 模板消息推送（订单、发货、物流通知）
 */
@Service
public class WxMpService {

    private static final Logger log = LoggerFactory.getLogger(WxMpService.class);
    private static final String TOKEN_KEY = "wx:mp:access_token";
    private static final String TOKEN_URL =
            "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s";
    private static final String TEMPLATE_URL =
            "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=%s";

    private final RestTemplate restTemplate;
    private final RedisService redisService;
    private final SysConfigService sysConfigService;
    private final ObjectMapper objectMapper;

    public WxMpService(RestTemplate restTemplate, RedisService redisService,
                       SysConfigService sysConfigService, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.redisService = redisService;
        this.sysConfigService = sysConfigService;
        this.objectMapper = objectMapper;
    }

    /** access_token：Redis 缓存，避免频繁刷新 */
    public String accessToken() {
        String cached = redisService.get(TOKEN_KEY, String.class);
        if (cached != null) {
            return cached;
        }
        String appid = sysConfigService.getString("wechat.mp.appid", "");
        String secret = sysConfigService.getString("wechat.mp.secret", "");
        if (appid.isBlank() || secret.isBlank()) {
            log.warn("公众号 AppID/Secret 未配置，模板消息不会真实下发");
            return null;
        }
        String body = restTemplate.getForObject(String.format(TOKEN_URL, appid, secret), String.class);
        try {
            JsonNode node = objectMapper.readTree(body);
            String token = node.path("access_token").asText(null);
            if (token != null) {
                redisService.set(TOKEN_KEY, token, Duration.ofSeconds(7000));
            }
            return token;
        } catch (Exception e) {
            log.error("获取公众号 access_token 失败: {}", body);
            return null;
        }
    }

    /**
     * 模板消息推送（订单支付成功 / 已发货 / 物流更新）
     * templateData 形如 { "first": {"value":"..."}, "keyword1": {"value":"..."} }
     */
    public boolean sendTemplateMessage(String openId, String templateId, String url,
                                       Map<String, Object> templateData) {
        String token = accessToken();
        if (token == null || openId == null || templateId == null || templateId.isBlank()) {
            log.info("[模板消息-骨架] openId={} templateId={} data={}", openId, templateId, templateData);
            return false;
        }
        Map<String, Object> payload = Map.of(
                "touser", openId,
                "template_id", templateId,
                "url", url == null ? "" : url,
                "data", templateData);
        try {
            String body = restTemplate.postForObject(String.format(TEMPLATE_URL, token),
                    payload, String.class);
            return body != null && body.contains("\"errcode\":0");
        } catch (Exception e) {
            log.error("模板消息推送失败 openId={}", openId, e);
            return false;
        }
    }
}
