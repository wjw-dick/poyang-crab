package com.xiegongzhu.crab.module.product.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.product.entity.ProductSpec;
import com.xiegongzhu.crab.module.product.mapper.ProductSpecMapper;
import com.xiegongzhu.crab.module.product.service.ProductSpecService;
import org.springframework.stereotype.Service;

@Service
public class ProductSpecServiceImpl extends ServiceImpl<ProductSpecMapper, ProductSpec> implements ProductSpecService {
}