//
//  StickerEditorView.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/22.
//

import SwiftUI
import PhotosUI

// MARK: - Placed Sticker Model
struct PlacedSticker: Identifiable {
    let id = UUID()
    let imageName: String
    var position: CGPoint
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
}

// MARK: - Sticker Editor View
struct StickerEditorView: View {
    let theme: StickerTheme
    @Environment(\.dismiss) var dismiss
    
    @State private var backgroundImage: UIImage?
    @State private var placedStickers: [PlacedSticker] = []
    @State private var selectedStickerId: UUID?
    @State private var showImagePicker = false
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isStickerPanelExpanded = false
    @State private var showPermissionDenied = false
    @State private var showSaveSuccess = false
    @State private var showGuide = false
    @AppStorage("dontShowGuideAgain") private var dontShowGuideAgain = false
    
    // Canvas ID for screenshot
    @State private var canvasID = UUID()
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Canvas
            ZStack {
                // Background Image
                if let backgroundImage = backgroundImage {
                    GeometryReader { geometry in
                        Image(uiImage: backgroundImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                } else {
                    // Default theme image
                    GeometryReader { geometry in
                        MaskImageView(theme.mainImage, contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                
                // Placed Stickers
                ForEach($placedStickers) { $sticker in
                    DraggableSticker(
                        sticker: $sticker,
                        isSelected: selectedStickerId == sticker.id,
                        onTap: {
                            selectedStickerId = sticker.id
                        },
                        onDelete: {
                            placedStickers.removeAll { $0.id == sticker.id }
                            if selectedStickerId == sticker.id {
                                selectedStickerId = nil
                            }
                        }
                    )
                }
            }
            .ignoresSafeArea()
            .onTapGesture {
                // Tap canvas to deselect sticker
                selectedStickerId = nil
            }
            .id(canvasID)  // 用于标识画布进行截图
            
            // 侧边浮动工具栏 - 右下角
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    EditorSideToolbar(
                        theme: theme,
                        selectedStickerId: $selectedStickerId,
                        isStickerPanelExpanded: $isStickerPanelExpanded,
                        onAddSticker: { stickerName in
                            addSticker(stickerName)
                        },
                        onChangeBackground: {
                            requestPhotoPickerPermission()
                        },
                        onDeleteSelected: {
                            if let selectedId = selectedStickerId {
                                placedStickers.removeAll { $0.id == selectedId }
                                selectedStickerId = nil
                            }
                        }
                    )
                    .padding(.trailing, 20)
                    .padding(.bottom, 50)
                }
            }
            
            // Top Bar
            VStack {
                EditorTopBar(onClose: {
                    dismiss()
                }, onSave: {
                    saveCompositeImage()
                })
                .padding(.top, 50)
                
                Spacer()
            }
            
            // Sticker Panel Overlay (底部抽屉式)
            if isStickerPanelExpanded {
                VStack {
                    Spacer()
                    
                    StickerSelectionPanel(
                        theme: theme,
                        onAddSticker: { stickerName in
                            addSticker(stickerName)
                        },
                        onClose: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isStickerPanelExpanded = false
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .background(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isStickerPanelExpanded = false
                            }
                        }
                )
                .zIndex(100)
            }
            
            // Save Success Overlay
            if showSaveSuccess {
                SaveSuccessOverlay(onDismiss: {
                    showSaveSuccess = false
                    
                    // 显示引导 (如果用户没有选择不再提示)
                    if !dontShowGuideAgain {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showGuide = true
                        }
                    } else {
                        dismiss()
                    }
                })
                .zIndex(200)
            }
            
            // Wallpaper Guide
            if showGuide {
                WallpaperGuideView(
                    dontShowAgain: $dontShowGuideAgain,
                    onDismiss: {
                        showGuide = false
                        dismiss()
                    }
                )
                .zIndex(300)
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $photoPickerItem, matching: .images)
        .onChange(of: photoPickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    backgroundImage = image
                }
            }
        }
        .withPhotoLibraryPermission(
            showDeniedGuide: $showPermissionDenied,
            title: "需要相册权限",
            message: "请允许访问相册，以便保存您的创作作品"
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Request Photo Picker Permission
    private func requestPhotoPickerPermission() {
        // Request read/write access for photo picker
        PhotoLibraryPermissionManager.shared.requestPermissionAndExecute(
            for: .readWrite,
            onAuthorized: {
                // Permission granted - Open picker
                showImagePicker = true
            },
            onDenied: {
                // Permission denied - Show guide
                showPermissionDenied = true
            }
        )
    }
    
    // MARK: - Add Sticker
    private func addSticker(_ stickerName: String) {
        let newSticker = PlacedSticker(
            imageName: stickerName,
            position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 200),
            scale: 1.0,
            rotation: .zero
        )
        placedStickers.append(newSticker)
        selectedStickerId = newSticker.id
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Save Composite Image (高分辨率渲染 - 只渲染画布)
    private func saveCompositeImage() {
        // 取消选中状态，确保渲染时没有选中框
        selectedStickerId = nil
        
        // 延迟一点确保UI更新
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 渲染高分辨率画布
            let canvasImage = renderCanvas()
            
            // 1. 保存到Documents（用于"我的作品"展示）
            MyWorksManager.shared.saveWork(image: canvasImage) { result in
                switch result {
                case .success(let work):
                    print("✅ 作品已保存到Documents: \(work.fileName)")
                case .failure(let error):
                    print("❌ 保存作品失败: \(error.localizedDescription)")
                }
            }
            
            // 2. 保存到相册（用户使用）
            PhotoLibraryPermissionManager.shared.saveImage(
                canvasImage,
                onSuccess: {
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // Show success overlay
                    withAnimation {
                        showSaveSuccess = true
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
    }
    
    // MARK: - Render Canvas (高分辨率渲染画布)
    private func renderCanvas() -> UIImage {
        let screenSize = UIScreen.main.bounds.size
        let scale: CGFloat = 3.0  // 使用3倍分辨率，确保高清
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        
        let renderer = UIGraphicsImageRenderer(size: screenSize, format: format)
        
        return renderer.image { context in
            // 1. 绘制背景图
            if let backgroundImage = backgroundImage {
                // 使用 aspectFill 效果
                let imageSize = backgroundImage.size
                let screenAspect = screenSize.width / screenSize.height
                let imageAspect = imageSize.width / imageSize.height
                
                var drawRect: CGRect
                if imageAspect > screenAspect {
                    // 图片更宽，按高度缩放
                    let scaledWidth = screenSize.height * imageAspect
                    drawRect = CGRect(
                        x: (screenSize.width - scaledWidth) / 2,
                        y: 0,
                        width: scaledWidth,
                        height: screenSize.height
                    )
                } else {
                    // 图片更高，按宽度缩放
                    let scaledHeight = screenSize.width / imageAspect
                    drawRect = CGRect(
                        x: 0,
                        y: (screenSize.height - scaledHeight) / 2,
                        width: screenSize.width,
                        height: scaledHeight
                    )
                }
                backgroundImage.draw(in: drawRect)
            } else if let defaultImage = loadImage(theme.mainImage) {
                // 绘制默认主题图
                let imageSize = defaultImage.size
                let screenAspect = screenSize.width / screenSize.height
                let imageAspect = imageSize.width / imageSize.height
                
                var drawRect: CGRect
                if imageAspect > screenAspect {
                    let scaledWidth = screenSize.height * imageAspect
                    drawRect = CGRect(
                        x: (screenSize.width - scaledWidth) / 2,
                        y: 0,
                        width: scaledWidth,
                        height: screenSize.height
                    )
                } else {
                    let scaledHeight = screenSize.width / imageAspect
                    drawRect = CGRect(
                        x: 0,
                        y: (screenSize.height - scaledHeight) / 2,
                        width: screenSize.width,
                        height: scaledHeight
                    )
                }
                defaultImage.draw(in: drawRect)
            }
            
            // 2. 绘制贴纸（按照屏幕上的实际位置）
            for sticker in placedStickers {
                if let stickerImage = loadImage(sticker.imageName) {
                    context.cgContext.saveGState()
                    
                    // 移动到贴纸位置
                    context.cgContext.translateBy(x: sticker.position.x, y: sticker.position.y)
                    
                    // 应用旋转
                    context.cgContext.rotate(by: CGFloat(sticker.rotation.radians))
                    
                    // 应用缩放
                    context.cgContext.scaleBy(x: sticker.scale, y: sticker.scale)
                    
                    // 绘制贴纸（居中）
                    // 贴纸的基础大小与界面显示一致：150pt
                    let baseStickerSize: CGFloat = 150
                    let rect = CGRect(
                        x: -baseStickerSize / 2,
                        y: -baseStickerSize / 2,
                        width: baseStickerSize,
                        height: baseStickerSize
                    )
                    stickerImage.draw(in: rect)
                    
                    context.cgContext.restoreGState()
                }
            }
        }
    }
    
    // MARK: - Capture Screen (截取画布区域)
    private func captureScreen() -> UIImage {
        // 获取整个屏幕
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let bounds = UIScreen.main.bounds
        
        // 创建截图
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let screenshot = renderer.image { context in
            window?.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        
        return screenshot
    }
    
    // MARK: - Load Image Helper
    private func loadImage(_ imageName: String) -> UIImage? {
        if let image = UIImage(named: imageName) {
            return image
        }
        
        // Try loading from bundle paths
        let paths = [
            "mask/stick/\(theme.id)/\(imageName).png",
            "mask/stick/\(theme.id)/stickers/\(imageName).png"
        ]
        
        for path in paths {
            if let bundlePath = Bundle.main.path(forResource: path.replacingOccurrences(of: ".png", with: ""), ofType: "png"),
               let image = UIImage(contentsOfFile: bundlePath) {
                return image
            }
        }
        
        return nil
    }
}

// MARK: - Draggable Sticker
struct DraggableSticker: View {
    @Binding var sticker: PlacedSticker
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var lastScale: CGFloat = 1.0
    @State private var lastRotation: Angle = .zero
    
    var body: some View {
        MaskImageView(sticker.imageName, contentMode: .fit)
            .frame(width: 150, height: 150)
            .scaleEffect(sticker.scale)
            .rotationEffect(sticker.rotation)
            .position(sticker.position)
            .overlay(
                Group {
                    if isSelected {
                        // Selection Frame
                        ZStack {
                            // Dashed border
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                                )
                                .foregroundColor(.white)
                            
                            // Corner handles
                            ForEach([UnitPoint.topLeading, .topTrailing, .bottomLeading, .bottomTrailing], id: \.self) { corner in
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    .position(
                                        x: corner.x == 0 ? 0 : 150 * sticker.scale,
                                        y: corner.y == 0 ? 0 : 150 * sticker.scale
                                    )
                            }
                        }
                        .frame(width: 150 * sticker.scale, height: 150 * sticker.scale)
                        .position(sticker.position)
                    }
                }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        sticker.position = value.location
                    }
            )
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        sticker.scale = lastScale * value
                    }
                    .onEnded { value in
                        lastScale = sticker.scale
                    }
            )
            .simultaneousGesture(
                RotationGesture()
                    .onChanged { value in
                        sticker.rotation = lastRotation + value
                    }
                    .onEnded { value in
                        lastRotation = sticker.rotation
                    }
            )
            .onTapGesture {
                onTap()
            }
    }
}

// MARK: - Editor Top Bar
struct EditorTopBar: View {
    let onClose: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        HStack {
            // Close Button
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                    )
            }
            
            Spacer()
            
            Text("编辑贴纸")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Save Button
            Button(action: onSave) {
                Text("完成")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Editor Side Toolbar (侧边浮动工具栏)
struct EditorSideToolbar: View {
    let theme: StickerTheme
    @Binding var selectedStickerId: UUID?
    @Binding var isStickerPanelExpanded: Bool
    let onAddSticker: (String) -> Void
    let onChangeBackground: () -> Void
    let onDeleteSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Add Sticker Button
            ToolbarButton(
                icon: "face.smiling",
                color: Color.blue,
                action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isStickerPanelExpanded.toggle()
                    }
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            )
            
            // Change Background Button
            ToolbarButton(
                icon: "photo",
                color: Color.purple,
                action: {
                    onChangeBackground()
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            )
            
            // Delete Selected Button (only show when sticker is selected)
            if selectedStickerId != nil {
                ToolbarButton(
                    icon: "trash",
                    color: Color.red,
                    action: {
                        onDeleteSelected()
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.warning)
                    }
                )
            }
        }
    }
}

// MARK: - Toolbar Button
struct ToolbarButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // 外圈光晕
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 64, height: 64)
                    .blur(radius: 8)
                
                // 主圆形
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 4)
                
                // 图标
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(ToolbarButtonStyle())
    }
}

// MARK: - Toolbar Button Style
struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Sticker Selection Panel (底部抽屉式)
struct StickerSelectionPanel: View {
    let theme: StickerTheme
    let onAddSticker: (String) -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle Bar
            VStack(spacing: 16) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                // Header
                HStack {
                    Text("选择贴纸")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Sticker Grid
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(theme.stickers, id: \.self) { sticker in
                        Button(action: {
                            onAddSticker(sticker)
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            
                            // 添加后自动关闭面板
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onClose()
                            }
                        }) {
                            VStack(spacing: 8) {
                                // Sticker Image - 透明背景
                                ZStack {
                                    // 透明背景，只有边框和阴影
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.clear)
                                    
                                    MaskImageView(sticker, contentMode: .fit)
                                        .padding(16)
                                }
                                .frame(height: 110)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    theme.color.opacity(0.5),
                                                    theme.color.opacity(0.3)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: theme.color.opacity(0.2), radius: 12, x: 0, y: 6)
                            }
                        }
                        .buttonStyle(StickerButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .frame(maxHeight: 500)
        }
        .background(
            ZStack {
                // 半透明毛玻璃背景
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                    .opacity(0.95)
                
                // 顶部微光效果
                VStack {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 30))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: -10)
    }
}

// MARK: - Sticker Button Style
struct StickerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Editor Bottom Toolbar (保留但不使用)
struct EditorBottomToolbar: View {
    let theme: StickerTheme
    @Binding var selectedStickerId: UUID?
    @Binding var isStickerPanelExpanded: Bool
    let onAddSticker: (String) -> Void
    let onChangeBackground: () -> Void
    let onDeleteSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticker Selection Panel (Expandable)
            if isStickerPanelExpanded {
                VStack(spacing: 16) {
                    // Panel Header
                    HStack {
                        Text("选择贴纸")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isStickerPanelExpanded = false
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Sticker Grid
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(theme.stickers, id: \.self) { sticker in
                                Button(action: {
                                    onAddSticker(sticker)
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }) {
                                    MaskImageView(sticker, contentMode: .fit)
                                        .frame(width: 80, height: 80)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 100)
                    .padding(.bottom, 16)
                }
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.8), Color.black.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Main Action Bar
            VStack(spacing: 12) {
                // Action Buttons
                HStack(spacing: 12) {
                    // Sticker Button
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isStickerPanelExpanded.toggle()
                        }
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isStickerPanelExpanded ? "face.smiling.fill" : "face.smiling")
                                .font(.system(size: 16))
                            Text("贴纸")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isStickerPanelExpanded ? Color.blue.opacity(0.3) : Color.white.opacity(0.15))
                        )
                    }
                    
                    // Change Background
                    Button(action: {
                        onChangeBackground()
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                            Text("底图")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.15))
                        )
                    }
                    
                    // Delete Selected
                    if selectedStickerId != nil {
                        Button(action: {
                            onDeleteSelected()
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.warning)
                        }) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.red.opacity(0.3))
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .padding(.bottom, 34)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.7), Color.black.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Save Success Overlay
struct SaveSuccessOverlay: View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Success Animation
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.green)
                }
                
                // Message
                VStack(spacing: 12) {
                    Text("保存成功！")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("作品已保存到相册")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Done Button
                Button(action: onDismiss) {
                    Text("完成")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green)
                        )
                }
                .padding(.top, 16)
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.8)))
    }
}

#Preview {
    StickerEditorView(theme: StickerTheme.sampleThemes[0])
}

