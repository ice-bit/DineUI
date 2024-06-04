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
    weak var menuItemDelegate: MenuItemDelegate?
    
    // MARK: - Properties
    
    private let pickerData: [MenuSection] = [.starter, .mainCourse, .side, .desserts, .beverages]
    private var selectedMenuSection: MenuSection?
    
    private var stackView: UIStackView!
    private var itemImageView: UIImageView!
    private var nameTextField: UITextField!
    private var priceTextField: UITextField!
    private var descTextField: UITextField!
    private var addButton: UIButton!
    private var addImageButton: UIButton!
    private var sectionSelectionButton: UIButton!
    
    private var pickerView: UIPickerView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupSubviews()
    }
    
    // MARK: - @OBJC Methods
    @objc private func selectMenuSectionButtonTapped(_ sender: UIButton) {
        print("menu selection button tapped")
        let alert = UIAlertController(title: "Select Section", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let pickerViewFrame = CGRect(x: 0, y: 50, width: alert.view.bounds.width - 20, height: 200)
        pickerView = UIPickerView(frame: pickerViewFrame)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        alert.view.addSubview(pickerView)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            let selectedIndex = self.pickerView.selectedRow(inComponent: 0)
            let selectedSection = self.pickerData[selectedIndex].rawValue
            self.selectedMenuSection = MenuSection(rawValue: selectedSection)
            self.sectionSelectionButton.setTitle(selectedSection, for: .normal)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - View Setup
    private func configureView() {
        view.backgroundColor = /*UIColor(named: "primaryBgColor")*/.systemBackground
    }
    
    private func setupSubviews() {
        setupStackView()
        setupAddImageButton()
        setupNameTextField()
        setupPriceTextField()
        setupSectionSelectionButton()
        setupAddButton()
        addSubviews()
        setupConstraints()
        setupPickerView()
    }
    
    private func setupPickerView() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    private func setupSectionSelectionButton() {
        sectionSelectionButton = UIButton()
        sectionSelectionButton.setTitle("Select Section", for: .normal)
        sectionSelectionButton.translatesAutoresizingMaskIntoConstraints = false
        sectionSelectionButton.setTitleColor(.label, for: .normal)
        sectionSelectionButton.backgroundColor = .systemGray5
        sectionSelectionButton.layer.cornerRadius = 10
        sectionSelectionButton.addTarget(self, action: #selector(selectMenuSectionButtonTapped(_:)), for: .touchUpInside)
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
        addImageButton.backgroundColor = .systemGray5
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
        nameTextField.backgroundColor = .systemGray5
        nameTextField.layer.cornerRadius = 12
    }
    
    private func setupPriceTextField() {
        priceTextField = DTextField()
        priceTextField.keyboardType = .decimalPad
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        priceTextField.placeholder = "Price Tag"
        priceTextField.backgroundColor = .systemGray5
        priceTextField.layer.cornerRadius = 12
    }
    
    private func setupAddButton() {
        addButton = UIButton()
        addButton.setTitle("Add Item", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.backgroundColor = .app
        addButton.layer.cornerRadius = 10
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.setTitleColor(.label, for: .normal)
    }
    
    private func addSubviews() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(addImageButton)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(priceTextField)
        stackView.addArrangedSubview(sectionSelectionButton)
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
            
            sectionSelectionButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            sectionSelectionButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        guard let priceString = priceTextField.text,
              let price = Double(priceString) else {
            self.present(UIAlertController().defaultStyle(title: "Failed to Add Item", message: "Provide valid price!"), animated: true)
            return
        }
        
        if let name = nameTextField.text, let selectedSection = selectedMenuSection {
            let menuItem = MenuItem(name: name, price: price, menuSection: selectedSection) 
            do  {
                let databaseAccess = try SQLiteDataAccess.openDatabase()
                let menuService = MenuServiceImpl(databaseAccess: databaseAccess)
                try menuService.add(menuItem)
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.prepare()
                impactFeedback.impactOccurred()
                NotificationCenter.default.post(name: .didAddMenuItemNotification, object: nil)
            } catch {
                print("Unable to add MenuItem - \(error)")
            }
            menuItemDelegate?.menuItemDidAdd(menuItem)
            self.dismiss(animated: true)
        }
        
    }
}

extension AddItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerData[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected Item: \(pickerData[row].rawValue)")
    }
    
}

#Preview {
    AddItemViewController()
}

