//
//  UIImageView+cacheImage.swift
//  Dine
//
//  Created by doss-zstch1212 on 15/07/24.
//

import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private init() {}
    
    let cache = NSCache<NSString, UIImage>()
}

extension UIImageView {
    func cacheImage(for uuid: UUID) {
        let cache = ImageCacheManager.shared.cache
        
        image = nil
        
        if let imageFromCache = cache.object(forKey: uuid.uuidString as NSString) {
            self.image = imageFromCache
            print("Image rendered from cache")
            return
        }
        
        guard var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to construct URL")
            return
        }
        fileURL.append(component: "\(uuid.uuidString).png")
        print("FileURL: \(fileURL)")
        
        do {
            let data = try Data(contentsOf: fileURL)
            guard let imageToCache = UIImage(data: data) else {
                fatalError("Failed to create UIImage")
            }
            cache.setObject(imageToCache, forKey: uuid.uuidString as NSString)
            self.image = imageToCache
        } catch {
            fatalError("🔨 Failed to load assets from files: \(error)")
        }
    }
}
