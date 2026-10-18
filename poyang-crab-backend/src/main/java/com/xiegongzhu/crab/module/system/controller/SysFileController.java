package com.xiegongzhu.crab.module.system.controller;

import com.xiegongzhu.crab.common.annotation.AuditLog;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.common.storage.StorageFactory;
import com.xiegongzhu.crab.common.storage.StorageService;
import com.xiegongzhu.crab.common.storage.dto.StorageResult;
import com.xiegongzhu.crab.module.system.entity.SysFile;
import com.xiegongzhu.crab.module.system.service.SysFileService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;

/**
 * T13 图片上传组件后端：独立整行、拖拽多图、多图并行、失败重试
 * 上传统一走当前启用的对象存储驱动
 */
@RestController
@RequestMapping("/system/file")
public class SysFileController {

    private final StorageFactory storageFactory;
    private final SysFileService sysFileService;

    public SysFileController(StorageFactory storageFactory, SysFileService sysFileService) {
        this.storageFactory = storageFactory;
        this.sysFileService = sysFileService;
    }

    /** 单图上传 */
    @AuditLog(module = "文件管理", operation = "CREATE")
    @PostMapping("/upload")
    public R<StorageResult> upload(@RequestParam("file") MultipartFile file,
                                   @RequestParam(required = false) String bizType) {
        return R.ok(store(file, bizType));
    }

    /** 多图并行上传（前端缩略图网格逐个占位，失败可单张重试） */
    @AuditLog(module = "文件管理", operation = "CREATE")
    @PostMapping("/upload-batch")
    public R<List<StorageResult>> uploadBatch(@RequestParam("files") MultipartFile[] files,
                                              @RequestParam(required = false) String bizType) {
        List<StorageResult> results = new ArrayList<>(files.length);
        for (MultipartFile file : files) {
            results.add(store(file, bizType));
        }
        return R.ok(results);
    }

    /** 驱动信息（上传组件展示存储位置） */
    @GetMapping("/driver")
    public R<String> currentDriver() {
        return R.ok(storageFactory.active().driver().name());
    }

    private StorageResult store(MultipartFile file, String bizType) {
        StorageService storageService = storageFactory.active();
        StorageResult result = storageService.upload(file, bizType);

        SysFile record = new SysFile();
        record.setDriver(storageService.driver().name());
        record.setObjectKey(result.getObjectKey());
        record.setUrl(result.getUrl());
        record.setOriginName(result.getOriginName());
        record.setFileSize(result.getSize());
        record.setContentType(result.getContentType());
        record.setBizType(bizType);
        sysFileService.save(record);
        return result;
    }
}
