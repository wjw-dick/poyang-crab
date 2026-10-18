package com.xiegongzhu.crab.module.system.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.system.entity.SysDict;
import com.xiegongzhu.crab.module.system.entity.SysDictItem;
import com.xiegongzhu.crab.module.system.mapper.SysDictItemMapper;
import com.xiegongzhu.crab.module.system.mapper.SysDictMapper;
import com.xiegongzhu.crab.module.system.service.SysDictService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class SysDictServiceImpl extends ServiceImpl<SysDictMapper, SysDict> implements SysDictService {

    private final SysDictItemMapper dictItemMapper;

    public SysDictServiceImpl(SysDictItemMapper dictItemMapper) {
        this.dictItemMapper = dictItemMapper;
    }

    @Override
    public Map<String, List<Map<String, String>>> allOptions() {
        List<SysDictItem> items = dictItemMapper.selectList(Wrappers.<SysDictItem>lambdaQuery()
                .eq(SysDictItem::getStatus, 1)
                .orderByAsc(SysDictItem::getDictType)
                .orderByAsc(SysDictItem::getSort));
        Map<String, List<Map<String, String>>> grouped = new LinkedHashMap<>();
        for (SysDictItem item : items) {
            Map<String, String> option = new LinkedHashMap<>();
            option.put("label", item.getItemLabel());
            option.put("value", item.getItemValue());
            grouped.computeIfAbsent(item.getDictType(), key -> new ArrayList<>()).add(option);
        }
        return grouped;
    }
}
