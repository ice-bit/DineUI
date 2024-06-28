//
//  SalesReport.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/06/24.
//

import Foundation

struct SalesReport: Identifiable {
    let id = UUID()
    let date: Date
    let report: Double
}

extension SalesReport {
    // Function to generate a random SalesReport
    static func randomSalesReport() -> SalesReport {
        let randomDate = Date.random(in: Date().addingTimeInterval(-60*60*24*365)..<Date())
        let randomReport = Double.random(in: 1000.0...10000.0)
        return SalesReport(date: randomDate, report: randomReport)
    }

    // Function to generate a list of random SalesReports
    static func generateRandomSalesReports(count: Int) -> [SalesReport] {
        return (0..<count).map { _ in randomSalesReport() }
    }
}
