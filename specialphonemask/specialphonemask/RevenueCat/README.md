# RevenueCat 通用内购系统

这是一个完整的、可复用的 RevenueCat 内购集成方案，可以直接复制到其他项目使用。

## 📦 文件结构

```
RevenueCat/
├── RCConfiguration.swift      # 配置文件（唯一需要修改的文件）
├── RCPurchaseManager.swift    # 核心购买管理类
├── RCPaywallView.swift        # 付费墙 UI
├── RCPremiumGate.swift        # Premium 功能门控组件
└── README.md                  # 使用文档
```

## 🚀 快速开始

### 1. 添加依赖

在 Xcode 中添加 RevenueCat SPM 依赖：

```
https://github.com/RevenueCat/purchases-ios-spm
```

选择以下包：
- `RevenueCat` ✅
- `RevenueCatUI` ✅（可选，但推荐）

### 2. 配置项目

打开 `RCConfiguration.swift`，修改以下配置：

```swift
// 1. 替换为你的 API Key
static let apiKey = "appl_YOUR_API_KEY_HERE"

// 2. 配置产品 ID
struct ProductIDs {
    static let monthly = "your_monthly_product_id"
    static let yearly = "your_yearly_product_id"
    static let lifetime = "your_lifetime_product_id"
}

// 3. 配置权益 ID
static let entitlementID = "premium"

// 4. 如果是付费 App 转免费，启用迁移
static let enableLegacyMigration = true
static let legacyAppCutoffDate = "2024-01-01"
```

### 3. 初始化

在 App 启动时初始化（通常在 `App.swift` 或 `AppDelegate.swift`）：

```swift
import SwiftUI

@main
struct YourApp: App {
    
    init() {
        // 初始化 RevenueCat
        RCPurchaseManager.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## 📖 使用方法

### 检查 Premium 状态

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var purchaseManager = RCPurchaseManager.shared
    
    var body: some View {
        VStack {
            if purchaseManager.hasPremium {
                Text("你是 Premium 用户！")
            } else {
                Text("升级到 Premium")
            }
        }
    }
}
```

### 显示付费墙

```swift
struct ContentView: View {
    @State private var showPaywall = false
    
    var body: some View {
        Button("升级到 Premium") {
            showPaywall = true
        }
        .fullScreenCover(isPresented: $showPaywall) {
            RCPaywallView()
        }
    }
}
```

### 使用 Premium 门控

#### 方法 1：使用 `RCPremiumGate` 包裹内容

```swift
RCPremiumGate {
    // 需要 Premium 的内容
    Text("Premium 功能")
        .frame(maxWidth: .infinity, height: 200)
        .background(Color.blue)
}
```

#### 方法 2：使用 View Extension

```swift
Text("Premium 功能")
    .premiumGated()
```

#### 方法 3：使用 Premium Button

```swift
RCPremiumButton(title: "导出高清图片", icon: "square.and.arrow.up") {
    // 只有 Premium 用户才会执行
    exportImage()
}
```

#### 方法 4：使用 Premium Feature Item

```swift
RCPremiumFeatureItem(
    icon: "photo.stack.fill",
    title: "无限保存",
    description: "保存所有你的创作",
    isPremium: true
) {
    // 功能操作
}
```

### 手动购买流程

```swift
// 购买指定产品
Task {
    do {
        try await RCPurchaseManager.shared.purchaseProduct(
            withID: RCConfiguration.ProductIDs.yearly
        )
        print("购买成功！")
    } catch {
        print("购买失败：\(error)")
    }
}

// 恢复购买
Task {
    do {
        try await RCPurchaseManager.shared.restorePurchases()
        print("恢复成功！")
    } catch {
        print("恢复失败：\(error)")
    }
}
```

### 获取产品信息

```swift
@StateObject private var purchaseManager = RCPurchaseManager.shared

// 获取所有可用产品
let products = purchaseManager.availableProducts

// 获取指定产品
if let yearlyProduct = purchaseManager.getProduct(
    withID: RCConfiguration.ProductIDs.yearly
) {
    print("年度订阅价格：\(yearlyProduct.localizedPriceString)")
}

// 获取本地化价格
if let price = purchaseManager.getLocalizedPrice(
    for: RCConfiguration.ProductIDs.monthly
) {
    print("月度订阅：\(price)")
}
```

### 订阅信息

```swift
@StateObject private var purchaseManager = RCPurchaseManager.shared

// 是否是活跃订阅者
let isActive = purchaseManager.isActiveSubscriber

// 订阅到期日期
if let expirationDate = purchaseManager.subscriptionExpirationDate {
    print("订阅到期：\(expirationDate)")
}

// 是否会自动续订
let willRenew = purchaseManager.willRenew
```

## 🔄 付费 App 迁移到免费 + 内购

如果你的 App 之前是付费下载，现在改为免费 + 内购：

### 1. 启用迁移功能

在 `RCConfiguration.swift` 中：

```swift
static let enableLegacyMigration = true
static let legacyAppCutoffDate = "2024-01-01" // App 转免费的日期
```

### 2. 自动检测

系统会自动检测用户的安装日期：
- 如果安装日期 < 截止日期 → 自动解锁 Premium
- 如果安装日期 ≥ 截止日期 → 需要购买

### 3. 手动标记（可选）

如果需要手动标记某些用户为老用户：

```swift
RCConfiguration.markAsLegacyUser()
```

### 4. 检查老用户状态

```swift
@StateObject private var purchaseManager = RCPurchaseManager.shared

if purchaseManager.isLegacyUser {
    print("这是付费 App 的老用户")
}
```

## 🎨 自定义付费墙 UI

`RCPaywallView.swift` 提供了一个完整的付费墙界面，你可以：

1. **直接使用**：开箱即用的精美界面
2. **修改样式**：调整颜色、字体、布局
3. **完全自定义**：参考代码创建自己的付费墙

### 自定义示例

```swift
// 修改渐变色
LinearGradient(
    colors: [
        Color.purple,  // 改为你的品牌色
        Color.blue
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

// 修改功能列表
FeatureRow(icon: "your.icon", title: "你的功能", description: "描述")
```

## 🔧 高级功能

### 用户管理

```swift
// 设置用户 ID（用于跨设备同步）
await RCPurchaseManager.shared.setUserID("user_123")

// 登出用户
await RCPurchaseManager.shared.logoutUser()
```

### 刷新购买状态

```swift
// 手动刷新（通常不需要，系统会自动更新）
await RCPurchaseManager.shared.refreshPurchaseState()
```

### 检查是否可以购买

```swift
if RCPurchaseManager.shared.canMakePurchases {
    // 设备支持内购
} else {
    // 设备不支持内购（如企业设备）
}
```

## 📱 完整示例

```swift
import SwiftUI

struct FeatureView: View {
    @StateObject private var purchaseManager = RCPurchaseManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 显示 Premium 徽章
            RCPremiumBadge()
            
            // Premium 功能列表
            VStack(spacing: 12) {
                RCPremiumFeatureItem(
                    icon: "photo.stack.fill",
                    title: "无限保存",
                    description: "保存所有作品",
                    isPremium: true
                ) {
                    saveWork()
                }
                
                RCPremiumFeatureItem(
                    icon: "wand.and.stars",
                    title: "所有贴纸",
                    description: "解锁全部贴纸主题",
                    isPremium: true
                ) {
                    unlockStickers()
                }
            }
            
            // 升级按钮
            if !purchaseManager.hasPremium {
                Button("升级到 Premium") {
                    showPaywall = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .fullScreenCover(isPresented: $showPaywall) {
            RCPaywallView {
                // 购买成功回调
                print("购买成功！")
            }
        }
    }
    
    private func saveWork() {
        // 保存作品逻辑
    }
    
    private func unlockStickers() {
        // 解锁贴纸逻辑
    }
}
```

## 🐛 调试

### 启用调试日志

在 `RCConfiguration.swift` 中：

```swift
#if DEBUG
static let enableDebugLogs = true
#else
static let enableDebugLogs = false
#endif
```

调试日志会显示：
- ✅ 配置成功
- 📦 产品加载
- 💰 购买流程
- 🔄 状态更新
- ❌ 错误信息

### 测试沙盒环境

在 Debug 模式下，系统会自动使用沙盒环境。确保：
1. 使用沙盒测试账号
2. 在 App Store Connect 中创建了测试产品
3. 在设备上登录沙盒账号

## 📋 复制到新项目

1. **复制整个 `RevenueCat` 文件夹**到新项目
2. **添加 RevenueCat 依赖**（SPM）
3. **修改 `RCConfiguration.swift`**：
   - API Key
   - Product IDs
   - Entitlement ID
   - Legacy Migration 设置
4. **在 App 启动时调用** `RCPurchaseManager.shared.configure()`
5. **完成！** 🎉

## 🎯 最佳实践

1. **尽早初始化**：在 App 启动时就配置 RevenueCat
2. **使用 @StateObject**：确保 PurchaseManager 只创建一次
3. **处理错误**：使用 do-catch 处理购买错误
4. **提供恢复购买**：在付费墙中提供恢复购买按钮
5. **测试所有流程**：购买、恢复、取消、网络错误等

## ⚠️ 注意事项

1. **API Key 安全**：虽然 Public API Key 可以暴露，但不要提交到公开仓库
2. **Product IDs**：必须与 App Store Connect 中的产品 ID 完全一致
3. **Entitlement ID**：必须与 RevenueCat Dashboard 中的配置一致
4. **测试环境**：使用沙盒账号测试，不要使用真实账号
5. **Legacy Migration**：仔细设置截止日期，避免误判

## 📚 相关资源

- [RevenueCat 官方文档](https://docs.revenuecat.com/)
- [RevenueCat Dashboard](https://app.revenuecat.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)

## 💡 常见问题

### Q: 为什么购买后没有立即生效？
A: 检查 Entitlement ID 是否配置正确，查看调试日志。

### Q: 如何测试订阅？
A: 使用沙盒测试账号，订阅会加速（1个月 = 5分钟）。

### Q: 老用户迁移不生效？
A: 检查 `enableLegacyMigration` 和 `legacyAppCutoffDate` 配置。

### Q: 如何自定义付费墙？
A: 直接修改 `RCPaywallView.swift` 或创建自己的 View。

---

**版本**: 1.0.0  
**最后更新**: 2024-10-23  
**兼容性**: iOS 16.0+, RevenueCat 5.0+

