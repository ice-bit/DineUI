//
//  TablesViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit
import SwiftUI

class TablesViewController: UIViewController {
    
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupAppearance()
        
    }
    
    @objc private func addTableButtonTapped(sender: UIBarButtonItem) {
        print("Add table button tapped")
        let hostingVC = UIHostingController(rootView: AddTableFormView())
        let addTableSheetVC = /*AddTablesViewController()*/hostingVC
        if let sheet = addTableSheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        self.present(addTableSheetVC, animated: true)
    }
    
    private func setupAppearance() {
        self.title = "Tables"
        view.backgroundColor = UIColor(named: "primaryBgColor")
        setupNavBar()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTableButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        // register cell
        collectionView.register(TableCollectionViewCell.self, forCellWithReuseIdentifier: "CustomCell")
        collectionView.backgroundColor = UIColor(named: "primaryBgColor")
        view.addSubview(collectionView)
    }

}

extension TablesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as? TableCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
    
    
}

extension TablesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        CGSize(width: 162, height: 65)
        let width = (collectionView.frame.width / 2) - 16 // Adjust for padding
        let height: CGFloat = 80 // Set your desired cell height
        return CGSize(width: width, height: height)
    }
}

