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
    static let didAddMenuItemNotification = Notification.Name("com.euphoria.Dine.didAddMenuItemNotification")
    static let billDidAddNotification = Notification.Name("com.euphoria.Dine.billDidAddNotification")
}
