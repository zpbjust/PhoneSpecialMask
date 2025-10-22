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
            
            // Bottom Toolbar
            VStack {
                Spacer()
                
                EditorBottomToolbar(
                    theme: theme,
                    selectedStickerId: $selectedStickerId,
                    isStickerPanelExpanded: $isStickerPanelExpanded,
                    onAddSticker: { stickerName in
                        addSticker(stickerName)
                    },
                    onChangeBackground: {
                        showImagePicker = true
                    },
                    onDeleteSelected: {
                        if let selectedId = selectedStickerId {
                            placedStickers.removeAll { $0.id == selectedId }
                            selectedStickerId = nil
                        }
                    }
                )
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $photoPickerItem, matching: .images)
        .onChange(of: photoPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    backgroundImage = image
                }
            }
        }
        .ignoresSafeArea()
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
    
    // MARK: - Save Composite Image
    private func saveCompositeImage() {
        let renderer = UIGraphicsImageRenderer(size: UIScreen.main.bounds.size)
        
        let compositeImage = renderer.image { context in
            // Draw background
            if let backgroundImage = backgroundImage {
                backgroundImage.draw(in: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
            } else if let defaultImage = loadImage(theme.mainImage) {
                defaultImage.draw(in: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
            }
            
            // Draw stickers
            for sticker in placedStickers {
                if let stickerImage = loadImage(sticker.imageName) {
                    context.cgContext.saveGState()
                    
                    // Transform context
                    context.cgContext.translateBy(x: sticker.position.x, y: sticker.position.y)
                    context.cgContext.rotate(by: CGFloat(sticker.rotation.radians))
                    context.cgContext.scaleBy(x: sticker.scale, y: sticker.scale)
                    
                    // Draw sticker centered
                    let stickerSize: CGFloat = 150
                    let rect = CGRect(
                        x: -stickerSize / 2,
                        y: -stickerSize / 2,
                        width: stickerSize,
                        height: stickerSize
                    )
                    stickerImage.draw(in: rect)
                    
                    context.cgContext.restoreGState()
                }
            }
        }
        
        // Save to photo library
        UIImageWriteToSavedPhotosAlbum(compositeImage, nil, nil, nil)
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Close editor
        dismiss()
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

// MARK: - Editor Bottom Toolbar
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

#Preview {
    StickerEditorView(theme: StickerTheme.sampleThemes[0])
}

