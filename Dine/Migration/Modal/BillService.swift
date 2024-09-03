//
//  BillService.swift
//  Dine
//
//  Created by doss-zstch1212 on 26/03/24.
//

import Foundation

protocol BillService {
    func add(_ bill: Bill) throws
    func fetch() throws -> [Bill]?
    func update(_ bill: Bill) throws
    func delete(_ bill: Bill) throws
}

struct BillServiceImpl: BillService {
    
    private let databaseAccess: DatabaseAccess
    
    init(databaseAccess: DatabaseAccess) {
        self.databaseAccess = databaseAccess
    }
    
    func add(_ bill: Bill) throws {
        try databaseAccess.insert(bill)
        publishNotification()
    }
    
    func fetch() throws -> [Bill]? {
        let query = "SELECT * FROM \(DatabaseTables.billTable.rawValue);"
        guard let resultBills = try? databaseAccess.retrieve(query: query, parseRow: Bill.parseRow) as? [Bill] else {
            throw DatabaseError.conversionFailed
        }
        return resultBills
    }
    
    func update(_ bill: Bill) throws {
        try databaseAccess.update(bill)
        publishNotification()
    }
    
    func delete(_ bill: Bill) throws {
        try databaseAccess.delete(item: bill)
        publishNotification()
    }
    
    private func publishNotification() {
        NotificationCenter.default.post(name: .billDidChangeNotification, object: nil)
    }
}
