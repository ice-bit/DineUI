//
//  MenuCategory.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/06/24.
//

import Foundation
import SQLite3

struct MenuCategory {
    let id: UUID
    let categoryName: String
}

extension MenuCategory: SQLTable {
    static var createStatement: String {
        """
        CREATE TABLE IF NOT EXISTS \(DatabaseTables.category.rawValue) (
            id VARCHAR(32) PRIMARY KEY,
            name TEXT NOT NULL
        );
        """
    }

    static var tableName: String {
        DatabaseTables.category.rawValue
    }
}

extension MenuCategory: SQLUpdatable {
    var createUpdateStatement: String {
        """
        UPDATE \(DatabaseTables.category.rawValue)
        SET id = '\(id)', name = '\(categoryName)'
        WHERE id = '\(id)'
        """
    }
}

extension MenuCategory: SQLInsertable {
    var createInsertStatement: String {
        """
        INSERT INTO \(DatabaseTables.category.rawValue) (id, name)
        VALUES ('\(id.uuidString)', '\(categoryName)');
        """
    }
}

extension MenuCategory: SQLDeletable {
    var createDeleteStatement: String {
        "DELETE FROM \(DatabaseTables.category.rawValue) WHERE id = '\(id)';"
    }
}

extension MenuCategory: DatabaseParsable {
    static func parseRow(statement: OpaquePointer?) throws -> MenuCategory? {
        guard let statement = statement else { return nil }
        guard let idCString = sqlite3_column_text(statement, 0),
              let nameCString = sqlite3_column_text(statement, 1) else {
            throw DatabaseError.missingRequiredValue
        }
        
        guard let id = UUID(uuidString: String(cString: idCString)) else {
            throw DatabaseError.conversionFailed
        }
        
        let categoryName = String(cString: nameCString)
        
        let menuCategory = MenuCategory(id: id, categoryName: categoryName)
        return menuCategory
    }
}
