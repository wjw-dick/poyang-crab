package com.xiegongzhu.crab.common.sensitive;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.xiegongzhu.crab.module.system.entity.SysSensitiveWord;
import com.xiegongzhu.crab.module.system.mapper.SysSensitiveWordMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * T31 敏感词过滤：内存词库（启动 + 变更时刷新），命中 level=2 直接拦截，level=1 替换为 *
 */
@Service
public class SensitiveWordService {

    private final SysSensitiveWordMapper sensitiveWordMapper;
    private final Map<String, Integer> words = new ConcurrentHashMap<>();
    private volatile boolean loaded = false;

    public SensitiveWordService(SysSensitiveWordMapper sensitiveWordMapper) {
        this.sensitiveWordMapper = sensitiveWordMapper;
    }

    public void refresh() {
        words.clear();
        List<SysSensitiveWord> list = sensitiveWordMapper.selectList(Wrappers.emptyWrapper());
        for (SysSensitiveWord item : list) {
            if (item.getWord() != null && !item.getWord().isBlank()) {
                words.put(item.getWord(), item.getLevel() == null ? 1 : item.getLevel());
            }
        }
        loaded = true;
    }

    private void ensureLoaded() {
        if (!loaded) {
            synchronized (this) {
                if (!loaded) {
                    refresh();
                }
            }
        }
    }

    /** 是否命中拦截级敏感词 */
    public boolean containsBlockWord(String text) {
        if (text == null || text.isEmpty()) {
            return false;
        }
        ensureLoaded();
        for (Map.Entry<String, Integer> entry : words.entrySet()) {
            if (entry.getValue() == 2 && text.contains(entry.getKey())) {
                return true;
            }
        }
        return false;
    }

    /** 替换级敏感词打码 */
    public String filter(String text) {
        if (text == null || text.isEmpty()) {
            return text;
        }
        ensureLoaded();
        String result = text;
        for (Map.Entry<String, Integer> entry : words.entrySet()) {
            if (entry.getValue() == 1 && result.contains(entry.getKey())) {
                result = result.replace(entry.getKey(), "*".repeat(entry.getKey().length()));
            }
        }
        return result;
    }
}
