//
//  Bill.swift
//  Dine
//
//  Created by doss-zstch1212 on 30/01/24.
//

import Foundation
import SQLite3
enum PaymentStatus: String {
    case paid = "Paid"
    case unpaid = "Unpaid"
}

class Bill {
    private var _billId: UUID
    private var amount: Double
    var date: Date
    private var tip: Double
    private var tax: Double
    private var orderId: UUID
    var isPaid: Bool
    
    var billId: UUID {
        return _billId
    }
    
    var getOrderId: UUID {
        orderId
    }
    
    var csvString: String {
        "\(_billId),\(amount),\(date),\(tip),\(tax),\(isPaid)"
    }
    
    var paymentStatus: PaymentStatus {
        isPaid ? PaymentStatus.paid : PaymentStatus.unpaid
    }
    
    var getTotalAmount: Double {
        amount + tip + tax
    }
    
    var getTip: Double {
        tip
    }
    
    var getTax: Double {
        tax
    }
    
    var getOrder: Order? {
        guard let orderService = try? OrderServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase()) else { return nil }
        guard let results = try? orderService.fetch() else { return nil }
        guard let index = results.firstIndex(where: { $0.orderIdValue == orderId }) else { return nil }
        return results[index]
    }
    
    init(_billId: UUID, amount: Double, date: Date, tip: Double, tax: Double, orderId: UUID,isPaid: Bool) {
        self._billId = _billId
        self.amount = amount
        self.date = date
        self.tip = tip
        self.tax = tax
        self.orderId = orderId
        self.isPaid = isPaid
    }
    
    convenience init(amount: Double, tip: Double, tax: Double, orderId: UUID, isPaid: Bool) {
        self.init(_billId: UUID(), amount: amount, date: Date(), tip: tip, tax: tax, orderId: orderId, isPaid: isPaid)
    }
    
    convenience init(amount: Double, tax: Double, orderId: UUID, isPaid: Bool) {
        self.init(amount: amount, tip: 0.0, tax: tax, orderId: orderId, isPaid: isPaid)
    }
    
    func displayBill() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        let paidStatus = isPaid ? "Paid" : "Unpaid"
        
        let billDetails = """
        Bill ID: \(_billId)
        Amount: \(amount)
        Date: \(formatter.string(from: date))
        Tip: \(tip)
        Tax: \(tax.rounded(.up))
        Status: \(paidStatus)
        """
        
        return billDetails
    }
}

extension Bill {
    var getOrderedItems: [MenuItem]? {
        do {
            let orderService = try OrderServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let order = try orderService.fetch(orderId)
            guard let order else {
                fatalError("Failed to fetch order!")
            }
            return order.menuItems
        } catch {
            fatalError("Failed to fetch order: \(error)")
        }
    }
}

extension Bill: Parsable {}

extension Bill: SQLTable {
    static var tableName: String {
        DatabaseTables.billTable.rawValue
    }
    
    static var createStatement: String {
        """
        CREATE TABLE \(DatabaseTables.billTable.rawValue) (
            BillID VARCHAR(32) PRIMARY KEY,
            Amount REAL NOT NULL,
            BillDate TEXT NOT NULL,
            Tip REAL,
            Tax REAL NOT NULL,
            OrderID VARCHAR(32),
            IsBillPaid TEXT NOT NULL
        );
        """
    }
}

extension Bill: SQLUpdatable {
    var createUpdateStatement: String {
        """
        UPDATE \(DatabaseTables.billTable.rawValue)
        SET Amount = \(amount),
            Tip = \(tip),
            Tax = \(tax),
            OrderID = '\(orderId)',
            IsBillPaid = '\(isPaid)'
        WHERE BillID = '\(billId)';
        """
    }
}

extension Bill: SQLInsertable {
    var createInsertStatement: String {
        """
        INSERT INTO \(DatabaseTables.billTable.rawValue) (BillID, Amount, BillDate, Tip, Tax, OrderID, IsBillPaid)
        VALUES ('\(billId.uuidString)', \(amount), '\(date)', \(tip), \(tax), '\(orderId)', '\(isPaid)');
        """
    }
}

extension Bill: DatabaseParsable {
    static func parseRow(statement: OpaquePointer?) throws -> Bill? {
        guard let statement = statement else { return nil }
        guard let billIdCString = sqlite3_column_text(statement, 0),
              let dateCString = sqlite3_column_text(statement, 2),
              let orderIdCString = sqlite3_column_text(statement, 5),
              let isPaidCString = sqlite3_column_text(statement, 6) else {
            throw DatabaseError.missingRequiredValue
        }
        
        let amount = sqlite3_column_double(statement, 1)
        let tip = sqlite3_column_double(statement, 3)
        let tax = sqlite3_column_double(statement, 4)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        guard let billId = UUID(uuidString: String(cString: billIdCString)),
              let date = dateFormatter.date(from: String(cString: dateCString)),
              let orderId = UUID(uuidString: String(cString: orderIdCString)),
              let isPaid = Bool(String(cString: isPaidCString)) else {
            throw DatabaseError.conversionFailed
        }
        
        let bill = Bill(_billId: billId, amount: amount, date: date, tip: tip, tax: tax, orderId: orderId, isPaid: isPaid)
        return bill
    }
}

extension Bill: SQLQueriable {
    static var createQueryStatement: String {
        "SELECT * FROM \(DatabaseTables.billTable.rawValue);"
    }
}

extension Bill: SQLDeletable {
    var createDeleteStatement: String {
        "DELETE FROM \(DatabaseTables.billTable.rawValue) WHERE BillID = '\(billId)';"
    }
}
