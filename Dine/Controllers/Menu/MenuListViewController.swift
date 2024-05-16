//
//  MenuListViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/05/24.
//

import UIKit

class MenuListViewController: UIViewController {
    private let sectionTitle: String
    private let menuService: MenuService
    private let isPresented: Bool

    private var tableView: UITableView!
    private var addItemsButton: UIButton!
    
    private let menuData: [MenuCell] = [
        MenuCell(image: UIImage(named: "burger")!, indicator: nil, title: "Bacon Bliss Loaded Burger", price: 6.99, secTitle: "Savory Bacon Delight"),
        MenuCell(image: UIImage(named: "tofu")!, indicator: nil, title: "Something just like this", price: 69.3, secTitle: "Coldplay is in live at coachella!")
    ]
    
    private var menuItemCart: [MenuItem] = []
    
    private var menuItems: [MenuItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(sectionTitle: String, menuService: MenuService, isPresented: Bool) {
        self.sectionTitle = sectionTitle
        self.menuService = menuService
        self.isPresented = isPresented
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
        setupAddButton()
        configureView()
        loadMenu()
    }
    
    @objc func presentAddMenuSheet() {
        let addItemSheetVC = AddItemViewController(menuService: menuService)
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
    
    private func setupNavBar() {
        title = sectionTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddMenuSheet))
//        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
        if isPresented {
            navigationItem.rightBarButtonItem = cancelButton
        } else {
            navigationItem.rightBarButtonItem = addButton
        }
        setupSearchBar()
    }
    
    private func loadMenu() {
        if let menuItems = try? menuService.fetch() {
            self.menuItems = menuItems
        }
    }
    
    private func configureView() {
        view.backgroundColor = UIColor(named: "primaryBgColor")
        tableView.backgroundColor = UIColor(named: "primaryBgColor")
        tableView.separatorStyle = .none
        navigationController?.navigationBar.backgroundColor = UIColor(named: "primaryBgColor")
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MenuItemCell.self, forCellReuseIdentifier: MenuItemCell.reuseIdentifier)
    }
    
    private func setupAddButton() {
        guard isPresented else { return }
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
    
    private func setupSearchBar() {
        let searchBar = UISearchController()
        navigationItem.searchController = searchBar
    }

}

extension MenuListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultData = menuData[0]
        let menuData = menuItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemCell.reuseIdentifier, for: indexPath) as! MenuItemCell
        cell.configure(itemImage: defaultData.image, isFoodVeg: true, title: menuData.name, price: menuData.price, secondaryTitle: defaultData.secTitle)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        122
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMenuItem = menuData[indexPath.row]
        let detailVC = MenuDetailViewController(menu: selectedMenuItem)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MenuListViewController: MenuItemDelegate {
    func menuItemDidAdd(_ item: MenuItem) {
        menuItems.append(item)
    }
}
