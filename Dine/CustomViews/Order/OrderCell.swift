//
//  OrderCell.swift
//  Dine
//
//  Created by doss-zstch1212 on 10/05/24.
//

import UIKit

class OrderCell: UITableViewCell {
    
    static let reuseIdentifier = "OrderCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "quaternaryBgColor")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var overlayContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "secondaryBgColor")
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var orderIDLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableIDLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var billStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(overlayContainerView)
        containerView.addSubview(statusLabel)
        containerView.addSubview(itemCountLabel)
        overlayContainerView.addSubview(orderIDLabel)
        overlayContainerView.addSubview(tableIDLabel)
        overlayContainerView.addSubview(dateLabel)
        overlayContainerView.addSubview(billStatusLabel)
        
        NSLayoutConstraint.activate([
            // containerView constraints
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            // overlayContainerView constraints
            overlayContainerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            overlayContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            overlayContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            overlayContainerView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            // statusLabel constraints
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            statusLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant:12),
            statusLabel.trailingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor, constant: -4),
            
            // itemCountLabel constraints
            itemCountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            itemCountLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            itemCountLabel.trailingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor, constant: -4),
            itemCountLabel.heightAnchor.constraint(equalToConstant: 22),
            // orderIDLabel constriants
            orderIDLabel.leadingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor, constant: 8),
            orderIDLabel.topAnchor.constraint(equalTo: overlayContainerView.topAnchor, constant: 12),
//            orderIDLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -4),
            // tableIDLabel Constraints
            tableIDLabel.leadingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor, constant: 8),
            tableIDLabel.bottomAnchor.constraint(equalTo: overlayContainerView.bottomAnchor, constant: -8),
//            tableIDLabel.trailingAnchor.constraint(equalTo: billStatusLabel.leadingAnchor, constant: -4),
            // dateLabel constraints
            dateLabel.topAnchor.constraint(equalTo: overlayContainerView.topAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: overlayContainerView.trailingAnchor, constant: -4),
            // billStatusLabel constraints
            billStatusLabel.bottomAnchor.constraint(equalTo: overlayContainerView.bottomAnchor, constant: -4),
            billStatusLabel.trailingAnchor.constraint(equalTo: overlayContainerView.trailingAnchor, constant: -4),
            billStatusLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    func configureCell(with order: Order) {
        statusLabel.text = order.orderStatusValue.rawValue
        itemCountLabel.text = "Items: \(String(order.menuItems.count))"
        orderIDLabel.text = /*orderID.uuidString*/order.orderIdValue.uuidString
        tableIDLabel.text = order.tableIDValue.uuidString
        
        dateLabel.text = Date().formatted()
        billStatusLabel.text = "Unbilled"
    }
    
    
    
}
