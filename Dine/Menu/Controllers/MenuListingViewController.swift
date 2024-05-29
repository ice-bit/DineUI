//
//  MenuListingViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 23/05/24.
//

import UIKit
import SwiftUI

class MenuListingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    private var searchController: UISearchController!
    private let cellReuseID = "MenuItemRow"
    private let activeSection: MenuSection
    
    private var menuData: [MenuItem] = []
    
    init(activeSection: MenuSection) {
        self.activeSection = activeSection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        populateMenuData()
        setupTableView()
        view = tableView
        title = activeSection.rawValue
        navigationController?.navigationBar.prefersLargeTitles = true
        setupSearchBar()
        setupNavbar()
        NotificationCenter.default.addObserver(self, selector: #selector(didAddMenuItem(_ :)), name: .didAddMenuItemNotification, object: nil)
    }
    
    @objc private func didAddMenuItem(_ sender: NotificationCenter) {
        populateMenuData()
        tableView.reloadData()
    }
    
    @objc private func addMenuItemButtonTapped(_ sender: UIBarButtonItem) {
        print("Add menu button tapped")
        let addMenuVC = AddItemViewController()
        if let sheet = addMenuVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        
        present(addMenuVC, animated: true)
    }
    
    // Load methods
    private func populateMenuData() {
        do {
            let dataAccess = try SQLiteDataAccess.openDatabase()
            let menuService = MenuServiceImpl(databaseAccess: dataAccess)
            let results = try menuService.fetch()
            if let results = results {
                let menuItemForSection = results.filter { $0.menuSection == activeSection }
                menuData = menuItemForSection
            }
        } catch {
            print("Unable to fetch menu items - \(error)")
        }
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupNavbar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMenuItemButtonTapped(_ :)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    
    private func setupSearchBar() {
        searchController = UISearchController()
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Search Items"
        definesPresentationContext = true
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        let menuItem = menuData[indexPath.row]
        cell.contentConfiguration = UIHostingConfiguration {
            MenuItemRow(menuItem: menuItem)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = menuData[indexPath.row] // TODO: Provide real data
        let detailVC = MenuDetailViewController(menu: menuItem)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

#Preview{
    UINavigationController(rootViewController: MenuListingViewController(activeSection: .mainCourse))
}
