//
//  BillDetailViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 17/06/24.
//

import UIKit

class BillDetailViewController: UIViewController {
    private let bill: Bill
    
    init(bill: Bill) {
        self.bill = bill
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        title = "Bill Detail"
    }
}
