//
//  BillViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit

class BillViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
    }
    

    private func setupAppearance() {
        self.title = "Bills"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
