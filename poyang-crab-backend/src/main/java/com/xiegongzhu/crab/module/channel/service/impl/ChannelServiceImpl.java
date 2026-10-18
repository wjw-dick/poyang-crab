package com.xiegongzhu.crab.module.channel.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.channel.entity.Channel;
import com.xiegongzhu.crab.module.channel.mapper.ChannelMapper;
import com.xiegongzhu.crab.module.channel.service.ChannelService;
import org.springframework.stereotype.Service;

@Service
public class ChannelServiceImpl extends ServiceImpl<ChannelMapper, Channel> implements ChannelService {
}