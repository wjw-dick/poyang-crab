package com.xiegongzhu.crab.module.product.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.product.entity.ProductCategory;
import com.xiegongzhu.crab.module.product.mapper.ProductCategoryMapper;
import com.xiegongzhu.crab.module.product.service.ProductCategoryService;
import org.springframework.stereotype.Service;

@Service
public class ProductCategoryServiceImpl extends ServiceImpl<ProductCategoryMapper, ProductCategory> implements ProductCategoryService {
}