//
//  MyWorksManager.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/23.
//

import SwiftUI
import UIKit

// MARK: - My Work Model
struct MyWork: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let createdAt: Date
    let thumbnailFileName: String?
    
    init(id: UUID = UUID(), fileName: String, createdAt: Date = Date(), thumbnailFileName: String? = nil) {
        self.id = id
        self.fileName = fileName
        self.createdAt = createdAt
        self.thumbnailFileName = thumbnailFileName
    }
}

// MARK: - My Works Manager
class MyWorksManager: ObservableObject {
    static let shared = MyWorksManager()
    
    @Published var works: [MyWork] = []
    
    private let worksDirectory: URL
    private let metadataFile: URL
    
    private init() {
        // 创建作品目录
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.worksDirectory = documentsPath.appendingPathComponent("MyWorks", isDirectory: true)
        self.metadataFile = worksDirectory.appendingPathComponent("metadata.json")
        
        // 创建目录（如果不存在）
        try? FileManager.default.createDirectory(at: worksDirectory, withIntermediateDirectories: true)
        
        // 加载已有作品
        loadWorks()
    }
    
    // MARK: - Save Work
    func saveWork(image: UIImage, completion: @escaping (Result<MyWork, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                // 生成文件名（使用时间戳）
                let timestamp = Date().timeIntervalSince1970
                let fileName = "work_\(Int(timestamp)).jpg"
                let fileURL = self.worksDirectory.appendingPathComponent(fileName)
                
                // 保存原图
                guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                    throw NSError(domain: "MyWorksManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
                }
                try imageData.write(to: fileURL)
                
                // 生成缩略图 - 使用屏幕比例（竖屏手机比例）
                let thumbnailFileName = "thumb_\(Int(timestamp)).jpg"
                let thumbnailURL = self.worksDirectory.appendingPathComponent(thumbnailFileName)
                // 使用手机屏幕比例生成缩略图
                let screenAspect = UIScreen.main.bounds.width / UIScreen.main.bounds.height
                let thumbnailSize = CGSize(width: 600, height: 600 / screenAspect)  // 保持屏幕比例
                if let thumbnail = self.createThumbnail(from: image, size: thumbnailSize) {
                    if let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) {
                        try thumbnailData.write(to: thumbnailURL)
                    }
                }
                
                // 创建作品记录
                let work = MyWork(fileName: fileName, thumbnailFileName: thumbnailFileName)
                
                // 保存元数据
                DispatchQueue.main.async {
                    self.works.insert(work, at: 0)  // 最新的在前面
                    self.saveMetadata()
                    completion(.success(work))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Load Work Image
    func loadWorkImage(_ work: MyWork, useThumbnail: Bool = false) -> UIImage? {
        let fileName = useThumbnail ? (work.thumbnailFileName ?? work.fileName) : work.fileName
        let fileURL = worksDirectory.appendingPathComponent(fileName)
        
        guard let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            return nil
        }
        
        return image
    }
    
    // MARK: - Delete Work
    func deleteWork(_ work: MyWork) {
        // 删除文件
        let fileURL = worksDirectory.appendingPathComponent(work.fileName)
        try? FileManager.default.removeItem(at: fileURL)
        
        // 删除缩略图
        if let thumbnailFileName = work.thumbnailFileName {
            let thumbnailURL = worksDirectory.appendingPathComponent(thumbnailFileName)
            try? FileManager.default.removeItem(at: thumbnailURL)
        }
        
        // 更新列表
        works.removeAll { $0.id == work.id }
        saveMetadata()
    }
    
    // MARK: - Private Methods
    
    private func loadWorks() {
        guard let data = try? Data(contentsOf: metadataFile),
              let loadedWorks = try? JSONDecoder().decode([MyWork].self, from: data) else {
            return
        }
        
        self.works = loadedWorks
    }
    
    private func saveMetadata() {
        guard let data = try? JSONEncoder().encode(works) else { return }
        try? data.write(to: metadataFile)
    }
    
    private func createThumbnail(from image: UIImage, size: CGSize) -> UIImage? {
        // 计算 aspectFill 的绘制区域（保持比例，填满目标尺寸）
        let imageAspect = image.size.width / image.size.height
        let targetAspect = size.width / size.height
        
        var drawRect: CGRect
        if imageAspect > targetAspect {
            // 图片更宽，按高度缩放
            let scaledWidth = size.height * imageAspect
            drawRect = CGRect(
                x: (size.width - scaledWidth) / 2,
                y: 0,
                width: scaledWidth,
                height: size.height
            )
        } else {
            // 图片更高，按宽度缩放
            let scaledHeight = size.width / imageAspect
            drawRect = CGRect(
                x: 0,
                y: (size.height - scaledHeight) / 2,
                width: size.width,
                height: scaledHeight
            )
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // 裁剪到目标尺寸
            UIRectClip(CGRect(origin: .zero, size: size))
            // 绘制图片（保持比例）
            image.draw(in: drawRect)
        }
    }
}

