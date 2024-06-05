//
//  BillItem.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/05/24.
//

import SwiftUI

struct BillItem: View {
    var billData: Bill
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "square.dashed")
                    .font(.title3)
                    .padding(.bottom, 5)
                
                Text("Items _")
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
                    Label(billData.paymentStatus.rawValue, systemImage: "circle.dashed.inset.fill")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(billData.date, style: .date)
                        .font(.caption2)
                    
                    Image(systemName: "chevron.right")
                        .padding(.trailing)
                        .font(.caption2)
                }
                .padding(.bottom, 8)
                
                Text(billData.billId.uuidString)
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
    let billData = Bill(amount: 30, tip: 9, tax: 89, isPaid: true)
    
    return BillItem(billData: billData)
}
