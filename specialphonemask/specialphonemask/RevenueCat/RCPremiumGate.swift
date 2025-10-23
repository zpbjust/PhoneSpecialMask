//
//  RCPremiumGate.swift
//  RevenueCat Integration
//
//  Premium 功能门控组件 - 用于限制功能访问
//

import SwiftUI

/// Premium Gate - 用于包裹需要 Premium 权限的功能
struct RCPremiumGate<Content: View>: View {
    
    @StateObject private var purchaseManager = RCPurchaseManager.shared
    @State private var showPaywall = false
    
    let content: Content
    let showLockIcon: Bool
    let onPremiumRequired: (() -> Void)?
    
    init(
        showLockIcon: Bool = true,
        onPremiumRequired: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.showLockIcon = showLockIcon
        self.onPremiumRequired = onPremiumRequired
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if purchaseManager.hasPremium {
                // 已解锁，显示内容
                content
            } else {
                // 未解锁，显示锁定状态
                Button(action: {
                    onPremiumRequired?()
                    showPaywall = true
                }) {
                    ZStack {
                        content
                            .blur(radius: 3)
                            .disabled(true)
                        
                        if showLockIcon {
                            VStack(spacing: 8) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 4)
                                
                                Text("Premium")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 4)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            RCPaywallView()
        }
    }
}

/// Premium Button - 带锁图标的按钮
struct RCPremiumButton: View {
    
    @StateObject private var purchaseManager = RCPurchaseManager.shared
    @State private var showPaywall = false
    
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if purchaseManager.hasPremium {
                action()
            } else {
                showPaywall = true
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                
                Text(title)
                
                if !purchaseManager.hasPremium {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            RCPaywallView()
        }
    }
}

/// Premium Badge - Premium 徽章
struct RCPremiumBadge: View {
    
    @StateObject private var purchaseManager = RCPurchaseManager.shared
    
    var body: some View {
        if purchaseManager.hasPremium {
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 12))
                Text("Premium")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.yellow)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(8)
        }
    }
}

/// Premium Feature List Item - 功能列表项
struct RCPremiumFeatureItem: View {
    
    @StateObject private var purchaseManager = RCPurchaseManager.shared
    @State private var showPaywall = false
    
    let icon: String
    let title: String
    let description: String
    let isPremium: Bool
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        description: String,
        isPremium: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.isPremium = isPremium
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isPremium || purchaseManager.hasPremium {
                action()
            } else {
                showPaywall = true
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if isPremium && !purchaseManager.hasPremium {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showPaywall) {
            RCPaywallView()
        }
    }
}

// MARK: - View Extensions

extension View {
    
    /// 为 View 添加 Premium 门控
    func premiumGated(showLockIcon: Bool = true) -> some View {
        RCPremiumGate(showLockIcon: showLockIcon) {
            self
        }
    }
    
    /// 检查 Premium 状态并执行操作
    func requiresPremium(action: @escaping () -> Void) -> some View {
        self.modifier(PremiumRequiredModifier(action: action))
    }
}

// MARK: - Premium Required Modifier

struct PremiumRequiredModifier: ViewModifier {
    
    @StateObject private var purchaseManager = RCPurchaseManager.shared
    @State private var showPaywall = false
    
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if purchaseManager.hasPremium {
                    action()
                } else {
                    showPaywall = true
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                RCPaywallView()
            }
    }
}

// MARK: - Preview

#Preview("Premium Gate") {
    VStack(spacing: 20) {
        RCPremiumGate {
            Text("Premium Content")
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
        }
        
        RCPremiumButton(title: "Premium Feature", icon: "star.fill") {
            print("Premium feature tapped")
        }
        
        RCPremiumBadge()
    }
    .padding()
}

