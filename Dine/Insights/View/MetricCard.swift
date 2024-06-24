//
//  InsightBlockView.swift
//  Dine
//
//  Created by doss-zstch1212 on 20/06/24.
//

import SwiftUI

struct MetricCard: View {
    var viewModal: MetricCardViewModal
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModal.title)
                    .padding(.trailing)
                
                Text(viewModal.percentageChange)
                    .font(.caption)
                    .foregroundStyle(.darkGreen)
            }
            .padding(.bottom, 1)
            
            Text(viewModal.amount)
                .font(.title)
                .bold(true)
            
            Text(viewModal.comparison)
                .font(.footnote)
                .foregroundStyle(.gray)
        }
        .padding()
        .background(.app)
        .clipShape(.rect(cornerRadius: 24))
        .foregroundStyle(.black)
        .frame(width: 200)
    }
}

#Preview {
    let viewModal = MetricCardViewModal(
        title: "Sales",
        percentageChange: "+2.5%",
        amount: "$10345",
        comparison: "Compared to \n($1900 last year)"
    )
    
    return MetricCard(viewModal: viewModal)
}
