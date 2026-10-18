package com.xiegongzhu.crab.common.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.TableFieldInfo;
import com.baomidou.mybatisplus.core.metadata.TableInfo;
import com.baomidou.mybatisplus.core.metadata.TableInfoHelper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.xiegongzhu.crab.common.entity.BaseEntity;
import com.xiegongzhu.crab.common.result.PageResult;
import com.xiegongzhu.crab.common.result.R;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 通用 CRUD 基类。
 *
 * PRO.md 6.2 红线：除审计日志只读外，系统参数 / 商品 / 订单 / CMS / 会员 / 菜单 /
 * 渠道商等所有业务模块，超级管理员具备完整增删改查能力。
 * 各业务模块 Controller 继承本类即可获得 page/detail/create/update/delete/batch。
 *
 * 审计日志请使用 @AuditLog(module = "...", operation = "...") 标注在具体模块的自定义方法上。
 */
public abstract class BaseCrudController<T extends BaseEntity, S extends IService<T>> {

    @Autowired
    protected S service;

    /**
     * 分页查询（带通用筛选）。
     *
     * 除 current/size 外的查询参数按「实体属性名 → 数据库列名」自动映射后拼进 WHERE：
     *   * 数字（如 categoryId=1、status=1）走等值比较
     *   * 其它（如 productName=礼盒、orderNo=DD2026）走模糊匹配
     * 这样各业务模块无需逐个手写 Wrapper，列表页筛选开箱即用。
     */
    @GetMapping("/page")
    public R<PageResult<T>> page(@RequestParam(defaultValue = "1") long current,
                                 @RequestParam(defaultValue = "10") long size,
                                 @RequestParam Map<String, Object> params) {
        return R.ok(PageResult.of(service.page(new Page<>(current, size), buildQuery(params))));
    }

    /** 由查询参数构造 WHERE 条件（属性名自动转列名，空值忽略） */
    protected QueryWrapper<T> buildQuery(Map<String, Object> params) {
        QueryWrapper<T> wrapper = new QueryWrapper<>();
        Map<String, String> propertyToColumn = new HashMap<>();
        String keyColumn = null;
        TableInfo tableInfo = TableInfoHelper.getTableInfo(service.getEntityClass());
        if (tableInfo != null) {
            keyColumn = tableInfo.getKeyColumn();
            if (tableInfo.getKeyProperty() != null) {
                propertyToColumn.put(tableInfo.getKeyProperty(), keyColumn);
            }
            for (TableFieldInfo field : tableInfo.getFieldList()) {
                propertyToColumn.put(field.getProperty(), field.getColumn());
            }
        }
        if (params != null) {
            params.forEach((key, value) -> {
                if ("current".equals(key) || "size".equals(key) || value == null) {
                    return;
                }
                String text = String.valueOf(value).trim();
                if (text.isEmpty()) {
                    return;
                }
                String column = propertyToColumn.get(key);
                if (column == null) {
                    // 兼容直接传数据库列名（下划线），其余未知参数一律忽略
                    if (!key.matches("^[A-Za-z_][A-Za-z0-9_]*$")) {
                        return;
                    }
                    column = key;
                }
                if (text.matches("^-?\\d+(\\.\\d+)?$")) {
                    wrapper.eq(column, value);
                } else {
                    wrapper.like(column, text);
                }
            });
        }
        if (keyColumn != null) {
            // 固定按主键升序，避免分页结果漂移
            wrapper.orderByAsc(keyColumn);
        }
        return wrapper;
    }

    /** 列表查询（不分页，用于下拉/穿梭） */
    @GetMapping("/list")
    public R<List<T>> list() {
        return R.ok(service.list());
    }

    /** 详情 */
    @GetMapping("/{id}")
    public R<T> detail(@PathVariable Long id) {
        return R.ok(service.getById(id));
    }

    /** 新增 */
    @PostMapping
    public R<Long> create(@RequestBody T entity) {
        service.save(entity);
        return R.ok(entity.getId());
    }

    /** 修改 */
    @PutMapping
    public R<Boolean> update(@RequestBody T entity) {
        return R.ok(service.updateById(entity));
    }

    /** 逻辑删除 */
    @DeleteMapping("/{id}")
    public R<Boolean> delete(@PathVariable Long id) {
        return R.ok(service.removeById(id));
    }

    /** 批量逻辑删除 */
    @DeleteMapping("/batch")
    public R<Boolean> deleteBatch(@RequestBody List<Long> ids) {
        return R.ok(service.removeByIds(ids));
    }
}
