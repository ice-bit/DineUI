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
            Label(catergory.categoryName, systemImage: "square.dashed.inset.filled")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding()
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .padding()
        }
        .background(Color.app)
        .clipShape(.rect(cornerRadius: 10))
        .foregroundStyle(.black)
    }
}

#Preview {
    let data = MenuCategory(
        id: UUID(),
        categoryName: "Starters"
    )
    return SectionView(catergory: data)
}
