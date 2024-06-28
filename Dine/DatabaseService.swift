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
    private var databaseAccess: DatabaseAccess?
    
    init() {
        do {
            databaseAccess = try SQLiteDataAccess.openDatabase()
        } catch {
            print("Unable to open database!")
        }
    }
    
    func createAccountTable() {
        do {
            try databaseAccess?.createTable(for: Account.self)
        } catch {
            print("Failed to create account table")
        }
    }
    
    func createMenuItemTable() {
        do {
            try databaseAccess?.createTable(for: MenuItem.self)
        } catch {
            print("Failed to create MenuItem table")
        }
    }
    
    func createBillTable() {
        do {
            try databaseAccess?.createTable(for: Bill.self)
        } catch {
            print("Failed to create Bills table!")
        }
    }
    
    func createTableDataTable() {
        do {
            try databaseAccess?.createTable(for: RestaurantTable.self)
        } catch {
            print("Failed to create restaurant table")
        }
    }
    
    func createOrderTable() {
        do {
            try databaseAccess?.createTable(for: Order.self)
        } catch {
            print("Failed to create order table")
        }
    }
    
    func createOrderItemTable() {
        do {
            try databaseAccess?.createTable(for: OrderItem.self)
        } catch {
            print("Failed to create orderItem table")
        }
    }
    
    func createCategoryTable() {
        do {
            try databaseAccess?.createTable(for: MenuCategory.self)
        } catch {
            print("Failed to create \(DatabaseTables.category.rawValue) table")
        }
    }
    
    deinit {
        print("DatabaseService no longer active...Deinitializing...")
        databaseAccess = nil
    }
}
