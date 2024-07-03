//
//  BillViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit
import SwiftUI
import Toast

class BillViewController: UIViewController {
    // MARK: - Properties
    
    // TableView for displaying bills
    private var tableView: UITableView!
    
    // Placeholder label for empty state
    private var placeholderLabel: UILabel!
    
    // Reuse identifier for table view cells
    private let cellReuseIdentifier = "BillItem"
    
    // Data source for bills
    private var billData: [Bill] = [] {
        didSet {
            // Show/hide placeholder based on data availability
            placeholderLabel.isHidden = !billData.isEmpty
            tableView.isHidden = billData.isEmpty
        }
    }
    
    // Computed properties for categorizing bills
    private var todaysBills: [Bill] {
        billData.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    private var yesterdaysBills: [Bill] {
        billData.filter { Calendar.current.isDateInYesterday($0.date) }
    }
    
    private var previousBills: [Bill] {
        billData.filter {
            guard let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date()) else { return false }
            return Calendar.current.compare($0.date, to: twoDaysAgo, toGranularity: .day) == .orderedSame
        }
    }
    
    // Grouped bill data by sections
    private var tableViewData: [BillSection: [Bill]] {
        [.today: todaysBills, .yesterday: yesterdaysBills, .previous: previousBills]
    }
    
    // Sections with non-empty data
    private var nonEmptyBillSection: [BillSection] {
        BillSection.allCases.filter { tableViewData[$0]?.isEmpty == false }
    }
    
    // Filter button in navigation bar
    private var filterBarButton: UIBarButtonItem!
    
    // MARK: - View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTableView()
        setupPlaceholderLabel()
        // setupBarButton()
        loadBillData()
        
        // Register for notification when a bill is added
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(billDidAdd(_:)),
            name: .billDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(listDidChange(_:)),
            name: .tablesDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func billDidAdd(_ sender: Notification) {
        loadBillData()
    }
    
    @objc private func listDidChange(_ sender: Notification) {
        print(#function)
        loadBillData()
    }
    
    // MARK: - Methods
    
    // Setup table view
    private func setupTableView() {
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Layout constraints for table view
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // Setup placeholder label
    private func setupPlaceholderLabel() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Add Bills to Continue"
        placeholderLabel.textColor = .systemGray3
        placeholderLabel.font = .preferredFont(forTextStyle: .title1)
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        // Layout constraints for placeholder label
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Initially hidden
        placeholderLabel.isHidden = true
    }
    
    // Setup navigation bar appearance
    private func setupAppearance() {
        self.title = "Bills"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // Setup filter bar button
    private func setupBarButton() {
        filterBarButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterAction(_:))
        )
        navigationItem.rightBarButtonItem = filterBarButton
    }
    
    @objc private func filterAction(_ sender: UIBarButtonItem) {
        print("Filter button tapped!")
    }
    
    // Load bill data from database
    private func loadBillData() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let billService = BillServiceImpl(databaseAccess: databaseAccess)
            let results = try billService.fetch()
            if let results {
                billData = results
                tableView.reloadData()
            }
        } catch {
            print("Unable to load bills = \(error)")
        }
    }
    
    private func deleteBill(_ bill: Bill) {
        do {
            let databaseAccess  = try SQLiteDataAccess.openDatabase()
            let billService = BillServiceImpl(databaseAccess: databaseAccess)
            try billService.delete(bill)
            let toast = Toast.text("Bill Deleted!")
            toast.show(haptic: .success)
            NotificationCenter.default.post(name: .billDidChangeNotification, object: nil)
        } catch {
            print("Failed to perform \(#function) - \(error)")
            fatalError("Failed to perform \(#function) - \(error)")
        }
    }
    
    enum BillSection: Int, CaseIterable {
        case today
        case yesterday
        case previous
        
        var title: String {
            switch self {
            case .today: return "Today"
            case .yesterday: return "Yesterday"
            case .previous: return "Previous"
            }
        }
    }
    
    func presentWarning(for item: Bill) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Delete", message: "Do you want to delete the bill?", preferredStyle: .alert)
        
        // Create the 'Delete' action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            // Handle the delete action
            print("Order deleted")
            self.deleteBill(item)
            loadBillData() // Reload is handled inside this method
        }
        
        // Create the 'Add Items' action
        let addItemsAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add the actions to the alert controller
        alertController.addAction(addItemsAction)
        alertController.addAction(deleteAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - TableView DataSource & Delegate methods
extension BillViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        nonEmptyBillSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let billSection = nonEmptyBillSection[section]
        return tableViewData[billSection]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let billSection = nonEmptyBillSection[indexPath.section]
        guard let bill = tableViewData[billSection]?[indexPath.row] else { return cell }
        cell.selectionStyle = .none
        cell.contentConfiguration = UIHostingConfiguration {
            BillItem(billData: bill)
        }
        .background(Color(.systemGroupedBackground))
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let billSection = nonEmptyBillSection[section]
        return billSection.title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = billData[indexPath.row]
        let billDetailViewController = BillDetailViewController(bill: data)
        navigationController?.pushViewController(billDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedBill = billData[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self else { return }
            
            print("Delete")
            presentWarning(for: selectedBill)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

#Preview  {
    let billVC = BillViewController()
    billVC.title = "Bills"
    return UINavigationController(rootViewController: BillViewController())
}


