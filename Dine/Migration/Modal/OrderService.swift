//
//  OrderService.swift
//  Dine
//
//  Created by doss-zstch1212 on 26/03/24.
//

import Foundation

protocol OrderService {
    func add(_ order: Order) throws
    func add(_ orderItem: OrderItem) throws
    func fetch() throws -> [Order]?
    func update(_ order: Order) throws
    func delete(_ order: Order) throws
}

struct OrderServiceImpl: OrderService {
    private let databaseAccess: DatabaseAccess
    init(databaseAccess: DatabaseAccess) {
        self.databaseAccess = databaseAccess
    }
    
    func add(_ order: Order) throws {
        try databaseAccess.insert(order)
    }
    
    func add(_ orderItem: OrderItem) throws {
        try databaseAccess.insert(orderItem)
    }
    
    func fetch() throws -> [Order]? {
        var mappedOrders = [Order]()
        let query = "SELECT * FROM \(DatabaseTables.orderTable.rawValue);"
        guard let resultOrders = try databaseAccess.retrieve(query: query, parseRow: Order.parseRow) as? [Order] else {
            print("Invalid order data")
            return nil
        }
        for resultOrder in resultOrders {
            let menuItemTable = DatabaseTables.menuItem.rawValue
            let orderItemTable = DatabaseTables.orderMenuItemTable.rawValue
            let menuItemQuery = """
                SELECT \(menuItemTable).MenuItemID, \(menuItemTable).MenuItemName, \(menuItemTable).Price, \(orderItemTable).Quantity, \(menuItemTable).category_id, \(menuItemTable).description
                FROM \(DatabaseTables.orderMenuItemTable.rawValue)
                JOIN \(menuItemTable) ON \(orderItemTable).MenuItemID = \(menuItemTable).MenuItemID
                WHERE \(orderItemTable).OrderID = '\(resultOrder.orderIdValue.uuidString)';
                """
            guard let resultOrderMenuItems = try databaseAccess.retrieve(query: menuItemQuery, parseRow: OrderItem.parseRow) as? [OrderItem] else {
                print("Failed to convert to MenuItems")
                return nil
            }
            for orderMenuItem in resultOrderMenuItems {
                for _ in 0..<orderMenuItem.quantity {
                    let menuItem = MenuItem(
                        itemId: orderMenuItem.menuItemID,
                        name: orderMenuItem.menuItemName,
                        price: orderMenuItem.price,
                        category: MenuCategory(
                            id: UUID(),
                            categoryName: "Starter"
                        ),
                        description: String()
                    )
                    resultOrder.menuItems.append(menuItem)
                }
            }
            mappedOrders.append(resultOrder)
        }
        return mappedOrders
    }
    
    func fetch(_ id: UUID) throws -> Order? {
        var mappedOrders = [Order]()
        let query = "SELECT * FROM \(DatabaseTables.orderTable.rawValue) WHERE OrderID = '\(id)';"
        guard let resultOrders = try databaseAccess.retrieve(query: query, parseRow: Order.parseRow) as? [Order] else {
            print("Invalid order data")
            return nil
        }
        for resultOrder in resultOrders {
            let menuItemTable = DatabaseTables.menuItem.rawValue
            let orderItemTable = DatabaseTables.orderMenuItemTable.rawValue
            let menuItemQuery = """
                SELECT \(menuItemTable).MenuItemID, \(menuItemTable).MenuItemName, \(menuItemTable).Price, \(orderItemTable).Quantity, \(menuItemTable).category_id, \(menuItemTable).description
                FROM \(DatabaseTables.orderMenuItemTable.rawValue)
                JOIN \(menuItemTable) ON \(orderItemTable).MenuItemID = \(menuItemTable).MenuItemID
                WHERE \(orderItemTable).OrderID = '\(resultOrder.orderIdValue.uuidString)';
                """
            guard let resultOrderMenuItems = try databaseAccess.retrieve(query: menuItemQuery, parseRow: OrderItem.parseRow) as? [OrderItem] else {
                print("Failed to convert to MenuItems")
                return nil
            }
            for orderMenuItem in resultOrderMenuItems {
                for _ in 0..<orderMenuItem.quantity {
                    let menuItem = MenuItem(
                        itemId: orderMenuItem.menuItemID,
                        name: orderMenuItem.menuItemName,
                        price: orderMenuItem.price,
                        category: MenuCategory(
                            id: UUID(),
                            categoryName: "Starters"
                        ),
                        description: orderMenuItem.description
                    )
                    resultOrder.menuItems.append(menuItem)
                }
            }
            mappedOrders.append(resultOrder)
        }
        return mappedOrders[0]
    }
    
    func update(_ order: Order) throws {
        try databaseAccess.update(order)
    }
    
    func delete(_ order: Order) throws {
        try databaseAccess.delete(item: order)
    }
}
