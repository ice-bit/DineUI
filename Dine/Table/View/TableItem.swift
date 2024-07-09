//
//  TableItem.swift
//  SwiftUIPractice
//
//  Created by doss-zstch1212 on 21/05/24.
//

import SwiftUI

struct TableItem: View {
    @ObservedObject var table: RestaurantTable
    
    var body: some View {
        VStack {
            Image("table") // Replace with the actual image name
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(10)
            
            
            HStack {
                Text("Location ID -")
                Text("\(table.locationIdentifier)")
                    .lineLimit(1)
            }
            .font(.subheadline)
            
            HStack {
                Text("Capacity -")
                Text("\(table.capacity)")
            }
            .font(.subheadline)
        }
        .font(.subheadline)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    let tables = ModelData().tables
    return Group {
        TableItem(table: tables[0])
        TableItem(table: tables[1])
    }
}
