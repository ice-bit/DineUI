//
//  MenuCartView.swift
//  Dine
//
//  Created by doss-zstch1212 on 31/05/24.
//

import UIKit

class MenuCartView: UIView {

    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code...
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        // Disclosure System Image
        let disclosureImageView = UIImageView()
        disclosureImageView.tintColor = .label
        disclosureImageView.image = UIImage(systemName: "chevron.right")
        // Add subviews
        self.addSubview(hStackView)
        hStackView.addArrangedSubview(itemCountLabel)
        hStackView.addArrangedSubview(disclosureImageView)
        
        NSLayoutConstraint.activate([
            hStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14),
            hStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14),
            hStackView.topAnchor.constraint(equalTo: self.topAnchor),
            hStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    func setItemCount(_ count: Int) {
        let itemCountString = "\(count) Items added"
        itemCountLabel.text = itemCountString
    }
    
}

#Preview {
    let view = MenuCartView()
    view.setItemCount(20)
    return view
}
