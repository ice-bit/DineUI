//
//  SectionView.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/05/24.
//

import SwiftUI

struct SectionView: View {
    var catergory: MenuCategory
    
    var body: some View {
        HStack {
            Label(catergory.categoryName, systemImage: "square.3.layers.3d.top.filled")
                .foregroundStyle(Color(.label))
                .font(.subheadline)
                .padding()
            
            Spacer()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    let data = MenuCategory(
        id: UUID(),
        categoryName: "Starters"
    )
    return SectionView(catergory: data)
}
