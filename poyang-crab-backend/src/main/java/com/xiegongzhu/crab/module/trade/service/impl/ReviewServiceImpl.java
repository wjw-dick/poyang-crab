package com.xiegongzhu.crab.module.trade.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.trade.entity.Review;
import com.xiegongzhu.crab.module.trade.mapper.ReviewMapper;
import com.xiegongzhu.crab.module.trade.service.ReviewService;
import org.springframework.stereotype.Service;

@Service
public class ReviewServiceImpl extends ServiceImpl<ReviewMapper, Review> implements ReviewService {
}