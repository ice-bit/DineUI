//
//  MetricRecord.swift
//  Dine
//
//  Created by doss-zstch1212 on 26/06/24.
//

import Foundation

struct MetricRecord {
    private var orders: [Order] {
        getOrders() ?? []
    }
    
    private var bills: [Bill] {
        getBills() ?? []
    }
    
    // Populate neccesary data
    private func getOrders() -> [Order]? {
        do {
            let orderService = try OrderServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let result = try orderService.fetch()
            return result
        } catch {
            fatalError("Failed to fetch orders = \(error)")
        }
    }
    
    private func getBills() -> [Bill]? {
        do {
            let billService = try BillServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let result = try billService.fetch()
            return result
        } catch {
            fatalError("Failed to fetch orders = \(error)")
        }
    }
    
    func orderRecieved(for date: Date) -> [Order] {
        orders.filter { $0.getDate == date }
    }
    
    // MARK: - Generate metric data
    
    /// Calculates the total sales for a given date.
    /// - Parameter date: The date for which to calculate total sales.
    /// - Returns: The total sales amount as a Double.
    func totalSales(for date: Date) -> Double {
        // let filteredBills = bills.filter { $0.date == date }
        // return filteredBills.reduce(0) { $0 + $1.getTotalAmount }
        bills.reduce(0) { $0 + $1.getTotalAmount }
    }
    
    /// Calculates the number of orders for a given date.
    /// - Parameter date: The date for which to calculate the number of orders.
    /// - Returns: The number of orders as an Int.
    func numberOfOrder(for date: Date) -> Int {
        // orders.filter { $0.getDate == date }.count
        orders.count
    }
    
    /// Calculates the average order value for a given date.
    /// - Parameter date: The date for which to calculate the average order value.
    /// - Returns: The average order value as a Double, or 0 if there are no orders for the date.
    func averageOrderValue(for date: Date) -> Double {
        guard numberOfOrder(for: date) > 0 else { return 0 }
        return totalSales(for: date) / Double(numberOfOrder(for: date))
    }
    
    /// Determines the peak hours for a given date.
    /// - Parameter date: The date for which to determine the peak hours.
    /// - Returns: A dictionary where the keys are the hours (0-23) and the values are the counts of orders received in each hour.
    func peakHours(for date: Date) -> [Int: Int] {
        var hoursCount = [Int: Int]()
        // let filteredOrders = orderRecieved(for: date)
        for order in orders {
            let hour = Calendar.current.component(.hour, from: order.getDate)
            hoursCount[hour, default: 0] += 1
        }
        return hoursCount
    }
    
    /// Determines the most popular menu item based on the number of times it appears in orders.
    /// - Returns: The most popular MenuItem, or nil if there are no items.
    func popularItem() -> MenuItem? {
        var totalMenuItems = [MenuItem]()
        var counts: [MenuItem: Int] = [:]
        // Populate `totalMenuItems` for all the items associated with orders
        for order in orders {
            for item in order.menuItems {
                totalMenuItems.append(item)
            }
        }
        
        // Count occurrences of each MenuItem
        for item in totalMenuItems {
            counts[item, default: 0] += 1
        }
        
        // Find the MenuItem with the highest count
        if let (mostRepeatedItem, _) = counts.max(by: { $0.value < $1.value }) {
            return mostRepeatedItem
        } else {
            return nil
        }
    }
    
    func ordersInLast7Days() -> [Order] {
        let calendar = Calendar.current
        let now = Date()
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return [] }
        
        return orders.filter { $0.getDate >= sevenDaysAgo && $0.getDate <= now }
    }
    
    func billsInLast7Days() -> [Bill] {
        let calendar = Calendar.current
        let now = Date()
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return [] }
        
        return bills.filter { $0.date >= sevenDaysAgo && $0.date <= now }
    }
    
    func salesReportLast7Days() -> [SalesReport] {
        let calendar = Calendar.current
        let now = Date()
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return [] }
        
        let billsLast7Days = bills.filter { $0.date >= sevenDaysAgo && $0.date <= now }
        
        var report: [SalesReport] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let dailyBills = billsLast7Days.filter { $0.date >= startOfDay && $0.date < endOfDay }
            let totalSales = dailyBills.reduce(0) { $0 + $1.getTotalAmount }
            let dailyReport = SalesReport(date: startOfDay, report: totalSales)
            report.append(dailyReport)
        }
        
        return report
    }
}
