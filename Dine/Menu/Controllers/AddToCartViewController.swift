//
//  MenuListViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/05/24.
//

import UIKit
import SwiftUI

class AddToCartViewController: UIViewController {
    private var tableView: UITableView!
    
    private var addItemsButton: UIButton!
    private var menuCartView: MenuCartView!
    let searchController = UISearchController()
    
    private var filteredItems: [MenuItem] = []
    
    private var menuItemCart: [MenuItem: Int] = [:] {
        didSet {
            if !menuItemCart.isEmpty {
                navigationItem.rightBarButtonItem?.isHidden = false
                menuCartView.isHidden = false
            } else {
                navigationItem.rightBarButtonItem?.isHidden = true
                menuCartView.isHidden = true
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
        setupTableView()
        view = tableView
        loadMenu()
        setupNavBar()
        configureView()
        setupSearchBar()
        setupCartView()
    }
    
    // MARK: - CUSTOM Methods
    private func setupNavBar() {
        title = "Menu"
        navigationController?.navigationBar.prefersLargeTitles = true
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        let proceedbutton = UIBarButtonItem(title: "Proceed", style: .plain, target: self, action: #selector(proceedButtonAction(_:)))
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
        navigationController?.pushViewController(chooseTableVC, animated: true)
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

extension AddToCartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredItems.count : menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemTableViewCell.reuseIdentifier, for: indexPath) as? MenuItemTableViewCell else {
            return UITableViewCell()
        }
        
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
            // Update the cart view to reflect the new count of items
            let totalItemCount = menuItemCart.values.reduce(0, +)
            menuCartView.setItemCount(totalItemCount)
        } else {
            // Remove the menuItem if the count is 0
            menuItemCart.removeValue(forKey: menuItem)
        }
        
        for (item, count) in menuItemCart {
            print("\(item.name) - \(count)")
        }
    }
}

#Preview {
    AddToCartViewController()
}
