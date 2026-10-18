package com.xiegongzhu.crab.common.config;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.DirectExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.QueueBuilder;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * T06 RabbitMQ：
 * 1) 订单异步消息（下单后扣减锁定库存、发券、埋点）
 * 2) 支付回调解耦（网关 -> 队列 -> 业务落库）
 * 3) 延迟队列：订单超时未支付自动取消（TTL + 死信转发）
 * 4) 冷链发货状态流转通知
 */
@Configuration
public class RabbitMQConfig {

    public static final String ORDER_EXCHANGE = "crab.order.exchange";
    public static final String ORDER_CREATE_QUEUE = "crab.order.create.queue";
    public static final String ORDER_CREATE_KEY = "order.create";

    public static final String PAY_NOTIFY_QUEUE = "crab.pay.notify.queue";
    public static final String PAY_NOTIFY_KEY = "pay.notify";

    public static final String LOGISTICS_QUEUE = "crab.logistics.status.queue";
    public static final String LOGISTICS_KEY = "logistics.status";

    /** 延迟交换机 + 延迟队列（TTL 到期进入死信交换机） */
    public static final String DELAY_EXCHANGE = "crab.order.delay.exchange";
    public static final String DELAY_QUEUE = "crab.order.delay.queue";
    public static final String DELAY_KEY = "order.delay";

    /** 订单超时取消队列 */
    public static final String ORDER_CANCEL_QUEUE = "crab.order.cancel.queue";
    public static final String ORDER_CANCEL_KEY = "order.timeout.cancel";

    @Bean
    public MessageConverter messageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory, MessageConverter converter) {
        RabbitTemplate template = new RabbitTemplate(connectionFactory);
        template.setMessageConverter(converter);
        template.setMandatory(true);
        return template;
    }

    @Bean
    public TopicExchange orderExchange() {
        return new TopicExchange(ORDER_EXCHANGE, true, false);
    }

    @Bean
    public Queue orderCreateQueue() {
        return QueueBuilder.durable(ORDER_CREATE_QUEUE).build();
    }

    @Bean
    public Binding orderCreateBinding() {
        return BindingBuilder.bind(orderCreateQueue()).to(orderExchange()).with(ORDER_CREATE_KEY);
    }

    @Bean
    public Queue payNotifyQueue() {
        return QueueBuilder.durable(PAY_NOTIFY_QUEUE).build();
    }

    @Bean
    public Binding payNotifyBinding() {
        return BindingBuilder.bind(payNotifyQueue()).to(orderExchange()).with(PAY_NOTIFY_KEY);
    }

    @Bean
    public Queue logisticsQueue() {
        return QueueBuilder.durable(LOGISTICS_QUEUE).build();
    }

    @Bean
    public Binding logisticsBinding() {
        return BindingBuilder.bind(logisticsQueue()).to(orderExchange()).with(LOGISTICS_KEY);
    }

    @Bean
    public Queue orderCancelQueue() {
        return QueueBuilder.durable(ORDER_CANCEL_QUEUE).build();
    }

    @Bean
    public Binding orderCancelBinding() {
        return BindingBuilder.bind(orderCancelQueue()).to(orderExchange()).with(ORDER_CANCEL_KEY);
    }

    @Bean
    public DirectExchange orderDelayExchange() {
        return new DirectExchange(DELAY_EXCHANGE, true, false);
    }

    /**
     * 延迟队列：消息到期后按死信路由进入 order.cancel 队列
     */
    @Bean
    public Queue orderDelayQueue() {
        return QueueBuilder.durable(DELAY_QUEUE)
                .withArgument("x-dead-letter-exchange", ORDER_EXCHANGE)
                .withArgument("x-dead-letter-routing-key", ORDER_CANCEL_KEY)
                .build();
    }

    @Bean
    public Binding orderDelayBinding() {
        return BindingBuilder.bind(orderDelayQueue()).to(orderDelayExchange()).with(DELAY_KEY);
    }
}
