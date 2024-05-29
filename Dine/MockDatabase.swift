//
//  MockDatabase.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/05/24.
//

import Foundation

class MockDatabase {
    static let databaseAccess = try? SQLiteDataAccess.openDatabase()
    
    static func getOrderService() -> OrderService {
        do {
            try databaseAccess?.createTable(for: Order.self)
        } catch {
            print("Failed creating table")
        }
        let orderService = OrderServiceImpl(databaseAccess: databaseAccess!)
        return orderService
    }
    
    static func getTableService() -> TableService {
        do {
            try databaseAccess?.createTable(for: Order.self)
        } catch {
            print("Failed creating table")
        }
        let tableService = TableServiceImpl(databaseAccess: databaseAccess!)
        return tableService
    }
    
    static func getMenuService() -> MenuService {
        let menuService = MenuServiceImpl(databaseAccess: databaseAccess!)
        return menuService
    }
}
