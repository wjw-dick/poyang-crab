package com.xiegongzhu.crab.module.member.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.member.entity.MemberAddress;
import com.xiegongzhu.crab.module.member.service.MemberAddressService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 会员收货地址 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/member/address")
public class MemberAddressController extends BaseCrudController<MemberAddress, MemberAddressService> {
}