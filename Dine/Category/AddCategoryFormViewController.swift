//
//  AddCategoryFormViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/06/24.
//

import UIKit
import Toast

class AddCategoryFormViewController: UIViewController {
    
    private var toast: Toast!
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    
    private var activeTextField: DineTextField?
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let categoryTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Category"
        field.placeholder = "e.g. Appetizers"
        field.textfield.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Section", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(addButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Section"
        view.backgroundColor = .systemGroupedBackground
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        setupScrollView()
        navigationController?.navigationBar.prefersLargeTitles = true
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setupSubviews()
        configureTextFieldDelegates()
    }
    
    private func configureTextFieldDelegates() {
        categoryTextField.onDidBeginEditing = onDidBeginEditing
        categoryTextField.onDidEndEditing = onDidEndEditing
        categoryTextField.onReturn = textFieldShouldReturn
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
    
    private func showErrorToast() {
        if let toast {
            toast.close(animated: false)
        }
        toast = Toast.text("Invalid Category Name!")
        toast.show(haptic: .warning)
    }
    
    @objc private func addButtonAction(_ sender: UIButton) {
        print(#function)
        guard let categoryName = categoryTextField.inputText,
              !categoryName.isEmpty else {
            showErrorToast()
            return
        }
        
        do {
            let categoryService = try CategoryServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let category = MenuCategory(id: UUID(), categoryName: categoryName)
            try categoryService.add(category)
            // Post Notification
            NotificationCenter.default.post(name: .categoryDataDidChangeNotification, object: nil)
            self.dismiss(animated: true)
        } catch {
            print("Failed to perform \(#function): \(error)")
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
        verticalStackView.addArrangedSubview(categoryTextField)
        verticalStackView.addArrangedSubview(addButton)
        verticalStackView.setCustomSpacing(34, after: categoryTextField)
        
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            verticalStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 40),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 55),
        ])
    }
}

extension AddCategoryFormViewController {
    private func onDidBeginEditing(_ textField: DineTextField) {
        activeTextField = textField
    }
    
    private func onDidEndEditing(_ textField: DineTextField) {
        activeTextField = nil
    }
    
    private func textFieldShouldReturn(_ textField: DineTextField) -> Bool {
        textField.textfield.resignFirstResponder()
        return true
    }
}

#Preview {
    UINavigationController(rootViewController: AddCategoryFormViewController())
}
