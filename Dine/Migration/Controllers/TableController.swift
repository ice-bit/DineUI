//
//  TableController.swift
//  Dine
//
//  Created by doss-zstch1212 on 12/02/24.
//

import Foundation

protocol TableServicable {
    func addTable(maxCapacity: Int, locationIdentifier: Int) throws
    func removeTable(_ table: RestaurantTable) -> Bool
    func fetchAvailableTables() -> [RestaurantTable]?
    func fetchTables() -> [RestaurantTable]?
}

class TableController: TableServicable {
    private let tableService: TableService
    init(tableService: TableService) {
        self.tableService = tableService
    }
    
    func addTable(maxCapacity: Int, locationIdentifier: Int) throws  {
        let table = RestaurantTable(tableStatus: .free, maxCapacity: maxCapacity, locationIdentifier: locationIdentifier)
        
        let resultTables = try tableService.fetch()
        guard let resultTables else { throw TableError.parsingFailed }
            
        if let _ = resultTables.first(where: { $0.locationIdentifier == locationIdentifier }) {
            throw TableError.locationIdAlreadyTaken
        }
            
        try tableService.add(table)
        print("Table added successfully to DB")
    }
    
    func removeTable(_ table: RestaurantTable) -> Bool {
        do {
            try tableService.delete(table)
            print("Restaurant table removed successfully.")
            return true
        } catch {
            print("Error removing table: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchAvailableTables() -> [RestaurantTable]? {
        guard let resultTables = try? tableService.fetch() else {
            print("Failed to fetch available tables.")
            return nil
        }
        let availableTables = resultTables.filter { $0.tableStatus == .free }
        return availableTables
    }
    
    func fetchTables() -> [RestaurantTable]? {
        guard let resultTables = try? tableService.fetch() else {
            print("Failed to fetch available tables.")
            return nil
        }
        return resultTables
    }
}

enum TableError: Error {
    case locationIdAlreadyTaken
    case parsingFailed
    case invalidLocationId
    case invalidCapacity
    case noDataFound
    case unknownError(Error)
}
