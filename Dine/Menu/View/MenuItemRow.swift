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
            AsyncImage(url: menuItem.imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                @unknown default:
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                }
            }
            .clipShape(.rect(cornerRadius: 6))
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
