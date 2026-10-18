package com.xiegongzhu.crab.module.member.service;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.security.JwtUtils;
import com.xiegongzhu.crab.common.security.LoginUser;
import com.xiegongzhu.crab.module.member.entity.Member;
import com.xiegongzhu.crab.module.member.mapper.MemberMapper;
import com.xiegongzhu.crab.module.wechat.service.WxMiniService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;

/**
 * T18/T17 会员 UnionID 互通登录：
 * 小程序 / 公众号 / H5 三端同一 UnionID 视为同一会员，自动注册。
 */
@Service
public class MemberAuthService {

    private static final Logger log = LoggerFactory.getLogger(MemberAuthService.class);

    private final MemberMapper memberMapper;
    private final WxMiniService wxMiniService;
    private final JwtUtils jwtUtils;

    public MemberAuthService(MemberMapper memberMapper, WxMiniService wxMiniService, JwtUtils jwtUtils) {
        this.memberMapper = memberMapper;
        this.wxMiniService = wxMiniService;
        this.jwtUtils = jwtUtils;
    }

    /**
     * @param source MINIAPP（小程序）/ MP（公众号）/ H5
     * @return 会员令牌
     */
    @Transactional(rollbackFor = Exception.class)
    public Member loginByWxCode(String code, String source) {
        String[] session = wxMiniService.code2Session(code);
        String openId = session[0];
        String unionId = session[1];
        if (unionId == null || unionId.isBlank()) {
            // 未绑定开放平台时退化为 openId 维度，仍保证同一来源可复用
            log.warn("code2Session 未返回 unionid，暂以 openid 维度识别会员");
            unionId = openId;
        }
        Member member = memberMapper.selectOne(Wrappers.<Member>lambdaQuery()
                .eq(Member::getUnionId, unionId));
        if (member == null) {
            member = new Member();
            member.setUnionId(unionId);
            member.setMemberLevel("NORMAL");
            member.setPoints(0);
            member.setStatus(1);
            member.setGender(0);
            member.setChannelId(0L);
            member.setBalance(java.math.BigDecimal.ZERO);
            bindOpenId(member, source, openId);
            memberMapper.insert(member);
        } else {
            bindOpenId(member, source, openId);
            memberMapper.updateById(member);
        }
        return member;
    }

    public LoginUser toLoginUser(Member member) {
        LoginUser loginUser = new LoginUser();
        loginUser.setUserId(member.getId());
        loginUser.setUsername(member.getNickname());
        loginUser.setNickname(member.getNickname());
        loginUser.setLoginType("MEMBER");
        loginUser.setRoleType("MEMBER");
        loginUser.setChannelId(member.getChannelId());
        loginUser.setPerms(new HashSet<>());
        return loginUser;
    }

    public String createToken(Member member) {
        return jwtUtils.createToken(toLoginUser(member));
    }

    public Member requireMember(Long memberId) {
        Member member = memberMapper.selectById(memberId);
        if (member == null) {
            throw new BizException("会员不存在");
        }
        return member;
    }

    private void bindOpenId(Member member, String source, String openId) {
        switch (source == null ? "MINIAPP" : source.toUpperCase()) {
            case "MP" -> member.setOpenIdMp(openId);
            case "H5" -> member.setOpenIdH5(openId);
            default -> member.setOpenIdMini(openId);
        }
    }
}
