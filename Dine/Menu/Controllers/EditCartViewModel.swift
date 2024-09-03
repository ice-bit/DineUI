//
//  EditCartViewModel.swift
//  Dine
//
//  Created by doss-zstch1212 on 03/09/24.
//

import Foundation
import Combine

struct EditCartSection {
    let category: MenuCategory
    let items: [MenuItem]
}

class EditCartViewModel: ObservableObject {
    @Published private(set) var sections: [EditCartSection] = []
    private var allMenuItems: [MenuItem] = []
    private(set) var cart: [MenuItem: Int]
    private var order: Order
    
    // MARK: - Initialization
    init(cart: [MenuItem: Int], order: Order) {
        self.cart = cart
        self.order = order
        fetchMenuItems()
    }
    
    // MARK: - Data Fetching and Processing
    private func fetchMenuItems() {
        do {
            let menuService = try MenuServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            guard let result = try? menuService.fetch() else { return }
            allMenuItems = result
            for (item, quantity) in cart {
                if let index = allMenuItems.firstIndex(where: { $0.itemId == item.itemId }) {
                    allMenuItems[index].count = quantity
                }
            }
            organizeSections()
        } catch {
            print("Failed to fetch menu items: \(error)")
        }
    }
    
    private func organizeSections() {
        let grouped = Dictionary(grouping: allMenuItems) { $0.category }
        sections = grouped.map { EditCartSection(category: $0.key, items: $0.value) }
            .sorted { $0.category.categoryName < $1.category.categoryName }
    }
    
    // MARK: - Cart Management
    func updateCart(for menuItem: MenuItem, quantity: Int) {
        if quantity > 0 {
            cart[menuItem] = quantity
        } else {
            cart.removeValue(forKey: menuItem)
        }
        // Update the count in allMenuItems
        if let index = allMenuItems.firstIndex(where: { $0.itemId == menuItem.itemId }) {
            allMenuItems[index].count = quantity
        }
        organizeSections()
    }
    
    func addItems(completion: @escaping (Bool) -> Void) {
        do {
            let orderService = try OrderServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            for (item, quantity) in cart {
                let orderItem = OrderItem(
                    orderID: order.orderIdValue,
                    menuItemID: item.itemId,
                    menuItemName: item.name,
                    price: item.price,
                    quantity: quantity,
                    categoryId: item.category.id,
                    description: item.description
                )
                try orderService.add(orderItem)
            }
            completion(true)
        } catch {
            print("Failed to add items: \(error)")
            completion(false)
        }
    }
    
    func deleteOrderedItems() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            try databaseAccess.delete(from: DatabaseTables.orderMenuItemTable.rawValue, where: "OrderID = '\(order.orderIdValue.uuidString)'")
        } catch {
            print("Failed to delete ordered items: \(error)")
        }
    }
}
