package com.xiegongzhu.crab.module.system.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.system.entity.SysMenu;
import com.xiegongzhu.crab.module.system.mapper.SysMenuMapper;
import com.xiegongzhu.crab.module.system.service.SysMenuService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class SysMenuServiceImpl extends ServiceImpl<SysMenuMapper, SysMenu> implements SysMenuService {

    @Override
    public List<SysMenu> tree(String platform) {
        List<SysMenu> all = list(Wrappers.<SysMenu>lambdaQuery()
                .eq(platform != null && !platform.isBlank(), SysMenu::getPlatform, platform)
                .orderByAsc(SysMenu::getSort));
        return buildTree(all, 0L);
    }

    @Override
    public List<SysMenu> routes() {
        // TODO(T07) 按当前登录用户角色过滤（loadPerms 已产出权限标识）
        return tree("ADMIN");
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void dragSort(List<SysMenu> nodes) {
        if (nodes == null || nodes.isEmpty()) {
            return;
        }
        for (SysMenu node : nodes) {
            SysMenu update = new SysMenu();
            update.setId(node.getId());
            update.setParentId(node.getParentId() == null ? 0L : node.getParentId());
            update.setSort(node.getSort() == null ? 0 : node.getSort());
            updateById(update);
        }
    }

    private List<SysMenu> buildTree(List<SysMenu> all, Long parentId) {
        Map<Long, List<SysMenu>> grouped = all.stream()
                .collect(Collectors.groupingBy(menu -> menu.getParentId() == null ? 0L : menu.getParentId()));
        List<SysMenu> roots = grouped.getOrDefault(parentId, new ArrayList<>());
        roots.sort(Comparator.comparing(menu -> menu.getSort() == null ? 0 : menu.getSort()));
        for (SysMenu root : roots) {
            root.setChildren(buildTree(all, root.getId()));
        }
        return roots;
    }
}
