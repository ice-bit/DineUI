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
                
                Text(viewModal.percentageChange ?? "")
                    .font(.caption)
                    .foregroundStyle(.darkGreen)
            }
            .padding(.bottom, 1)
            
            Text(viewModal.data)
                .font(.title)
                .bold(true)
            
            Text(viewModal.footnote ?? "")
                .font(.footnote)
                .foregroundStyle(.gray)
        }
        .padding()
        .background(.app)
        .clipShape(.rect(cornerRadius: 12))
        .foregroundStyle(.black)
    }
}

#Preview {
    let viewModal = MetricCardViewModal(
        title: "Sales",
        percentageChange: "+2.5%",
        data: "$10345",
        footnote: "$1900"
    )
    
    return MetricCard(viewModal: viewModal)
}
