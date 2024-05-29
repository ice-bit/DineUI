//
//  BillViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit
import SwiftUI

class BillViewController: UIViewController, UITableViewDataSource {
    // MARK: - Properties
    private var tableView: UITableView!
    private var cellReuseIdentifier = "BillItem"
    private var billData: [BillData] = ModelData().bills
    
    // MARK: -View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        view = tableView
        setupAppearance()
    }
    
    // MARK: - Methods
    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.dataSource = self
    }
    private func setupAppearance() {
        self.title = "Bills"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        billData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let item = billData[indexPath.row]
        cell.contentConfiguration = UIHostingConfiguration {
            BillItem(billData: item)
        }
        return cell
    }
}

#Preview  {
    let billVC = BillViewController()
    billVC.title = "Bills"
    return UINavigationController(rootViewController: BillViewController())
}

