package com.xiegongzhu.crab.common.security;

import com.xiegongzhu.crab.common.result.ResultCode;
import com.xiegongzhu.crab.common.exception.BizException;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 登录拦截：解析 JWT 写入 CurrentUserHolder；权限标识校验由各 Controller 的 @PreAuthorize 语义完成
 * （脚手架阶段以角色/权限标识判断，见 PermissionChecker）
 */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final JwtUtils jwtUtils;

    public AuthInterceptor(JwtUtils jwtUtils) {
        this.jwtUtils = jwtUtils;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }
        String token = jwtUtils.resolveToken(request.getHeader(JwtUtils.HEADER));
        if (token == null) {
            throw new BizException(ResultCode.UNAUTHORIZED);
        }
        try {
            CurrentUserHolder.set(jwtUtils.parseToken(token));
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            throw new BizException(ResultCode.UNAUTHORIZED);
        }
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        CurrentUserHolder.clear();
    }
}
