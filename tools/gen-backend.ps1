# =============================================================
# 后端脚手架批量生成器（幂等，可重复执行）
# 生成：实体 / Mapper / Service / ServiceImpl / 通用 CRUD Controller
# 系统域中需定制逻辑的实体（SysUser/SysMenu/SysConfig/SysStorageConfig/
# SysAuditLog/SysSensitiveWord）不在此生成，由手写文件提供。
# =============================================================
$ErrorActionPreference = 'Stop'
$root = 'D:\ai\xiegongzhu.com\poyang-crab-backend\src\main\java\com\xiegongzhu\crab\module'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Write-Java([string]$path, [string]$content) {
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, $utf8)
}

# ---------- 模板 ----------
$entityTpl = @'
package com.xiegongzhu.crab.module.{MOD}.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * {COMMENT}
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("{TABLE}")
public class {NAME} extends BaseEntity {

    private static final long serialVersionUID = 1L;

{FIELDS}}
'@

$mapperTpl = @'
package com.xiegongzhu.crab.module.{MOD}.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xiegongzhu.crab.module.{MOD}.entity.{NAME};
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface {NAME}Mapper extends BaseMapper<{NAME}> {
}
'@

$serviceTpl = @'
package com.xiegongzhu.crab.module.{MOD}.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.xiegongzhu.crab.module.{MOD}.entity.{NAME};

public interface {NAME}Service extends IService<{NAME}> {
}
'@

$implTpl = @'
package com.xiegongzhu.crab.module.{MOD}.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiegongzhu.crab.module.{MOD}.entity.{NAME};
import com.xiegongzhu.crab.module.{MOD}.mapper.{NAME}Mapper;
import com.xiegongzhu.crab.module.{MOD}.service.{NAME}Service;
import org.springframework.stereotype.Service;

@Service
public class {NAME}ServiceImpl extends ServiceImpl<{NAME}Mapper, {NAME}> implements {NAME}Service {
}
'@

$controllerTpl = @'
package com.xiegongzhu.crab.module.{MOD}.controller;

import com.xiegongzhu.crab.common.controller.BaseCrudController;
import com.xiegongzhu.crab.module.{MOD}.entity.{NAME};
import com.xiegongzhu.crab.module.{MOD}.service.{NAME}Service;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * {COMMENT} 通用 CRUD（PRO.md 6.2：除审计日志外超管可完整增删改查）
 */
@RestController
@RequestMapping("/{PATH}")
public class {NAME}Controller extends BaseCrudController<{NAME}, {NAME}Service> {
}
'@

function New-EntityBlock([string[]]$fields) {
    return (($fields | ForEach-Object { "    private $_;" }) -join "`n")
}

# ---------- 数据定义 ----------
$business = @(
    @{ mod='member'; list=@(
        @{ n='Member'; t='member'; c='会员（公众号/小程序/H5 UnionID 互通）'; p='member'; f=@('String unionId','String openIdMp','String openIdMini','String openIdH5','String nickname','String avatar','String mobile','Integer gender','String memberLevel','Integer points','BigDecimal balance','Long channelId','Integer status') },
        @{ n='MemberAddress'; t='member_address'; c='会员收货地址'; p='member/address'; f=@('Long memberId','String contact','String mobile','String province','String city','String district','String detail','Integer isDefault') },
        @{ n='MemberCoupon'; t='member_coupon'; c='卡券模板'; p='member/coupon'; f=@('String couponName','String couponType','BigDecimal threshold','BigDecimal discountAmount','BigDecimal discountRate','Integer totalQty','Integer usedQty','LocalDateTime validStart','LocalDateTime validEnd','Integer status') },
        @{ n='MemberCouponLog'; t='member_coupon_log'; c='卡券领取/核销记录'; p='member/coupon-log'; f=@('Long couponId','Long memberId','String status','String orderNo','LocalDateTime usedTime') },
        @{ n='MemberPointLog'; t='member_point_log'; c='积分流水'; p='member/point-log'; f=@('Long memberId','String changeType','Integer points','Integer beforePoints','Integer afterPoints','String source','String bizNo') },
        @{ n='MemberBalanceLog'; t='member_balance_log'; c='储值流水'; p='member/balance-log'; f=@('Long memberId','String changeType','BigDecimal amount','BigDecimal beforeBalance','BigDecimal afterBalance','String bizNo') }
    )},
    @{ mod='product'; list=@(
        @{ n='Product'; t='product'; c='商品（鄱阳湖湖蟹）'; p='product'; f=@('String productNo','Long categoryId','String productName','String productNameEn','String mainImage','String images','String detailHtml','String detailHtmlEn','String origin','String sellMode','BigDecimal retailPrice','BigDecimal wholesalePrice','Integer minOrderQty','Long liveRoomId','String seoTitle','String seoKeywords','String seoDesc','Integer status','Integer sort') },
        @{ n='ProductCategory'; t='product_category'; c='商品分类'; p='product/category'; f=@('Long parentId','String categoryName','String categoryNameEn','String icon','Integer sort','Integer status') },
        @{ n='ProductSku'; t='product_sku'; c='商品 SKU'; p='product/sku'; f=@('Long productId','Long specId','String skuNo','String skuName','BigDecimal retailPrice','BigDecimal wholesalePrice','BigDecimal costPrice','String image','Integer status') },
        @{ n='ProductSpec'; t='product_spec'; c='湖蟹规格（公母/重量档/只数礼盒）'; p='product/spec'; f=@('Long productId','String crabSex','String weightLevel','BigDecimal weightMin','BigDecimal weightMax','Integer pieceCount','String packType') },
        @{ n='Stock'; t='stock'; c='库存（自营 + 批发共用）'; p='product/stock'; f=@('Long skuId','String warehouse','Integer totalQty','Integer availableQty','Integer lockedQty','Integer warnQty') },
        @{ n='StockLog'; t='stock_log'; c='库存流水'; p='product/stock-log'; f=@('Long skuId','String warehouse','String changeType','Integer qty','String bizType','String bizNo') },
        @{ n='Cart'; t='cart'; c='购物车'; p='cart'; f=@('Long memberId','Long skuId','Integer qty','Integer checked') },
        @{ n='LiveRoom'; t='live_room'; c='直播间关联'; p='live'; f=@('String roomName','String platform','String roomNo','String anchor','String cover','String replayUrl','Integer liveStatus','LocalDateTime startTime','LocalDateTime endTime') }
    )},
    @{ mod='trade'; list=@(
        @{ n='Order'; t='t_order'; c='订单（自营 + 批发）'; p='trade/order'; f=@('String orderNo','Long memberId','String bizMode','Long channelId','String orderStatus','String payStatus','BigDecimal totalAmount','BigDecimal discountAmount','BigDecimal freightAmount','BigDecimal payAmount','Long couponId','String payType','LocalDateTime payTime','String receiverName','String receiverMobile','String receiverAddress','LocalDateTime expireTime','String cancelReason','String source') },
        @{ n='OrderItem'; t='t_order_item'; c='订单明细'; p='trade/order-item'; f=@('String orderNo','Long orderId','Long productId','Long skuId','String productName','String skuName','String specDesc','BigDecimal price','Integer qty','BigDecimal amount','String image') },
        @{ n='Payment'; t='t_payment'; c='支付流水（微信/支付宝/储值）'; p='trade/payment'; f=@('String payNo','String orderNo','String payType','String tradeNo','BigDecimal amount','String payStatus','String notifyRaw','BigDecimal refundAmount','LocalDateTime payTime') },
        @{ n='OrderDelivery'; t='t_order_delivery'; c='冷链物流（顺丰单号与轨迹）'; p='trade/delivery'; f=@('String orderNo','String expressCompany','String expressNo','Integer coldChain','String packCheck','Long packerId','String shipStatus','String trackJson','LocalDateTime expressPrintTime','LocalDateTime outboundTime','LocalDateTime shipTime','LocalDateTime signedTime') },
        @{ n='Review'; t='t_review'; c='收货评价'; p='trade/review'; f=@('String orderNo','Long memberId','Long productId','Long skuId','Integer score','String content','String images','Integer survivalRate','Integer isShow','String replyContent') }
    )},
    @{ mod='channel'; list=@(
        @{ n='Channel'; t='t_channel'; c='渠道商（经销商/代理）'; p='channel'; f=@('String channelNo','String channelName','String contactName','String contactMobile','String unionId','String channelLevel','Long parentId','BigDecimal commissionRate','BigDecimal referralRate','BigDecimal creditQuota','BigDecimal usedQuota','BigDecimal timePrice','String status','String licenseImages') },
        @{ n='ChannelRelation'; t='t_channel_relation'; c='渠道下级关系树'; p='channel/relation'; f=@('Long channelId','Long parentId','String path','Integer level') },
        @{ n='ChannelOrder'; t='t_channel_order'; c='渠道报单'; p='channel/report'; f=@('String reportNo','Long channelId','String orderNo','Integer totalQty','BigDecimal totalAmount','String auditStatus','Long auditBy','LocalDateTime auditTime','String auditRemark') },
        @{ n='ChannelOrderItem'; t='t_channel_order_item'; c='渠道报单明细'; p='channel/report-item'; f=@('String reportNo','Long channelId','Long productId','Long skuId','String skuName','BigDecimal channelPrice','Integer qty','BigDecimal amount') },
        @{ n='Commission'; t='t_commission'; c='佣金/转介绍返佣'; p='channel/commission'; f=@('String commissionNo','Long channelId','Long fromChannelId','String orderNo','String commissionType','BigDecimal baseAmount','BigDecimal rate','BigDecimal amount','String settleStatus','String settleNo') },
        @{ n='Settlement'; t='t_settlement'; c='对账结算单'; p='channel/settlement'; f=@('String settleNo','Long channelId','LocalDate periodStart','LocalDate periodEnd','BigDecimal orderAmount','BigDecimal commissionAmount','BigDecimal settleAmount','String status','LocalDateTime confirmTime','LocalDateTime payTime') },
        @{ n='ChannelQuotaLog'; t='t_channel_quota_log'; c='渠道额度流水'; p='channel/quota-log'; f=@('Long channelId','String changeType','BigDecimal amount','BigDecimal beforeQuota','BigDecimal afterQuota','String bizNo') }
    )},
    @{ mod='cms'; list=@(
        @{ n='CmsCategory'; t='cms_category'; c='CMS 栏目'; p='cms/category'; f=@('Long parentId','String categoryName','String categoryNameEn','String categoryCode','Integer sort','Integer status') },
        @{ n='CmsArticle'; t='cms_article'; c='CMS 文章（双语 SEO / 富文本）'; p='cms/article'; f=@('Long categoryId','String title','String titleEn','String summary','String summaryEn','String cover','String contentHtml','String contentHtmlEn','String seoTitle','String seoKeywords','String seoDesc','Integer isTop','String status','LocalDateTime publishTime','Integer viewCount') },
        @{ n='CmsChannelApply'; t='cms_channel_apply'; c='渠道商申请（PC 官网招商）'; p='cms/apply'; f=@('String companyName','String contactName','String contactMobile','String region','String intention','String auditStatus','String auditRemark') }
    )}
)

$systemGen = @(
    @{ n='SysRole'; c='RBAC 角色'; p='system/role' },
    @{ n='SysDict'; c='字典类型'; p='system/dict' },
    @{ n='SysDictItem'; c='字典项'; p='system/dict-item' },
    @{ n='SysLang'; c='语言列表'; p='system/lang' },
    @{ n='SysI18n'; c='多语言词条'; p='system/i18n' },
    @{ n='SysFile'; c='文件记录'; p='system/file' }
)

$allMappers = @(
    @{ mod='system'; list=@('SysUser','SysRole','SysMenu','SysConfig','SysDict','SysDictItem','SysLang','SysI18n','SysStorageConfig','SysFile','SysUserRole','SysRoleMenu','SysAuditLog','SysSensitiveWord') },
    @{ mod='member'; list=$business[0].list | ForEach-Object { $_.n } },
    @{ mod='product'; list=$business[1].list | ForEach-Object { $_.n } },
    @{ mod='trade'; list=$business[2].list | ForEach-Object { $_.n } },
    @{ mod='channel'; list=$business[3].list | ForEach-Object { $_.n } },
    @{ mod='cms'; list=$business[4].list | ForEach-Object { $_.n } }
)

$entityCount = 0; $triadCount = 0; $mapperCount = 0

# ---------- 生成业务实体 + 三件套（Service/Impl/Controller） ----------
foreach ($g in $business) {
    $mod = $g.mod
    foreach ($e in $g.list) {
        $fieldsBlock = New-EntityBlock $e.f
        $entity = $entityTpl.Replace('{MOD}', $mod).Replace('{TABLE}', $e.t).Replace('{COMMENT}', $e.c).Replace('{NAME}', $e.n).Replace('{FIELDS}', $fieldsBlock)
        Write-Java "$root\$mod\entity\$($e.n).java" $entity
        $entityCount++

        $controller = $controllerTpl.Replace('{MOD}', $mod).Replace('{COMMENT}', $e.c).Replace('{NAME}', $e.n).Replace('{PATH}', $e.p)
        Write-Java "$root\$mod\controller\$($e.n)Controller.java" $controller
        $service = $serviceTpl.Replace('{MOD}', $mod).Replace('{NAME}', $e.n)
        Write-Java "$root\$mod\service\$($e.n)Service.java" $service
        $impl = $implTpl.Replace('{MOD}', $mod).Replace('{NAME}', $e.n)
        Write-Java "$root\$mod\service\impl\$($e.n)ServiceImpl.java" $impl
        $triadCount += 3
    }
}

# ---------- 生成 system 域通用三件套 ----------
foreach ($e in $systemGen) {
    $controller = $controllerTpl.Replace('{MOD}', 'system').Replace('{COMMENT}', $e.c).Replace('{NAME}', $e.n).Replace('{PATH}', $e.p)
    Write-Java "$root\system\controller\$($e.n)Controller.java" $controller
    $service = $serviceTpl.Replace('{MOD}', 'system').Replace('{NAME}', $e.n)
    Write-Java "$root\system\service\$($e.n)Service.java" $service
    $impl = $implTpl.Replace('{MOD}', 'system').Replace('{NAME}', $e.n)
    Write-Java "$root\system\service\impl\$($e.n)ServiceImpl.java" $impl
    $triadCount += 3
}

# ---------- 生成全量 Mapper ----------
foreach ($g in $allMappers) {
    foreach ($n in $g.list) {
        $mapper = $mapperTpl.Replace('{MOD}', $g.mod).Replace('{NAME}', $n)
        Write-Java "$root\$($g.mod)\mapper\$($n)Mapper.java" $mapper
        $mapperCount++
    }
}

Write-Host "生成完成：实体 $entityCount 个，Service/Impl/Controller $triadCount 个，Mapper $mapperCount 个"
