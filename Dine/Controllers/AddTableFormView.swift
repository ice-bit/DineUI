//
//  AddTableFormView.swift
//  Dine
//
//  Created by doss-zstch1212 on 16/05/24.
//

import SwiftUI

extension NSNotification.Name {
    static let didAddTable = Notification.Name("com.euphoria.Dine.didAddTable")
}

struct AddTableFormView: View {
    @State private var locationID: String = ""
    @State private var selectedNumber: Int = 0
    
    // Access the environment variable for presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Location Identifier", text: $locationID)
                        .keyboardType(.numberPad)
                    
                    Picker("Capacity", selection: $selectedNumber) {
                        ForEach(1..<21) {
                            Text("\($0)").tag($0)
                        }
                    }
                }
                
            }
            .navigationTitle("Add Table")
            .navigationBarItems(leading: Button("Cancel", action: {
                // dismiss
                presentationMode.wrappedValue.dismiss()
            }), trailing: Button("Add", action: {
                // Handle add action
                guard let databaseAccess = try? SQLiteDataAccess.openDatabase() else {
                    print("Failed to open DB connection")
                    return
                }
                guard let locationIDString = Int(locationID) else {
                    print("Failed to convert the location ID")
                    return
                }
                let tableService = TableServiceImpl(databaseAccess: databaseAccess)
                // create new table instance
                let newTable = RestaurantTable(
                    tableStatus: .free,
                    maxCapacity: selectedNumber,
                    locationIdentifier: Int(locationIDString)
                )
                do {
                    try tableService.add(newTable)
                } catch {
                    print("Unable to add new table!")
                }
                // Notifying the observers a new table has been added
                NotificationCenter.default.post(name: .didAddTable, object: nil)
                presentationMode.wrappedValue.dismiss()
            }))
        }
    }
}

#Preview {
    AddTableFormView()
}

