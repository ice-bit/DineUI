//
//  MenuCellView.swift
//  Dine
//
//  Created by doss-zstch1212 on 17/06/24.
//

import SwiftUI

struct OrderCellView: View {
    var order: Order
    
    var body: some View {
        HStack {
            VStack {
                Text("#\(order.getTable?.locationIdentifier ?? 0)")
                    .font(.subheadline)
                    .padding(.bottom, 8)
                
                Image(systemName: "table.furniture")
                    .font(.title3)
                    .padding(.bottom, 5)
            }
            .padding()
            .overlay (
                Rectangle()
                    .frame(width: 1, height: 44)
                    .foregroundStyle(.primary),
                alignment: .trailing
            )
            
            Label(order.orderStatusValue.rawValue, systemImage: "circle.dashed.inset.fill")
                /*.font(.subheadline)*/ // While the tableView is in editing mode this label will truncate!
                .foregroundStyle(.primary)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack {
                    Text(order.getDate, style: .date)
                        .font(.caption2)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                }
                .padding(.bottom, 8)
                
                Text("Items \(order.menuItems.count)")
                    .font(.subheadline)
            }
            .padding()
        }
        .background(Color.app)
        .clipShape(.rect(cornerRadius: 10))
        .foregroundStyle(.black)
    }
}

#Preview {
    let order = Order(tableId: UUID(), orderStatus: .received, menuItems: ModelData().menuItems)
    return OrderCellView(order: order)
}
