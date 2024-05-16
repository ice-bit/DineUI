//
//  MenuViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit

class MenuViewController: UIViewController {
    
    private let menuService: MenuService
    
    private let menuSectionData = ["Starters", "Mains", "Side", "Desserts", "Beverages"]
    
    private var tableView: UITableView!
    
    init(menuService: MenuService) {
        self.menuService = menuService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: view.bounds)
        setupAppearance()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MenuSectionTableViewCell.self, forCellReuseIdentifier: MenuSectionTableViewCell.reuseIdentifier)
    }
    
    private func setupAppearance() {
        self.title = "Menu"
        view.backgroundColor = UIColor(named: "primaryBgColor")
        tableView.backgroundColor = UIColor(named: "primaryBgColor")
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuSectionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = menuSectionData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuSectionTableViewCell.reuseIdentifier, for: indexPath) as! MenuSectionTableViewCell
        cell.configure(title: data)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = menuSectionData[indexPath.row]
        let detailVC = MenuListViewController(sectionTitle: section, menuService: menuService, isPresented: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
