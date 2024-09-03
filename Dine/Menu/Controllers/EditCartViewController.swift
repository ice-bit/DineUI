//
//  EditCartViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 25/06/24.
//

import UIKit
import Toast
import Combine

class EditCartViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: EditCartViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
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
    
    // MARK: - Initialization
    init(cart: [MenuItem: Int], order: Order) {
        self.viewModel = EditCartViewModel(cart: cart, order: order)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareForEditing()
        setupTableView()
        setupNavBar()
        configureView()
        setupSearchBar()
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.$sections
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Custom Methods
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
        viewModel.addItems { [weak self] success in
            guard let self = self else { return }
            if success {
                NotificationCenter.default.post(name: .cartDidChangeNotification, object: nil, userInfo: ["MenuItems": self.viewModel.cart])
                NotificationCenter.default.post(name: .metricDataDidChangeNotification, object: nil)
                
                self.dismiss(animated: true)
                let toast = Toast.default(image: UIImage(systemName: "checkmark")!, title: "Updated")
                toast.show(haptic: .success)
            } else {
                // Handle failure (e.g., show an error toast)
                let toast = Toast.default(image: UIImage(systemName: "xmark.circle")!, title: "Failed to Update")
                toast.show(haptic: .error)
            }
        }
    }
    
    private func prepareForEditing() {
        viewModel.deleteOrderedItems()
    }
    
    private func configureView() {
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped) // Use grouped style for sections
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuItemCell.self, forCellReuseIdentifier: MenuItemCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
        filteredItems = viewModel.sections.flatMap { $0.items }.filter { (menuItem: MenuItem) -> Bool in
            return menuItem.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension EditCartViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering ? 1 : viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredItems.count
        }
        return viewModel.sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return "Search Results"
        }
        return viewModel.sections[section].category.categoryName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemCell.reuseIdentifier, for: indexPath) as? MenuItemCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        let menuItem: MenuItem
        if isFiltering {
            menuItem = filteredItems[indexPath.row]
        } else {
            menuItem = viewModel.sections[indexPath.section].items[indexPath.row]
        }
        
        cell.configure(menuItem: menuItem)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EditCartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem: MenuItem
        if isFiltering {
            menuItem = filteredItems[indexPath.row]
        } else {
            menuItem = viewModel.sections[indexPath.section].items[indexPath.row]
        }
        let detailVC = MenuDetailViewController(menu: menuItem)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension EditCartViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text ?? "")
    }
}

// MARK: - MenuItemTableViewCellDelegate
extension EditCartViewController: MenuItemTableViewCellDelegate {
    func menuTableViewCell(_ cell: MenuItemCell, didChangeItemCount count: Int, for menuItem: MenuItem) {
        viewModel.updateCart(for: menuItem, quantity: count)
    }
}

