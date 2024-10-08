//
//  MenuItemCell.swift
//  Dine
//
//  Created by doss-zstch1212 on 29/05/24.
//

import UIKit

protocol MenuItemTableViewCellDelegate: AnyObject {
    func menuTableViewCell(_ cell: MenuItemCell, didChangeItemCount count: Int, for menuItem: MenuItem)
}

class MenuItemCell: UITableViewCell {
    
    static let reuseIdentifier = "MenuItemTableViewCell"
    weak var delegate: MenuItemTableViewCellDelegate?
    var menuItem: MenuItem?
    
    private var itemCount: Int = 0 {
        didSet {
            itemCountLabel.text = String(itemCount)
            itemCountLabel.isHidden = itemCount == 0
            stepper.value = Double(itemCount)
        }
    }
    
    private lazy var itemImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var vegNonVegSymbol: UIImageView = {
        let symbol = UIImageView()
        symbol.contentMode = .scaleToFill
        symbol.translatesAutoresizingMaskIntoConstraints = false
        return symbol
    }()
    
    private lazy var itemNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 15)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private lazy var secTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.addTarget(self, action: #selector(stepperAction(_:)), for: .touchUpInside)
        stepper.setBackgroundImage(UIImage(color: UIColor.clear), for: .normal)
        stepper.setDividerImage(UIImage(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    private lazy var itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.isHidden = true // Initially is it hidden
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code...
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func stepperAction(_ sender: UIStepper) {
        // Haptic feedback
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.prepare()
        selectionFeedback.selectionChanged()
        
        itemCount = Int(stepper.value)
        menuItem?.count = itemCount
        if let menuItem {
            delegate?.menuTableViewCell(self, didChangeItemCount: itemCount, for: menuItem)
        }
    }
    
    // MARK: - View Setup
    private func setupSubviews() {
        contentView.addSubview(wrapperView)
        stepper.addSubview(itemCountLabel)
        
        /*wrapperView.backgroundColor = .red*/
        //hStackView.backgroundColor = .blue
        
        wrapperView.addSubview(hStackView)
        hStackView.addArrangedSubview(itemImage)
        hStackView.addArrangedSubview(labelVStackView)
        hStackView.addArrangedSubview(stepper)
        
        //labelVStackView.addArrangedSubview(vegNonVegSymbol)
        labelVStackView.addArrangedSubview(itemNameLabel)
        labelVStackView.addArrangedSubview(priceLabel)
        // removed this and solved the stepper going out of bounds issue (still didn't figure out how)
        //labelVStackView.addArrangedSubview(secTitleLabel)
        
        NSLayoutConstraint.activate([
            wrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            wrapperView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            wrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            itemImage.heightAnchor.constraint(equalToConstant: 72),
            itemImage.widthAnchor.constraint(equalToConstant: 72),
            
            hStackView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            hStackView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
            hStackView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 16),
            hStackView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -16),


            itemCountLabel.centerXAnchor.constraint(equalTo: stepper.centerXAnchor),
            itemCountLabel.centerYAnchor.constraint(equalTo: stepper.centerYAnchor),
            stepper.centerYAnchor.constraint(equalTo: hStackView.centerYAnchor),
            stepper.trailingAnchor.constraint(equalTo: hStackView.trailingAnchor),
        ])
    }
    
    func configure(menuItem: MenuItem) {
        self.menuItem = menuItem
        itemImage.cacheImage(for: menuItem.itemId)
        
        vegNonVegSymbol.image = UIImage(systemName: "square.dashed.inset.filled")
        itemNameLabel.text = menuItem.name
        let priceString = String(format: "%.2f", menuItem.price)
        priceLabel.text = "$ \(priceString)"
        secTitleLabel.text = menuItem.description
        itemCount = menuItem.count
        stepper.value = Double(menuItem.count)
    }
    
    private func configureMenuItem() {
        guard let menuItem else { return }
        itemCount = menuItem.count
    }

}

#Preview {
    let menuItem: MenuItem = .init(name: "Boom chicka vaaava", price: 0.87, category: MenuCategory(id: UUID(), categoryName: "Main Course"), description: "There are no flying car which fly above tower!")
    let cell = MenuItemCell()
    cell.configure(menuItem: menuItem)
    return cell
}
