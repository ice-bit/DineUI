//
//  OrderDetailViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 14/06/24.
//

import UIKit
import SwiftUI
import Toast

class OrderDetailViewController: UIViewController {
    
    private let order: Order // Dependency Injection
    private let cellReuseIdentifier = "menuItemCell" // Reuse identifier for table view cells
    
    private var tableView: UITableView!
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var billButton: UIButton!
    private var editButton: UIButton!
    private var verticalStackView: UIStackView!
    private var horizontalButtonStackView: UIStackView!
    
    private var unorderedItems: [MenuItem] = []
    private var orderedItems: [MenuItem: Int] = [:]
    private var menuItems: [MenuItem] = []
    
    init(order: Order) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScrollView()
        setupTableView()
        setupVerticalStackView()
        setupButtonStackView()
        populateMenuData()
        setupNotifications()
    }
    
    private func setupView() {
        view.backgroundColor = .systemGroupedBackground
        title = "Order"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollContentView = UIView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView = DynamicTableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 12
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollContentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: scrollContentView.topAnchor),
            tableView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
        ])
    }
    
    private func setupVerticalStackView() {
        verticalStackView = createVerticalStackView()
        
        scrollContentView.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            verticalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            verticalStackView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupButtonStackView() {
        horizontalButtonStackView = createHorizontalButtonStackView()
        
        scrollContentView.addSubview(horizontalButtonStackView)
        NSLayoutConstraint.activate([
            horizontalButtonStackView.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 20),
            horizontalButtonStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            horizontalButtonStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            horizontalButtonStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor)
        ])
    }
    
    private func createVerticalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.layer.cornerRadius = 12
        stackView.layer.masksToBounds = true
        stackView.backgroundColor = .secondarySystemGroupedBackground
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        
        let tableIDView = TitleAndDescriptionView()
        let orderIDView = TitleAndDescriptionView()
        let statusView = TitleAndDescriptionView()
        let dateView = TitleAndDescriptionView()
        
        dateView.configureView(title: "Date", description: order.getDate.formatted())
        statusView.configureView(title: "Status", description: order.orderStatusValue.rawValue.uppercased())
        tableIDView.configureView(title: "Table", description: order.tableIDValue.uuidString)
        orderIDView.configureView(title: "Order", description: order.orderIdValue.uuidString)
        
        stackView.addArrangedSubview(orderIDView)
        stackView.addArrangedSubview(tableIDView)
        stackView.addArrangedSubview(statusView)
        stackView.addArrangedSubview(dateView)
        
        return stackView
    }
    
    private func createHorizontalButtonStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let billAction = UIAction { [weak self] _ in
            self?.initiateBilling()
        }
        let editAction = UIAction { [weak self] _ in
            self?.initiateEditing()
        }
        
        billButton = createCustomButton(title: "Bill", type: .normal, primaryAction: billAction)
        editButton = createCustomButton(title: "Edit", type: .normal, primaryAction: editAction)
        
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(billButton)
        
        return stackView
    }
    
    private func createCustomButton(title: String, type: CustomButtonType, primaryAction: UIAction? = nil) -> UIButton {
        var config = UIButton.Configuration.gray()
        config.cornerStyle = .large
        config.buttonSize = .large
        config.title = title
        config.baseBackgroundColor = .secondarySystemGroupedBackground
        
        switch type {
        case .normal:
            config.baseForegroundColor = .tintColor
        case .destructive:
            config.baseForegroundColor = .red
        }
        
        return UIButton(configuration: config, primaryAction: primaryAction)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange(_:)),
            name: .cartDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func cartDidChange(_ sender: Notification) {
        if let userInfo = sender.userInfo,
           let updatedCart = userInfo["MenuItems"] as? [MenuItem: Int] {
            orderedItems = updatedCart
            updateMenuItems()
        }
    }
    
    private func updateMenuItems() {
        menuItems = orderedItems.compactMap { item, count in
            var updatedItem = item
            updatedItem.count = count
            return count > 0 ? updatedItem : nil
        }
        tableView.reloadData()
    }
    
    private func populateMenuData() {
        unorderedItems = order.menuItems
        populateOrderedItems()
        updateMenuItems()
    }
    
    private func populateOrderedItems() {
        unorderedItems.forEach { item in
            orderedItems[item, default: 0] += 1
        }
    }
    
    private func initiateBilling() {
        guard !menuItems.isEmpty else {
            presentEmptyCartAlert()
            return
        }
        presentBillingAlert()
    }
    
    private func billOrder() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let orderService = OrderServiceImpl(databaseAccess: databaseAccess)
            let billService = BillServiceImpl(databaseAccess: databaseAccess)
            let billingController = BillingController(billService: billService, orderService: orderService)
            
            try billingController.createBill(for: order, tip: 0.0)
            
            NotificationCenter.default.post(name: .billDidChangeNotification, object: nil)
            NotificationCenter.default.post(name: .orderDidChangeNotification, object: nil)
            NotificationCenter.default.post(name: .metricDataDidChangeNotification, object: nil)
            
            horizontalButtonStackView.isHidden = true
            navigationController?.popViewController(animated: true)
            
            let toast = Toast.default(image: UIImage(systemName: "checkmark.circle.fill")!, title: "New Bill Added")
            toast.show(haptic: .success)
        } catch {
            print("Unable to bill the order - \(error)")
        }
    }
    
    private func initiateEditing() {
        let editCartViewController = EditCartViewController(cart: orderedItems, order: order)
        present(UINavigationController(rootViewController: editCartViewController), animated: true)
    }
    
    private func presentEmptyCartAlert() {
        let alertController = UIAlertController(title: "Empty Cart", message: "Do you want to delete the order?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteOrder()
        }
        
        let addItemsAction = UIAlertAction(title: "Add Items", style: .default) { [weak self] _ in
            self?.initiateEditing()
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(addItemsAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentBillingAlert() {
        let alertController = UIAlertController(
            title: "Confirmation",
            message: "Are you sure that you want to bill the order?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            self?.billOrder()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteOrder() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let orderService = OrderServiceImpl(databaseAccess: databaseAccess)
            let tableService = TableServiceImpl(databaseAccess: databaseAccess)
            let orderController = OrderController(orderService: orderService, tableService: tableService)
            
            try orderController.deleteOrder(order)
            
            navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: .cartDidChangeNotification, object: nil)
            
            let toast = Toast.default(image: UIImage(systemName: "checkmark")!, title: "Order Deleted")
            toast.show(haptic: .success)
        } catch {
            print("Failed to delete order - \(error)")
        }
    }
}

extension OrderDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let menuItem = menuItems[indexPath.row]
        cell.selectionStyle = .none
        
        cell.contentConfiguration = UIHostingConfiguration {
            PlainMenuItemView(menuItem: menuItem)
        }.background(Color(.secondarySystemGroupedBackground))
        
        return cell
    }
}


class DynamicTableView: UITableView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

#Preview {
    let order = Order(tableId: UUID(), orderStatus: .completed, menuItems: ModelData().menuItems)
    return UINavigationController(rootViewController: OrderDetailViewController(order: order))
}
