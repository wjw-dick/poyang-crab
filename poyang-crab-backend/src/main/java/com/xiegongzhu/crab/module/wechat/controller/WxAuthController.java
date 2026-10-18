package com.xiegongzhu.crab.module.wechat.controller;

import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.annotation.RateLimit;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.module.channel.service.ChannelAuthService;
import com.xiegongzhu.crab.module.member.entity.Member;
import com.xiegongzhu.crab.module.member.service.MemberAuthService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * T18 小程序 / T17 公众号 / T23 H5 微信登录（UnionID 会员互通）
 * T25 渠道商端（B 端）登录：source=CHANNEL 时按 UnionID 匹配渠道档案并签发 CHANNEL 令牌。
 */
@RestController
@RequestMapping("/wx")
public class WxAuthController {

    private final MemberAuthService memberAuthService;
    private final ChannelAuthService channelAuthService;

    public WxAuthController(MemberAuthService memberAuthService, ChannelAuthService channelAuthService) {
        this.memberAuthService = memberAuthService;
        this.channelAuthService = channelAuthService;
    }

    @RateLimit(limit = 30, seconds = 60, key = "wx:login", dimension = "IP")
    @AuditLog(module = "认证中心", operation = "LOGIN", saveParam = false)
    @PostMapping("/login")
    public R<Map<String, Object>> login(@RequestParam String code,
                                        @RequestParam(defaultValue = "MINIAPP") String source) {
        // 渠道商端走独立登录链路（channelId 必须写入令牌，供 /channel/biz/** 归属过滤）
        if ("CHANNEL".equalsIgnoreCase(source)) {
            return R.ok(channelAuthService.loginByWxCode(code));
        }

        Member member = memberAuthService.loginByWxCode(code, source);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("token", memberAuthService.createToken(member));
        data.put("memberId", member.getId());
        data.put("nickname", member.getNickname());
        data.put("avatar", member.getAvatar());
        data.put("points", member.getPoints());
        data.put("balance", member.getBalance());
        return R.ok(data);
    }
}
