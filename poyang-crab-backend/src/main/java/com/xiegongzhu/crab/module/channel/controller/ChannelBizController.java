package com.xiegongzhu.crab.module.channel.controller;

import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.exception.BizException;
import com.xiegongzhu.crab.common.result.PageResult;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.common.result.ResultCode;
import com.xiegongzhu.crab.common.security.CurrentUserHolder;
import com.xiegongzhu.crab.module.channel.entity.Channel;
import com.xiegongzhu.crab.module.channel.entity.ChannelOrder;
import com.xiegongzhu.crab.module.channel.entity.ChannelQuotaLog;
import com.xiegongzhu.crab.module.channel.entity.Commission;
import com.xiegongzhu.crab.module.channel.entity.Settlement;
import com.xiegongzhu.crab.module.channel.service.ChannelBizService;
import com.xiegongzhu.crab.module.trade.dto.OrderCreateRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * T26/T27/T28 渠道商业务接口：报单、审核、佣金、结算
 */
@RestController
@RequestMapping("/channel/biz")
public class ChannelBizController {

    private final ChannelBizService channelBizService;

    public ChannelBizController(ChannelBizService channelBizService) {
        this.channelBizService = channelBizService;
    }

    /** 渠道商端报单（不传 channelId 时取当前登录渠道商） */
    @AuditLog(module = "渠道商管理", operation = "CREATE")
    @PostMapping("/report/submit")
    public R<ChannelOrder> submitReport(@RequestParam(required = false) Long channelId,
                                        @RequestBody List<OrderCreateRequest.Item> items) {
        return R.ok(channelBizService.submitReport(resolveChannelId(channelId), items));
    }

    /** 后台报单审核（通过即生成批发订单）—— 仅后台管理员可操作 */
    @AuditLog(module = "渠道商管理", operation = "UPDATE")
    @PostMapping("/report/audit")
    public R<String> auditReport(@RequestParam String reportNo,
                                 @RequestParam boolean approved,
                                 @RequestParam(required = false) String remark) {
        requireAdmin();
        return R.ok(channelBizService.auditReport(reportNo, approved, remark, CurrentUserHolder.userId()));
    }

    /** 佣金计算（订单支付成功后调用；比例已快照留痕）—— 仅后台管理员 / 系统内部可操作 */
    @AuditLog(module = "渠道商管理", operation = "CREATE")
    @PostMapping("/commission/calculate")
    public R<Void> calculate(@RequestParam Long channelId,
                             @RequestParam String orderNo,
                             @RequestParam BigDecimal baseAmount) {
        requireAdmin();
        channelBizService.calculateCommission(channelId, orderNo, baseAmount);
        return R.ok();
    }

    /** 生成对账结算单（渠道商自助生成）；channelId 不传时取当前登录渠道商 */
    @GetMapping("/settlement/create")
    public R<Settlement> createSettlement(@RequestParam(required = false) Long channelId,
                                          @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
                                          @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        return R.ok(channelBizService.createSettlement(resolveChannelId(channelId), start, end));
    }

    /** 结算确认：渠道商可确认自己的结算单，管理员可确认任意 */
    @AuditLog(module = "渠道商管理", operation = "UPDATE")
    @PostMapping("/settlement/{settleNo}/confirm")
    public R<Void> confirmSettlement(@PathVariable String settleNo) {
        channelBizService.confirmSettlement(settleNo, CurrentUserHolder.isAdmin() ? null : resolveChannelId(null));
        return R.ok();
    }

    /** 渠道端首页概览（额度 / 待结算）：不传 channelId 时取当前登录渠道商 */
    @GetMapping("/overview")
    public R<Map<String, Object>> overview(@RequestParam(required = false) Long channelId) {
        return R.ok(channelBizService.overview(resolveChannelId(channelId)));
    }

    /** 渠道端登录后拉取自身档案（登录态已含 channelId） */
    @GetMapping("/profile")
    public R<Channel> profile() {
        return R.ok(channelBizService.profile(resolveChannelId(null)));
    }

    /** 渠道商端额度使用流水 */
    @GetMapping("/quota/logs")
    public R<List<ChannelQuotaLog>> quotaLogs(@RequestParam(required = false) Long channelId) {
        return R.ok(channelBizService.quotaLogs(resolveChannelId(channelId)));
    }

    /** 我的报单（渠道商端） */
    @GetMapping("/report/page")
    public R<PageResult<ChannelOrder>> reportPage(@RequestParam(required = false) Long channelId,
                                                  @RequestParam(defaultValue = "1") long current,
                                                  @RequestParam(defaultValue = "10") long size,
                                                  @RequestParam(required = false) String auditStatus) {
        return R.ok(channelBizService.reportPage(resolveChannelId(channelId), current, size, auditStatus));
    }

    /** 我的佣金（渠道商端） */
    @GetMapping("/commission/page")
    public R<PageResult<Commission>> commissionPage(@RequestParam(required = false) Long channelId,
                                                    @RequestParam(defaultValue = "1") long current,
                                                    @RequestParam(defaultValue = "10") long size,
                                                    @RequestParam(required = false) String settleStatus) {
        return R.ok(channelBizService.commissionPage(resolveChannelId(channelId), current, size, settleStatus));
    }

    /** 我的结算单（渠道商端） */
    @GetMapping("/settlement/page")
    public R<PageResult<Settlement>> settlementPage(@RequestParam(required = false) Long channelId,
                                                    @RequestParam(defaultValue = "1") long current,
                                                    @RequestParam(defaultValue = "10") long size) {
        return R.ok(channelBizService.settlementPage(resolveChannelId(channelId), current, size));
    }

    /** 下级经销商（渠道商端） */
    @GetMapping("/dealer/list")
    public R<List<Channel>> dealers(@RequestParam(required = false) Long channelId) {
        return R.ok(channelBizService.dealers(resolveChannelId(channelId)));
    }

    /** T26 渠道专属价商品列表（含 SKU 批发价） */
    @GetMapping("/product/list")
    public R<List<Map<String, Object>>> productList(@RequestParam(required = false) String keyword) {
        return R.ok(channelBizService.channelProducts(keyword));
    }

    /**
     * 解析目标渠道商：显式传入优先，否则回退登录态中的 channelId。
     * 渠道商端一律不应由前端指定 channelId，避免越权查询他人数据。
     */
    private Long resolveChannelId(Long channelId) {
        if (channelId != null && channelId > 0) {
            return channelId;
        }
        Long loginChannelId = CurrentUserHolder.channelId();
        if (loginChannelId == null || loginChannelId <= 0) {
            throw new BizException("当前账号未绑定渠道商档案，请联系平台管理员");
        }
        return loginChannelId;
    }

    /** 仅后台管理员可执行的管理动作（报单审核、佣金计算等） */
    private void requireAdmin() {
        if (!CurrentUserHolder.isAdmin()) {
            throw new BizException(ResultCode.FORBIDDEN);
        }
    }
}
