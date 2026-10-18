package com.xiegongzhu.crab.module.product.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.product.entity.Stock;
import com.xiegongzhu.crab.module.product.mapper.StockMapper;
import com.xiegongzhu.crab.module.product.service.StockService;
import org.springframework.stereotype.Service;

@Service
public class StockServiceImpl extends ServiceImpl<StockMapper, Stock> implements StockService {
}