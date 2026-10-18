package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.annotation.RateLimit;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.common.result.ResultCode;
import com.xiegongzhu.crab.common.security.JwtUtils;
import com.xiegongzhu.crab.common.security.LoginUser;
import com.xiegongzhu.crab.module.system.dto.LoginRequest;
import com.xiegongzhu.crab.module.system.dto.LoginResponse;
import com.xiegongzhu.crab.module.system.service.SysUserService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * T07 登录：后台账号密码登录（微信 UnionID 登录见 WxAuthController）
 */
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final SysUserService sysUserService;
    private final JwtUtils jwtUtils;

    public AuthController(SysUserService sysUserService, JwtUtils jwtUtils) {
        this.sysUserService = sysUserService;
        this.jwtUtils = jwtUtils;
    }

    @RateLimit(limit = 10, seconds = 60, key = "auth:login", dimension = "IP")
    @AuditLog(module = "认证中心", operation = "LOGIN", saveParam = false)
    @PostMapping("/login")
    public R<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return R.ok(sysUserService.login(request));
    }

    /**
     * 当前登录用户信息：前端刷新页面后靠本接口恢复权限标识（perms 不在 JWT 内）。
     * /auth/** 在白名单内，故此处自行校验令牌。
     */
    @GetMapping("/profile")
    public R<LoginUser> profile(@RequestHeader(value = JwtUtils.HEADER, required = false) String header) {
        String token = jwtUtils.resolveToken(header);
        if (token == null) {
            throw new BizException(ResultCode.UNAUTHORIZED);
        }
        return R.ok(sysUserService.profile(jwtUtils.parseToken(token)));
    }

    @AuditLog(module = "认证中心", operation = "LOGOUT", saveParam = false)
    @PostMapping("/logout")
    public R<Void> logout() {
        // JWT 无状态：前端清除令牌即可；如需强制下线可在此写入 Redis 黑名单
        return R.ok();
    }
}
