//
//  AddItemViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/05/24.
//

import UIKit
import Toast
import PhotosUI

protocol MenuItemDelegate: AnyObject {
    func menuItemDidAdd(_ item: MenuItem)
}

class AddItemViewController: UIViewController {
    weak var menuItemDelegate: MenuItemDelegate?
    
    // MARK: - Properties
    private let category: MenuCategory
    
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var toast: Toast!
    
    private var stackView: UIStackView!
    private var nameTextField: UITextField!
    private var priceTextField: UITextField!
    private var descTextField: UITextField!
    private var addButton: UIButton!
    
    private var pickerView: UIPickerView!
    
    lazy private var imagePickerButton: UIButton = {
        let button = UIButton()
        button.setTitle("add photo", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 75
        button.layer.masksToBounds = true
        button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        button.layer.borderWidth = 1
        button.layer.borderColor = .init(gray: 1, alpha: 1)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.addTarget(self, action: #selector(imagePickerButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    /*private lazy var titleLabel: UILabel = {
     let label = UILabel()
     label.text = "Add Menu Item"
     label.font = .preferredFont(forTextStyle: .largeTitle)
     label.translatesAutoresizingMaskIntoConstraints = false
     return label
     }()*/
    
    // MARK: - Initializer
    init(category: MenuCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Item"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        configureView()
        setupSubviews()
    }
    
    @objc private func imagePickerButtonAction(_ sender: UIButton) {
        configureAndPresentPicker()
    }
    
    func configureAndPresentPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - @OBJC Methods
    
    // MARK: - View Setup
    private func configureView() {
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollContentView = UIView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            scrollContentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
    
    private func setupSubviews() {
        setupScrollView()
        setupStackView()
        setupNameTextField()
        setupPriceTextField()
        setupDescTextField()
        setupAddButton()
        addSubviews()
        setupConstraints()
        setupPickerView()
    }
    
    private func setupPickerView() {
        pickerView = UIPickerView()
        // pickerView.delegate = self
        // pickerView.dataSource = self
    }
    
    /*private func setupSectionSelectionButton() {
     sectionSelectionButton = UIButton()
     sectionSelectionButton.setTitle("Select Section", for: .normal)
     sectionSelectionButton.translatesAutoresizingMaskIntoConstraints = false
     sectionSelectionButton.setTitleColor(.label, for: .normal)
     sectionSelectionButton.backgroundColor = .systemGray5
     sectionSelectionButton.layer.cornerRadius = 10
     sectionSelectionButton.addTarget(self, action: #selector(selectMenuSectionButtonTapped(_:)), for: .touchUpInside)
     }*/
    
    private func setupStackView() {
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
    }
    
    private func setupNameTextField() {
        nameTextField = DTextField()
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.placeholder = "Name"
        nameTextField.backgroundColor = .secondarySystemGroupedBackground
        nameTextField.layer.cornerRadius = 12
    }
    
    private func setupPriceTextField() {
        priceTextField = DTextField()
        priceTextField.keyboardType = .decimalPad
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        priceTextField.placeholder = "Price Tag"
        priceTextField.backgroundColor = .secondarySystemGroupedBackground
        priceTextField.layer.cornerRadius = 12
    }
    
    private func setupDescTextField() {
        descTextField = DTextField()
        descTextField.translatesAutoresizingMaskIntoConstraints = false
        descTextField.placeholder = "Description"
        descTextField.backgroundColor = .secondarySystemGroupedBackground
        descTextField.layer.cornerRadius = 12
    }
    
    private func setupAddButton() {
        addButton = UIButton()
        addButton.setTitle("Add Item", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.backgroundColor = .app
        addButton.layer.cornerRadius = 10
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func addSubviews() {
        scrollContentView.addSubview(stackView)
        //stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imagePickerButton)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(priceTextField)
        stackView.addArrangedSubview(descTextField)
        stackView.addArrangedSubview(addButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            stackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            
            addButton.heightAnchor.constraint(equalToConstant: 55),
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            
            nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            priceTextField.heightAnchor.constraint(equalToConstant: 44),
            priceTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            
            descTextField.heightAnchor.constraint(equalToConstant: 44),
            descTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            
            imagePickerButton.heightAnchor.constraint(equalToConstant: 150),
            imagePickerButton.widthAnchor.constraint(equalToConstant: 150),
            
            /*sectionSelectionButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
             sectionSelectionButton.heightAnchor.constraint(equalToConstant: 44),*/
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        guard let priceString = priceTextField.text,
              let price = Double(priceString) else {
            self.present(UIAlertController().defaultStyle(title: "Failed to Add Item", message: "Provide valid price!"), animated: true)
            return
        }
        
        guard let description = descTextField.text,
              !description.isEmpty else {
            let toast = Toast.text("Invalid Description!")
            toast.show(haptic: .error)
            return
        }
        
        guard let image = imagePickerButton.backgroundImage(for: .normal) else {
            if let toast {
                toast.close(animated: false)
            }
            toast = Toast.text("No Image Selected")
            toast.show(haptic: .warning)
            return
        }
        guard let name = nameTextField.text else { return }
        let menuItem = MenuItem(
            name: name,
            price: price,
            category: category,
            description: description
        )
        menuItem.image = image
        // Perform database operations asynchronously
        DispatchQueue.global(qos: .background).async {
            do {
                let databaseAccess = try SQLiteDataAccess.openDatabase()
                let menuService = MenuServiceImpl(databaseAccess: databaseAccess)
                try menuService.add(menuItem)
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                DispatchQueue.main.async {
                    impactFeedback.prepare()
                    impactFeedback.impactOccurred()
                    
                    NotificationCenter.default.post(name: .menuItemDidChangeNotification, object: nil)
                    self.menuItemDelegate?.menuItemDidAdd(menuItem)
                    self.dismiss(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Unable to add MenuItem - \(error)")
                    let toast = Toast.text("Failed to add menu item!")
                    toast.show(haptic: .error)
                }
            }
        }
        
        // Dismiss the loading indicator
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.dismiss(animated: true)
            }
        }
    }
}

extension AddItemViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider else { return }
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { image, error in
                if let selectedImage = image as? UIImage {
                    DispatchQueue.main.async {
                        // Update UI
                        self.imagePickerButton.setBackgroundImage(selectedImage, for: .normal)
                        self.imagePickerButton.setTitle("", for: .normal)
                        self.view.layoutIfNeeded()
                    }
                }
            })
        }
    }
}

#Preview {
    AddItemViewController(category: MenuCategory(id: UUID(), categoryName: "Starter"))
}

