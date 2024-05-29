//
//  TableItem.swift
//  SwiftUIPractice
//
//  Created by doss-zstch1212 on 21/05/24.
//

import SwiftUI

struct TableItem: View {
    var table: RestaurantTable
    
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
                Text("\(table.locationId)")
            }
            
            HStack {
                Text("Capacity -")
                Text("\(table.capacity)")
            }
        }
        .font(.subheadline)
        .padding()
        .background(Color.app)
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
