package com.xiegongzhu.crab.module.channel.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.channel.entity.Settlement;
import com.xiegongzhu.crab.module.channel.mapper.SettlementMapper;
import com.xiegongzhu.crab.module.channel.service.SettlementService;
import org.springframework.stereotype.Service;

@Service
public class SettlementServiceImpl extends ServiceImpl<SettlementMapper, Settlement> implements SettlementService {
}