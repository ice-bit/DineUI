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
    
    func salesSummaryForMonth(bills: [Bill]) -> [SalesSummary] {
        var salesPerMonth: [SalesSummary] = []
        let calendar = Calendar.current

        // Group bills by month
        let groupedBills = Dictionary(grouping: bills) { (bill) -> Date in
            let components = calendar.dateComponents([.year, .month], from: bill.date)
            return calendar.date(from: components)!
        }

        for (monthStart, billsInMonth) in groupedBills {
            let totalSales = billsInMonth.reduce(0.0) { $0 + $1.getTotalAmount }
            salesPerMonth.append(SalesSummary(weekday: monthStart, sales: Int(totalSales)))
        }

        return salesPerMonth
    }
    
    
    func salesSummaryForWeek(bills: [Bill]) -> [SalesSummary] {
        var salesPerWeek: [SalesSummary] = []
        let calendar = Calendar.current

        // Group bills by week
        let groupedBills = Dictionary(grouping: bills) { (bill) -> Date in
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: bill.date)
            return calendar.date(from: components)!
        }

        for (weekStart, billsInWeek) in groupedBills {
            let totalSales = billsInWeek.reduce(0.0) { $0 + $1.getTotalAmount }
            salesPerWeek.append(SalesSummary(weekday: weekStart, sales: Int(totalSales)))
        }

        return salesPerWeek
    }
    
    func generateChartData() -> SalesChartViewModal {
        /*let salesPerWeek = salesSummaryForWeek(bills: bills)
        let salesPerMonth = salesSummaryForMonth(bills: bills)*/
        
        let salesData: [TimePeriod: [SalesSummary]] = [.week: salesPerWeek, .month: salesPerMonth]
        let chartViewModalData = SalesChartViewModal(salesByDateInterval: salesData)
        return chartViewModalData
    }
}


// Helper function to create a date from a string
func dateFromString(_ dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.date(from: dateString) ?? Date()
}

let salesPerWeek: [SalesSummary] = [
    SalesSummary(weekday: dateFromString("2024-06-24"), sales: 120),
    SalesSummary(weekday: dateFromString("2024-06-25"), sales: 150),
    SalesSummary(weekday: dateFromString("2024-06-26"), sales: 100),
    SalesSummary(weekday: dateFromString("2024-06-27"), sales: 180),
    SalesSummary(weekday: dateFromString("2024-06-28"), sales: 130),
    SalesSummary(weekday: dateFromString("2024-06-29"), sales: 90),
    SalesSummary(weekday: dateFromString("2024-06-30"), sales: 160)
]

let salesPerMonth: [SalesSummary] = [
    SalesSummary(weekday: dateFromString("2024-06-01"), sales: 1000),
    SalesSummary(weekday: dateFromString("2024-06-02"), sales: 950),
    SalesSummary(weekday: dateFromString("2024-06-03"), sales: 1100),
    SalesSummary(weekday: dateFromString("2024-06-04"), sales: 1050),
    SalesSummary(weekday: dateFromString("2024-06-05"), sales: 1200),
    SalesSummary(weekday: dateFromString("2024-06-06"), sales: 1150),
    SalesSummary(weekday: dateFromString("2024-06-07"), sales: 980),
    SalesSummary(weekday: dateFromString("2024-06-08"), sales: 1250),
    SalesSummary(weekday: dateFromString("2024-06-09"), sales: 1020),
    SalesSummary(weekday: dateFromString("2024-06-10"), sales: 1300),
    SalesSummary(weekday: dateFromString("2024-06-11"), sales: 1280),
    SalesSummary(weekday: dateFromString("2024-06-12"), sales: 1100),
    SalesSummary(weekday: dateFromString("2024-06-13"), sales: 1200),
    SalesSummary(weekday: dateFromString("2024-06-14"), sales: 1400),
    SalesSummary(weekday: dateFromString("2024-06-15"), sales: 1350),
    SalesSummary(weekday: dateFromString("2024-06-16"), sales: 1150),
    SalesSummary(weekday: dateFromString("2024-06-17"), sales: 1230),
    SalesSummary(weekday: dateFromString("2024-06-18"), sales: 1280),
    SalesSummary(weekday: dateFromString("2024-06-19"), sales: 1220),
    SalesSummary(weekday: dateFromString("2024-06-20"), sales: 1300),
    SalesSummary(weekday: dateFromString("2024-06-21"), sales: 1500),
    SalesSummary(weekday: dateFromString("2024-06-22"), sales: 1400),
    SalesSummary(weekday: dateFromString("2024-06-23"), sales: 1350),
    SalesSummary(weekday: dateFromString("2024-06-24"), sales: 1200),
    SalesSummary(weekday: dateFromString("2024-06-25"), sales: 1250),
    SalesSummary(weekday: dateFromString("2024-06-26"), sales: 1000),
    SalesSummary(weekday: dateFromString("2024-06-27"), sales: 1150),
    SalesSummary(weekday: dateFromString("2024-06-28"), sales: 1300),
    SalesSummary(weekday: dateFromString("2024-06-29"), sales: 1400),
    SalesSummary(weekday: dateFromString("2024-06-30"), sales: 1500)
]
