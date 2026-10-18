package com.xiegongzhu.crab.module.trade.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 下单入参（自营直销 / 渠道批发复用；批发走渠道价与起订量校验）
 */
@Data
public class OrderCreateRequest {

    /** RETAIL 自营 / WHOLESALE 批发 */
    private String bizMode = "RETAIL";

    private Long channelId;

    private String receiverName;
    private String receiverMobile;
    private String receiverAddress;

    private Long couponId;

    /** 下单来源：MINIAPP / H5 / PC / ADMIN / CHANNEL */
    private String source = "MINIAPP";

    @NotEmpty(message = "下单商品不能为空")
    private List<Item> items = new ArrayList<>();

    @Data
    public static class Item {
        @NotNull(message = "SKU 不能为空")
        private Long skuId;

        @Min(value = 1, message = "购买数量至少为 1")
        private Integer qty = 1;
    }
}
