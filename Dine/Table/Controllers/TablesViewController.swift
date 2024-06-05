//
//  TablesViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit
import SwiftUI

class TablesViewController: UIViewController, UICollectionViewDataSource {
    // MARK: - Properties
    private let tableService: TableService
    
    private var collectionView: UICollectionView!
    
    private var tables: [RestaurantTable] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
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
        view = collectionView
        setupAppearance()
        loadTables()
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(didAddTable(_:)), name: .didAddTable, object: nil)
    }
    
    // MARK: - OBJC methods
    // Observer method
    @objc private func didAddTable(_ notification: NotificationCenter) {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let tableService = TableServiceImpl(databaseAccess: databaseAccess)
            let results = try tableService.fetch()
            if let results {
                tables = results
            }
        } catch {
            print("Unable to load table - \(error)")
        }
    }
    
    @objc private func addTableButtonTapped(sender: UIBarButtonItem) {
        print("Add table button tapped")
        let addFormVC = AddTableFormView()
        let hostingVC = UIHostingController(rootView: addFormVC)
        let addTableSheetVC = /*AddTablesViewController()*/hostingVC
        if let sheet = addTableSheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        self.present(addTableSheetVC, animated: true)
    }
    
    // MARK: - Methods
    private func loadTables() {
        do {
            let result = try tableService.fetch()
            guard let result else {
                print("Failed to unwrap! - (type error)")
                return
            }
            tables = result
        } catch {
            print("Unable to fetch and load RestaurantTable Table - (fetch failed)")
        }
    }
    
    private func setupAppearance() {
        self.title = "Tables"
        view.backgroundColor = .systemBackground
        setupNavBar()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTableButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    // MARK: - Collection view setup (grid)
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in
            createGridSection()
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
    }
    
    // Returns a compositional layout section for cells in a grid.
    private func createGridSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .zero
        section.contentInsets.leading = LayoutMetrics.horizontalMargin
        section.contentInsets.trailing = LayoutMetrics.horizontalMargin
        section.contentInsets.bottom = LayoutMetrics.sectionSpacing
        return section
    }
    
    private struct LayoutMetrics {
        static let horizontalMargin = 16.0
        static let sectionSpacing = 10.0
        static let cornerRadius = 10.0
    }

    private var tableItemRegistration: UICollectionView.CellRegistration<UICollectionViewCell, RestaurantTable> = {
        .init { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                TableItem(table: item)
            }
//            .margins(.horizontal, 10)
        }
    }()
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tables.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = tables[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: tableItemRegistration, for: indexPath, item: item)
    }
}

