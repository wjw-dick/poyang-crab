package com.xiegongzhu.crab.module.trade.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.trade.entity.Payment;
import com.xiegongzhu.crab.module.trade.mapper.PaymentMapper;
import com.xiegongzhu.crab.module.trade.service.PaymentService;
import org.springframework.stereotype.Service;

@Service
public class PaymentServiceImpl extends ServiceImpl<PaymentMapper, Payment> implements PaymentService {
}