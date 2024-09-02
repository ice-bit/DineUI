//
//  BillSummaryViewModal.swift
//  Dine
//
//  Created by doss-zstch1212 on 02/09/24.
//

import Foundation

struct BillItem {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
}

struct BillSection {
    let header: String?
    let items: [BillItem]
}

class BillSummaryViewModel: ObservableObject {
    private let bill: Bill
    @Published var sections: [BillSection] = []
    
    init(bill: Bill) {
        self.bill = bill
        populateSections()
    }
    
    private func populateSections() {
        let locationID = bill.getOrder?.getTable?.locationIdentifier
        let summarySection = BillSection(header: "Summary", items: [
            .init(title: String(bill.getTotalAmount.rounded()), subtitle: "Payable amount", action: nil),
            .init(title: "#\(locationID ?? 0)", subtitle: "Location Identifier", action: nil),
            .init(title: String(bill.getTip.rounded()), subtitle: "Tip", action: nil),
            .init(title: String(bill.getTax.rounded()), subtitle: "Tax", action: nil),
            .init(title: String(bill.date.formattedDateString()), subtitle: "Date", action: nil),
            .init(title: String(bill.paymentStatus.rawValue), subtitle: "Payment status", action: nil)
        ])
        
        let checkoutSection = BillSection(header: nil, items: [
            .init(title: "Checkout", subtitle: nil, action: updatePaymentStatus)
        ])
        
        guard bill.isPaid else {
            sections = [summarySection, checkoutSection]
            return
        }
        
        sections = [summarySection]
    }
    
    func getNumberOfSection() -> Int {
        sections.count
    }
    
    func getNumberOfItems(in section: Int) -> Int {
        sections[section].items.count
    }
    
    private func updatePaymentStatus() {
        do {
            let dbAccessor = try SQLiteDataAccess.openDatabase()
            let billService = BillServiceImpl(databaseAccess: dbAccessor)
            bill.isPaid = true
            try billService.update(bill)
            sections.removeLast()
        } catch {
            fatalError("Failed to update bill: \(error)")
        }
    }
}
