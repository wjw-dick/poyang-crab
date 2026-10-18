package com.xiegongzhu.crab.common.security;

import lombok.Data;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

/**
 * 登录态（后台用户 / 会员 / 渠道商 复用）
 */
@Data
public class LoginUser implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 登录主体 ID：sys_user.id 或 member.id */
    private Long userId;
    private String username;
    private String nickname;
    /** MEMBER / ADMIN / CHANNEL */
    private String loginType;
    /** SUPER_ADMIN / SHOP_MANAGER / FINANCE / SHIPPER / CHANNEL / CHANNEL_ADMIN / MEMBER */
    private String roleType;
    private Long channelId;
    private Set<String> perms = new HashSet<>();

    public boolean isAdmin() {
        return "SUPER_ADMIN".equals(roleType);
    }
}
