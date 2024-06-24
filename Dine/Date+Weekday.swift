//
//  Date+Weekday.swift
//  Dine
//
//  Created by doss-zstch1212 on 21/06/24.
//

import Foundation

extension Date {
    var weekday: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE" // or "EEEE" for non-abbreviated day
        return dateFormatter.string(from: self)
    }
}

