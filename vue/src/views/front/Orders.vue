
<script setup>
import { ref, onMounted, reactive, watch } from 'vue'
import { ShoppingCart, List, Search } from '@element-plus/icons-vue'
import request from "@/utils/request.js"
import { ElMessage } from "element-plus"
import {useRouter} from "vue-router";
const router = useRouter()
const activeGroup = ref('我卖出的')
const activeStatus = ref('全部')

const groups = [
  { label: '我卖出的', value: '我卖出的' },
  { label: '我买到的', value: '我买到的' },
]
const statusTabs = [
  { label: '全部',   value: '全部'   },
  { label: '待支付', value: '待支付' },
  { label: '待发货', value: '待发货' },
  { label: '待收货', value: '待收货' },
]

const orders = ref([])
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(10)
const searchForm = reactive({ keyword: '' })
const users = ref([])

const load = () => {
  request.get("/orders/front/page", {
    params: {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: searchForm.keyword,
      status: activeStatus.value,
      flag: activeGroup.value,
    }
  }).then(res => {
    if (res.data) {
      orders.value = res.data.records
      total.value = res.data.total
    }
  })
}

const loadUser = () => {
  request.get('/user').then(res => { users.value = res.data })
}

const getStatusMeta = (status) => {
  const map = {
    '交易关闭': { cls: 'stt-closed', text: '交易关闭' },
    '交易完成': { cls: 'stt-done',   text: '交易完成' },
    '待支付':   { cls: 'stt-pay',    text: '待支付'   },
    '待发货':   { cls: 'stt-ship',   text: '待发货'   },
    '待收货':   { cls: 'stt-recv',   text: '待收货'   },
  }
  return map[status] || { cls: '', text: status }
}

const handleSearch = () => { pageNum.value = 1; load() }
const handlePageChange = (val) => { pageNum.value = val; load() }

watch([activeGroup, activeStatus], () => { pageNum.value = 1; load() })

const pay = (id) => {
  request.get('/orders/pay/' + id).then(res => {
    res.code === '200' ? ElMessage.success("已支付") : ElMessage.error(res.msg)
    load()
  })
}
const cancel = (id) => {
  request.get('/orders/cancel/' + id).then(res => {
    res.code === '200' ? ElMessage.success("已取消") : ElMessage.error(res.msg)
    load()
  })
}
const shipment = (id) => {
  request.get('/orders/shipment/' + id).then(res => {
    res.code === '200' ? ElMessage.success("发货成功") : ElMessage.error(res.msg)
    load()
  })
}
const receipt = (id) => {
  request.get('/orders/receipt/' + id).then(res => {
    res.code === '200' ? ElMessage.success("收货成功") : ElMessage.error(res.msg)
    load()
  })
}
onMounted(() => { load(); loadUser() })
</script>

<template>
  <div class="orders-page">
    <div class="orders-container">

      <!-- 页面标题 -->
      <div class="orders-topbar">
        <div class="orders-topbar-left">
          <div class="orders-topbar-icon">
            <el-icon><ShoppingCart /></el-icon>
          </div>
          <div>
            <h1 class="orders-heading">我的订单</h1>
            <p class="orders-sub">管理你的交易记录</p>
          </div>
        </div>
        <div class="orders-search-wrap">
          <el-input
              v-model="searchForm.keyword"
              placeholder="搜索订单号..."
              clearable
              @keyup.enter="handleSearch"
              @clear="handleSearch"
          >
            <template #prefix><el-icon><Search /></el-icon></template>
          </el-input>
        </div>
      </div>

      <!-- 控制栏 -->
      <div class="orders-ctrl">
        <div class="orders-group-toggle">
          <button
              v-for="g in groups"
              :key="g.value"
              :class="['toggle-btn', { 'toggle-btn--active': activeGroup === g.value }]"
              @click="activeGroup = g.value"
          >{{ g.label }}</button>
        </div>
        <div class="orders-status-tabs">
          <button
              v-for="s in statusTabs"
              :key="s.value"
              :class="['status-tab', { 'status-tab--active': activeStatus === s.value }]"
              @click="activeStatus = s.value"
          >{{ s.label }}</button>
        </div>
      </div>

      <!-- 订单列表 -->
      <div class="orders-list">
        <div v-for="order in orders" :key="order.id" class="order-card">

          <!-- 卡片头部：订单号 + 时间 + 状态 -->
          <div class="order-card-head">
            <div class="order-card-head-left">
              <span class="order-no-label">订单号</span>
              <span class="order-no-val">{{ order.no }}</span>
              <span class="order-time">{{ order.time }}</span>
            </div>
            <span :class="['order-status-tag', getStatusMeta(order.status).cls]">
              {{ getStatusMeta(order.status).text }}
            </span>
          </div>

          <!-- 卡片主体 -->
          <div class="order-card-body">

            <!-- 商品信息 -->
            <div class="order-goods">
              <img :src="order.img" class="order-goods-img" alt="商品图" />
              <div class="order-goods-detail">
                <p class="order-goods-name">{{ order.itemName }}</p>
                <p class="order-goods-price">¥{{ order.price?.toFixed(2) }}</p>
              </div>
            </div>

            <!-- 分隔线 -->
            <div class="order-divider"></div>

            <!-- 交易区域 -->
            <div class="order-trade-block">
              <span class="order-trade-label">交易区域</span>
              <div class="order-trade-grid">
                <div
                    class="order-trade-item"
                >
                  <img :src="order.addressImg" :alt="order.addressName" class="order-trade-avatar" />
                  <span class="order-trade-name">{{ order.addressName }}</span>
                </div>
              </div>
            </div>

            <!-- 分隔线 -->
            <div class="order-divider"></div>

            <!-- 交易方 + 操作 -->
            <div class="order-party-actions">
              <div class="order-party">
                <span class="order-party-label">{{ activeGroup === '我卖出的' ? '买家' : '卖家' }}</span>
                <img
                    :src="activeGroup === '我卖出的'
                    ? users.find(u => u.id === order.toId)?.avatarUrl
                    : users.find(u => u.id === order.fromId)?.avatarUrl"
                    class="order-party-avatar"
                    alt="头像"
                />
                <span class="order-party-name">
                  {{ activeGroup === '我卖出的'
                    ? users.find(u => u.id === order.toId)?.nickname
                    : users.find(u => u.id === order.fromId)?.nickname }}
                </span>
              </div>

              <div class="order-actions">
                <button
                    v-if="order.status !== '交易关闭' && activeGroup === '我买到的'"
                    class="oact-btn oact-btn--primary"
                    @click="router.push('/front/chat?userId='+ order.fromId)"
                >联系卖家</button>
                <button
                    v-if="order.status !== '交易关闭' && activeGroup === '我卖出的'"
                    class="oact-btn oact-btn--primary"
                    @click="router.push('/front/chat?userId='+ order.toId)"
                >联系买家</button>
                <button
                    v-if="order.status === '待支付' && activeGroup === '我买到的'"
                    class="oact-btn oact-btn--primary"
                    @click="pay(order.id)"
                >立即支付</button>
                <button
                    v-if="order.status === '待支付'"
                    class="oact-btn oact-btn--danger"
                    @click="cancel(order.id)"
                >取消订单</button>
                <button
                    v-if="order.status === '待发货' && activeGroup === '我卖出的'"
                    class="oact-btn oact-btn--primary"
                    @click="shipment(order.id)"
                >立即发货</button>
                <button
                    v-if="order.status === '待收货' && activeGroup === '我买到的'"
                    class="oact-btn oact-btn--primary"
                    @click="receipt(order.id)"
                >确认收货</button>
                <span v-if="order.status === '交易关闭'" class="oact-none">—</span>
              </div>
            </div>

          </div>
        </div>

        <!-- 空状态 -->
        <div v-if="orders.length === 0" class="orders-empty">
          <el-icon class="orders-empty-icon"><List /></el-icon>
          <p class="orders-empty-text">暂无订单记录</p>
        </div>
      </div>

      <!-- 分页 -->
      <div v-if="total > 0" class="orders-pager">
        <el-pagination
            v-model:current-page="pageNum"
            :page-size="pageSize"
            :total="total"
            layout="total, prev, pager, next, jumper"
            background
            @current-change="handlePageChange"
        />
      </div>

    </div>
  </div>
</template>

<style scoped>
/* ===== 整体 ===== */
.orders-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding: 36px 0 72px;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

.orders-container {
  max-width: 860px;
  margin: 0 auto;
  padding: 0 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* ===== 顶部栏 ===== */
.orders-topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
}

.orders-topbar-left {
  display: flex;
  align-items: center;
  gap: 14px;
}

.orders-topbar-icon {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  background: #111;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 20px;
  flex-shrink: 0;
}

.orders-heading {
  font-size: 20px;
  font-weight: 700;
  color: #111;
  margin: 0 0 2px;
  line-height: 1.2;
}

.orders-sub {
  font-size: 13px;
  color: #aaa;
  margin: 0;
}

.orders-search-wrap {
  width: 240px;
  flex-shrink: 0;
}

.orders-search-wrap :deep(.el-input__wrapper) {
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: none;
  padding: 7px 14px;
  transition: border-color 0.2s;
}

.orders-search-wrap :deep(.el-input__wrapper:hover),
.orders-search-wrap :deep(.el-input__wrapper.is-focus) {
  border-color: #111;
  box-shadow: none;
}

/* ===== 控制栏 ===== */
.orders-ctrl {
  background: white;
  border-radius: 10px;
  border: 1px solid #e8e8e8;
  padding: 14px 18px;
  display: flex;
  align-items: center;
  gap: 24px;
}

.orders-group-toggle {
  display: flex;
  background: #f5f5f5;
  border-radius: 7px;
  padding: 3px;
  gap: 2px;
  flex-shrink: 0;
}

.toggle-btn {
  padding: 6px 18px;
  border: none;
  background: none;
  border-radius: 5px;
  font-size: 13px;
  font-weight: 500;
  color: #888;
  cursor: pointer;
  transition: all 0.2s;
}

.toggle-btn--active {
  background: white;
  color: #111;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

.orders-status-tabs {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.status-tab {
  padding: 5px 14px;
  border: 1px solid #e8e8e8;
  background: none;
  border-radius: 20px;
  font-size: 13px;
  color: #888;
  cursor: pointer;
  transition: all 0.2s;
}

.status-tab:hover {
  border-color: #111;
  color: #111;
}

.status-tab--active {
  background: #111;
  border-color: #111;
  color: white;
}

/* ===== 订单卡片 ===== */
.orders-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.order-card {
  background: white;
  border: 1px solid #e8e8e8;
  border-radius: 12px;
  overflow: hidden;
  transition: box-shadow 0.25s, border-color 0.25s;
}

.order-card:hover {
  border-color: #bbb;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.07);
}

/* 卡片头 */
.order-card-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 20px;
  background: #fafafa;
  border-bottom: 1px solid #ebebeb;
}

.order-card-head-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.order-no-label {
  font-size: 11px;
  font-weight: 600;
  color: #bbb;
  letter-spacing: 0.5px;
}

.order-no-val {
  font-size: 12px;
  color: #555;
  font-family: 'Courier New', monospace;
}

.order-time {
  font-size: 12px;
  color: #bbb;
}

/* 状态标签 */
.order-status-tag {
  font-size: 12px;
  font-weight: 500;
  padding: 3px 12px;
  border-radius: 20px;
}

.stt-closed { background: #f5f5f5; color: #aaa;    border: 1px solid #e8e8e8; }
.stt-done   { background: #f0f0f0; color: #333;    border: 1px solid #ddd;    }
.stt-pay    { background: #fff7ed; color: #ea580c; border: 1px solid #fed7aa; }
.stt-ship   { background: #f5f5f5; color: #555;    border: 1px solid #ddd;    }
.stt-recv   { background: #fafafa; color: #333;    border: 1px solid #e0e0e0; }

/* 卡片主体 */
.order-card-body {
  padding: 18px 20px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

/* 商品信息 */
.order-goods {
  display: flex;
  align-items: center;
  gap: 14px;
}

.order-goods-img {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
  flex-shrink: 0;
  border: 1px solid #ebebeb;
  background: #f5f5f5;
}

.order-goods-detail {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}

.order-goods-name {
  font-size: 15px;
  font-weight: 500;
  color: #111;
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 480px;
}

.order-goods-price {
  font-size: 16px;
  font-weight: 700;
  color: #111;
  margin: 0;
}

/* 分隔线 */
.order-divider {
  height: 1px;
  background: #f0f0f0;
}

/* 交易区域 */
.order-trade-block {
  display: flex;
  flex-direction: column;
  gap: 10px;
  background: #fafafa;
  border: 1px solid #ebebeb;
  border-radius: 8px;
  padding: 12px 14px;
}

.order-trade-label {
  font-size: 12px;
  font-weight: 600;
  color: #bbb;
  letter-spacing: 0.4px;
}

.order-trade-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.order-trade-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  border: 1.5px solid #e5e7eb;
  border-radius: 10px;
  padding: 10px 16px;
  min-width: 90px;
  background: white;
}

.order-trade-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #e5e7eb;
}

.order-trade-name {
  font-size: 12px;
  font-weight: 500;
  color: #374151;
}

/* 交易方 + 操作 */
.order-party-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.order-party {
  display: flex;
  align-items: center;
  gap: 8px;
}

.order-party-label {
  font-size: 12px;
  color: #bbb;
}

.order-party-avatar {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid #e8e8e8;
  flex-shrink: 0;
}

.order-party-name {
  font-size: 13px;
  color: #555;
  max-width: 120px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* 操作按钮 */
.order-actions {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.oact-btn {
  padding: 6px 16px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  border: 1px solid transparent;
  transition: all 0.2s;
  white-space: nowrap;
}

.oact-btn--primary {
  background: #111;
  color: white;
  border-color: #111;
}

.oact-btn--primary:hover {
  background: #333;
  border-color: #333;
}

.oact-btn--danger {
  background: white;
  color: #555;
  border-color: #ddd;
}

.oact-btn--danger:hover {
  background: #f5f5f5;
  border-color: #bbb;
  color: #111;
}

.oact-none {
  font-size: 14px;
  color: #ddd;
}

/* ===== 空状态 ===== */
.orders-empty {
  background: white;
  border: 1px solid #e8e8e8;
  border-radius: 12px;
  padding: 64px 24px;
  text-align: center;
}

.orders-empty-icon {
  font-size: 48px;
  color: #ddd;
  margin-bottom: 12px;
}

.orders-empty-text {
  font-size: 14px;
  color: #bbb;
  margin: 0;
}

/* ===== 分页 ===== */
.orders-pager {
  display: flex;
  justify-content: center;
  padding: 8px 0;
}

.orders-pager :deep(.el-pager li) {
  background: white;
  border: 1px solid #e8e8e8;
  border-radius: 6px;
  color: #555;
}

.orders-pager :deep(.el-pager li:hover) {
  border-color: #111;
  color: #111;
}

.orders-pager :deep(.el-pager li.is-active) {
  background: #111;
  border-color: #111;
  color: white;
}

.orders-pager :deep(.btn-prev),
.orders-pager :deep(.btn-next) {
  background: white;
  border: 1px solid #e8e8e8;
  border-radius: 6px;
  color: #555;
}

.orders-pager :deep(.btn-prev:hover),
.orders-pager :deep(.btn-next:hover) {
  border-color: #111;
  color: #111;
}
</style>
