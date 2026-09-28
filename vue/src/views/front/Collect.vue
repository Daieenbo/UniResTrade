<script setup>
import { ref, onMounted } from 'vue'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import { StarFilled, ChatDotSquare, Search } from '@element-plus/icons-vue'

const router = useRouter()
const goods = ref([])
const keyword = ref('')
const pageNum = ref(1)
const pageSize = ref(12)
const total = ref(0)

const load = () => {
  request.get('/goods/collect/page', {
    params: {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: keyword.value,
    }
  }).then(res => {
    if (res.code === '200') {
      goods.value = res.data.records || []
      total.value = res.data?.total || 0
    }
  })
}

const reset = () => {
  keyword.value = ''
  load()
}

const handleSizeChange = (val) => {
  pageSize.value = val
  load()
}

const handleCurrentChange = (val) => {
  pageNum.value = val
  load()
}

const cancel = (id) => {
  request.delete('/collect/' + id).then(res => {
    if (res.code === '200') {
      ElMessage.success('取消收藏成功')
      load()
    }
  })
}

onMounted(() => {
  load()
})
</script>

<template>
  <div class="fav-page">

    <!-- 页头 -->
    <div class="fav-header">
      <div class="fav-header__title">
        <StarFilled class="fav-header__icon"/>
        我的收藏
      </div>
      <span class="fav-header__count" v-if="total > 0">共 {{ total }} 件</span>
    </div>

    <!-- 搜索栏 -->
    <div class="search-box">
      <el-input
          v-model="keyword"
          placeholder="搜索物品名称……"
          :prefix-icon="Search"
          clearable
          @keyup.enter="load"
          @clear="load"
      />
    </div>

    <!-- 空状态 -->
    <div v-if="goods.length === 0" class="fav-empty">
      <StarFilled class="fav-empty__icon"/>
      <p class="fav-empty__text">暂无收藏商品</p>
      <p class="fav-empty__sub">去逛逛，发现心仪的二手好物</p>
    </div>

    <!-- 商品网格 -->
    <div v-else class="fav-grid">
      <div v-for="item in goods" :key="item.id" class="fav-card">

        <!-- 图片区 -->
        <div class="fav-card__img-wrap">
          <img
              :src="item.img || '/placeholder.svg?height=200&width=200'"
              :alt="item.name"
              class="fav-card__img"
          />

          <!-- 已售出遮罩 -->
          <div v-if="item.status === '已售出'" class="fav-card__sold-mask">
            <span class="fav-card__sold-label">已售出</span>
          </div>

          <!-- hover 操作层 -->
          <div class="fav-card__actions">
            <button class="fav-card__act-btn fav-card__act-btn--cancel" @click.stop="cancel(item.id)">
              <el-icon>
                <StarFilled/>
              </el-icon>
              取消收藏
            </button>
            <button
                v-if="item.status !== '已售出'"
                class="fav-card__act-btn fav-card__act-btn--chat"
                @click.stop="router.push('/front/chat?userId=' + item.userId)"
            >
              <el-icon>
                <ChatDotSquare/>
              </el-icon>
              我想要
            </button>
          </div>
        </div>

        <!-- 信息区 -->
        <div class="fav-card__body" @click="router.push('/front/goodsDetail?id=' + item.id)">
          <p class="fav-card__name">{{ item.name }}</p>
          <div class="fav-card__footer">
            <span class="fav-card__price">¥{{ item.price }}</span>
            <span class="fav-card__link">查看详情 →</span>
          </div>
        </div>

      </div>
    </div>

    <!-- 分页 -->
    <div class="pagination-wrapper" v-if="total > 0">
      <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :page-sizes="[ 12, 24, 48]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          background
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
      />
    </div>

  </div>
</template>

<style scoped>
/* ===== 页面容器 ===== */
.fav-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 40px 80px;
  background: #fafaf9;
  min-height: 100vh;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

/* ===== 页头 ===== */
.fav-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 28px;
}

.fav-header__title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 22px;
  font-weight: 600;
  color: #1a3a2a;
}

.fav-header__icon {
  width: 22px;
  height: 22px;
  color: #efdf29;
}

.fav-header__count {
  font-size: 13px;
  color: #6b9080;
  background: #e6f4ee;
  padding: 4px 14px;
  border-radius: 20px;
}

/* ===== 搜索栏 ===== */

.search-box {
  width: 280px;
  margin-bottom: 20px;
}

.search-box :deep(.el-input__wrapper) {
  background: white;
  border: 1px solid #e7e5e4;
  border-radius: 24px;
  box-shadow: none;
  padding: 8px 20px;
  transition: all 0.3s ease;
}

.search-box :deep(.el-input__wrapper:hover) {
  border-color: #d6d3d1;
}

.search-box :deep(.el-input__wrapper.is-focus) {
  border-color: #78716c;
  box-shadow: 0 0 0 3px rgba(120, 113, 108, 0.1);
}

.search-box :deep(.el-input__inner) {
  color: #1c1917;
  font-size: 14px;
}

.search-box :deep(.el-input__inner::placeholder) {
  color: #a8a29e;
}

/* ===== 空状态 ===== */
.fav-empty {
  text-align: center;
  padding: 80px 0 60px;
  color: #9ab5a8;
}

.fav-empty__icon {
  width: 48px;
  height: 48px;
  color: #e1d079;
  margin-bottom: 16px;
}

.fav-empty__text {
  font-size: 16px;
  font-weight: 500;
  color: #0e0c0c;
  margin: 0 0 6px;
}

.fav-empty__sub {
  font-size: 13px;
  color: #363638;
  margin: 0;
}

/* ===== 商品网格 ===== */
.fav-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 48px;
}

/* ===== 商品卡片 ===== */
.fav-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid #e2efe9;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.fav-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 28px rgba(61, 153, 112, 0.12);
}

/* 图片区 */
.fav-card__img-wrap {
  position: relative;
  width: 100%;
  aspect-ratio: 1 / 1;
  overflow: hidden;
  background: #eaf7f1;
}

.fav-card__img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.4s ease;
}

.fav-card:hover .fav-card__img {
  transform: scale(1.05);
}

/* 已售出遮罩 */
.fav-card__sold-mask {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1;
  pointer-events: none;
}

.fav-card__sold-label {
  font-size: 16px;
  font-weight: 600;
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.7);
  padding: 6px 18px;
  border-radius: 4px;
  letter-spacing: 3px;
}

/* hover 操作层 */
.fav-card__actions {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  opacity: 0;
  transform: translateY(8px);
  transition: all 0.25s ease;
  z-index: 2;
}

.fav-card:hover .fav-card__actions {
  opacity: 1;
  transform: translateY(0);
}

.fav-card__act-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
  padding: 11px 6px;
  border: none;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
  color: white;
}

.fav-card__act-btn--cancel {
  background: rgb(236, 105, 56);
  backdrop-filter: blur(6px);
}

.fav-card__act-btn--cancel:hover {
  background: rgba(193, 110, 61, 0.66);
}

.fav-card__act-btn--chat {
  background: rgba(20, 65, 43, 0.72);
  backdrop-filter: blur(6px);
  border-left: 1px solid rgba(255, 255, 255, 0.2);
}

.fav-card__act-btn--chat:hover {
  background: rgba(26, 58, 42, 0.92);
}

/* 信息区 */
.fav-card__body {
  padding: 14px 16px 16px;
  cursor: pointer;
}

.fav-card__name {
  font-size: 14px;
  font-weight: 500;
  color: #1a3a2a;
  margin: 0 0 10px;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.fav-card__footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.fav-card__price {
  font-size: 18px;
  font-weight: 600;
  color: #e44d26;
  letter-spacing: -0.3px;
}

.fav-card__link {
  font-size: 12px;
  color: #3d9970;
  transition: opacity 0.2s;
}

.fav-card:hover .fav-card__link {
  opacity: 0.7;
}

/* ===== 分页 ===== */
.pagination-wrapper {
  display: flex;
  justify-content: center;
  padding-top: 48px;
}

.pagination-wrapper :deep(.el-pagination) {
  gap: 8px;
}

.pagination-wrapper :deep(.el-pager li) {
  background: white;
  border: 1px solid #e7e5e4;
  border-radius: 2px;
  color: #57534e;
  font-weight: 400;
  min-width: 36px;
  height: 36px;
  line-height: 34px;
}

.pagination-wrapper :deep(.el-pager li:hover) {
  color: #1c1917;
  border-color: #78716c;
}

.pagination-wrapper :deep(.el-pager li.is-active) {
  background: #1c1917;
  border-color: #1c1917;
  color: white;
}

.pagination-wrapper :deep(.btn-prev),
.pagination-wrapper :deep(.btn-next) {
  background: white;
  border: 1px solid #e7e5e4;
  border-radius: 2px;
  color: #57534e;
  width: 36px;
  height: 36px;
}

.pagination-wrapper :deep(.btn-prev:hover),
.pagination-wrapper :deep(.btn-next:hover) {
  color: #1c1917;
  border-color: #78716c;
}
</style>
