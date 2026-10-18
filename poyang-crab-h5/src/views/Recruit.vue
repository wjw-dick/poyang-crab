<template>
  <div class="recruit">
    <h1>渠道批发 · 招商合作</h1>
    <p class="desc">
      我们提供：产地直供渠道专属批发价、分销佣金与转介绍返佣（比例后台可配置）、授信额度、
      报单审核、对账结算与下级经销商管理。经销商 / 代理 / 团购 / 加盟均可申请。
    </p>

    <div class="grid grid-4 perks">
      <div class="card"><h3>产地直供</h3><p>鄱阳湖现捞，冷链直达</p></div>
      <div class="card"><h3>专属批发价</h3><p>渠道价后台可配置</p></div>
      <div class="card"><h3>佣金返佣</h3><p>分销 + 转介绍双收益</p></div>
      <div class="card"><h3>对账结算</h3><p>佣金快照留痕，透明可核</p></div>
    </div>

    <div class="card form">
      <h2>提交合作申请</h2>
      <div class="field">
        <label>公司 / 个人名称 <i>*</i></label>
        <input v-model="form.companyName" placeholder="请输入名称" />
      </div>
      <div class="field">
        <label>联系人 <i>*</i></label>
        <input v-model="form.contactName" placeholder="请输入联系人" />
      </div>
      <div class="field">
        <label>联系电话 <i>*</i></label>
        <input v-model="form.contactMobile" placeholder="请输入手机号" />
      </div>
      <div class="field">
        <label>所在区域</label>
        <input v-model="form.region" placeholder="如 江西省南昌市" />
      </div>
      <div class="field">
        <label>合作意向</label>
        <textarea v-model="form.intention" rows="4" placeholder="预计月拿货量 / 渠道类型 / 团购或加盟等"></textarea>
      </div>
      <button class="btn-primary" :disabled="submitting" @click="submit">
        {{ submitting ? '提交中...' : '提交申请' }}
      </button>
      <p v-if="submitted" class="ok">提交成功，工作人员将尽快与您联系。</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { portalApi } from '@/api/portal'
import { useSeo } from '@/composables/useSeo'

/** T16 招商（渠道商申请）表单：POST /portal/channel-apply */
const form = reactive({ companyName: '', contactName: '', contactMobile: '', region: '', intention: '' })
const submitting = ref(false)
const submitted = ref(false)

useSeo(() => ({
  title: '招商合作 · 渠道批发加盟',
  keywords: '湖蟹批发,鄱阳湖湖蟹加盟,河蟹代理,生鲜渠道合作',
  desc: '螃蟹小公主渠道招商：产地直供、渠道专属批发价、分销佣金与转介绍返佣、授信额度与对账结算。'
}))

const submit = async () => {
  if (!form.companyName || !form.contactName || !form.contactMobile) {
    alert('请填写公司/个人名称、联系人与联系电话')
    return
  }
  submitting.value = true
  try {
    await portalApi.channelApply({ ...form })
    submitted.value = true
    Object.keys(form).forEach((key) => ((form as Record<string, any>)[key] = ''))
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
h1 {
  font-size: 26px;
  margin: 0 0 10px;
}
.desc {
  color: #475569;
  line-height: 1.9;
  max-width: 860px;
}
.perks {
  margin: 18px 0;
}
.perks h3 {
  margin: 0 0 6px;
  font-size: 15px;
}
.perks p {
  margin: 0;
  color: #64748b;
  font-size: 13px;
}
.form h2 {
  font-size: 18px;
  margin: 0 0 14px;
}
.field {
  margin-bottom: 12px;
  max-width: 520px;
}
.field label {
  display: block;
  font-size: 13px;
  margin-bottom: 6px;
  color: #334155;
}
.field label i {
  color: #e11d48;
  font-style: normal;
}
.field input,
.field textarea {
  width: 100%;
  border: 1px solid #d7dee8;
  border-radius: 8px;
  padding: 10px 12px;
  font-size: 14px;
  font-family: inherit;
}
.ok {
  color: #16a34a;
  font-size: 13px;
  margin-top: 10px;
}
</style>
