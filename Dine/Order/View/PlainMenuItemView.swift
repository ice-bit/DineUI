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
            Label(menuItem.name, systemImage: "carrot")
            
            Spacer()
            
            Text("x\(menuItem.count)")
        }
    }
}

#Preview {
    PlainMenuItemView(menuItem: ModelData().menuItems[0])
}
