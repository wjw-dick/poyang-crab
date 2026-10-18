package com.xiegongzhu.crab.module.system.dto;

import lombok.Data;

import java.util.Set;

/**
 * 登录返回：令牌 + 用户概览 + 权限标识集合
 */
@Data
public class LoginResponse {

    private String token;
    private Long userId;
    private String username;
    private String nickname;
    private String roleType;
    private Long channelId;
    private Set<String> perms;
}
