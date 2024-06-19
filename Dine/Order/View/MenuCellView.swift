//
//  MenuCellView.swift
//  Dine
//
//  Created by doss-zstch1212 on 17/06/24.
//

import SwiftUI

struct MenuCellView: View {
    var order: Order
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.title3)
                    .padding(.bottom, 5)
                
                Text("Items \(order.menuItems.count)")
                    .font(.caption)
            }
            .padding()
            .overlay (
                Rectangle()
                    .frame(width: 1, height: 50)
                    .foregroundStyle(.primary),
                alignment: .trailing
            )
            
            VStack(alignment: .leading) {
                HStack {
                    Label(order.orderStatusValue.rawValue, systemImage: "circle.dashed.inset.fill")
                        /*.font(.subheadline)*/ // While the tableView is in editing mode this label will truncate!
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(order.getDate, style: .date)
                        .font(.caption2)
                    
                    Image(systemName: "chevron.right")
                        .padding(.trailing)
                        .font(.caption2)
                }
                .padding(.bottom, 8)
                
                Text(order.orderIdValue.uuidString)
                    .font(.caption2)
                    .padding(.trailing)
            }
        }
        .background(.app)
        .clipShape(.rect(cornerRadius: 10))
        .foregroundStyle(.black)
    }
}

#Preview {
    let order = Order(tableId: UUID(), orderStatus: .received, menuItems: ModelData().menuItems)
    return MenuCellView(order: order)
}
