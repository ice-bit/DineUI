//
//  OrderData.swift
//  Dine
//
//  Created by doss-zstch1212 on 21/06/24.
//

import Foundation

struct OrderData: Identifiable {
    let id = UUID()
    let date: Date
    let orderCount: Int
}

extension OrderData {
    static func generateRandomData(days: Int) -> [OrderData] {
        var data = [OrderData]()
        let today = Date()
        for index in 0..<days {
            let date = Calendar.current.date(byAdding: .day, value: -index, to: today)!
            let stepCount = Int.random(in: 500...25_000)
            data.append(OrderData(date: date, orderCount: stepCount))
        }
        return data
    }
}
