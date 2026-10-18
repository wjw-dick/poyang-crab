package com.xiegongzhu.crab.common.result;

/**
 * 业务状态码
 */
public enum ResultCode {

    SUCCESS(200, "操作成功"),
    FAIL(500, "操作失败"),
    PARAM_ERROR(400, "参数校验失败"),
    UNAUTHORIZED(401, "未登录或登录已过期"),
    FORBIDDEN(403, "无操作权限"),
    NOT_FOUND(404, "资源不存在"),
    REPEAT_SUBMIT(429, "请勿重复提交"),
    RATE_LIMITED(429, "请求过于频繁，请稍后再试"),
    SENSITIVE_WORD(452, "内容含敏感词，请修改后重试"),
    BIZ_ERROR(1000, "业务处理失败"),
    STOCK_NOT_ENOUGH(1001, "库存不足"),
    ORDER_STATUS_ERROR(1002, "订单状态不允许该操作"),
    STORAGE_NOT_READY(1003, "对象存储未通过连接测试，无法保存并应用"),
    CHANNEL_AUDIT_REQUIRED(1004, "渠道报单需审核后才能转为正式订单");

    private final int code;
    private final String message;

    ResultCode(int code, String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
