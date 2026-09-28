<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Search, User, Grid } from '@element-plus/icons-vue'
import request from '@/utils/request'
import {useRouter} from "vue-router";

const router = useRouter()
const categories = ref([])
const goods = ref([])
const users = ref([])
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(12)


const searchForm = reactive({
  keyword: '',
  cateId: 0,
});

const loadCategory = () => {
  request.get('/category').then(res => {
    categories.value = res.data
  })
}

const loadUser = () => {
  request.get('/user').then(res => {
    users.value = res.data
  })
}

const load = () => {
  request.get("/goods/front/page", {
    params: {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: searchForm.keyword,
      cateId: searchForm.cateId,
    }
  }).then(res => {
    if (res.data) {
      goods.value = res.data.records
      total.value = res.data.total
    }
  })
}

const handleTypeFilter = (typeId) => {
  searchForm.cateId = typeId;
  pageNum.value = 1
  load()
}

const handleSearch = () => {
  pageNum.value = 1
  load()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  load()
}

const handleCurrentChange = (current) => {
  pageNum.value = current
  load()
}

onMounted(() => {
  window.scrollTo(0, 0)
  loadCategory()
  load()
  loadUser()
})
</script>

<template>
  <div class="post-page">
    <div class="content-wrapper">
      <!-- 页头区域 -->
      <div class="page-header">
        <div class="header-content">
          <div class="icon-wrapper">
            <img src="../../assets/闲置资源.png" class = "header-icon"/>
          </div>
          <div class="header-text">
            <h1 class="page-title">闲置资源</h1>
            <p class="page-subtitle">好物不闲置，省钱又省心，淘你所爱</p>
          </div>
        </div>
      </div>

      <!-- 分类和搜索栏 -->
      <div class="filter-section">
        <div class="category-tabs">
          <button
              class="category-tab"
              :class="{ active: searchForm.cateId === 0 }"
              @click="handleTypeFilter(0)"
          >
            全部
          </button>
          <button
              v-for="category in categories"
              :key="category.id"
              class="category-tab"
              :class="{ active: searchForm.cateId === category.id }"
              @click="handleTypeFilter(category.id)"
          >
            {{ category.name }}
          </button>
        </div>

        <div class="search-box">
          <el-input
              v-model="searchForm.keyword"
              placeholder="搜索物品名称……"
              :prefix-icon="Search"
              clearable
              @keyup.enter="handleSearch"
              @clear="handleSearch"
          />
        </div>
      </div>

      <!-- 商品列表 -->
      <div class="goods-grid">
        <div v-for="item in goods" :key="item.id" class="goods-card" @click="router.push('/front/goodsDetail?id=' + item.id)">
          <div class="goods-image-wrapper">
            <img v-if="item.img" :src="item.img" :alt="item.name" class="goods-img" />
            <div v-else class="goods-placeholder">
              <Grid class="placeholder-icon" />
            </div>
            <span v-if="item.cateId" class="goods-category-badge">
              {{ categories.find(c => c.id === item.cateId)?.name }}
            </span>
          </div>
          <div class="goods-info">
            <h3 class="goods-name">{{ item.name }}</h3>
            <div class="goods-meta">
              <User class="meta-icon" />
              <span class="goods-seller">{{ users.find(c => c.id === item.userId)?.nickname }}</span>
            </div>
            <div class="goods-bottom">
              <span class="goods-price">¥ {{ item.price }}</span>
              <span class="goods-btn">查看详情</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-if="goods.length === 0" class="empty-state">
        <Grid class="empty-icon" />
        <p class="empty-text">暂无商品</p>
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
  </div>
</template>

<style scoped>
.post-page {
  min-height: 100vh;
  background: #fafaf9;
  padding: 20px 0 50px;
}

.content-wrapper {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 48px;
}

/* 页头区域 */
.page-header {
  margin-bottom: 64px;
}

.header-content {
  display: flex;
  align-items: center;
  gap: 24px;
}

.header-icon {
  width: 72px;
  height: 72px;
}

.header-text {
  flex: 1;
}

.page-title {
  font-size: 36px;
  font-weight: 400;
  color: #1c1917;
  margin: 0 0 8px 0;
  letter-spacing: -0.5px;
}

.page-subtitle {
  font-size: 16px;
  color: #78716c;
  margin: 0;
  line-height: 1.6;
}

/* 筛选区域 */
.filter-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 32px;
  margin-bottom: 48px;
  padding-bottom: 32px;
  border-bottom: 1px solid #e7e5e4;
}

.category-tabs {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  flex: 1;
}

.category-tab {
  padding: 10px 24px;
  background: white;
  border: 1px solid #e7e5e4;
  border-radius: 24px;
  font-size: 14px;
  color: #57534e;
  cursor: pointer;
  transition: all 0.3s ease;
  outline: none;
}

.category-tab:hover {
  border-color: #78716c;
  color: #1c1917;
}

.category-tab.active {
  background: #1c1917;
  border-color: #1c1917;
  color: white;
}

.search-box {
  width: 280px;
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

/* 商品网格 */
.goods-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  margin-bottom: 64px;
}

.goods-card {
  background: white;
  border-radius: 10px;
  overflow: hidden;
  border: 1px solid #e7e5e4;
  cursor: pointer;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.goods-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.09);
}

.goods-image-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 1 / 1;
  overflow: hidden;
  background: #f5f5f4;
}

.goods-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.4s ease;
}

.goods-card:hover .goods-img {
  transform: scale(1.05);
}

.goods-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f4;
}

.placeholder-icon {
  width: 48px;
  height: 48px;
  color: #d6d3d1;
}

.goods-category-badge {
  position: absolute;
  top: 10px;
  left: 10px;
  font-size: 11px;
  font-weight: 500;
  color: white;
  background: rgba(0, 0, 0, 0.45);
  backdrop-filter: blur(4px);
  padding: 3px 10px;
  border-radius: 20px;
}

.goods-info {
  padding: 14px 16px 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.goods-name {
  font-size: 15px;
  font-weight: 500;
  color: #1c1917;
  margin: 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.goods-meta {
  display: flex;
  align-items: center;
  gap: 5px;
}

.meta-icon {
  width: 13px;
  height: 13px;
  color: #a8a29e;
  flex-shrink: 0;
}

.goods-seller {
  font-size: 12px;
  color: #a8a29e;
}

.goods-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 4px;
}

.goods-price {
  font-size: 18px;
  font-weight: 600;
  color: #e44d26;
  letter-spacing: -0.3px;
}

.goods-btn {
  font-size: 12px;
  color: #78716c;
  border: 1px solid #e7e5e4;
  border-radius: 4px;
  padding: 4px 10px;
  transition: all 0.2s ease;
}

.goods-card:hover .goods-btn {
  background: #1c1917;
  color: white;
  border-color: #1c1917;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 80px 0;
}

.empty-icon {
  width: 72px;
  height: 72px;
  color: #d6d3d1;
  margin-bottom: 16px;
}

.empty-text {
  font-size: 16px;
  color: #a8a29e;
  margin: 0;
}

/* 分页 */
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
