//
//  SignUpViewController.swift
//  Dine
//
//  Created by ice-bit on 18/06/24.
//

import UIKit
import Toast

class SignUpViewController: UIViewController {
    private var toast: Toast!
    var isInitialScreen: Bool = false
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var toggleButton: UIButton!
    private var confirmPasswordToggleButton: UIButton!
    private var activeTextField: DineTextField?
    
    private var textFields: [DineTextField] {
        return [usernameTextField, passwordTextField, verifyPasswordTextField]
    }
    
    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Dine!"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
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
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(signUpButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign Up"
        view.backgroundColor = .systemGroupedBackground
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        setupPasswordVisibiltyToggle()
        setupConfirmPasswordVisibiltyToggle()
        setupSubviews()
        configureTextFieldDelegates()
        
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
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureTextFieldDelegates() {
        usernameTextField.onShouldEndEditing = textFieldShouldEndEditing
        passwordTextField.onShouldEndEditing = textFieldShouldEndEditing
        verifyPasswordTextField.onShouldEndEditing = textFieldShouldEndEditing
        
        usernameTextField.onDidBeginEditing = onDidBeginEditing
        passwordTextField.onDidBeginEditing = onDidBeginEditing
        verifyPasswordTextField.onDidBeginEditing = onDidBeginEditing
        
        verifyPasswordTextField.onDidEndEditing = onDidEndEditing
        usernameTextField.onDidEndEditing = onDidEndEditing
        passwordTextField.onDidEndEditing = onDidEndEditing
        
        usernameTextField.onReturn = textFieldShouldReturn
        passwordTextField.onReturn = textFieldShouldReturn
        verifyPasswordTextField.onReturn = textFieldShouldReturn
        
        usernameTextField.onEditingChanged = textFieldDidChangeEditing
        passwordTextField.onEditingChanged = textFieldDidChangeEditing
        verifyPasswordTextField.onEditingChanged = textFieldDidChangeEditing
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
    
    private func setupPasswordVisibiltyToggle() {
        toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        toggleButton.tintColor = .secondaryLabel
        toggleButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        let padding: CGFloat = 0 // Change this value to adjust the padding
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: toggleButton.frame.width + padding * 2, height: toggleButton.frame.height))
        toggleButton.center = containerView.center
        containerView.addSubview(toggleButton)
        
        passwordTextField.textfield.rightView = containerView
    }
    
    @objc func togglePasswordVisibility() {
        passwordTextField.textfield.isSecureTextEntry.toggle()
        let buttonImageName = passwordTextField.textfield.isSecureTextEntry ? "eye" : "eye.slash"
        toggleButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
        if let existingText = passwordTextField.inputText, passwordTextField.textfield.isSecureTextEntry {
            passwordTextField.textfield.deleteBackward()
            passwordTextField.textfield.insertText(existingText)
        }
    }
    
    private func setupConfirmPasswordVisibiltyToggle() {
        confirmPasswordToggleButton = UIButton(type: .custom)
        confirmPasswordToggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        confirmPasswordToggleButton.tintColor = .secondaryLabel
        confirmPasswordToggleButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        confirmPasswordToggleButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
        
        let padding: CGFloat = 0 // Change this value to adjust the padding
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: confirmPasswordToggleButton.frame.width + padding * 2, height: confirmPasswordToggleButton.frame.height))
        confirmPasswordToggleButton.center = containerView.center
        containerView.addSubview(confirmPasswordToggleButton)
        
        verifyPasswordTextField.textfield.rightView = containerView
    }
    
    @objc func toggleConfirmPasswordVisibility() {
        verifyPasswordTextField.textfield.isSecureTextEntry.toggle()
        let buttonImageName = verifyPasswordTextField.textfield.isSecureTextEntry ? "eye" : "eye.slash"
        confirmPasswordToggleButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
        if let existingText = verifyPasswordTextField.inputText, verifyPasswordTextField.textfield.isSecureTextEntry {
            verifyPasswordTextField.textfield.deleteBackward()
            verifyPasswordTextField.textfield.insertText(existingText)
        }
    }
    
    @objc private func loginLabelAction(_ sender: UILabel) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func signUpButtonAction(_ sender: UIButton) {
        createAccountAndSignIn()
    }
    
    private func createAccountAndSignIn() {
        guard let username = usernameTextField.inputText,
              let password = passwordTextField.inputText,
              let confirmPassword = verifyPasswordTextField.inputText else {
            showToast(message: "Please fill all fields.")
            return
        }
        
        guard !username.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            showToast(message: "Please fill all fields.")
            return
        }
        
        guard password == confirmPassword else {
            showToast(message: "Password Doesn't Match")
            return
        }
        
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let authController = AuthController(databaseAccess: databaseAccess)
            try authController.createAccount(username: username, password: confirmPassword, userRole: .manager)
            guard let account = try authController.login(username: username, password: confirmPassword) else {
                throw AuthenticationError.noUserFound
            }
            RootViewManager.didSignInSuccessfully(with: account)
        } catch let error as AuthenticationError {
            handleLoginError(error)
        } catch {
            handleLoginError(.other(error))
        }
    }
    
    func handleLoginError(_ error: AuthenticationError) {
        switch error {
        case .invalidUsername:
            showToast(message: "Invalid username.")
        case .invalidPassword:
            showToast(message: "Invalid password.")
        case .userAlreadyExists:
            showToast(message: "Username taken.")
        case .inactiveAccount:
            showToast(message: "Account inactive.")
        case .noUserFound:
            showToast(message: "User not found.")
        case .other:
            showToast(message: "An error occurred.")
        case .incorrectPassword:
            showToast(message: "Incorrect password")
        case .notStrongPassword:
            showToast(message: "Provide a strong password")
        }
    }
    
    func showToast(message: String) {
        if let toast {
            toast.close(animated: false)
        }
        toast = Toast.default(image: UIImage(systemName: "exclamationmark.triangle.fill")!, title: message)
        toast.show(haptic: .warning)
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
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView = UIView()
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(introLabel)
        verticalStackView.addArrangedSubview(usernameTextField)
        verticalStackView.addArrangedSubview(passwordTextField)
        verticalStackView.addArrangedSubview(verifyPasswordTextField)
        verticalStackView.addArrangedSubview(signUpButton)
        
        // Set custom spacing
        verticalStackView.setCustomSpacing(34, after: introLabel)
        verticalStackView.setCustomSpacing(34, after: verifyPasswordTextField)
        
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
            
            verticalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            verticalStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 65),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 55),
        ])
    }
    
    func validateText(_ textfield: DineTextField) -> DineTextInputError? {
        guard let text = textfield.inputText else { return nil }
        
        if textfield == usernameTextField {
            guard !text.isEmpty else { return nil }
            
            if !AuthenticationValidator.isValidUsername(text) {
                return DineTextInputError(localizedDescription: "Username must be 3-20 characters, only letters, numbers, and underscores.")
            }
        }
        
        if textfield == passwordTextField {
            guard !text.isEmpty else { return nil }
            
            if !AuthenticationValidator.isStrongPassword(text) {
                return DineTextInputError(localizedDescription: "Password must be 8+ characters, with letters, numbers, and special characters.")
            }
        }
        
        if textfield == verifyPasswordTextField {
            guard !text.isEmpty else { return nil }
            
            if !AuthenticationValidator.isStrongPassword(text) {
                return DineTextInputError(localizedDescription: "Password must be 8+ characters, with letters, numbers, and special characters.")
            }
            if !(passwordTextField.inputText == verifyPasswordTextField.inputText) {
                return DineTextInputError(localizedDescription: "Passwords doesn't match.")
            }
        }
        
        return nil
    }
    
    let usernameTextField: DineTextField = {
        let field = DineTextField()
        field.keyboardType = .emailAddress
        field.titleText = "Username"
        field.placeholder = "Username (e.g., johndoe)"
        field.textfield.returnKeyType = .next
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let passwordTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Create a Password"
        field.textfield.isSecureTextEntry = true
        field.placeholder = "Set Password"
        field.textfield.returnKeyType = .next
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let verifyPasswordTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Confirm Password"
        field.textfield.isSecureTextEntry = true
        field.placeholder = "Verify Password"
        field.textfield.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private func animateErrorMessage(for textfield: DineTextField) {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func onEditingChanged(_ textfield: DineTextField) {
        textfield.error = validateText(textfield)
        animateErrorMessage(for: textfield)
    }

}

extension SignUpViewController {
    private func onDidBeginEditing(_ textField: DineTextField) {
        activeTextField = textField
    }
    
    private func onDidEndEditing(_ textField: DineTextField) {
        activeTextField = nil
    }
    
    private func textFieldDidChangeEditing(_ textField: DineTextField) {
        textField.error = nil
        animateErrorMessage(for: textField)
    }
    
    private func textFieldShouldEndEditing(_ textField: DineTextField) -> Bool {
        if let validator = validateText(textField) {
            textField.error = validator
            animateErrorMessage(for: textField)
            return false
        } else {
            return true
        }
    }
    
    private func textFieldShouldReturn(_ textField: DineTextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.textfield.becomeFirstResponder()
        } else if textField == passwordTextField {
            verifyPasswordTextField.textfield.becomeFirstResponder()
        } else if textField == verifyPasswordTextField {
            verifyPasswordTextField.textfield.resignFirstResponder()
        }
        return true
    }
}

#Preview {
    UINavigationController(rootViewController: SignUpViewController())
}
