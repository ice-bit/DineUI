//
//  DatabaseService.swift
//  Dine
//
//  Created by doss-zstch1212 on 13/05/24.
//

import Foundation

protocol DatabaseService {
    
}

class DatabaseServiceImpl {
    private let databaseAccessor: DatabaseAccess
    
    init(databaseAccessor: DatabaseAccess) {
        self.databaseAccessor = databaseAccessor
    }
    
    func setupTables() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            try databaseAccess.createTable(for: Account.self)
            try databaseAccess.createTable(for: Restaurant.self)
            try databaseAccess.createTable(for: MenuItem.self)
            try databaseAccess.createTable(for: Bill.self)
            try databaseAccess.createTable(for: RestaurantTable.self)
            try databaseAccess.createTable(for: OrderItem.self)
            try databaseAccess.createTable(for: Order.self)
        } catch {
            print("Failed to create table: \(error)")
        }
    }
}
