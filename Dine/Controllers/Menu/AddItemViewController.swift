//
//  AddItemViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/05/24.
//

import UIKit

protocol MenuItemDelegate: AnyObject {
    func menuItemDidAdd(_ item: MenuItem)
}

class AddItemViewController: UIViewController {
    
    private let menuService: MenuService
    
    weak var menuItemDelegate: MenuItemDelegate?
    
    init(menuService: MenuService) {
        self.menuService = menuService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private var stackView: UIStackView!
    private var itemImageView: UIImageView!
    private var nameTextField: UITextField!
    private var priceTextField: UITextField!
    private var descTextField: UITextField!
    private var addButton: UIButton!
    private var addImageButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupSubviews()
    }
    
    // MARK: - View Setup
    
    private func configureView() {
        view.backgroundColor = UIColor(named: "primaryBgColor")
    }
    
    private func setupSubviews() {
        setupStackView()
//        setupItemImageView()
        setupAddImageButton()
        setupNameTextField()
        setupPriceTextField()
        setupAddButton()
        addSubviews()
        setupConstraints()
    }
    
    private func setupStackView() {
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
    }
    
    private func setupItemImageView() {
        itemImageView = UIImageView()
        itemImageView.backgroundColor = .systemBlue
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.layer.cornerRadius = 10
    }
    
    private func setupAddImageButton() {
        addImageButton = UIButton()
        let symbolConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 40, weight: .medium))
        addImageButton.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig), for: .normal)
        addImageButton.backgroundColor = UIColor(named: "secondaryBgColor")
        addImageButton.tintColor = .label
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        addImageButton.layer.borderWidth = 1
        addImageButton.layer.borderColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        addImageButton.layer.cornerRadius = 12
    }
    
    private func setupNameTextField() {
        nameTextField = DTextField()
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.placeholder = "Name"
        nameTextField.backgroundColor = UIColor(named: "secondaryBgColor")
        nameTextField.layer.cornerRadius = 12
    }
    
    private func setupPriceTextField() {
        priceTextField = DTextField()
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        priceTextField.placeholder = "Price Tag"
        priceTextField.backgroundColor = UIColor(named: "secondaryBgColor")
        priceTextField.layer.cornerRadius = 12
    }
    
    private func setupAddButton() {
        addButton = UIButton()
        addButton.setTitle("Add Item", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.backgroundColor = UIColor(named: "secondaryBgColor")
        addButton.layer.cornerRadius = 10
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.setTitleColor(.label, for: .normal)
    }
    
    private func addSubviews() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(addImageButton)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(priceTextField)
        stackView.addArrangedSubview(addButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            addButton.heightAnchor.constraint(equalToConstant: 55),
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            priceTextField.heightAnchor.constraint(equalToConstant: 44),
            priceTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            addImageButton.heightAnchor.constraint(equalToConstant: 150),
            addImageButton.widthAnchor.constraint(equalToConstant: 150),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        guard let priceString = priceTextField.text,
              let price = Double(priceString) else {
            self.present(UIAlertController().defaultStyle(title: "Failed to Add Item", message: "Provide valid price!"), animated: true)
            return
        }
        
        if let name = nameTextField.text {
            let menuItem = MenuItem(name: name, price: price)
            try? menuService.add(menuItem)
            menuItemDelegate?.menuItemDidAdd(menuItem)
            self.dismiss(animated: true)
        }
        
    }
}

