//
//  OrderViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit

class OrderViewController: UIViewController {
    private let orderService: OrderService
    private let menuService: MenuService
    
    private var tableView: UITableView!
    
    private var orderData: [Order] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let cellData = [
        OrderDummy(status: "Preparing", itemCount: 12, billStatus: true),
        OrderDummy(status: "Preparing", itemCount: 8, billStatus: true),
        OrderDummy(status: "Preparing", itemCount: 9, billStatus: true),
        OrderDummy(status: "Preparing", itemCount: 12, billStatus: true),
        OrderDummy(status: "Preparing", itemCount: 16, billStatus: true),
        OrderDummy(status: "Completed", itemCount: 32, billStatus: true),
        OrderDummy(status: "Cancelled", itemCount: 11, billStatus: true),
        OrderDummy(status: "Preparing", itemCount: 1, billStatus: true),
        OrderDummy(status: "Preparing", itemCount: 2, billStatus: true),
        OrderDummy(status: "Completed", itemCount: 22, billStatus: true),
        OrderDummy(status: "Preparing", itemCount: 5, billStatus: true),
        OrderDummy(status: "Preparing", itemCount: 92, billStatus: true),
        OrderDummy(status: "Preparing", itemCount: 37, billStatus: true),
    ]
    
    init(orderService: OrderService, menuService: MenuService) {
        self.orderService = orderService
        self.menuService = menuService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseIdentifier)
        loadOrderData()
        setupNavigationBar()
    }
    
    @objc private func addOrder() {
        /*let menuItems = [
            MenuItem(name: "Chicken", price: 3.4),
            MenuItem(name: "Beef", price: 3.4),
            MenuItem(name: "Bacon bread", price: 3.4),
        ]
        let order = Order(tableId: UUID(), orderStatus: .received, menuItems: menuItems)
        orderData.append(order)
        do {
            try orderService.add(order)
        } catch {
            print("Failed to add order to db: \(error)")
        }*/
        let menuListVC = MenuListViewController(sectionTitle: "Menu", menuService: menuService, isPresented: true)
        let navController = UINavigationController(rootViewController: menuListVC)
        present(navController, animated: true)
    }
    
    private func setupNavigationBar() {
        let addBarButton = UIBarButtonItem(image: UIImage(systemName: "plus.app"), style: .done, target: self, action: #selector(addOrder))
        navigationItem.rightBarButtonItem = addBarButton
    }
    
    private func loadOrderData() {
        if let orders = try? orderService.fetch() {
            orderData = orders
        } else {
            print("Order data not found!")
        }
    }
    
    private func setupAppearance() {
        self.title = "Orders"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = orderData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.reuseIdentifier, for: indexPath) as! OrderCell
//        cell.configure(status: data.status, itemCount: data.itemCount, orderID: "fuwfewf", tableID: "fwefewfewf", date: data.date, isOrderBilled: true)
//        cell.configure(status: data.orderStatusValue.rawValue, itemCount: data.menuItems.count, orderID: data.orderIdValue.uuidString, tableID: data.tableIDValue.uuidString, date: data.getDate, isOrderBilled: data.isOrderBilledValue)
        cell.configure(status: data.orderStatusValue.rawValue, itemCount: data.menuItems.count, orderID: "7264rhr74ry34r", tableID: "d476139424", date: data.getDate, isOrderBilled: data.isOrderBilledValue)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orderData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

struct OrderDummy {
    let status: String
    let itemCount: Int
    let orderID = UUID()
    let tableID = UUID()
    let date = Date()
    let billStatus: Bool
    
}
