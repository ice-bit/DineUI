//
//  SectionView.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/05/24.
//

import SwiftUI

struct SectionView: View {
    var sectionData: SectionData
    
    var body: some View {
        HStack {
            Label(sectionData.sectionTitle, systemImage: sectionData.systemImage)
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
    let data = SectionData(systemImage: "doc.richtext.ja", sectionTitle: "Starters")
    return SectionView(sectionData: data)
}
