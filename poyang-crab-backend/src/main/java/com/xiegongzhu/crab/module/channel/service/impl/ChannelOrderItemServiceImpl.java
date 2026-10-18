package com.xiegongzhu.crab.module.channel.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.channel.entity.ChannelOrderItem;
import com.xiegongzhu.crab.module.channel.mapper.ChannelOrderItemMapper;
import com.xiegongzhu.crab.module.channel.service.ChannelOrderItemService;
import org.springframework.stereotype.Service;

@Service
public class ChannelOrderItemServiceImpl extends ServiceImpl<ChannelOrderItemMapper, ChannelOrderItem> implements ChannelOrderItemService {
}