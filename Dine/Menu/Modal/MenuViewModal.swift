//
//  MenuViewModal.swift
//  Dine
//
//  Created by doss-zstch1212 on 21/08/24.
//

import Combine
import Foundation

class MenuViewModal: ObservableObject {
    // publishers
    @Published var menuItems: [MenuItem] = []
    @Published var categories: [MenuCategory] = []
    @Published var selectedCategory: MenuCategory?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeMenuItems), name: .menuItemDidChangeNotification, object: nil)
        fetchFromDatabase()
    }
    
    @objc private func didChangeMenuItems() {
        fetchFromDatabase()
    }
    
    private func fetchFromDatabase() {
        do {
            let dbAccess = try SQLiteDataAccess.openDatabase()
            let menuService = MenuServiceImpl(databaseAccess: dbAccess)
            let categoryService = CategoryServiceImpl(databaseAccess: dbAccess)
            let resultMenuItems = try menuService.fetch()
            let resultCategories = try categoryService.fetch()
            if let resultMenuItems,
               let resultCategories {
                menuItems = resultMenuItems
                categories = resultCategories
                selectedCategory = categories.first
            }
        } catch {
            fatalError("failed to load menu data: failed with error: \(error)")
        }
    }
    
    var filteredMenuItems: [MenuItem] {
        guard let selectedCategory else {
            return []
        }
        return getMenuItems(for: selectedCategory)
    }
    
    func getMenuItems(for category: MenuCategory) -> [MenuItem] {
        return menuItems.filter { $0.category.id == category.id }
    }
}
