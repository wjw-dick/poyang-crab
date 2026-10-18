package com.xiegongzhu.crab.module.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.xiegongzhu.crab.common.security.LoginUser;
import com.xiegongzhu.crab.module.system.dto.LoginRequest;
import com.xiegongzhu.crab.module.system.dto.LoginResponse;
import com.xiegongzhu.crab.module.system.entity.SysUser;

public interface SysUserService extends IService<SysUser> {

    /** 后台账号密码登录 */
    LoginResponse login(LoginRequest request);

    /**
     * 依据 JWT 令牌中的身份，回查数据库补全角色与权限标识。
     * 说明：JWT 只承载 userId/roleType 等轻量声明，perms 不入 token（避免令牌过长与权限变更不生效），
     *      因此刷新页面后前端必须靠本接口重新取回权限，否则动态路由会因权限为空而全部丢失。
     */
    LoginUser profile(LoginUser tokenUser);

    /** 重置密码（超管） */
    void resetPassword(Long userId, String rawPassword);
}
