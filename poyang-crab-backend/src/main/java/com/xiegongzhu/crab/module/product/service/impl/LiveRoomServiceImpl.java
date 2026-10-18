package com.xiegongzhu.crab.module.product.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.product.entity.LiveRoom;
import com.xiegongzhu.crab.module.product.mapper.LiveRoomMapper;
import com.xiegongzhu.crab.module.product.service.LiveRoomService;
import org.springframework.stereotype.Service;

@Service
public class LiveRoomServiceImpl extends ServiceImpl<LiveRoomMapper, LiveRoom> implements LiveRoomService {
}