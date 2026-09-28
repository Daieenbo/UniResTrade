<script setup>
import { ref, onMounted } from 'vue'
import {useRoute, useRouter} from 'vue-router'
import request from '@/utils/request'
import { ArrowLeft } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const article = ref({})
const id = route.query.id;

const loadArticle = () => {
  request.get('/article/' + id).then(res => {
    article.value = res.data
    })

}

onMounted(() => {
  window.scrollTo(0, 0)
  loadArticle()
})

const goBack = () => {
  router.back()
}
</script>

<template>
  <div class="article-detail-page">
    <div class="detail-container">
      <!-- 返回按钮 -->
      <button class="back-button" @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
        <span>返回</span>
      </button>

      <header class="article-header">
        <h1 class="article-title">{{ article.name }}</h1>
        <time class="article-meta">
         发布时间： {{ article.time }}</time>
      </header>

      <div v-if="article.img" class="article-hero">
        <img :src="article.img" :alt="article.name" class="article-hero-img" />
      </div>

      <article class="article-content">
        <div v-html="article.content" class="rich-content"></div>
      </article>
    </div>
  </div>
</template>

<style scoped>
.article-detail-page {
  min-height: 100vh;
  background: #fafaf9;
  padding: 20px 24px 50px;
}

.detail-container {
  max-width: 800px;
  margin: 0 auto;
}

/* 返回按钮 */
.back-button {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  margin-bottom: 48px;
  background: white;
  border: 1px solid #e7e5e4;
  border-radius: 2px;
  color: #57534e;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.back-button:hover {
  border-color: #78716c;
  color: #1c1917;
}

/* 文章头部 */
.article-header {
  margin-bottom: 48px;
}

.article-meta {
  margin-top: 10px;
  display: block;
  font-size: 13px;
  color: #a8a29e;
  letter-spacing: 1px;
  margin-bottom: 16px;
}

.article-title {
  font-size: 42px;
  font-weight: 500;
  color: #1c1917;
  line-height: 1.2;
  letter-spacing: -1px;
  margin: 0;
}

/* 文章图片 */
.article-hero {
  width: 100%;
  margin-bottom: 64px;
  overflow: hidden;
  background: #f5f5f4;
}

.article-hero-img {
  width: 100%;
  height: auto;
  display: block;
}

/* 文章内容 */
.article-content {
  background: white;
  padding: 64px;
  border-radius: 2px;
}

.rich-content {
  line-height: 1.8; /* 行高设置 */
  font-size: 16px; /* 字体大小 */
  color: #333; /* 字体颜色 */
  word-wrap: break-word; /* 自动换行 */
  overflow-wrap: break-word; /* 处理长文本 */
}
/* 图片样式 */
.rich-content img {
  max-width: 100% !important; /* 最大宽度为100% */
  width: auto !important; /* 自动宽度 */
  height: auto !important; /* 自动高度 */
  display: block !important; /* 块级显示 */
  margin: 15px auto !important; /* 自动居中 */
  border-radius: 4px; /* 圆角 */
  box-sizing: border-box !important; /* 包含内边距和边框 */
}
/* 视频样式 */
.rich-content video {
  max-width: 100% !important; /* 最大宽度为100% */
  width: auto !important; /* 自动宽度 */
  height: auto !important; /* 自动高度 */
  display: block !important; /* 块级显示 */
  margin: 15px auto !important; /* 自动居中 */
  border-radius: 4px; /* 圆角 */
}
/* 处理iframe嵌入内容 */
.rich-content iframe {
  max-width: 100% !important; /* 最大宽度为100% */
  height: auto !important; /* 自动高度 */
  display: block; /* 块级显示 */
  margin: 15px auto; /* 自动居中 */
}
/* 确保所有媒体元素都受到限制 */
.rich-content * {
  max-width: 100% !important; /* 最大宽度为100% */
  box-sizing: border-box; /* 包含内边距和边框 */
}


</style>
