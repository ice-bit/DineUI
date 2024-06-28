//
//  ProfileEditor.swift
//  Dine
//
//  Created by doss-zstch1212 on 13/06/24.
//

import SwiftUI

struct ProfileEditor: View {
    @Binding var account: Account
    var body: some View {
        NavigationView {
            Text("Experimental")
                .font(.largeTitle)
            .navigationTitle("Edit Profile")
        }
    }
}

#Preview {
    ProfileEditor(account: .constant(.default))
}
