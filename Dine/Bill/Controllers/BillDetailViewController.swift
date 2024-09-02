//
//  BillDetailViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 17/06/24.
//

import UIKit
import SwiftUI
import Toast

class BillDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let bill: Bill
    private var toast: Toast!
    
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var verticalStackView: UIStackView!
    private var horizontalStackView: UIStackView!
    private var paymentButton: UIButton!
    private var deleteButton: UIButton!
    
    private let cellReuseIdentifier = "menuItemCell" // Reuse identifier for table view cells
    private var menuItems: [MenuItem] = []
    private var tableView: UITableView!
    
    private var associateOrder: Order?
    
    // MARK: - Initialization
    
    init(bill: Bill) {
        self.bill = bill
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupSubviews()
        setAssociatedOrder()
        createMenu()
    }
    
    // MARK: - Setup Methods
    private func setupViewController() {
        view.backgroundColor = .systemGroupedBackground
        title = "Bill"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupSubviews() {
        setupScrollView()
        //setupTableView()
        setupVerticalStackView()
        setupHorizontalStackView()
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollContentView = UIView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollContentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
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
        
        let amountInfoView = createInfoView(title: "Amount", description: "$\(bill.getTotalAmount.rounded())")
        let tipInfoView = createInfoView(title: "Tip", description: "$\(bill.getTip.rounded())")
        let taxInfoView = createInfoView(title: "Tax", description: "$\(bill.getTax.rounded())")
        let dateInfoView = createInfoView(title: "Date", description: bill.date.formattedDateString())
        let billIdInfoView = createInfoView(title: "Bill ID", description: bill.billId.uuidString)
        let orderIdInfoView = createInfoView(title: "Order ID", description: bill.getOrderId.uuidString)
        let paymentStatusInfoView = createInfoView(title: "Payment Status", description: bill.paymentStatus.rawValue)
        
        if let order = bill.getOrder, let table = order.getTable {
            let tableStatusView = createInfoView(title: "Table", description: table.locationIdentifier.description)
            verticalStackView.addArrangedSubview(tableStatusView)
        }
        
        verticalStackView.addArrangedSubview(amountInfoView)
        verticalStackView.addArrangedSubview(tipInfoView)
        verticalStackView.addArrangedSubview(taxInfoView)
        verticalStackView.addArrangedSubview(dateInfoView)
        //verticalStackView.addArrangedSubview(billIdInfoView)
        //verticalStackView.addArrangedSubview(orderIdInfoView)
        verticalStackView.addArrangedSubview(paymentStatusInfoView)
        
        scrollContentView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            verticalStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            verticalStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 20),
        ])
    }
    
    private func updatedPaymentStatus() {
        do {
            let dbAsseccor = try SQLiteDataAccess.openDatabase()
            let billService = BillServiceImpl(databaseAccess: dbAsseccor)
            try billService.update(bill)
        } catch {
            fatalError("Failed to update bill: \(error)")
        }
    }
    
    private func showSuccessToast(_ message: String) {
        if let toast {
            toast.close(animated: true)
        }
        toast = Toast.text(message)
        toast.show(haptic: .success)
    }
    
    private func setupHorizontalStackView() {
        horizontalStackView = createHorizontalStackView()
        
        let paymentAction = UIAction { [weak self] _ in
            self?.bill.isPaid = true
            self?.paymentButton.isHidden = true
            self?.updatedPaymentStatus()
            self?.showSuccessToast("Bill Paid")
        }
        
        paymentButton = createCustomButton(title: "Checkout", type: .normal, primaryAction: paymentAction)
        if let account = UserSessionManager.shared.loadAccount() {
            if account.userRole == .waitStaff {
                paymentButton.isEnabled = UserDefaultsManager.shared.isPaymentEnabled
            }
        }
        
        horizontalStackView.addArrangedSubview(paymentButton)
        
        scrollContentView.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            horizontalStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            horizontalStackView.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 20),
            horizontalStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor)
        ])
    }
    
    private func setAssociatedOrder() {
        do {
            let dbAccess = try SQLiteDataAccess.openDatabase()
            let orderService = OrderServiceImpl(databaseAccess: dbAccess)
            let resultOrders = try orderService.fetch()
            guard let orders = resultOrders else { return }
            guard let order = orders.first(where: { $0.orderIdValue == bill.getOrderId }) else { return }
            menuItems = order.menuItems
            associateOrder = order
        } catch {
            fatalError("Failed to get associated order")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createVerticalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.layer.cornerRadius = 16
        stackView.layer.masksToBounds = true
        stackView.backgroundColor = .secondarySystemGroupedBackground
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func createHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func createInfoView(title: String, description: String) -> TitleAndDescriptionView {
        let infoView = TitleAndDescriptionView()
        infoView.configureView(title: title, description: description)
        return infoView
    }
    
    private func createCustomButton(title: String, type: CustomButtonType, primaryAction: UIAction? = nil) -> UIButton {
        var config = UIButton.Configuration.gray()
        config.cornerStyle = .large
        config.buttonSize = .large
        config.title = title
        config.baseBackgroundColor = .app
        
        switch type {
        case .normal:
            config.baseForegroundColor = .systemBackground
        case .destructive:
            config.baseForegroundColor = .red
        }
        
        let button = UIButton(configuration: config, primaryAction: primaryAction)
        button.isHidden = bill.isPaid
        return button
    }
    
    private func showErrorToast() {
        if let toast = toast {
            toast.close(animated: false)
        }
        toast = Toast.text("Not functional!")
        toast.show(haptic: .warning)
    }
    
    private func deleteBill() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let billService = BillServiceImpl(databaseAccess: databaseAccess)
            try billService.delete(bill)
            let toast = Toast.text("Bill Deleted!")
            toast.show(haptic: .success)
            NotificationCenter.default.post(name: .billDidChangeNotification, object: nil)
            navigationController?.popViewController(animated: true)
        } catch {
            let toast = Toast.text("Failed to delete bill: \(error.localizedDescription)")
            toast.show(haptic: .error)
        }
    }

    private func createMenu() {
        let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
            print("Edit action")
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { [weak self] _ in
            print("Delete action")
            guard let self else { return }
            self.deleteBill()
        }
        
        let menu = UIMenu(children: [/*editAction, */deleteAction])
        let menuBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        navigationItem.rightBarButtonItem = menuBarButton
    }
}

extension BillDetailViewController: UITableViewDelegate, UITableViewDataSource {
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

#Preview {
    let bill = Bill(amount: 33.8, tax: 0.99, orderId: UUID(), isPaid: false)
    return UINavigationController(rootViewController: BillDetailViewController(bill: bill))
}
