//
//  MenuListingViewController.swift
//  Dine
//
//  Created by ice on 23/05/24.
//

import UIKit
import SwiftUI
import Toast
import Combine

class MenuListingViewController: UIViewController {
    
    var viewModal: MenuViewModal = MenuViewModal()
    private var cancellables = Set<AnyCancellable>()
    
    private var tableView: UITableView!
    private var placeholderLabel: UILabel!
    private var noResultsLabel: UILabel! // Added noResultsLabel
    private let cellReuseID = "MenuItemRow"
    private var searchController: UISearchController!
    private var lastChangedMenuItem: MenuItem?
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Menu"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        setupSearchBar()
        setupNoResultsLabel() // Setup noResultsLabel
        setupPlaceholderLabel()
        setupTableView()
        setupNavBarButton()
        setupBindings()
        //updateUIForMenuItemData()
    }
    
    private func setupNavBarButton() {
        // Create actions for the menu items
        let categoryFilter = UIAction(title: "View Categories") { action in
            print("view categories selected")
            let categoryListingVC = MenuSectionViewController(isSelectable: false)
            self.navigationController?.present(UINavigationController(rootViewController: categoryListingVC), animated: true)
        }

        // Create the menu
        let menu = UIMenu(children: [categoryFilter])

        let menuBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease"), menu: menu)
        // Set it as the right bar button item
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMenuItemButtonTapped(_:)))
        
        navigationItem.rightBarButtonItems = [addButton/*, menuBarButtonItem*/]
    }
    
    private func setupBindings() {
        // Bind the filtered menu items to the table view reload
        viewModal.$menuSections
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.scrollToUpdatedMenuItem()
            }
            .store(in: &cancellables)
    }
    
    @objc private func addMenuItemButtonTapped(_ sender: UIBarButtonItem) {
        print("Add menu button tapped")
        let addMenuVC = AddItemFormViewController() // Unwrapper the option
        addMenuVC.didUpdateMenuItem = didUpdateMenuItem
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
    
    private func didUpdateMenuItem(_ menuItem: MenuItem) {
        print(#function)
        lastChangedMenuItem = menuItem
    }
    
    private func scrollToUpdatedMenuItem() {
        guard let menuItem = lastChangedMenuItem else { return }
        // Find the section where the item was added
        guard let sectionIndex = viewModal.menuSections.firstIndex(where: { $0.header == menuItem.category.categoryName }) else {
            print("Section not found")
            return
        }
        
        // Find the index of the newly added item within that section
        guard let rowIndex = viewModal.menuSections[sectionIndex].items.firstIndex(where: { $0.itemId == menuItem.itemId }) else {
            print("Item not found in the section")
            return
        }
        
        // Create an IndexPath for the new item
        let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
        
        // Scroll to the newly added item
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
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
    
    private func updateUIForMenuItemData() {
        let menuData = viewModal.menuItems
        let hasMenuItems = !menuData.isEmpty
        
        // Handle tableView visibility
        tableView.isHidden = !hasMenuItems
        
        // Handle placeholder label visibility
        placeholderLabel.isHidden = hasMenuItems
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
    
    private func setupSearchBar() {
        searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
        let menuData = viewModal.menuItems
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
}

extension MenuListingViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        viewModal.filterContentForSearch(searchController)
//        updateUIForMenuItemData()
    }
    
}

extension MenuListingViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModal.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModal.menuSections[section].header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModal.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItems = viewModal.items(in: indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        if menuItems.isEmpty {
            let leadingMargin = tableView.frame.width / 5
            cell.contentConfiguration = UIHostingConfiguration {
                NoResultCellView()
            }
            .margins(.leading, leadingMargin)
            return cell
        }
        let menuItem = menuItems[indexPath.row]
        cell.contentConfiguration = UIHostingConfiguration {
            MenuItemRow(menuItem: menuItem)
        }
        .margins(.horizontal, 20)
        .background(Color(.systemGroupedBackground))
        cell.backgroundColor = .systemGroupedBackground
        congifureSelectedState(for: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItems = viewModal.items(in: indexPath.section)
        guard !menuItems.isEmpty else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = menuItems[indexPath.row]
        let menuDetailViewController = MenuDetailViewController(menu: menuItem)
        navigationController?.pushViewController(menuDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let menuItems = viewModal.items(in: indexPath.section)
        let item = menuItems[indexPath.row]
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
        let menuItems = viewModal.items(in: indexPath.section)
        let item = menuItems[indexPath.row]
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
    
}

#Preview{
    UINavigationController(rootViewController: MenuListingViewController())
}

