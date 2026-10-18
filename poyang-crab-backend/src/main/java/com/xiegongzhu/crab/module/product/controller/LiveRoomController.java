package com.xiegongzhu.crab.module.product.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.product.entity.LiveRoom;
import com.xiegongzhu.crab.module.product.service.LiveRoomService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 直播间关联 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/live")
public class LiveRoomController extends BaseCrudController<LiveRoom, LiveRoomService> {
}