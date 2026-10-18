package com.xiegongzhu.crab.module.cms.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.cms.entity.CmsCategory;
import com.xiegongzhu.crab.module.cms.mapper.CmsCategoryMapper;
import com.xiegongzhu.crab.module.cms.service.CmsCategoryService;
import org.springframework.stereotype.Service;

@Service
public class CmsCategoryServiceImpl extends ServiceImpl<CmsCategoryMapper, CmsCategory> implements CmsCategoryService {
}