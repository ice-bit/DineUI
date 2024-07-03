//
//  ConfirmOrderViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/05/24.
//

import UIKit
import SwiftUI

class ConfirmOrderViewController: UIViewController {
    private let menuItems: [MenuItem]
    private let selectedTable: RestaurantTable
    
    // MARK: - Init
    init(menuItems: [MenuItem], selectedTable: RestaurantTable) {
        self.menuItems = menuItems
        self.selectedTable = selectedTable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
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

