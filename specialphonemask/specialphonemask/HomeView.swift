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
    @State private var showGridView = false
    
    var body: some View {
        ZStack {
            // Main Content
            TabView(selection: $selectedTab) {
                // Wallpapers Tab
                WallpaperGalleryView(
                    currentIndex: $currentWallpaperIndex,
                    showGridView: $showGridView
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
                .padding(.top, 50)  // Increased padding for safe area
                
                Spacer()
            }
            .background(
                // Gradient fade from top
                VStack {
                    LinearGradient(
                        colors: [.black.opacity(0.5), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 150)
                    
                    Spacer()
                }
                .ignoresSafeArea()
            )
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
                                .fill(selectedTab == tab ? Color.white : Color.white.opacity(0.3))
                                .frame(width: selectedTab == tab ? 6 : 5, height: selectedTab == tab ? 6 : 5)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: selectedTab == tab ? 1 : 0)
                                        .scaleEffect(selectedTab == tab ? 1.5 : 1.0)
                                        .opacity(selectedTab == tab ? 0.3 : 0)
                                )
                            
                            // Label Text (only show when selected)
                            if selectedTab == tab {
                                Text(tab.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, selectedTab == tab ? 12 : 8)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color.white.opacity(0.15) : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
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
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(showGridView ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
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
    @State private var wallpapers = Wallpaper.sampleWallpapers
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Full Screen View
            if !showGridView {
                TabView(selection: $currentIndex) {
                    ForEach(Array(wallpapers.enumerated()), id: \.element.id) { index, wallpaper in
                        WallpaperPageView(wallpaper: wallpaper, currentIndex: index + 1, total: wallpapers.count)
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
    }
}

// MARK: - Wallpaper Page View
struct WallpaperPageView: View {
    let wallpaper: Wallpaper
    let currentIndex: Int
    let total: Int
    
    @State private var showDetails = false
    @State private var isSaved = false
    @State private var showGuide = false
    @State private var showPermissionDenied = false
    
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
                    showDetails: $showDetails,
                    isSaved: $isSaved,
                    onSave: {
                        saveWallpaper()
                    },
                    onEdit: {
                        // TODO: Navigate to edit
                    }
                )
                .padding(.bottom, 40)
            }
            
            // Wallpaper Guide Overlay
            if showGuide {
                WallpaperGuideView(onDismiss: {
                    showGuide = false
                })
            }
        }
        .edgesIgnoringSafeArea(.all)
        .withPhotoLibraryPermission(
            showDeniedGuide: $showPermissionDenied,
            title: "需要相册权限",
            message: "请允许访问相册，以便保存精美壁纸到您的设备"
        )
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
                
                // Show guide after 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        showGuide = true
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
    @Binding var showDetails: Bool
    @Binding var isSaved: Bool
    let onSave: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Simple Page Indicator (no arrows)
            Text("\(currentIndex)/\(total)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            // Description (expandable)
            if showDetails {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                // Save Button
                Button(action: onSave) {
                    HStack(spacing: 8) {
                        Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down.fill")
                            .font(.system(size: 18))
                        Text(isSaved ? "已保存" : "保存到相册")
                            .font(.system(size: 16, weight: .semibold))
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
                
                // Info Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showDetails.toggle()
                    }
                }) {
                    Image(systemName: showDetails ? "info.circle.fill" : "info.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Color.white.opacity(0.15),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 30)
        }
        .padding(.horizontal, 20)
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

// MARK: - Sticker Gallery View
struct StickerGalleryView: View {
    @Binding var currentIndex: Int
    @Binding var showGridView: Bool
    @State private var themes = StickerTheme.sampleThemes
    
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

// MARK: - Sticker Page View
struct StickerPageView: View {
    let theme: StickerTheme
    let currentIndex: Int
    let total: Int
    
    @State private var showDetails = false
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
                    showDetails: $showDetails,
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
    @Binding var showDetails: Bool
    let onStartCreate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Simple Page Indicator
            Text("\(currentIndex)/\(total)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            // Action Buttons
            HStack(spacing: 16) {
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
                
                // Info Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showDetails.toggle()
                    }
                }) {
                    Image(systemName: showDetails ? "info.circle.fill" : "info.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Color.white.opacity(0.15),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                }
            }
            .padding(.horizontal, 30)
        }
    }
}

// MARK: - My Works View
struct MyWorksView: View {
    @State private var savedWorks: [String] = []
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Empty State
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("还没有作品")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("去创作你的第一张壁纸吧！")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Wallpaper Guide View
struct WallpaperGuideView: View {
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
                .padding(.top, 40)
                
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
                    
                    // Dismiss Button
                    Button(action: onDismiss) {
                        Text("我知道了")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 20)
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

