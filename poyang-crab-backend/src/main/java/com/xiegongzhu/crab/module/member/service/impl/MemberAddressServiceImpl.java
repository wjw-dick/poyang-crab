package com.xiegongzhu.crab.module.member.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.member.entity.MemberAddress;
import com.xiegongzhu.crab.module.member.mapper.MemberAddressMapper;
import com.xiegongzhu.crab.module.member.service.MemberAddressService;
import org.springframework.stereotype.Service;

@Service
public class MemberAddressServiceImpl extends ServiceImpl<MemberAddressMapper, MemberAddress> implements MemberAddressService {
}