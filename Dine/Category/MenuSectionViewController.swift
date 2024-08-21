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
    private var noResultsLabel: UILabel! // Added noResultsLabel
    private var addButton: UIBarButtonItem!
    private var categories: [MenuCategory] = [] {
        didSet {
            updateUIForData()
        }
    }
    
    // Search Components
    private var filteredCategories: [MenuCategory] = []
    private var searchController: UISearchController!
    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }
    
    var didSelectCategory: ((MenuCategory) -> Void)?
    
    // MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        setupCollectionView()
        setupPlaceholderLabel()
        setupNoResultsLabel() // Setup noResultsLabel
        setupSearchBar()
        setupBarButton()
        populateCategoryData()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(categoryDataDidChange(_:)),
            name: .categoryDataDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(mockDataDidChange(_:)), name: .mockDataDidChangeNotification, object: nil)
    }
    
    @objc private func mockDataDidChange(_ sender: Notification) {
        print("Reloading Category Collection View")
        populateCategoryData()
        collectionView.reloadData()
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
        let hasFilteredItems = !filteredCategories.isEmpty
        collectionView.isHidden = !(hasCategories || isFiltering)
        placeholderLabel.isHidden = hasCategories || isFiltering
        noResultsLabel.isHidden = hasFilteredItems || !isFiltering
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
    
    private func setupNoResultsLabel() {
        noResultsLabel = UILabel()
        noResultsLabel.text = "No Results Found"
        noResultsLabel.textColor = .systemGray3
        noResultsLabel.font = .preferredFont(forTextStyle: .title1)
        noResultsLabel.textAlignment = .center
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noResultsLabel)
        
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Initially hidden
        noResultsLabel.isHidden = true
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
        addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonAction(_:))
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addButtonAction(_ sender: UIBarButtonItem) {
        print(#function)
        let addSectionViewController = AddSectionViewController()
        let navCon = UINavigationController(rootViewController: addSectionViewController)
        if let sheet = navCon.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        self.present(navCon, animated: true)
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
        collectionView.backgroundColor = .systemGroupedBackground
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
        presentWarning(for: item)
    }
    
    private func filterContentsForSearch(_ searchText: String) {
        filteredCategories = categories.filter{ (category: MenuCategory) -> Bool in
            category.categoryName.lowercased().contains(searchText.lowercased())
        }
        
        updateUIForData()
        collectionView.reloadData()
    }
    
    func presentWarning(for item: MenuCategory) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Delete", message: "Do you want to delete the order?", preferredStyle: .alert)
        
        // Create the 'Delete' action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            // Handle the delete action
            print("Order deleted")
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
        
        // Create the 'Add Items' action
        let addItemsAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add the actions to the alert controller
        alertController.addAction(addItemsAction)
        alertController.addAction(deleteAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isFiltering ? filteredCategories.count : categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = isFiltering ? filteredCategories[indexPath.item] : categories[indexPath.item]
        let cell =  collectionView.dequeueConfiguredReusableCell(using: sectionViewRegistration, for: indexPath, item: item)
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .systemGray4
        cell.selectedBackgroundView = selectedBackgroundView
        return cell
    }
    
    private var sectionViewRegistration: UICollectionView.CellRegistration<UICollectionViewCell, MenuCategory> = {
        .init { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                SectionView(catergory: item)
            }
            .margins(.horizontal, 20)
            .margins(.vertical, 8)
        }
    }()
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = isFiltering ? filteredCategories[indexPath.item] : categories[indexPath.item]
        didSelectCategory?(item)
        self.dismiss(animated: true)
        /*let sectionDetailVC = MenuListingViewController(category: item)
        navigationController?.pushViewController(sectionDetailVC, animated: true)*/
    }
}

extension MenuSectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentsForSearch(searchBar.text!)
    }
}
