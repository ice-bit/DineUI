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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var orderIDLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableIDLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var billStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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

        let footerVStackView = UIStackView()
        footerVStackView.backgroundColor = .app
        footerVStackView.axis = .vertical
        footerVStackView.alignment = .center
        footerVStackView.distribution = .fillEqually
        footerVStackView.layer.cornerRadius = 10
        footerVStackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        footerVStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerHStackView = UIStackView()
        headerHStackView.backgroundColor = UIColor(red: 1, green: 0.643, blue: 0.000, alpha: 0.85) // faded yellow
        headerHStackView.axis = .horizontal
        headerHStackView.layer.cornerRadius = 10
        headerHStackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerHStackView.distribution = .fillEqually
        headerHStackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(vStackView)
        vStackView.addArrangedSubview(headerHStackView)
        vStackView.addArrangedSubview(footerVStackView)
        
        let headerLeadingVStackView = UIStackView()
        headerLeadingVStackView.axis = .vertical
        headerLeadingVStackView.distribution = .fillEqually
        headerLeadingVStackView.alignment = .center
        headerLeadingVStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerTrailingVStackView = UIStackView()
        headerTrailingVStackView.axis = .vertical
        headerTrailingVStackView.distribution = .fillEqually
        headerTrailingVStackView.alignment = .center
        headerTrailingVStackView.translatesAutoresizingMaskIntoConstraints = false
        
        headerHStackView.addArrangedSubview(headerLeadingVStackView)
        headerHStackView.addArrangedSubview(headerTrailingVStackView)
        
        headerLeadingVStackView.addArrangedSubview(itemCountLabel)
        headerLeadingVStackView.addArrangedSubview(statusLabel)
        
        headerTrailingVStackView.addArrangedSubview(dateLabel)
        headerTrailingVStackView.addArrangedSubview(billStatusLabel)
        
        footerVStackView.addArrangedSubview(orderIDLabel)
        footerVStackView.addArrangedSubview(tableIDLabel)
        
        
        NSLayoutConstraint.activate([
            
            // New Constraints
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            vStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            vStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            vStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            vStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            footerVStackView.heightAnchor.constraint(equalTo: vStackView.heightAnchor, multiplier: 0.4),
        ])
    }
    
    func configureCell(with order: Order) {
        statusLabel.text = order.orderStatusValue.rawValue
        itemCountLabel.text = "Items: \(String(order.menuItems.count))"
        orderIDLabel.text = /*orderID.uuidString*/order.orderIdValue.uuidString
        tableIDLabel.text = order.tableIDValue.uuidString
        
        dateLabel.text = Date().formattedDateString()
        billStatusLabel.text = "Unbilled"
    }
}

#Preview {
    let cell = OrderCell()
    let order = Order(tableId: UUID(), orderStatus: .completed, menuItems: [])
    cell.configureCell(with: order)
    return cell
}
