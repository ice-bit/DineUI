//
//  AddItemViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/05/24.
//

import UIKit
import Toast

protocol MenuItemDelegate: AnyObject {
    func menuItemDidAdd(_ item: MenuItem)
}

class AddItemViewController: UIViewController {
    weak var menuItemDelegate: MenuItemDelegate?
    
    // MARK: - Properties
    private let category: MenuCategory
    
    private var stackView: UIStackView!
    private var nameTextField: UITextField!
    private var priceTextField: UITextField!
    private var descTextField: UITextField!
    private var addButton: UIButton!
    // private var sectionSelectionButton: UIButton!
    
    private var pickerView: UIPickerView!
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Menu Item"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        configureView()
        setupSubviews()
    }
    
    // MARK: - @OBJC Methods
    /*@objc private func selectMenuSectionButtonTapped(_ sender: UIButton) {
        print("menu selection button tapped")
        let alert = UIAlertController(title: "Select Section", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let pickerViewFrame = CGRect(x: 0, y: 50, width: alert.view.bounds.width - 20, height: 200)
        pickerView = UIPickerView(frame: pickerViewFrame)
        // pickerView.delegate = self
        // pickerView.dataSource = self
        
        alert.view.addSubview(pickerView)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view // Specify the view from which the popover should originate
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // Set the rectangle for the popover
            popoverController.permittedArrowDirections = [] // Optional: specify allowed arrow directions
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            let selectedIndex = self.pickerView.selectedRow(inComponent: 0)
            let selectedSection = self.pickerData[selectedIndex].rawValue
            self.selectedMenuSection = MenuSectionType(rawValue: selectedSection)
            self.sectionSelectionButton.setTitle(selectedSection, for: .normal)
        }))
        
        present(alert, animated: true, completion: nil)
    }*/
    
    // MARK: - View Setup
    private func configureView() {
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupSubviews() {
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
        view.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(priceTextField)
        stackView.addArrangedSubview(descTextField)
        // stackView.addArrangedSubview(sectionSelectionButton)
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
            
            descTextField.heightAnchor.constraint(equalToConstant: 44),
            descTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
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
        
        if let name = nameTextField.text {
            let menuItem = MenuItem(
                name: name,
                price: price,
                category: category,
                description: description
            )
            do  {
                let databaseAccess = try SQLiteDataAccess.openDatabase()
                let menuService = MenuServiceImpl(databaseAccess: databaseAccess)
                try menuService.add(menuItem)
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.prepare()
                impactFeedback.impactOccurred()
                NotificationCenter.default.post(name: .menuItemDidChangeNotification, object: nil)
            } catch {
                print("Unable to add MenuItem - \(error)")
            }
            menuItemDelegate?.menuItemDidAdd(menuItem)
            self.dismiss(animated: true)
        }
        
    }
}

/*extension AddItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
    
}*/

#Preview {
    AddItemViewController(category: MenuCategory(id: UUID(), categoryName: "Starter"))
}

