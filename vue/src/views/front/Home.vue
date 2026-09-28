<script setup>
import { ref, reactive } from 'vue'
import request from '@/utils/request'
import { Search } from '@element-plus/icons-vue'
import {useRouter} from "vue-router";
import {projectName} from "../../../config/config.default.js";

const router = useRouter()

const banners = ref([])
const loadBanner = () => {
  request.get('/banner').then(res => {
    banners.value = res.data;
  });
};
loadBanner();

const notices = ref([])
const loadNotice = () => {
  request.get('/notice').then(res => {
    notices.value = res.data;
  });
};
loadNotice();

const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(3)
const articles = ref([])

const searchForm = reactive({
  keyword: '',
})
// 加载数据
const loadArticle = () => {
  request.get("/article/page", {
    params: {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: searchForm.keyword,
    }
  }).then(res => {
    if (res.data) {
      articles.value = res.data.records
      total.value = res.data.total
    }
  })
}
loadArticle()

// 分页大小变化
const handleSizeChange = (size) => {
  pageSize.value = size
  loadArticle()
}

// 页码变化
const handleCurrentChange = (current) => {
  pageNum.value = current
  loadArticle()
}
const stripHtmlTags = (html) => {
  if (!html) return ''
  // 创建临时 div 元素来解析 HTML
  const tmp = document.createElement('div')
  tmp.innerHTML = html
  // 获取纯文本内容
  return tmp.textContent || tmp.innerText || ''
}

</script>

<template>
  <div class="home-page">
    <!-- 轮播图区域 -->
    <div class="banner-section">
      <el-carousel :interval="5000" height="420px" arrow="always">
        <el-carousel-item v-for="banner in banners" :key="banner.id">
          <div class="banner-slide">
            <img :src="banner.img" :alt="banner.name" class="banner-img" />
            <div class="banner-overlay"></div>
            <div class="banner-content">
              <div class="banner-badge">「{{projectName}}」</div>
              <h2 class="banner-title">{{ banner.name }}</h2>
              <p class="banner-desc">让闲置物品流转起来，让校园生活更轻松</p>
            </div>
          </div>
        </el-carousel-item>
      </el-carousel>
    </div>

    <!-- 公告区域 -->
    <div class="notice-section">
      <div class="content-wrapper">
        <div class="section-header-row">
          <div class="section-label">
            <span class="label-dot"></span>
            平台公告
          </div>
        </div>
        <div class="notice-grid">
          <div v-for="notice in notices" :key="notice.id" class="notice-card">
            <div class="notice-tag">公告</div>
            <div class="notice-header">
              <h3 class="notice-title">{{ notice.name }}</h3>
              <time class="notice-date">{{ notice.time }}</time>
            </div>
            <p class="notice-description">{{ notice.info }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 文章列表区域 -->
    <div class="article-section">
      <div class="content-wrapper">
        <div class="section-header">
          <div class="page-header">
            <div class="header-content">
              <div class="icon-wrapper">
                <img src="../../assets/文章.png" class = "header-icon"/>
              </div>
              <div class="header-text">
                <h1 class="page-title">宣传倡议</h1>
                <p class="page-subtitle">闲置循环，好物共享，共建温暖便捷的校园交易环境</p>
              </div>
            </div>
          </div>

          <div class="search-bar">

            <el-input
                v-model="searchForm.keyword"
                placeholder="搜索文章"
                :prefix-icon="Search"
                clearable
                @keyup.enter="loadArticle"
                @clear="loadArticle"
            />
          </div>
        </div>

        <div class="article-grid">
          <article v-for="article in articles" :key="article.id" class="article-card">
            <div class="article-image-wrapper">
              <img :src="article.img" :alt="article.name" class="article-img" />
            </div>
            <div class="article-body" @click="router.push('/front/articleDetail?id=' + article.id)">
              <time class="article-date">{{ article.time }}</time>
              <h3 class="article-title">{{ article.name }}</h3>
              <p class="article-excerpt">{{ stripHtmlTags(article.content) }}</p>
            </div>
          </article>
        </div>

        <div class="pagination-wrapper" v-if="total > 0">
          <el-pagination
              v-model:current-page="pageNum"
              v-model:page-size="pageSize"
              :page-sizes="[3, 6, 9]"
              layout="total, sizes, prev, pager, next, jumper"
              :total="total"
              background
              @size-change="handleSizeChange"
              @current-change="handleCurrentChange"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ===== 基础 ===== */
.home-page {
  min-height: 100vh;
  background: #fafaf9;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

.content-wrapper {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 40px;
}

/* ===== 轮播图 ===== */
.banner-section {
  width: 100%;
}

.banner-slide {
  position: relative;
  width: 100%;
  height: 450px;
  overflow: hidden;
}

.banner-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.banner-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to bottom, rgba(0,0,0,0.1) 0%, rgba(0,0,0,0.5) 100%);
}

.banner-content {
  position: absolute;
  bottom: 60px;
  left: 72px;
  text-align: left;
}

.banner-badge {
  display: inline-block;
  background: rgba(255,255,255,0.2);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255,255,255,0.4);
  color: white;
  font-size: 12px;
  font-weight: 500;
  letter-spacing: 2px;
  padding: 5px 14px;
  border-radius: 20px;
  margin-bottom: 14px;
}

.banner-title {
  font-size: 38px;
  font-weight: 600;
  color: white;
  margin: 0 0 10px 0;
  text-shadow: 0 2px 12px rgba(0, 0, 0, 0.25);
  line-height: 1.25;
}

.banner-desc {
  font-size: 16px;
  color: rgba(255,255,255,0.85);
  margin: 0;
}

:deep(.el-carousel__container) {
  height: 450px;
}
:deep(.el-carousel__item) {
  background: #d1e8de;
}
:deep(.el-carousel__arrow) {
  background: rgba(255,255,255,0.25);
  border: none;
}
:deep(.el-carousel__arrow:hover) {
  background: rgba(255,255,255,0.45);
}
:deep(.el-carousel__indicator .el-carousel__button) {
  background: rgba(255,255,255,0.5);
  border-radius: 4px;
  width: 24px;
  height: 4px;
}
:deep(.el-carousel__indicator.is-active .el-carousel__button) {
  background: white;
}

.section-header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.section-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 600;
  color: #1a3a2a;
}

.label-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #3d9970;
}

/* ===== 公告区域 ===== */
.notice-section {
  padding: 48px 0 36px;
}

.notice-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 16px;
}

.notice-card {
  background: white;
  padding: 24px 24px 20px;
  border-radius: 12px;
  border: 1px solid #e2efe9;
  transition: box-shadow 0.25s ease, transform 0.25s ease;
  position: relative;
}

.notice-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(61, 153, 112, 0.1);
}

.notice-tag {
  display: inline-block;
  background: #eaf7f1;
  color: #3d9970;
  font-size: 11px;
  font-weight: 600;
  padding: 2px 10px;
  border-radius: 20px;
  margin-bottom: 12px;
  letter-spacing: 1px;
}

.notice-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 10px;
}

.notice-title {
  font-size: 16px;
  font-weight: 600;
  color: #1a3a2a;
  margin: 0;
  line-height: 1.45;
}

.notice-date {
  font-size: 12px;
  color: #9ab5a8;
  white-space: nowrap;
  flex-shrink: 0;
  margin-top: 2px;
}

.notice-description {
  font-size: 14px;
  line-height: 1.7;
  color: #4a7a64;
  margin: 0;
}


/* 文章区域 */
.article-section {
  padding: 40px 0 120px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 48px;
  gap: 32px;
}
/* 页头区域 */
.page-header {
  margin-bottom: 20px;
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


.search-bar {
  width: 100%;
  max-width: 320px;
}

.search-bar :deep(.el-input__wrapper) {
  background: white;
  border: 1px solid #e7e5e4;
  border-radius: 2px;
  box-shadow: none;
  padding: 8px 16px;
  transition: all 0.3s ease;
}

.search-bar :deep(.el-input__wrapper:hover) {
  border-color: #d6d3d1;
}

.search-bar :deep(.el-input__wrapper.is-focus) {
  border-color: #78716c;
  box-shadow: 0 0 0 3px rgba(120, 113, 108, 0.1);
}

.search-bar :deep(.el-input__inner) {
  color: #1c1917;
  font-size: 14px;
}

.search-bar :deep(.el-input__inner::placeholder) {
  color: #a8a29e;
}

.article-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px 20px;
  margin-bottom: 64px;
}

.article-card {
  background: white;
  overflow: hidden;
  transition: transform 0.3s ease;
  cursor: pointer;
}

.article-card:hover {
  transform: translateY(-8px);
}

.article-card:hover .article-img {
  transform: scale(1.05);
}

.article-image-wrapper {
  width: 100%;
  height: 280px;
  overflow: hidden;
  background: #f5f5f4;
}

.article-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.article-body {
  padding: 20px;
}

.article-date {
  display: block;
  font-size: 12px;
  color: #a8a29e;
  margin-bottom: 12px;
  letter-spacing: 1px;
}

.article-title {
  font-size: 18px;
  font-weight: 500;
  color: #1c1917;
  margin: 0 0 16px 0;
  line-height: 1.4;
}

.article-excerpt {
  font-size: 15px;
  line-height: 1.7;
  color: #57534e;
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

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

/* Element Plus 轮播图自定义样式 */
:deep(.el-carousel__container) {
  height: 600px;
}

:deep(.el-carousel__item) {
  background: #f5f5f4;
}
</style>
