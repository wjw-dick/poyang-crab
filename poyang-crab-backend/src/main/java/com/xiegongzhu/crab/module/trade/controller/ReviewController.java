package com.xiegongzhu.crab.module.trade.controller;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.annotation.RateLimit;
import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.result.PageResult;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.common.security.CurrentUserHolder;
import com.xiegongzhu.crab.module.trade.entity.Order;
import com.xiegongzhu.crab.module.trade.entity.Review;
import com.xiegongzhu.crab.module.trade.service.OrderService;
import com.xiegongzhu.crab.module.trade.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 收货评价 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 *
 * C 端入口：/submit（登录会员自行发表评价，memberId 由登录态注入，避免前端伪造）+ /my（我的评价）。
 */
@RestController
@RequestMapping("/trade/review")
public class ReviewController extends BaseCrudController<Review, ReviewService> {

    @Autowired
    private OrderService orderService;

    /**
     * C 端发表评价：memberId 取登录态；仅允许评价自己已签收/已完成的订单。
     * 内容敏感词过滤由 SensitiveWordService 在 Service 层完成（TODO(T22)）。
     */
    @RateLimit(limit = 20, seconds = 60, dimension = "USER", key = "review:submit")
    @AuditLog(module = "评价管理", operation = "CREATE", saveParam = false)
    @PostMapping("/submit")
    public R<Long> submit(@RequestBody Review review) {
        if (review.getOrderNo() == null || review.getOrderNo().isBlank()) {
            throw new BizException("订单号不能为空");
        }
        Order order = orderService.getOne(Wrappers.<Order>lambdaQuery()
                .eq(Order::getOrderNo, review.getOrderNo()));
        if (order == null) {
            throw new BizException("订单不存在：" + review.getOrderNo());
        }
        if (!CurrentUserHolder.isAdmin() && !CurrentUserHolder.userId().equals(order.getMemberId())) {
            throw new BizException("无权评价他人订单");
        }
        if (!OrderService.STATUS_RECEIVED.equals(order.getOrderStatus())
                && !OrderService.STATUS_COMPLETED.equals(order.getOrderStatus())) {
            throw new BizException("订单尚未收货，暂不能评价");
        }
        Review exist = service.getOne(Wrappers.<Review>lambdaQuery()
                .eq(Review::getOrderNo, review.getOrderNo())
                .eq(Review::getMemberId, CurrentUserHolder.userId()));
        if (exist != null) {
            throw new BizException("该订单已评价，请勿重复提交");
        }
        review.setId(null);
        review.setMemberId(CurrentUserHolder.userId());
        // is_show 默认待审核（0），由后台审核后展示
        if (review.getIsShow() == null) {
            review.setIsShow(0);
        }
        service.save(review);
        return R.ok(review.getId());
    }

    /** 我的评价分页 */
    @GetMapping("/my")
    public R<PageResult<Review>> my(@RequestParam(defaultValue = "1") long current,
                                    @RequestParam(defaultValue = "10") long size) {
        return R.ok(PageResult.of(service.page(
                new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(current, size),
                Wrappers.<Review>lambdaQuery()
                        .eq(Review::getMemberId, CurrentUserHolder.userId())
                        .orderByDesc(Review::getCreateTime))));
    }
}
