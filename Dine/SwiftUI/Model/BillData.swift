//
//  BillData.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/05/24.
//

import Foundation

struct BillData: Identifiable, Codable {
    var id: UUID
    var date: Date
    let billStatus: BillStatus
    let items: [Item]

    enum BillStatus: String, Codable {
        case paid = "Paid"
        case unpaid = "Unpaid"
        case waitingForConfirmation = "Processing"
    }
}

struct Item: Codable, Identifiable {
    var id: UUID
    let name: String
    let price: Double
}

