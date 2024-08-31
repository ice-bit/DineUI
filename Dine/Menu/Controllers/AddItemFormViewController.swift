//
//  AddItemFormViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/05/24.
//

import UIKit
import Toast
import PhotosUI

class AddItemFormViewController: UIViewController {
    
    // MARK: - Properties
    var didUpdateMenuItem: ((MenuItem) -> Void)?
    private var selectedCategory: MenuCategory? {
        didSet {
            categoryTFPicker.text = selectedCategory?.categoryName
        }
    }
    private var menuItem: MenuItem?
    
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var toast: Toast!
    
    private var stackView: UIStackView!
    private var wrapperStackView: UIStackView!
    private var addButton: UIButton!
    
    private var pickerView: UIPickerView!
    
    // This property will store the active text field
    var activeTextField: DineTextField? {
        didSet {
            
        }
    }
    
    lazy private var imagePickerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Photo", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 56
        button.layer.masksToBounds = true
        button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        button.layer.borderWidth = 1
        button.layer.borderColor = .init(gray: 1, alpha: 1)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.addTarget(self, action: #selector(imagePickerButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(menuItem: MenuItem) {
        self.menuItem = menuItem
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
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        bindTextFieldEvents()
        configureForEditing()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            var visibleRect = self.view.frame
            visibleRect.size.height -= keyboardHeight

            if let activeTextField = self.activeTextField {
                // Convert the text field's frame to the scroll view's coordinate system
                let textFieldFrameInScrollView = activeTextField.convert(activeTextField.bounds, to: scrollView)
                // Check if the active text field is not visible
                if !visibleRect.contains(textFieldFrameInScrollView.origin) {
                    scrollView.scrollRectToVisible(textFieldFrameInScrollView, animated: true)
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    private func bindTextFieldEvents() {
        nameTextField.onEditingChanged = textFieldDidChangeEditing
        priceTextField.onEditingChanged = textFieldDidChangeEditing
        descTextField.onEditingChanged = textFieldDidChangeEditing
        nameTextField.onReturn = textFieldShouldReturn
        priceTextField.onReturn = textFieldShouldReturn
        descTextField.onReturn = textFieldShouldReturn
        nameTextField.onShouldEndEditing = textFieldShouldEndEditing
        priceTextField.onShouldEndEditing = textFieldShouldEndEditing
        descTextField.onShouldEndEditing = textFieldShouldEndEditing
        nameTextField.onDidBeginEditing = textFieldDidBeginEditing
        priceTextField.onDidBeginEditing = textFieldDidBeginEditing
        descTextField.onDidBeginEditing = textFieldDidBeginEditing
        nameTextField.onDidEndEditing = textFieldDidEndEditing
        priceTextField.onDidEndEditing = textFieldDidEndEditing
        descTextField.onDidEndEditing = textFieldDidEndEditing
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
    // looking for methods? sorry for disappointing :(
    
    // MARK: - View Setup
    private func createTextFieldHeaderLabel(with title: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.text = title
        label.textAlignment = .left
        return label
    }
    
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
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    private func setupSubviews() {
        setupScrollView()
        setupStackView()
        setupAddButton()
        addSubviews()
        setupConstraints()
    }
    
    private func setupStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupAddButton() {
        addButton = UIButton()
        addButton.setTitle("Save", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.backgroundColor = .app
        addButton.layer.cornerRadius = 10
        addButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
    }
    
    private func createWrapperStackView() -> UIStackView {
        let wrapperStackView = UIStackView()
        wrapperStackView.axis = .vertical
        wrapperStackView.alignment = .center
        wrapperStackView.translatesAutoresizingMaskIntoConstraints = false
        return wrapperStackView
    }
    
    private func didTapPicker() {
        print(#function)
        let categoryListingVC = MenuSectionViewController(isSelectable: true)
        categoryListingVC.didSelectCategory = didSelectCategory
        navigationController?.present(UINavigationController(rootViewController: categoryListingVC), animated: true)
    }
    
    private func didSelectCategory(_ category: MenuCategory) {
        selectedCategory = category
    }
    
    private func addSubviews() {
        scrollContentView.addSubview(stackView)
        wrapperStackView = createWrapperStackView()
        wrapperStackView.addArrangedSubview(imagePickerButton)
        stackView.addArrangedSubview(wrapperStackView)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(priceTextField)
        stackView.addArrangedSubview(descTextField)
        stackView.addArrangedSubview(categoryTFPicker)
        stackView.addArrangedSubview(addButton)
        categoryTFPicker.onDidTapPicker = didTapPicker
        
        // Custom spacing
        stackView.setCustomSpacing(25, after: imagePickerButton)
        stackView.setCustomSpacing(10, after: nameTextField)
        stackView.setCustomSpacing(10, after: priceTextField)
        stackView.setCustomSpacing(10, after: descTextField)
        stackView.setCustomSpacing(34, after: categoryTFPicker)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            stackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 55),
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            priceTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            descTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            imagePickerButton.heightAnchor.constraint(equalToConstant: 112),
            imagePickerButton.widthAnchor.constraint(equalToConstant: 112),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func saveAction() {
        guard let priceString = priceTextField.inputText,
              let price = Double(priceString) else {
            presentAlert(title: "Failed to Add Item", message: "Provide a valid price!")
            return
        }
        
        guard let description = descTextField.inputText, !description.isEmpty else {
            showToast(message: "Invalid Description!", haptic: .error)
            return
        }
        
        guard let image = imagePickerButton.image(for: .normal) else {
            showToast(message: "No Image Selected", haptic: .warning)
            return
        }
        
        guard let name = nameTextField.inputText else { return }
        
        guard let selectedCategory else { return }
        
        let newItem = MenuItem(name: name, price: price, category: selectedCategory, description: description, image: image)
        
        saveMenuItem(newItem)
    }

    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController().defaultStyle(title: title, message: message)
        present(alertController, animated: true)
    }

    private func showToast(message: String, haptic: UINotificationFeedbackGenerator.FeedbackType) {
        let toast = Toast.text(message)
        toast.show(haptic: haptic)
    }

    private func saveMenuItem(_ menuItem: MenuItem) {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let menuService = MenuServiceImpl(databaseAccess: databaseAccess)
            
            if let existingMenuItem = self.menuItem {
                try updateMenuItem(existingMenuItem, with: menuItem, using: menuService)
            } else {
                try menuService.add(menuItem)
            }
            didUpdateMenuItem?(menuItem)
            self.showToast(message: "Item Added", haptic: .success)
            self.dismiss(animated: true)
        } catch {
            self.handleDatabaseError(error)
        }
    }

    private func updateMenuItem(_ existingMenuItem: MenuItem, with newItem: MenuItem, using menuService: MenuServiceImpl) throws {
        existingMenuItem.image = newItem.image
        existingMenuItem.name = newItem.name
        existingMenuItem.price = newItem.price
        existingMenuItem.description = newItem.description
        existingMenuItem.category = newItem.category
        try menuService.update(existingMenuItem)
    }

    private func handleDatabaseError(_ error: Error) {
        print("Unable to add MenuItem - \(error)")
        self.showToast(message: "Failed to add menu item!", haptic: .warning)
    }
    
    let nameTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Item Name"
        field.textfield.returnKeyType = .next
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let priceTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Price Tag"
        field.keyboardType = .decimalPad
        field.textfield.returnKeyType = .next
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let descTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Description"
        field.textfield.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let categoryTFPicker: DineUserSelector = {
        let selector = DineUserSelector()
        selector.title = "Choose Category"
        selector.text = "No Categories Selected"
        selector.translatesAutoresizingMaskIntoConstraints = false
        return selector
    }()
    
    private func configureForEditing() {
        if let menuItem {
            nameTextField.inputText = menuItem.name
            priceTextField.inputText = String(menuItem.price)
            descTextField.inputText = menuItem.description
            categoryTFPicker.text = menuItem.category.categoryName
            imagePickerButton.setTitle(nil, for: .normal)
            Task {
                let renderedImage = menuItem.renderedImage
                imagePickerButton.setImage(renderedImage, for: .normal)
            }
        } else {
            nameTextField.placeholder = "e.g. McWings"
            priceTextField.placeholder = "Enter Price"
            descTextField.placeholder = "Provide Details"
        }
    }
    
    private func validateInputText(_ textField: DineTextField) -> DineTextInputError? {
        guard let text = textField.inputText else { return nil }
        
        if textField == priceTextField {
            guard !text.isEmpty else { return nil }
            
            if Double(text) == nil {
                return DineTextInputError(localizedDescription: "Please enter a valid price using only numbers and a decimal point.")
            }
        }

        return nil
    }
    
    private func animateErrorMessage(for textfield: DineTextField) {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension AddItemFormViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider else { return }
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { image, error in
                if let selectedImage = image as? UIImage {
                    DispatchQueue.main.async {
                        // Update UI
                        self.imagePickerButton.setImage(selectedImage, for: .normal)
                        self.imagePickerButton.setTitle("", for: .normal)
                        self.view.layoutIfNeeded()
                    }
                }
            })
        }
    }
}

extension AddItemFormViewController {
    private func textFieldDidBeginEditing(_ textField: DineTextField) {
        activeTextField = textField
    }
    
    private func textFieldDidEndEditing(_ textField: DineTextField) {
        activeTextField = nil
    }
    
    private func textFieldDidChangeEditing(_ textField: DineTextField) {
        textField.error = nil
        animateErrorMessage(for: textField)
    }
    
    private func textFieldShouldEndEditing(_ textField: DineTextField) -> Bool {
        if let validator = validateInputText(textField) {
            textField.error = validator
            animateErrorMessage(for: textField)
            return false
        } else {
            return true
        }
    }
    
    private func textFieldShouldReturn(_ textField: DineTextField) -> Bool {
        if textField == nameTextField {
            priceTextField.textfield.becomeFirstResponder()
        } else if textField == priceTextField {
            descTextField.textfield.becomeFirstResponder()
        } else if textField == descTextField {
            descTextField.textfield.resignFirstResponder()
        }
        return true
    }
}

#Preview {
    UINavigationController(rootViewController: AddItemFormViewController())
}

