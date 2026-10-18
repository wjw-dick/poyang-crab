package com.xiegongzhu.crab.module.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.xiegongzhu.crab.module.system.entity.SysMenu;

import java.util.List;

/**
 * T10 菜单可视化维护
 */
public interface SysMenuService extends IService<SysMenu> {

    /** 菜单树（按平台过滤：ADMIN/PC/WECHAT_MP/MINIAPP/H5） */
    List<SysMenu> tree(String platform);

    /** 当前登录用户可见的路由（vue-pure-admin 动态路由） */
    List<SysMenu> routes();

    /**
     * 拖拽排序：提交 [{id, parentId, sort}, ...] 后整体重排
     */
    void dragSort(List<SysMenu> nodes);
}
