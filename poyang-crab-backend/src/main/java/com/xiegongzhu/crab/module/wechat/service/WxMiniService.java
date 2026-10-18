package com.xiegongzhu.crab.module.wechat.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.module.system.service.SysConfigService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

/**
 * T18 微信小程序登录：code2Session 换取 openid / unionid（会员 UnionID 互通）
 */
@Service
public class WxMiniService {

    private static final Logger log = LoggerFactory.getLogger(WxMiniService.class);
    private static final String CODE2SESSION_URL =
            "https://api.weixin.qq.com/sns/jscode2session?appid=%s&secret=%s&js_code=%s&grant_type=authorization_code";

    private final RestTemplate restTemplate;
    private final SysConfigService sysConfigService;
    private final ObjectMapper objectMapper;

    public WxMiniService(RestTemplate restTemplate, SysConfigService sysConfigService,
                         ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.sysConfigService = sysConfigService;
        this.objectMapper = objectMapper;
    }

    /**
     * @return [openid, unionid, sessionKey]
     */
    public String[] code2Session(String code) {
        String appid = sysConfigService.getString("wechat.mini.appid", "");
        String secret = sysConfigService.getString("wechat.mini.secret", "");
        if (appid.isBlank() || secret.isBlank()) {
            throw new BizException("小程序 AppID/Secret 未配置，请在系统参数中维护");
        }
        String body = restTemplate.getForObject(
                String.format(CODE2SESSION_URL, appid, secret, code), String.class);
        try {
            JsonNode node = objectMapper.readTree(body);
            if (node.hasNonNull("errcode") && node.path("errcode").asInt() != 0) {
                throw new BizException("微信登录失败：" + node.path("errmsg").asText());
            }
            String openid = node.path("openid").asText(null);
            String unionid = node.path("unionid").asText(null);
            String sessionKey = node.path("session_key").asText(null);
            if (openid == null) {
                throw new BizException("微信登录失败：未返回 openid");
            }
            return new String[]{openid, unionid, sessionKey};
        } catch (BizException e) {
            throw e;
        } catch (Exception e) {
            log.error("code2Session 解析失败: {}", body);
            throw new BizException("微信登录失败");
        }
    }
}
