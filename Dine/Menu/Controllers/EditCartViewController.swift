//
//  EditCartViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 25/06/24.
//

import UIKit
import Toast

class EditCartViewController: UIViewController {
    private var menuItems: [MenuItem] = []
    private var cart: [MenuItem: Int]
    private var order: Order

    private var tableView: UITableView!
    private var menuCartView: MenuCartView!
    let searchController = UISearchController()
    
    private var filteredItems: [MenuItem] = []
    
    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    init(cart: [MenuItem: Int], order: Order) {
        self.cart = cart
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupToast()
        prepareForEditing()
        setupTableView()
        view = tableView
        setupNavBar()
        configureView()
        setupSearchBar()
        print("ORDER: \(order.orderIdValue)")
    }
    
    // MARK: - CUSTOM Methods
    private func setupNavBar() {
        title = "Menu"
        navigationController?.navigationBar.prefersLargeTitles = true
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func doneAction(_ sender: UIBarButtonItem) {
        if addItems() {
            // Notify the observers for UI changes
             NotificationCenter.default.post(name: .cartDidChangeNotification, object: nil, userInfo: ["MenuItems": cart]) // Filter upon recieving the payload (check for items with quantity zero).
            NotificationCenter.default.post(name: .metricDataDidChangeNotification, object: nil)
            
            self.dismiss(animated: true)
            let toast = Toast.default(image: UIImage(systemName: "checkmark")!, title: "Updated")
            toast.show(haptic: .success)
        }
    }
    
    private func addItems() -> Bool {
        do {
            let orderService = try OrderServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            for (item, quantity) in cart {
                print("[\(item.name): \(quantity)]\n")
                let orderItem = OrderItem(
                    orderID: order.orderIdValue,
                    menuItemID: item.itemId,
                    menuItemName: item.name,
                    price: item.price,
                    categoryId: item.category.id,
                    quantity: quantity
                )
                // Insert into DB join table
                try orderService.add(orderItem)
            }
            return true
        } catch {
            print("Failed to perform \(#function) - \(error)")
            return false
        }
    }
    
    private func prepareForEditing() {
        deleteOrderedItems()
        populateMenuItems()
    }
    
    private func populateMenuItems() {
        do {
            let menuService = try MenuServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            guard let result = try? menuService.fetch() else { return }
            menuItems = result
            for (item, quantity) in cart {
                if let index = menuItems.firstIndex(where: { $0.itemId == item.itemId }) {
                    menuItems[index].count = quantity
                }
            }
        } catch {
            print("Failed to perform \(#function) - \(error)")
        }
    }
    
    func deleteOrderedItems() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            try databaseAccess.delete(from: DatabaseTables.orderMenuItemTable.rawValue, where: "OrderID = '\(order.orderIdValue.uuidString)'")
        } catch {
            print("Failed to perform \(#function) - \(error)")
        }
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

    
    private func configureView() {
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.register(MenuItemTableViewCell.self, forCellReuseIdentifier: MenuItemTableViewCell.reuseIdentifier)
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
        
        tableView.reloadData()
    }
}

// MARK: - TableView built-in methods
extension EditCartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredItems.count : menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemTableViewCell.reuseIdentifier, for: indexPath) as? MenuItemTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let menuItem = isFiltering ? filteredItems[indexPath.row] : menuItems[indexPath.row]
        cell.configure(menuItem: menuItem)
        cell.delegate = self
        return cell
    }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let menuItem: MenuItem
         if isFiltering {
             menuItem = filteredItems[indexPath.row]
         } else {
             menuItem = menuItems[indexPath.row]
         }
         let detailVC = MenuDetailViewController(menu: menuItem)
         navigationController?.pushViewController(detailVC, animated: true)
     }
}

extension EditCartViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension EditCartViewController: MenuItemTableViewCellDelegate {
    func menuTableViewCell(_ cell: MenuItemTableViewCell, didChangeItemCount count: Int, for menuItem: MenuItem) {
        // Remove the key if the count is zero.
        if count > 0 {
            cart[menuItem] = count
        } else {
            // Remove the menuItem if the count is 0
             cart.removeValue(forKey: menuItem)
        }
        
        // Note - Ensure the MenuItem count is updated
        if let index = menuItems.firstIndex(where: { $0 == menuItem }) {
            menuItems[index].count = count
        }
        
        if let index = filteredItems.firstIndex(where: { $0 == menuItem }) {
            filteredItems[index].count = count
        }
        
        // Update UI here to reflect the changes...
        
        for (item, count) in cart {
            print("\(item.name) - \(count)")
        }
        print("------------------------------")
    }
}
