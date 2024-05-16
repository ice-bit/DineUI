//
//  QuantityButton.swift
//  Dine
//
//  Created by doss-zstch1212 on 14/05/24.
//

import UIKit

class QuantityButton: UIView {

    private let count: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // init code
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "primaryBgColor")
        return view
    }()
    
    private var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "secondaryBgColor")
        return button
    }()
    
    private var minusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "secondaryBgColor")
        return button
    }()
    
    private lazy var countTag: UILabel = {
        let label = UILabel()
        label.text = String(count)
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupSubviews() {
        self.addSubview(containerView)
        containerView.addSubview(countTag)
        containerView.addSubview(addButton)
        containerView.addSubview(minusButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            addButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            addButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            minusButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            minusButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            minusButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            countTag.topAnchor.constraint(equalTo: containerView.topAnchor),
            countTag.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            

        ])
    }

}
