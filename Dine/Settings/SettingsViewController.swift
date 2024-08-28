//
//  SettingsViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 14/08/24.
//

import UIKit
enum SettingsCategory {
    case general
    case preference
    case logout
}

class SettingsViewController: UIViewController {
    private let reuseIdentifier = "cell"
    private var tableView: UITableView!
    
    private let settingsViewModal = SettingsViewModal()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        self.title = "Settings"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    @objc private func toggleSwitchValueChanged() {
        print(#function)
    }

}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        settingsViewModal.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let header = settingsViewModal[section]?.header {
            return header
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let footer = settingsViewModal[section]?.footer {
            return footer
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsViewModal[section]?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.contentConfiguration =  requestConfiguration(for: cell, at: indexPath)
        cell.accessoryView = requestAccessoryView(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = settingsViewModal.sections[indexPath.section].items[indexPath.row]
        item.action?(self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func requestConfiguration(for cell: UITableViewCell, at indexPath: IndexPath) -> UIContentConfiguration {
        let item = settingsViewModal.sections[indexPath.section].items[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        if let subtitle = item.subtitle {
            content.secondaryText = subtitle
        }
        if let thumbnail = item.image {
            content.image = thumbnail
        }
        if indexPath.section == settingsViewModal.sections.count - 1 && indexPath.row == 0 {
            content.textProperties.alignment = .center
            content.textProperties.color = .systemRed
        }
        
        if !(indexPath.last == settingsViewModal.sections.count - 1) {
            cell.selectionStyle = .none
        }
        
        return content
    }
    
    private func requestAccessoryView(at indexPath: IndexPath) -> UIView? {
        if indexPath.section == 2 && indexPath.row == 0 {
            let toggleSwitch = UISwitch()
            // toggleSwitch.isOn = datum.isToggled // Assuming datum has an 'isToggled' property
            toggleSwitch.addTarget(self, action: #selector(toggleSwitchValueChanged), for: .valueChanged)
            return toggleSwitch
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            let toggleSwitch = UISwitch()
            // toggleSwitch.isOn = datum.isToggled // Assuming datum has an 'isToggled' property
            toggleSwitch.addTarget(self, action: #selector(toggleSwitchValueChanged), for: .valueChanged)
            return toggleSwitch
        }
        return nil
    }
}

struct SettingSection {
    let header: String?
    let items: [SettingItem]
    let footer: String?
}

struct SettingItem {
    let title: String
    let subtitle: String?
    let image: UIImage?
    let action: ((UIViewController) -> Void)?
}

class SettingsViewModal {
    var sections: [SettingSection] = []
    
    init() {
        setupSections()
    }
    
    subscript(index: Int) -> SettingSection? {
        guard index >= 0 && index < sections.count else { return nil }
        return self.sections[index]
    }
    
    private func setupSections() {
        let currentUser = UserSessionManager.shared.loadAccount()
        let accountSection = SettingSection(header: "Profile", items: [
            .init(title: currentUser?.username ?? "No Username Found", subtitle: "Username", image: UIImage(systemName: "person.fill"), action: nil),
        ], footer: nil)
        
        let currencySection = SettingSection(header: nil, items: [
            .init(title: "Currency", subtitle: nil, image: nil, action: nil)
        ], footer: "Change the currency across the app.")
        
        let preferencesSection = SettingSection(header: "Preferences", items: [
            .init(title: "Notifications", subtitle: "Allow notifications", image: UIImage(systemName: "app.badge"), action: nil),
            .init(title: "Language", subtitle: "Select your language", image: UIImage(systemName: "globe"), action: nil),
            .init(title: "Theme", subtitle: "Select your theme", image: UIImage(systemName: "moon"), action: nil),
        ], footer: nil)
        
        let logoutSection = SettingSection(header: nil, items: [
            .init(title: "Logout", subtitle: nil, image: nil, action: logout),
        ], footer: nil)
        
        let appLockSection = SettingSection(header: nil, items: [
            .init(title: "App lock", subtitle: nil, image: nil, action: nil)
        ], footer: "Require Face ID to unlock Dine.")
        
        sections = [accountSection, preferencesSection, appLockSection, logoutSection]
    }
    
    private func logout(_ viewController: UIViewController) {
        UserSessionManager.shared.clearAccount()
        RootViewManager.didLoggedOutSuccessfully()
    }
    
    private func pushProfileViewController(_ viewController: UIViewController) {
        let profileViewController = ProfileViewController()
        viewController.navigationController?.pushViewController(profileViewController, animated: true)
    }
}

#Preview {
    UINavigationController(rootViewController: SettingsViewController())
}
