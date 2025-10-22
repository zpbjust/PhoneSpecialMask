# 🎨 Special Phone Mask

<div align="center">

**一款精美的 iOS 壁纸工具，帮助你优雅遮挡锁屏底部的管理文字**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://www.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## ✨ 功能特性

### 🎯 核心功能

- **快速壁纸** - 16 张精选遮挡壁纸，直接保存使用
- **贴纸定制** - 9 套创意贴纸主题，自由搭配你的照片
- **我的作品** - 保存和管理你的创作

### 🎨 设计亮点

- ✅ **沉浸式全屏体验** - 类似 Instagram Stories 的流畅交互
- ✅ **精美视觉效果** - 毛玻璃、渐变、动画一应俱全
- ✅ **触觉反馈** - 操作反馈丰富，体验极致
- ✅ **暗黑模式** - 完美适配暗黑模式

### 📱 交互手势

| 手势 | 功能 |
|------|------|
| 左右滑动 | 切换壁纸/贴纸 |
| 双击屏幕 | 快速保存（震动反馈）|
| 长按 | 进入编辑模式 |
| 点击标签 | 切换分类 |
| 上滑 | 查看详情 |

---

## 📸 预览

### 欢迎页面
- 精美的渐变背景
- 流畅的入场动画
- 清晰的功能介绍

### 快速壁纸
- 全屏展示壁纸效果
- 模拟真实锁屏界面
- 一键保存到相册

### 贴纸主题
- 9 套主题，22 个贴纸
- 每套主题独特配色
- 支持自定义底图

---

## 🚀 快速开始

### 系统要求

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/yourusername/specialphonemask.git
cd specialphonemask
```

2. **打开项目**
```bash
open specialphonemask.xcodeproj
```

3. **添加图片资源** ⚠️ **重要**

图片资源需要添加到 Xcode 项目中才能正常显示：

**方法一：拖拽到 Assets（推荐）**
- 打开 `Assets.xcassets`
- 将 `mask/pager/` 和 `mask/stick/` 中的所有图片拖入

**方法二：添加文件到项目**
- 右键项目 → Add Files to "specialphonemask"
- 选择 `mask` 文件夹
- ✅ 勾选 "Copy items if needed"
- ✅ 选择 "Create folder references"

4. **运行项目**
- 选择目标设备（建议使用真机）
- 按 ⌘ + R 运行

---

## 📁 项目结构

```
specialphonemask/
├── Models.swift              # 数据模型
│   ├── Wallpaper            # 壁纸模型
│   ├── StickerTheme         # 贴纸主题模型
│   └── HomeTab              # 标签枚举
│
├── HomeView.swift            # 主页视图
│   ├── TopNavigationBar     # 顶部导航栏
│   ├── WallpaperGalleryView # 壁纸画廊
│   ├── StickerGalleryView   # 贴纸画廊
│   └── MyWorksView          # 我的作品
│
├── WelcomeView.swift         # 欢迎页面
├── ImageLoader.swift         # 图片加载辅助
├── ContentView.swift         # 入口视图
│
└── mask/                     # 图片资源
    ├── pager/                # 16 张快速壁纸
    │   ├── pager_01.png
    │   ├── pager_02.png
    │   └── ...
    │
    └── stick/                # 9 套贴纸主题
        ├── bear/             # 熊 (3个贴纸)
        ├── cat/              # 猫 (3个贴纸)
        ├── cloud/            # 云朵 (3个贴纸)
        ├── energy/           # 能量 (3个贴纸)
        ├── kite/             # 风筝 (3个贴纸)
        ├── mask/             # 面具 (3个贴纸)
        ├── penguin/          # 企鹅 (3个贴纸)
        ├── pixel/            # 像素 (2个贴纸)
        └── totoro/           # 龙猫 (1个贴纸)
```

---

## 🎨 贴纸主题详情

| 主题 | Emoji | 风格 | 适合场景 | 贴纸数 |
|------|-------|------|---------|--------|
| 熊 | 🐻 | 可爱温馨 | 温馨照片、儿童风格 | 3 |
| 猫 | 🐱 | 俏皮灵动 | 猫奴、宠物照片 | 3 |
| 云朵 | ☁️ | 清新自然 | 天空、风景照 | 3 |
| 能量 | ⚡ | 科技动感 | 运动、科技主题 | 3 |
| 风筝 | 🪁 | 文艺清新 | 春天、户外照片 | 3 |
| 面具 | 🎭 | 神秘艺术 | 艺术照、个性风格 | 3 |
| 企鹅 | 🐧 | 呆萌可爱 | 冬季、冰雪场景 | 3 |
| 像素 | 🎨 | 复古游戏 | 怀旧、极简风格 | 2 |
| 龙猫 | 🌿 | 治愈温暖 | 动漫风、绿色主题 | 1 |

---

## 🛠️ 技术栈

- **语言**: Swift 5.9
- **框架**: SwiftUI
- **最低版本**: iOS 17.0
- **架构**: MVVM
- **状态管理**: @State, @Binding, @AppStorage
- **动画**: SwiftUI Animations, Spring, Transitions
- **图片处理**: UIKit, Core Graphics

---

## 📋 开发计划

### ✅ 已完成

- [x] 精美的欢迎页面
- [x] 沉浸式全屏首页
- [x] 顶部导航栏切换
- [x] 快速壁纸展示
- [x] 贴纸主题展示
- [x] 保存按钮（UI）
- [x] 触觉反馈
- [x] 流畅动画

### 🚧 进行中

- [ ] 保存到相册功能
- [ ] 贴纸编辑器
- [ ] 我的作品管理

### 📝 计划中

- [ ] 使用教程页面
- [ ] 自定义底图（相册/拍照）
- [ ] 贴纸拖动、缩放、旋转
- [ ] 图层管理
- [ ] 分享功能
- [ ] 更多贴纸主题
- [ ] 暗黑模式优化
- [ ] 性能优化

---

## 🐛 已知问题

1. **图片资源加载** - 需要手动添加图片到 Xcode 项目
2. **保存功能** - 尚未实现真实保存到相册
3. **编辑功能** - 贴纸编辑器待开发

---

## 💡 使用提示

### 如何设置为锁屏壁纸？

1. 在 App 中保存喜欢的壁纸
2. 打开 iPhone 设置 → 壁纸
3. 选择刚才保存的图片
4. 设置为"锁定屏幕"
5. 享受简洁的锁屏效果！

### 如何自定义贴纸壁纸？

1. 选择"贴纸主题"标签
2. 浏览并选择喜欢的贴纸主题
3. 点击"开始创作"
4. 选择推荐图片或自定义底图
5. 拖动贴纸到底部遮挡位置
6. 保存并设置为壁纸

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 👨‍💻 作者

**Nash Zhou**

- GitHub: [@nashzhou](https://github.com/nashzhou)

---

## 🙏 致谢

- 感谢所有贡献者
- 设计灵感来自现代 iOS 应用
- 特别感谢 SwiftUI 社区

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐️ Star 吧！**

Made with ❤️ by Nash Zhou

</div>

