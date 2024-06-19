//
//  OrderDetailViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 14/06/24.
//

import UIKit
import SwiftUI

class OrderDetailViewController: UIViewController {
    
    private let order: Order // Injection
    private let cellReuseIdentifier = "menuItem" // Reuse identifier for table view cells
    
    private var tableView: UITableView!
    private var scrollView: UIScrollView!
    /// View to hold the scrollable content
    private var contentView: UIView!
    
    private lazy var cardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.layer.cornerRadius = 12
        stackView.layer.masksToBounds = true
        stackView.backgroundColor = .app
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var menuModelData: [MenuItem] = ModelData().menuItems
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
        view.backgroundColor = .secondarySystemBackground
        title = "Order"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupScrollView()
        populateMenuModelData()
        populateOrderedItems()
        populateMenuItems()
        setupTableView()
        setupStackView()
    }
    
    private func setupNavbar() {
        // TODO: Setup edit buttons
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Set up constraints for the UIScrollView to match the view's size
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup content view
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Due to referring to tableView and stackView before initializing, the app crashes!
        /*let totalSubviewHeight: CGFloat = tableView.frame.height + cardStackView.frame.height
        var contentViewHeight: CGFloat = view.frame.height
        
        if totalSubviewHeight > contentViewHeight {
            contentViewHeight = view.frame.height + totalSubviewHeight + 100 // 100 is the extra offset ignoring the spacing between the subviews.
        }*/
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Set the width and height constraints for the content view
            // These constraints define the scrollable area
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 1000) // Set a height to make the content scrollable
        ])
    }
    
    private func populateOrderedItems() {
        for item in menuModelData {
            if let count = orderedItems[item] {
                orderedItems[item] = count + 1
            } else {
                orderedItems[item] = 1
            }
        }
    }
    
    private func populateMenuItems() {
        for (item, count) in orderedItems {
            let menuitem = item
            menuitem.count = count
            menuItems.append(menuitem)
        }
    }
    
    private func populateMenuModelData() {
        menuModelData = order.menuItems
    }
    
    private func setupTableView() {
        tableView = DynamicTableView()
        tableView.layoutIfNeeded()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 12
        tableView.translatesAutoresizingMaskIntoConstraints = false
        //view.addSubview(tableView)
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            tableView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.88),
        ])
    }
    
    private func setupStackView() {
        let tableIDView = CustomIDView()
        let orderIDView = CustomIDView()
        let statusView = CustomIDView()
        let dateView = CustomIDView()
        dateView.configureView(title: "Date", description: order.getDate.formatted())
        statusView.configureView(title: "Status", description: order.orderStatusValue.rawValue)
        tableIDView.configureView(title: "Table", description: order.tableIDValue.uuidString)
        orderIDView.configureView(title: "Order", description: order.orderIdValue.uuidString)
        //view.addSubview(cardStackView)
        contentView.addSubview(cardStackView)
        cardStackView.addArrangedSubview(orderIDView)
        cardStackView.addArrangedSubview(tableIDView)
        cardStackView.addArrangedSubview(statusView)
        cardStackView.addArrangedSubview(dateView)
        
        NSLayoutConstraint.activate([
            cardStackView.centerXAnchor.constraint(equalTo: contentView/*.safeAreaLayoutGuide*/.centerXAnchor),
            cardStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            cardStackView.widthAnchor.constraint(equalTo: contentView/*.safeAreaLayoutGuide*/.widthAnchor, multiplier: 0.88)
        ])
    }
}

extension OrderDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let menuItem = menuItems[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = .app
        
        cell.contentConfiguration = UIHostingConfiguration {
            PlainMenuItemView(menuItem: menuItem)
        }
        
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

class CustomIDView: UIView {
    
    private lazy var contentWrapperStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Mostly representing UUID
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Initialization code...
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.addSubview(contentWrapperStackView)
        contentWrapperStackView.addArrangedSubview(titleLabel)
        contentWrapperStackView.addArrangedSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            contentWrapperStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            contentWrapperStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            contentWrapperStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            contentWrapperStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
        ])
    }
    
    func configureView(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
}

#Preview {
    let order = Order(tableId: UUID(), orderStatus: .completed, menuItems: ModelData().menuItems)
    return UINavigationController(rootViewController: OrderDetailViewController(order: order))
}
