//
//  OrderController.swift
//  Dine
//
//  Created by doss-zstch1212 on 24/01/24.
//

import Foundation

protocol OrderServicable {
    func createOrder(for table: RestaurantTable, menuItems: [MenuItem: Int]) throws
    func getOrdersCount() -> Int?
    func displayOrders()
    func getUnbilledOrders() -> [Order]?
}

class OrderController: OrderServicable {
    private let orderService: OrderService
    private let tableService: TableService
    init(orderService: OrderService, tableService: TableService) {
        self.orderService = orderService
        self.tableService = tableService
    }
    
    func createOrder(for table: RestaurantTable, menuItems: [MenuItem: Int]) throws {
        var orderMenuItems: [MenuItem] = []
        
        // Iterate through the dictionary of menu item quantities
        let orderID = UUID()
        for (menuItem, quantity) in menuItems {
            // Append the menu item to the array the specified number of times
            orderMenuItems.append(contentsOf: Array(repeating: menuItem, count: quantity))
            // Add to join table
            let orderItem = OrderItem(
                orderID: orderID,
                menuItemID: menuItem.itemId,
                menuItemName: menuItem.name,
                price: menuItem.price,
                quantity: quantity,
                categoryId: menuItem.category.id,
                description: menuItem.description
            )
            try orderService.add(orderItem)
        }
        let order = Order(orderId: orderID, tableId: table.tableId, isOrderBilled: false, orderDate: Date(), menuItems: orderMenuItems, orderStatus: .received)
        // Change order status
        guard let resultTables = try tableService.fetch() else {
            print("Failed to fetch tables")
            return
        }
        guard let tableIndex = resultTables.firstIndex(where: { $0.tableId == table.tableId }) else {
            print("No tables found under UUID: \(table.tableId) for updating")
            return
        }
        let choosenTable = resultTables[tableIndex]
        choosenTable.tableStatus = .occupied
        try orderService.add(order)
        try tableService.update(choosenTable)
    }
    
    func getOrdersCount() -> Int? {
        guard let resultOrder = try? orderService.fetch() else {
            print("No orders found.")
            return nil
        }
        return resultOrder.count
    }
    
    func displayOrders() {
        guard let resultOrder = try? orderService.fetch() else {
            print("No orders found")
            return
        }
        for (index, order) in resultOrder.enumerated() {
            print("\(index + 1). Order: \(order.orderIdValue)")
            print(" - Ordered Items:")
            print(" - \(order.displayOrderItems())\n")
        }
    }
    
    func getUnbilledOrders() -> [Order]? {
        guard let resultOrder = try? orderService.fetch() else {
            print("No orders found")
            return nil
        }
        let unbilledOrders = resultOrder.filter { $0.isOrderBilledValue == false }
        return unbilledOrders
    }
    
    func deleteOrder(_ order: Order) throws {
        // Release the table that the order holds
        guard let resultTables = try tableService.fetch() else {
            print("Failed to fetch tables")
            return
        }
        guard let tableIndex = resultTables.firstIndex(where: { $0.tableId == order.tableIDValue }) else {
            print("No tables found under UUID: \(order.tableIDValue) for updating")
            return
        }
        
        let choosenTable = resultTables[tableIndex]
        choosenTable.tableStatus = .free
        
        try tableService.update(choosenTable)
        
        // Delete the order
        try orderService.delete(order)
        
        // Remove all reference in the join table OrderItems
        let databaseAccess = try SQLiteDataAccess.openDatabase()
        try databaseAccess.delete(from: DatabaseTables.orderMenuItemTable.rawValue, where: "OrderID = '\(order.orderIdValue.uuidString)'")
    }
    
    func updateStatus(for orderId: UUID, to status: OrderStatus) {
        do {
            let resultOrders = try orderService.fetch()
            let resultTables = try tableService.fetch()
            guard let orders = resultOrders,
                  let tables = resultTables else { return }
            guard let order = orders.first(where: { $0.orderIdValue == orderId }) else { return }
            guard let table = tables.first(where: { $0.tableId == order.tableIDValue }) else { return }
            
            // Update the order and related tables status
            order.orderStatusValue = .received
            table.changeTableStatus(to: .occupied)
            
            try orderService.update(order)
            try tableService.update(table)
        } catch {
            fatalError("Error updating order status - \(error)")
        }
    }
}
