//
//  OrderData.swift
//  Dine
//
//  Created by doss-zstch1212 on 21/06/24.
//

import Foundation

struct OrderData: Identifiable {
    let id = UUID()
    let date: Date
    let orderCount: Int
}
