//
//  MenuService.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/03/24.
//

import Foundation

protocol MenuService {
    func add(_ menuItem: MenuItem) throws
    func fetch() throws -> [MenuItem]?
    func update(_ menuItem: MenuItem) throws
    func delete(_ menuItem: MenuItem) throws
}

struct MenuServiceImpl: MenuService {
    private let databaseAccess: DatabaseAccess
    
    init(databaseAccess: DatabaseAccess) {
        self.databaseAccess = databaseAccess
    }
    
    func add(_ menuItem: MenuItem) throws {
        try databaseAccess.insert(menuItem)
    }
    
    func fetch() throws -> [MenuItem]? {
        // let query = "SELECT * FROM \(DatabaseTables.menuItem.rawValue);"
        let menuItemTable = DatabaseTables.menuItem.rawValue
        let query = """
                    SELECT
                        \(menuItemTable).MenuItemID,
                        \(menuItemTable).MenuItemName,
                        \(menuItemTable).Price,
                        \(menuItemTable).description,
                        \(menuItemTable).category_id,
                        Category.name AS category_name,
                        \(menuItemTable).imageURL
                    FROM
                        \(menuItemTable)
                    JOIN
                        Category ON \(menuItemTable).category_id = Category.id;
                    """
        guard let results = try databaseAccess.retrieve(query: query, parseRow: MenuItem.parseRow) as? [MenuItem] else {
            throw DatabaseError.conversionFailed
        }
        return results
    }
    
    func update(_ menuItem: MenuItem) throws {
        try databaseAccess.update(menuItem)
    }
    
    func delete(_ menuItem: MenuItem) throws {
        try databaseAccess.delete(item: menuItem)
    }
}
