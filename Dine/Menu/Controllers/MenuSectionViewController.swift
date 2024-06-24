//
//  MenuSectionViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/05/24.
//

import UIKit
import SwiftUI

class MenuSectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var sectionData: [SectionData] = ModelData().sections
    private let menuService: MenuService
    
    // MARK: - Init
    init(menuService: MenuService) {
        self.menuService = menuService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Menu"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupCollectionView()
        view = collectionView
    }
    
    // MARK: - Methods
    private func setupCollectionView() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfig.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sectionData[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: sectionViewRegistration, for: indexPath, item: item)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionData.count
    }
    
    private var sectionViewRegistration: UICollectionView.CellRegistration<UICollectionViewCell, SectionData> = {
        .init { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                SectionView(sectionData: item)
            }
            .margins(.horizontal, 14)
            .margins(.vertical, 8)
        }
    }()
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sectionData[indexPath.item]
        guard let selectedSection = MenuSectionType(rawValue: item.sectionTitle) else {
            print("Invalid section data!")
            return
        }
        let sectionDetailVC = MenuListingViewController(activeSection: selectedSection)
        navigationController?.pushViewController(sectionDetailVC, animated: true)
    }
}
