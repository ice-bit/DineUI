//
//  AddUserFormViewController.swift
//  Dine
//
//  Created by ice on 07/08/24.
//
import UIKit

class AddUserFormViewController: UIViewController {
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var toggleButton: UIButton!
    private var confirmPasswordToggleButton: UIButton!
    var onDidAddUser: ((Account) -> Void)?
    private var selectedUserRole: UserRole = .employee {
        didSet {
            dinePicker.contentLabel.text = selectedUserRole.rawValue
        }
    }
    
    private var activeTextField: DineTextField?
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(handleSignUpButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let usernameDineTextField: DineTextField = {
        let field = DineTextField()
        field.keyboardType = .emailAddress
        field.titleText = "Username"
        field.placeholder = "Username (e.g., johndoe)"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let passwordDineTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Create a Password"
        field.textfield.isSecureTextEntry = true
        field.placeholder = "Set Password"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let confirmPasswordDineTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Confirm Password"
        field.textfield.isSecureTextEntry = true
        field.placeholder = "Verify Password"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let dinePicker: DineUserSelector = {
        let picker = DineUserSelector()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private var isFormValid: Bool {
        guard let usernameAssitiveText = usernameDineTextField.assitiveText,
              let passwordAssitiveText = passwordDineTextField.assitiveText,
              let confirmPasswordAssitveText = confirmPasswordDineTextField.assitiveText else {
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        view.backgroundColor = .systemGroupedBackground
        title = "Add User"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupPasswordVisibilityToggle()
        setupConfirmPasswordVisibilityToggle()
        setupSubviews()
        configureTapGesture()
        setupPicker()
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        usernameDineTextField.onEditingChanged = onEditingChanged
        usernameDineTextField.onDidBeginEditing = onDidBeginEditing
        usernameDineTextField.onDidEndEditing = onDidEndEditingUsernameTF
        passwordDineTextField.onEditingChanged = onEditingChanged
        passwordDineTextField.onDidBeginEditing = onDidBeginEditing
        passwordDineTextField.onDidEndEditing = onDidEndEditing
        confirmPasswordDineTextField.onEditingChanged = onEditingChanged
        confirmPasswordDineTextField.onDidBeginEditing = onDidBeginEditing
        confirmPasswordDineTextField.onDidEndEditing = onDidEndEditing
        dinePicker.contentLabel.text = selectedUserRole.rawValue
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
    
    private func setupPicker() {
        var actions = [UIAction]()
        for role in UserRole.allCases {
            let action = UIAction(title: role.rawValue) { [weak self] _ in
                self?.selectedUserRole = role
            }
            actions.append(action)
        }
        
        let menu = UIMenu(children: actions)
        dinePicker.menu = menu
    }

    private func setupPasswordVisibilityToggle() {
        toggleButton = createVisibilityToggleButton()
        configureVisibilityToggle(for: passwordDineTextField, with: toggleButton)
    }

    private func setupConfirmPasswordVisibilityToggle() {
        confirmPasswordToggleButton = createVisibilityToggleButton()
        configureVisibilityToggle(for: confirmPasswordDineTextField, with: confirmPasswordToggleButton)
    }

    private func createVisibilityToggleButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .secondaryLabel
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        return button
    }

    private func configureVisibilityToggle(for textField: DineTextField, with button: UIButton) {
        button.addTarget(self, action: #selector(handleVisibilityToggle(_:)), for: .touchUpInside)
        let padding: CGFloat = 0
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: button.frame.width + padding * 2, height: button.frame.height))
        button.center = containerView.center
        containerView.addSubview(button)
        textField.textfield.rightView = containerView
    }

    @objc private func handleVisibilityToggle(_ sender: UIButton) {
        if sender == toggleButton {
            toggleSecureTextEntry(for: passwordDineTextField, with: toggleButton)
        } else if sender == confirmPasswordToggleButton {
            toggleSecureTextEntry(for: confirmPasswordDineTextField, with: confirmPasswordToggleButton)
        }
    }

    private func toggleSecureTextEntry(for textField: DineTextField, with button: UIButton) {
        textField.textfield.isSecureTextEntry.toggle()
        let buttonImageName = textField.textfield.isSecureTextEntry ? "eye" : "eye.slash"
        button.setImage(UIImage(systemName: buttonImageName), for: .normal)
        if let existingText = textField.inputText, textField.textfield.isSecureTextEntry {
            textField.textfield.deleteBackward()
            textField.textfield.insertText(existingText)
        }
    }

    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func handleSignUpButtonTapped(_ sender: UIButton) {
        createAccountAndSignIn()
    }

    private func createAccountAndSignIn() {
        guard let username = usernameDineTextField.inputText,
              let password = passwordDineTextField.inputText,
              let confirmPassword = confirmPasswordDineTextField.inputText else {
            // showToast(message: "Please fill all fields.")
            return
        }

        guard !username.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            // showToast(message: "Please fill all fields.")
            return
        }

        guard password == confirmPassword else {
            // showToast(message: "Password Doesn't Match")
            return
        }
        
        let account = Account(username: username, password: password, accountStatus: .active, userRole: selectedUserRole)

        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let accountService = AccountServiceImpl(databaseAccess: databaseAccess)
            try accountService.add(account)
            onDidAddUser?(account)
            dismiss(animated: true)
        } catch let error as AuthenticationError {
            fatalError("Auth error: \(error)")
        } catch {
            fatalError("Error: \(error)")
        }
    }

    private func setupSubviews() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(usernameDineTextField)
        verticalStackView.addArrangedSubview(passwordDineTextField)
        verticalStackView.addArrangedSubview(confirmPasswordDineTextField)
        verticalStackView.addArrangedSubview(dinePicker)
        verticalStackView.addArrangedSubview(signUpButton)
        verticalStackView.setCustomSpacing(34, after: confirmPasswordDineTextField)
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            verticalStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.88),
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 55),
        ])
    }
    
    private func isUserAvaialable(_ username: String) -> Bool {
        do {
            let dbAccess = try SQLiteDataAccess.openDatabase()
            let accountService = AccountServiceImpl(databaseAccess: dbAccess)
            let account = try accountService.fetch()
            if let account {
                if account.first(where: { $0.username == username }) != nil {
                    return true
                } else {
                    return false
                }
            } else {
                print("no account found")
                return false
            }
        } catch {
            fatalError("accessing db failed with error: \(error)")
        }
    }

    private func validateText(_ textField: DineTextField) -> DineTextInputError? {
        guard let text = textField.inputText else { return nil }
        
        if textField == usernameDineTextField {
            guard !text.isEmpty else { return nil }
            if !AuthenticationValidator.isValidUsername(text) {
                return DineTextInputError(localizedDescription: "Username must be 3-20 characters, only letters, numbers, and underscores.")
            }
        }
        
        if textField == passwordDineTextField {
            guard !text.isEmpty else { return nil }
            if !AuthenticationValidator.isStrongPassword(text) {
                return DineTextInputError(localizedDescription: "Password must be 8+ characters, with letters, numbers, and special characters.")
            }
        }
        
        if textField == confirmPasswordDineTextField {
            guard !text.isEmpty else { return nil }
            if !AuthenticationValidator.isStrongPassword(text) {
                return DineTextInputError(localizedDescription: "Password must be 8+ characters, with letters, numbers, and special characters.")
            }
            if passwordDineTextField.inputText != confirmPasswordDineTextField.inputText {
                return DineTextInputError(localizedDescription: "Passwords don't match.")
            }
        }
        
        return nil
    }
    
    private func validateUsername(_ textField: DineTextField) -> DineTextInputError? {
        guard let text = textField.inputText else { return nil }
        
        if isUserAvaialable(text) {
            return DineTextInputError(localizedDescription: "Username not available")
        }
        
        return nil
    }

    private func animateErrorMessage(for textField: DineTextField) {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private func onEditingChanged(_ textField: DineTextField) {
        textField.error = validateText(textField)
        animateErrorMessage(for: textField)
    }
    
    private func onDidEndEditingUsernameTF(_ textField: DineTextField) {
        textField.error = validateUsername(textField)
        animateErrorMessage(for: textField)
        activeTextField = nil
    }
}

extension AddUserFormViewController {
    private func onDidBeginEditing(_ textField: DineTextField) {
        activeTextField = textField
    }
    
    private func onDidEndEditing(_ textField: DineTextField) {
        activeTextField = nil
    }
}

#Preview {
    AddUserFormViewController()
}

