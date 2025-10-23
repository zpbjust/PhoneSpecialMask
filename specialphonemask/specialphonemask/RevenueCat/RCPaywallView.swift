//
//  RCPaywallView.swift
//  RevenueCat Integration
//
//  付费墙 UI 组件 - 可自定义的购买界面
//

import SwiftUI
import RevenueCat

/// Paywall View - 付费墙界面
struct RCPaywallView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseManager = RCPurchaseManager.shared
    
    @State private var selectedProductID: String = RCConfiguration.ProductIDs.yearly
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showRestoreSuccess: Bool = false
    
    var onPurchaseSuccess: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.6, blue: 1.0),
                    Color(red: 0.2, green: 0.4, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                    }
                    
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("解锁全部功能")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("享受完整的创作体验")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 20)
                    
                    // Features
                    VStack(spacing: 20) {
                        PaywallFeatureRow(icon: "photo.stack.fill", title: "无限制保存作品", description: "保存所有你的创意设计")
                        PaywallFeatureRow(icon: "wand.and.stars", title: "所有贴纸主题", description: "解锁全部精美贴纸")
                        PaywallFeatureRow(icon: "paintbrush.fill", title: "自定义背景", description: "使用任意照片作为背景")
                        PaywallFeatureRow(icon: "sparkles", title: "持续更新", description: "获取最新内容和功能")
                    }
                    .padding(.horizontal, 30)
                    
                    // Product selection
                    VStack(spacing: 16) {
                        if !purchaseManager.availableProducts.isEmpty {
                            ForEach(purchaseManager.availableProducts, id: \.productIdentifier) { product in
                                ProductCard(
                                    product: product,
                                    isSelected: selectedProductID == product.productIdentifier,
                                    onSelect: { selectedProductID = product.productIdentifier }
                                )
                            }
                        } else {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Purchase button
                    Button(action: { purchaseSelectedProduct() }) {
                        HStack {
                            if purchaseManager.isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("立即订阅")
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.9))
                        .cornerRadius(28)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .disabled(purchaseManager.isPurchasing || purchaseManager.availableProducts.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Restore button
                    Button(action: { restorePurchases() }) {
                        HStack {
                            if purchaseManager.isRestoring {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("恢复购买")
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .disabled(purchaseManager.isRestoring)
                    
                    // Terms and privacy
                    HStack(spacing: 20) {
                        Button("服务条款") {
                            // Open terms URL
                        }
                        
                        Button("隐私政策") {
                            // Open privacy URL
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 30)
                }
            }
        }
        .alert("提示", isPresented: $showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("恢复成功", isPresented: $showRestoreSuccess) {
            Button("确定", role: .cancel) {
                if purchaseManager.hasPremium {
                    onPurchaseSuccess?()
                    dismiss()
                }
            }
        } message: {
            Text("已成功恢复您的购买")
        }
        .onChange(of: purchaseManager.hasPremium) { newValue in
            if newValue {
                onPurchaseSuccess?()
                dismiss()
            }
        }
    }
    
    // MARK: - Actions
    
    private func purchaseSelectedProduct() {
        Task {
            do {
                try await purchaseManager.purchaseProduct(withID: selectedProductID)
                // Success is handled by onChange(of: hasPremium)
            } catch PurchaseError.userCancelled {
                // User cancelled, do nothing
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            do {
                try await purchaseManager.restorePurchases()
                showRestoreSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Paywall Feature Row

struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.yellow)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

// MARK: - Product Card

struct ProductCard: View {
    let product: StoreProduct
    let isSelected: Bool
    let onSelect: () -> Void
    
    private var isYearly: Bool {
        product.productIdentifier.contains("yearly")
    }
    
    private var savingsText: String? {
        if isYearly {
            return "最超值"
        }
        return nil
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(product.localizedTitle)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if let savings = savingsText {
                            Text(savings)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(product.localizedDescription)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(product.localizedPriceString)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let period = product.subscriptionPeriod {
                        Text(periodText(period))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color(red: 0.2, green: 0.4, blue: 0.9) : .gray)
                    .padding(.leading, 8)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(red: 0.2, green: 0.4, blue: 0.9) : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func periodText(_ period: SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            return "每 \(period.value) 天"
        case .week:
            return "每 \(period.value) 周"
        case .month:
            return "每 \(period.value) 个月"
        case .year:
            return "每 \(period.value) 年"
        @unknown default:
            return ""
        }
    }
}

// MARK: - Preview

#Preview {
    RCPaywallView()
}

