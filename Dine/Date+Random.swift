//
//  Date+Random.swift
//  Dine
//
//  Created by doss-zstch1212 on 28/06/24.
//

import Foundation

extension Date {
    static func random(in range: Range<Date>) -> Date {
        let interval = range.upperBound.timeIntervalSince(range.lowerBound)
        let randomInterval = TimeInterval(arc4random_uniform(UInt32(interval)))
        return range.lowerBound.addingTimeInterval(randomInterval)
    }
}
