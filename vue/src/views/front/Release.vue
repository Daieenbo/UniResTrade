<script setup>
import { ref, reactive } from 'vue'
import { Delete, UploadFilled, ArrowLeft } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import request from '../../utils/request'
import { serverHost } from '../../../config/config.default'
import { useRouter } from 'vue-router'

const router = useRouter()

const account = ref(localStorage.getItem('account') ? JSON.parse(localStorage.getItem('account')) : {})

const form = reactive({
  name: '',
  info: '',
  quality: '',
  price: '',
  cateId: '',
  img: '',
})

const imgList = ref([])
const categories = ref([])
const loadCategory = () => {
  request.get('/category').then(res => {
    categories.value = res.data
  })
}
loadCategory()

const qualityOptions = ['全新', '几乎全新', '9成新', '8成新', '7成新', '6成新及以下']

const handleCoverUploadSuccess = (res) => {
  form.img = res
}

const handleImgListUploadSuccess = (res) => {
  imgList.value.push(res)
}

const removeImg = (index) => {
  imgList.value.splice(index, 1)
}

const validateForm = () => {
  if (!form.name.trim()) { ElMessage.warning('请填写物品标题'); return false }
  if (!form.img) { ElMessage.warning('请上传物品封面'); return false }
  if (!form.info.trim()) { ElMessage.warning('请填写物品描述'); return false }
  if (!form.quality) { ElMessage.warning('请选择物品成色'); return false }
  if (!form.price || Number(form.price) <= 0) { ElMessage.warning('请填写有效的价格'); return false }
  if (!form.cateId) { ElMessage.warning('请选择物品分类'); return false }
  return true
}

const submitting = ref(false)
const handleRelease = () => {
  if (!validateForm()) return
  submitting.value = true
  const payload = {
    ...form,
    userId: account.value.id,
    imgList: imgList.value.join(','),
  }
  request.post('/goods', payload).then(res => {
    if (res.code === '200') {
      ElMessage.success('发布成功')
      router.push('/front/goods')
    } else {
      ElMessage.error(res.msg || '发布失败，请重试')
    }
  }).finally(() => {
    submitting.value = false
  })
}

const handleReset = () => {
  form.name = ''
  form.info = ''
  form.quality = ''
  form.price = ''
  form.cateId = ''
  form.img = ''
  imgList.value = []
}
</script>

<template>
  <div class="pub-page">
    <div class="pub-container">

      <!-- 页头 -->
      <div class="pub-header">
        <el-button text :icon="ArrowLeft" @click="router.back()" class="pub-back">返回</el-button>
        <div class="pub-title-block">
          <h1 class="pub-title">发布闲置</h1>
          <p class="pub-subtitle">填写物品信息，等待审核后即可展示给其他同学</p>
        </div>
      </div>

      <el-form :model="form" label-position="top" class="pub-form">
        <div class="pub-grid">

          <!-- 左列：基本信息 -->
          <div class="pub-col">
            <div class="pub-card">
              <div class="pub-card__title">基本信息</div>

              <el-form-item label="物品标题" required>
                <el-input
                    v-model="form.name"
                    placeholder="简洁描述物品，如「95新 高数教材第七版」"
                    maxlength="40"
                    show-word-limit
                />
              </el-form-item>

              <el-form-item label="物品描述" required>
                <el-input
                    v-model="form.info"
                    type="textarea"
                    :rows="5"
                    placeholder="描述物品的详细情况，如购入时间、使用频率、是否有划痕等"
                    maxlength="500"
                    show-word-limit
                />
              </el-form-item>

              <div class="pub-row">
                <el-form-item label="物品成色" required class="pub-flex">
                  <el-select v-model="form.quality" placeholder="请选择成色" style="width: 100%">
                    <el-option v-for="q in qualityOptions" :key="q" :label="q" :value="q"/>
                  </el-select>
                </el-form-item>

                <el-form-item label="期望价格（元）" required class="pub-flex">
                  <el-input-number
                      v-model="form.price"
                      :min="0.01"
                      :precision="2"
                      :step="1"
                      placeholder="0.00"
                      style="width: 100%"
                      controls-position="right"
                  />
                </el-form-item>
              </div>

              <el-form-item label="物品分类" required>
                <el-select v-model="form.cateId" placeholder="请选择分类" style="width: 100%">
                  <el-option v-for="item in categories" :key="item.id" :label="item.name" :value="item.id"/>
                </el-select>
              </el-form-item>
            </div>
          </div>

          <!-- 右列：图片上传 -->
          <div class="pub-col">
            <div class="pub-card">
              <div class="pub-card__title">物品图片</div>

              <el-form-item label="封面图片" required>
                <el-upload
                    :action="`${serverHost}/web/upload`"
                    :on-success="handleCoverUploadSuccess"
                    :show-file-list="false"
                    accept="image/*"
                    class="pub-cover-uploader"
                >
                  <div v-if="form.img" class="pub-cover-preview">
                    <img :src="form.img" alt="封面" class="pub-cover-img"/>
                    <div class="pub-cover-mask">点击更换</div>
                  </div>
                  <div v-else class="pub-cover-placeholder">
                    <el-icon class="pub-upload-icon">
                      <UploadFilled/>
                    </el-icon>
                    <p class="pub-upload-hint">点击上传封面图</p>
                    <p class="pub-upload-tip">建议尺寸 800×800，JPG / PNG</p>
                  </div>
                </el-upload>
              </el-form-item>

              <el-form-item label="更多图片">
                <div class="pub-imglist">
                  <div class="pub-imglist__grid">
                    <div v-for="(img, index) in imgList" :key="index" class="pub-imglist__item">
                      <img :src="img" alt="图片" class="pub-imglist__thumb"/>
                      <button class="pub-imglist__del" @click.prevent="removeImg(index)">
                        <el-icon>
                          <Delete/>
                        </el-icon>
                      </button>
                    </div>

                    <el-upload
                        v-if="imgList.length < 6"
                        :action="`${serverHost}/web/upload`"
                        :on-success="handleImgListUploadSuccess"
                        :show-file-list="false"
                        accept="image/*"
                        multiple
                        class="pub-imglist__add"
                    >
                      <div class="pub-imglist__add-inner">
                        <el-icon>
                          <UploadFilled/>
                        </el-icon>
                        <span>添加</span>
                      </div>
                    </el-upload>
                  </div>
                  <p class="pub-upload-tip">最多上传 6 张，每张建议不超过 5MB</p>
                </div>
              </el-form-item>
            </div>
          </div>

        </div>

        <!-- 底部操作 -->
        <div class="pub-actions">
          <el-button size="large" @click="handleReset" class="pub-reset-btn">重置</el-button>
          <el-button
              type="primary"
              size="large"
              :loading="submitting"
              @click="handleRelease"
              class="pub-submit-btn"
          >
            {{ submitting ? '发布中...' : '立即发布' }}
          </el-button>
        </div>

      </el-form>
    </div>
  </div>
</template>

<style scoped>
/* ===== 页面基础 ===== */
.pub-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding: 40px 24px 80px;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

.pub-container {
  max-width: 960px;
  margin: 0 auto;
}

/* ===== 页头 ===== */
.pub-header {
  margin-bottom: 28px;
}

.pub-back {
  color: #888;
  font-size: 14px;
  padding: 0;
  margin-bottom: 14px;
}

.pub-back:hover {
  color: #222;
}

.pub-title {
  font-size: 24px;
  font-weight: 600;
  color: #111;
  margin: 0 0 5px 0;
  line-height: 1.3;
}

.pub-subtitle {
  font-size: 13px;
  color: #888;
  margin: 0;
}

/* ===== 表单布局 ===== */
.pub-form {
  width: 100%;
}

.pub-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

.pub-card {
  background: #fff;
  border-radius: 10px;
  border: 1px solid #e8e8e8;
  padding: 26px 26px 14px;
}

.pub-card__title {
  font-size: 14px;
  font-weight: 600;
  color: #111;
  margin-bottom: 18px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
  letter-spacing: 0.3px;
}

.pub-row {
  display: flex;
  gap: 14px;
}

.pub-flex {
  flex: 1;
}

/* ===== Element Plus 覆盖（黑白风格）===== */
:deep(.el-form-item__label) {
  font-size: 13px;
  font-weight: 500;
  color: #444;
  padding-bottom: 6px;
  line-height: 1.4;
}

:deep(.el-input__wrapper),
:deep(.el-textarea__inner) {
  border-radius: 7px;
  border: 1px solid #d9d9d9;
  box-shadow: none;
  background: #fafafa;
  transition: all 0.2s ease;
}

:deep(.el-input__wrapper:hover),
:deep(.el-textarea__inner:hover) {
  border-color: #999;
}

:deep(.el-input__wrapper.is-focus),
:deep(.el-textarea__inner:focus) {
  border-color: #222;
  box-shadow: 0 0 0 3px rgba(0, 0, 0, 0.07);
  background: #fff;
}

:deep(.el-select .el-input__wrapper) {
  border-radius: 7px;
}

:deep(.el-input-number .el-input__wrapper) {
  border-radius: 7px;
}

:deep(.el-input__inner),
:deep(.el-textarea__inner) {
  color: #111;
}

:deep(.el-input__inner::placeholder),
:deep(.el-textarea__inner::placeholder) {
  color: #bbb;
}

/* ===== 封面上传 ===== */
.pub-cover-uploader {
  width: 100%;
  display: block;
}

:deep(.pub-cover-uploader .el-upload) {
  width: 100%;
  display: block;
}

.pub-cover-placeholder,
.pub-cover-preview {
  width: 100%;
  height: 196px;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
}

.pub-cover-placeholder {
  border: 2px dashed #d9d9d9;
  background: #fafafa;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.2s ease;
}

.pub-cover-placeholder:hover {
  border-color: #555;
  background: #f3f3f3;
}

.pub-upload-icon {
  font-size: 34px;
  color: #bbb;
}

.pub-upload-hint {
  font-size: 14px;
  color: #555;
  margin: 0;
  font-weight: 500;
}

.pub-upload-tip {
  font-size: 12px;
  color: #bbb;
  margin: 0;
}

.pub-cover-preview {
  position: relative;
}

.pub-cover-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.pub-cover-mask {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 14px;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.pub-cover-preview:hover .pub-cover-mask {
  opacity: 1;
}

/* ===== 多图上传 ===== */
.pub-imglist {
  width: 100%;
}

.pub-imglist__grid {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 8px;
}

.pub-imglist__item {
  position: relative;
  width: 78px;
  height: 78px;
  flex-shrink: 0;
}

.pub-imglist__thumb {
  width: 78px;
  height: 78px;
  object-fit: cover;
  border-radius: 7px;
  border: 1px solid #e8e8e8;
  display: block;
}

.pub-imglist__del {
  position: absolute;
  top: -7px;
  right: -7px;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #333;
  color: #fff;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  padding: 0;
  z-index: 1;
  transition: background 0.2s;
}

.pub-imglist__del:hover {
  background: #000;
}

.pub-imglist__add {
  flex-shrink: 0;
}

:deep(.pub-imglist__add .el-upload) {
  display: block;
}

.pub-imglist__add-inner {
  width: 78px;
  height: 78px;
  border: 2px dashed #d9d9d9;
  border-radius: 7px;
  background: #fafafa;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  cursor: pointer;
  font-size: 12px;
  color: #aaa;
  transition: all 0.2s ease;
}

.pub-imglist__add-inner:hover {
  border-color: #555;
  background: #f3f3f3;
  color: #333;
}

.pub-imglist__add-inner .el-icon {
  font-size: 20px;
}

/* ===== 底部操作 ===== */
.pub-actions {
  background: #fff;
  border-radius: 10px;
  border: 1px solid #e8e8e8;
  padding: 18px 26px;
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 12px;
}

.pub-reset-btn {
  border-radius: 7px;
  padding: 0 28px;
  font-size: 14px;
  color: #555;
  border-color: #d9d9d9;
  background: #fff;
}

.pub-reset-btn:hover {
  color: #111;
  border-color: #999;
  background: #fafafa;
}

/* 发布按钮保留绿色 */
.pub-submit-btn {
  border-radius: 7px;
  padding: 0 36px;
  font-size: 15px;
  background: #3d9970;
  border-color: #3d9970;
}

.pub-submit-btn:hover {
  background: #339962;
  border-color: #339962;
}

/* ===== 响应式 ===== */
@media (max-width: 768px) {
  .pub-grid {
    grid-template-columns: 1fr;
  }

  .pub-row {
    flex-direction: column;
    gap: 0;
  }

  .pub-page {
    padding: 20px 16px 60px;
  }
}
</style>
