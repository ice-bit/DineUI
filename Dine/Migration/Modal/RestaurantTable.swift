//
//  Table.swift
//  Dine
//
//  Created by doss-zstch1212 on 25/01/24.
//

import Foundation
import SQLite3

class RestaurantTable: ObservableObject {
    private let _tableId: UUID
    var tableStatus: TableStatus
    @Published var capacity: Int
    @Published var locationIdentifier: Int
    @Published var isSelected: Bool = false // For Dynamically changing SwiftUIView
    
    var tableId: UUID {
        return _tableId
    }
    
    init(tableId: UUID, tableStatus: TableStatus, maxCapacity: Int, locationIdentifier: Int) {
        self._tableId = tableId
        self.tableStatus = tableStatus
        self.capacity = maxCapacity
        self.locationIdentifier = locationIdentifier
    }
    
    convenience init(tableStatus: TableStatus, maxCapacity: Int, locationIdentifier: Int) {
        self.init(tableId: UUID(), tableStatus: tableStatus, maxCapacity: maxCapacity, locationIdentifier: locationIdentifier)
    }
    
    func changeTableStatus(to status: TableStatus) {
        tableStatus = status
    }
    
    func getCSVString() -> String {
        return "\(_tableId),\(tableStatus.rawValue),\(capacity),\(locationIdentifier)"
    }
    
}

extension RestaurantTable: Parsable {}

extension RestaurantTable: SQLTable {
    static var tableName: String {
        DatabaseTables.restaurantTable.rawValue
    }
    
    static var createStatement: String {
        """
        CREATE TABLE \(DatabaseTables.restaurantTable.rawValue) (
          TableID VARCHAR(32) PRIMARY KEY,
          TableStatus VARCHAR(255),
          MaxCapacity INTEGER,
          LocationIdentifier INTEGER
        );
        """
    }
}

extension RestaurantTable: SQLUpdatable {
    var createUpdateStatement: String {
        """
        UPDATE \(DatabaseTables.restaurantTable.rawValue)
        SET TableID = '\(tableId)', TableStatus = '\(tableStatus.rawValue)', MaxCapacity = \(capacity), LocationIdentifier = \(locationIdentifier)
        WHERE TableID = '\(tableId)'
        """
    }
}

extension RestaurantTable: SQLInsertable {
    var createInsertStatement: String {
        """
        INSERT INTO \(DatabaseTables.restaurantTable.rawValue) (TableID, TableStatus, MaxCapacity, LocationIdentifier)
        VALUES ('\(tableId.uuidString)', '\(tableStatus.rawValue)', \(capacity), \(locationIdentifier));
        """
    }
}

extension RestaurantTable: SQLDeletable {
    var createDeleteStatement: String {
        "DELETE FROM \(DatabaseTables.restaurantTable.rawValue) WHERE TableID = '\(tableId)';"
    }
}

extension RestaurantTable: DatabaseParsable {
    static func parseRow(statement: OpaquePointer?) throws -> RestaurantTable? {
        guard let statement = statement else { return nil }
        guard let tableIdCString = sqlite3_column_text(statement, 0),
              let statusCString = sqlite3_column_text(statement, 1) else {
            throw DatabaseError.missingRequiredValue
        }
        
        let maxCapacity = Int(sqlite3_column_int(statement, 2))
        let locationIdentifier = Int(sqlite3_column_int(statement, 3))
        
        guard let tableId = UUID(uuidString: String(cString: tableIdCString)),
              let status = TableStatus(rawValue: String(cString: statusCString)) else {
            throw DatabaseError.conversionFailed
        }
        
        let restaurantTable = RestaurantTable(tableId: tableId, tableStatus: status, maxCapacity: maxCapacity, locationIdentifier: locationIdentifier)
        return restaurantTable
    }
}


