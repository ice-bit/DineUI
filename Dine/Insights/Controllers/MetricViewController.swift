//
//  MetricViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 20/06/24.
//

import UIKit
import SwiftUI

// An enum representing the sections of this collection view.
private enum InsightSection: Int, CaseIterable {
    case quickInsights
    case salesChart
    case salesList
}

class MetricViewController: UIViewController, UICollectionViewDataSource {
    
    // The collection view which will display the custom cells.
    private var collectionView: UICollectionView!
    
    // Static view modal data for grid items
    private var gridData: [MetricCardViewModal] = []
    
    private let staticOrderCountData: [OrderData] = OrderData.generateRandomData(days: 7)
    
    private var chartData: [ChartViewModal] = []
    
//    private let chartData = [Insight().getChartData()]
    
    override func loadView() {
        setUpCollectionView()
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Insights"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Poppulate data
        populateCollectionViewData()
        setupBarButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(metricDataDidChange(_:)), name: .metricDataDidChangeNotification, object: nil)
    }
    
    @objc private func metricDataDidChange(_ sender: Notification) {
        print("Reloading metric data...")
        populateCollectionViewData()
        collectionView.reloadData()
    }
    
    private func populateCollectionViewData() {
        populateGridData()
        populateChartData()
    }
    
    private func populateGridData() {
         gridData = MetricCollectionViewModel().gridData
    }
    
    private func populateChartData() {
        // Uncomment for live data
        // chartData = MetricCollectionViewModel().generateChartData()
        chartData = [ChartViewModal.generateRandomChartViewModal()]
    }
    
    private func setupBarButton() {
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(settingsButtonAction(_ :))
        )
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    @objc private func settingsButtonAction(_ sender: UIBarButtonItem) {
        print(#function)
        guard let account = UserSessionManager.shared.loadAccount() else {
            fatalError("Invalid User session")
        }
        let settingsHostingController = UIHostingController(
            rootView: SettingsView(account: account)
        )
        self.present(settingsHostingController, animated: true)
    }
    
    private func setUpCollectionView() {
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in
            switch InsightSection(rawValue: sectionIndex)! {
            case .quickInsights:
                return createGridSection()
            case .salesChart:
                return createOrthogonalScrollingSection()
            case .salesList:
                return createListSection(layoutEnvironment)
            }
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.allowsSelection = false
        collectionView.dataSource = self
    }
    
    private struct LayoutMetrics {
        static let horizontalMargin = 16.0
        static let sectionSpacing = 10.0
        static let cornerRadius = 10.0
    }
    
    // Returns a compositional layout section for cells in a grid.
    private func createGridSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .zero
        section.contentInsets.leading = LayoutMetrics.horizontalMargin
        section.contentInsets.trailing = LayoutMetrics.horizontalMargin
        section.contentInsets.bottom = LayoutMetrics.sectionSpacing
        return section
    }
    
    // Returns a compositional layout section for cells that will scroll orthogonally. (Chart)
    private func createOrthogonalScrollingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .zero
        group.contentInsets.leading = LayoutMetrics.horizontalMargin
        
        let section = NSCollectionLayoutSection(group: group)
        // section.orthogonalScrollingBehavior = .groupPaging 
        section.contentInsets = .zero
        section.contentInsets.trailing = LayoutMetrics.horizontalMargin
        section.contentInsets.bottom = LayoutMetrics.sectionSpacing
        return section
    }
    
    // Returns a compositional layout section for cells in a list.
    private func createListSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        section.contentInsets = .zero
        section.contentInsets.leading = LayoutMetrics.horizontalMargin
        section.contentInsets.trailing = LayoutMetrics.horizontalMargin
        section.contentInsets.bottom = LayoutMetrics.sectionSpacing
        return section
    }
    
    // MARK: - CollectionView datasource methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        InsightSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch InsightSection(rawValue: section)! {
        case .quickInsights:
            return gridData.count
        case .salesChart:
            return chartData.count
        case .salesList:
            return staticOrderCountData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch InsightSection(rawValue: indexPath.section)! {
        case .quickInsights:
            let item = gridData[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(using: metricCellRegistration, for: indexPath, item: item)
        case .salesChart:
            let item = chartData[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(using: metricChartCellRegistration, for: indexPath, item: item)
        case .salesList:
            let item = staticOrderCountData[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(using: orderCountCellRegistration, for: indexPath, item: item)
        }
    }
    
    // A cell registration that configures a custom cell with a SwiftUI metric view.
    private var metricCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, MetricCardViewModal> = {
        .init { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIHostingConfiguration {
                MetricCard(viewModel: itemIdentifier)
            }
            /*.margins(.horizontal, LayoutMetrics.horizontalMargin)
            .background {
                RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            }*/
        }
    }()
    
    // A cell registration that configures a custom cell with a SwiftUI chart view.
    private var metricChartCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, ChartViewModal> = {
        .init { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIHostingConfiguration {
                MetricChart(chartData: itemIdentifier)
            }
            .margins(.horizontal, LayoutMetrics.horizontalMargin)
            .background {
                RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            }
        }
    }()
    
    // A cell registration that configures a custom cell with SwiftUI order count view.
    private var orderCountCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, OrderData> = {
        .init { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIHostingConfiguration {
                OrderCountCellView(orderData: itemIdentifier)
            }
        }
    }()
    
    
}

#Preview {
    UINavigationController(rootViewController: MetricViewController())
}

