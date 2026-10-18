package com.xiegongzhu.crab.module.system.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 登录入参：ADMIN（后台）/ MEMBER（会员）/ CHANNEL（渠道商）
 */
@Data
public class LoginRequest {

    @NotBlank(message = "登录名不能为空")
    private String username;

    @NotBlank(message = "密码不能为空")
    private String password;

    /** 默认后台登录 */
    private String loginType = "ADMIN";

    /** 微信登录：小程序/公众号 code（UnionID 互通） */
    private String wxCode;
}
