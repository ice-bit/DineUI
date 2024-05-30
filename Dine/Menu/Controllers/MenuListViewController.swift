//
//  MenuListViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/05/24.
//

import UIKit
import SwiftUI

class MenuListViewController: UIViewController {
    private var tableView: UITableView!
    
    private var addItemsButton: UIButton!
    let searchController = UISearchController()
    
    private var filteredItems: [MenuItem] = []
    
    private var menuItemCart: [MenuItem] = [] {
        didSet {
            if !menuItemCart.isEmpty {
                navigationItem.rightBarButtonItem?.isHidden = false
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
    }
    
    @objc func tableSelectionButtonTapped(sender: UIBarButtonItem) {
        // TODO: Push the table selection VC
        let chooseTableVC = ChooseTableViewController()
        self.navigationController?.pushViewController(chooseTableVC, animated: true)
    }
    
    
    // MARK: - CUSTOM Methods
    private func setupNavBar() {
        title = "Menu"
        navigationController?.navigationBar.prefersLargeTitles = true
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        let proceedbutton = UIBarButtonItem(title: "Proceed", style: .plain, target: self, action: #selector(proceedButtonAction(_ :)))
        navigationItem.rightBarButtonItem = proceedbutton
        navigationItem.rightBarButtonItem?.isHidden = true // Initially hidden
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func proceedButtonAction(_ sender: UIBarButtonItem) {
        for item in menuItemCart {
            print(item.name)
        }
//        let chooseTableVC = ChooseTableViewController()
//        navigationController?.pushViewController(chooseTableVC, animated: true)
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
    
    private func setupAddButton() {
        addItemsButton = UIButton()
        addItemsButton.setTitleColor(.label, for: .normal)
        addItemsButton.layer.cornerRadius = 12
        addItemsButton.backgroundColor = UIColor(named: "teritiaryBgColor")
        addItemsButton.addTarget(self, action: #selector(tableSelectionButtonTapped), for: .touchUpInside)
        tableView.addSubview(addItemsButton)
        addItemsButton.setTitle("Choose Table", for: .normal)
        view.addSubview(addItemsButton)
        addItemsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addItemsButton.heightAnchor.constraint(equalToConstant: 55),
            addItemsButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            addItemsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            addItemsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        
        tableView.reloadData()
    }
}

extension MenuListViewController: UITableViewDelegate, UITableViewDataSource {
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

extension MenuListViewController: MenuItemDelegate {
    func menuItemDidAdd(_ item: MenuItem) {
        menuItems.append(item)
    }
}

extension MenuListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension MenuListViewController: MenuItemTableViewCellDelegate {
    func menuTableViewCell(_ cell: MenuItemTableViewCell, didChangeItemCount count: Int, for menuItem: MenuItem) {
        menuItemCart.removeAll { $0 == menuItem }
        
        for _ in 0..<count {
            menuItemCart.append(menuItem)
        }
    }
}

#Preview {
    MenuListViewController()
}
