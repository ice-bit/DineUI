//
//  BillItem.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/05/24.
//

import SwiftUI

struct BillItemView: View {
    var billData: Bill
    
    var body: some View {
        HStack {
            VStack {
                Text("#\(billData.getOrder?.getTable?.locationIdentifier ?? 0)")
                    .font(.subheadline)
                    .padding(.bottom, 8)
                
                Image(systemName: "table.furniture")
                    .font(.title3)
                    .padding(.bottom, 5)
            }
            .padding()
            .overlay (
                Rectangle()
                    .frame(width: 1, height: 44),
                alignment: .trailing
            )
            
            Label(billData.paymentStatus.rawValue, systemImage: billData.isPaid ? "checkmark.circle.fill" : "multiply.circle.fill")
                .foregroundStyle(Color(.label))
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack {
                    Text(billData.date, style: .date)
                        .font(.caption2)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                }
                .padding(.bottom, 8)
                
                Text("Items \(billData.getOrderedItems?.count ?? 0)")
                    .font(.subheadline)
            }
            .padding()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    let billData = Bill(amount: 30, tip: 9, tax: 89, orderId: UUID(), isPaid: true)
    
    return BillItemView(billData: billData)
}
