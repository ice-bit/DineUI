//
//  MenuItem.swift
//  Dine
//
//  Created by doss-zstch1212 on 04/01/24.
//

import UIKit
import SQLite3

class MenuItem: ObservableObject {
    let itemId: UUID
    @Published var name: String
    @Published var price: Double
    @Published var count: Int = 0
    var category: MenuCategory
    @Published var description: String
    
    var image: UIImage? {
        didSet {
            saveImage()
        }
    }
    
    var renderedImage: UIImage? {
        get {
            loadImage()
        }
    }
    
    var imageURL: URL? {
        getImageURL()
    }
    
    init(itemId: UUID, name: String, price: Double, category: MenuCategory, description: String) {
        self.itemId = itemId
        self.name = name
        self.price = price
        self.category = category
        self.description = description
    }
    
    convenience init(name: String, price: Double, category: MenuCategory, description: String) {
        self.init(itemId: UUID(), name: name, price: price, category: category, description: description)
    }
    
    convenience init(name: String, price: Double, category: MenuCategory, description: String, image: UIImage) {
        self.init(itemId: UUID(), name: name, price: price, category: category, description: description)
        self.image = image
        saveImage()
    }
    
    convenience init(itemId: UUID, name: String, price: Double, category: MenuCategory, description: String, image: UIImage) {
        self.init(itemId: itemId, name: name, price: price, category: category, description: description)
        self.image = image
        saveImage()
    }
    
    private func getImageURL() -> URL? {
        let fileName = itemId.uuidString
        let fileURL = getDocumentsDirectory().appending(path: "\(fileName).png")
        return fileURL
    }
    
    func saveImage() {
        guard let image else {
            fatalError("Unexpectedily found nil while unwrapping")
        }
        
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            fatalError("Error compressing image")
        }
        
        let fileName = itemId.uuidString
        let fileURL = getDocumentsDirectory().appending(path: "\(fileName).png")
        
        do {
            try data.write(to: fileURL)
            print("Image saved successfully at \(fileURL)")
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension MenuItem {
    func loadImage() -> UIImage? {
        let cache = ImageCacheManager.shared.cache
        
        if let imageFromCache = cache.object(forKey: self.itemId.uuidString as NSString) {
            print("Image rendered from cache")
            return imageFromCache
        }
        
        guard var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to construct URL")
            return nil
        }
        fileURL.appendPathComponent("\(self.itemId.uuidString).png")
        print("FileURL: \(fileURL)")
        
        do {
            let data = try Data(contentsOf: fileURL)
            guard let imageToCache = UIImage(data: data) else {
                fatalError("Failed to create UIImage")
            }
            cache.setObject(imageToCache, forKey: self.itemId.uuidString as NSString)
            image = imageToCache // set the image
            return imageToCache
        } catch {
            fatalError("🔨 Failed to load assets from files: \(error)")
        }
    }
}

extension UIImageView {
    func loadImageFromCache(for itemId: UUID) {
        let cache = ImageCacheManager.shared.cache
        if let imageFromCache = cache.object(forKey: itemId.uuidString as NSString) {
            print("Image rendered from cache")
            self.image = imageFromCache
        }
    }
}

extension MenuItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(itemId)
    }
    
    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        return lhs.itemId == rhs.itemId
    }
}

extension MenuItem: Parsable {}

extension MenuItem: SQLTable {
    static var tableName: String {
        DatabaseTables.menuItem.rawValue
    }
    
    static var createStatement: String {
        """
        CREATE TABLE \(DatabaseTables.menuItem.rawValue) (
            MenuItemID TEXT PRIMARY KEY,
            MenuItemName TEXT NOT NULL,
            Price REAL NOT NULL,
            category_id VARCHAR(32),
            description VARCHAR(255),
            imageURL VARCHAR(255),
            FOREIGN KEY (category_id) REFERENCES \(DatabaseTables.category.rawValue)(id)
        );
        """
    }
}

extension MenuItem: SQLUpdatable {
    var createUpdateStatement: String {
        """
        UPDATE \(DatabaseTables.menuItem.rawValue)
        SET MenuItemID = '\(itemId)', MenuItemName = '\(name)', Price = \(price), category_id = '\(category.id)', description = '\(description)'
        WHERE MenuItemID = '\(itemId)';
        """
    }
}

extension MenuItem: SQLDeletable {
    var createDeleteStatement: String {
        "DELETE FROM \(DatabaseTables.menuItem.rawValue) WHERE MenuItemID = '\(itemId)'"
    }
}

extension MenuItem: SQLInsertable {
    var createInsertStatement: String {
        """
        INSERT INTO \(DatabaseTables.menuItem.rawValue) (MenuItemID, MenuItemName, Price, category_id, description)
        VALUES ('\(itemId)', '\(name)', \(price), '\(category.id)', '\(description)');
        """
    }
}

extension MenuItem: DatabaseParsable {
    static func parseRow(statement: OpaquePointer?) throws -> MenuItem? {
        guard let statement = statement else { return nil }
        guard let itemIdCString = sqlite3_column_text(statement, 0),
              let nameCString = sqlite3_column_text(statement, 1),
              let descriptionCString = sqlite3_column_text(statement, 3),
              let categoryIdCString = sqlite3_column_text(statement, 4),
              let categoryNameCString = sqlite3_column_text(statement, 5) else {
            throw DatabaseError.missingRequiredValue
        }
        
        let name = String(cString: nameCString)
        let price = sqlite3_column_double(statement, 2)
        let categoryName = String(cString: categoryNameCString)
        let description = String(cString: descriptionCString)
        
        guard let itemId = UUID(uuidString: String(cString: itemIdCString)),
              let categoryId = UUID(uuidString: String(cString: categoryIdCString)) else {
            throw DatabaseError.conversionFailed
        }
        
        let category = MenuCategory(
            id: categoryId,
            categoryName: categoryName
        )
        
        let menuItem = MenuItem(itemId: itemId, name: name, price: price, category: category, description: description)
        return menuItem
    }
}



