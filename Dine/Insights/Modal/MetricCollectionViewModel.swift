//
//  MetricDataProvider.swift
//  Dine
//
//  Created by doss-zstch1212 on 26/06/24.
//

import Foundation

struct MetricCollectionViewModel {
    private let metricRecord = MetricRecord()
    
    var gridData: [MetricCardViewModal] {
        generateGridData()
    }
    
    func generateGridData() -> [MetricCardViewModal] {
        // Generate sales report
        let saleData = metricRecord.totalSales(for: Date())
        print("Sale data: \(saleData)")
        let salesReport = MetricCardViewModal(title: "Sales", data: "$\(saleData.rounded())", footnote: "Today's sales report.", cardType: .sales)
        
        // Generate average report
        let averageData = metricRecord.averageOrderValue(for: Date())
        print("Average order: \(averageData)")
        let averageReport = MetricCardViewModal(title: "Average", data: "\(averageData.rounded()) Orders", footnote: "Average orders received today.", cardType: .average)
        
        // Generate peak hours report
        let peakHourData = metricRecord.peakHours(for: Date())
        var peakHourLabel = ""
        if let peakHour = peakHourData.max(by: { a, b in a.value < b.value }) {
            let labelText = "Hour: \(peakHour.key), Orders: \(peakHour.value)"
            peakHourLabel = labelText
        } else {
            peakHourLabel = "No orders available"
        }
        let peakHourReport = MetricCardViewModal(title: "Peak Hour", data: peakHourLabel, cardType: .peakHours)
        
        // Generate popular item report
        let popularItem: MenuItem = metricRecord.popularItem() ?? MenuItem(
            name: "No Data Available",
            price: 0.0,
            category: MenuCategory(
                id: UUID(),
                categoryName: "Starter"
            )
        )
        let popularItemReport = MetricCardViewModal(title: "Popular Item", data: "\(popularItem.name)", cardType: .popularItem)
        
        // After generating return
        let viewModelData = [salesReport, averageReport, peakHourReport, popularItemReport]
        return viewModelData
    }
    
    func generateChartData() -> [ChartViewModal] {
        var salesReport = [ChartViewModal]()
        
        let salesReportLast7Days = metricRecord.salesReportLast7Days()
        let chartViewModal = ChartViewModal(weeklySales: salesReportLast7Days, monthlySales: [])
        
        salesReport.append(chartViewModal)
        
        return salesReport
    }
}
