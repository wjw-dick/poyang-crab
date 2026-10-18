package com.xiegongzhu.crab.common.redis;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Collection;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

/**
 * T05 Redis 门面：缓存 / 限流 / 分布式锁 / 购物车 / 佣金对账缓存
 */
@Service
public class RedisService {

    /** 分布式锁释放脚本：仅持有者可释放 */
    private static final String UNLOCK_LUA =
            "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end";

    private final RedisTemplate<String, Object> redisTemplate;
    private final StringRedisTemplate stringRedisTemplate;

    public RedisService(RedisTemplate<String, Object> redisTemplate, StringRedisTemplate stringRedisTemplate) {
        this.redisTemplate = redisTemplate;
        this.stringRedisTemplate = stringRedisTemplate;
    }

    // ===== 缓存 =====
    public void set(String key, Object value, Duration ttl) {
        redisTemplate.opsForValue().set(key, value, ttl);
    }

    public void set(String key, Object value) {
        redisTemplate.opsForValue().set(key, value);
    }

    @SuppressWarnings("unchecked")
    public <T> T get(String key, Class<T> type) {
        Object value = redisTemplate.opsForValue().get(key);
        return value == null ? null : (T) value;
    }

    /** 缓存穿透读：未命中时回源并写入缓存 */
    public <T> T getOrLoad(String key, Duration ttl, Supplier<T> loader) {
        Object cached = redisTemplate.opsForValue().get(key);
        if (cached != null) {
            @SuppressWarnings("unchecked")
            T value = (T) cached;
            return value;
        }
        T value = loader.get();
        if (value != null) {
            redisTemplate.opsForValue().set(key, value, ttl);
        }
        return value;
    }

    public void delete(String key) {
        redisTemplate.delete(key);
    }

    public void delete(Collection<String> keys) {
        redisTemplate.delete(keys);
    }

    public void deleteByPrefix(String prefix) {
        Set<String> keys = redisTemplate.keys(prefix + "*");
        if (keys != null && !keys.isEmpty()) {
            redisTemplate.delete(keys);
        }
    }

    public boolean hasKey(String key) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    // ===== 限流 / 防重 =====
    /**
     * 固定窗口计数：返回值 > limit 视为超限
     */
    public long incrementWithExpire(String key, long windowSeconds) {
        Long count = stringRedisTemplate.opsForValue().increment(key);
        if (count != null && count == 1L) {
            stringRedisTemplate.expire(key, windowSeconds, TimeUnit.SECONDS);
        }
        return count == null ? 0 : count;
    }

    /** 接口防重：key 存在则说明重复提交 */
    public boolean tryMark(String key, Duration ttl) {
        return Boolean.TRUE.equals(stringRedisTemplate.opsForValue().setIfAbsent(key, "1", ttl));
    }

    // ===== 分布式锁 =====
    public boolean tryLock(String lockKey, String requestId, Duration ttl) {
        return Boolean.TRUE.equals(stringRedisTemplate.opsForValue().setIfAbsent(lockKey, requestId, ttl));
    }

    public boolean unlock(String lockKey, String requestId) {
        Long result = stringRedisTemplate.execute(
                new org.springframework.data.redis.core.script.DefaultRedisScript<>(UNLOCK_LUA, Long.class),
                java.util.Collections.singletonList(lockKey), requestId);
        return result != null && result > 0;
    }
}
