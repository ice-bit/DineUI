//
//  MenuDetailView.swift
//  Dine
//
//  Created by doss-zstch1212 on 04/06/24.
//

import SwiftUI

struct MenuDetailView: View {
    var menuItem: MenuItem
    var body: some View {
        ScrollView {
            VStack {
                Image(.burger)
                    .frame(width: 300, height: 300)
                    .clipShape(.rect(cornerRadius: 30))
                
                Text(menuItem.name)
                    .font(.title)
                
                Text(String(menuItem.price))
                    .font(.title3)
                
                VStack {
                    Text("About")
                        .font(.headline)
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                        .frame(maxWidth: 300)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
    }
}

#Preview {
    MenuDetailView(menuItem: MenuItem(name: "Mac n Cheese", price: 7.9, menuSection: .mainCourse))
}
