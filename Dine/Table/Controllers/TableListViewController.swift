//
//  TableListViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 03/09/24.
//

import UIKit
import Combine

class TableListViewController: UIViewController {
    private let viewModel: TableListViewModel
    
    private var tableView: UITableView!
    private let reuseIdentifier = "TableCell"
    private var cancellables: Set<AnyCancellable> = []
    
    
    init(viewModel: TableListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tables"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        setupNavbar()
        setupTableView()
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavbar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTableButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    /// Action method for the add table button.
    @objc private func addTableButtonTapped(sender: UIBarButtonItem) {
        print("Add table button tapped")
        let addTableController = AddTableFormViewController()
        let navigationController = UINavigationController(rootViewController: addTableController)
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        self.present(navigationController, animated: true)
    }
}

extension TableListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.selectionStyle = .none
        
        var content = cell.defaultContentConfiguration()
        content.text = "Location: \(item.title)"
        content.secondaryText = "Capacity: \(item.subtitle ?? "")"
        content.image = item.image
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            // Handle the delete action
            self.handleDelete(at: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        // Configure the swipe actions
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Edit action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            // Handle the edit action
            self.handleEdit(at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
        
        // Configure the swipe actions
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        return configuration
    }
    
    private func handleDelete(at indexPath: IndexPath) {
        // Code to handle deletion, e.g., removing the item from your data source
        viewModel.deleteTable(at: indexPath.row)
    }

    private func handleEdit(at indexPath: IndexPath) {
        // Code to handle editing, e.g., presenting an edit screen
        // Present your edit view controller here
        guard let table = viewModel.getTable(at: indexPath.row) else { return }
        let editTableViewController = EditTableFormViewController(table: table)
        let navCon = UINavigationController(rootViewController: editTableViewController)
        if let sheet = navCon.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        self.present(navCon, animated: true)
    }

}

/*    private func buildAccessoryButton() -> UIButton {
 var config = UIButton.Configuration.filled()
 config.image = UIImage(systemName: "ellipsis")
 let button = UIButton(configuration: config)
 button.showsMenuAsPrimaryAction = true
 return button
}

private func buildMenu(for row: Int) -> UIMenu? {
 print(#function)
 guard let seletecedTable = viewModel.getTable(at: row) else { return nil }
 
 let editAction = UIAction(title: "Edit") { [weak self] _ in
     let editViewController = EditTableFormViewController(table: seletecedTable)
     self?.present(UINavigationController(rootViewController: editViewController), animated: true)
 }
 
 let deleteAction = UIAction(title: "Delete") { [weak self] _ in
     self?.viewModel.deleteTable(at: row)
 }
 
 let menu = UIMenu(children: [editAction, deleteAction])
 return menu
}*/
