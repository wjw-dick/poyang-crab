package com.xiegongzhu.crab.module.member.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.member.entity.MemberPointLog;
import com.xiegongzhu.crab.module.member.mapper.MemberPointLogMapper;
import com.xiegongzhu.crab.module.member.service.MemberPointLogService;
import org.springframework.stereotype.Service;

@Service
public class MemberPointLogServiceImpl extends ServiceImpl<MemberPointLogMapper, MemberPointLog> implements MemberPointLogService {
}