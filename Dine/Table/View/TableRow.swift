//
//  TableRow.swift
//  SwiftUIPractice
//
//  Created by doss-zstch1212 on 20/05/24.
//

import SwiftUI

struct TableRow: View {
    @ObservedObject var table: RestaurantTable
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Location ID: \(table.locationIdentifier)")
                    .font(.headline)
                    
                Text("Capacity: \(table.capacity)")
                    .font(.subheadline)
            }
            .padding()
            
            Spacer()
            
            Image(systemName: table.isSelected ? "checkmark" : "plus")
                .foregroundColor(table.isSelected ? .black : .white)
                .padding()
                .background(table.isSelected ? Color.white : Color.black)
                .clipShape(Circle())
                .padding(.trailing)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
}

#Preview {
    let tables = ModelData().tables
    return Group {
        TableRow(table: tables[0])
        TableRow(table: tables[1])
    }
}
