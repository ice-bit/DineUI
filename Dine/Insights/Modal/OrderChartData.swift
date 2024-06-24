//
//  OrderChartData.swift
//  Dine
//
//  Created by doss-zstch1212 on 20/06/24.
//

import Foundation

struct OrderChartData: Identifiable {
    let id = UUID()
    let date: String
    let count: Int
}
