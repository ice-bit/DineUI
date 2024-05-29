//
//  BillItem.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/05/24.
//

import SwiftUI

struct BillItem: View {
    var billData: BillData
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "square.dashed")
                    .font(.title3)
                    .padding(.bottom, 5)
                
                Text("Items \(billData.items.count)")
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
                    Label(billData.billStatus.rawValue, systemImage: "circle.dashed.inset.fill")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(billData.date, style: .date)
                        .font(.caption2)
//                        .padding(.trailing)
                    
                    Image(systemName: "chevron.right")
                        .padding(.trailing)
                        .font(.caption2)
                }
                .padding(.bottom, 8)
                
                Text(billData.id.uuidString)
                    .font(.caption2)
                    .padding(.trailing)
            }
        }
        .background(.app)
        .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    let billData = BillData(
        id: UUID(), date: Date(),
        billStatus: .waitingForConfirmation,
        items: [
            Item(id: UUID(), name: "Sushi", price: 4.8),
            Item(id: UUID(), name: "Sushi", price: 4.8),
            Item(id: UUID(), name: "Sushi", price: 4.8)
        ])
    
    return BillItem(billData: billData)
}
