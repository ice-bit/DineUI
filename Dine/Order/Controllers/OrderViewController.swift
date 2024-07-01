//
//  OrderViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//
import UIKit
import SwiftUI
import Toast

class OrderViewController: UIViewController {
    // MARK: - Properties
    
    private let orderService: OrderService
    private let menuService: MenuService
    
    // Cell reuse identifier
    private let cellReuseIdentifier: String = "MenuCellView"
    
    // UI Elements
    private var tableView: UITableView!
    private var placeholderLabel: UILabel!
    
    // Bar Buttons
    private var addBarButton: UIBarButtonItem!
    private var quickMenuBarButton: UIBarButtonItem!
    private var doneBarButton: UIBarButtonItem!
    private var billButton: UIBarButtonItem!
    private var deleteButton: UIBarButtonItem!
    
    // Data
    private var orderData: [Order] = [] {
        didSet {
            updateUIForOrderData()
        }
    }
    
    private var selectedOrders: [Order] = [] {
        didSet {
            updateToolbarButtonsState()
        }
    }
    
    // MARK: - Initializers
    init(orderService: OrderService, menuService: MenuService) {
        self.orderService = orderService
        self.menuService = menuService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View LifeCycle Methods
    override func viewDidLoad() {
        print(UUID())
        super.viewDidLoad()
        setupAppearance()
        setupNavigationBar()
        setupTableView()
        setupPlaceholderLabel()
        loadOrderData()
        setupToolbar()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAddOrder(_:)),
            name: .orderDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange(_:)),
            name: .cartDidChangeNotification,
            object: nil
        )
    }
    
    // MARK: - UI Setup Methods
    private func setupNavigationBar() {
        addBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addOrder))
        doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBarButtonAction(_:)))
        createMenuBarButton()
        navigationItem.rightBarButtonItems = [addBarButton, quickMenuBarButton]
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        // tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupPlaceholderLabel() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Add Orders to Continue"
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
    
    private func setupToolbar() {
        billButton = UIBarButtonItem(title: "Bill", style: .plain, target: self, action: #selector(billButtonAction(_:)))
        deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteButtonAction(_:)))
        
        billButton.isEnabled = false
        deleteButton.isEnabled = false

        toolbarItems = [ // Removed bill button
            UIBarButtonItem(systemItem: .flexibleSpace),
            deleteButton
        ]
    }
    
    private func setupAppearance() {
        self.title = "Orders"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func createMenuBarButton() {
        let selectAction = UIAction(title: "Select Orders", image: UIImage(systemName: "checkmark.circle")) { [weak self] _ in
            self?.setSelection(true, animated: true)
        }
        
        let selectAllAction = UIAction(title: "Select All Orders", image: UIImage(systemName: "checkmark.rectangle.stack.fill")) { [weak self] _ in
            self?.setSelection(true, animated: true)
            self?.selectAllOrders()
        }
        
        let menu = UIMenu(children: [selectAction, selectAllAction])
        quickMenuBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
    }
    
    // MARK: - Data Methods
    private func loadOrderData() {
        do {
            let dataAccess = try SQLiteDataAccess.openDatabase()
            let orderService = OrderServiceImpl(databaseAccess: dataAccess)
            if let results = try orderService.fetch() {
                orderData = results.filter { $0.orderStatusValue != .completed }
                tableView.reloadData() // Reload
            }
        } catch {
            print("Unable to load orders - \(error)")
        }
    }
    
    private func deleteSelectedOrders() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let orderService = OrderServiceImpl(databaseAccess: databaseAccess)
            let tableService = TableServiceImpl(databaseAccess: databaseAccess)
            
            guard let tablesResult = try tableService.fetch() else { throw DatabaseError.fetchFailed }
            
            for order in selectedOrders {
                guard let orderIndex = orderData.firstIndex(where: { $0.isOrderBilledValue == order.isOrderBilledValue }) else { continue }
                guard let tableIndex = tablesResult.firstIndex(where: { $0.tableId == order.tableIDValue }) else { continue }
                
                let table = tablesResult[tableIndex]
                table.changeTableStatus(to: .free)
                try tableService.update(table)
                try orderService.delete(order)
                orderData.remove(at: orderIndex)
                
                let toastView = Toast.default(image: UIImage(systemName: "checkmark.circle.fill")!, title: "Bills Deleted")
                toastView.show(haptic: .success)
            }
            
            setSelection(false, animated: true)
            tableView.reloadData()
        } catch {
            print("Unable to delete order - \(error)")
        }
    }
    
    private func selectAllOrders() {
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            let currentOrder = orderData[indexPath.row]
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            selectedOrders.append(currentOrder)
        }
    }
    
    // MARK: - Action Methods
    @objc private func cartDidChange(_ sender: Notification) {
        loadOrderData()
    }
    
    @objc private func addOrder() {
        let menuListVC = AddToCartViewController()
        let navController = UINavigationController(rootViewController: menuListVC)
        present(navController, animated: true)
    }
    
    @objc private func billButtonAction(_ sender: UIBarButtonItem) {
        print("Bill orders")
        
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let orderService = OrderServiceImpl(databaseAccess: databaseAccess)
            let billService = BillServiceImpl(databaseAccess: databaseAccess)
            let billingController = BillingController(billService: billService, orderService: orderService)
            
            for order in selectedOrders {
                try billingController.createBill(for: order, tip: nil)
            }
            
            NotificationCenter.default.post(name: .billDidChangeNotification, object: nil)
            loadOrderData()
            tableView.reloadData()
            setSelection(false, animated: true)
            
            let toast = Toast.default(image: UIImage(systemName: "checkmark.circle.fill")!, title: "New Bill Added")
            toast.show(haptic: .success)
        } catch {
            print("Unable to bill the order - \(error)")
        }
    }
    
    private func billOrder(_ order: Order) {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let orderService = OrderServiceImpl(databaseAccess: databaseAccess)
            let billService = BillServiceImpl(databaseAccess: databaseAccess)
            let billingController = BillingController(billService: billService, orderService: orderService)
            
            try billingController.createBill(for: order, tip: nil)
            
            NotificationCenter.default.post(name: .billDidChangeNotification, object: nil)
        } catch {
            print("Failed to perform \(#function) - \(error)")
        }
    }
    
    @objc private func deleteButtonAction(_ sender: UIBarButtonItem) {
        deleteSelectedOrders()
        loadOrderData()
    }
    
    @objc private func doneBarButtonAction(_ sender: UIBarButtonItem) {
        selectedOrders.removeAll()
        setSelection(false, animated: true)
    }
    
    @objc private func didAddOrder(_ notification: Notification) {
        loadOrderData()
    }
    
    // MARK: - Helper Methods
    private func updateUIForOrderData() {
        let hasOrders = !orderData.isEmpty
        quickMenuBarButton.isHidden = !hasOrders
        tableView.isHidden = !hasOrders
        placeholderLabel.isHidden = hasOrders
    }
    
    private func updateToolbarButtonsState() {
        let hasSelectedOrders = !selectedOrders.isEmpty
        billButton.isEnabled = hasSelectedOrders
        deleteButton.isEnabled = hasSelectedOrders
    }
    
    private func setSelection(_ editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
        setRightBarButtons(editing ? doneBarButton : addBarButton, editing ? nil : quickMenuBarButton)
        setToolbarActive(editing)
        
        if !editing {
            selectedOrders.removeAll()
        }
    }
    
    private func setRightBarButtons(_ barButtons: UIBarButtonItem?...) {
        navigationItem.rightBarButtonItems = barButtons.compactMap { $0 }
    }
    
    private func setToolbarActive(_ isActive: Bool) {
        navigationController?.setToolbarHidden(!isActive, animated: true)
    }
    
    private func printSelectedOrders() {
        for order in selectedOrders {
            print(order.orderIdValue)
        }
        print("-----------------------------------")
    }
    
    // MARK: - Destructive
    private func deleteOrder(_ order: Order) {
        do {
            let tableService = try TableServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let orderService = try OrderServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let orderController = OrderController(orderService: orderService, tableService: tableService)
            try orderController.deleteOrder(order)
        } catch {
            print("Failed to perform \(#function) - \(error)")
        }
    }
    
    func presentWarning(for item: Order) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Delete", message: "Do you want to delete the order?", preferredStyle: .alert)
        
        // Create the 'Delete' action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            // Handle the delete action
            print("Order deleted")
            self.deleteOrder(item)
            
            loadOrderData() // Reload is handled inside this method
        }
        
        // Create the 'Add Items' action
        let addItemsAction = UIAlertAction(title: "Cancel", style: .default) { [weak self] _ in
            // Handle the add items action
            guard let self else { return }
            print("Cancelled")
        }
        
        // Add the actions to the alert controller
        alertController.addAction(addItemsAction)
        alertController.addAction(deleteAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - TableView Delegate and DataSource
extension OrderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order = orderData[indexPath.row]
        //guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.reuseIdentifier, for: indexPath) as? OrderCell else { return UITableViewCell() }
        //cell.configureCell(with: order)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.contentConfiguration = UIHostingConfiguration {
            OrderCellView(order: order)
        }
        //cell.backgroundColor = .systemBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOrder = orderData[indexPath.row]
        
        guard tableView.isEditing else {
            // Not in editing mode...push to detail vc
            let detailVC = OrderDetailViewController(order: selectedOrder)
            navigationController?.pushViewController(detailVC, animated: true)
            return
        }
        
        selectedOrders.append(selectedOrder)
        printSelectedOrders()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let selectedOrder = orderData[indexPath.row]
            if let index = selectedOrders.firstIndex(where: { $0.orderIdValue == selectedOrder.orderIdValue }) {
                selectedOrders.remove(at: index)
            }
            printSelectedOrders()
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedOrder = orderData[indexPath.row]
        let billAction = UIContextualAction(style: .normal, title: "Bill") { [weak self] action, view, completionHandler in
            guard let self else { return }
            print("Bill")
            self.billOrder(selectedOrder)
            let toast = Toast.default(image: UIImage(systemName: "checkmark.circle.fill")!, title: "New Bill Added")
            toast.show(haptic: .success)
            completionHandler(true)
        }
        
        billAction.backgroundColor = .app
        
        let configuration = UISwipeActionsConfiguration(actions: [billAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedOrder = orderData[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self else { return }
            print("Delete Action")
            presentWarning(for: selectedOrder)
            
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }    
}

