//
//  ViewCartOverlayView.swift
//  Dine
//
//  Created by doss-zstch1212 on 28/08/24.
//

import UIKit

class ViewCartOverlayView: UIView {
    
    var onTap: (() -> Void)?

    private let itemsCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "0 items added"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    private let viewCartLabel: UILabel = {
        let label = UILabel()
        label.text = "View Cart"
        label.textColor = .systemBackground
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let accessoryImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()  // Only call it here
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        onTap?()
    }

    private func setupSubviews() {
        self.backgroundColor = .app
        
        // Create the stack view
        let accessoryStackView = UIStackView(arrangedSubviews: [viewCartLabel, accessoryImageView])
        accessoryStackView.axis = .horizontal
        accessoryStackView.translatesAutoresizingMaskIntoConstraints = false
        accessoryStackView.distribution = .equalSpacing
        accessoryStackView.spacing = 4
        
        let textHorizontalStackView = UIStackView(arrangedSubviews: [itemsCountLabel, accessoryStackView])
        textHorizontalStackView.axis = .horizontal
        textHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        textHorizontalStackView.distribution = .equalSpacing // Adjust this based on your needs
        
        
        // Add the stack view to the view hierarchy
        addSubview(textHorizontalStackView)
        
        // Set up the constraints for the stack view
        NSLayoutConstraint.activate([
            textHorizontalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            textHorizontalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            textHorizontalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            textHorizontalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }

    func configure(itemsCount: Int) {
        itemsCountLabel.text = "\(itemsCount) items added"
    }
}
