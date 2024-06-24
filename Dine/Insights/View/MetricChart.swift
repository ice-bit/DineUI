//
//  MetricChartView.swift
//  Dine
//
//  Created by doss-zstch1212 on 20/06/24.
//

import SwiftUI
import Charts

struct MetricChart: View {
    var orderData: [OrderData]
    
    var body: some View {
        Chart(orderData) { data in
            BarMark(
                x: .value("Day", data.date.weekday),
                y: .value("Count", data.orderCount)
            )
        }
    }
}

#Preview {
    MetricChart(orderData: OrderData.generateRandomData(days: 7))
}


