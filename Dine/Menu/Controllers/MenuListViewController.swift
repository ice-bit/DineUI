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
    
    private var menuItemCart: [MenuItem] = []
    
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
        setupNavBar()
//        setupAddButton()
        configureView()
        loadMenu()
    }
    
    // MARK: - OBJC
    @objc func presentAddMenuSheet() {
        let addItemSheetVC = AddItemViewController()
        addItemSheetVC.menuItemDelegate = self
        if let sheet = addItemSheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        
        present(addItemSheetVC, animated: true)
    }
    
    @objc func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func tableSelectionButtonTapped(sender: UIBarButtonItem) {
        // TODO: Push the table selection VC
        let chooseTableVC = ChooseTableViewController()
        self.navigationController?.pushViewController(chooseTableVC, animated: true)
    }
    
    @objc func doneButtonTapped(sender: UIBarButtonItem) {
        print("Done button for add items tapped!")
        var itemCart = [MenuItem]()
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        for rowIndex in 0..<numberOfRows {
            let menuItem = menuItems[rowIndex]
            let indexPath = IndexPath(row: rowIndex, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! MenuItemCell
            for _ in 0..<cell.itemCount {
                itemCart.append(menuItem)
            }
        }
        
        for item in itemCart {
            print("\(item.name)")
        }
        
        guard let databaseAccess = try? SQLiteDataAccess.openDatabase() else {
            print("Failed to open database connection!")
            // TODO: Do something if the database connection failed
            return
        }
        
        // TODO: Comeback after building table
        
        let orderService = OrderServiceImpl(databaseAccess: databaseAccess)
        let tableService = TableServiceImpl(databaseAccess: databaseAccess)
        
        let orderController = OrderController(orderService: orderService, tableService: tableService)
    }
    
    // MARK: - CUSTOM Methods
    private func setupNavBar() {
        title = "Menu"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddMenuSheet))
        //        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
        
        navigationItem.rightBarButtonItem = cancelButton
        
        setupSearchBar()
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
        tableView.register(MenuItemCell.self, forCellReuseIdentifier: MenuItemCell.reuseIdentifier)
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
        if isFiltering {
            return filteredItems.count
        }
        
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemCell.reuseIdentifier, for: indexPath) as? MenuItemCell else {
            return UITableViewCell()
        }
        
        let menuItem: MenuItem
        if isFiltering {
            menuItem = filteredItems[indexPath.row]
        } else {
            menuItem = menuItems[indexPath.row]
        }
        
        cell.configure(itemImage: .burger, isFoodVeg: true, title: menuItem.name, price: menuItem.price, secondaryTitle: "Lorem ipsum")
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        122
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

#Preview {
    MenuListViewController()
}
