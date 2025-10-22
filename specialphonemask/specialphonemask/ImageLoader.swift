//
//  ImageLoader.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/22.
//

import SwiftUI

extension Image {
    /// Load image from mask folder
    static func maskImage(_ name: String) -> Image {
        // Try to load from Assets first
        if UIImage(named: name) != nil {
            return Image(name)
        }
        
        // Try to load from mask folder
        let paths = [
            "mask/pager/\(name)",
            "mask/stick/bear/\(name)",
            "mask/stick/cat/\(name)",
            "mask/stick/cloud/\(name)",
            "mask/stick/energy/\(name)",
            "mask/stick/kite/\(name)",
            "mask/stick/mask/\(name)",
            "mask/stick/penguin/\(name)",
            "mask/stick/pixel/\(name)",
            "mask/stick/totoro/\(name)",
            "mask/stick/bear/stickers/\(name)",
            "mask/stick/cat/stickers/\(name)",
            "mask/stick/cloud/stickers/\(name)",
            "mask/stick/energy/stickers/\(name)",
            "mask/stick/kite/stickers/\(name)",
            "mask/stick/mask/stickers/\(name)",
            "mask/stick/penguin/stickers/\(name)",
            "mask/stick/pixel/stickers/\(name)",
            "mask/stick/totoro/stickers/\(name)"
        ]
        
        for path in paths {
            if let bundle = Bundle.main.path(forResource: "\(path)", ofType: "png"),
               let uiImage = UIImage(contentsOfFile: bundle) {
                return Image(uiImage: uiImage)
            }
        }
        
        // Fallback to system image
        return Image(systemName: "photo")
    }
}

// Custom Image View for better error handling
struct MaskImageView: View {
    let imageName: String
    let contentMode: ContentMode
    
    init(_ imageName: String, contentMode: ContentMode = .fill) {
        self.imageName = imageName
        self.contentMode = contentMode
    }
    
    var body: some View {
        GeometryReader { geometry in
            if let uiImage = loadImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            } else {
            // Placeholder
            ZStack {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(imageName)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
    }
    
    private func loadImage() -> UIImage? {
        // Try to load from Assets first
        if let image = UIImage(named: imageName) {
            return image
        }
        
        // Try to load from bundle with different paths
        let possiblePaths = [
            "mask/pager/\(imageName).png",
            "mask/stick/bear/\(imageName).png",
            "mask/stick/cat/\(imageName).png",
            "mask/stick/cloud/\(imageName).png",
            "mask/stick/energy/\(imageName).png",
            "mask/stick/kite/\(imageName).png",
            "mask/stick/mask/\(imageName).png",
            "mask/stick/penguin/\(imageName).png",
            "mask/stick/pixel/\(imageName).png",
            "mask/stick/totoro/\(imageName).png",
            "mask/stick/bear/stickers/\(imageName).png",
            "mask/stick/cat/stickers/\(imageName).png",
            "mask/stick/cloud/stickers/\(imageName).png",
            "mask/stick/energy/stickers/\(imageName).png",
            "mask/stick/kite/stickers/\(imageName).png",
            "mask/stick/mask/stickers/\(imageName).png",
            "mask/stick/penguin/stickers/\(imageName).png",
            "mask/stick/pixel/stickers/\(imageName).png",
            "mask/stick/totoro/stickers/\(imageName).png"
        ]
        
        for path in possiblePaths {
            if let bundlePath = Bundle.main.path(forResource: path.replacingOccurrences(of: ".png", with: ""), ofType: "png"),
               let image = UIImage(contentsOfFile: bundlePath) {
                return image
            }
        }
        
        return nil
    }
}

