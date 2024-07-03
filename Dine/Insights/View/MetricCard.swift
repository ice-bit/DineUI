//
//  InsightBlockView.swift
//  Dine
//
//  Created by doss-zstch1212 on 20/06/24.
//

import SwiftUI

enum MetricCardType {
    case sales
    case average
    case peakHours
    case popularItem
}

struct MetricCard: View {
    var viewModel: MetricCardViewModal
    
    var body: some View {
        switch viewModel.cardType {
        case .sales:
            SalesCardView(viewModel: viewModel)
        case .average:
            AverageCardView(viewModel: viewModel)
        case .peakHours:
            PeakHoursCardView(viewModel: viewModel)
        case .popularItem:
            PopularItemCardView(viewModel: viewModel)
        }
    }
}

struct SalesCardView: View {
    var viewModel: MetricCardViewModal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                .padding(.bottom, 1)
                .font(.subheadline)
                
                Text(viewModel.data)
                    .font(.headline)
                    .bold(true)
                
                
                Text(viewModel.footnote ?? "")
                    .font(.footnote)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct AverageCardView: View {
    var viewModel: MetricCardViewModal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .padding(.bottom, 4)
                    .font(.subheadline)
                
                Text(viewModel.data)
                    .font(.headline)
                    .bold()
                    .padding(.bottom, 4)
                
                Text(viewModel.footnote ?? "")
                    .font(.footnote)
                Spacer()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct PeakHoursCardView: View {
    var viewModel: MetricCardViewModal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .padding(.bottom, 4)
                    .font(.subheadline)
                
                Text(viewModel.data)
                    .font(.headline)
                    .bold()
                    .padding(.bottom, 4)
                
                Text(viewModel.footnote ?? "")
                    .font(.footnote)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct PopularItemCardView: View {
    var viewModel: MetricCardViewModal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .padding(.bottom, 4)
                    .font(.subheadline)
                
                Text("\(viewModel.data)")
                    .font(.headline)
                    .bold()
                    .padding(.bottom, 4)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    let viewModel = [
        MetricCardViewModal(
            title: "Peak Hours",
            percentageChange: "+2.5%",
            data: "12:00",
            footnote: "Orders peaked at \n12:00 Hour",
            cardType: .peakHours
        ),
        MetricCardViewModal(
            title: "Popular Item",
            percentageChange: "+2.5%",
            data: "Potassium Chloride",
            footnote: "Orders peaked at \n12:00 Hour",
            cardType: .popularItem
        )
    ]
    
    return MetricCard(viewModel: viewModel[1])
}
