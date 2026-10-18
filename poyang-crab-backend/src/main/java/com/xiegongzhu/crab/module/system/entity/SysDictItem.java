package com.xiegongzhu.crab.module.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_dict_item")
public class SysDictItem extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String dictType;
    private String itemLabel;
    private String itemValue;
    private Integer sort;
    private Integer status;
}
