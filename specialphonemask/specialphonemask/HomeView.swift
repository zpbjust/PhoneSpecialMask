//
//  HomeView.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/22.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: HomeTab = .wallpapers
    @State private var currentWallpaperIndex = 0
    @State private var currentStickerIndex = 0
    @State private var showGridView = true  // 默认网格模式，方便预览和切换
    
    // 弹窗状态 - 提升到HomeView层级
    @State private var showWallpaperGuide = false
    @State private var showPermissionDenied = false
    @AppStorage("dontShowGuideAgain") private var dontShowGuideAgain = false
    
    var body: some View {
        ZStack {
            // Main Content
            TabView(selection: $selectedTab) {
                // Wallpapers Tab
                WallpaperGalleryView(
                    currentIndex: $currentWallpaperIndex,
                    showGridView: $showGridView,
                    showGuide: $showWallpaperGuide,
                    showPermissionDenied: $showPermissionDenied
                )
                .tag(HomeTab.wallpapers)
                
                // Stickers Tab
                StickerGalleryView(
                    currentIndex: $currentStickerIndex,
                    showGridView: $showGridView
                )
                .tag(HomeTab.stickers)
                
                // My Works Tab
                MyWorksView()
                    .tag(HomeTab.myWorks)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Floating Navigation
            VStack {
                MinimalistNavigationBar(
                    selectedTab: $selectedTab,
                    showGridView: $showGridView
                )
                .padding(.top, 70)  // 增加顶部间距，避免被灵动岛遮挡
                
                Spacer()
            }
            .background(
                // Gradient fade from top - 更柔和的渐变
                VStack {
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 180)
                    
                    Spacer()
                }
                .ignoresSafeArea()
            )
            
            // 全局弹窗 - 在ZStack最上层，覆盖所有内容包括导航栏
            if showWallpaperGuide {
                WallpaperGuideView(
                    dontShowAgain: $dontShowGuideAgain,
                    onDismiss: {
                        showWallpaperGuide = false
                    }
                )
                .zIndex(1000)
            }
            
            if showPermissionDenied {
                PermissionDeniedGuideView(
                    title: "需要相册权限",
                    message: "请允许访问相册，以便保存精美壁纸到您的设备",
                    onDismiss: {
                        showPermissionDenied = false
                    }
                )
                .zIndex(1000)
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
 }

// MARK: - Minimalist Navigation Bar
struct MinimalistNavigationBar: View {
    @Binding var selectedTab: HomeTab
    @Binding var showGridView: Bool
    
    var body: some View {
        HStack {
            // Tab Indicators with Labels
            HStack(spacing: 16) {
                ForEach(HomeTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                        
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }) {
                        HStack(spacing: 6) {
                            // Dot Indicator
                            Circle()
                                .fill(selectedTab == tab ? Color(red: 0.2, green: 0.5, blue: 1.0) : Color.gray.opacity(0.5))
                                .frame(width: selectedTab == tab ? 6 : 5, height: selectedTab == tab ? 6 : 5)
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.3), lineWidth: selectedTab == tab ? 1 : 0)
                                        .scaleEffect(selectedTab == tab ? 1.5 : 1.0)
                                        .opacity(selectedTab == tab ? 0.3 : 0)
                                )
                            
                            // Label Text (only show when selected)
                            if selectedTab == tab {
                                Text(tab.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, selectedTab == tab ? 12 : 8)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.15) : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)  // 使用毛玻璃效果
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
            )
            
            Spacer()
            
            // Grid View Button (only for wallpapers and stickers)
            if selectedTab != .myWorks {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showGridView.toggle()
                    }
                    
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: showGridView ? "rectangle.fill" : "square.grid.3x3.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        if showGridView {
                            Text("列表")
                                .font(.system(size: 13, weight: .semibold))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .foregroundColor(showGridView ? Color(red: 0.2, green: 0.5, blue: 1.0) : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)  // 使用毛玻璃效果
                            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Wallpaper Gallery View
struct WallpaperGalleryView: View {
    @Binding var currentIndex: Int
    @Binding var showGridView: Bool
    @Binding var showGuide: Bool
    @Binding var showPermissionDenied: Bool
    
    @State private var wallpapers: [Wallpaper] = []
    @State private var dragOffset: CGFloat = 0
    @AppStorage("dontShowGuideAgain") private var dontShowGuideAgain = false
    
    var body: some View {
        ZStack {
            // Full Screen View
            if !showGridView {
                TabView(selection: $currentIndex) {
                    ForEach(Array(wallpapers.enumerated()), id: \.element.id) { index, wallpaper in
                        WallpaperPageView(
                            wallpaper: wallpaper,
                            currentIndex: index + 1,
                            total: wallpapers.count,
                            showGuide: $showGuide,
                            showPermissionDenied: $showPermissionDenied
                        )
                        .ignoresSafeArea()
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                .transition(.opacity)
            } else {
                // Grid View
                WallpaperGridView(
                    wallpapers: wallpapers,
                    currentIndex: $currentIndex,
                    showGridView: $showGridView
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .onAppear {
            if wallpapers.isEmpty {
                print("🔄 Loading wallpapers from ResourceLoader...")
                wallpapers = Wallpaper.sampleWallpapers
                print("📊 Loaded \(wallpapers.count) wallpapers")
            }
        }
    }
}

// MARK: - Wallpaper Page View
struct WallpaperPageView: View {
    let wallpaper: Wallpaper
    let currentIndex: Int
    let total: Int
    @Binding var showGuide: Bool
    @Binding var showPermissionDenied: Bool
    
    @State private var isSaved = false
    @AppStorage("dontShowGuideAgain") private var dontShowGuideAgain = false
    
    var body: some View {
        ZStack {
            // Wallpaper Image (absolute full screen)
            MaskImageView(wallpaper.imageName, contentMode: .fill)
                .ignoresSafeArea()
            
            // Gradient Overlay (bottom)
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.3), .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
            }
            .ignoresSafeArea()
            
            // Bottom Info Bar
            VStack {
                Spacer()
                
                BottomInfoBar(
                    title: wallpaper.title,
                    description: wallpaper.description,
                    currentIndex: currentIndex,
                    total: total,
                    isPremium: wallpaper.isPremium,
                    isSaved: $isSaved,
                    onSave: {
                        saveWallpaper()
                    }
                )
                .padding(.bottom, 40)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func saveWallpaper() {
        // Load image
        guard let image = loadWallpaperImage() else { return }
        
        // Request permission and save
        PhotoLibraryPermissionManager.shared.saveImage(
            image,
            onSuccess: {
                // Success - Update UI
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isSaved = true
                }
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // Show guide after 1 second (if not disabled)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if !dontShowGuideAgain {
                        withAnimation {
                            showGuide = true
                        }
                    }
                }
                
                // Reset saved state after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isSaved = false
                    }
                }
            },
            onFailure: { errorMessage in
                // Permission denied - Show guide
                withAnimation {
                    showPermissionDenied = true
                }
            }
        )
    }
    
    private func loadWallpaperImage() -> UIImage? {
        // Try to load from assets
        if let image = UIImage(named: wallpaper.imageName) {
            return image
        }
        
        // Try loading from bundle paths
        let paths = [
            "mask/wallpaper/\(wallpaper.imageName).png",
            "mask/wallpaper/\(wallpaper.imageName).jpg"
        ]
        
        for path in paths {
            if let bundlePath = Bundle.main.path(forResource: path.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: ".jpg", with: ""), ofType: nil),
               let image = UIImage(contentsOfFile: bundlePath) {
                return image
            }
        }
        
        return nil
    }
}

// MARK: - Bottom Info Bar
struct BottomInfoBar: View {
    let title: String
    let description: String
    let currentIndex: Int
    let total: Int
    let isPremium: Bool
    @Binding var isSaved: Bool
    let onSave: () -> Void
    
    @StateObject private var purchaseManager = RCPurchaseManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Simple Page Indicator (no arrows)
            Text("\(currentIndex)/\(total)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            // Save Button
            Button(action: {
                // Check premium status before saving
                if isPremium && !purchaseManager.hasPremium {
                    showPaywall = true
                } else {
                    onSave()
                }
            }) {
                HStack(spacing: 8) {
                    if isSaved {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                        Text("已保存")
                            .font(.system(size: 16, weight: .semibold))
                    } else if isPremium && !purchaseManager.hasPremium {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18))
                        Text("保存到相册")
                            .font(.system(size: 16, weight: .semibold))
                    } else {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.system(size: 18))
                        Text("保存到相册")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(isSaved ? .green : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isSaved ? Color.green.opacity(0.2) : Color.white.opacity(0.15),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSaved ? Color.green : Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            .disabled(isSaved)
            .padding(.horizontal, 30)
        }
        .padding(.horizontal, 20)
        .fullScreenCover(isPresented: $showPaywall) {
            RCPaywallView()
        }
    }
}

// MARK: - Wallpaper Grid View
struct WallpaperGridView: View {
    let wallpapers: [Wallpaper]
    @Binding var currentIndex: Int
    @Binding var showGridView: Bool
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.95, green: 0.96, blue: 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(wallpapers.enumerated()), id: \.element.id) { index, wallpaper in
                        Button(action: {
                            currentIndex = index
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showGridView = false
                            }
                            
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }) {
                            ZStack(alignment: .bottomLeading) {
                                // Wallpaper Thumbnail
                                MaskImageView(wallpaper.imageName, contentMode: .fill)
                                    .frame(height: 240)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                // Gradient Overlay
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.6)],
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                // Title
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(wallpaper.title)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("\(index + 1)/\(wallpapers.count)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(12)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(currentIndex == index ? Color.blue : Color.clear, lineWidth: 3)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 120)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Sticker Gallery View
struct StickerGalleryView: View {
    @Binding var currentIndex: Int
    @Binding var showGridView: Bool
    @State private var themes: [StickerTheme] = []
    
    var body: some View {
        ZStack {
            // Full Screen View
            if !showGridView {
                TabView(selection: $currentIndex) {
                    ForEach(Array(themes.enumerated()), id: \.element.id) { index, theme in
                        StickerPageView(theme: theme, currentIndex: index + 1, total: themes.count)
                            .ignoresSafeArea()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                .transition(.opacity)
            } else {
                // Grid View
                StickerGridView(
                    themes: themes,
                    currentIndex: $currentIndex,
                    showGridView: $showGridView
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .onAppear {
            if themes.isEmpty {
                print("🔄 Loading sticker themes from ResourceLoader...")
                themes = StickerTheme.sampleThemes
                print("📊 Loaded \(themes.count) sticker themes")
            }
        }
    }
}

// MARK: - Sticker Grid View
struct StickerGridView: View {
    let themes: [StickerTheme]
    @Binding var currentIndex: Int
    @Binding var showGridView: Bool
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.95, green: 0.96, blue: 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(themes.enumerated()), id: \.element.id) { index, theme in
                        Button(action: {
                            currentIndex = index
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showGridView = false
                            }
                            
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }) {
                            ZStack(alignment: .bottomLeading) {
                                // Theme Main Image
                                MaskImageView(theme.mainImage, contentMode: .fill)
                                    .frame(height: 240)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                // Gradient Overlay
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.6)],
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                                .frame(height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                // Theme Info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(theme.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("\(theme.stickerCount) 个贴纸")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(12)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(currentIndex == index ? Color.blue : Color.clear, lineWidth: 3)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 120)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Sticker Page View
struct StickerPageView: View {
    let theme: StickerTheme
    let currentIndex: Int
    let total: Int
    
    @State private var showEditor = false
    
    var body: some View {
        ZStack {
            // Theme Main Image (full screen)
            MaskImageView(theme.mainImage, contentMode: .fill)
                .ignoresSafeArea()
            
            // Gradient Overlay (bottom)
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.3), .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 350)
            }
            .ignoresSafeArea()
            
            // Sticker Preview Overlay (middle)
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    ForEach(theme.stickers, id: \.self) { sticker in
                        MaskImageView(sticker, contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                                    .shadow(color: .black.opacity(0.3), radius: 10)
                            )
                    }
                }
                .padding(.bottom, 150)
            }
            
            // Bottom Bar
            VStack {
                Spacer()
                
                StickerBottomBar(
                    currentIndex: currentIndex,
                    total: total,
                    stickerCount: theme.stickerCount,
                    onStartCreate: {
                        showEditor = true
                    }
                )
                .padding(.bottom, 40)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $showEditor) {
            StickerEditorView(theme: theme)
        }
    }
}

// MARK: - Sticker Bottom Bar
struct StickerBottomBar: View {
    let currentIndex: Int
    let total: Int
    let stickerCount: Int
    let onStartCreate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Simple Page Indicator
            Text("\(currentIndex)/\(total)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            // Start Create Button
            Button(action: onStartCreate) {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 18))
                    Text("开始创作")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 30)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - My Works View
struct MyWorksView: View {
    @StateObject private var worksManager = MyWorksManager.shared
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // 背景渐变 - 调整色调更柔和
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.97, blue: 0.99),
                    Color(red: 0.93, green: 0.95, blue: 0.98),
                    Color(red: 0.90, green: 0.93, blue: 0.97)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header - 内购信息区域 - 增加顶部间距
                VStack(spacing: 12) {
                    Text("我的")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Premium Banner（预留内购位置）
                    PremiumBanner()
                }
                .padding(.horizontal, 20)
                .padding(.top, 100)  // 增加顶部间距，从60改为100
                .padding(.bottom, 20)
                
                // Works Content
                if worksManager.works.isEmpty {
                    // Empty State
                    VStack(spacing: 24) {
                        Spacer()
                        
                        ZStack {
                            // Background circle
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.1),
                                            Color.purple.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "photo.stack")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 12) {
                            Text("还没有作品")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("创作专属壁纸，让锁屏更个性")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                } else {
                    // Works Grid
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(worksManager.works) { work in
                                WorkCard(work: work, worksManager: worksManager)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .preferredColorScheme(.light)  // 强制使用亮色模式
    }
}

// MARK: - Premium Banner
struct PremiumBanner: View {
    @StateObject private var purchaseManager = RCPurchaseManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        Button(action: {
            if !purchaseManager.hasPremium {
                showPaywall = true
            }
        }) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: purchaseManager.hasPremium ? [Color.green, Color.blue] : [Color.orange, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: purchaseManager.hasPremium ? "checkmark.circle.fill" : "crown.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    if purchaseManager.hasPremium {
                        Text("专业版会员")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if let expirationDate = purchaseManager.subscriptionExpirationDate {
                            if purchaseManager.willRenew {
                                Text("到期时间：\(formatDate(expirationDate))")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("到期时间：\(formatDate(expirationDate))（不续费）")
                                    .font(.system(size: 13))
                                    .foregroundColor(.orange)
                            }
                        } else {
                            Text("终身会员")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("升级至专业版")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("解锁全部主题和功能")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Arrow
                if !purchaseManager.hasPremium {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showPaywall) {
            RCPaywallView()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - Work Card
struct WorkCard: View {
    let work: MyWork
    @ObservedObject var worksManager: MyWorksManager
    
    @State private var showDeleteConfirmation = false
    @State private var showFullImage = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Work Thumbnail - 点击整个卡片预览
            Button(action: {
                showFullImage = true
            }) {
                ZStack {
                    if let thumbnail = worksManager.loadWorkImage(work, useThumbnail: true) {
                        ThumbnailImageView(thumbnail: thumbnail)
                    } else {
                        // Placeholder
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.gray.opacity(0.1),
                                        Color.gray.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 240)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.3))
                            )
                    }
                    
                    // Actions Overlay (只保留删除按钮)
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            // Delete Button
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.trailing, 12)
                            .padding(.bottom, 12)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            colors: [
                                .clear,
                                .black.opacity(0.1),
                                .black.opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .allowsHitTesting(true)  // 允许点击事件
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Date Info
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Text(work.createdAt, style: .date)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .offset(y: -8)
            .padding(.horizontal, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .alert("确认删除", isPresented: $showDeleteConfirmation) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    worksManager.deleteWork(work)
                }
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
        } message: {
            Text("删除后无法恢复此作品")
        }
        .fullScreenCover(isPresented: $showFullImage) {
            if let fullImage = worksManager.loadWorkImage(work) {
                FullImageView(image: fullImage, onDismiss: {
                    showFullImage = false
                })
            }
        }
    }
}

// MARK: - Action Button
// MARK: - Thumbnail Image View
struct ThumbnailImageView: View {
    let thumbnail: UIImage
    
    var body: some View {
        let cardWidth = (UIScreen.main.bounds.width - 56) / 2
        let cardHeight: CGFloat = 240
        
        return Image(uiImage: thumbnail)
            .resizable()
            .scaledToFill()  // 等比例放大填满，保持比例
            .frame(width: cardWidth, height: cardHeight)
            .clipped()  // 裁剪超出部分
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(color)
                        .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                )
        }
    }
}

// MARK: - Full Image View
struct FullImageView: View {
    let image: UIImage
    let onDismiss: () -> Void
    
    @State private var showSaveSuccess = false
    @State private var isSaving = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Image (居中显示)
            GeometryReader { geometry in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .ignoresSafeArea()
            
            // Top Bar - 提高位置
            VStack {
                HStack {
                    // Close Button
                    Button(action: onDismiss) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: saveToAlbum) {
                        HStack(spacing: 8) {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else if showSaveSuccess {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            Text(showSaveSuccess ? "已保存" : "保存")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(showSaveSuccess ? Color.green : Color.blue)
                        )
                    }
                    .disabled(isSaving || showSaveSuccess)
                }
                .padding(.horizontal, 20)
                .padding(.top, 36)  // 调整为36
                
                Spacer()
            }
            
            // Success Overlay
            if showSaveSuccess {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                        
                        Text("已保存到相册")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .background(.ultraThinMaterial)
                    )
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private func saveToAlbum() {
        isSaving = true
        
        PhotoLibraryPermissionManager.shared.saveImage(
            image,
            onSuccess: {
                withAnimation {
                    isSaving = false
                    showSaveSuccess = true
                }
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // 3秒后隐藏成功提示
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showSaveSuccess = false
                    }
                }
            },
            onFailure: { error in
                withAnimation {
                    isSaving = false
                }
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        )
    }
}

// MARK: - Wallpaper Guide View
struct WallpaperGuideView: View {
    @Binding var dontShowAgain: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background Overlay
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("已保存到相册")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 80)  // 增加顶部padding，避免被刘海遮挡
                
                // Guide Steps
                VStack(alignment: .leading, spacing: 24) {
                    Text("如何设置为壁纸？")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    GuideStepView(
                        number: "1",
                        icon: "gear",
                        title: "打开\"设置\"",
                        description: "在主屏幕找到设置应用"
                    )
                    
                    GuideStepView(
                        number: "2",
                        icon: "photo",
                        title: "选择\"壁纸\"",
                        description: "进入壁纸设置页面"
                    )
                    
                    GuideStepView(
                        number: "3",
                        icon: "plus.circle",
                        title: "添加新壁纸",
                        description: "从相册中选择刚保存的图片"
                    )
                    
                    GuideStepView(
                        number: "4",
                        icon: "checkmark.circle",
                        title: "设为锁屏或主屏",
                        description: "选择锁定屏幕或主屏幕"
                    )
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    // Don't Show Again Toggle
                    Button(action: {
                        withAnimation {
                            dontShowAgain.toggle()
                        }
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundColor(dontShowAgain ? .blue : .white.opacity(0.5))
                            
                            Text("不再提示")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Open Settings
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                        onDismiss()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "gear")
                                .font(.system(size: 18))
                            Text("打开设置")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Dismiss Button
                    Button(action: onDismiss) {
                        Text("我知道了")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

// MARK: - Guide Step View
struct GuideStepView: View {
    let number: String
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Step Number
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(number)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}

