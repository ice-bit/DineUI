//
//  ModelData.swift
//  SwiftUIPractice
//
//  Created by doss-zstch1212 on 20/05/24.
//

import Foundation

@Observable
class ModelData {
    var orders: [Order] {
        do {
            let orderService = try OrderServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            if let results = try? orderService.fetch() {
                return results
            }
        } catch {
            print(error)
        }
        return [Order(
            tableId: UUID(),
            orderStatus: .preparing,
            menuItems: [MenuItem(
                name: "Bus",
                price: 3.9,
                category: MenuCategory(
                    id: UUID(),
                    categoryName: "Starter"
                )
            )]
        )]
    }
    
    var tables: [RestaurantTable] = [
        RestaurantTable(tableStatus: .free, maxCapacity: 12, locationIdentifier: 103),
        RestaurantTable(tableStatus: .free, maxCapacity: 12, locationIdentifier: 103),
        RestaurantTable(tableStatus: .free, maxCapacity: 12, locationIdentifier: 103),
    ]
    
    var sections: [SectionData] = load("SectionData.json")
    
     var menuItems: [MenuItem] = [
        MenuItem(
            name: "Sushi",
            price: 4.99,
            category: MenuCategory(
                id: UUID(),
                categoryName: "Starter"
            )
        )
     ]
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // Set the date decoding strategy
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

