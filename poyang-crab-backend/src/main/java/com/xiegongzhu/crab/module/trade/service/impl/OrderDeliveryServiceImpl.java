package com.xiegongzhu.crab.module.trade.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.trade.entity.OrderDelivery;
import com.xiegongzhu.crab.module.trade.mapper.OrderDeliveryMapper;
import com.xiegongzhu.crab.module.trade.service.OrderDeliveryService;
import org.springframework.stereotype.Service;

@Service
public class OrderDeliveryServiceImpl extends ServiceImpl<OrderDeliveryMapper, OrderDelivery> implements OrderDeliveryService {
}