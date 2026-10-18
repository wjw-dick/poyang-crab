package com.xiegongzhu.crab.module.mq.consumer;

import com.rabbitmq.client.Channel;
import com.xiegongzhu.crab.common.config.RabbitMQConfig;
import com.xiegongzhu.crab.common.redis.RedisService;
import com.xiegongzhu.crab.module.system.service.SysConfigService;
import com.xiegongzhu.crab.module.trade.service.OrderService;
import com.xiegongzhu.crab.module.wechat.service.WxMpService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;

/**
 * T06 支付回调解耦：网关回调 → 队列 → 本消费者落库 + 模板消息通知
 * 幂等：以 payNo 维度加 Redis 标记，重复投递只处理一次
 */
@Component
public class PayNotifyConsumer {

    private static final Logger log = LoggerFactory.getLogger(PayNotifyConsumer.class);
    private static final String IDEMPOTENT_KEY = "mq:pay:notify:";

    private final OrderService orderService;
    private final RedisService redisService;
    private final WxMpService wxMpService;
    private final SysConfigService sysConfigService;

    public PayNotifyConsumer(OrderService orderService, RedisService redisService,
                             WxMpService wxMpService, SysConfigService sysConfigService) {
        this.orderService = orderService;
        this.redisService = redisService;
        this.wxMpService = wxMpService;
        this.sysConfigService = sysConfigService;
    }

    @RabbitListener(queues = RabbitMQConfig.PAY_NOTIFY_QUEUE)
    public void onMessage(Message message, Channel channel) throws IOException {
        long tag = message.getMessageProperties().getDeliveryTag();
        try {
            String payNo = new String(message.getBody());
            String tradeNo = String.valueOf(message.getMessageProperties().getHeaders().get("tradeNo"));
            String payType = String.valueOf(message.getMessageProperties().getHeaders().get("payType"));

            if (!redisService.tryMark(IDEMPOTENT_KEY + payNo, Duration.ofMinutes(10))) {
                log.info("支付回调重复消息，已忽略 payNo={}", payNo);
                channel.basicAck(tag, false);
                return;
            }
            orderService.markPaid(payNo, tradeNo, payType);

            String templateId = sysConfigService.getString("wechat.mp.template.paid", "");
            wxMpService.sendTemplateMessage(null, templateId, null,
                    Map.of("first", Map.of("value", "支付成功，现捞鲜活，冷链直达"),
                            "keyword1", Map.of("value", payNo)));
            channel.basicAck(tag, false);
        } catch (Exception e) {
            log.error("支付回调处理失败，稍后重试", e);
            channel.basicNack(tag, false, true);
        }
    }
}
