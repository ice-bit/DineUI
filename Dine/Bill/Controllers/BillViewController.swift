//
//  BillViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit
import SwiftUI

class BillViewController: UIViewController {
    // MARK: - Properties
    private var tableView: UITableView!
    private var cellReuseIdentifier = "BillItem"
    //    private var billData: [BillData] = ModelData().bills
    private var billData: [Bill] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var todaysBills: [Bill] {
        billData.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    private var yesterdaysBills: [Bill] {
        billData.filter { Calendar.current.isDateInYesterday($0.date) }
    }
    
    private var previousBills: [Bill] {
        billData.filter {
            guard let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date()) else { return false }
            return Calendar.current.isDate($0.date, inSameDayAs: twoDaysAgo)
        }
    }
    
    private var tableViewData: [BillSection: [Bill]] {
        [.today: todaysBills, .yesterday: yesterdaysBills, .previous: previousBills]
    }
    
    private var nonEmptySection: [BillSection] {
        BillSection.allCases.filter { tableViewData[$0]?.isEmpty == false }
    }
    
    
    private var filterBarButton: UIBarButtonItem!
    
    // MARK: -View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        view = tableView
        setupAppearance()
        setupBarButton()
        loadBillData()
        NotificationCenter.default.addObserver(self, selector: #selector(billDidAdd(_:)), name: .billDidAddNotification, object: nil)
    }
    
    @objc private func billDidAdd(_ sender: NotificationCenter) {
        loadBillData()
    }
    
    // MARK: - Methods
    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupAppearance() {
        self.title = "Bills"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupBarButton() {
        filterBarButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(filterAction(_:)))
        navigationItem.rightBarButtonItem = filterBarButton
    }
    
    @objc private func filterAction(_ sender: UIBarButtonItem) {
        print("Filter button tapped!")
        
    }
    
    private func loadBillData() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let billService = BillServiceImpl(databaseAccess: databaseAccess)
            let results = try billService.fetch()
            if let results {
                billData = results
            }
        } catch {
            print("Unable to load bills = \(error)")
        }
    }
    
    // MARK: - TableViewDataSource
    
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
}

extension BillViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        nonEmptySection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let billSection = nonEmptySection[section]
        return tableViewData[billSection]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let billSection = nonEmptySection[indexPath.section]
        guard let bill = tableViewData[billSection]?[indexPath.row] else { return cell }
        cell.selectionStyle = .none
        cell.contentConfiguration = UIHostingConfiguration {
            BillItem(billData: bill)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let billSection = nonEmptySection[section]
        return billSection.title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let customBillVC = CustomBillViewController()
        customBillVC.modalPresentationStyle = .popover
        present(customBillVC, animated: true)
    }
    
}

#Preview  {
    let billVC = BillViewController()
    billVC.title = "Bills"
    return UINavigationController(rootViewController: BillViewController())
}

