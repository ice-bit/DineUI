//
//  MenuListViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/05/24.
//

import UIKit
import SwiftUI
import Toast

class AddToCartViewController: UIViewController {
    private var tableView: UITableView!
    
    private var addItemsButton: UIButton!
    private var menuCartView: MenuCartView!
    let searchController = UISearchController()
    
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
        
        //setupToast()
        setupTableView()
        view = tableView
        loadMenu()
        setupNavBar()
        configureView()
        setupSearchBar()
        // setupCartView()
    }
    
    // MARK: - CUSTOM Methods
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
            let toast = Toast.default(image: UIImage(systemName: "exclamationmark.circle.fill")!, title: "No Tables Available")
            toast.show(haptic: .error)
            proceedbutton.isEnabled = false
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
    
    // Toast View for the showing number of items
    func showToast() {
        let config = ToastConfiguration(
            direction: .bottom,
            dismissBy: [.time(time: 3.0), .swipe(direction: .natural), .longPress],
            animationTime: 0.2,
            enteringAnimation: .fade(alpha: 1.0),
            exitingAnimation: .fade(alpha: 0.5)
        )
        
        let itemCount = menuItemCart.values.reduce(0, +)
        toast = Toast.default(image: UIImage(systemName: "cart")!, title: "Items \(itemCount)", config: config)
        toast.show()
    }
    
    // Setup toast
    /*private func setupToast() {
        let config = ToastConfiguration(
            direction: .bottom,
            dismissBy: [.time(time: 4.0), .swipe(direction: .natural), .longPress],
            animationTime: 0.2
        )
        
        toast = Toast.default(
            image: UIImage(systemName: "cart")!,
            title: "Items 0",
            config: config
        )
    }*/
    
    private func loadMenu() {
        do {
            let dataAccess = try SQLiteDataAccess.openDatabase()
            let menuService = MenuServiceImpl(databaseAccess: dataAccess)
            let results = try menuService.fetch()
            if let results {
                menuItems = results
            }
        } catch {
            print("Unable to fetch menu items - \(error)")
        }
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
extension AddToCartViewController: UITableViewDelegate, UITableViewDataSource {
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
        showToast()
        
        for (item, count) in menuItemCart {
            print("\(item.name) - \(count)")
        }
    }
}

#Preview {
    AddToCartViewController()
}
