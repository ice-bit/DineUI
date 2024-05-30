//
//  MenuItemCell.swift
//  DineUIComponents
//
//  Created by doss-zstch1212 on 02/05/24.
//

import UIKit
import SwiftUI

protocol CustomStepperDelegate: AnyObject {
    func stepperValueChanged(value: Double)
}

class MenuItemCell: UITableViewCell {
    static let reuseIdentifier = "MenuItemCell"
    
    private var count: Int = 0 {
        willSet {
            countTag.text = String(newValue)
        }
    }
    
    var itemCount: Int {
        count
    }
    private var menuItem: MenuItem?
    
    weak var stepperDelegate: CustomStepperDelegate?
    
    private var itemImageView: UIImageView!
    private var foodIndicator: UIImageView!
    private var title: UILabel!
    private var priceTag: UILabel!
    private var secondaryTitle: UILabel!
    private var containerView: UIView!
    private var countTag: UILabel!
    private var stepper: UIStepper!
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func stepperValueChanged(sender: UIStepper) {
        print("Stepper value: \(stepper.value)")
        count = Int(stepper.value)
        
        stepperDelegate?.stepperValueChanged(value: stepper.value)
    }
    
    private func setupSubViews() {
        containerView = UIView()
        itemImageView = UIImageView()
        foodIndicator = UIImageView()
        title = UILabel()
        priceTag = UILabel()
        secondaryTitle = UILabel()
        countTag = UILabel()
        stepper = UIStepper()
        
        contentView.addSubview(containerView)
        containerView.addSubview(itemImageView)
//        containerView.addSubview(stepper)
//        containerView.addSubview(countTag)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(foodIndicator)
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(priceTag)
        stackView.addArrangedSubview(secondaryTitle)
        
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        foodIndicator.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        priceTag.translatesAutoresizingMaskIntoConstraints = false
        secondaryTitle.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stepper.translatesAutoresizingMaskIntoConstraints = false
        countTag.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.backgroundColor = .systemBackground
        
        containerView.backgroundColor = .app
        containerView.layer.cornerRadius = 12
        
        countTag.font = .systemFont(ofSize: 14)
        
        itemImageView.layer.cornerRadius = 8 // Adjust the value as needed
        itemImageView.layer.masksToBounds = true
        itemImageView.contentMode = .scaleToFill
        foodIndicator.image = UIImage(systemName: "square.dashed")
        title.font = .systemFont(ofSize: 17, weight: .medium)
        priceTag.font = .systemFont(ofSize: 14, weight: .regular)
        secondaryTitle.font = .systemFont(ofSize: 12, weight: .regular)
        
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .touchUpInside)
        
        countTag.text = String(count)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            itemImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            itemImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            itemImageView.heightAnchor.constraint(equalToConstant: 100),
            itemImageView.widthAnchor.constraint(equalToConstant: 100),
            
            stackView.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 12),
            stackView.centerYAnchor.constraint(equalTo: itemImageView.centerYAnchor),
            
            /*stepper.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stepper.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            countTag.centerXAnchor.constraint(equalTo: stepper.centerXAnchor),
            countTag.centerYAnchor.constraint(equalTo: stepper.centerYAnchor)*/
        ])
        
    }
    
    func configure(itemImage: UIImage, isFoodVeg: Bool, title: String, price: Double, secondaryTitle: String) {
        itemImageView.image = itemImage
        self.title.text = title
        let priceString = String(price)
        self.priceTag.text = "$ \(priceString)"
        self.secondaryTitle.text = secondaryTitle
    }
    
    func configure(menuItem: MenuItem) {
        itemImageView.image = UIImage(named: "burger")!
        title.text = menuItem.name
        let priceString = String(format: "%.2f", menuItem.price)
        self.priceTag.text = "$ \(priceString)"
        secondaryTitle.text = "Lorem ipsum is not fair."
        self.menuItem = menuItem
    }
    
}

struct MenuCell {
    let image: UIImage
    let indicator: UIImage?
    let title: String
    let price: Double
    let secTitle: String
}

#Preview {
    let menuItemCell = MenuItemCell()
    menuItemCell.configure(itemImage: .burger, isFoodVeg: false, title: "Burger", price: 8.98, secondaryTitle: "Lorem ipsumfew")
    return menuItemCell
}
