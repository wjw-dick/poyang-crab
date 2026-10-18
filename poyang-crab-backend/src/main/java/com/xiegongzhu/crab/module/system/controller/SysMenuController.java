package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.module.system.entity.SysMenu;
import com.xiegongzhu.crab.module.system.service.SysMenuService;
import com.xiegongzhu.crab.module.wechat.service.WxMpMenuService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * T10 菜单维护：菜单树 + 拖拽排序 + 图标/权限标识 + 公众号菜单两步发布
 */
@RestController
@RequestMapping("/system/menu")
public class SysMenuController extends BaseCrudController<SysMenu, SysMenuService> {

    private final WxMpMenuService wxMpMenuService;

    public SysMenuController(WxMpMenuService wxMpMenuService) {
        this.wxMpMenuService = wxMpMenuService;
    }

    /** 菜单树（编辑器左侧树 + 平台切换） */
    @GetMapping("/tree")
    public R<List<SysMenu>> tree(@RequestParam(required = false) String platform) {
        return R.ok(service.tree(platform));
    }

    /** vue-pure-admin 动态路由 */
    @GetMapping("/routes")
    public R<List<SysMenu>> routes() {
        return R.ok(service.routes());
    }

    /** 拖拽排序 */
    @AuditLog(module = "菜单维护", operation = "UPDATE")
    @PostMapping("/drag-sort")
    public R<Void> dragSort(@RequestBody List<SysMenu> nodes) {
        service.dragSort(nodes);
        return R.ok();
    }

    /** 公众号菜单：第一步「预览到微信」 */
    @AuditLog(module = "菜单维护", operation = "QUERY")
    @PostMapping("/wechat/preview")
    public R<String> wechatPreview() {
        return R.ok(wxMpMenuService.preview());
    }

    /** 公众号菜单：第二步「发布」 */
    @AuditLog(module = "菜单维护", operation = "PUBLISH")
    @PostMapping("/wechat/publish")
    public R<Void> wechatPublish() {
        wxMpMenuService.publish();
        service.update(new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<SysMenu>()
                .eq(SysMenu::getPlatform, "WECHAT_MP")
                .set(SysMenu::getWxPublishStatus, 1));
        return R.ok();
    }
}
