//
//  MenuItemRow.swift
//  Dine
//
//  Created by doss-zstch1212 on 23/05/24.
//

import SwiftUI

struct MenuItemRow: View {
    @ObservedObject var menuItem: MenuItem
    
    var body: some View {
        HStack {
            Image(uiImage: (menuItem.image ?? UIImage(named: "burger")!))
                .resizable()
                .clipShape(.rect(cornerRadius: 10))
                .frame(width: 75, height: 75)
            
            VStack(alignment: .leading) {
                Image(systemName: "square.dashed")
                    .font(.caption)
                
                Text("\(menuItem.name)")
                    .font(.headline)
                
                Text("$" + String(format: "%.2f", menuItem.price))
                    .font(.subheadline)
                
                Text(menuItem.description)
                    .font(.caption)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
    
    
}
