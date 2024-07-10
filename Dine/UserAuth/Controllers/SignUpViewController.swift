//
//  SignUpViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 18/06/24.
//

import UIKit
import Toast

class SignUpViewController: UIViewController, UITextFieldDelegate {
    private var toast: Toast!
    var isInitialScreen: Bool = false
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var activeTextField: UITextField?
    private var toggleButton: UIButton!
    private var confirmPasswordToggleButton: UIButton!
    
    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Dine!"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var usernameTextField: UITextField = {
        let textField = DTextField()
        textField.placeholder = "Username"
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = DTextField()
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.delegate = self
        return textField
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = DTextField()
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.layer.cornerRadius = 10
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Confirm Password"
        textField.delegate = self
        return textField
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(signUpButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account? Login"
        label.font = .preferredFont(forTextStyle: .footnote)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        if isInitialScreen {
            loginLabel.isHidden = true
        }
        setupPasswordVisibiltyToggle()
        setupConfirmPasswordVisibiltyToggle()
        setupLoginLabelGesture()
        setupSubviews()
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Sign Up"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.height
            if let activeField = self.activeTextField {
                if !aRect.contains(activeField.frame.origin) {
                    scrollView.scrollRectToVisible(activeField.frame, animated: true)
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
        toggleButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordTextField.rightView = toggleButton
        passwordTextField.rightViewMode = .always
    }
    
    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let buttonImageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        toggleButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
        if let existingText = passwordTextField.text, passwordTextField.isSecureTextEntry {
            passwordTextField.deleteBackward()
            passwordTextField.insertText(existingText)
        }
    }
    
    private func setupConfirmPasswordVisibiltyToggle() {
        confirmPasswordToggleButton = UIButton(type: .custom)
        confirmPasswordToggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        confirmPasswordToggleButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        confirmPasswordToggleButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
        confirmPasswordTextField.rightView = confirmPasswordToggleButton
        confirmPasswordTextField.rightViewMode = .always
    }
    
    @objc func toggleConfirmPasswordVisibility() {
        confirmPasswordTextField.isSecureTextEntry.toggle()
        let buttonImageName = confirmPasswordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        confirmPasswordToggleButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
        if let existingText = confirmPasswordTextField.text, confirmPasswordTextField.isSecureTextEntry {
            confirmPasswordTextField.deleteBackward()
            confirmPasswordTextField.insertText(existingText)
        }
    }
    
    private func setupLoginLabelGesture() {
        loginLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(loginLabelAction(_:)))
        loginLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func loginLabelAction(_ sender: UILabel) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func signUpButtonAction(_ sender: UIButton) {
        createAccountAndSignIn()
    }
    
    private func createAccountAndSignIn() {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
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
    
    private func setupSubviews() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(verticalStackView)
        contentView.addSubview(loginLabel)
        verticalStackView.addArrangedSubview(introLabel)
        verticalStackView.addArrangedSubview(usernameTextField)
        verticalStackView.addArrangedSubview(passwordTextField)
        verticalStackView.addArrangedSubview(confirmPasswordTextField)
        verticalStackView.addArrangedSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            verticalStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            verticalStackView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: contentView.topAnchor, multiplier: 0.2),
            verticalStackView.bottomAnchor.constraint(greaterThanOrEqualTo: loginLabel.topAnchor, constant: -20),
            
            usernameTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            signUpButton.heightAnchor.constraint(equalToConstant: 55),
            
            loginLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}


#Preview {
    SignUpViewController()
}
