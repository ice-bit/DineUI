//
//  MetricChartView.swift
//  Dine
//
//  Created by doss-zstch1212 on 20/06/24.
//

import SwiftUI
import Charts

enum SalesType {
    case week
    case month
}


struct MetricChart: View {
    @State private var salesType: SalesType = .week
    var chartData: ChartViewModal
    
    private var data: [SalesReport] {
        switch salesType {
        case .week:
            chartData.weeklySales
        case .month:
            chartData.monthlySales
        }
    }
    
    var body: some View {
        /*Picker("Sales", selection: $salesType) {
            Text("Week")
            Text("Month")
        }
        .pickerStyle(.segmented)*/
        Chart(data) { data in
            BarMark(
                x: .value("Day", data.date.weekday),
                y: .value("Count", data.report)
            )
            .foregroundStyle(by: .value("Date", data.date.weekday))
        }
    }
}

extension SalesReport {
    static func generateRandomData(days: Int) -> [SalesReport] {
        var data = [SalesReport]()
        let today = Date()
        for index in 0..<days {
            let date = Calendar.current.date(byAdding: .day, value: -index, to: today)!
            let orderCount = Int.random(in: 500...25_000)
            data.append(SalesReport(date: date, report: Double(orderCount)))
        }
        return data
    }
}

#Preview {
    MetricChart(
        chartData: ChartViewModal(
            weeklySales: SalesReport.generateRandomData(days: 7),
            monthlySales: SalesReport.generateRandomData(days: 6)
        )
    )
}


