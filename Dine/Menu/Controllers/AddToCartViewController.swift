//
//  MenuListViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/05/24.
//

import UIKit
import SwiftUI
import Toast

struct MenuItemTableViewViewModal {
    let sectionHeader: String
    let items: [MenuItem]
}

class AddToCartViewController: UIViewController {
    private var tableView: UITableView!
    
    private var addItemsButton: UIButton!
    private var noResultsLabel: UILabel! // Added noResultsLabel
    private var menuCartView: MenuCartView!
    let searchController = UISearchController()
    
    private var catalogButton: UIButton!
    
    /// View that represents toast
    private var toast: Toast!
    
    // BarButton
    private var proceedbutton: UIBarButtonItem!
    
    private var filteredItems: [MenuItem] = []
    
    private var menuItemCart: [MenuItem: Int] = [:] {
        didSet {
            if !menuItemCart.isEmpty {
                navigationItem.rightBarButtonItem?.isHidden = false
                // menuCartView.isHidden = false
            } else {
                navigationItem.rightBarButtonItem?.isHidden = true
                // menuCartView.isHidden = true
            }
            
        }
    }
    
    private var tableViewViewModal: [MenuItemTableViewViewModal] = []
    private var menuCategories: [MenuCategory] = []
    
    private var menuItems: [MenuItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        loadMenu()
        populateCategories()
        populateTableViewVM()
        setupNavBar()
        configureView()
        setupSearchBar()
        setupCatalogButton()
        setupNoResultsLabel() // Setup noResultsLabel
    }
    
    // MARK: - CUSTOM Methods
    
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
    
    private func populateCategories() {
        do {
            let categoryService = try CategoryServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let result = try categoryService.fetch()
            if let result {
                menuCategories = result
            }
        } catch {
            print("Failed to fetch 'MenuCategory' for database: Failed with error: \(error)")
        }
    }
    
    private func populateTableViewVM() {
        var tableViewViewModals = [MenuItemTableViewViewModal]()
        for category in menuCategories {
            let filteredItems = menuItems.filter { $0.category.id == category.id }
            let tableViewVM = MenuItemTableViewViewModal(sectionHeader: category.categoryName, items: filteredItems)
            tableViewViewModals.append(tableViewVM)
        }
        
        tableViewViewModal = tableViewViewModals
    }
    
    private func setupNavBar() {
        title = "Menu"
        navigationController?.navigationBar.prefersLargeTitles = true
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        proceedbutton = UIBarButtonItem(title: "Proceed", style: .plain, target: self, action: #selector(proceedButtonAction(_:)))
        navigationItem.rightBarButtonItem = proceedbutton
        navigationItem.rightBarButtonItem?.isHidden = true // Initially hidden
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func proceedButtonAction(_ sender: UIBarButtonItem) {
        for (menuItem, numOfItem) in menuItemCart {
            print("\(menuItem.name) - \(numOfItem)")
        }
        
        let chooseTableVC = ChooseTableViewController(selectedMenuItems: menuItemCart)
        // Check if the tables are available
        if chooseTableVC.isTablesAvailable() {
            navigationController?.pushViewController(chooseTableVC, animated: true)
        } else {
            /*let alert = UIAlertController(title: "Cannot Proceed", message: "No available tables.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)*/
            showErrorToast(with: "No Available Tables")
            proceedbutton.isEnabled = false
        }
    }
    
    private func showErrorToast(with message: String) {
        if let toast {
            toast.close(animated: false)
        }
        toast = Toast.text(message)
        toast.show(haptic: .warning)
    }
    
    private func updateUIForNoData() {
        let hasMenuItems = !menuItems.isEmpty
        let hasFilteredItems = !filteredItems.isEmpty
        tableView.isHidden = !(hasMenuItems || isFiltering)
        noResultsLabel.isHidden = hasFilteredItems || !isFiltering
    }
    
    private func setupCartView() {
        menuCartView = MenuCartView()
        menuCartView.layer.cornerRadius = 30 // Half of the height (60 / 2)
        menuCartView.backgroundColor = .secondarySystemBackground
        menuCartView.isHidden = true
        menuCartView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(menuCartView)
        
        NSLayoutConstraint.activate([
            menuCartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            menuCartView.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, multiplier: 0.43),
            menuCartView.heightAnchor.constraint(equalToConstant: 60),
            menuCartView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // Toast View for the showing number of items
    func showCartToast() {
        if let toast {
            toast.close(animated: true)
        }
        let config = ToastConfiguration(
            direction: .bottom,
            dismissBy: [.time(time: 2.4)],
            animationTime: 0.2,
            enteringAnimation: .fade(alpha: 1.0),
            exitingAnimation: .fade(alpha: 0.5)
        )
        
        let itemCount = menuItemCart.values.reduce(0, +)
        toast = Toast.default(image: UIImage(systemName: "cart")!, title: "Items \(itemCount)", config: config)
        toast.show()
    }
    
    private func loadMenu() {
        do {
            let dataAccess = try SQLiteDataAccess.openDatabase()
            let menuService = MenuServiceImpl(databaseAccess: dataAccess)
            let results = try menuService.fetch()
            if let results {
                menuItems = results
                if menuItems.isEmpty {
                    presentEmptyMenuAlert(on: self)
                }
            }
        } catch {
            fatalError("Unable to fetch menu items - \(error)")
        }
    }
    
    private func configureView() {
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MenuItemTableViewCell.self, forCellReuseIdentifier: MenuItemTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        
        // TableView Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    
    
    // MARK: - SearchBar Methods
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredItems = menuItems.filter { (menuItem: MenuItem) -> Bool in
            return menuItem.name.lowercased().contains(searchText.lowercased())
        }
        
        updateUIForNoData()
        tableView.reloadData()
    }
    
    func presentEmptyMenuAlert(on viewController: UIViewController) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Empty Menu", message: "Add menu items to continue?", preferredStyle: .alert)
        
        // Create the 'cancel' action
        /*let cancelAction = UIAlertAction(title: "cancel", style: .destructive) { [weak self] _ in
            guard let self else { return }
            // Handle the delete action
            print("Cancelled ordering")
            self.dismiss(animated: true)
        }
        
        // Create the 'Add Items' action
        let addItemsAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            // Handle the add items action
            guard let self else { return }
            print("Add items")
            self.dismiss(animated: true) {
                // Select the menu screen
                self.presentMenuSection()
            }
        }
        
        // Add the actions to the alert controller
        alertController.addAction(cancelAction)
        alertController.addAction(addItemsAction)*/
        let continueAction = UIAlertAction(title: "Continue", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        
        alertController.addAction(continueAction)
        
        // Present the alert controller
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func presentMenuSection() {
        do {
            let menuService = try MenuServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let menuSectionViewController = MenuSectionViewController(menuService: menuService)
            navigationController?.present(menuSectionViewController, animated: true)
        } catch {
            fatalError("Failed to build menuService @\(#line): \(error)")
        }
    }

    var showCatalogMenu: UIMenu {
        var children = [UIMenuElement]()
        print("Show catalog")
        for vm in self.tableViewViewModal {
            let menuElement = UIAction(title: vm.sectionHeader) { [weak self] _ in
                guard let self else { return }
                print("\(vm.sectionHeader) selected")
                if let index = menuCategories.firstIndex(where: { $0.categoryName == vm.sectionHeader }) {
                    let indexPath = IndexPath(row: 0, section: index)
                    tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
            children.append(menuElement)
        }
        let menu = UIMenu(title: "Catalog", options: .singleSelection, children: children)
        return menu
    }
    
    private func setupCatalogButton() {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .label
        config.baseForegroundColor = .systemBackground
        config.buttonSize = .large
        config.image = UIImage(systemName: "book.pages")
        catalogButton = UIButton(configuration: config)
        catalogButton.translatesAutoresizingMaskIntoConstraints = false
        catalogButton.menu  = showCatalogMenu
        catalogButton.showsMenuAsPrimaryAction = true
        tableView.addSubview(catalogButton)
        
        NSLayoutConstraint.activate([
            catalogButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            catalogButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            catalogButton.widthAnchor.constraint(equalToConstant: 60),
            catalogButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - TableView built-in methods
extension AddToCartViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        isFiltering ? filteredItems.count : tableViewViewModal.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredItems.count : tableViewViewModal[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemTableViewCell.reuseIdentifier, for: indexPath) as? MenuItemTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.backgroundColor = .systemGroupedBackground
        
        let menuItem = isFiltering ? filteredItems[indexPath.row] : tableViewViewModal[indexPath.section].items[indexPath.row]
        cell.configure(menuItem: menuItem)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem: MenuItem
        if isFiltering {
            menuItem = filteredItems[indexPath.row]
        } else {
            menuItem = tableViewViewModal[indexPath.section].items[indexPath.row]
        }
        let detailVC = MenuDetailViewController(menu: menuItem)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return ""
        }
        return tableViewViewModal[section].sectionHeader
    }
}

extension AddToCartViewController: MenuItemDelegate {
    func menuItemDidAdd(_ item: MenuItem) {
        menuItems.append(item)
    }
}

extension AddToCartViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension AddToCartViewController: MenuItemTableViewCellDelegate {
    func menuTableViewCell(_ cell: MenuItemTableViewCell, didChangeItemCount count: Int, for menuItem: MenuItem) {
        // Remove the key if the count is zero.
        if count > 0 {
            menuItemCart[menuItem] = count
        } else {
            // Remove the menuItem if the count is 0
            menuItemCart.removeValue(forKey: menuItem)
        }
        // Note - Ensure the MenuItem count is updated
        if let index = menuItems.firstIndex(where: { $0 == menuItem }) {
            menuItems[index].count = count
        }
        
        if let index = filteredItems.firstIndex(where: { $0 == menuItem }) {
            filteredItems[index].count = count
        }
        
        // menuCartView.setItemCount(menuItemCart.values.reduce(0, +))
        
        // Update the toast view with proper item count
        showCartToast()
        
        for (item, count) in menuItemCart {
            print("\(item.name) - \(count)")
        }
    }
}

#Preview {
    AddToCartViewController()
}
