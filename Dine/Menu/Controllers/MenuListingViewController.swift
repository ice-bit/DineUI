//
//  MenuListingViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 23/05/24.
//

import UIKit
import SwiftUI
import Toast

class MenuListingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    private var placeholderLabel: UILabel!
    private var noResultsLabel: UILabel! // Added noResultsLabel
    private let cellReuseID = "MenuItemRow"
    private var category: MenuCategory?
    
//    private var menuData: [MenuItem] = [] {
//        didSet {
//            updateUIForMenuItemData()
//        }
//    }
    
    private var activeCategory: MenuCategory? {
        didSet {
            reloadMenuData()
        }
    }
    private var menuData: [MenuItem]?
    
    // Search essentials
    private var filteredItems: [MenuItem] = []
    private var searchController: UISearchController!
    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }
    
    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var menuDataSource: [MenuListViewModel] = []
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupNoResultsLabel() // Setup noResultsLabel
        title = "Menu List"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        setupNavbar()
        setupPlaceholderLabel()
        //populateMenuData()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(menuItemDidChange(_:)),
            name: .menuItemDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(menuItemDidChange(_:)), name: .mockDataDidChangeNotification, object: nil)
        populateViewModal()
        populateDatasource()
    }
    
    @objc private func menuItemDidChange(_ sender: NotificationCenter) {
        //populateMenuData()
        tableView.reloadData()
    }
    
    private func fetchCategory() {
        do {
            let categoryService = try CategoryServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            guard let result = try? categoryService.fetch() else {
                fatalError("Failed to load")
            }
            category = result[0]
        } catch {
            print("Failed to load categories: \(error)")
        }
    }
    
    @objc private func addMenuItemButtonTapped(_ sender: UIBarButtonItem) {
        print("Add menu button tapped")
        guard let activeCategory else { return }
        let addMenuVC = ItemFormViewController(category: activeCategory) // Unwrapper the option
        addMenuVC.menuItemDelegate = self
        let navController = UINavigationController(rootViewController: addMenuVC)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.largestUndimmedDetentIdentifier = nil
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        self.present(navController, animated: true, completion: nil)
    }
    
    private func setupPlaceholderLabel() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Add Menu Items to Continue"
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
    
    private func reloadMenuData() {
        guard let activeCategory else { return }
        if let dataSet = menuDataSource.first(where: { $0.category.id == activeCategory.id }) {
            menuData?.removeAll()
            menuData = dataSet.menuItem
            tableView.reloadData()
        }
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
    
    // Load methods
    /*private func populateMenuData() {
        guard let category else { return }
        do {
            let dataAccess = try SQLiteDataAccess.openDatabase()
            let menuService = MenuServiceImpl(databaseAccess: dataAccess)
            let results = try menuService.fetch()
            if let results = results {
                let menuItemForSection = results.filter { $0.category.id == category.id }
                DispatchQueue.main.async {
                    self.menuData = menuItemForSection
                    self.tableView.reloadData()
                }
            }
        } catch {
            fatalError("Unable to fetch menu items - \(error)")
        }
    }*/
    
    private func updateUIForMenuItemData() {
        guard let menuData else { return }
        let hasMenuItems = !menuData.isEmpty
        let hasFilteredItems = !filteredItems.isEmpty
        tableView.isHidden = !(hasMenuItems || isFiltering)
        placeholderLabel.isHidden = hasMenuItems || isFiltering
        noResultsLabel.isHidden = hasFilteredItems || !isFiltering
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView = UITableView()
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupNavbar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMenuItemButtonTapped(_:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    
    private func setupSearchBar() {
        searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func filterContentForSearch(_ searchText: String) {
        guard let menuData else { return }
        filteredItems = menuData.filter { (menuData: MenuItem) -> Bool in
            menuData.name.lowercased().contains(searchText.lowercased())
        }
        
        updateUIForMenuItemData()
        tableView.reloadData()
    }
    
    // MARK: - Destructive actions
    private func deleteMenuItem(_ menuItem: MenuItem) {
        do {
            let menuService = try MenuServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let menuController = MenuController(menuService: menuService)
            try menuController.removeItemFromMenu(menuItem)
        } catch {
            print("Failed to perform \(#function) - \(error)")
        }
    }
    
    func presentWarning(for item: MenuItem) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Delete", message: "Do you want to delete the order?", preferredStyle: .alert)
        
        // Create the 'Delete' action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            // Handle the delete action
            print("Order deleted")
            self.deleteMenuItem(item) // delete
            //populateMenuData() // fetch
            tableView.reloadData() // reload to reflect
        }
        
        // Create the 'Add Items' action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add the actions to the alert controller
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func congifureSelectedState(for cell: UITableViewCell) {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.systemGray3
        cell.selectedBackgroundView = selectedBackgroundView
    }
    
    private func presentEditAlertController(for item: MenuItem) {
        let alertController = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = item.name
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Price"
            textField.keyboardType = .decimalPad
            textField.text = String(item.price)
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Description"
            textField.text = item.description
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self else { return }
            guard let firstTextField = alertController.textFields?[0],
                  let secondTextField = alertController.textFields?[1],
                  let descriptionTextField = alertController.textFields?[2] else { return }
            
            guard let name = firstTextField.text,
                  !name.isEmpty else {
                self.showToast("Invalid Name")
                return
            }
            
            guard let priceText = secondTextField.text,
                  !priceText.isEmpty,
                  let price = Double(priceText) else {
                self.showToast("Invalid price")
                return
            }
            
            guard let descriptionText = descriptionTextField.text,
                  !descriptionText.isEmpty else {
                self.showToast("Invalid Description")
                return
            }
            
            // Handle the text input
            print("Name text field: \(name)")
            print("Price text field: \(price)")
            print("Description text field: \(descriptionText)")
            
            let updatedItem = MenuItem(itemId: item.itemId, name: name, price: price, category: item.category, description: descriptionText)
            editItem(updatedItem)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func editItem(_ item: MenuItem) {
        guard let menuData else { return }
        do {
            let menuService = try MenuServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            try menuService.update(item)
            let toast = Toast.text("Updated!")
            toast.show(haptic: .success)
            
            guard let selectedMenuItem = menuData.first(where: { $0 == item }) else { return }
            selectedMenuItem.name = item.name
            selectedMenuItem.price = item.price
            
            tableView.reloadData()
        } catch {
            fatalError("Updating menu item failed!") // Will be removed in production!
        }
    }
    
    private func showToast(_ message: String) {
        let toast = Toast.text(message)
        toast.show(haptic: .error)
    }
    
    private func populateViewModal() {
        do {
            let dbAccess = try SQLiteDataAccess.openDatabase()
            let categoryService = CategoryServiceImpl(databaseAccess: dbAccess)
            let menuService = MenuServiceImpl(databaseAccess: dbAccess)
            let categoriesResult = try categoryService.fetch()
            let menuItemsResult = try menuService.fetch()
            if let categories = categoriesResult, let menuItems = menuItemsResult {
                for category in categories {
                    let filteredItems = menuItems.filter { $0.category.id == category.id }
                    let menuListViewModal = MenuListViewModel(category: category, menuItem: filteredItems)
                    menuDataSource.append(menuListViewModal)
                }
            }
        } catch {
            
        }
    }
    
    private func populateDatasource() {
        activeCategory = menuDataSource[0].category
        menuData = menuDataSource[0].menuItem
    }
}

extension MenuListingViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearch(searchBar.text!)
    }
}

extension MenuListingViewController: MenuItemDelegate {
    func menuDidChange(_ item: MenuItem) {
        menuData?.append(item) // Gonna boom
        tableView.reloadData()
    }
}

extension MenuListingViewController {
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let activeCategory else { return nil }
        let headerView = MenuListHeader()
        headerView.title.text = activeCategory.categoryName
        headerView.onHeaderTapped = onCategoryHeaderTapped
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menuData else { return 0 }
        if menuData.isEmpty {
            return 1
        }
        return isFiltering ? filteredItems.count : menuData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menuData else { return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        if menuData.isEmpty {
            let leadingMargin = tableView.frame.width / 5
            cell.contentConfiguration = UIHostingConfiguration {
                NoResultCellView()
            }
            .margins(.leading, leadingMargin)
            return cell
        }
        let menuItem = isFiltering ? filteredItems[indexPath.row] : menuData[indexPath.row]
        cell.contentConfiguration = UIHostingConfiguration {
            MenuItemRow(menuItem: menuItem)
        }
        .margins(.horizontal, 20)
        .background(Color(.systemGroupedBackground))
        cell.backgroundColor = .systemGroupedBackground
        congifureSelectedState(for: cell)
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell = tableView.cellForRow(at: indexPath) else { return indexPath }
        congifureSelectedState(for: cell)
        return indexPath
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuData else { return }
        guard !menuData.isEmpty else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = isFiltering ? filteredItems[indexPath.row] : menuData[indexPath.row]
//        let menuDetailViewHostVC = UIHostingController(rootView: MenuDetailView(menuItem: menuItem))
        let menuDetailViewController = MenuDetailViewController(menu: menuItem)
        navigationController?.pushViewController(menuDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let menuData else { return nil }
        guard !menuData.isEmpty else { return nil }
        let item = menuData[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self else { return }
            print("Delete action")
            presentWarning(for: item)
            
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let menuData else { return nil }
        guard !menuData.isEmpty else { return nil }
        let item = menuData[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] action in
                // Handle action 1
                guard let self else { return }
                print("Edit context menu action")
                self.presentEditAlertController(for: item)
                
            }
            
            return UIMenu(title: "", children: [editAction])
        }
    }
    
    private func onCategoryHeaderTapped() {
        print(#function)
        do {
            let dbAccess = try SQLiteDataAccess.openDatabase()
            let menuService = MenuServiceImpl(databaseAccess: dbAccess)
            let menuSectionViewcontroller = MenuSectionViewController(menuService: menuService)
            menuSectionViewcontroller.didSelectCategory = didSelectedCategory
            self.present(UINavigationController(rootViewController: menuSectionViewcontroller), animated: true)
        } catch {
            fatalError("Failed to buid menu service \(#function)")
        }
    }
    
    private func didSelectedCategory(_ category: MenuCategory) {
        print(#function)
        activeCategory = category
    }
    
}

#Preview{
    UINavigationController(rootViewController: MenuListingViewController())
}

struct MenuListViewModel {
    let category: MenuCategory
    let menuItem: [MenuItem]
}
