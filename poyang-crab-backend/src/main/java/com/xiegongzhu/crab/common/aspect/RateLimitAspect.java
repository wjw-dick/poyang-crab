package com.xiegongzhu.crab.common.aspect;

import com.xiegongzhu.crab.common.annotation.RateLimit;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.redis.RedisService;
import com.xiegongzhu.crab.common.result.ResultCode;
import com.xiegongzhu.crab.common.security.CurrentUserHolder;
import com.xiegongzhu.crab.common.security.LoginUser;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.Duration;

/**
 * 限流 + 防重切面（Redis 固定窗口计数）
 */
@Aspect
@Component
public class RateLimitAspect {

    private final RedisService redisService;

    public RateLimitAspect(RedisService redisService) {
        this.redisService = redisService;
    }

    @Around("@annotation(rateLimit)")
    public Object around(ProceedingJoinPoint point, RateLimit rateLimit) throws Throwable {
        String businessKey = rateLimit.key().isBlank()
                ? point.getSignature().toShortString()
                : rateLimit.key();
        String dimension = switch (rateLimit.dimension()) {
            case "USER" -> "u:" + currentUserId();
            case "GLOBAL" -> "g";
            default -> "ip:" + clientIp();
        };
        String counterKey = "rate:" + businessKey + ":" + dimension;

        if (rateLimit.dedup() && !redisService.tryMark(counterKey + ":dedup",
                Duration.ofSeconds(rateLimit.seconds()))) {
            throw new BizException(ResultCode.REPEAT_SUBMIT);
        }
        long count = redisService.incrementWithExpire(counterKey, rateLimit.seconds());
        if (count > rateLimit.limit()) {
            throw new BizException(ResultCode.RATE_LIMITED);
        }
        return point.proceed();
    }

    private Long currentUserId() {
        LoginUser user = CurrentUserHolder.get();
        return user == null ? 0L : user.getUserId();
    }

    private String clientIp() {
        ServletRequestAttributes attributes =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null) {
            return "unknown";
        }
        HttpServletRequest request = attributes.getRequest();
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
