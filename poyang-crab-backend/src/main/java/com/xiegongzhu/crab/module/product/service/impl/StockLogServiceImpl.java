package com.xiegongzhu.crab.module.product.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.product.entity.StockLog;
import com.xiegongzhu.crab.module.product.mapper.StockLogMapper;
import com.xiegongzhu.crab.module.product.service.StockLogService;
import org.springframework.stereotype.Service;

@Service
public class StockLogServiceImpl extends ServiceImpl<StockLogMapper, StockLog> implements StockLogService {
}