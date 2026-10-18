package com.xiegongzhu.crab.module.mq.consumer;

import com.rabbitmq.client.Channel;
import com.xiegongzhu.crab.common.config.RabbitMQConfig;
import com.xiegongzhu.crab.module.trade.service.OrderService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * T06 延迟队列消费：订单超时未支付自动取消
 * 生产：延迟队列（TTL 30 分钟）—死信—> order.cancel 队列—> 本消费者
 */
@Component
public class OrderTimeoutConsumer {

    private static final Logger log = LoggerFactory.getLogger(OrderTimeoutConsumer.class);

    private final OrderService orderService;

    public OrderTimeoutConsumer(OrderService orderService) {
        this.orderService = orderService;
    }

    @RabbitListener(queues = RabbitMQConfig.ORDER_CANCEL_QUEUE)
    public void onMessage(Message message, Channel channel) throws IOException {
        long tag = message.getMessageProperties().getDeliveryTag();
        try {
            String orderNo = new String(message.getBody());
            log.info("收到订单超时取消消息 orderNo={}", orderNo);
            orderService.cancelExpired(orderNo);
            channel.basicAck(tag, false);
        } catch (Exception e) {
            log.error("订单超时取消处理失败", e);
            // 重回队列前先拒绝，交由应用层幂等重试
            channel.basicNack(tag, false, true);
        }
    }
}
