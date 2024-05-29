//
//  ChoseTableViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 21/05/24.
//

import UIKit
import SwiftUI

class ChooseTableViewController: UIViewController {
    
    // MARK: - Properties
    private var tableData: [RestaurantTable] = []
    private var selectedTables: [RestaurantTable] = []
    
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTables()
        setupCollectionView()
        view = collectionView
        setupNavigationBar()
    }
    
    // MARK: - Private methods
    
    private func loadTables() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let tableService = TableServiceImpl(databaseAccess: databaseAccess)
            try fetchTables(using: tableService)
        } catch {
            handleDatabaseError(error)
        }
    }

    private func fetchTables(using tableService: TableService) throws {
        guard let result = try tableService.fetch() else {
            print("No `RestaurantTable` records found in the database.")
            return
        }
        // Process the result here if needed
        tableData = result
    }

    private func handleDatabaseError(_ error: Error) {
        print("Unable to fetch `RestaurantTable` from the database: \(error.localizedDescription)")
    }

    
    private struct LayoutMetrics {
        static let horizontalMargin = 14.0
        static let sectionSpacing = 8.0
        static let cornerRadius = 10.0
    }
    
    // A cell registration that configures a custom cell with a SwiftUI Table view.
    private var tableRowRegistration: UICollectionView.CellRegistration<UICollectionViewCell, RestaurantTable> = {
        .init { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                TableRow(table: item)
            }
            .margins(.vertical, 8)
            .margins(.horizontal, 14)
        }
    }()
    
    private func setupCollectionView() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfig.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupNavigationBar() {
        title = "Choose Table"
        navigationController?.navigationBar.prefersLargeTitles = true
        let confirmBarButton = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(confirmBarButtonTapped(_ :)))
        navigationItem.rightBarButtonItem = confirmBarButton
    }
    
    @objc private func confirmBarButtonTapped(_ sender: UIBarButtonItem) {
        let confirmOrderVC = ConfirmOrderViewController()
        self.navigationController?.pushViewController(confirmOrderVC, animated: true)
    }
}

extension ChooseTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tableData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = tableData[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: tableRowRegistration, for: indexPath, item: item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTable = tableData[indexPath.item]
        selectedTables.append(selectedTable)
        // print(selectedTables.description)
    }
}

#Preview {
    UINavigationController(rootViewController: ChooseTableViewController())
}

class TableSelector: ObservableObject {
    @Published var isTableSelected: Bool = false
    
    func toggleTableSelection() {
        isTableSelected.toggle()
    }
}
