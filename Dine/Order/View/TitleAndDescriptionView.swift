//
//  TitleAndDescriptionView.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/06/24.
//

import UIKit

class TitleAndDescriptionView: UIView {
    
    private lazy var contentWrapperStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Mostly representing UUID
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Initialization code...
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.addSubview(contentWrapperStackView)
        contentWrapperStackView.addArrangedSubview(titleLabel)
        contentWrapperStackView.addArrangedSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            contentWrapperStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            contentWrapperStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            contentWrapperStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            contentWrapperStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
        ])
    }
    
    func configureView(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
    
}


