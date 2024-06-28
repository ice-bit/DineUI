//
//  MenuItem.swift
//  Dine
//
//  Created by doss-zstch1212 on 04/01/24.
//

import Foundation
import SQLite3

enum MenuSectionType: String {
    case starter = "Starters"
    case mainCourse = "Main Course"
    case side = "Side"
    case desserts = "Desserts"
    case beverages = "Beverages"
}

class MenuItem {
    let itemId: UUID
    var name: String
    var price: Double
    var count: Int = 0
    let category: MenuCategory
    
    init(itemId: UUID, name: String, price: Double, category: MenuCategory) {
        self.itemId = itemId
        self.name = name
        self.price = price
        self.category = category
    }
    
    convenience init(name: String, price: Double, category: MenuCategory) {
        self.init(itemId: UUID(), name: name, price: price, category: category)
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
            FOREIGN KEY (category_id) REFERENCES \(DatabaseTables.category.rawValue)(id)
        );
        """
    }
}

extension MenuItem: SQLUpdatable {
    var createUpdateStatement: String {
        """
        UPDATE \(DatabaseTables.menuItem.rawValue)
        SET MenuItemID = '\(itemId)', MenuItemName = '\(name)', Price = \(price), category_id = '\(category.id)'
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
        INSERT INTO \(DatabaseTables.menuItem.rawValue) (MenuItemID, MenuItemName, Price, category_id)
        VALUES ('\(itemId)', '\(name)', \(price), '\(category.id)');
        """
    }
}

extension MenuItem: DatabaseParsable {
    static func parseRow(statement: OpaquePointer?) throws -> MenuItem? {
        guard let statement = statement else { return nil }
        guard let itemIdCString = sqlite3_column_text(statement, 0),
              let nameCString = sqlite3_column_text(statement, 1),
              let categoryIdCString = sqlite3_column_text(statement, 3),
              let categoryNameCString = sqlite3_column_text(statement, 4) else {
            throw DatabaseError.missingRequiredValue
        }
        
        let name = String(cString: nameCString)
        let price = sqlite3_column_double(statement, 2)
        let categoryName = String(cString: categoryNameCString)
        
        guard let itemId = UUID(uuidString: String(cString: itemIdCString)),
              let categoryId = UUID(uuidString: String(cString: categoryIdCString)) else {
            throw DatabaseError.conversionFailed
        }
        
        let category = MenuCategory(
            id: categoryId,
            categoryName: categoryName
        )
        
        let menuItem = MenuItem(itemId: itemId, name: name, price: price, category: category)
        return menuItem
    }
}



