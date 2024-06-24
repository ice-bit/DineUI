//
//  OrderCountCellView.swift
//  Dine
//
//  Created by doss-zstch1212 on 21/06/24.
//

import SwiftUI

struct OrderCountCellView: View {
    var orderData: OrderData
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(orderData.date, format: .dateTime.weekday())
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .font(.system(.title3, weight: .bold).uppercaseSmallCaps())
                .frame(minWidth: 50)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(orderData.orderCount, format: .number)
                    .foregroundStyle(.primary)
                    .font(.system(.title, weight: .semibold))
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
                Text("orders")
                    .foregroundStyle(.orange)
                    .font(.system(.subheadline, weight: .bold))
            }
            Spacer()
        }
    }
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

#Preview {
    List {
        ForEach(OrderData.generateRandomData(days: 7)) { data in
            OrderCountCellView(orderData: data)
        }
    }
}

