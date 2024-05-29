//
//  ConfirmOrderViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/05/24.
//

import UIKit
import SwiftUI

class ConfirmOrderViewController: UIViewController {
    private let menuItems: [MenuItem] = []
    private let selectedTables: [RestaurantTable] = []
    
    private var firstTable: RestaurantTable? {
        selectedTables.first
    }
    
    // MARK: - Init
    /*init(menuItems: [MenuItem], selectedTables: [RestaurantTable]) {
        self.menuItems = menuItems
        self.selectedTables = selectedTables
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupNavigationBar()
    }

    // MARK: - Private methods
    private func setupNavigationBar() {
        title = "Confirm Order"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupBackground() {
        view.backgroundColor = .systemBackground
    }
}

fileprivate let menuItems = [
    MenuItem(name: "Chicken", price: 4.9, menuSection: .beverages),
    MenuItem(name: "Chicken", price: 4.9, menuSection: .desserts),
    MenuItem(name: "Chicken", price: 4.9, menuSection: .mainCourse),
    MenuItem(name: "Chicken", price: 4.9, menuSection: .side)
]

fileprivate let tables = [
    RestaurantTable(tableStatus: .free, maxCapacity: 10, locationIdentifier: 120)
]

#Preview {
    UINavigationController(rootViewController: ConfirmOrderViewController())
}
