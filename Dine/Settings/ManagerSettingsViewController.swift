//
//  ManagerSettingsViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 06/08/24.
//

import UIKit

class ManagerSettingsViewController: UIViewController {
    private let cellReuseIdentifier = "cell"
    private var tableView: UITableView!
    private let viewModal: ControlsViewModal = ControlsViewModal()
    private let billingToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = UserDefaultsManager.shared.isBillingEnabled
        return toggle
    }()
    
    private let paymentToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = UserDefaultsManager.shared.isPaymentEnabled
        return toggle
    }()
    
    private let mockDataToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = UserDefaultsManager.shared.isMockDataEnabled
        return toggle
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        billingToggle.addTarget(self, action: #selector(billToggleAction), for: .valueChanged)
        paymentToggle.addTarget(self, action: #selector(paymentToggleAction), for: .valueChanged)
        mockDataToggle.addTarget(self, action: #selector(mockDataToggleAction), for: .valueChanged)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func billToggleAction() {
        print(#function)
        UserDefaultsManager.shared.isBillingEnabled = billingToggle.isOn
    }
    
    @objc private func paymentToggleAction() {
        print(#function)
        UserDefaultsManager.shared.isPaymentEnabled = paymentToggle.isOn
    }
    
    @objc private func mockDataToggleAction() {
        print(#function)
        if mockDataToggle.isOn {
            print("🔨 enabling mock data.")
            var mockDataManager = MockDataManager()
            mockDataManager.generateData()
            NotificationCenter.default.post(name: .mockDataDidChangeNotification, object: nil)
        } else {
            print("🔨 disabling mock data.")
            var mockDataManager = MockDataManager()
            mockDataManager.deleteGeneratedData()
            NotificationCenter.default.post(name: .mockDataDidChangeNotification, object: nil)
        }
    }
}

extension ManagerSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModal.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionHeader = viewModal.sections[section].header {
            return sectionHeader
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let sectionFooter = viewModal.sections[section].footer {
            return sectionFooter
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModal.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.contentConfiguration = requestContentConfig(for: cell, at: indexPath)
        cell.accessoryType = requestAccessoryType(at: indexPath)
        cell.accessoryView = requestAccessoryView(at: indexPath)
        return cell
    }
    
    private func requestContentConfig(for cell: UITableViewCell, at indexPath: IndexPath) -> UIContentConfiguration {
        let datum = viewModal.sections[indexPath.section].items[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = datum.title
        if let subtitle = datum.subtitle {
            content.secondaryText = subtitle
        }
        if let image = datum.image {
            content.image = image
        }
        if indexPath.section == viewModal.sections.count - 1 && indexPath.row == 0 {
            content.textProperties.alignment = .center
            content.textProperties.color = .systemRed
        }
        return content
    }
    
    private func requestAccessoryView(at indexPath: IndexPath) -> UIView? {
        if indexPath.section == 1 {
            return billingToggle
        }
        if indexPath.section == 2 {
            return paymentToggle
        }
        if indexPath.section == 3 {
            return mockDataToggle
        }
        return nil
    }
    
    private func requestAccessoryType(at indexPath: IndexPath) -> UITableViewCell.AccessoryType {
        if indexPath.section == 0 {
            return .disclosureIndicator
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModal.sections[indexPath.section].items[indexPath.row]
        item.action?(self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func toggleSwitchValueChanged(_ sender: UISwitch) {
        // Handle toggle switch value change
        // For example, update the corresponding datum's 'isToggled' property
        // and potentially reload the table view row
    }
}

#Preview {
    UINavigationController(rootViewController: ManagerSettingsViewController())
}

struct ManagerSettingsViewModal {
    let sectionHeader: String
    let cells: [CellViewModal]
    
    struct CellViewModal {
        let title: String
        let thumbnail: UIImage
    }
}

struct ControlSection {
    let header: String?
    let items: [ControlItem]
    let footer: String?
}

struct ControlItem {
    let title: String
    let subtitle: String?
    let image: UIImage?
    let action: ((UIViewController) -> Void)?
}

class ControlsViewModal {
    var sections: [ControlSection] = []
    
    init() {
        setupSections()
    }
    
    subscript(index: Int) -> ControlSection? {
        guard index >= 0 && index < sections.count else { return nil }
        return self.sections[index]
    }
    
    private func setupSections() {
        let employeesItem = ControlItem(title: "Employees", subtitle: nil, image: UIImage(systemName: "person.2.fill"), action: pushToUserList)
        let managementSection = ControlSection(header: "Management", items: [employeesItem], footer: nil)
        
        let billingItem = ControlItem(title: "Billing", subtitle: nil, image: UIImage(systemName: "dollarsign.circle.fill"), action: nil)
        let paymentItem = ControlItem(title: "Transactions", subtitle: nil, image: UIImage(systemName: "creditcard.fill"), action: nil)
        
        let billSection = ControlSection(header: nil, items: [billingItem], footer: "Enabling this option allows waitstaff to bill the order.")
        let paymentSection = ControlSection(header: nil, items: [paymentItem], footer: "Enabling this option allows waitstaff to process transactions.")
        
        let logoutItem = ControlItem(title: "Logout", subtitle: nil, image: nil, action: logout)
        let logoutSection = ControlSection(header: nil, items: [logoutItem], footer: nil)
        
        let mockDataItem = ControlItem(title: "Mock data", subtitle: nil, image: nil, action: nil)
        let mockDataSection = ControlSection(header: nil, items: [mockDataItem], footer: "Enabling this option allows you to use mock data for testing purposes.")
        
        sections = [managementSection, billSection, paymentSection, mockDataSection, logoutSection]
        
    }
    
    private func logout(_ viewController: UIViewController) {
        UserSessionManager.shared.clearAccount()
        RootViewManager.didLoggedOutSuccessfully()
    }
    
    private func pushToUserList(_ viewController: UIViewController) {
        let userListViewController = UserListViewController()
        viewController.navigationController?.pushViewController(userListViewController, animated: true)
    }
}
