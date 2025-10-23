//
//  RCPurchaseManager.swift
//  RevenueCat Integration
//
//  核心购买管理类 - 处理所有购买逻辑
//

import Foundation
import RevenueCat
import Combine

/// Purchase State
enum PurchaseState {
    case notPurchased
    case purchased
    case loading
    case error(Error)
}

/// Purchase Error
enum PurchaseError: LocalizedError {
    case userCancelled
    case productNotFound
    case purchaseFailed(String)
    case restoreFailed(String)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "购买已取消"
        case .productNotFound:
            return "找不到该产品"
        case .purchaseFailed(let message):
            return "购买失败：\(message)"
        case .restoreFailed(let message):
            return "恢复购买失败：\(message)"
        case .networkError:
            return "网络连接失败，请检查网络后重试"
        }
    }
}

/// Purchase Manager - Singleton
@MainActor
class RCPurchaseManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = RCPurchaseManager()
    
    // MARK: - Published Properties
    
    /// 当前购买状态
    @Published private(set) var purchaseState: PurchaseState = .loading
    
    /// 是否拥有 Premium 权益
    @Published private(set) var hasPremium: Bool = false
    
    /// 可用的产品列表
    @Published private(set) var availableProducts: [StoreProduct] = []
    
    /// 当前用户信息
    @Published private(set) var customerInfo: CustomerInfo?
    
    /// 是否正在处理购买
    @Published private(set) var isPurchasing: Bool = false
    
    /// 是否正在恢复购买
    @Published private(set) var isRestoring: Bool = false
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        configure()
    }
    
    // MARK: - Configuration
    
    /// 配置 RevenueCat
    func configure() {
        // 配置日志级别
        if RCConfiguration.enableDebugLogs {
            Purchases.logLevel = .debug
        } else {
            Purchases.logLevel = .error
        }
        
        // 配置 RevenueCat
        Purchases.configure(withAPIKey: RCConfiguration.apiKey)
        
        // 设置代理
        Purchases.shared.delegate = self
        
        // 获取初始状态
        Task {
            await refreshPurchaseState()
            await loadProducts()
        }
        
        if RCConfiguration.enableDebugLogs {
            print("✅ RevenueCat configured with API Key: \(RCConfiguration.apiKey)")
        }
    }
    
    // MARK: - Purchase State Management
    
    /// 刷新购买状态
    func refreshPurchaseState() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            await updateCustomerInfo(info)
        } catch {
            if RCConfiguration.enableDebugLogs {
                print("❌ Failed to refresh purchase state: \(error)")
            }
            purchaseState = .error(error)
        }
    }
    
    /// 更新用户信息
    private func updateCustomerInfo(_ info: CustomerInfo) async {
        customerInfo = info
        
        // 检查是否拥有 Premium 权益
        hasPremium = info.entitlements[RCConfiguration.entitlementID]?.isActive == true
        purchaseState = hasPremium ? .purchased : .notPurchased
        
        if RCConfiguration.enableDebugLogs {
            print("📊 Customer Info Updated:")
            print("  - Has Premium: \(hasPremium)")
            print("  - Entitlements: \(info.entitlements.all.keys)")
        }
    }
    
    // MARK: - Product Loading
    
    /// 加载可用产品
    func loadProducts() async {
        do {
            let products = try await Purchases.shared.products(RCConfiguration.ProductIDs.all)
            availableProducts = products
            
            if RCConfiguration.enableDebugLogs {
                print("📦 Loaded \(products.count) products:")
                products.forEach { product in
                    print("  - \(product.productIdentifier): \(product.localizedPriceString)")
                }
            }
        } catch {
            if RCConfiguration.enableDebugLogs {
                print("❌ Failed to load products: \(error)")
            }
        }
    }
    
    /// 获取指定产品
    func getProduct(withID productID: String) -> StoreProduct? {
        return availableProducts.first { $0.productIdentifier == productID }
    }
    
    // MARK: - Purchase Flow
    
    /// 购买产品
    func purchase(_ product: StoreProduct) async throws {
        guard !isPurchasing else { return }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let result = try await Purchases.shared.purchase(product: product)
            
            if RCConfiguration.enableDebugLogs {
                print("✅ Purchase successful:")
                print("  - Product: \(product.productIdentifier)")
                print("  - Transaction: \(result.transaction?.transactionIdentifier ?? "N/A")")
            }
            
            // 更新状态
            await updateCustomerInfo(result.customerInfo)
            
        } catch let error as ErrorCode {
            if RCConfiguration.enableDebugLogs {
                print("❌ Purchase failed: \(error)")
            }
            
            // ErrorCode itself is the enum, not a wrapper with .code property
            switch error {
            case .purchaseCancelledError:
                throw PurchaseError.userCancelled
            case .networkError:
                throw PurchaseError.networkError
            default:
                throw PurchaseError.purchaseFailed(error.localizedDescription)
            }
        } catch {
            throw PurchaseError.purchaseFailed(error.localizedDescription)
        }
    }
    
    /// 通过产品 ID 购买
    func purchaseProduct(withID productID: String) async throws {
        guard let product = getProduct(withID: productID) else {
            throw PurchaseError.productNotFound
        }
        
        try await purchase(product)
    }
    
    // MARK: - Restore Purchases
    
    /// 恢复购买
    func restorePurchases() async throws {
        guard !isRestoring else { return }
        
        isRestoring = true
        defer { isRestoring = false }
        
        do {
            let info = try await Purchases.shared.restorePurchases()
            
            if RCConfiguration.enableDebugLogs {
                print("✅ Restore successful")
            }
            
            await updateCustomerInfo(info)
            
            // 检查是否有任何活跃的权益
            if !info.entitlements.active.isEmpty {
                // 恢复成功
            } else {
                throw PurchaseError.restoreFailed("未找到可恢复的购买记录")
            }
            
        } catch let error as ErrorCode {
            if RCConfiguration.enableDebugLogs {
                print("❌ Restore failed: \(error)")
            }
            
            // ErrorCode itself is the enum, not a wrapper with .code property
            switch error {
            case .networkError:
                throw PurchaseError.networkError
            default:
                throw PurchaseError.restoreFailed(error.localizedDescription)
            }
        } catch {
            throw PurchaseError.restoreFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Subscription Info
    
    /// 获取订阅到期日期
    var subscriptionExpirationDate: Date? {
        return customerInfo?.entitlements[RCConfiguration.entitlementID]?.expirationDate
    }
    
    /// 是否是活跃订阅
    var isActiveSubscriber: Bool {
        return customerInfo?.entitlements[RCConfiguration.entitlementID]?.isActive == true
    }
    
    /// 订阅是否会自动续订
    var willRenew: Bool {
        return customerInfo?.entitlements[RCConfiguration.entitlementID]?.willRenew == true
    }
}

// MARK: - PurchasesDelegate

extension RCPurchaseManager: PurchasesDelegate {
    
    /// 当用户信息更新时调用
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            await updateCustomerInfo(customerInfo)
            
            if RCConfiguration.enableDebugLogs {
                print("🔄 Customer info updated from delegate")
            }
        }
    }
}

