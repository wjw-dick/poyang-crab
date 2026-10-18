package com.xiegongzhu.crab.module.product.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 直播间关联
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("live_room")
public class LiveRoom extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String roomName;
    private String platform;
    private String roomNo;
    private String anchor;
    private String cover;
    private String replayUrl;
    private Integer liveStatus;
    private LocalDateTime startTime;
    private LocalDateTime endTime;}