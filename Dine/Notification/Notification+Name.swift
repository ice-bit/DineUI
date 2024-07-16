//
//  Notification+Name.swift
//  Dine
//
//  Created by doss-zstch1212 on 01/06/24.
//

import Foundation

extension Notification.Name {
    static let orderDidChangeNotification = Notification.Name("com.euphoria.Dine.didAddNewOrderNotification")
    static let tableSelectionNotification = Notification.Name("com.euphoria.Dine.tableSelectionNotification")
    static let didAddTable = Notification.Name("com.euphoria.Dine.didAddTable")
    static let menuItemDidChangeNotification = Notification.Name("com.euphoria.Dine.menuItemDidChangeNotification")
    static let billDidChangeNotification = Notification.Name("com.euphoria.Dine.billDidAddNotification")
    static let cartDidChangeNotification = Notification.Name("com.euphoria.Dine.cartDidChangeNotification")
    // Adding order, editing order, billing order
    static let metricDataDidChangeNotification = Notification.Name("com.euphoria.Dine.metricDataDidChangeNotification")
    // `AddCategoryViewController`
    static let categoryDataDidChangeNotification = Notification.Name("com.euphoria.Dine.categoryDataDidChangeNotification")
    /// Broadcaster name for changes in table data.
    static let tablesDidChangeNotification = Notification.Name("com.euphoria.Dine.tablesDidChangeNotification")
    /// Broadcaster name for changes in mock data.
    static let mockDataDidChangeNotification = Notification.Name("com.euphoria.Dine.mockDataDidChangeNotification")
}
