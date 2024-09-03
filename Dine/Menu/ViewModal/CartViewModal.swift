//
//  CartViewModal.swift
//  Dine
//
//  Created by doss-zstch1212 on 28/08/24.
//

import UIKit

struct CartItemViewModel {
    let menuItem: MenuItem
    let menuItemName: String
    let quantity: Int
    let image: UIImage?
}

class CartViewModel {
    @Published private(set) var items: [CartItemViewModel]
    var cart: [MenuItem: Int]
    
    init(cart: [MenuItem: Int]) {
        self.cart = cart
        self.items = cart.map {
            CartItemViewModel(
                menuItem: $0.key,
                menuItemName: $0.key.name,
                quantity: $0.value,
                image: $0.key.renderedImage
            )
        }
    }
    
    func updateQuantity(for menuItem: MenuItem, by quantity: Int) {
        cart[menuItem] = quantity
        // recompute items
        items = cart.map {
            CartItemViewModel(
                menuItem: $0.key,
                menuItemName: $0.key.name,
                quantity: $0.value,
                image: $0.key.renderedImage
            )
        }
        print(cart.debugDescription)
    }
}
