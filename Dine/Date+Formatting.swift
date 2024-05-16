//
//  Date+Formatting.swift
//  Dine
//
//  Created by doss-zstch1212 on 13/05/24.
//

import Foundation

extension Date {
    func formattedDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: self)
    }
}
