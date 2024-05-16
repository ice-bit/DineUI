//
//  TableCollectionViewCell.swift
//  Dine
//
//  Created by doss-zstch1212 on 15/05/24.
//

import UIKit

class TableCollectionViewCell: UICollectionViewCell {
    private lazy var wrapperHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 12
        stackView.layer.borderColor = CGColor(red: 0.47, green: 0.42, blue: 0.36, alpha: 1) /// R 0.47 G 0.42 B 0.36 A 1.00
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    private lazy var leftVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = UIColor(named: "secondaryBgColor")
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    private lazy var rightVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = UIColor(named: "teritiaryBgColor")
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = " Status"
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = " Location ID"
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var capacityLabel: UILabel = {
        let label = UILabel()
        label.text = " Capacity"
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statusValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var locationValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var capacityValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // initialization code
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        setupStackView()
    }
    
    private func setupStackView() {
        contentView.addSubview(wrapperHStackView)
        wrapperHStackView.addArrangedSubview(leftVStackView)
        wrapperHStackView.addArrangedSubview(rightVStackView)
        
        leftVStackView.addArrangedSubview(statusLabel)
        leftVStackView.addArrangedSubview(locationLabel)
        leftVStackView.addArrangedSubview(capacityLabel)
        
        rightVStackView.addArrangedSubview(statusValueLabel)
        rightVStackView.addArrangedSubview(locationValueLabel)
        rightVStackView.addArrangedSubview(capacityValueLabel)
        
        NSLayoutConstraint.activate([
            wrapperHStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wrapperHStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            wrapperHStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            wrapperHStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            
        ])
    }
    
    func configureCell(table: RestaurantTable) {
        statusValueLabel.text = table.tableStatus.rawValue
        locationValueLabel.text = String(table.locationId)
        capacityValueLabel.text = String(table.capacity)
    }
}
