package com.xiegongzhu.crab.module.product.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.product.entity.ProductSku;
import com.xiegongzhu.crab.module.product.mapper.ProductSkuMapper;
import com.xiegongzhu.crab.module.product.service.ProductSkuService;
import org.springframework.stereotype.Service;

@Service
public class ProductSkuServiceImpl extends ServiceImpl<ProductSkuMapper, ProductSku> implements ProductSkuService {
}