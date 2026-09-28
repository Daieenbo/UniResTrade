<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { projectName } from '../../config/config.default'
import { User, Lock, SwitchButton } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

// 路由实例
const router = useRouter()
const route = useRoute()

// 用户信息
const account = ref(
    localStorage.getItem('account') ? JSON.parse(localStorage.getItem('account')) : {}
)

// 当前激活的菜单项
const activeMenu = computed(() => route.path)

// 退出登录
const logout = () => {
  localStorage.removeItem('account')
  ElMessage.success('退出成功')
  router.push('/login')
}

const handleUpdateAccount = (updatedAccount) => {
  // 更新父组件中的用户信息
  account.value = updatedAccount
}

</script>

<template>
  <div class="front-container">
    <!-- 顶部导航栏 -->
    <header class="header-nav">
      <div class="header-inner">
        <div class="logo-warp">
          <div class="logo">
            <img src="../../config/logo.svg" alt="Logo" />
          </div>
          <div class="brand-info">
          <div class="logo-text">{{ projectName }}</div>
          <span class="brand-slogan">好物循环，实惠共享</span>
          </div>
        </div>

        <div class="header-navs">
          <el-menu
              router
              :default-active="activeMenu"
              mode="horizontal"
              :ellipsis="false"
          >
            <el-menu-item index="/front/home">前台首页</el-menu-item>
            <el-menu-item index="/front/goods">闲置资源</el-menu-item>
            <el-menu-item index="/front/release">发布闲置</el-menu-item>
            <el-menu-item index="/front/myGoods">我的物品</el-menu-item>
            <el-menu-item index="/front/orders">我的订单</el-menu-item>
            <el-menu-item index="/front/collect">收藏物品</el-menu-item>
            <el-menu-item index="/front/chat">沟通列表</el-menu-item>

          </el-menu>
        </div>

        <div class="user-warp">
          <template v-if="!account.id">
            <el-button size="small" @click="router.push('/login')">登录</el-button>
            <el-button size="small" type="primary" @click="router.push('/register')">注册</el-button>
          </template>

          <el-dropdown v-else class="custom-dropdown">
            <div class="user-avatar">
              <img :src="account.avatarUrl" />
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item disabled>{{ account.nickname }}</el-dropdown-item>
                <el-dropdown-item>
                  <router-link to="/front/person" class="dropdown-link">
                    <el-icon><User /></el-icon>
                    <span>个人信息</span>
                  </router-link>
                </el-dropdown-item>
                <el-dropdown-item>
                  <router-link to="/front/password" class="dropdown-link">
                    <el-icon><Lock /></el-icon>
                    <span>修改密码</span>
                  </router-link>
                </el-dropdown-item>
                <el-dropdown-item divided>
                  <div @click="logout" class="dropdown-link">
                    <el-icon><SwitchButton /></el-icon>
                    <span>退出登录</span>
                  </div>
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </header>

    <!-- 主内容区域 -->
    <div class="main-content">
      <router-view @update-account="handleUpdateAccount"></router-view>
    </div>

    <!-- 页脚 -->
    <footer class="front-footer">
      <p>© {{ new Date().getFullYear() }} {{ projectName }}. 保留所有权利</p>
    </footer>
  </div>
</template>

<style lang="scss" scoped>

/*定义前台头部 背景 主题色*/
$front-back-color: #fff;

/*定义前台头部 字体 主题色*/
$front-font-color: #287c21;
$text-muted: #999;
.front-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.header-nav {
  z-index: 1800;
  position: sticky;
  top: 0;
  height: 56px;
  background-color: $front-back-color;
  box-shadow: 0 1px 6px 0 rgba(0, 0, 0, 0.08);
  overflow: visible;

  .header-inner {
    max-width: 1200px;
    margin: 0 auto;
    height: 100%;
    display: flex;
    align-items: center;
    padding: 0 24px;
    gap: 32px;
  }

  .logo-warp {
    display: flex;
    align-items: center;
    flex-shrink: 0;
    gap: 8px;

    .logo {
      width: 26px;
      height: 26px;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
    }

    .brand-info {
      display: flex;
      flex-direction: column;
      line-height: 1.2;
    }

    .logo-text {
      font-size: 16px;
      font-weight: 600;
      color: $front-font-color;
      white-space: nowrap;
    }


    .brand-slogan {
      font-size: 11px;
      color: $text-muted;
      letter-spacing: 0.5px;
      margin-top: 5px;
    }
  }

  .header-navs {
    flex: 1;
    height: 100%;

    .el-menu {
      background-color: $front-back-color !important;
      border: none !important;
      height: 56px !important;
    }

    .el-menu-item {
      height: 56px !important;
      line-height: 56px !important;
      font-size: 14px !important;
      padding: 0 14px !important;
      border-bottom: 2px solid transparent !important;

      &:hover {
        color: $front-font-color !important;
        background-color: transparent !important;
      }

      &.is-active {
        color: $front-font-color !important;
        background-color: transparent !important;
        border-bottom: 2px solid $front-font-color !important;
      }
    }
  }

  .user-warp {
    display: flex;
    align-items: center;
    flex-shrink: 0;
    gap: 8px;

    .user-avatar {
      width: 34px;
      height: 34px;
      border-radius: 50%;
      overflow: hidden;
      border: 2px solid rgba(64, 132, 217, 0.3);
      cursor: pointer;
      outline: none !important;
      transition: border-color 0.2s;

      &:hover {
        border-color: $front-font-color;
      }

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 50%;
      }
    }

    .dropdown-link {
      display: flex;
      align-items: center;
      color: inherit;
      text-decoration: none;

      .el-icon {
        margin-right: 6px;
      }
    }
  }
}

.main-content {
  flex: 1;
  background-color: #fff;
}

.front-footer {
  padding: 16px 24px;
  text-align: center;
  background-color: #fff;
  color: #666;
  font-size: 12px;
  border-top: 1px solid #eee;
}

</style>
