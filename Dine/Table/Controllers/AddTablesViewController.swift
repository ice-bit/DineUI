//
//  AddTablesViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 16/05/24.
//

import UIKit
import Toast

class AddTablesViewController: UIViewController {
    
    private var toast: Toast!
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var activeTextField: DineTextField?
    
    private func validateForm() {
        guard locationIdDineTextField.assitiveText != nil else { return }
        guard capacityDineTextField.assitiveText != nil else { return }
        addButton.isEnabled = true
    }
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 12
        return stackView
    }()
    
    let locationIdDineTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Location Identifier"
        field.placeholder = "Enter Location ID"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    let capacityDineTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Capacity"
        field.placeholder = "Max Capacity"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Table", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(addButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Add Table"
        setupScrollView()
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        navigationController?.navigationBar.prefersLargeTitles = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setupSubviews()
        locationIdDineTextField.onEditingChanged = onEditingChanged
        capacityDineTextField.onEditingChanged = onEditingChanged
        locationIdDineTextField.onDidBeginEditing = onDidBeginEditing
        locationIdDineTextField.onDidEndEditing = onDidEndEditing
        capacityDineTextField.onDidBeginEditing = onDidBeginEditing
        capacityDineTextField.onDidEndEditing = onDidEndEditing
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            
            /*scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets*/
            
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

    
    @objc private func addButtonAction(_ sender: UIButton) {
        print(#function)
        guard let locationIdText = locationIdDineTextField.inputText,
              let maxCapacityText = capacityDineTextField.inputText else {
            return
        }
        
        guard !locationIdText.isEmpty, let locationId = Int(locationIdText) else {
            handleTableError(.invalidLocationId)
            return
        }
        
        guard !maxCapacityText.isEmpty, let maxCapacity = Int(maxCapacityText) else {
            handleTableError(.invalidCapacity)
            return
        }
                
        do {
            let tableService = try TableServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let tableController = TableController(tableService: tableService)
            try tableController.addTable(maxCapacity: maxCapacity, locationIdentifier: locationId)
            
            // Notify
            NotificationCenter.default.post(name: .didAddTable, object: nil)
            
            self.dismiss(animated: true)
        } catch let error as TableError {
            handleTableError(error)
        } catch {
            print("Failed to perform \(#function): \(error)")
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func createTextFieldHeaderLabel(with title: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.text = title
        label.textAlignment = .left
        return label
    }
    
    private func setupSubviews() {
        scrollContentView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(locationIdDineTextField)
        verticalStackView.addArrangedSubview(capacityDineTextField)
        verticalStackView.addArrangedSubview(addButton)
        
        // Set custom spacing
        verticalStackView.setCustomSpacing(30, after: capacityDineTextField)

        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            verticalStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 20),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 55),
        ])
    }
    
    private func handleTableError(_ error: TableError) {
        switch error {
        case .locationIdAlreadyTaken:
            showErrorToast("Location ID already exist!")
        case .invalidLocationId:
            showErrorToast("Invalid location Identifier!")
        case .invalidCapacity:
            showErrorToast("Invalid capacity!")
        case .parsingFailed:
            fatalError("Parsing tables failed")
        case .noDataFound:
            showErrorToast("Please provide data")
        case .unknownError(let error):
            print("Unknown error: \(error)")
        }
    }
    
    private func showErrorToast(_ message: String) {
        if let toast {
            toast.close(animated: false)
        }
        toast = Toast.text(message)
        toast.show(haptic: .warning)
    }
    
    private func validataInput(_ textField: DineTextField) -> DineTextInputError? {
        guard let text = textField.inputText else { return nil }
        
        if Int(text) == nil {
            guard !text.isEmpty else { return nil }
            if textField == locationIdDineTextField {
                return DineTextInputError(localizedDescription: "Location ID must contain only numbers (0-9).")
            }
            if textField == capacityDineTextField {
                return DineTextInputError(localizedDescription: "Capacity must contain only numbers (0-9).")
            }
        }
        
        return nil
    }
    
    private func validataInput(_ text: String?) -> DineTextInputError? {
        guard let text else { return nil }
        
        if Int(text) == nil {
            return DineTextInputError(localizedDescription: "Capacity must contain only numbers (0-9).")
        }
        
        return nil
    }
    
    private func animateErrorMessage(for textfield: DineTextField) {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func onEditingChanged(_ textfield: DineTextField) {
        textfield.error = validataInput(textfield)
        animateErrorMessage(for: textfield)
    }
}

extension AddTablesViewController {
    private func onDidBeginEditing(_ textField: DineTextField) {
        activeTextField = textField
    }
    
    private func onDidEndEditing(_ textField: DineTextField) {
        activeTextField = nil
    }
}

#Preview {
    UINavigationController(rootViewController: AddTablesViewController())
}
