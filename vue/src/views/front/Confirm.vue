<script setup>
import {ref, onMounted} from 'vue'
import request from '@/utils/request.js'
import {useRoute, useRouter} from 'vue-router'
import {Location, LocationFilled} from '@element-plus/icons-vue'
import {ElMessage} from 'element-plus'

const route = useRoute()
const router = useRouter()

const address = ref([])
const selectedAddressId = ref(null)
const storedAccount = localStorage.getItem('account')
const account = ref(storedAccount ? JSON.parse(storedAccount) : {})

const id = route.query.id
const goods = ref()

const load = () => {
  request.get('/goods/' + id).then(res => {
    goods.value = res.data
  })
}

const loadAddress = () => {
  request.get('/address').then(res => {
    address.value = res.data
    if (res.data.length > 0 && !selectedAddressId.value) {
      selectedAddressId.value = res.data[0].id
    }
  })
}

const confirmOrder = () => {
  if (account.value.id == null) {
    ElMessage.warning('请登录')
    return
  }
  if (selectedAddressId.value === '') {
    ElMessage.error('请选择您的收货地址')
    return
  }
  if (goods.value.status !== '已上架') {
    ElMessage.error('商品未上架或已卖出，请联系卖家确认')
    return
  }
  request.post('/orders', {
    itemId: id,
    addressId: selectedAddressId.value
  }).then(res => {
    if (res.code === '200') {
      ElMessage.success('已下单，请及时支付订单！')
      router.push('/front/orders')
    } else {
      ElMessage.error(res.msg)
    }
  })
}

onMounted(() => {
  load()
  loadAddress()
})
</script>

<template>
  <div class="checkout-page">
    <div class="checkout-container">

      <!-- 步骤提示 -->
      <div class="checkout-steps">
        <span class="step step-active">1. 确认信息</span>
        <span class="step-divider">—</span>
        <span class="step step-inactive">2. 提交订单</span>
        <span class="step-divider">—</span>
        <span class="step step-inactive">3. 完成支付</span>
      </div>

      <div class="checkout-body">
        <!-- 主内容区 -->
        <div class="checkout-main">

          <!-- 交易区域 -->
          <section class="checkout-block">
            <div class="block-head">
              <span class="block-title">交易区域</span>
            </div>
            <div class="trade-grid">
              <div
                  v-for="addr in address"
                  :key="addr.id"
                  class="trade-item"
                  :class="{ 'trade-item--active': selectedAddressId === addr.id }"
                  @click="selectedAddressId = addr.id"
              >
                <img :src="addr.img" :alt="addr.name" class="trade-avatar" />
                <span class="trade-name">{{ addr.name }}</span>
                <span v-if="selectedAddressId === addr.id" class="trade-check">✓</span>
              </div>
            </div>
          </section>

          <!-- 商品信息 -->
          <section class="checkout-block">
            <div class="block-head">
              <span class="block-title">商品信息</span>
            </div>
            <div v-if="goods" class="item-row">
              <img :src="goods.img" :alt="goods.name" class="item-thumb"/>
              <div class="item-meta">
                <p class="item-name">{{ goods.name }}</p>
                <p v-if="goods.info" class="item-info">{{ goods.info }} </p>
              </div>
              <span class="item-unit-price">¥{{ goods.price }}</span>
            </div>
          </section>

        </div>

        <!-- 结算侧边栏 -->
        <aside class="checkout-sidebar">
          <div class="summary-card">
            <h3 class="summary-title">订单汇总</h3>

            <div class="summary-total-row">
              <span class="summary-total-label">商品金额</span>
              <span class="summary-total-amount">
                <em class="currency">¥</em>{{ goods?.price || 0 }}
              </span>
            </div>

            <div class="selected-addr-tip" v-if="selectedAddressId">
              <el-icon>
                <LocationFilled/>
              </el-icon>
              <span>
                {{
                  address.find(a => a.id === selectedAddressId)?.name
                }} &nbsp;
                {{
                  address.find(a => a.id === selectedAddressId)?.phone
                }}&nbsp;
                   {{
                  address.find(a => a.id === selectedAddressId)?.info
                }}
              </span>
            </div>
            <div class="selected-addr-tip selected-addr-tip--warn" v-else>
              <el-icon>
                <Location/>
              </el-icon>
              <span>请选择收货地址</span>
            </div>

            <button class="submit-btn" @click="confirmOrder">确认购买</button>
            <button class="cancel-btn" @click="router.back()">返回上一页</button>
          </div>
        </aside>
      </div>

    </div>
  </div>
</template>

<style scoped>
/* ===== 页面基础 ===== */
.checkout-page {
  min-height: 100vh;
  background: #f4f6f8;
  padding: 32px 20px 60px;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

.checkout-container {
  max-width: 1100px;
  margin: 0 auto;
}

/* ===== 步骤条 ===== */
.checkout-steps {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 28px;
  font-size: 13px;
  color: #aaa;
}

.step {
  font-weight: 500;
}

.step-active {
  color: #2563eb;
}

.step-inactive {
  color: #bbb;
}

.step-divider {
  color: #ddd;
  letter-spacing: 2px;
}

/* ===== 主布局 ===== */
.checkout-body {
  display: flex;
  gap: 20px;
  align-items: flex-start;
}

.checkout-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-width: 0;
}

/* ===== 通用区块 ===== */
.checkout-block {
  background: white;
  border-radius: 10px;
  padding: 24px 28px;
  border: 1px solid #eaecf0;
}

.block-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.block-title {
  font-size: 15px;
  font-weight: 600;
  color: #1a1a2e;
  position: relative;
  padding-left: 12px;
}

.block-title::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 4px;
  height: 16px;
  background: #2563eb;
  border-radius: 2px;
}

.link-btn {
  background: none;
  border: none;
  font-size: 13px;
  color: #2563eb;
  cursor: pointer;
  padding: 0;
  transition: opacity 0.2s;
}

.link-btn:hover {
  opacity: 0.7;
}

/* ===== 地址网格 ===== */
.addr-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 14px;
}

.addr-item {
  border: 1.5px solid #e5e7eb;
  border-radius: 8px;
  padding: 14px 16px;
  display: flex;
  gap: 10px;
  cursor: pointer;
  transition: border-color 0.2s, background 0.2s;
  position: relative;
}

.addr-item:hover {
  border-color: #93c5fd;
}

.addr-item--active {
  border-color: #2563eb;
  background: #eff6ff;
}

.addr-pin {
  font-size: 18px;
  color: #9ca3af;
  flex-shrink: 0;
  margin-top: 2px;
}

.addr-item--active .addr-pin {
  color: #2563eb;
}

.addr-body {
  flex: 1;
  min-width: 0;
}

.addr-street {
  font-size: 14px;
  font-weight: 500;
  color: #111827;
  margin: 0 0 4px;
  line-height: 1.4;
}

.addr-remark {
  font-size: 12px;
  color: #6b7280;
  margin: 0 0 4px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.addr-contact {
  font-size: 12px;
  color: #9ca3af;
  margin: 0;
}

.addr-check {
  position: absolute;
  top: 8px;
  right: 10px;
  font-size: 12px;
  font-weight: 700;
  color: #2563eb;
}

/* ===== 交易区域 ===== */
.trade-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
}

.trade-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  border: 1.5px solid #e5e7eb;
  border-radius: 10px;
  padding: 16px 20px;
  cursor: pointer;
  transition: border-color 0.2s, background 0.2s;
  position: relative;
  min-width: 110px;
}

.trade-item:hover {
  border-color: #93c5fd;
}

.trade-item--active {
  border-color: #2563eb;
  background: #eff6ff;
}

.trade-avatar {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #e5e7eb;
}

.trade-item--active .trade-avatar {
  border-color: #2563eb;
}

.trade-name {
  font-size: 13px;
  font-weight: 500;
  color: #374151;
}

.trade-item--active .trade-name {
  color: #2563eb;
}

.trade-check {
  position: absolute;
  top: 6px;
  right: 10px;
  font-size: 12px;
  font-weight: 700;
  color: #2563eb;
}

/* ===== 商品行 ===== */
.item-row {
  display: flex;
  align-items: center;
  gap: 20px;
}

.item-thumb {
  width: 90px;
  height: 90px;
  border-radius: 8px;
  object-fit: cover;
  background: #f3f4f6;
  flex-shrink: 0;
  border: 1px solid #f0f0f0;
}

.item-meta {
  flex: 1;
  min-width: 0;
}

.item-name {
  font-size: 16px;
  font-weight: 500;
  color: #111827;
  margin: 0 0 6px;
  line-height: 1.5;
}

.item-info {
  font-size: 14px;
  color: #1a1a1a;
  margin-bottom: 8px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-unit-price {
  font-size: 20px;
  font-weight: 600;
  color: #dc2626;
  flex-shrink: 0;
}

/* ===== 结算侧边栏 ===== */
.checkout-sidebar {
  width: 300px;
  flex-shrink: 0;
  position: sticky;
  top: 24px;
}

.summary-card {
  background: white;
  border-radius: 10px;
  padding: 24px;
  border: 1px solid #eaecf0;
}

.summary-title {
  font-size: 15px;
  font-weight: 600;
  color: #1a1a2e;
  margin: 0 0 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
}

.summary-line {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
  margin-bottom: 12px;
}

.summary-key {
  color: #6b7280;
}

.summary-val {
  color: #374151;
  font-weight: 500;
}

.summary-free {
  color: #16a34a;
}

.summary-sep {
  height: 1px;
  background: #f0f0f0;
  margin: 16px 0;
}

.summary-total-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 20px;
}

.summary-total-label {
  font-size: 14px;
  font-weight: 600;
  color: #111827;
}

.summary-total-amount {
  font-size: 26px;
  font-weight: 700;
  color: #dc2626;
  line-height: 1;
}

.currency {
  font-size: 16px;
  font-style: normal;
  margin-right: 1px;
}

/* ===== 已选地址提示 ===== */
.selected-addr-tip {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #374151;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 8px 12px;
  margin-bottom: 16px;
}

.selected-addr-tip--warn {
  color: #b45309;
  background: #fffbeb;
  border-color: #fde68a;
}

/* ===== 按钮 ===== */
.submit-btn {
  width: 100%;
  background: #2563eb;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 13px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s, transform 0.15s;
  margin-bottom: 10px;
}

.submit-btn:hover {
  background: #1d4ed8;
  transform: translateY(-1px);
}

.submit-btn:active {
  transform: translateY(0);
}

.cancel-btn {
  width: 100%;
  background: white;
  color: #6b7280;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 11px;
  font-size: 14px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}

.cancel-btn:hover {
  border-color: #9ca3af;
  color: #374151;
}
</style>
