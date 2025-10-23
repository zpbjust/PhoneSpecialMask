//
//  Models.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/22.
//

import Foundation
import SwiftUI

// MARK: - Wallpaper Model
struct Wallpaper: Identifiable, Hashable {
    let id: String
    let imageName: String
    let title: String
    let description: String
    let category: WallpaperCategory
    
    var image: String {
        imageName
    }
}

enum WallpaperCategory: String, CaseIterable {
    case all = "全部"
    case nature = "自然"
    case abstract = "抽象"
    case gradient = "渐变"
}

// MARK: - Sticker Theme Model
struct StickerTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    let mainImage: String
    let stickers: [String]
    let suitableScene: String
    let color: Color
    
    var stickerCount: Int {
        stickers.count
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

// MARK: - Sample Data
extension Wallpaper {
    static let sampleWallpapers: [Wallpaper] = [
        Wallpaper(id: "1", imageName: "pager_01", title: "海浪渐变", description: "蓝色海浪渐变设计，底部波浪造型自然遮挡", category: .nature),
        Wallpaper(id: "2", imageName: "pager_02", title: "日落余晖", description: "温暖的日落色调，渐变效果柔和", category: .nature),
        Wallpaper(id: "3", imageName: "pager_03", title: "樱花飘落", description: "粉色樱花元素，春天气息浓郁", category: .nature),
        Wallpaper(id: "4", imageName: "pager_04", title: "夜空月亮", description: "深邃夜空搭配明月，神秘感十足", category: .nature),
        Wallpaper(id: "5", imageName: "pager_05", title: "闪电能量", description: "动感闪电设计，充满活力", category: .abstract),
        Wallpaper(id: "6", imageName: "pager_06", title: "几何图案", description: "现代几何设计，简约大方", category: .abstract),
        Wallpaper(id: "7", imageName: "pager_07", title: "流体艺术", description: "流动的色彩，艺术感满满", category: .abstract),
        Wallpaper(id: "8", imageName: "pager_08", title: "极光炫彩", description: "如极光般的炫彩效果", category: .gradient),
        Wallpaper(id: "9", imageName: "pager_09", title: "紫色梦境", description: "梦幻紫色渐变，浪漫优雅", category: .gradient),
        Wallpaper(id: "10", imageName: "pager_10", title: "橙色暖阳", description: "温暖橙色调，充满阳光气息", category: .gradient),
        Wallpaper(id: "11", imageName: "pager_11", title: "青色清新", description: "清新青色，宁静舒适", category: .gradient),
        Wallpaper(id: "12", imageName: "pager_12", title: "玫瑰金", description: "高级玫瑰金色调", category: .gradient),
        Wallpaper(id: "13", imageName: "pager_13", title: "薄荷绿", description: "清凉薄荷绿，夏日首选", category: .gradient),
        Wallpaper(id: "14", imageName: "pager_14", title: "深海蓝", description: "深邃海洋蓝，沉静内敛", category: .nature),
        Wallpaper(id: "15", imageName: "pager_15", title: "星空璀璨", description: "璀璨星空，浪漫唯美", category: .nature),
        Wallpaper(id: "16", imageName: "pager_16", title: "彩虹光谱", description: "彩虹色彩，活力四射", category: .abstract)
    ]
}

extension StickerTheme {
    static let sampleThemes: [StickerTheme] = [
        StickerTheme(
            id: "bear",
            name: "熊",
            emoji: "🐻",
            description: "可爱温馨",
            mainImage: "bear_main",
            stickers: ["bear_sticker_01", "bear_sticker_02", "bear_sticker_03"],
            suitableScene: "温馨照片、儿童风格",
            color: .brown
        ),
        StickerTheme(
            id: "cat",
            name: "猫",
            emoji: "🐱",
            description: "俏皮灵动",
            mainImage: "cat_main",
            stickers: ["cat_sticker_01", "cat_sticker_02", "cat_sticker_03"],
            suitableScene: "猫奴、宠物照片",
            color: .orange
        ),
        StickerTheme(
            id: "cloud",
            name: "云朵",
            emoji: "☁️",
            description: "清新自然",
            mainImage: "cloud_main",
            stickers: ["cloud_sticker_01", "cloud_sticker_02", "cloud_sticker_03"],
            suitableScene: "天空、风景照",
            color: .blue
        ),
        StickerTheme(
            id: "energy",
            name: "能量",
            emoji: "⚡",
            description: "科技动感",
            mainImage: "energy_main",
            stickers: ["energy_sticker_01", "energy_sticker_02", "energy_sticker_03"],
            suitableScene: "运动、科技主题",
            color: .yellow
        ),
        StickerTheme(
            id: "kite",
            name: "风筝",
            emoji: "🪁",
            description: "文艺清新",
            mainImage: "kite_main",
            stickers: ["kite_sticker_01", "kite_sticker_02", "kite_sticker_03"],
            suitableScene: "春天、户外照片",
            color: .pink
        ),
        StickerTheme(
            id: "mask",
            name: "面具",
            emoji: "🎭",
            description: "神秘艺术",
            mainImage: "mask_main",
            stickers: ["mask_sticker_01", "mask_sticker_02", "mask_sticker_03"],
            suitableScene: "艺术照、个性风格",
            color: .purple
        ),
        StickerTheme(
            id: "penguin",
            name: "企鹅",
            emoji: "🐧",
            description: "呆萌可爱",
            mainImage: "penguin_main",
            stickers: ["penguin_sticker_01", "penguin_sticker_02", "penguin_sticker_03"],
            suitableScene: "冬季、冰雪场景",
            color: .cyan
        ),
        StickerTheme(
            id: "pixel",
            name: "像素",
            emoji: "🎨",
            description: "复古游戏",
            mainImage: "pixel_main",
            stickers: ["pixel_sticker_01", "pixel_sticker_02"],
            suitableScene: "怀旧、极简风格",
            color: .indigo
        ),
        StickerTheme(
            id: "totoro",
            name: "龙猫",
            emoji: "🌿",
            description: "治愈温暖",
            mainImage: "totoro_main",
            stickers: ["totoro_sticker_01"],
            suitableScene: "动漫风、绿色主题",
            color: .green
        )
    ]
}

