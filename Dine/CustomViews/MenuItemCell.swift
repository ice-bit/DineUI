//
//  MenuItemCell.swift
//  DineUIComponents
//
//  Created by doss-zstch1212 on 02/05/24.
//

import UIKit

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
    // Hide the stepper when the cell is called for just displaying
    private var stepper: UIStepper!

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
        containerView.addSubview(foodIndicator)
        containerView.addSubview(title)
        containerView.addSubview(priceTag)
        containerView.addSubview(secondaryTitle)
        containerView.addSubview(stepper)
        containerView.addSubview(countTag)
        
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        foodIndicator.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        priceTag.translatesAutoresizingMaskIntoConstraints = false
        secondaryTitle.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stepper.translatesAutoresizingMaskIntoConstraints = false
        countTag.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.backgroundColor = UIColor(named: "primaryBgColor")
        
        containerView.backgroundColor = UIColor(named: "secondaryBgColor")
        containerView.layer.cornerRadius = 12
        
        countTag.font = .systemFont(ofSize: 14)
        
        itemImageView.layer.cornerRadius = 8 // Adjust the value as needed
        itemImageView.layer.masksToBounds = true
        itemImageView.contentMode = .scaleToFill
        foodIndicator.image = UIImage(systemName: "square.dashed")
        title.font = .systemFont(ofSize: 17, weight: .regular)
        priceTag.font = .systemFont(ofSize: 14, weight: .regular)
        secondaryTitle.font = .systemFont(ofSize: 12, weight: .light)
        
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .touchUpInside)
        
        countTag.text = String(count)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            containerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.92),
            
            itemImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.8),
            itemImageView.widthAnchor.constraint(equalTo: itemImageView.heightAnchor),
            itemImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            itemImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            
            foodIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            foodIndicator.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 14),
            foodIndicator.heightAnchor.constraint(equalToConstant: 14),
            foodIndicator.widthAnchor.constraint(equalToConstant: 14),
            
            title.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 14),
            title.topAnchor.constraint(equalTo: foodIndicator.bottomAnchor, constant: 0),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            title.heightAnchor.constraint(equalToConstant: 24),
            
            priceTag.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 0),
            priceTag.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 14),
            priceTag.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            priceTag.heightAnchor.constraint(equalToConstant: 20),
            
            secondaryTitle.heightAnchor.constraint(equalToConstant: 20),
            secondaryTitle.topAnchor.constraint(equalTo: priceTag.bottomAnchor, constant: 0),
            secondaryTitle.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 14),
            secondaryTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            stepper.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stepper.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            countTag.centerXAnchor.constraint(equalTo: stepper.centerXAnchor),
            countTag.centerYAnchor.constraint(equalTo: stepper.centerYAnchor)
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
        let priceString = String(menuItem.price)
        priceTag.text = "$ \(priceString)"
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

