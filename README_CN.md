# Solian (Solar Network)

<p align="center">
  <img src="assets/icons/icon.png" width="120" alt="Solian Logo">
</p>

<p align="center">
  <b>一个宁静的社交网络</b>
</p>

<p align="center">
  <a href="LICENSE.txt"><img src="https://img.shields.io/github/license/Solsynth/HyperNet.Surface" alt="License"></a>
  <a href="https://crowdin.com/project/solian"><img src="https://badges.crowdin.net/solian/localized.svg" alt="Localization Status"></a>
  <a href="https://github.com/Solsynth/HyperNet.Surface/releases"><img src="https://img.shields.io/github/v/release/Solsynth/HyperNet.Surface?include_prereleases" alt="Latest Release"></a>
</p>

---

Solian（又名 Solar Network）是一个社交平台，旨在帮助你自由表达自我并与他人建立联系。我们并不打算取代任何主流平台——只是为你提供另一个宁静和谐的社区选择。

注意：联邦宇宙（Fediverse）支持目前处于实验阶段，功能有限。

提示：中文版本的 README 信息可能更新不及时，请以英文版本的为准。

> **帮助我们翻译！** 点击上方的 Crowdin 徽章参与翻译贡献。
>
> 中文文档：[Suki - Solar Network](https://kb.solsynth.dev/zh/solar-network) | [English README](./README.md)

---

## 目录

- [功能特性](#功能特性)
- [开始使用](#开始使用)
  - [普通用户](#普通用户)
  - [开发者](#开发者)
- [软件包](#软件包)
- [服务端](#服务端)
- [技术栈](#技术栈)
- [参与贡献](#参与贡献)

---

## 功能特性

### 已上线功能

| 功能 | 状态 | 描述 |
|---------|--------|-------------|
| 时间线 | 已完成 | 按时间顺序展示动态 |
| 帖子、文章与瞬间 | 已完成 | 多种内容类型满足不同需求 |
| 即时通讯 | 已完成 | 实时聊天，支持群组 |
| 领域 | 已完成 | 按共同兴趣组织的社区 |
| OAuth 集成 | 已完成 | 安全的第三方认证 |
| 签到 | 已完成 | 位置和状态分享 |
| 倒计时 | 已完成 | 追踪特殊日期和节日 |
| RSS 阅读器 | 已完成 | 订阅外部资讯源 |
| 钱包 | 已完成 | 积分交易系统 |
| 贴纸 | 已完成 | 用自定义贴纸表达自我 |
| 富文本编辑器 | 已完成 | 基于 Markdown，支持扩展语法 |
| 社交功能 | 已完成 | 好友列表和黑名单管理 |
| 文件管理 | 已完成 | 上传和管理文件 |
| AI 功能 | 已完成 | 智能助手功能 |

### 即将推出

- **健身与健康** - 追踪健康和运动目标
- **SolarWatt Ideask** - 待办事项和任务管理应用

---

## 开始使用

### 普通用户

1. **下载应用**
   - 访问 [GitHub Releases](https://github.com/Solsynth/HyperNet.Surface/releases) 下载适合你平台的最新版本
   - **稳定版与预发布版的区别：** 预发布版包含最新功能但可能未经充分测试。由于我们不做 API 版本控制，破坏性更新可能会影响稳定版，因此建议使用预发布版以获得最佳体验。

2. **创建账号**
   - 在 Solar Network 上注册账号
   - 验证你的邮箱地址
   - 开始探索吧！

### 开发者

#### 前置要求

- 安装 [Flutter SDK](https://flutter.dev)
- Linux 开发需要安装额外依赖：

```bash
sudo apt-get update -y
sudo apt-get install -y \
  ninja-build \
  libgtk-3-dev \
  libmpv-dev \
  mpv \
  libayatana-appindicator3-dev \
  keybinder-3.0 \
  libnotify-dev \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  gstreamer-1.0
```

#### 运行应用

```bash
# 安装依赖
flutter pub get

# 以调试模式运行
flutter run

# 构建发布版本
flutter build <platform>
```

更多构建选项请查看 [Flutter 官方文档](https://docs.flutter.dev)。

---

## 软件包

本仓库采用单体仓库（monorepo）结构，在 `packages/` 目录下包含多个实用的 Dart 软件包。

想要基于 Solar Network 进行开发？查看以下资源：

- [开发文档](https://kb.solsynth.dev)
- [API 文档](https://api.solsynth.dev)
- [`packages/solar_network_sdk`](./packages/solar_network_sdk) - 官方 Dart SDK

---

## 服务端

Solar Network 的后端服务位于：
**[Solsynth/DysonNetwork](https://github.com/Solsynth/DysonNetwork)**

---

## 技术栈

| 层级 | 技术 |
|-------|------------|
| **前端** | Flutter - 跨平台 UI 框架 |
| **后端** | .NET + PostgreSQL 数据库 |
| **协议** | ActivityPub (联邦宇宙)、WebSockets、REST API |

---

## 参与贡献

我们欢迎各种形式的贡献！参与前请阅读我们的[行为准则](./CODE_OF_CONDUCT.md)。

- [报告 Bug](https://github.com/Solsynth/HyperNet.Surface/issues)
- [建议新功能](https://github.com/Solsynth/HyperNet.Surface/discussions)
- [参与应用翻译](https://crowdin.com/project/solian)

---

<p align="center">
  Made with love by the Solar Network Team
</p>
