//
//  TablesViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit
import SwiftUI

class TablesViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupAppearance()
        loadTables()
    }
    
    @objc private func addTableButtonTapped(sender: UIBarButtonItem) {
        print("Add table button tapped")
        var addFormVC = AddTableFormView()
        addFormVC.delegate = self
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
    
    private func loadTables() {
        guard let fetchedTables = try? tableService.fetch() else {
            print("Failed to fetch tables")
            return
        }
        tables = fetchedTables
    }
    
    private func setupAppearance() {
        self.title = "Tables"
        view.backgroundColor = UIColor(named: "primaryBgColor")
        setupNavBar()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTableButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        // register cell
        collectionView.register(TableCollectionViewCell.self, forCellWithReuseIdentifier: "CustomCell")
        collectionView.backgroundColor = UIColor(named: "primaryBgColor")
        view.addSubview(collectionView)
    }

}

extension TablesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tables.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as? TableCollectionViewCell else {
            return UICollectionViewCell()
        }
        let cellTableData = tables[indexPath.row]
        cell.configureCell(table: cellTableData)
        return cell
    }
    
    
}

extension TablesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        CGSize(width: 162, height: 65)
        let width = (collectionView.frame.width / 2) - 16 // Adjust for padding
        let height: CGFloat = 80 // Set your desired cell height
        return CGSize(width: width, height: height)
    }
}

extension TablesViewController: AddFormViewControllerDelegate {
    func didAddTable(_ table: RestaurantTable) {
        tables.append(table)
    }
    
    
}

