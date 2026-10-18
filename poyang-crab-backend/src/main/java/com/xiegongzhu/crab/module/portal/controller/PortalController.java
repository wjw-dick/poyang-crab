package com.xiegongzhu.crab.module.portal.controller;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.xiegongzhu.crab.common.annotation.RateLimit;
import com.xiegongzhu.crab.common.result.R;
import com.xiegongzhu.crab.module.cms.entity.CmsArticle;
import com.xiegongzhu.crab.module.cms.entity.CmsCategory;
import com.xiegongzhu.crab.module.cms.entity.CmsChannelApply;
import com.xiegongzhu.crab.module.cms.mapper.CmsArticleMapper;
import com.xiegongzhu.crab.module.cms.mapper.CmsCategoryMapper;
import com.xiegongzhu.crab.module.cms.mapper.CmsChannelApplyMapper;
import com.xiegongzhu.crab.module.product.entity.Product;
import com.xiegongzhu.crab.module.product.entity.ProductCategory;
import com.xiegongzhu.crab.module.product.entity.ProductSku;
import com.xiegongzhu.crab.module.product.entity.ProductSpec;
import com.xiegongzhu.crab.module.product.mapper.ProductCategoryMapper;
import com.xiegongzhu.crab.module.product.mapper.ProductMapper;
import com.xiegongzhu.crab.module.product.mapper.ProductSkuMapper;
import com.xiegongzhu.crab.module.product.mapper.ProductSpecMapper;
import com.xiegongzhu.crab.module.system.entity.SysConfig;
import com.xiegongzhu.crab.module.system.entity.SysI18n;
import com.xiegongzhu.crab.module.system.entity.SysMenu;
import com.xiegongzhu.crab.module.system.mapper.SysI18nMapper;
import com.xiegongzhu.crab.module.system.mapper.SysMenuMapper;
import com.xiegongzhu.crab.module.system.service.SysConfigService;
import com.xiegongzhu.crab.module.trade.entity.Review;
import com.xiegongzhu.crab.module.trade.mapper.ReviewMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * T15/T16/T23 门户接口（PC 官网 / H5 分享页 / 小程序公开数据源，同源同数据）
 * 白名单路径：/portal/**（无需登录）
 */
@RestController
@RequestMapping("/portal")
public class PortalController {

    private final SysConfigService sysConfigService;
    private final SysMenuMapper sysMenuMapper;
    private final SysI18nMapper sysI18nMapper;
    private final ProductMapper productMapper;
    private final ProductCategoryMapper productCategoryMapper;
    private final ProductSkuMapper productSkuMapper;
    private final ProductSpecMapper productSpecMapper;
    private final CmsArticleMapper cmsArticleMapper;
    private final CmsCategoryMapper cmsCategoryMapper;
    private final CmsChannelApplyMapper cmsChannelApplyMapper;
    private final ReviewMapper reviewMapper;

    public PortalController(SysConfigService sysConfigService, SysMenuMapper sysMenuMapper,
                            SysI18nMapper sysI18nMapper, ProductMapper productMapper,
                            ProductCategoryMapper productCategoryMapper, ProductSkuMapper productSkuMapper,
                            ProductSpecMapper productSpecMapper, CmsArticleMapper cmsArticleMapper,
                            CmsCategoryMapper cmsCategoryMapper, CmsChannelApplyMapper cmsChannelApplyMapper,
                            ReviewMapper reviewMapper) {
        this.sysConfigService = sysConfigService;
        this.sysMenuMapper = sysMenuMapper;
        this.sysI18nMapper = sysI18nMapper;
        this.productMapper = productMapper;
        this.productCategoryMapper = productCategoryMapper;
        this.productSkuMapper = productSkuMapper;
        this.productSpecMapper = productSpecMapper;
        this.cmsArticleMapper = cmsArticleMapper;
        this.cmsCategoryMapper = cmsCategoryMapper;
        this.cmsChannelApplyMapper = cmsChannelApplyMapper;
        this.reviewMapper = reviewMapper;
    }

    /** 站点公开参数（站点/ICP/客服），密钥字段一律不返回 */
    @GetMapping("/site")
    public R<Map<String, String>> site() {
        Map<String, String> result = new LinkedHashMap<>();
        List<SysConfig> configs = sysConfigService.list(Wrappers.<SysConfig>lambdaQuery()
                .in(SysConfig::getConfigGroup, List.of("SITE", "ICP", "SERVICE"))
                .eq(SysConfig::getIsEncrypted, 0));
        configs.forEach(config -> result.put(config.getConfigKey(), config.getConfigValue()));
        return R.ok(result);
    }

    /** 导航由后台菜单配置驱动，非写死 */
    @GetMapping("/nav")
    public R<List<SysMenu>> nav(@RequestParam(defaultValue = "PC") String platform) {
        return R.ok(sysMenuMapper.selectList(Wrappers.<SysMenu>lambdaQuery()
                .eq(SysMenu::getPlatform, platform)
                .eq(SysMenu::getVisible, 1)
                .orderByAsc(SysMenu::getSort)));
    }

    /** 多语言词条包（前台切换器） */
    @GetMapping("/i18n/{langCode}")
    public R<Map<String, String>> i18n(@PathVariable String langCode) {
        List<SysI18n> list = sysI18nMapper.selectList(Wrappers.<SysI18n>lambdaQuery()
                .eq(SysI18n::getLangCode, langCode));
        return R.ok(list.stream().collect(Collectors.toMap(
                SysI18n::getItemKey, item -> item.getItemValue() == null ? "" : item.getItemValue(),
                (a, b) -> a)));
    }

    /** 商品列表（C 端只展示 RETAIL/BOTH 且在架商品） */
    @GetMapping("/product/list")
    public R<List<Product>> productList(@RequestParam(required = false) Long categoryId,
                                        @RequestParam(required = false) String keyword) {
        return R.ok(productMapper.selectList(Wrappers.<Product>lambdaQuery()
                .eq(Product::getStatus, 1)
                .in(Product::getSellMode, List.of("RETAIL", "BOTH"))
                .eq(categoryId != null, Product::getCategoryId, categoryId)
                .like(keyword != null && !keyword.isBlank(), Product::getProductName, keyword)
                .orderByAsc(Product::getSort)));
    }

    /** 商品详情（含湖蟹规格：公母/重量档/只数礼盒 + SKU） */
    @GetMapping("/product/{id}")
    public R<Map<String, Object>> productDetail(@PathVariable Long id) {
        Product product = productMapper.selectById(id);
        List<ProductSpec> specs = productSpecMapper.selectList(Wrappers.<ProductSpec>lambdaQuery()
                .eq(ProductSpec::getProductId, id));
        List<ProductSku> skus = productSkuMapper.selectList(Wrappers.<ProductSku>lambdaQuery()
                .eq(ProductSku::getProductId, id)
                .eq(ProductSku::getStatus, 1));
        skus.forEach(sku -> sku.setWholesalePrice(null));
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("product", product);
        data.put("specs", specs);
        data.put("skus", skus);
        return R.ok(data);
    }

    /** 商品分类 */
    @GetMapping("/category/list")
    public R<List<ProductCategory>> categoryList() {
        return R.ok(productCategoryMapper.selectList(Wrappers.<ProductCategory>lambdaQuery()
                .eq(ProductCategory::getStatus, 1)
                .orderByAsc(ProductCategory::getSort)));
    }

    /** 内容列表：品牌故事 / 养殖基地 / 捕捞实景 / 招商 */
    @GetMapping("/article/list")
    public R<List<CmsArticle>> articleList(@RequestParam(required = false) String categoryCode) {
        Long categoryId = null;
        if (categoryCode != null && !categoryCode.isBlank()) {
            CmsCategory category = cmsCategoryMapper.selectOne(Wrappers.<CmsCategory>lambdaQuery()
                    .eq(CmsCategory::getCategoryCode, categoryCode));
            categoryId = category == null ? -1L : category.getId();
        }
        return R.ok(cmsArticleMapper.selectList(Wrappers.<CmsArticle>lambdaQuery()
                .eq(CmsArticle::getStatus, "PUBLISHED")
                .eq(categoryId != null, CmsArticle::getCategoryId, categoryId)
                .orderByDesc(CmsArticle::getIsTop)
                .orderByDesc(CmsArticle::getPublishTime)));
    }

    /** 文章详情 */
    @GetMapping("/article/{id}")
    public R<CmsArticle> article(@PathVariable Long id) {
        return R.ok(cmsArticleMapper.selectById(id));
    }

    /** 商品评价（C 端只展示已审核通过的：is_show=1） */
    @GetMapping("/review/list")
    public R<List<Review>> reviewList(@RequestParam Long productId,
                                      @RequestParam(defaultValue = "20") long limit) {
        return R.ok(reviewMapper.selectList(Wrappers.<Review>lambdaQuery()
                .eq(Review::getProductId, productId)
                .eq(Review::getIsShow, 1)
                .orderByDesc(Review::getCreateTime)
                .last("LIMIT " + Math.max(1, Math.min(limit, 50)))));
    }

    /** 招商：渠道商申请提交 */
    @RateLimit(limit = 5, seconds = 300, key = "portal:channel-apply", dimension = "IP")
    @PostMapping("/channel-apply")
    public R<Long> channelApply(@RequestBody CmsChannelApply apply) {
        apply.setId(null);
        apply.setAuditStatus("PENDING");
        cmsChannelApplyMapper.insert(apply);
        return R.ok(apply.getId());
    }
}
