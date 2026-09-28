<script setup>
import {ref, reactive, onMounted} from 'vue'
import {Search, Edit, Delete, Grid, UploadFilled} from '@element-plus/icons-vue'
import {ElMessage, ElMessageBox} from 'element-plus'
import request from '@/utils/request.js'
import {useRouter} from 'vue-router'
import {serverHost} from '../../../config/config.default.js'

const router = useRouter()

const goods = ref([])
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(12)

const searchForm = reactive({
  keyword: '',
})


const load = () => {
  request.get('/goods/my/page', {
    params: {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: searchForm.keyword,
    }
  }).then(res => {
    if (res.data) {
      goods.value = res.data.records
      total.value = res.data.total
    }
  })
}

const handleStatusFilter = (status) => {
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

// ===== 编辑 =====
const form = ref({})
const dialogVisible = ref(false)
const imgList = ref([])
const categories = ref([])

const loadCategory = () => {
  request.get('/category').then(res => {
    categories.value = res.data
  })
}

const handleEdit = (item) => {
  form.value = JSON.parse(JSON.stringify(item))
  imgList.value = form.value.imgList ? form.value.imgList.split(',') : []
  dialogVisible.value = true
}

const save = () => {
  form.value.imgList = imgList.value.length > 0 ? imgList.value.join(',') : ''
  request.post('/goods', form.value).then(res => {
    if (res.code === '200') {
      ElMessage.success('保存成功')
      dialogVisible.value = false
      load()
    } else {
      ElMessage.error('保存失败')
    }
  })
}

const handleImgUploadSuccess = (res) => {
  form.value.img = res
}

const handleImgListUploadSuccess = (res) => {
  imgList.value.push(res)
}

const removeImgList = (index) => {
  imgList.value.splice(index, 1)
}

// ===== 删除 =====
const del = (id) => {
  request.delete('/goods/' + id).then(res => {
    if (res.code === '200') {
      ElMessage.success('删除成功')
      load()
    } else {
      ElMessage.error('删除失败')
    }
  })
}

const confirmDelete = (id) => {
  ElMessageBox.confirm('确定要删除这件商品吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(() => del(id))
}

// 状态标签样式映射
const statusClass = (status) => {
  const map = {
    '已上架': 'st-sale',
    '已下架': 'st-off',
    '已售出': 'st-sold',
  }
  return map[status] || ''
}

onMounted(() => {
  loadCategory()
  load()
})
</script>

<template>
  <div class="mg-page">
    <div class="mg-wrapper">

      <!-- 页头 -->
      <div class="mg-header">
        <div class="mg-header-left">
          <h1 class="mg-title">我的物品</h1>
          <p class="mg-subtitle">管理你发布的所有二手商品</p>
        </div>
        <div class="mg-header-right">
          <div class="mg-search">
            <el-input
                v-model="searchForm.keyword"
                placeholder="搜索物品名称..."
                :prefix-icon="Search"
                clearable
                @keyup.enter="handleSearch"
                @clear="handleSearch"
            />
          </div>
        </div>
      </div>

      <!-- 状态筛选 + 统计 -->
      <div class="mg-filter">
        <div class="mg-status-tabs">

        </div>
        <span class="mg-total-label">共 {{ total }} 件</span>
      </div>

      <!-- 商品网格 -->
      <div class="mg-grid" v-if="goods.length > 0">
        <div
            v-for="item in goods"
            :key="item.id"
            class="mg-card"
        >
          <!-- 图片区 -->
          <div class="mg-card-img" @click="router.push('/front/goodsDetail?id=' + item.id)">
            <img v-if="item.img" :src="item.img" :alt="item.name" class="mg-img"/>
            <div v-else class="mg-img-placeholder">
              <Grid class="mg-placeholder-icon"/>
            </div>
            <!-- 分类徽章 -->
            <span v-if="item.cateId" class="mg-cate-badge">
              {{ categories.find(c => c.id === item.cateId)?.name }}
            </span>
            <!-- 已售出遮罩 -->
            <div v-if="item.status === '已售出'" class="mg-sold-mask">
              <span class="mg-sold-text">已售出</span>
            </div>
          </div>

          <!-- 信息区 -->
          <div class="mg-card-info">
            <div class="mg-card-top">
              <h3 class="mg-name">{{ item.name }}</h3>
              <span class="mg-status-tag" :class="statusClass(item.status)">{{ item.status }}</span>
            </div>
            <div class="mg-card-meta">
              <span class="mg-quality" v-if="item.quality">{{ item.quality }}</span>
            </div>
            <div class="mg-card-bottom">
              <span class="mg-price">¥ {{ item.price }}</span>
              <div class="mg-actions" v-if="item.status !== '已售出'">
                <button class="mg-act-btn mg-act-btn--edit" @click.stop="handleEdit(item)">
                  <Edit class="mg-act-icon"/>
                  编辑
                </button>
                <button class="mg-act-btn mg-act-btn--del" @click.stop="confirmDelete(item.id)">
                  <Delete class="mg-act-icon"/>
                  删除
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-else class="mg-empty">
        <Grid class="mg-empty-icon"/>
        <p class="mg-empty-text">暂无商品</p>
      </div>

      <!-- 分页 -->
      <div class="mg-pagination" v-if="total > 0">
        <el-pagination
            v-model:current-page="pageNum"
            v-model:page-size="pageSize"
            :page-sizes="[12, 24, 48]"
            layout="total, sizes, prev, pager, next, jumper"
            :total="total"
            background
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
        />
      </div>
    </div>

    <!-- 编辑弹窗 -->
    <el-dialog v-model="dialogVisible" title="编辑商品" width="480px" center>
      <el-form :model="form" label-width="88px">
        <el-form-item label="商品名称">
          <el-input v-model="form.name" placeholder="请输入名称"/>
        </el-form-item>
        <el-form-item label="封面图片">
          <div class="dlg-upload-row">
            <el-avatar v-if="form.img" :src="form.img" :size="72" shape="square"/>
            <el-upload :action="`${serverHost}/web/upload`" :on-success="handleImgUploadSuccess"
                       :show-file-list="false">
              <el-button size="small" :icon="UploadFilled">{{ form.img ? '更换' : '上传' }}</el-button>
            </el-upload>
          </div>
        </el-form-item>
        <el-form-item label="更多图片">
          <div class="dlg-imglist">
            <div v-for="(img, idx) in imgList" :key="idx" class="dlg-imglist-item">
              <el-avatar :src="img" :size="64" shape="square"/>
              <button class="dlg-imglist-del" @click="removeImgList(idx)">×</button>
            </div>
            <el-upload :action="`${serverHost}/web/upload`" :on-success="handleImgListUploadSuccess"
                       :show-file-list="false" multiple>
              <el-button size="small" :icon="UploadFilled">上传</el-button>
            </el-upload>
          </div>
        </el-form-item>
        <el-form-item label="商品描述">
          <el-input v-model="form.info" type="textarea" :rows="3" placeholder="请输入描述"/>
        </el-form-item>
        <el-form-item label="成色">
          <el-radio-group v-model="form.quality">
            <el-radio value="全新">全新</el-radio>
            <el-radio value="9成新">9成新</el-radio>
            <el-radio value="8成新">8成新</el-radio>
            <el-radio value="7成新">7成新</el-radio>
            <el-radio value="6成新及以下">6成新及以下</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="价格">
          <el-input v-model="form.price" type="number" placeholder="请输入价格"/>
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="form.cateId" placeholder="请选择分类" style="width: 220px">
            <el-option v-for="c in categories" :key="c.id" :label="c.name" :value="c.id"/>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="save">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
/* ===== 整体 ===== */
.mg-page {
  min-height: 100vh;
  background: #fafaf9;
  padding: 32px 0 72px;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

.mg-wrapper {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 48px;
}

/* ===== 页头 ===== */
.mg-header {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 24px;
  margin-bottom: 32px;
}

.mg-title {
  font-size: 32px;
  font-weight: 600;
  color: #1c1917;
  margin: 0 0 6px 0;
  letter-spacing: -0.5px;
}

.mg-subtitle {
  font-size: 14px;
  color: #a8a29e;
  margin: 0;
}

.mg-search {
  width: 260px;
}

.mg-search :deep(.el-input__wrapper) {
  background: white;
  border: 1px solid #e7e5e4;
  border-radius: 24px;
  box-shadow: none;
  padding: 8px 20px;
  transition: all 0.25s;
}

.mg-search :deep(.el-input__wrapper:hover),
.mg-search :deep(.el-input__wrapper.is-focus) {
  border-color: #78716c;
  box-shadow: none;
}

/* ===== 筛选栏 ===== */
.mg-filter {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 32px;
  padding-bottom: 24px;
  border-bottom: 1px solid #e7e5e4;
}

.mg-status-tabs {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.mg-tab {
  padding: 7px 20px;
  background: white;
  border: 1px solid #e7e5e4;
  border-radius: 24px;
  font-size: 13px;
  color: #57534e;
  cursor: pointer;
  transition: all 0.2s;
  outline: none;
}

.mg-tab:hover {
  border-color: #78716c;
  color: #1c1917;
}

.mg-tab--active {
  background: #1c1917;
  border-color: #1c1917;
  color: white;
}

.mg-total-label {
  font-size: 13px;
  color: #a8a29e;
  white-space: nowrap;
}

/* ===== 商品网格 ===== */
.mg-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  margin-bottom: 56px;
}

.mg-card {
  background: white;
  border-radius: 10px;
  overflow: hidden;
  border: 1px solid #e7e5e4;
  transition: transform 0.25s, box-shadow 0.25s;
}

.mg-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.09);
}

/* 图片 */
.mg-card-img {
  position: relative;
  width: 100%;
  aspect-ratio: 1 / 1;
  overflow: hidden;
  background: #f5f5f4;
  cursor: pointer;
}

.mg-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.4s;
}

.mg-card:hover .mg-img {
  transform: scale(1.05);
}

.mg-img-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.mg-placeholder-icon {
  width: 44px;
  height: 44px;
  color: #d6d3d1;
}

.mg-cate-badge {
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

.mg-sold-mask {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
}

.mg-sold-text {
  color: white;
  font-size: 18px;
  font-weight: 600;
  letter-spacing: 2px;
  border: 2px solid white;
  padding: 6px 18px;
  border-radius: 4px;
}

/* 信息区 */
.mg-card-info {
  padding: 14px 16px 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.mg-card-top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 8px;
}

.mg-name {
  font-size: 14px;
  font-weight: 500;
  color: #1c1917;
  margin: 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  flex: 1;
}

/* 状态标签 */
.mg-status-tag {
  font-size: 11px;
  font-weight: 500;
  padding: 2px 8px;
  border-radius: 20px;
  white-space: nowrap;
  flex-shrink: 0;
}

.st-pending {
  background: #fff7ed;
  color: #ea580c;
  border: 1px solid #fed7aa;
}

.st-sale {
  background: #f0fdf4;
  color: #16a34a;
  border: 1px solid #bbf7d0;
}

.st-off {
  background: #f5f5f4;
  color: #78716c;
  border: 1px solid #e7e5e4;
}

.st-sold {
  background: #f5f5f4;
  color: #a8a29e;
  border: 1px solid #e7e5e4;
}

.mg-card-meta {
  min-height: 16px;
}

.mg-quality {
  font-size: 12px;
  color: #a8a29e;
  background: #f5f5f4;
  padding: 2px 8px;
  border-radius: 10px;
}

.mg-card-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 2px;
}

.mg-price {
  font-size: 18px;
  font-weight: 600;
  color: #e44d26;
  letter-spacing: -0.3px;
}

.mg-actions {
  display: flex;
  gap: 6px;
}

.mg-act-btn {
  display: flex;
  align-items: center;
  gap: 3px;
  padding: 4px 10px;
  border-radius: 5px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  border: 1px solid #e7e5e4;
  background: white;
  color: #57534e;
  transition: all 0.2s;
  outline: none;
}

.mg-act-icon {
  width: 12px;
  height: 12px;
}

.mg-act-btn--edit:hover {
  background: #1c1917;
  color: white;
  border-color: #1c1917;
}

.mg-act-btn--del:hover {
  background: #fee2e2;
  color: #dc2626;
  border-color: #fca5a5;
}

/* ===== 空状态 ===== */
.mg-empty {
  text-align: center;
  padding: 80px 0;
}

.mg-empty-icon {
  width: 64px;
  height: 64px;
  color: #d6d3d1;
  margin-bottom: 14px;
}

.mg-empty-text {
  font-size: 15px;
  color: #a8a29e;
  margin: 0;
}

/* ===== 分页 ===== */
.mg-pagination {
  display: flex;
  justify-content: center;
  padding-top: 16px;
}

.mg-pagination :deep(.el-pager li) {
  background: white;
  border: 1px solid #e7e5e4;
  border-radius: 4px;
  color: #57534e;
}

.mg-pagination :deep(.el-pager li:hover) {
  border-color: #78716c;
  color: #1c1917;
}

.mg-pagination :deep(.el-pager li.is-active) {
  background: #1c1917;
  border-color: #1c1917;
  color: white;
}

.mg-pagination :deep(.btn-prev),
.mg-pagination :deep(.btn-next) {
  background: white;
  border: 1px solid #e7e5e4;
  border-radius: 4px;
  color: #57534e;
}

/* ===== 弹窗 ===== */
.dlg-upload-row {
  display: flex;
  align-items: center;
  gap: 14px;
}

.dlg-imglist {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px;
}

.dlg-imglist-item {
  position: relative;
}

.dlg-imglist-del {
  position: absolute;
  top: -6px;
  right: -6px;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: #1c1917;
  color: white;
  border: none;
  font-size: 12px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
