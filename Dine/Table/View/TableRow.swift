//
//  TableRow.swift
//  SwiftUIPractice
//
//  Created by doss-zstch1212 on 20/05/24.
//

import SwiftUI

struct TableRow: View {
    var table: RestaurantTable
    @ObservedObject var tableSelection = TableSelector()
    
    @State private var isSelected: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Location ID: \(table.locationId)")
                    .font(.headline)
                    
                Text("Capacity: \(table.capacity)")
                    .font(.caption)
                
                Text("\(UUID().uuidString)")
                    .font(.caption2)
                    
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                // Action for the plus button
                /*isSelected.toggle()
                print("Plus button tapped")*/
                tableSelection.toggleTableSelection()
            }) {
                Image(systemName: isSelected ? "checkmark" : "plus")
                    .foregroundColor(isSelected ? .black : .white)
                    .padding()
                    .background(isSelected ? Color.white : Color.black)
                    .clipShape(Circle())
            }
            .padding(.trailing)
        }
        .background(Color("AppColor"))
        .cornerRadius(20)
    }
}

extension Notification.Name {
    static let tableSelectionNotification = Notification.Name("com.euphoria.Dine.tableSelectionNotification")
}

#Preview {
    let tables = ModelData().tables
    return Group {
        TableRow(table: tables[0])
        TableRow(table: tables[1])
    }
}
