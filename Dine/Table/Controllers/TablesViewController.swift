//
//  TablesViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit
import SwiftUI
import Toast

class TablesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - Properties
    
    /// Service to fetch and manage table data.
    private let tableService: TableService
    
    /// Collection view to display the tables.
    private var collectionView: UICollectionView!
    
    /// Placeholder label to show when there are no tables.
    private var placeholderLabel: UILabel!
    
    /// List of restaurant tables.
    private var tables: [RestaurantTable] = [] {
        didSet {
            collectionView.isHidden = tables.isEmpty
            placeholderLabel.isHidden = !tables.isEmpty
        }
    }
    
    // MARK: - Initializer
    
    /// Initializes a new instance of `TablesViewController` with the given table service.
    /// - Parameter tableService: The service to fetch and manage table data.
    init(tableService: TableService) {
        self.tableService = tableService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupPlaceholderLabel()
        setupAppearance()
        loadTables()
        NotificationCenter.default.addObserver(self, selector: #selector(didAddTable(_:)), name: .didAddTable, object: nil)
    }
    
    // MARK: - OBJC methods
    
    /// Observer method for when a new table is added.
    @objc private func didAddTable(_ notification: Notification) {
        loadTables()
    }
    
    /// Action method for the add table button.
    @objc private func addTableButtonTapped(sender: UIBarButtonItem) {
        print("Add table button tapped")
        let addFormVC = AddTableFormView()
        let hostingVC = UIHostingController(rootView: addFormVC)
        if let sheet = hostingVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        self.present(hostingVC, animated: true)
    }
    
    // MARK: - Methods
    
    /// Sets up the placeholder label.
    private func setupPlaceholderLabel() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Add Table to Continue"
        placeholderLabel.textColor = .systemGray3
        placeholderLabel.font = .preferredFont(forTextStyle: .title1)
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        placeholderLabel.isHidden = true
    }
    
    /// Loads the table data.
    private func loadTables() {
        do {
            let result = try tableService.fetch()
            tables = result ?? []
            collectionView.reloadData()
        } catch {
            print("Unable to fetch and load RestaurantTable Table - (fetch failed)")
        }
    }
    
    /// Sets up the appearance of the view.
    private func setupAppearance() {
        self.title = "Tables"
        view.backgroundColor = .systemBackground
        setupNavBar()
    }
    
    /// Sets up the navigation bar.
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTableButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    /// Sets up the collection view.
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in
            self.createGridSection()
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    /// Returns a compositional layout section for cells in a grid.
    private func createGridSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 0, leading: LayoutMetrics.horizontalMargin, bottom: LayoutMetrics.sectionSpacing, trailing: LayoutMetrics.horizontalMargin)
        return section
    }
    
    private struct LayoutMetrics {
        static let horizontalMargin = 16.0
        static let sectionSpacing = 10.0
    }
    
    /// Cell registration for the collection view.
    private var tableItemRegistration: UICollectionView.CellRegistration<UICollectionViewCell, RestaurantTable> = {
        .init { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                TableItem(table: item)
            }
        }
    }()
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tables.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = tables[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: tableItemRegistration, for: indexPath, item: item)
    }
    
    // MARK: - UICollectionViewDelegate methods
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        let item = tables[indexPaths[0].item]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] action in
                guard let self else { return }
                print("Edit context menu action")
                self.presentEditAlertController(for: item)
            }
            
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { action in
                print("Delete context menu action")
                self.deleteTable(item)
            }
            
            deleteAction.image?.withTintColor(.red)
            return UIMenu(children: [editAction, deleteAction])
        }
    }
    
    
    
    private func deleteTable(_ table: RestaurantTable) {
        do {
            let tableService = try TableServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            try tableService.delete(table)
            if let index = tables.firstIndex(where: { $0.tableId == table.tableId }) {
                tables.remove(at: index)
                collectionView.reloadData()
            }
        } catch {
            fatalError("Error while deleting table! - \(error)")
        }
    }
    
    private func presentEditAlertController(for table: RestaurantTable) {
        let alertController = UIAlertController(title: "Edit Table", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Location Identifier"
            textField.text = String(table.locationIdentifier)
            textField.keyboardType = .numberPad
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Capacity"
            textField.keyboardType = .numberPad
            textField.text = String(table.capacity)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self else { return }
            guard let firstTextField = alertController.textFields?[0],
                  let secondTextField = alertController.textFields?[1] else { return }
            
            guard let locationIdString = firstTextField.text,
                  let locationId = Int(locationIdString),
                  !locationIdString.isEmpty else {
                self.showToast("Invalid Location ID")
                return
            }
            
            guard let capacityText = secondTextField.text,
                  !capacityText.isEmpty,
                  let capacity = Int(capacityText) else {
                self.showToast("Invalid capacity")
                return
            }
            
            
            // Handle the text input
            print("Location ID text field: \(locationIdString)")
            print("Capacity text field: \(capacity)")
            
            table.locationIdentifier = locationId
            table.capacity = capacity
            
            editTable(table)
            
            let toast = Toast.text("Updated!")
            toast.show(haptic: .success)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func editTable(_ table: RestaurantTable) {
        do {
            let tableService = try TableServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            try tableService.update(table)
            
            guard let currentTable = tables.first(where: { $0.tableId == table.tableId }) else { return }
            currentTable.locationIdentifier = table.locationIdentifier
            currentTable.capacity = table.capacity
            
            collectionView.reloadData()
        } catch {
            fatalError("\(#function) failed with \(error)!") // Will be removed in production!
        }
    }
    
    private func showToast(_ message: String) {
        let toast = Toast.text(message)
        toast.show(haptic: .error)
    }
}
