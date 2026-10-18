package com.xiegongzhu.crab.common.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;
import java.util.Map;

/**
 * JWT 令牌：后台 / 会员 / 渠道商 三端共用同一签发逻辑
 */
@Component
public class JwtUtils {

    public static final String HEADER = "Authorization";
    public static final String PREFIX = "Bearer ";

    private final Key key;
    private final long expireMillis;

    public JwtUtils(@Value("${crab.jwt.secret}") String secret,
                    @Value("${crab.jwt.expire-hours:24}") long expireHours) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expireMillis = expireHours * 60 * 60 * 1000;
    }

    public String createToken(LoginUser user) {
        Date now = new Date();
        return Jwts.builder()
                .setSubject(String.valueOf(user.getUserId()))
                .claim("username", user.getUsername())
                .claim("loginType", user.getLoginType())
                .claim("roleType", user.getRoleType())
                .claim("channelId", user.getChannelId())
                .setIssuedAt(now)
                .setExpiration(new Date(now.getTime() + expireMillis))
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public LoginUser parseToken(String token) {
        Claims claims = Jwts.parserBuilder().setSigningKey(key).build()
                .parseClaimsJws(token).getBody();
        LoginUser user = new LoginUser();
        user.setUserId(Long.valueOf(claims.getSubject()));
        user.setUsername(claims.get("username", String.class));
        user.setLoginType(claims.get("loginType", String.class));
        user.setRoleType(claims.get("roleType", String.class));
        Object channelId = claims.get("channelId");
        if (channelId instanceof Number n) {
            user.setChannelId(n.longValue());
        }
        Map<String, Object> all = claims;
        user.setNickname(all.get("username") == null ? null : String.valueOf(all.get("username")));
        return user;
    }

    public String resolveToken(String headerValue) {
        if (headerValue == null || headerValue.isBlank()) {
            return null;
        }
        return headerValue.startsWith(PREFIX) ? headerValue.substring(PREFIX.length()) : headerValue;
    }
}
