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
                
                // 生成缩略图 - 保持原图比例
                let thumbnailFileName = "thumb_\(Int(timestamp)).jpg"
                let thumbnailURL = self.worksDirectory.appendingPathComponent(thumbnailFileName)
                // 使用较小尺寸，但保持原图比例
                if let thumbnail = self.createThumbnail(from: image, maxSize: 800) {
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
    
    // 生成缩略图 - 保持原图比例
    private func createThumbnail(from image: UIImage, maxSize: CGFloat) -> UIImage? {
        let size = image.size
        
        // 计算缩放比例（保持原始比例）
        let scale: CGFloat
        if size.width > size.height {
            // 横图：按宽度缩放
            scale = maxSize / size.width
        } else {
            // 竖图：按高度缩放
            scale = maxSize / size.height
        }
        
        // 如果图片已经很小，不需要缩放
        if scale >= 1.0 {
            return image
        }
        
        // 计算新尺寸（保持原始比例）
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        // 生成缩略图
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

