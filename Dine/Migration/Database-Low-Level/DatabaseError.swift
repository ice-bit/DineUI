//
//  DatabaseError.swift
//  Dine
//
//  Created by doss-zstch1212 on 13/03/24.
//

import Foundation

enum DatabaseError: Error {
    case couldNotOpenDatabase(reason: String)
    case tableCreationFailed(reason: String)
    case dataInsertionFailed(reason: String)
    case missingRequiredValue
    case conversionFailed
    case fetchFailed
    case imageConversionFailed

    var localizedDescription: String {
        switch self {
        case .couldNotOpenDatabase(let reason):
            return "Error opening database: \(reason)"
        case .tableCreationFailed(let reason):
            return "Failed to create table: \(reason)"
        case .dataInsertionFailed(let reason):
            return "Error inserting data: \(reason)"
        case .missingRequiredValue:
            return "Required value missing"
        case .conversionFailed:
            return "Conversion from cString failed"
        case .fetchFailed:
            return "Failed to fetch table"
        case .imageConversionFailed:
            return "Failed to convert into image (UIImage)"
        }
    }
}
