package com.xiegongzhu.crab;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * 螃蟹小公主 · 鄱阳湖湖蟹 多端数字化平台 后端入口
 * 服务对象：PC 官网 / 公众号 / 小程序 / H5 / 后台 / 冷链发货端 / 渠道商端
 */
@EnableAsync
@EnableScheduling
@MapperScan("com.xiegongzhu.crab.module.**.mapper")
@SpringBootApplication
public class PoyangCrabApplication {

    public static void main(String[] args) {
        SpringApplication.run(PoyangCrabApplication.class, args);
    }
}
