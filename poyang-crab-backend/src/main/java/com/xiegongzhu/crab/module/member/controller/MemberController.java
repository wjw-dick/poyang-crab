package com.xiegongzhu.crab.module.member.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.common.security.CurrentUserHolder;
import com.xiegongzhu.crab.module.member.entity.Member;
import com.xiegongzhu.crab.module.member.service.MemberService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 会员（公众号/小程序/H5 UnionID 互通） 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 *
 * 另提供 /profile 供 C 端（小程序 / H5）读取当前登录会员，避免前端调用通用 /page 越权读取。
 */
@RestController
@RequestMapping("/member")
public class MemberController extends BaseCrudController<Member, MemberService> {

    /** 当前登录会员信息（C 端「我的」页） */
    @GetMapping("/profile")
    public R<Member> profile() {
        Member member = service.getById(CurrentUserHolder.userId());
        if (member == null) {
            throw new BizException("会员不存在或已注销");
        }
        // 登录凭证类字段不下发到前端
        member.setOpenIdMini(null);
        member.setOpenIdMp(null);
        member.setOpenIdH5(null);
        member.setUnionId(null);
        return R.ok(member);
    }
}
