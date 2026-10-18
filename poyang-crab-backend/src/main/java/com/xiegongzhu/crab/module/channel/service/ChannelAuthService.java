package com.xiegongzhu.crab.module.channel.service;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.security.JwtUtils;
import com.xiegongzhu.crab.common.security.LoginUser;
import com.xiegongzhu.crab.module.channel.entity.Channel;
import com.xiegongzhu.crab.module.channel.mapper.ChannelMapper;
import com.xiegongzhu.crab.module.wechat.service.WxMiniService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * T25 渠道商端（B 端小程序）登录：
 * 按 UnionID 匹配 t_channel，签发携带 channelId / roleType=CHANNEL 的令牌。
 *
 * 与 {@link com.xiegongzhu.crab.module.member.service.MemberAuthService} 的区别：
 * - 会员登录：登录主体是 member，channelId 取会员档案；
 * - 渠道商登录：登录主体是 channel，签发 channelId 供 /channel/biz/** 做归属过滤。
 */
@Service
public class ChannelAuthService {

    private static final Logger log = LoggerFactory.getLogger(ChannelAuthService.class);

    private final ChannelMapper channelMapper;
    private final WxMiniService wxMiniService;
    private final JwtUtils jwtUtils;

    public ChannelAuthService(ChannelMapper channelMapper, WxMiniService wxMiniService, JwtUtils jwtUtils) {
        this.channelMapper = channelMapper;
        this.wxMiniService = wxMiniService;
        this.jwtUtils = jwtUtils;
    }

    /**
     * 渠道商端微信登录。
     *
     * @return token + 渠道档案（已脱敏）
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> loginByWxCode(String code) {
        String[] session = wxMiniService.code2Session(code);
        String openId = session[0];
        String unionId = session[1];
        if (unionId == null || unionId.isBlank()) {
            unionId = openId;
        }

        Channel channel = channelMapper.selectOne(Wrappers.<Channel>lambdaQuery()
                .eq(Channel::getUnionId, unionId));
        if (channel == null) {
            log.warn("渠道商登录失败：UnionID 未绑定渠道档案 unionId={}", unionId);
            throw new BizException("当前微信号未绑定渠道商档案，请联系平台管理员开通");
        }
        if ("DISABLED".equals(channel.getStatus())) {
            throw new BizException("渠道商账号已停用，请联系平台管理员");
        }

        LoginUser loginUser = new LoginUser();
        loginUser.setUserId(channel.getId());
        loginUser.setUsername(channel.getChannelNo());
        loginUser.setNickname(channel.getChannelName());
        loginUser.setLoginType("CHANNEL");
        loginUser.setRoleType("CHANNEL");
        loginUser.setChannelId(channel.getId());
        loginUser.setPerms(new HashSet<>());

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("token", jwtUtils.createToken(loginUser));
        data.put("channelId", channel.getId());
        data.put("channelNo", channel.getChannelNo());
        data.put("channelName", channel.getChannelName());
        data.put("status", channel.getStatus());
        return data;
    }
}
