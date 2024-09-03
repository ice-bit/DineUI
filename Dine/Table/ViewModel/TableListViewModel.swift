//
//  TableListViewModel.swift
//  Dine
//
//  Created by doss-zstch1212 on 03/09/24.
//

import Foundation
import UIKit
import Combine

struct TableListItem {
    let title: String
    let subtitle: String?
    let image: UIImage?
}

class TableListViewModel: ObservableObject {
    @Published private(set) var items: [TableListItem] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        fetchTablesFromDatabase()
        setupNotificationListners()
    }
    
    private func setupNotificationListners() {
        NotificationCenter.default
            .publisher(for: .tablesDidChangeNotification)
            .sink { [weak self] _ in
                self?.fetchTablesFromDatabase()
            }
            .store(in: &cancellables)
    }
    
    private func fetchTablesFromDatabase() {
        do {
            let dbAccessor = try SQLiteDataAccess.openDatabase()
            let tableService = TableServiceImpl(databaseAccess: dbAccessor)
            let resultTables = try tableService.fetch()
            guard let resultTables else { return }
            items = resultTables.map { table in
                    .init(
                        title: table.locationIdentifier.description,
                        subtitle: table.capacity.description,
                        image: nil
                    )
            }
        } catch {
            fatalError("Failed to perform fetch tables: \(error)")
        }
    }
    
    func getTable(at index: Int) -> RestaurantTable? {
        let tableListItem = items[index]
        do {
            let dbAccessor = try SQLiteDataAccess.openDatabase()
            let tableService = TableServiceImpl(databaseAccess: dbAccessor)
            let resultTables = try tableService.fetch()
            guard let resultTables else { return nil }
            let table = resultTables.first(where: { $0.locationIdentifier.description == tableListItem.title.description })
            return table
        } catch {
            fatalError("Failed to perform fetch tables: \(error)")
        }
    }
    
    func deleteTable(at index: Int) {
        guard let table = getTable(at: index) else { return }
        do {
            let tableService = try TableServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            try tableService.delete(table)
        } catch {
            fatalError("Error while deleting table! - \(error)")
        }
    }
}
