package com.xiegongzhu.crab.module.system.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.result.ResultCode;
import com.xiegongzhu.crab.common.security.JwtUtils;
import com.xiegongzhu.crab.common.security.LoginUser;
import com.xiegongzhu.crab.module.system.dto.LoginRequest;
import com.xiegongzhu.crab.module.system.dto.LoginResponse;
import com.xiegongzhu.crab.module.system.entity.SysMenu;
import com.xiegongzhu.crab.module.system.entity.SysRole;
import com.xiegongzhu.crab.module.system.entity.SysRoleMenu;
import com.xiegongzhu.crab.module.system.entity.SysUser;
import com.xiegongzhu.crab.module.system.entity.SysUserRole;
import com.xiegongzhu.crab.module.system.mapper.SysMenuMapper;
import com.xiegongzhu.crab.module.system.mapper.SysRoleMapper;
import com.xiegongzhu.crab.module.system.mapper.SysRoleMenuMapper;
import com.xiegongzhu.crab.module.system.mapper.SysUserMapper;
import com.xiegongzhu.crab.module.system.mapper.SysUserRoleMapper;
import com.xiegongzhu.crab.module.system.service.SysUserService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements SysUserService {

    private final JwtUtils jwtUtils;
    private final PasswordEncoder passwordEncoder;
    private final SysUserRoleMapper userRoleMapper;
    private final SysRoleMenuMapper roleMenuMapper;
    private final SysRoleMapper roleMapper;
    private final SysMenuMapper menuMapper;

    public SysUserServiceImpl(JwtUtils jwtUtils, PasswordEncoder passwordEncoder,
                              SysUserRoleMapper userRoleMapper, SysRoleMenuMapper roleMenuMapper,
                              SysRoleMapper roleMapper, SysMenuMapper menuMapper) {
        this.jwtUtils = jwtUtils;
        this.passwordEncoder = passwordEncoder;
        this.userRoleMapper = userRoleMapper;
        this.roleMenuMapper = roleMenuMapper;
        this.roleMapper = roleMapper;
        this.menuMapper = menuMapper;
    }

    @Override
    public LoginResponse login(LoginRequest request) {
        SysUser user = getOne(Wrappers.<SysUser>lambdaQuery()
                .eq(SysUser::getUsername, request.getUsername()));
        if (user == null) {
            throw new BizException("账号或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new BizException("账号已禁用，请联系超级管理员");
        }
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BizException("账号或密码错误");
        }

        Set<String> perms = loadPerms(user);
        LoginUser loginUser = new LoginUser();
        loginUser.setUserId(user.getId());
        loginUser.setUsername(user.getUsername());
        loginUser.setNickname(user.getRealName());
        loginUser.setLoginType("ADMIN");
        loginUser.setRoleType(user.getRoleType());
        loginUser.setChannelId(user.getChannelId());
        loginUser.setPerms(perms);

        SysUser update = new SysUser();
        update.setId(user.getId());
        update.setLastLoginAt(LocalDateTime.now());
        updateById(update);

        LoginResponse response = new LoginResponse();
        response.setToken(jwtUtils.createToken(loginUser));
        response.setUserId(user.getId());
        response.setUsername(user.getUsername());
        response.setNickname(user.getRealName());
        response.setRoleType(user.getRoleType());
        response.setChannelId(user.getChannelId());
        response.setPerms(perms);
        return response;
    }

    @Override
    public LoginUser profile(LoginUser tokenUser) {
        if (tokenUser == null || tokenUser.getUserId() == null) {
            throw new BizException(ResultCode.UNAUTHORIZED);
        }
        SysUser user = getById(tokenUser.getUserId());
        if (user == null) {
            throw new BizException(ResultCode.UNAUTHORIZED);
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new BizException(ResultCode.UNAUTHORIZED, "账号已禁用");
        }
        LoginUser result = new LoginUser();
        result.setUserId(user.getId());
        result.setUsername(user.getUsername());
        result.setNickname(user.getRealName());
        result.setLoginType("ADMIN");
        result.setRoleType(user.getRoleType());
        result.setChannelId(user.getChannelId());
        result.setPerms(loadPerms(user));
        return result;
    }

    @Override
    public void resetPassword(Long userId, String rawPassword) {
        if (rawPassword == null || rawPassword.length() < 8) {
            throw new BizException(ResultCode.PARAM_ERROR, "密码长度不得少于 8 位");
        }
        SysUser user = new SysUser();
        user.setId(userId);
        user.setPassword(passwordEncoder.encode(rawPassword));
        if (!updateById(user)) {
            throw new BizException("用户不存在");
        }
    }

    /** 角色 -> 菜单权限标识；超管直接放行全部 */
    private Set<String> loadPerms(SysUser user) {
        if ("SUPER_ADMIN".equals(user.getRoleType())) {
            return new HashSet<>(List.of("*:*:*"));
        }
        List<SysUserRole> userRoles = userRoleMapper.selectList(
                Wrappers.<SysUserRole>lambdaQuery().eq(SysUserRole::getUserId, user.getId()));
        if (userRoles.isEmpty()) {
            return new HashSet<>();
        }
        List<Long> roleIds = userRoles.stream().map(SysUserRole::getRoleId).collect(Collectors.toList());
        List<SysRole> roles = roleMapper.selectList(Wrappers.<SysRole>lambdaQuery().in(SysRole::getId, roleIds));
        List<Long> menuIds = roleMenuMapper.selectList(
                        Wrappers.<SysRoleMenu>lambdaQuery().in(SysRoleMenu::getRoleId, roleIds))
                .stream().map(SysRoleMenu::getMenuId).collect(Collectors.toList());
        if (menuIds.isEmpty()) {
            return roles.stream().map(SysRole::getRoleCode).collect(Collectors.toSet());
        }
        return menuMapper.selectList(Wrappers.<SysMenu>lambdaQuery().in(SysMenu::getId, menuIds))
                .stream()
                .map(SysMenu::getPerm)
                .filter(perm -> perm != null && !perm.isBlank())
                .collect(Collectors.toSet());
    }
}
