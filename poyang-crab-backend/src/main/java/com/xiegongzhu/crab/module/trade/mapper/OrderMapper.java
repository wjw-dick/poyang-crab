package com.xiegongzhu.crab.module.trade.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xiegongzhu.crab.module.trade.entity.Order;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderMapper extends BaseMapper<Order> {
}