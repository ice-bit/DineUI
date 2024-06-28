//
//  MenuSectionViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/05/24.
//

import UIKit
import SwiftUI

class MenuSectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var placeholderLabel: UILabel!
    private var addButton: UIBarButtonItem!
    private var categories: [MenuCategory] = [] {
        didSet {
            updateUIForData()
        }
    }
    private let menuService: MenuService
    
    // Search Components
    private var filteredCategories: [MenuCategory] = []
    private var searchController: UISearchController!
    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }
    
    // MARK: - Init
    init(menuService: MenuService) {
        self.menuService = menuService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        setupCollectionView()
        setupPlaceholderLabel()
        setupSearchBar()
        setupBarButton()
        populateCategoryData()
        NotificationCenter.default.addObserver(self, selector: #selector(categoryDataDidChange(_:)), name: .categoryDataDidChangeNotification, object: nil)
    }
    
    @objc private func categoryDataDidChange(_ notification: Notification) {
        populateCategoryData()
        collectionView.reloadData()
    }
    
    // MARK: - Methods
    private func populateCategoryData() {
        do {
            let categoryService = try CategoryServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            guard let result = try? categoryService.fetch() else {
                fatalError("Failed to load")
            }
            categories = result
        } catch {
            print("Failed to load categories: \(error)")
        }
    }
    
    private func updateUIForData() {
        let hasCategories = !categories.isEmpty
        collectionView.isHidden = !hasCategories
        placeholderLabel.isHidden = hasCategories
    }
    
    private func setupPlaceholderLabel() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Add Category to Continue"
        placeholderLabel.textColor = .systemGray3
        placeholderLabel.font = .preferredFont(forTextStyle: .title1)
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Initially hidden
        placeholderLabel.isHidden = true
    }
    
    private func setupSearchBar() {
        searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupBarButton() {
        addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonAction(_:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addButtonAction(_ sender: UIBarButtonItem) {
        print(#function)
        let addSectionViewController = AddSectionViewController()
        if let sheet = addSectionViewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        self.present(addSectionViewController, animated: true)
    }
    
    private func setupCollectionView() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfig.showsSeparators = false
        
        listConfig.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
                let item = self.categories[indexPath.item]
                self.handleSwipe(item: item)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        
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
    
    private func handleSwipe(item: MenuCategory) {
        do {
            let categoryService = try CategoryServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            try categoryService.delete(item)
            if let index = categories.firstIndex(where: { $0.id == item.id }) {
                categories.remove(at: index)
                collectionView.reloadData()
            }
        } catch {
            print("Counldn't delete category")
        }
    }
    
    private func filterContentsForSearch(_ searchText: String) {
        filteredCategories = categories.filter{ (category: MenuCategory) -> Bool in
            category.categoryName.lowercased().contains(searchText.lowercased())
        }
        
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isFiltering ? filteredCategories.count : categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = isFiltering ? filteredCategories[indexPath.item] : categories[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: sectionViewRegistration, for: indexPath, item: item)
    }
    
    private var sectionViewRegistration: UICollectionView.CellRegistration<UICollectionViewCell, MenuCategory> = {
        .init { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                SectionView(catergory: item)
            }
            .margins(.horizontal, 14)
            .margins(.vertical, 8)
        }
    }()
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = isFiltering ? filteredCategories[indexPath.item] : categories[indexPath.item]
        let sectionDetailVC = MenuListingViewController(activeSection: .mainCourse, category: item)
        navigationController?.pushViewController(sectionDetailVC, animated: true)
    }
}

extension MenuSectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentsForSearch(searchBar.text!)
    }
}
