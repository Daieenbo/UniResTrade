<script setup>
import {ref, reactive} from 'vue'
import {useRouter} from 'vue-router'
import {projectName} from '../../config/config.default'
import {User, Lock} from '@element-plus/icons-vue'
import {ElMessage} from 'element-plus'
import request from '@/utils/request.js'

const router = useRouter()
const userFormInst = ref(null)

const roleOptions = [
  // 系统角色
  {label: '普通用户', value: 'ROLE_USER'},
  // {label: '管理员', value: 'ROLE_ADMIN'},
  // 系统角色
]

const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  role: 'ROLE_USER'
})

const isAllow = ref(true)

const rules = {
  username: [
    {required: true, message: '请输入用户名', trigger: 'blur'},
    {min: 3, max: 10, message: '长度在 3 到 10 个字符', trigger: 'blur'}
  ],
  password: [
    {required: true, message: '请输入密码', trigger: 'blur'},
    {min: 3, max: 10, message: '长度在 3 到 10 个字符', trigger: 'blur'}
  ],
  confirmPassword: [
    {required: true, message: '请确认密码', trigger: 'blur'},
    {min: 3, max: 10, message: '长度在 3 到 10 个字符', trigger: 'blur'}
  ],
  role: [
    {required: true, message: '请选择角色', trigger: 'change'}
  ]
}

const register = () => {
  userFormInst.value.validate((valid) => {
    if (valid) {
      if (registerForm.password !== registerForm.confirmPassword) {
        ElMessage.error('两次输入的新密码不相同')
        return false
      }
      const registerData = {
        username: registerForm.username,
        password: registerForm.password,
        role: registerForm.role
      }
      request.post('/web/register', registerData).then((res) => {
        if (res.code === '200') {
          ElMessage.success('注册成功，请登录')
          router.push('/login')
        } else {
          ElMessage.error(res.msg || '注册失败')
        }
      }).catch(error => {
        console.error('注册请求错误:', error)
        ElMessage.error('注册失败，请稍后重试')
      })
    }
  })
}
</script>

<template>
  <div class="reg-bg">
    <!-- 背景装饰气泡 -->
    <div class="reg-bubble reg-bubble--1"></div>
    <div class="reg-bubble reg-bubble--2"></div>
    <div class="reg-bubble reg-bubble--3"></div>
    <div class="reg-bubble reg-bubble--4"></div>
    <div class="reg-bubble reg-bubble--5"></div>

    <div class="reg-card">
      <!-- 顶部品牌 -->
      <div class="reg-card-top">
        <div class="reg-brand">
          <img src="../../config/logo.svg" alt="logo" class="reg-logo"/>
          <span class="reg-brand-name">{{ projectName }}</span>
        </div>
        <div class="reg-divider"></div>
        <h2 class="reg-title">创建账号</h2>
        <p class="reg-sub">加入我们，开启你的校园二手交易之旅</p>
      </div>

      <el-form
          :model="registerForm"
          :rules="rules"
          ref="userFormInst"
          @keydown.enter="register"
          class="reg-form"
      >
        <div class="reg-row">
          <el-form-item prop="username" class="reg-row-item">
            <div class="reg-field-label">用户名</div>
            <el-input
                v-model="registerForm.username"
                placeholder="3-10 字符"
                size="large"
                :prefix-icon="User"
            />
          </el-form-item>
          <el-form-item prop="role" class="reg-row-item">
            <div class="reg-field-label">注册身份</div>
            <el-select
                v-model="registerForm.role"
                placeholder="请选择"
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
        </div>

        <el-form-item prop="password">
          <div class="reg-field-label">密码</div>
          <el-input
              v-model="registerForm.password"
              placeholder="请输入密码（3-10 字符）"
              size="large"
              :prefix-icon="Lock"
              show-password
          />
        </el-form-item>

        <el-form-item prop="confirmPassword">
          <div class="reg-field-label">确认密码</div>
          <el-input
              v-model="registerForm.confirmPassword"
              placeholder="请再次输入密码"
              size="large"
              :prefix-icon="Lock"
              show-password
          />
        </el-form-item>

        <el-form-item>
          <el-checkbox v-model="isAllow" class="reg-agree">
            我已阅读并同意
            <a href="#" class="reg-link">《隐私政策》</a>和
            <a href="#" class="reg-link">《服务条款》</a>
          </el-checkbox>
        </el-form-item>

        <el-form-item>
          <button
              class="reg-submit-btn"
              :class="{ 'reg-submit-btn--disabled': !isAllow }"
              :disabled="!isAllow"
              @click.prevent="register"
          >
            注 册
          </button>
        </el-form-item>
      </el-form>

      <div class="reg-switch">
        已有账号？
        <span class="reg-link reg-link--action" @click="router.push('/login')">立即登录</span>
      </div>

      <div class="reg-steps">
        <div class="reg-step">
          <span class="reg-step-dot"></span>
          <span class="reg-step-text">注册账号，完善个人信息</span>
        </div>
        <div class="reg-step">
          <span class="reg-step-dot"></span>
          <span class="reg-step-text">发布闲置，快速上架好物</span>
        </div>
        <div class="reg-step">
          <span class="reg-step-dot"></span>
          <span class="reg-step-text">线上沟通，校园当面交易</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ===== 背景 ===== */
.reg-bg {
  position: relative;
  width: 100%;
  height: 100vh;
  background: #eef2ee;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

/* 装饰气泡 — 注册页用椭圆方向区别于登录页 */
.reg-bubble {
  position: absolute;
  border-radius: 50%;
  background: transparent;
}

.reg-bubble--1 {
  width: 480px;
  height: 480px;
  border: 1px solid rgba(61, 107, 82, 0.1);
  bottom: -160px;
  left: -160px;
}

.reg-bubble--2 {
  width: 240px;
  height: 240px;
  border: 1px solid rgba(61, 107, 82, 0.09);
  bottom: 60px;
  left: 60px;
}

.reg-bubble--3 {
  width: 560px;
  height: 560px;
  border: 1px solid rgba(61, 107, 82, 0.06);
  top: -200px;
  right: -180px;
}

.reg-bubble--4 {
  width: 180px;
  height: 180px;
  border: 1px solid rgba(61, 107, 82, 0.1);
  top: 60px;
  right: 120px;
}

.reg-bubble--5 {
  width: 80px;
  height: 80px;
  background: rgba(61, 107, 82, 0.05);
  bottom: 30%;
  right: 14%;
  border-radius: 50%;
}

/* ===== 卡片 ===== */
.reg-card {
  position: relative;
  z-index: 1;
  background: white;
  border-radius: 20px;
  padding: 44px 52px;
  width: 100%;
  max-width: 600px;
  box-shadow: 0 4px 40px rgba(0, 0, 0, 0.07);
}

/* ===== 顶部品牌 ===== */
.reg-card-top {
  margin-bottom: 28px;
}

.reg-brand {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
}

.reg-logo {
  width: 32px;
  height: 32px;
  border-radius: 7px;
  object-fit: contain;
}

.reg-brand-name {
  font-size: 15px;
  font-weight: 600;
  color: #3d6b52;
  letter-spacing: 0.3px;
}

.reg-divider {
  width: 32px;
  height: 3px;
  background: #3d6b52;
  border-radius: 2px;
  margin-bottom: 16px;
}

.reg-title {
  font-size: 26px;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0 0 6px;
  letter-spacing: -0.3px;
}

.reg-sub {
  font-size: 13px;
  color: #999;
  margin: 0;
}

/* 用户名+身份并排 */
.reg-row {
  display: flex;
  gap: 16px;
}

.reg-row-item {
  flex: 1;
  min-width: 0;
}

/* ===== 表单 ===== */
.reg-form {
  margin-bottom: 4px;
}

.reg-field-label {
  font-size: 13px;
  font-weight: 500;
  color: #555;
  margin-bottom: 6px;
}

:deep(.el-input__wrapper) {
  border: 1px solid #e2e8e4;
  border-radius: 8px;
  box-shadow: none !important;
  padding: 4px 12px;
  background: #f7faf8;
  transition: border-color 0.2s, background 0.2s;
}

:deep(.el-input__wrapper:hover),
:deep(.el-input__wrapper.is-focus) {
  border-color: #3d6b52;
  background: white;
}

:deep(.el-select .el-input__wrapper) {
  border: 1px solid #e2e8e4;
  border-radius: 8px;
  box-shadow: none !important;
  background: #f7faf8;
}

:deep(.el-select .el-input__wrapper:hover),
:deep(.el-select .el-input.is-focus .el-input__wrapper) {
  border-color: #3d6b52;
  background: white;
}

:deep(.el-form-item) {
  margin-bottom: 16px;
}

:deep(.el-form-item__error) {
  font-size: 12px;
}

.reg-agree {
  font-size: 13px;
  color: #777;
}

/* 提交按钮 */
.reg-submit-btn {
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

.reg-submit-btn:hover {
  background: #2f5440;
  transform: translateY(-1px);
}

.reg-submit-btn:active {
  transform: translateY(0);
}

.reg-submit-btn--disabled {
  background: #c8c8c8;
  cursor: not-allowed;
  transform: none;
}

/* 切换登录 */
.reg-switch {
  text-align: center;
  margin-top: 18px;
  font-size: 13px;
  color: #999;
}

.reg-link {
  color: #3d6b52;
  text-decoration: none;
}

.reg-link:hover {
  text-decoration: underline;
}

.reg-link--action {
  cursor: pointer;
  font-weight: 600;
}

/* 底部步骤提示 */
.reg-steps {
  display: flex;
  justify-content: space-between;
  gap: 8px;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #edf0ec;
}

.reg-step {
  display: flex;
  align-items: flex-start;
  gap: 7px;
  flex: 1;
}

.reg-step-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #3d6b52;
  flex-shrink: 0;
  margin-top: 5px;
}

.reg-step-text {
  font-size: 11px;
  color: #aaa;
  line-height: 1.55;
}
</style>
