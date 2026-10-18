package com.xiegongzhu.crab.module.system.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.system.entity.SysRole;
import com.xiegongzhu.crab.module.system.mapper.SysRoleMapper;
import com.xiegongzhu.crab.module.system.service.SysRoleService;
import org.springframework.stereotype.Service;

@Service
public class SysRoleServiceImpl extends ServiceImpl<SysRoleMapper, SysRole> implements SysRoleService {
}