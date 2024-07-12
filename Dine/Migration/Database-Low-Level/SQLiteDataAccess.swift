//
//  SQLiteDataAccess.swift
//  Dine
//
//  Created by doss-zstch1212 on 15/03/24.
//

import Foundation

protocol DatabaseAccess {
    func createTable(for entity: SQLTable.Type) throws
    func insert(_ entity: SQLInsertable) throws
    func retrieve(query: String, parseRow: (OpaquePointer?) throws -> Any?) throws -> [Any?]
    func update(tableName: String, columnValuePairs: [String: Any], condition: String?) throws
    func update(_ entity: SQLUpdatable) throws
    func delete(item: SQLDeletable) throws
    func delete(from tableName: String, where condition: String?) throws
    func verifyTablesExistence(tableNames: [String]) throws -> Bool
}

class SQLiteDataAccess: DatabaseAccess {
    private let database: SQLiteDatabase
    
    init(database: SQLiteDatabase) {
        self.database = database
    }
    
    static func openDatabase() throws -> SQLiteDataAccess {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileIOError.documentDirectoryUnavailable
        }
        let fileURL = documentDirectory.appending(path: "dine.sqlite")
        print("Database connection opened by \(#fileID)")
        let database = try SQLiteDatabase.open(path: fileURL.absoluteString)
        return SQLiteDataAccess(database: database)
    }
    
    func createTable(for entity: SQLTable.Type) throws {
        try database.createTable(table: entity)
    }
    
    func insert(_ entity: SQLInsertable) throws {
        try database.insert(entity)
    }
    
    func retrieve(query: String, parseRow: (OpaquePointer?) throws -> Any?) throws -> [Any?] {
        try database.retrieve(query: query, parseRow: parseRow)
    }
    
    func delete(item: SQLDeletable) throws {
        try database.delete(item: item)
    }
    
    // Deletes rows from the specified table based on the provided condition.
    ///
    /// - Parameters:
    ///   - tableName: The name of the table from which rows should be deleted.
    ///   - condition: An optional condition to specify which rows to delete. If no condition is provided, all rows in the table will be deleted.
    /// - Throws: An error of type `SQLiteError` if the delete operation fails.
    ///
    /// - Note: This is a very sensitive action. Ensure that the `condition` is provided to specify which row(s) to delete.
    ///   If no condition is provided, this method will delete all rows in the table, resulting in potential data loss.
    func delete(from tableName: String, where condition: String? = nil) throws {
        try database.delete(from: tableName, where: condition)
    }
    
    func update(tableName: String, columnValuePairs: [String: Any], condition: String?) throws {
        try database.update(tableName: tableName, columnValuePairs: columnValuePairs, condition: condition)
    }
    
    func update(_ entity: SQLUpdatable) throws {
        try database.update(entity)
    }
    
    func verifyTablesExistence(tableNames: [String]) throws -> Bool {
        try database.verifyTablesExistence(tableNames: tableNames)
    }
}


