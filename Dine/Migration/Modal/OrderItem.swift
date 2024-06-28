//
//  OrderMenuItem.swift
//  Dine
//
//  Created by doss-zstch1212 on 21/03/24.
//

import Foundation
import SQLite3

struct OrderItem {
    let orderID: UUID?
    let menuItemID: UUID
    let menuItemName: String
    let price: Double
    let categoryId: UUID
    let quantity: Int
}
extension OrderItem: SQLTable {
    static var tableName: String {
        DatabaseTables.orderMenuItemTable.rawValue
    }
    
    static var createStatement: String {
        /*CREATE TABLE OrderItem (
         OrderItemID INTEGER PRIMARY KEY,
         OrderID VARCHAR(32) NOT NULL,
         MenuItemID VARCHAR(32) NOT NULL,
         Quantity INT NOT NULL,
         Category VARCHAR(32) NOT NULL,
         FOREIGN KEY (OrderID) REFERENCES Order(OrderID),
         FOREIGN KEY (MenuItemID) REFERENCES MenuItem(MenuItemID)
     );*/
        """
        CREATE TABLE \(DatabaseTables.orderMenuItemTable.rawValue) (
            OrderItemID INTEGER PRIMARY KEY,
            OrderID VARCHAR(32) NOT NULL,
            MenuItemID VARCHAR(32) NOT NULL,
            Quantity INT NOT NULL,
            category_id VARCHAR(32) NOT NULL,
            FOREIGN KEY (OrderID) REFERENCES \(DatabaseTables.orderTable.rawValue)(OrderID),
            FOREIGN KEY (MenuItemID) REFERENCES \(DatabaseTables.menuItem.rawValue)(MenuItemID)
        );
        """
    }
}

extension OrderItem: SQLInsertable {
    var createInsertStatement: String {
        guard let orderID = self.orderID else {
            print("No OrderID found.")
            return ""
        }
        return """
        INSERT INTO \(DatabaseTables.orderMenuItemTable.rawValue) (OrderID, MenuItemID, Quantity, category_id)
        VALUES ('\(orderID.uuidString)', '\(menuItemID.uuidString)', \(quantity), '\(categoryId)');
        """
    }
}

extension OrderItem: SQLUpdatable, SQLDeletable {
    var createUpdateStatement: String {
        guard let orderID else { return String() }
        return """
        UPDATE \(DatabaseTables.orderMenuItemTable.rawValue)
        SET Quantity = \(quantity)
        WHERE OrderID = '\(orderID)' AND MenuItemID = '\(menuItemID)';
        """
    }
    
    var createDeleteStatement: String {
        guard let orderID else { return String() }
        return """
        DELETE FROM \(DatabaseTables.orderMenuItemTable.rawValue)
        WHERE OrderID = '\(orderID)';
        """
    }
}


extension OrderItem: DatabaseParsable {
    static func parseRow(statement: OpaquePointer?) throws -> OrderItem? {
        guard let statement = statement else { return nil }
        guard let itemIdCString = sqlite3_column_text(statement, 0),
              let nameCString = sqlite3_column_text(statement, 1),
              let categoryIdCString = sqlite3_column_text(statement, 4) else {
            throw DatabaseError.missingRequiredValue
        }
        
        let name = String(cString: nameCString)
        let price = sqlite3_column_double(statement, 2)
        
        let quantityPointer = sqlite3_column_int(statement, 3)
        let resultQuantity = Int(quantityPointer)
        guard let itemId = UUID(uuidString: String(cString: itemIdCString)),
              let categoryId = UUID(uuidString: String(cString: categoryIdCString))else {
            throw DatabaseError.conversionFailed
        }
        
        let orderMenuItem = OrderItem(orderID: nil, menuItemID: itemId, menuItemName: name, price: price, categoryId: categoryId, quantity: resultQuantity)
        return orderMenuItem
    }
}
