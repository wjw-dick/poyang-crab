package com.xiegongzhu.crab.module.trade.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.trade.entity.OrderItem;
import com.xiegongzhu.crab.module.trade.mapper.OrderItemMapper;
import com.xiegongzhu.crab.module.trade.service.OrderItemService;
import org.springframework.stereotype.Service;

@Service
public class OrderItemServiceImpl extends ServiceImpl<OrderItemMapper, OrderItem> implements OrderItemService {
}