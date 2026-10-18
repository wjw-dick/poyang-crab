package com.xiegongzhu.crab.module.wechat.service;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.module.system.entity.SysMenu;
import com.xiegongzhu.crab.module.system.mapper.SysMenuMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * T10 公众号菜单「预览到微信」+「发布」两步
 * 菜单来源：sys_menu 中 platform = WECHAT_MP 的节点（后台可视化维护）
 */
@Service
public class WxMpMenuService {

    private static final Logger log = LoggerFactory.getLogger(WxMpMenuService.class);
    private static final String MENU_CREATE_URL =
            "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=%s";

    private final SysMenuMapper sysMenuMapper;
    private final WxMpService wxMpService;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public WxMpMenuService(SysMenuMapper sysMenuMapper, WxMpService wxMpService,
                           RestTemplate restTemplate, ObjectMapper objectMapper) {
        this.sysMenuMapper = sysMenuMapper;
        this.wxMpService = wxMpService;
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
    }

    /** 第一步：预览（返回将要提交给微信的菜单 JSON，供后台手机外壳模拟预览） */
    public String preview() {
        return toJson(buildMenu());
    }

    /** 第二步：发布到微信 */
    public void publish() {
        String token = wxMpService.accessToken();
        String menuJson = preview();
        if (token == null) {
            log.warn("[公众号菜单-骨架] 未配置公众号凭证，仅本地生成菜单：{}", menuJson);
            return;
        }
        String body = restTemplate.postForObject(String.format(MENU_CREATE_URL, token), menuJson, String.class);
        if (body == null || !body.contains("\"errcode\":0")) {
            throw new BizException("公众号菜单发布失败：" + body);
        }
    }

    private Map<String, Object> buildMenu() {
        List<SysMenu> menus = sysMenuMapper.selectList(Wrappers.<SysMenu>lambdaQuery()
                .eq(SysMenu::getPlatform, "WECHAT_MP")
                .eq(SysMenu::getVisible, 1)
                .orderByAsc(SysMenu::getSort));
        List<Map<String, Object>> buttons = new ArrayList<>();
        for (SysMenu menu : menus) {
            if (menu.getParentId() != null && menu.getParentId() != 0) {
                continue;
            }
            Map<String, Object> button = new LinkedHashMap<>();
            button.put("name", menu.getMenuName());
            List<Map<String, Object>> sub = new ArrayList<>();
            for (SysMenu child : menus) {
                if (menu.getId().equals(child.getParentId())) {
                    Map<String, Object> subButton = new LinkedHashMap<>();
                    subButton.put("name", child.getMenuName());
                    subButton.put(mapType(child.getLinkType()), child.getPath() == null ? "" : child.getPath());
                    sub.add(subButton);
                }
            }
            if (sub.isEmpty()) {
                button.put(mapType(menu.getLinkType()), menu.getPath() == null ? "" : menu.getPath());
            } else {
                button.put("sub_button", sub);
            }
            buttons.add(button);
        }
        return Map.of("button", buttons);
    }

    private String mapType(String linkType) {
        if ("MINIAPP".equalsIgnoreCase(linkType)) {
            return "miniprogram";
        }
        return "OUTER".equalsIgnoreCase(linkType) ? "view" : "click";
    }

    private String toJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (Exception e) {
            throw new BizException("公众号菜单序列化失败");
        }
    }
}
