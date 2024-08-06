//
//  MenuDetailView.swift
//  Dine
//
//  Created by doss-zstch1212 on 04/06/24.
//
import SwiftUI

struct MenuDetailView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isLandscape: Bool { verticalSizeClass == .compact }
    var menuItem: MenuItem
    @State var uiImage: UIImage? = nil
    
    var body: some View {
        ScrollView {
            if isLandscape {
                MenuDetailCompactView(menuItem: menuItem, uiImage: uiImage)
            } else {
                MenuDetailRegularView(menuItem: menuItem, uiImage: uiImage)
            }
        }
    }
}

struct MenuDetailRegularView: View {
    var menuItem: MenuItem
    @State var uiImage: UIImage? = nil
    
    var body: some View {
        VStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(.rect(cornerRadius: 30))
            } else {
                ProgressView()
                    .frame(width: 75, height: 75)
                    .clipShape(.rect(cornerRadius: 10))
                    .background(Color(.tertiarySystemGroupedBackground))
                    .onAppear {
                        loadImage()
                    }
            }
            
            Text(menuItem.name)
                .font(.title)
            
            Text("$\(String(menuItem.price))")
                .font(.title3)
            
            VStack {
                Text("About")
                    .font(.headline)
                
                Text(menuItem.description)
                    .frame(maxWidth: 300)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

struct MenuDetailCompactView: View {
    var menuItem: MenuItem
    @State var uiImage: UIImage? = nil

    var body: some View {
        HStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(.rect(cornerRadius: 30))
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
                Text(menuItem.name)
                    .font(.largeTitle)

                Text("$\(String(menuItem.price))")
                    .font(.title3)

                Text("About")
                    .font(.headline)
                
                Text(menuItem.description)
                    .frame(maxWidth: 300)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
    }
}

extension MenuDetailRegularView {
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

extension MenuDetailCompactView {
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
