package com.xiegongzhu.crab.module.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.ArrayList;
import java.util.List;

/**
 * T10 菜单可视化维护：多端（ADMIN/PC/WECHAT_MP/MINIAPP/H5）统一菜单树
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_menu")
public class SysMenu extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private Long parentId;
    private String menuName;
    /** ADMIN / PC / WECHAT_MP / MINIAPP / H5 */
    private String platform;
    /** DIR / MENU / BUTTON */
    private String menuType;
    /** INNER / OUTER / MINIAPP */
    private String linkType;
    private String path;
    private String component;
    private String icon;
    private String perm;
    private Integer sort;
    private Integer visible;
    private Integer keepAlive;
    /** 公众号菜单发布状态：0 未发布 / 1 已发布 */
    private Integer wxPublishStatus;

    /** 树形结构（非表字段） */
    @com.baomidou.mybatisplus.annotation.TableField(exist = false)
    private List<SysMenu> children = new ArrayList<>();
}
