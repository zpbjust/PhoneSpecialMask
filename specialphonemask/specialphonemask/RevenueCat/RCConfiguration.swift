//
//  RCConfiguration.swift
//  RevenueCat Integration
//
//  通用配置文件 - 所有项目只需修改这个文件
//

import Foundation

/// RevenueCat Configuration
/// 使用说明：在新项目中只需修改此文件的配置即可
struct RCConfiguration {
    
    // MARK: - API Key Configuration
    
    /// RevenueCat API Key
    /// 替换为你的项目的 API Key
    static let apiKey = "appl_iVZXezLxwtMVWxSQLzEeNFrqiRp"
    
    // MARK: - Product Configuration
    
    /// 产品 ID 配置
    /// 根据你的 App Store Connect 配置修改
    struct ProductIDs {
        /// 月度订阅
        static let monthly = "mask.month"
        

        
        /// 年度订阅
        static let yearly = "mask.year"
        
        /// 终身购买（一次性）
        static let lifetime = "mask.lifetime"
        
        /// 所有产品 ID 列表
        static var all: [String] {
            [monthly, yearly, lifetime]
        }
    }
    
    // MARK: - Entitlement Configuration
    
    /// 权益标识符
    /// 在 RevenueCat Dashboard 中配置
    static let entitlementID = "premium_access"
    
    // MARK: - Debug Configuration
    
    /// 是否启用调试日志
    #if DEBUG
    static let enableDebugLogs = true
    #else
    static let enableDebugLogs = false
    #endif
}

