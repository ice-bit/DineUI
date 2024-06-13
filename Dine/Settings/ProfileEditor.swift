//
//  ProfileEditor.swift
//  Dine
//
//  Created by doss-zstch1212 on 13/06/24.
//

import SwiftUI

struct ProfileEditor: View {
    @Binding var profile: Profile
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("Username").bold()
                    Divider()
                    TextField("Username", text: $profile.username)
                }
                
                HStack {
                    Text("Email").bold()
                    Divider()
                    TextField("Mail Address", text: $profile.email)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("Edit Profile")
        }
    }
}

#Preview {
    ProfileEditor(profile: .constant(.default))
}
