//
//  Table.swift
//  SwiftUIPractice
//
//  Created by doss-zstch1212 on 20/05/24.
//

import Foundation

enum TableStatus: String, CaseIterable, Codable {
    case free = "Free"
    case reserved = "Reserved"
    case occupied = "Occupied"
    case other = "Other"
}

struct TableData: Codable, Identifiable, Hashable {
    let id: UUID
    let locationID: Int
    let capacity: Int
    let tableStatus: TableStatus
}

fileprivate var getNewTableID: String {
    let uuid = UUID().uuidString
    let uuidData = uuid.data(using: .utf8)!
    let base64UUID = uuidData.base64EncodedString()
    let shortUUID = String(base64UUID.prefix(8))  // Adjust length as needed
    return shortUUID
}
