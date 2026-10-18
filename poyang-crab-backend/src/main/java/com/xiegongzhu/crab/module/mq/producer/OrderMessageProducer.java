package com.xiegongzhu.crab.module.mq.producer;

import com.xiegongzhu.crab.common.config.RabbitMQConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * T06 订单异步消息投递：下单后异步处理（发券、埋点、通知等），避免阻塞主链路
 */
@Component
public class OrderMessageProducer {

    private static final Logger log = LoggerFactory.getLogger(OrderMessageProducer.class);

    private final RabbitTemplate rabbitTemplate;

    public OrderMessageProducer(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    public void sendOrderCreated(String orderNo) {
        rabbitTemplate.convertAndSend(RabbitMQConfig.ORDER_EXCHANGE, RabbitMQConfig.ORDER_CREATE_KEY,
                Map.of("orderNo", orderNo));
        log.debug("订单创建消息已投递 orderNo={}", orderNo);
    }

    public void sendPayNotify(String payNo, String tradeNo, String payType) {
        rabbitTemplate.convertAndSend(RabbitMQConfig.ORDER_EXCHANGE, RabbitMQConfig.PAY_NOTIFY_KEY,
                Map.of("payNo", payNo, "tradeNo", tradeNo, "payType", payType));
        log.debug("支付回调消息已投递 payNo={}", payNo);
    }

    public void sendLogisticsStatus(String orderNo, String shipStatus, String expressNo) {
        rabbitTemplate.convertAndSend(RabbitMQConfig.ORDER_EXCHANGE, RabbitMQConfig.LOGISTICS_KEY,
                Map.of("orderNo", orderNo, "shipStatus", shipStatus,
                        "expressNo", expressNo == null ? "" : expressNo));
    }
}
