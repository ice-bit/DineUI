//
//  NoResultCellView.swift
//  Dine
//
//  Created by doss-zstch1212 on 05/08/24.
//

import SwiftUI

struct NoResultCellView: View {
    var body: some View {
        VStack {
            Label("Add Items to Continue", systemImage: "quote.opening")
                .foregroundStyle(Color.gray)
        }
        .padding()
    }
}

#Preview {
    NoResultCellView()
}
