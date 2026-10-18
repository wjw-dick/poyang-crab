package com.xiegongzhu.crab.module.channel.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.channel.entity.ChannelOrder;
import com.xiegongzhu.crab.module.channel.mapper.ChannelOrderMapper;
import com.xiegongzhu.crab.module.channel.service.ChannelOrderService;
import org.springframework.stereotype.Service;

@Service
public class ChannelOrderServiceImpl extends ServiceImpl<ChannelOrderMapper, ChannelOrder> implements ChannelOrderService {
}