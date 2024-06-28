//
//  Insight.swift
//  Dine
//
//  Created by doss-zstch1212 on 20/06/24.
//

import Foundation

struct Insight {
    private let bills: [Bill] = []
    private var yesterdaysBill: [Bill] {
        filterBills(for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, in: bills)
    }
    
    private var todaysBills: [Bill] {
        filterBills(for: Date(), in: bills)
    }
    
    /// Retrieves the order counts per day for the past 7 days from the current date.
    func getChartData() -> [OrderData] {
        let orders = ModelData().orders
        var orderData = [OrderData]()
        
        // Get the current date and the date 7 days ago
        let now = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        
        // Filter the orders that fall within the last 7 days
        let recentOrders = orders.filter { $0.getDate >= sevenDaysAgo && $0.getDate <= now }
        
        for order in recentOrders {
            orderData.append(.init(date: order.getDate, orderCount: order.menuItems.count))
        }
        
        return orderData
    }
    
    func getAverageOrdersCount() -> Int {
        let orderData = getChartData()
        
        var numberOfOrders = 0
        
        for orderDatum in orderData {
            numberOfOrders += orderDatum.orderCount
        }
        
        guard orderData.count != 0 else { return 0 }
        
        let avg = numberOfOrders / orderData.count
        return avg
    }
    
    func getTodaysReturn() -> Double {
        return calculateTotalAmount(for: todaysBills)
    }
    
    func getYesterdaysReturns() -> Double {
        return calculateTotalAmount(for: yesterdaysBill)
    }
    
    func getPercentageDifference() -> Double {
        calculatePercentageDifference(todayTotal: getYesterdaysReturns(), yesterdayTotal: getTodaysReturn())
    }
    
    // Helper function to filter bills for a specific date
    private func filterBills(for date: Date, in bills: [Bill]) -> [Bill] {
        let calendar = Calendar.current
        return bills.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
    }

    // Helper function to calculate total amount
    private func calculateTotalAmount(for bills: [Bill]) -> Double {
        return bills.reduce(0) { $0 + $1.getTotalAmount }
    }

    // Helper function to calculate percentage difference
    private func calculatePercentageDifference(todayTotal: Double, yesterdayTotal: Double) -> Double {
        guard yesterdayTotal != 0 else { return Double.infinity }
        return ((todayTotal - yesterdayTotal) / yesterdayTotal) * 100
    }
}
