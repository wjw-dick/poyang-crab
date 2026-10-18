package com.xiegongzhu.crab.module.channel.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.channel.entity.Commission;
import com.xiegongzhu.crab.module.channel.mapper.CommissionMapper;
import com.xiegongzhu.crab.module.channel.service.CommissionService;
import org.springframework.stereotype.Service;

@Service
public class CommissionServiceImpl extends ServiceImpl<CommissionMapper, Commission> implements CommissionService {
}