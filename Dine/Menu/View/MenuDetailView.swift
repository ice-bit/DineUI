//
//  MenuDetailView.swift
//  Dine
//
//  Created by doss-zstch1212 on 04/06/24.
//

import SwiftUI

struct MenuDetailView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image(.burger)
                        .frame(width: 300, height: 300)
                        .clipShape(.rect(cornerRadius: 30))
                    
                    Text("Mac n Cheese")
                        .font(.title)
                    
                    Text("$23.09")
                        .font(.title3)
                    
                    VStack {
                        Text("About")
                            .font(.headline)
                        Text("I want a UIAlertController which helps in editing, to text field and one picker to scroll and pick from")
                            .frame(maxWidth: 300)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Mac n Cheese")
    }
}

#Preview {
    MenuDetailView()
}
