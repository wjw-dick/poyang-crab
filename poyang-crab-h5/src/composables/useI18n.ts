import { ref } from 'vue'
import { portalApi } from '@/api/portal'

/**
 * T09/T15 前台多语言切换器：词条来自后端 sys_i18n（/portal/i18n/{langCode}）
 * 默认中文，切换后写入 localStorage 并重新拉取词条包。
 */
const LANG_KEY = 'crab_lang'
const lang = ref(localStorage.getItem(LANG_KEY) || 'zh-CN')
const bundle = ref<Record<string, string>>({})

const fallback: Record<string, string> = {
  'footer.brand': '螃蟹小公主｜鄱阳湖产地蟹主 · 现捞鲜活 · 顺丰冷链直达'
}

export function useI18n() {
  const loadBundle = async () => {
    try {
      bundle.value = await portalApi.i18n(lang.value)
    } catch (error) {
      bundle.value = {}
    }
  }

  /** 词条读取：未配置时回退内置文案 / 词条键 */
  const t = (key: string) => bundle.value[key] || fallback[key] || key

  const switchLang = async () => {
    localStorage.setItem(LANG_KEY, lang.value)
    document.documentElement.lang = lang.value
    document.body.dataset.lang = lang.value
    await loadBundle()
  }

  return { lang, bundle, t, loadBundle, switchLang }
}
