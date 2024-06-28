//
//  ChartViewModal.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/06/24.
//

import Foundation

struct ChartViewModal {
    let weeklySales: [SalesReport]
    let monthlySales: [SalesReport]
}

extension ChartViewModal {
    static func generateRandomChartViewModal() -> ChartViewModal {
        let weeklySales = SalesReport.generateRandomSalesReports(count: 7)
        let monthlySales = SalesReport.generateRandomSalesReports(count: 30)
        return ChartViewModal(weeklySales: weeklySales, monthlySales: monthlySales)
    }
}
