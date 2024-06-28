//
//  SettingsView.swift
//  Dine
//
//  Created by doss-zstch1212 on 13/06/24.
//

import SwiftUI

struct SettingsView: View {
    @State var account: Account
    @State var isDarkModeEnabled: Bool = true
    @State private var selectedLanguage = "English"
    let languages = ["English", "Spanish", "French", "German", "Chinese", "Japanese"]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(.circle)
                            
                            Text(account.username)
                                .font(.title)
                            
                            Text(account.userId.uuidString)
                                .font(.footnote)
                            
                            NavigationLink(destination: ProfileEditor(account: $account)) {
                                Button(action: {
                                    print("Edit profile button tapped")
                                }, label: {
                                    Text("Edit Profile*")
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .padding()
                                        .background(.app)
                                        .foregroundStyle(.black)
                                        .clipShape(.rect(cornerRadius: 12))
                                })
                            }
                        }
                        
                        Spacer()
                    }
                } footer: {
                    Text("*Experimental. (Not functional!)")
                        .font(.footnote)
                        .foregroundStyle(Color(.secondaryLabel))
                }
                
                Section(header: Text("Configuration*"), content: {
                    NavigationLink(destination: Text("Sasuke")) {
                        Label {
                            Text("Restaurant")
                                .font(.body)
                                .foregroundStyle(.primary)
                        } icon: {
                            Image(systemName: "fork.knife")
                                .foregroundStyle(.app)
                        }
                    }
                })
                
                
                Section(header: Text("Preference*"), content: {
                    Toggle(isOn: $isDarkModeEnabled) {
                        // Label("Dark Mode", systemImage: "moon.fill")
                        Label {
                            Text("Dark Mode")
                                .font(.body)
                                .foregroundStyle(.primary)
                        } icon: {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.app)
                        }
                    }
                    
                    Picker(selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) {
                            Text($0)
                        }
                    } label: {
                        Label {
                            Text("Language")
                                .font(.body)
                                .foregroundStyle(.primary)
                        } icon: {
                            Image(systemName: "globe")
                                .foregroundStyle(.app)
                        }
                    }

                })
                
                Section {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            print("Log out action")
                            UserSessionManager.shared.clearAccount()
                            RootViewManager.didLoggedOutSuccessfully()
                        }, label: {
                            Text("Log out")
                                .foregroundStyle(.red)
                        })
                        
                        Spacer()
                    }
                } footer: {
                    Text("*Expirimental feature")
                        .font(.footnote)
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(account: .default)
}
