//
//  MenuViewModal.swift
//  Dine
//
//  Created by doss-zstch1212 on 29/08/24.
//

import UIKit
import Combine

struct MenuSection {
    let header: String
    var items: [MenuItem]
}

class MenuViewModal: ObservableObject {
    @Published var menuSections: [MenuSection] = []
    var menuItems: [MenuItem] = [] {
        didSet {
            updateSections()
        }
    }
    var isFiltering: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        fetchMenuFromDatabase()
        updateSections()
        setupBinding()
    }
    
    private func setupBinding() {
        NotificationCenter.default
            .publisher(for: .menuItemDidChangeNotification)
            .sink { [weak self] _ in
                self?.fetchMenuFromDatabase()
            }
            .store(in: &cancellables)
    }
    
    private func updateSections() {
        // Group items by category and create sections
        let groupedItems = Dictionary(grouping: menuItems, by: { $0.category.categoryName })
        self.menuSections = groupedItems.map { MenuSection(header: $0.key, items: $0.value) }
    }
    
    func filterContentForSearch(_ searchController: UISearchController) {
        let isSearchBarEmpty = searchController.searchBar.text?.isEmpty ?? true
        isFiltering = searchController.isActive && !isSearchBarEmpty
        
        if isFiltering {
            let filteredSections = menuSections.map { section in
                let filteredItems = section.items.filter { $0.name.lowercased().contains(searchController.searchBar.text!.lowercased()) }
                return MenuSection(header: section.header, items: filteredItems)
            }.filter { !$0.items.isEmpty } // Only include sections that have items after filtering
            
            menuSections = filteredSections
        } else {
            updateSections()
        }
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
    
    // method to get the number of sections
    func numberOfSections() -> Int {
        return menuSections.count
    }
    
    // method to get the number of items in a section
    func numberOfItems(in section: Int) -> Int {
        guard section < menuSections.count else { return 0 }
        return menuSections[section].items.count
    }
    
    // method to get menuItems in a section
    func items(in section: Int) -> [MenuItem] {
        guard section < menuSections.count else { return [] }
        return menuSections[section].items
    }
    
    // Example method to get a MenuItem for a given indexPath
    func item(at indexPath: IndexPath) -> MenuItem? {
        guard indexPath.section < menuSections.count else { return nil }
        let items = menuSections[indexPath.section].items
        guard indexPath.row < items.count else { return nil }
        return items[indexPath.row]
    }
    
    // Example method to update a MenuItem
    func updateItem(_ item: MenuItem) {
        if let sectionIndex = menuSections.firstIndex(where: { $0.header == item.category.categoryName }),
           let itemIndex = menuSections[sectionIndex].items.firstIndex(where: { $0.itemId == item.itemId }) {
            menuSections[sectionIndex].items[itemIndex] = item
        }
        
        // update in database
    }
}
