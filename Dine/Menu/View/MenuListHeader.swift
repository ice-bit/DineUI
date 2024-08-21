//
//  MenuListHeader.swift
//  Dine
//
//  Created by doss-zstch1212 on 30/07/24.
//

import UIKit

class MenuListHeader: UITableViewHeaderFooterView {
    
    // Define the closure property
    var onHeaderTapped: (() -> Void)?
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureContents() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .secondarySystemGroupedBackground
        backgroundView.layer.cornerRadius = 10
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backgroundView)
        backgroundView.addSubview(title)
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        self.addGestureRecognizer(tapGesture)
        
        // Center the label vertically, and use it to fill the remaining
        // space in the header view.
        NSLayoutConstraint.activate([
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor,
                                           constant: 12),
            title.trailingAnchor.constraint(equalTo:
                                                contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            backgroundView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            title.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 18),
            //title.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
            title.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
        ])
    }
    
    @objc private func headerTapped() {
        onHeaderTapped?()
    }
}
