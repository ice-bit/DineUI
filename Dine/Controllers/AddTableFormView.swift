//
//  AddTableFormView.swift
//  Dine
//
//  Created by doss-zstch1212 on 16/05/24.
//

import SwiftUI

protocol AddFormViewControllerDelegate: AnyObject {
    func didAddTable(_ table: RestaurantTable)
}

struct AddTableFormView: View {
    @State private var locationID: String = ""
    @State private var selectedNumber: Int = 0
    @State private var endDate: Date = Date().addingTimeInterval(3600) // 1 hour later
    @State private var travelTime: String = "None"
    @State private var repeatEvent: String = "Never"
    
    // Access the environment variable for presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    weak var delegate: AddFormViewControllerDelegate?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $locationID)
                    
                    Picker("Capacity", selection: $selectedNumber) {
                        ForEach(1..<21) {
                            Text("\($0)").tag($0)
                        }
                    }
                }
                
                /*Section {
                    Picker("Table Status", selection: $travelTime) {
                        Text("Free").tag("Free")
                        Text("Pre").tag("5 minutes")
                        Text("10 minutes").tag("10 minutes")
                        // Add more options as needed
                    }
                }*/
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
                try? tableService.add(newTable)
                // if the new table is not added don't add in runtime memory
                delegate?.didAddTable(newTable)
                presentationMode.wrappedValue.dismiss()
            }))
        }
    }}

#Preview {
    AddTableFormView()
}

