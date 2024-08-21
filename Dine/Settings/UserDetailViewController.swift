//
//  UserDetailViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/08/24.
//

import UIKit

class UserDetailViewController: UIViewController {
    private let account: Account
    
    init(account: Account) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}


