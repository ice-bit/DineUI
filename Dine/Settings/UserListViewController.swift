//
//  UserListViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/08/24.
//

import UIKit

class UserListViewController: UIViewController {
    private var tableView: UITableView!
    private var searchController: UISearchController!
    private let cellReuseIdentifier = "cell"
    
    private var users: [Account] = [
        .init(username: "John Cena", password: "fwhbh#f5wdfg65", accountStatus: .active, userRole: .employee),
        .init(username: "JaneDoe123", password: "hgd7&^g3Hsdf", accountStatus: .active, userRole: .admin),
        .init(username: "Sam_Smith", password: "j@D3s8c#lsh", accountStatus: .cancelled, userRole: .waitStaff),
        .init(username: "Alice.Wonder", password: "q#2nd9Hsdfk2", accountStatus: .closed, userRole: .employee),
        .init(username: "BobBuilder", password: "Xy75@#hds7", accountStatus: .active, userRole: .waitStaff),
        .init(username: "Charlie.Brown", password: "9&fjD3@#s6k", accountStatus: .closed, userRole: .employee),
        .init(username: "EmilyDavis", password: "p@5Jk3^9Shd", accountStatus: .active, userRole: .manager),
        .init(username: "MikeTyson", password: "fjD7@&3klFj", accountStatus: .active, userRole: .waitStaff),
        .init(username: "Laura.Palmer", password: "m@3kF6#j8dP", accountStatus: .active, userRole: .employee),
        .init(username: "TonyStark", password: "5^6fHjs@f2D", accountStatus: .closed, userRole: .admin),
        .init(username: "BruceWayne", password: "j^k3@9Jd2sl", accountStatus: .cancelled, userRole: .admin),
    ]
    
    private var filteredUsers: [Account] = []
    private var sections: [String: [Account]] = [:]
    private var filteredSections: [String: [Account]] = [:]
    private var sectionTitles: [String] = []
    private var filteredSectionTitles: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Employees"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        populateUserData()
        prepareData()
        setupTableView()
        setupSearchController()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUser))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addUser() {
        // Present a view controller to add a new user
        let addUserFormViewController = AddUserFormViewController()
        addUserFormViewController.onDidAddUser = didAddUser
        if let sheet = addUserFormViewController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.preferredCornerRadius = 16
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        self.present(/*UINavigationController(rootViewController: addUserFormViewController)*/addUserFormViewController, animated: true)
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
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
    
    private func prepareData() {
        // Sort the users by username
        users.sort { $0.username.lowercased() < $1.username.lowercased() }
        
        // Group the users by the first letter of the username
        for user in users {
            let key = String(user.username.prefix(1)).uppercased()
            if var userGroup = sections[key] {
                userGroup.append(user)
                sections[key] = userGroup
            } else {
                sections[key] = [user]
            }
        }
        
        // Create section titles
        sectionTitles = sections.keys.sorted()
    }
    
    private func populateUserData() {
        do {
            let dbAccess = try SQLiteDataAccess.openDatabase()
            let accountService = AccountServiceImpl(databaseAccess: dbAccess)
            let resultUsers = try accountService.fetch()
            guard let resultUsers else { return }
            users = resultUsers
        } catch {
            fatalError("Failed to load user data")
        }
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredSections.removeAll()
        filteredSectionTitles.removeAll()
        
        if searchText.isEmpty {
            filteredUsers = users
            filteredSections = sections
            filteredSectionTitles = sectionTitles
        } else {
            filteredUsers = users.filter { user in
                return user.username.lowercased().contains(searchText.lowercased())
            }
            
            // Group the filtered users by the first letter of the username
            for user in filteredUsers {
                let key = String(user.username.prefix(1)).uppercased()
                if var userGroup = filteredSections[key] {
                    userGroup.append(user)
                    filteredSections[key] = userGroup
                } else {
                    filteredSections[key] = [user]
                }
            }
            filteredSectionTitles = filteredSections.keys.sorted()
        }
        tableView.reloadData()
    }
    
    private func didAddUser(_ user: Account) {
        // Update the users array
        users.append(user)
        
        // Update the main sections
        let key = String(user.username.prefix(1)).uppercased()
        if var userGroup = sections[key] {
            userGroup.append(user)
            sections[key] = userGroup
        } else {
            sections[key] = [user]
            sectionTitles.append(key)
            sectionTitles.sort() // Sort again after adding a new key
        }
        
        // Update filtered data if filtering is active
        if isFiltering {
            filterContentForSearchText(searchController.searchBar.text ?? "")
        } else {
            tableView.reloadData()
            scrollToRow(user)
        }
    }
    
    private func scrollToRow(_ account: Account) {
        let key = String(account.username.prefix(1)).uppercased()
        if let section = sections[key] {
            let row = section.firstIndex(where: { $0.username == account.username })
            let indexPath = IndexPath(row: row ?? 0, section: sectionTitles.firstIndex(of: key) ?? 0)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }

    private func didEditUser(_ user: Account) {
        // Update the main sections
        let key = String(user.username.prefix(1)).uppercased()
        if let userGroup = sections[key] {
            if let transiantUser = userGroup.first(where: { $0.username == user.username }) {
                transiantUser.updateAccount(user)
            }
        }
        
        // Update filtered data if filtering is active
        if isFiltering {
            filterContentForSearchText(searchController.searchBar.text ?? "")
        } else {
            tableView.reloadData()
        }
    }
}

extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        isFiltering ? filteredSectionTitles.count : sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isFiltering ? filteredSectionTitles[section] : sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey = isFiltering ? filteredSectionTitles[section] : sectionTitles[section]
        return isFiltering ? filteredSections[sectionKey]?.count ?? 0 : sections[sectionKey]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let sectionKey = isFiltering ? filteredSectionTitles[indexPath.section] : sectionTitles[indexPath.section]
        let userInSection = isFiltering ? filteredSections[sectionKey] : sections[sectionKey]
        if let user = userInSection?[indexPath.row] {
            var content = cell.defaultContentConfiguration()
            content.text = user.username
            content.secondaryText = user.userRole.rawValue
            content.image = UIImage(systemName: "person.fill")!
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        isFiltering ? filteredSectionTitles : sectionTitles
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionKey = isFiltering ? filteredSectionTitles[indexPath.section] : sectionTitles[indexPath.section]
        let userInSection = isFiltering ? filteredSections[sectionKey] : sections[sectionKey]
        if let user = userInSection?[indexPath.row] {
            let editUserFormViewController = EditUserFormViewController(account: user)
            editUserFormViewController.onDidEditUser = didEditUser
            navigationController?.pushViewController(editUserFormViewController, animated: true)
        }
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
}


extension UserListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text ?? "")
    }
}

#Preview {
    UINavigationController(rootViewController: UserListViewController())
}
