//
//  CategoryService.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/06/24.
//

import Foundation

protocol CategoryService {
    func add(_ menuItem: MenuCategory) throws
    func fetch() throws -> [MenuCategory]?
    func update(_ menuItem: MenuCategory) throws
    func delete(_ menuItem: MenuCategory) throws
}

struct CategoryServiceImpl: CategoryService {
    private let databaseAccess: DatabaseAccess
    
    init(databaseAccess: DatabaseAccess) {
        self.databaseAccess = databaseAccess
    }
    
    func add(_ category: MenuCategory) throws {
        try databaseAccess.insert(category)
        publishNotification()
    }
    
    func fetch() throws -> [MenuCategory]? {
        let query = "SELECT * FROM \(DatabaseTables.category.rawValue);"
        let result = try databaseAccess.retrieve(query: query, parseRow: MenuCategory.parseRow) as? [MenuCategory]
        return result
    }
    
    func update(_ category: MenuCategory) throws {
        try databaseAccess.update(category)
        publishNotification()
    }
    
    func delete(_ category: MenuCategory) throws {
        // let query = "DELETE FROM \(DatabaseTables.menuItem.rawValue) WHERE category_id = '\(category.id)';"
        try databaseAccess.delete(from: DatabaseTables.menuItem.rawValue, where: "category_id = '\(category.id)'")
        try databaseAccess.delete(item: category)
        publishNotification()
    }
    
    private func publishNotification() {
        NotificationCenter.default.post(name: .categoryDataDidChangeNotification, object: nil)
    }
}
