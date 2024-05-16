//
//  Menu.swift
//  Dine
//
//  Created by doss-zstch1212 on 09/05/24.
//

import Foundation

struct MenuItemDummy {
    private let menuItemID: UUID
    private let itemName: String
    private let price: Double
    private let type: ItemType
    private let description: String
    
    init(menuItemID: UUID, itemName: String, price: Double, type: ItemType, description: String) {
        self.menuItemID = menuItemID
        self.itemName = itemName
        self.price = price
        self.type = type
        self.description = description
    }
    
    init(itemName: String, price: Double, type: ItemType, description: String) {
        self.init(menuItemID: UUID(), itemName: itemName, price: price, type: type, description: description)
    }
    
}

enum ItemType {
    case veg, nonVeg
}
