//
//  InsightView.swift
//  Dine
//
//  Created by doss-zstch1212 on 20/06/24.
//

import SwiftUI

struct InsightView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.fixed(2))]) {
                LazyHGrid(rows: [GridItem(.fixed(2))]) {
                    MetricCard(
                        viewModal: MetricCardViewModal(
                            title: "Sales",
                            percentageChange: "+2.5%",
                            data: "$13453",
                            footnote: "$29304"
                        )
                    )
                    
                    MetricCard(
                        viewModal: MetricCardViewModal(
                            title: "Sales",
                            percentageChange: "+2.5%",
                            data: "$13453",
                            footnote: "$29304"
                        )
                    )
                }
                
                LazyHGrid(rows: [GridItem(.fixed(2))]) {
                    MetricCard(
                        viewModal: MetricCardViewModal(
                            title: "Sales",
                            percentageChange: "+2.5%",
                            data: "$13453",
                            footnote: "$29304"
                        )
                    )
                    
                    MetricCard(
                        viewModal: MetricCardViewModal(
                            title: "Sales",
                            percentageChange: "+2.5%",
                            data: "$13453",
                            footnote: "$29304"
                        )
                    )
                }
            }
        }
    }
}

#Preview {
    InsightView()
}


