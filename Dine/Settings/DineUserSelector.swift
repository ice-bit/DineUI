//
//  DineUserSelector.swift
//  Dine
//
//  Created by doss-zstch1212 on 09/08/24.
//

import UIKit

class DineUserSelector: UIView {
    var onDidTapPicker: (() -> Void)?
    var menu: UIMenu? {
        didSet {
            trailingPickerButton.menu = menu
        }
    }
    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var text: String? {
        get {
            contentLabel.text
        }
        set {
            contentLabel.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set up button action
        trailingPickerButton.addTarget(self, action: #selector(trailingPickerButtonDidTap), for: .touchUpInside)
        
        // Create stacks
        let textStack = UIStackView(arrangedSubviews: [contentLabel, trailingPickerButton])
        textStack.axis = .horizontal
        textStack.spacing = 12
        
        let separatorStack = UIStackView(arrangedSubviews: [titleLabel, textStack, separator])
        separatorStack.axis = .vertical
        separatorStack.spacing = 12
        
        // Add the separatorStack to the view
        addSubview(separatorStack)
        
        // Disable autoresizing mask
        separatorStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Apply constraints
        NSLayoutConstraint.activate([
            separatorStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            separatorStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            separatorStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            separatorStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            separator.widthAnchor.constraint(equalTo: separatorStack.widthAnchor),
            trailingPickerButton.widthAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func trailingPickerButtonDidTap() {
        print(#function)
        onDidTapPicker?()
    }
    
    let trailingPickerButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.up.chevron.down")
        let button = UIButton(configuration: config)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "User Role"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .label
        return label
    }()
    
    private let separator: Separator = {
        let separator = Separator()
        return separator
    }()
}
