//
//  MenuItemRow.swift
//  Dine
//
//  Created by doss-zstch1212 on 23/05/24.
//

import SwiftUI

struct MenuItemRow: View {
    var menuItem: MenuItem
    
    var body: some View {
        HStack {
            Image("burger")
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
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.caption)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline)
        }
        .padding()
        .background(.app)
        .clipShape(.rect(cornerRadius: 10))
        .foregroundStyle(.black)
    }
    
    
}

#Preview {
    let menuItem = MenuItem(
        name: "Beef Jerky",
        price: 4.96,
        category: MenuCategory(
            id: UUID(),
            categoryName: "Starter"
        )
    )
    return MenuItemRow(menuItem: menuItem)
}
