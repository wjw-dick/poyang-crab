package com.xiegongzhu.crab.module.member.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.member.entity.Member;
import com.xiegongzhu.crab.module.member.mapper.MemberMapper;
import com.xiegongzhu.crab.module.member.service.MemberService;
import org.springframework.stereotype.Service;

@Service
public class MemberServiceImpl extends ServiceImpl<MemberMapper, Member> implements MemberService {
}