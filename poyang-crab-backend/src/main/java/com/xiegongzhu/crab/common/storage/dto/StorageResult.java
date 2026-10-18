package com.xiegongzhu.crab.common.storage.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

/**
 * 上传结果
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StorageResult implements Serializable {

    private static final long serialVersionUID = 1L;

    private String objectKey;
    private String url;
    private Long size;
    private String contentType;
    private String originName;
}
