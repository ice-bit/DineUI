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
    private let staticGridData: [MetricCardViewModal] = [
        MetricCardViewModal(title: "Sales", percentageChange: "+2.5%", data: "$34643", footnote: "$32323"),
        MetricCardViewModal(title: "Average", data: "\(Insight().getAverageOrdersCount()) orders"),
        MetricCardViewModal(title: "Return", percentageChange: "\(Insight().getPercentageDifference())", data: "$\(Insight().getTodaysReturn())", footnote: "Compared to (\(Insight().getYesterdaysReturns())yesterday)"),
        MetricCardViewModal(title: "Sales", percentageChange: "+2.5%", data: "$34643", footnote: "$32323"),
    ]
    
    private let staticOrderCountData: [OrderData] = OrderData.generateRandomData(days: 7)
    
    private let chartData = [
        OrderData.generateRandomData(days: 7),
        OrderData.generateRandomData(days: 7),
        OrderData.generateRandomData(days: 7)
    ]
    
//    private let chartData = [Insight().getChartData()]
    
    override func loadView() {
        setUpCollectionView()
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Insights"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupBarButton()
    }
    
    private func setupBarButton() {
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(settingsButtonAction(_ :)))
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    @objc private func settingsButtonAction(_ sender: UIBarButtonItem) {
        print(#function)
        let settingsHostingController = UIHostingController(rootView: SettingsView(profile: .init(username: "Sassuke Uchicha", email: "killitachi@leafvillage.com", password: "fygweihfbwef")))
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
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
    
    // Returns a compositional layout section for cells that will scroll orthogonally.
    private func createOrthogonalScrollingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .zero
        group.contentInsets.leading = LayoutMetrics.horizontalMargin
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
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
            return staticGridData.count
        case .salesChart:
            return chartData.count
        case .salesList:
            return staticOrderCountData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch InsightSection(rawValue: indexPath.section)! {
        case .quickInsights:
            let item = staticGridData[indexPath.item]
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
                MetricCard(viewModal: itemIdentifier)
            }
            /*.margins(.horizontal, LayoutMetrics.horizontalMargin)
            .background {
                RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            }*/
        }
    }()
    
    // A cell registration that configures a custom cell with a SwiftUI chart view.
    private var metricChartCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, [OrderData]> = {
        .init { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIHostingConfiguration {
                MetricChart(orderData: itemIdentifier)
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

