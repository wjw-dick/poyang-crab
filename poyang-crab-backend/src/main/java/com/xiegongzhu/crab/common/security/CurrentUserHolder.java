package com.xiegongzhu.crab.common.security;

import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.result.ResultCode;

/**
 * 当前登录用户上下文（ThreadLocal）
 */
public final class CurrentUserHolder {

    private static final ThreadLocal<LoginUser> HOLDER = new ThreadLocal<>();

    private CurrentUserHolder() {
    }

    public static void set(LoginUser user) {
        HOLDER.set(user);
    }

    public static LoginUser get() {
        return HOLDER.get();
    }

    public static LoginUser require() {
        LoginUser user = HOLDER.get();
        if (user == null) {
            throw new BizException(ResultCode.UNAUTHORIZED);
        }
        return user;
    }

    public static Long userId() {
        return require().getUserId();
    }

    /** 当前登录主体绑定的渠道商 ID（渠道商端 / 经销商登录时有效，可能为 null） */
    public static Long channelId() {
        LoginUser user = HOLDER.get();
        return user == null ? null : user.getChannelId();
    }

    public static boolean isAdmin() {
        LoginUser user = HOLDER.get();
        return user != null && user.isAdmin();
    }

    public static void clear() {
        HOLDER.remove();
    }
}
