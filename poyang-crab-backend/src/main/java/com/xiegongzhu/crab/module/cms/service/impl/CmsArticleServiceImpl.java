package com.xiegongzhu.crab.module.cms.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.cms.entity.CmsArticle;
import com.xiegongzhu.crab.module.cms.mapper.CmsArticleMapper;
import com.xiegongzhu.crab.module.cms.service.CmsArticleService;
import org.springframework.stereotype.Service;

@Service
public class CmsArticleServiceImpl extends ServiceImpl<CmsArticleMapper, CmsArticle> implements CmsArticleService {
}