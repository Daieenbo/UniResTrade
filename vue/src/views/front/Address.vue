<script setup>
import { ref, onMounted } from 'vue'
import request from '@/utils/request.js'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Location, EditPen, Delete } from '@element-plus/icons-vue'

const tableData = ref([])
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(-1)

const load = () => {
  request.get("/address/page", {
    params: {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: '',
    }
  }).then(res => {
    if (res.data) {
      tableData.value = res.data.records
      total.value = res.data.total
    }
  })
}

const form = ref({})
const dialogFormVisible = ref(false)

const handleAdd = () => {
  form.value = {}
  dialogFormVisible.value = true
}

const handleEdit = (row) => {
  form.value = JSON.parse(JSON.stringify(row))
  dialogFormVisible.value = true
}

const del = (id) => {
  request.delete("/address/" + id).then(res => {
    if (res.code === '200') {
      ElMessage.success("删除成功")
      load()
    } else {
      ElMessage.error("删除失败")
    }
  })
}

const save = () => {
  request.post("/address", form.value).then(res => {
    if (res.code === '200') {
      ElMessage.success("保存成功")
      dialogFormVisible.value = false
      load()
    } else {
      ElMessage.error("保存失败")
    }
  })
}

const confirmDelete = (id) => {
  ElMessageBox.confirm(
      '确定要删除这条地址吗？',
      '删除确认',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning',
      }
  ).then(() => {
    del(id)
  })
}

onMounted(() => {
  load()
})
</script>

<template>
  <div class="addr-page">
    <div class="addr-topbar">
      <div class="addr-topbar-left">
        <span class="addr-topbar-dot"></span>
        <h1 class="addr-topbar-title">收货地址</h1>
        <span class="addr-topbar-count" v-if="tableData.length > 0">共 {{ tableData.length }} 条</span>
      </div>
      <button class="addr-add-btn" @click="handleAdd">
        <el-icon><Plus /></el-icon>
        新增地址
      </button>
    </div>

    <div class="addr-grid">
      <div
          v-for="address in tableData"
          :key="address.id"
          class="addr-item"
      >
        <div class="addr-item-head">
          <div class="addr-avatar">{{ address.name?.charAt(0) }}</div>
          <div class="addr-contact">
            <span class="addr-name">{{ address.name }}</span>
            <span class="addr-phone">{{ address.phone }}</span>
          </div>
          <div class="addr-ops">
            <button class="addr-op-btn addr-op-edit" @click="handleEdit(address)">
              <el-icon><EditPen /></el-icon>
              编辑
            </button>
            <button class="addr-op-btn addr-op-del" @click="confirmDelete(address.id)">
              <el-icon><Delete /></el-icon>
              删除
            </button>
          </div>
        </div>
        <div class="addr-item-body">
          <el-icon class="addr-loc-icon"><Location /></el-icon>
          <span class="addr-loc-text">{{ address.info }}</span>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-if="tableData.length === 0" class="addr-empty">
        <div class="addr-empty-icon">
          <el-icon><Location /></el-icon>
        </div>
        <p class="addr-empty-tip">暂无收货地址</p>
        <button class="addr-add-btn" @click="handleAdd">
          <el-icon><Plus /></el-icon>
          添加第一条地址
        </button>
      </div>
    </div>

    <!-- 新增 / 编辑对话框 -->
    <el-dialog
        v-model="dialogFormVisible"
        :title="form.id ? '编辑地址' : '新增地址'"
        width="460px"
    >
      <el-form :model="form" label-width="90px" class="addr-form">
        <el-form-item label="收货人名">
          <el-input v-model="form.name" placeholder="请输入收货人姓名" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="form.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="具体地址">
          <el-input v-model="form.info" type="textarea" :rows="3" placeholder="请输入详细地址" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="addr-dialog-foot">
          <el-button @click="dialogFormVisible = false">取消</el-button>
          <el-button type="primary" @click="save">保存</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
/* ===== 页面容器 ===== */
.addr-page {
  max-width: 860px;
  margin: 0 auto;
  padding: 36px 24px 80px;
  min-height: 100vh;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

/* ===== 顶栏 ===== */
.addr-topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 28px;
}

.addr-topbar-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.addr-topbar-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #3d9970;
  flex-shrink: 0;
}

.addr-topbar-title {
  font-size: 20px;
  font-weight: 600;
  color: #1a3a2a;
  margin: 0;
}

.addr-topbar-count {
  font-size: 13px;
  color: #9ab5a8;
  background: #eaf7f1;
  padding: 2px 10px;
  border-radius: 20px;
}

/* ===== 新增按钮 ===== */
.addr-add-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: #3d9970;
  color: white;
  border: none;
  padding: 9px 20px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s ease;
}

.addr-add-btn:hover {
  background: #2e7d5a;
}

/* ===== 地址列表 ===== */
.addr-grid {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

/* ===== 单条地址卡片 ===== */
.addr-item {
  background: white;
  border: 1px solid #e2efe9;
  border-radius: 12px;
  padding: 20px 24px;
  transition: box-shadow 0.25s ease, border-color 0.25s ease;
}

.addr-item:hover {
  border-color: #a8d5bf;
  box-shadow: 0 4px 16px rgba(61, 153, 112, 0.08);
}

/* 卡片头部 */
.addr-item-head {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 14px;
}

.addr-avatar {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  background: #eaf7f1;
  color: #3d9970;
  font-size: 15px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.addr-contact {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
}

.addr-name {
  font-size: 15px;
  font-weight: 600;
  color: #1a3a2a;
}

.addr-phone {
  font-size: 13px;
  color: #6b9080;
}

/* 操作按钮 */
.addr-ops {
  display: flex;
  gap: 6px;
}

.addr-op-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  padding: 5px 12px;
  border-radius: 6px;
  border: 1px solid transparent;
  cursor: pointer;
  transition: all 0.2s ease;
  background: none;
}

.addr-op-edit {
  color: #3d9970;
  border-color: #c8e3d6;
}

.addr-op-edit:hover {
  background: #eaf7f1;
  border-color: #3d9970;
}

.addr-op-del {
  color: #e53e3e;
  border-color: #fcd5d5;
}

.addr-op-del:hover {
  background: #fff5f5;
  border-color: #e53e3e;
}

/* 地址信息行 */
.addr-item-body {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 12px 14px;
  background: #f7faf8;
  border-radius: 8px;
}

.addr-loc-icon {
  color: #3d9970;
  font-size: 16px;
  margin-top: 1px;
  flex-shrink: 0;
}

.addr-loc-text {
  font-size: 14px;
  line-height: 1.6;
  color: #4a7a64;
}

/* ===== 空状态 ===== */
.addr-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 72px 0;
  background: white;
  border: 1px dashed #c8e3d6;
  border-radius: 12px;
  gap: 12px;
}

.addr-empty-icon {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: #eaf7f1;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: #3d9970;
}

.addr-empty-tip {
  font-size: 15px;
  color: #9ab5a8;
  margin: 0;
}

/* ===== 表单 ===== */
.addr-form {
  padding: 8px 0;
}

/* ===== 对话框底部 ===== */
.addr-dialog-foot {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

:deep(.el-dialog) {
  border-radius: 12px;
}

:deep(.el-dialog__header) {
  padding: 20px 24px 16px;
  border-bottom: 1px solid #eaf7f1;
}

:deep(.el-dialog__title) {
  font-size: 16px;
  font-weight: 600;
  color: #1a3a2a;
}

:deep(.el-button--primary) {
  background: #3d9970;
  border-color: #3d9970;
}

:deep(.el-button--primary:hover) {
  background: #2e7d5a;
  border-color: #2e7d5a;
}
</style>
