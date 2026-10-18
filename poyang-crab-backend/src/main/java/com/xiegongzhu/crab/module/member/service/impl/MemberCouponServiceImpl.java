package com.xiegongzhu.crab.module.member.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.member.entity.MemberCoupon;
import com.xiegongzhu.crab.module.member.mapper.MemberCouponMapper;
import com.xiegongzhu.crab.module.member.service.MemberCouponService;
import org.springframework.stereotype.Service;

@Service
public class MemberCouponServiceImpl extends ServiceImpl<MemberCouponMapper, MemberCoupon> implements MemberCouponService {
}