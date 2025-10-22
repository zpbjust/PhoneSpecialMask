//
//  PhotoLibraryPermissionManager.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/22.
//

import SwiftUI
import Photos

// MARK: - Photo Library Permission Manager
class PhotoLibraryPermissionManager: ObservableObject {
    static let shared = PhotoLibraryPermissionManager()
    
    @Published var showPermissionDeniedAlert = false
    
    private init() {}
    
    // MARK: - Check Permission Status
    func checkPermissionStatus(for accessLevel: PHAccessLevel = .addOnly) -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: accessLevel)
    }
    
    // MARK: - Request Permission and Execute Action
    func requestPermissionAndExecute(
        for accessLevel: PHAccessLevel = .addOnly,
        onAuthorized: @escaping () -> Void,
        onDenied: @escaping () -> Void
    ) {
        let status = checkPermissionStatus(for: accessLevel)
        
        switch status {
        case .notDetermined:
            // First time - Request system permission
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        onAuthorized()
                    } else {
                        onDenied()
                    }
                }
            }
            
        case .authorized, .limited:
            // Already authorized - Execute directly
            onAuthorized()
            
        case .denied, .restricted:
            // Denied - Show guide to settings
            onDenied()
            
        @unknown default:
            onDenied()
        }
    }
    
    // MARK: - Save Image to Photo Library
    func saveImage(
        _ image: UIImage,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (String) -> Void
    ) {
        requestPermissionAndExecute(
            onAuthorized: {
                // Save image
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                
                DispatchQueue.main.async {
                    onSuccess()
                }
            },
            onDenied: {
                DispatchQueue.main.async {
                    onFailure("需要相册权限才能保存图片")
                }
            }
        )
    }
    
    // MARK: - Open Settings
    static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Permission Denied Guide View
struct PermissionDeniedGuideView: View {
    let title: String
    let message: String
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
                // Warning Icon
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(message)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Guide Steps
                VStack(alignment: .leading, spacing: 20) {
                    Text("如何开启相册权限？")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    PermissionGuideStepView(
                        number: "1",
                        icon: "gear",
                        title: "打开\"设置\"",
                        description: "点击下方按钮前往系统设置"
                    )
                    
                    PermissionGuideStepView(
                        number: "2",
                        icon: "apps.iphone",
                        title: "找到本应用",
                        description: "在设置中找到\"专用手机壳\""
                    )
                    
                    PermissionGuideStepView(
                        number: "3",
                        icon: "photo",
                        title: "开启\"照片\"权限",
                        description: "允许访问相册以保存图片"
                    )
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                )
                .padding(.horizontal, 20)
                
                // Action Buttons
                VStack(spacing: 12) {
                    // Open Settings Button
                    Button(action: {
                        PhotoLibraryPermissionManager.openSettings()
                        onDismiss()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "gear")
                                .font(.system(size: 18))
                            Text("前往设置")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.orange)
                        )
                    }
                    
                    // Dismiss Button
                    Button(action: onDismiss) {
                        Text("稍后再说")
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

// MARK: - Permission Guide Step View
struct PermissionGuideStepView: View {
    let number: String
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Step Number
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(number)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.orange)
            }
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.orange)
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

// MARK: - View Extension for Easy Permission Handling
extension View {
    func withPhotoLibraryPermission(
        showDeniedGuide: Binding<Bool>,
        title: String = "需要相册权限",
        message: String = "请在设置中允许访问相册，以便保存图片"
    ) -> some View {
        self.overlay(
            Group {
                if showDeniedGuide.wrappedValue {
                    PermissionDeniedGuideView(
                        title: title,
                        message: message,
                        onDismiss: {
                            showDeniedGuide.wrappedValue = false
                        }
                    )
                }
            }
        )
    }
}

#Preview {
    PermissionDeniedGuideView(
        title: "需要相册权限",
        message: "请在设置中允许访问相册，以便保存图片",
        onDismiss: {}
    )
}

