//
//  ChoseTableViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 21/05/24.
//

import UIKit
import SwiftUI
import Toast

class ChooseTableViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedMenuItems: [MenuItem: Int]
    
    private var tableData: [RestaurantTable] = []
    private var selectedTable: RestaurantTable?
    
    private var collectionView: UICollectionView!
    
    init(selectedMenuItems: [MenuItem: Int]) {
        self.selectedMenuItems = selectedMenuItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTables()
        setupCollectionView()
        view = collectionView
        setupNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectTable(_:)), name: .tableSelectionNotification, object: nil)
    }
    
    @objc private func didSelectTable(_ sender: NotificationCenter) {
        print(#function)
        
    }
    
    // MARK: - Methods
    
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
        let confirmBarButton = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(confirmButtonAction(_:)))
        navigationItem.rightBarButtonItem = confirmBarButton
    }
    
    @objc private func confirmButtonAction(_ sender: UIBarButtonItem) {
        do {
            let dataAccess = try SQLiteDataAccess.openDatabase()
            let orderService = OrderServiceImpl(databaseAccess: dataAccess)
            let tableService = TableServiceImpl(databaseAccess: dataAccess)
            let orderController = OrderController(orderService: orderService, tableService: tableService)
            if let selectedTable {
                try orderController.createOrder(for: selectedTable, menuItems: selectedMenuItems)
                NotificationCenter.default.post(name: .didAddNewOrderNotification, object: nil)
                self.dismiss(animated: true) {
                    // Show toast after completion
                    let toast = Toast.text("New Order Created")
                    toast.show(haptic: .success)
                }
            }
        } catch {
            print("Unable to create order - \(error)")
        }
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
        let currentTable = tableData[indexPath.item]
        for table in self.tableData {
            if table.tableId == currentTable.tableId {
                currentTable.isSelected.toggle()
                // Haptic feedback
                let feedBackGen = UISelectionFeedbackGenerator()
                feedBackGen.prepare()
                feedBackGen.selectionChanged()
            } else {
                table.isSelected = false
            }
        }
        
        // Setting the selected table
        selectedTable = currentTable
    }
}

#Preview {
    UINavigationController(rootViewController: ChooseTableViewController(selectedMenuItems: [:]))
}

class TableSelector: ObservableObject {
    @Published var isTableSelected: Bool = false
    
    func toggleTableSelection() {
        isTableSelected.toggle()
    }
}
