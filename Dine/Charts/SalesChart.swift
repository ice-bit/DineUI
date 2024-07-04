//
//  SalesChart.swift
//  Dine
//
//  Created by doss-zstch1212 on 04/07/24.
//

import SwiftUI
import Charts

struct SalesSummary: Identifiable {
    let weekday: Date
    let sales: Int
    
    var id: Date { weekday }
}

struct SalesChartViewModal {
    let salesByDateInterval: [TimePeriod: [SalesSummary]]
    
    subscript(timePeriod: TimePeriod) -> [SalesSummary]? {
        return salesByDateInterval[timePeriod]
    }
}

enum TimePeriod {
    case week
    case month
}

struct SalesChart: View {
    @State var timePeriod: TimePeriod = .week
    var salesData: SalesChartViewModal
    
    var data: [SalesSummary] {
        switch timePeriod {
        case .week:
            return salesData[.week] ?? []
        case .month:
            return salesData[.month] ?? []
        }
    }
    
    var body: some View {
        VStack {
            Picker("Time Period", selection: $timePeriod.animation(.easeInOut)) {
                Text("Weekly").tag(TimePeriod.week)
                Text("Monthly").tag(TimePeriod.month)
            }
            .pickerStyle(.segmented)
            Chart(data) { data in
                BarMark(
                    x: .value("Date", data.weekday),
                    y: .value("Sales", data.sales)
                )
                 .foregroundStyle(by: .value("Sales", data.sales))
            }
        }
    }
}

#Preview {
    SalesChart(salesData: SalesChartViewModal(salesByDateInterval: [.week: salesPerWeek, .month: salesPerMonth]))
}

