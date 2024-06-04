//
//  MenuViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit

class MenuViewController: UIViewController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    private let menuService: MenuService
    private let sectionData = [
        SectionItem(symbol: UIImage(systemName: "hare.fill")!, title: "Starters"),
        SectionItem(symbol: UIImage(systemName: "hare.fill")!, title: "Mains"),
        SectionItem(symbol: UIImage(systemName: "hare.fill")!, title: "Side"),
        SectionItem(symbol: UIImage(systemName: "hare.fill")!, title: "Desserts"),
        SectionItem(symbol: UIImage(systemName: "hare.fill")!, title: "Beverages"),
    ]
    
    init(menuService: MenuService) {
        self.menuService = menuService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        tableView.backgroundColor = /*UIColor(named: "primaryBgColor")*/.systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomSectionCell.self, forCellReuseIdentifier: "CustomSectionCell")
    }
    
    private func setupAppearance() {
        self.title = "Menu"
        view.backgroundColor = /*UIColor(named: "primaryBgColor")*/.systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomSectionCell", for: indexPath) as? CustomSectionCell else {
            return UITableViewCell()
        }
        let sectionData = sectionData[indexPath.row]
        cell.iconImageView.image = sectionData.symbol
        cell.titleLabel.text = sectionData.title
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sectionData[indexPath.row]
        let detailVC = AddToCartViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        49
    }
}
