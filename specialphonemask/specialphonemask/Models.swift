//
//  Models.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/22.
//

import Foundation
import SwiftUI

// MARK: - Wallpaper Model
struct Wallpaper: Identifiable, Hashable, Codable {
    let id: String
    let imageName: String
    let title: String
    let description: String
    let category: WallpaperCategory
    let isPremium: Bool
    
    var image: String {
        imageName
    }
}

enum WallpaperCategory: String, CaseIterable, Codable {
    case all = "all"
    case nature = "nature"
    case abstract = "abstract"
    case gradient = "gradient"
    
    var displayName: String {
        switch self {
        case .all: return "全部"
        case .nature: return "自然"
        case .abstract: return "抽象"
        case .gradient: return "渐变"
        }
    }
}

// MARK: - Sticker Theme Model
struct StickerTheme: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    let mainImage: String
    let stickers: [String]
    let suitableScene: String
    let colorName: String
    let isPremium: Bool
    
    var stickerCount: Int {
        stickers.count
    }
    
    var color: Color {
        switch colorName.lowercased() {
        case "brown": return .brown
        case "orange": return .orange
        case "blue": return .blue
        case "yellow": return .yellow
        case "pink": return .pink
        case "purple": return .purple
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "green": return .green
        default: return .gray
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, emoji, description, mainImage, stickers, suitableScene, isPremium
        case colorName = "color"
    }
}

// MARK: - Tab Type
enum HomeTab: String, CaseIterable {
    case wallpapers = "快速壁纸"
    case stickers = "贴纸主题"
    case myWorks = "我的"
    
    var icon: String {
        switch self {
        case .wallpapers:
            return "photo.stack.fill"
        case .stickers:
            return "face.smiling.fill"
        case .myWorks:
            return "heart.text.square.fill"
        }
    }
}

// MARK: - Resource Loader
class ResourceLoader {
    static let shared = ResourceLoader()
    
    private init() {}
    
    private struct ResourceData: Codable {
        let wallpapers: [Wallpaper]
        let stickerThemes: [StickerTheme]
    }
    
    private var cachedData: ResourceData?
    
    private func loadResources() -> ResourceData {
        // Return cached data if available
        if let cached = cachedData {
            return cached
        }
        
        // Try multiple paths to find the JSON file
        var url: URL?
        
        // Method 1: Try with subdirectory
        url = Bundle.main.url(forResource: "resources", withExtension: "json", subdirectory: "mask")
        if url == nil {
            // Method 2: Try without subdirectory
            url = Bundle.main.url(forResource: "mask/resources", withExtension: "json")
        }
        if url == nil {
            // Method 3: Try direct path
            url = Bundle.main.url(forResource: "resources", withExtension: "json")
        }
        
        guard let jsonURL = url else {
            print("❌ Failed to find resources.json in bundle")
            print("📦 Bundle path: \(Bundle.main.bundlePath)")
            if let resourcePath = Bundle.main.resourcePath {
                print("📂 Resource path: \(resourcePath)")
                // List files in resource path
                if let files = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                    print("📄 Files in bundle: \(files.prefix(10))")
                }
            }
            return ResourceData(wallpapers: [], stickerThemes: [])
        }
        
        print("✅ Found resources.json at: \(jsonURL.path)")
        
        guard let data = try? Data(contentsOf: jsonURL) else {
            print("❌ Failed to read data from resources.json")
            return ResourceData(wallpapers: [], stickerThemes: [])
        }
        
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(ResourceData.self, from: data)
            print("✅ Successfully loaded \(decoded.wallpapers.count) wallpapers and \(decoded.stickerThemes.count) sticker themes")
            cachedData = decoded
            return decoded
        } catch {
            print("❌ Failed to decode resources.json: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("  - Missing key: \(key.stringValue) at \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("  - Type mismatch: expected \(type) at \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("  - Value not found: \(type) at \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("  - Data corrupted at \(context.codingPath)")
                @unknown default:
                    print("  - Unknown decoding error")
                }
            }
            return ResourceData(wallpapers: [], stickerThemes: [])
        }
    }
    
    var wallpapers: [Wallpaper] {
        loadResources().wallpapers
    }
    
    var stickerThemes: [StickerTheme] {
        loadResources().stickerThemes
    }
}

// MARK: - Sample Data (for backward compatibility)
extension Wallpaper {
    static var sampleWallpapers: [Wallpaper] {
        ResourceLoader.shared.wallpapers
    }
}

extension StickerTheme {
    static var sampleThemes: [StickerTheme] {
        ResourceLoader.shared.stickerThemes
    }
}

