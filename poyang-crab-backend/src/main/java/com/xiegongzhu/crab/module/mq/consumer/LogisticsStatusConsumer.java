package com.xiegongzhu.crab.module.mq.consumer;

import com.rabbitmq.client.Channel;
import com.xiegongzhu.crab.common.config.RabbitMQConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * T06 冷链发货状态流转通知消费：发货端出库后触发模板消息 / 物流推送
 */
@Component
public class LogisticsStatusConsumer {

    private static final Logger log = LoggerFactory.getLogger(LogisticsStatusConsumer.class);

    @RabbitListener(queues = RabbitMQConfig.LOGISTICS_QUEUE)
    public void onMessage(Message message, Channel channel) throws IOException {
        long tag = message.getMessageProperties().getDeliveryTag();
        try {
            String body = new String(message.getBody(), StandardCharsets.UTF_8);
            log.info("冷链发货状态流转：{}", body);
            // TODO(T17) 按 shipStatus 组装模板消息推送（已发货 / 运输中 / 已签收）
            channel.basicAck(tag, false);
        } catch (Exception e) {
            log.error("冷链状态流转处理失败", e);
            channel.basicNack(tag, false, false);
        }
    }
}
