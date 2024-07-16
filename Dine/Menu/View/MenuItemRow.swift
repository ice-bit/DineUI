//
//  MenuItemRow.swift
//  Dine
//
//  Created by doss-zstch1212 on 23/05/24.
//

import SwiftUI

struct MenuItemRow: View {
    @ObservedObject var menuItem: MenuItem
    @State var uiImage: UIImage? = nil
    
    var body: some View {
        HStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 10))
                    .frame(width: 75, height: 75)
            } else {
                ProgressView()
                    .frame(width: 75, height: 75)
                    .clipShape(.rect(cornerRadius: 10))
                    .background(Color(.tertiarySystemGroupedBackground))
                    .onAppear {
                        loadImage()
                    }
            }
            
            VStack(alignment: .leading) {
                Image(systemName: "square.dashed")
                    .font(.caption)
                
                Text("\(menuItem.name)")
                    .font(.headline)
                
                Text("$" + String(format: "%.2f", menuItem.price))
                    .font(.subheadline)
                
                Text(menuItem.description)
                    .font(.caption)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

extension MenuItemRow {
    private func loadImage() {
        let cache = ImageCacheManager.shared.cache
        
        if let imageFromCache = cache.object(forKey: menuItem.itemId.uuidString as NSString) {
            uiImage = imageFromCache
            print("Image rendered from cache")
            return
        }
        
        guard var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to construct URL")
            return
        }
        fileURL.appendPathComponent("\(menuItem.itemId.uuidString).png")
        print("FileURL: \(fileURL)")
        
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: fileURL)
                guard let imageToCache = UIImage(data: data) else {
                    fatalError("Failed to create UIImage")
                }
                cache.setObject(imageToCache, forKey: menuItem.itemId.uuidString as NSString)
                DispatchQueue.main.async {
                    self.uiImage = imageToCache
                }
            } catch {
                fatalError("🔨 Failed to load assets from files: \(error)")
            }
        }
    }
}
