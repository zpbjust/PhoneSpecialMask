# Special Phone Mask - 设置指南

## 📱 项目配置

### 1. 将图片添加到 Xcode 项目

**重要：** 为了让 App 能够正确显示壁纸和贴纸，你需要将 `mask` 文件夹中的图片添加到 Xcode 项目中。

#### 方法一：拖拽到 Assets（推荐）

1. 打开 Xcode 项目
2. 在左侧项目导航中，选择 `Assets.xcassets`
3. 将以下图片拖入 Assets：
   - `mask/pager/` 下的所有图片 (pager_01.png ~ pager_16.png)
   - `mask/stick/` 下所有主题的主图和贴纸

#### 方法二：添加文件到项目

1. 打开 Xcode 项目
2. 右键点击项目根目录
3. 选择 "Add Files to specialphonemask..."
4. 选择 `mask` 文件夹
5. ✅ 勾选 "Copy items if needed"
6. ✅ 勾选 "Create folder references"（而不是 "Create groups"）
7. 点击 "Add"

### 2. 验证图片是否添加成功

1. 在 Xcode 中构建项目 (⌘ + B)
2. 运行项目 (⌘ + R)
3. 如果看到壁纸和贴纸正常显示，说明配置成功！

### 3. 如果图片不显示

检查以下事项：
- 图片是否在项目的 Target Membership 中
- Build Phases → Copy Bundle Resources 中是否包含图片
- 图片文件名是否正确（注意大小写）

## 🎨 项目结构

```
specialphonemask/
├── Models.swift              # 数据模型
├── HomeView.swift            # 主页视图
├── ImageLoader.swift         # 图片加载辅助
├── ContentView.swift         # 入口视图
└── mask/                     # 图片资源
    ├── pager/                # 快速壁纸 (16张)
    └── stick/                # 贴纸主题 (9套)
        ├── bear/
        ├── cat/
        ├── cloud/
        ├── energy/
        ├── kite/
        ├── mask/
        ├── penguin/
        ├── pixel/
        └── totoro/
```

## ✨ 功能说明

### 首页设计
- **沉浸式全屏翻页**：类似 Instagram Stories 的流畅体验
- **三个标签页**：
  - 快速壁纸：16 张精选遮挡壁纸
  - 贴纸主题：9 套创意贴纸
  - 我的作品：保存的创作

### 交互手势
- 左右滑动：切换壁纸/贴纸
- 双击：快速保存（带震动反馈）
- 长按：进入编辑模式（待实现）
- 点击标签：切换分类

### 视觉特效
- 毛玻璃效果顶部导航
- 渐变色按钮
- 流畅的动画过渡
- 震动触觉反馈

## 🚀 下一步开发

- [ ] 实现保存到相册功能
- [ ] 创建贴纸编辑器
- [ ] 添加我的作品管理
- [ ] 优化图片加载性能
- [ ] 添加使用教程页面

## 📝 注意事项

1. 确保所有图片都是 PNG 格式
2. 图片文件名不要包含空格和特殊字符
3. 建议图片尺寸为 1170x2532px (iPhone 屏幕比例)
4. 开发测试建议使用真机，模拟器可能显示效果不佳

