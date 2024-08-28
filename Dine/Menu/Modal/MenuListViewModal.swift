//
//  MenuViewModal.swift
//  Dine
//
//  Created by ice-bit on 21/08/24.
//

import Combine
import Foundation

class MenuListViewModal: ObservableObject {
    // publishers
    @Published var menuItems: [MenuItem] = []
    @Published var categories: [MenuCategory] = []
    @Published var selectedCategory: MenuCategory?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        setupBinding()
        fetchFromDatabase()
    }
    
    private func setupBinding() {
        NotificationCenter.default
            .publisher(for: .menuItemDidChangeNotification)
            .sink { [weak self] _ in
                self?.fetchMenuFromDatabase()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .categoryDataDidChangeNotification)
            .sink { [weak self] _ in
                self?.fetchCategoryFromDatabase()
            }
            .store(in: &cancellables)
    }
    
    private func fetchMenuFromDatabase() {
        do {
            let dbAccess = try SQLiteDataAccess.openDatabase()
            let menuService = MenuServiceImpl(databaseAccess: dbAccess)
            let resultMenuItems = try menuService.fetch()
            if let resultMenuItems {
                menuItems = resultMenuItems
            }
        } catch {
            print("🔨 failed with error: \(error)")
        }
    }
    
    private func fetchCategoryFromDatabase() {
        do {
            let dbAccess = try SQLiteDataAccess.openDatabase()
            let categoryService = CategoryServiceImpl(databaseAccess: dbAccess)
            let resultCategory = try categoryService.fetch()
            if let resultCategory {
                categories = resultCategory
                if let activeCategory = selectedCategory {
                    if categories.first(where: { $0.id == activeCategory.id }) != nil {
                        return
                    } else {
                        selectedCategory = categories.first
                    }
                } else {
                    selectedCategory = categories.first
                }
            }
        } catch {
            print("🔨 failed with error: \(error)")
        }
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
    
    func addMenuItems(_ menuItem: MenuItem) {
        menuItems.append(menuItem)
        
        do {
            try insertIntoDatabase(menuItem)
        } catch {
            fatalError("Failed to update menuItem: \(error)")
        }
    }
    
    private func insertIntoDatabase(_ menuItem: MenuItem) throws {
        let dbAccessor = try SQLiteDataAccess.openDatabase()
        let menuService = MenuServiceImpl(databaseAccess: dbAccessor)
        try menuService.add(menuItem)
    }
}
