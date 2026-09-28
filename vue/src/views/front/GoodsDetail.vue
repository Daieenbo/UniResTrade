<script setup>
import {ref, computed, onMounted} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import {ArrowLeft, Star, StarFilled, ChatDotRound, ShoppingCart} from '@element-plus/icons-vue'
import request from '@/utils/request'
import {ElMessage} from 'element-plus'

const route = useRoute()
const router = useRouter()
const id = route.query.id

const goods = ref({})
const categories = ref([])
const users = ref([])
const account = ref(localStorage.getItem('account') ? JSON.parse(localStorage.getItem('account')) : {})

// 当前主图（点缩略图切换）
const currentImg = ref('')

const imageList = computed(() => {
  if (!goods.value.imgList) return goods.value.img ? [goods.value.img] : []
  const imgs = goods.value.imgList.split(',').filter(Boolean)
  return imgs
})

// 状态标签映射
const statusMap = {
  '已上架': {label: '已上架', bg: '#dcfce7', color: '#16a34a'},
  '已下架': {label: '已下架', bg: '#f3f4f6', color: '#6b7280'},
  '已售出': {label: '已售出', bg: '#fee2e2', color: '#dc2626'},
}

const statusInfo = computed(() => statusMap[goods.value.status] || {
  label: goods.value.status,
  bg: '#f3f4f6',
  color: '#6b7280'
})

const categoryName = computed(() => {
  const cat = categories.value.find(c => c.id === goods.value.cateId)
  return cat ? cat.name : '--'
})

const loadGoods = () => {
  request.get('/goods/' + id).then(res => {
    goods.value = res.data
    // 合并封面图与多图，去重
    const allImgs = [res.data.img, ...(res.data.imgList ? res.data.imgList.split(',') : [])].filter(Boolean)
    const unique = [...new Set(allImgs)]
    goods.value.imgList = unique.join(',')
    currentImg.value = unique[0] || ''
  })
}

const loadCategory = () => {
  request.get('/category').then(res => {
    categories.value = res.data
  })
}

const loadUsers = () => {
  request.get('/user').then(res => {
    users.value = res.data || {}
  })
}

const collect = (id) => {
  if (account.value.id == null) {
    ElMessage.warning("请登录")
    return;
  }
  let data = {
    itemId: id,
    userId: account.value.id
  }
  request.post("/collect", data).then(res => {
    if (res.code === '200') {
      goods.value.isCollected = true
      ElMessage.success("收藏成功")
    } else {
      goods.value.isCollected = false
      ElMessage.error(res.msg)
    }
  })
}

const buy = (id) => {
  if (account.value.id === null) {
    ElMessage.warning("请登录");
    return;
  }
  router.push(`/front/confirm?id=${id}`);
};

const handleChat = () => {
  if (!account.value.id) {
    ElMessage.warning('请先登录')
    return
  }
  // 预留在线沟通逻辑，跳转到聊天页面
  ElMessage.info('在线沟通功能即将上线')
}

onMounted(() => {
  window.scrollTo(0, 0)
  loadCategory()
  loadGoods()
  loadUsers()
})
</script>

<template>
  <div class="detail-page">
    <div class="content-wrapper">

      <!-- 返回 -->
      <button class="back-btn" @click="router.back()">
        <ArrowLeft class="back-icon"/>
        返回列表
      </button>

      <!-- 主体内容 -->
      <div class="detail-layout" v-if="goods.id">

        <!-- 左：图片区域 -->
        <div class="image-panel">
          <div class="main-image-wrapper">
            <img v-if="currentImg" :src="currentImg" :alt="goods.name" class="main-image"/>
            <div v-else class="main-image-placeholder">暂无图片</div>
            <!-- 状态标签 -->
            <span class="status-badge" :style="{ background: statusInfo.bg, color: statusInfo.color }">
              {{ statusInfo.label }}
            </span>
          </div>
          <!-- 缩略图列表 -->
          <div class="thumb-list" v-if="imageList.length > 1">
            <div
                v-for="(img, idx) in imageList"
                :key="idx"
                class="thumb-item"
                :class="{ active: currentImg === img }"
                @click="currentImg = img"
            >
              <img :src="img" :alt="'图片' + (idx + 1)" class="thumb-img"/>
            </div>
          </div>
        </div>

        <!-- 右：信息区域 -->
        <div class="info-panel">

          <!-- 商品名称 -->
          <h1 class="goods-title">{{ goods.name }}</h1>

          <!-- 价格 -->
          <div class="price-row">
            <span class="price-label">售价</span>
            <span class="price-value">¥ {{ goods.price }}</span>
          </div>

          <div class="divider"></div>

          <!-- 基本属性 -->
          <div class="attrs">
            <div class="attr-row">
              <span class="attr-label">商品分类</span>
              <span class="attr-value">{{ categoryName }}</span>
            </div>
            <div class="attr-row">
              <span class="attr-label">商品成色</span>
              <span class="attr-value quality-tag" >{{ goods.quality }}</span>
            </div>
            <div class="attr-row">
              <span class="attr-label">卖家</span>
              <span class="attr-value">{{ users.find(c => c.id === goods.userId)?.nickname }}</span>
            </div>
          </div>

          <div class="divider"></div>

          <!-- 商品描述 -->
          <div class="desc-section">
            <p class="desc-label">商品描述</p>
            <p class="desc-text" v-if="goods.info">{{ goods.info }}</p>
            <p class="desc-empty" v-else>卖家暂未填写描述</p>
          </div>

          <div class="divider"></div>

          <!-- 操作按钮 -->
          <div class="action-row" v-if="account.id!==goods.userId">
            <!-- 收藏 -->
            <button
                class="action-btn collect-btn"
                :class="{ collected: goods.isCollected }"
                @click="collect(goods.id)"
            >
              <StarFilled v-if="goods.isCollected" class="btn-icon"/>
              <Star v-else class="btn-icon"/>
              {{ goods.isCollected ? '已收藏' : '收藏' }}
            </button>

            <!-- 在线沟通 -->
            <button class="action-btn chat-btn"
                    @click="router.push('/front/chat?userId='+goods.userId)">
              <ChatDotRound class="btn-icon"/>
              在线沟通
            </button>

            <!-- 立即购买 -->
            <button class="action-btn buy-btn"
                    @click="buy(goods.id)"
                    v-if="goods.status==='已上架'">
              <ShoppingCart class="btn-icon"/>
              立即购买
            </button>
          </div>

          <!-- 免责提示 -->
          <p class="disclaimer">交易请通过平台进行，谨防诈骗，平台不承担私下交易产生的任何纠纷。</p>
        </div>
      </div>

      <!-- 骨架加载态 -->
      <div class="skeleton-wrap" v-else>
        <el-skeleton :rows="8" animated/>
      </div>

    </div>
  </div>
</template>

<style scoped>
.detail-page {
  min-height: 100vh;
  background: #fafaf9;
  padding: 32px 0 80px;
}

.content-wrapper {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 48px;
}

/* 返回按钮 */
.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #78716c;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
  margin-bottom: 36px;
  transition: color 0.2s;
}

.back-btn:hover {
  color: #1c1917;
}

.back-icon {
  width: 16px;
  height: 16px;
}

/* 两栏布局 */
.detail-layout {
  display: grid;
  grid-template-columns: 480px 1fr;
  gap: 56px;
  align-items: flex-start;
}

/* 图片面板 */
.image-panel {
  position: sticky;
  top: 24px;
}

.main-image-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 1 / 1;
  border-radius: 12px;
  overflow: hidden;
  background: #f5f5f4;
  border: 1px solid #e7e5e4;
}

.main-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.main-image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  color: #a8a29e;
}

.status-badge {
  position: absolute;
  top: 14px;
  right: 14px;
  font-size: 12px;
  font-weight: 500;
  padding: 4px 12px;
  border-radius: 20px;
}

.thumb-list {
  display: flex;
  gap: 10px;
  margin-top: 14px;
  flex-wrap: wrap;
}

.thumb-item {
  width: 72px;
  height: 72px;
  border-radius: 8px;
  overflow: hidden;
  border: 2px solid transparent;
  cursor: pointer;
  transition: border-color 0.2s;
  flex-shrink: 0;
}

.thumb-item.active {
  border-color: #1c1917;
}

.thumb-item:hover {
  border-color: #78716c;
}

.thumb-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* 信息面板 */
.info-panel {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.goods-title {
  font-size: 26px;
  font-weight: 500;
  color: #1c1917;
  margin: 0 0 24px 0;
  line-height: 1.35;
  letter-spacing: -0.3px;
}

.price-row {
  display: flex;
  align-items: baseline;
  gap: 12px;
  margin-bottom: 24px;
}

.price-label {
  font-size: 14px;
  color: #a8a29e;
}

.price-value {
  font-size: 34px;
  font-weight: 700;
  color: #e44d26;
  letter-spacing: -0.5px;
  line-height: 1;
}

.divider {
  height: 1px;
  background: #f0eeec;
  margin: 4px 0 20px;
}

/* 属性列表 */
.attrs {
  display: flex;
  flex-direction: column;
  gap: 14px;
  margin-bottom: 20px;
}

.attr-row {
  display: flex;
  align-items: center;
  gap: 16px;
}

.attr-label {
  font-size: 13px;
  color: #a8a29e;
  width: 72px;
  flex-shrink: 0;
}

.attr-value {
  font-size: 14px;
  color: #1c1917;
}

.quality-tag {
  font-weight: 500;
}

/* 描述 */
.desc-section {
  margin-bottom: 20px;
}

.desc-label {
  font-size: 13px;
  color: #a8a29e;
  margin: 0 0 10px 0;
}

.desc-text {
  font-size: 14px;
  line-height: 1.8;
  color: #44403c;
  margin: 0;
  white-space: pre-wrap;
}

.desc-empty {
  font-size: 14px;
  color: #c4bfba;
  margin: 0;
}

/* 操作按钮行 */
.action-row {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.action-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  height: 46px;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  border: none;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.btn-icon {
  width: 18px;
  height: 18px;
}

/* 收藏 */
.collect-btn {
  padding: 0 20px;
  background: white;
  border: 1px solid #e7e5e4;
  color: #57534e;
}

.collect-btn:hover {
  border-color: #1c1917;
  color: #1c1917;
}

.collect-btn.collected {
  background: #fff7ed;
  border-color: #fb923c;
  color: #ea580c;
}

/* 在线沟通 */
.chat-btn {
  padding: 0 20px;
  background: white;
  border: 1px solid #e7e5e4;
  color: #57534e;
}

.chat-btn:hover {
  border-color: #1c1917;
  color: #1c1917;
}

/* 立即购买 */
.buy-btn {
  flex: 1;
  background: #1c1917;
  color: white;
}

.buy-btn:hover {
  background: #292524;
}

/* 免责提示 */
.disclaimer {
  font-size: 12px;
  color: #c4bfba;
  line-height: 1.6;
  margin: 0;
}

/* 骨架 */
.skeleton-wrap {
  margin-top: 40px;
}
</style>
