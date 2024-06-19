//
//  PlainMenuItemView.swift
//  Dine
//
//  Created by doss-zstch1212 on 14/06/24.
//

import SwiftUI

struct PlainMenuItemView: View {
    var menuItem: MenuItem
    
    var body: some View {
        HStack {
            Label(menuItem.name, systemImage: "app.dashed")
            
            Spacer()
            
            Text("x\(menuItem.count)")
        }
        .foregroundStyle(.black)
        // .padding()
        // .background(.app)
        // .clipShape(.rect(cornerRadius: 8))
    }
}

#Preview {
    PlainMenuItemView(menuItem: ModelData().menuItems[0])
}
