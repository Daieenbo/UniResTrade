<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { projectName } from '../../config/config.default'
import { User, Lock } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request.js'

const router = useRouter()
const userFormInst = ref(null)

const roleOptions = [
  // 系统角色
  { label: '普通用户', value: 'ROLE_USER' },
  { label: '管理员', value: 'ROLE_ADMIN' },
  // 系统角色
]

const account = reactive({
  username: '',
  password: '',
  role: 'ROLE_USER'
})

const isAllow = ref(true)

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 10, message: '长度在 3 到 10 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 1, max: 20, message: '长度在 1 到 20 个字符', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ]
}

const login = () => {
  userFormInst.value.validate((valid) => {
    if (valid) {
      request.post('/web/login', account).then((res) => {
        if (res.code === '200') {
          localStorage.setItem('account', JSON.stringify(res.data))
          if (res.data.role === 'ROLE_ADMIN') {
            router.push('/back/home')
          } else {
            router.push('/front/home')
          }
          ElMessage.success('登录成功')
        } else {
          ElMessage.error(res.msg || '出错啦')
        }
      })
    }
  })
}
</script>

<template>
  <div class="lgn-bg">
    <!-- 背景装饰气泡 -->
    <div class="lgn-bubble lgn-bubble--1"></div>
    <div class="lgn-bubble lgn-bubble--2"></div>
    <div class="lgn-bubble lgn-bubble--3"></div>
    <div class="lgn-bubble lgn-bubble--4"></div>
    <div class="lgn-bubble lgn-bubble--5"></div>

    <div class="lgn-card">
      <!-- 顶部品牌 -->
      <div class="lgn-card-top">
        <div class="lgn-brand">
          <img src="../../config/logo.svg" alt="logo" class="lgn-logo" />
          <span class="lgn-brand-name">{{ projectName }}</span>
        </div>
        <div class="lgn-divider"></div>
        <h2 class="lgn-title">欢迎回来</h2>
        <p class="lgn-sub">登录账号，继续你的校园交易之旅</p>
      </div>

      <el-form
          :model="account"
          :rules="rules"
          ref="userFormInst"
          @keydown.enter="login"
          class="lgn-form"
      >
        <el-form-item prop="username">
          <div class="lgn-field-label">用户名</div>
          <el-input
              v-model="account.username"
              placeholder="请输入用户名"
              size="large"
              :prefix-icon="User"
          />
        </el-form-item>

        <el-form-item prop="password">
          <div class="lgn-field-label">密码</div>
          <el-input
              v-model="account.password"
              placeholder="请输入密码"
              size="large"
              :prefix-icon="Lock"
              show-password
          />
        </el-form-item>

        <el-form-item prop="role">
          <div class="lgn-field-label">登录身份</div>
          <el-select
              v-model="account.role"
              placeholder="请选择角色"
              size="large"
              style="width: 100%"
          >
            <el-option
                v-for="item in roleOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-checkbox v-model="isAllow" class="lgn-agree">
            我已阅读并同意
            <a href="#" class="lgn-link">《隐私政策》</a>和
            <a href="#" class="lgn-link">《服务条款》</a>
          </el-checkbox>
        </el-form-item>

        <el-form-item>
          <button
              class="lgn-submit-btn"
              :class="{ 'lgn-submit-btn--disabled': !isAllow }"
              :disabled="!isAllow"
              @click.prevent="login"
          >
            登 录
          </button>
        </el-form-item>
      </el-form>

<!--      <div class="lgn-switch">-->
<!--        还没有账号？-->
<!--        <span class="lgn-link lgn-link&#45;&#45;action" @click="router.push('/register')">立即注册</span>-->
<!--      </div>-->

      <div class="lgn-tags">
        <span class="lgn-tag">学生自用</span>
        <span class="lgn-tag">实惠靠谱</span>
        <span class="lgn-tag">当面交易</span>
        <span class="lgn-tag">好物循环</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ===== 背景 ===== */
.lgn-bg {
  position: relative;
  width: 100%;
  height: 100vh;
  background: #f2efe9;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

/* 装饰气泡 */
.lgn-bubble {
  position: absolute;
  border-radius: 50%;
  background: transparent;
}

.lgn-bubble--1 {
  width: 420px;
  height: 420px;
  border: 1px solid rgba(61, 107, 82, 0.1);
  top: -100px;
  left: -120px;
}

.lgn-bubble--2 {
  width: 260px;
  height: 260px;
  border: 1px solid rgba(61, 107, 82, 0.08);
  top: 40px;
  left: 60px;
}

.lgn-bubble--3 {
  width: 500px;
  height: 500px;
  border: 1px solid rgba(61, 107, 82, 0.07);
  bottom: -180px;
  right: -140px;
}

.lgn-bubble--4 {
  width: 200px;
  height: 200px;
  border: 1px solid rgba(61, 107, 82, 0.1);
  bottom: 60px;
  right: 100px;
}

.lgn-bubble--5 {
  width: 100px;
  height: 100px;
  background: rgba(61, 107, 82, 0.04);
  top: 50%;
  left: 12%;
}

/* ===== 卡片 ===== */
.lgn-card {
  position: relative;
  z-index: 1;
  background: white;
  border-radius: 20px;
  padding: 48px 52px;
  width: 100%;
  max-width: 440px;
  box-shadow: 0 4px 40px rgba(0, 0, 0, 0.08);
}

/* ===== 顶部品牌 ===== */
.lgn-card-top {
  margin-bottom: 32px;
}

.lgn-brand {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
}

.lgn-logo {
  width: 32px;
  height: 32px;
  border-radius: 7px;
  object-fit: contain;
}

.lgn-brand-name {
  font-size: 15px;
  font-weight: 600;
  color: #3d6b52;
  letter-spacing: 0.3px;
}

.lgn-divider {
  width: 32px;
  height: 3px;
  background: #3d6b52;
  border-radius: 2px;
  margin-bottom: 16px;
}

.lgn-title {
  font-size: 26px;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0 0 6px;
  letter-spacing: -0.3px;
}

.lgn-sub {
  font-size: 13px;
  color: #999;
  margin: 0;
}

/* ===== 表单 ===== */
.lgn-form {
  margin-bottom: 4px;
}

.lgn-field-label {
  font-size: 13px;
  font-weight: 500;
  color: #555;
  margin-bottom: 6px;
}

:deep(.el-input__wrapper) {
  border: 1px solid #e8e4de;
  border-radius: 8px;
  box-shadow: none !important;
  padding: 4px 12px;
  background: #faf9f7;
  transition: border-color 0.2s, background 0.2s;
}

:deep(.el-input__wrapper:hover),
:deep(.el-input__wrapper.is-focus) {
  border-color: #3d6b52;
  background: white;
}

:deep(.el-select .el-input__wrapper) {
  border: 1px solid #e8e4de;
  border-radius: 8px;
  box-shadow: none !important;
  background: #faf9f7;
}

:deep(.el-select .el-input__wrapper:hover),
:deep(.el-select .el-input.is-focus .el-input__wrapper) {
  border-color: #3d6b52;
  background: white;
}

:deep(.el-form-item) {
  margin-bottom: 18px;
}

:deep(.el-form-item__error) {
  font-size: 12px;
}

.lgn-agree {
  font-size: 13px;
  color: #777;
}

/* 提交按钮 */
.lgn-submit-btn {
  width: 100%;
  height: 46px;
  background: #3d6b52;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  letter-spacing: 3px;
  transition: background 0.2s, transform 0.1s;
}

.lgn-submit-btn:hover {
  background: #2f5440;
  transform: translateY(-1px);
}

.lgn-submit-btn:active {
  transform: translateY(0);
}

.lgn-submit-btn--disabled {
  background: #c8c8c8;
  cursor: not-allowed;
  transform: none;
}

/* 切换注册 */
.lgn-switch {
  text-align: center;
  margin-top: 20px;
  font-size: 13px;
  color: #999;
}

.lgn-link {
  color: #3d6b52;
  text-decoration: none;
}

.lgn-link:hover {
  text-decoration: underline;
}

.lgn-link--action {
  cursor: pointer;
  font-weight: 600;
}

/* 底部标签 */
.lgn-tags {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #f0ede8;
}

.lgn-tag {
  font-size: 11px;
  color: #aaa;
  border: 1px solid #e8e4de;
  border-radius: 20px;
  padding: 3px 12px;
  background: #faf9f7;
  letter-spacing: 0.5px;
}
</style>
