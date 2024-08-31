//
//  TableConfirmationBottomSheetViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 29/08/24.
//

import UIKit

class TableConfirmationBottomSheetViewController: UIViewController {
    
    var onProceedTap: (() -> Void)?
    
    var containerStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tables"
        view.backgroundColor = .systemBackground
        setupSubview()
    }
    
    private func setupSubview() {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Select table"
        configuration.buttonSize = .large
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = .app
        configuration.baseForegroundColor = .white
        
        let proceedAction = UIAction { [weak self] _ in
            self?.onProceedTap?()
        }
        
        let proceedButton = UIButton(configuration: configuration, primaryAction: proceedAction)
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        
        let infoLabel = UILabel()
        infoLabel.text = "Proceed to confirm the order for your table."
        infoLabel.textColor = .label
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = .boldSystemFont(ofSize: 17)

        containerStackView = UIStackView(arrangedSubviews: [infoLabel, proceedButton])
        containerStackView.axis = .vertical
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.spacing = 14
        
        view.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            containerStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            containerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = containerStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
}
