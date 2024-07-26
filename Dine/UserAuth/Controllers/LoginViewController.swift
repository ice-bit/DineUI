//
//  LoginViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 18/06/24.
//

import UIKit
import Toast

class LoginViewController: UIViewController {
    private var toggleButton: UIButton!
    private var toast: Toast!
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    
    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Dine!"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(loginButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var forgotPasswordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .preferredFont(forTextStyle: .footnote)
        label.translatesAutoresizingMaskIntoConstraints = false
        // Create the attributed string with the text
        let text = "Forgot Password?"
        let attributedString = NSMutableAttributedString(string: text)
        // Add the underline attribute to the entire text
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        label.attributedText = attributedString
        return label
    }()
    
    private lazy var signUpLabel: UILabel = {
        let label = UILabel()
        // Full string
        let fullString = "Don't have an account? Sign Up"

        // Underline range
        let underlineRange = (fullString as NSString).range(of: "Sign Up")

        // Create an attributed string
        let attributedString = NSMutableAttributedString(string: fullString)

        // Add underline attribute to the specific range
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: underlineRange)

        // Set the attributed string to the label
        label.attributedText = attributedString
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        setupSubviews()
        //createTrackingConstraints()
        setupSignUpLabelGesture()
        setupPasswordVisibiltyToggle()
        setupForgetLabelGesture()
        view.backgroundColor = .systemGroupedBackground
        title = "Login"
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        fetchAccounts()
        //usernameDineTextField.onEditingChanged = onEditingChanged
        //passwordDineTextField.onEditingChanged = onEditingChanged
    }
    
    private func createTextFieldHeaderLabel(with title: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.text = title
        label.textAlignment = .left
        return label
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
    
    private func setupPasswordVisibiltyToggle() {
        toggleButton = UIButton(type: .custom)
        // Configure the toggle button
        toggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        toggleButton.tintColor = .secondaryLabel
        toggleButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        let padding: CGFloat = 0 // Change this value to adjust the padding
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: toggleButton.frame.width + padding * 2, height: toggleButton.frame.height))
        toggleButton.center = containerView.center
        containerView.addSubview(toggleButton)
        
        // Add the button to the right view of the text field
        passwordDineTextField.textfield.rightView = containerView
    }
    
    @objc func togglePasswordVisibility() {
        passwordDineTextField.textfield.isSecureTextEntry.toggle()
        let buttonImageName = passwordDineTextField.textfield.isSecureTextEntry ? "eye" : "eye.slash"
        toggleButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
    }
    
    // This method is meant to be removed
    private func fetchAccounts() {
        do {
            let accountService = try AccountServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            guard let results = try accountService.fetch() else { return }
            for account in results {
                print("Username: \(account.username)\nPassword: \(account.password)\n")
            }
        } catch {
            print("Unable to fetch accounts: \(error)")
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func loginButtonAction(_ sender: UIButton) {
        print(#function)
        guard let username = usernameDineTextField.inputText,
              let password = passwordDineTextField.inputText,
            !password.isEmpty,
              !username.isEmpty else {
            showToast(message: "Missing Credentials")
            return
        }
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let authController = AuthController(databaseAccess: databaseAccess)
            guard let account = try authController.login(username: username, password: password) else {
                throw AuthenticationError.noUserFound
            }
            RootViewManager.didSignInSuccessfully(with: account)
        }  catch let error as AuthenticationError {
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
        toast.show(haptic: .error)
    }
    
    private func createTrackingConstraints() {
        let keyboardToVerticalStackView = view.keyboardLayoutGuide.topAnchor.constraint(equalToSystemSpacingBelow: verticalStackView.bottomAnchor, multiplier: 1.0)
        keyboardToVerticalStackView.identifier = "keyboardToVerticalStackView"
        
        let nearBottomConstraints = [keyboardToVerticalStackView]
        view.keyboardLayoutGuide.setConstraints(nearBottomConstraints, activeWhenNearEdge: .bottom)
    }
    
    private func setupSubviews() {
        scrollContentView.addSubview(verticalStackView)
        scrollContentView.addSubview(signUpLabel)
        verticalStackView.addArrangedSubview(introLabel)
        verticalStackView.addArrangedSubview(usernameDineTextField)
        verticalStackView.addArrangedSubview(passwordDineTextField)
        verticalStackView.addArrangedSubview(forgotPasswordLabel)
        verticalStackView.addArrangedSubview(loginButton)
        
        // Custom spacing
        verticalStackView.setCustomSpacing(34, after: introLabel)
        verticalStackView.setCustomSpacing(20, after: forgotPasswordLabel)
        
        
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            verticalStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 100),
//            forgotPasswordLabel.heightAnchor.constraint(equalToConstant: 14),
            loginButton.heightAnchor.constraint(equalToConstant: 55),
            signUpLabel.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            signUpLabel.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 20),
            signUpLabel.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20),
        ])
    }
    
    private func setupSignUpLabelGesture() {
        signUpLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(signUpLabelAction(_:)))
        signUpLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func signUpLabelAction(_ sender: UILabel) {
        print(#function)
        let signUpViewController = SignUpViewController()
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    private func setupForgetLabelGesture() {
        forgotPasswordLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forgotLabelLabelAction(_:)))
        forgotPasswordLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func forgotLabelLabelAction(_ sender: UILabel) {
        print(#function)
        let recoverPasswordViewController = RecoverPasswordViewController()
        self.present(UINavigationController(rootViewController: recoverPasswordViewController), animated: true)
    }
    
    func validateText(_ textfield: DineTextField) -> DineTextInputError? {
        guard let text = textfield.inputText else { return nil }
        
        if textfield == usernameDineTextField {
            guard !text.isEmpty else { return nil }
            if !AuthenticationValidator.isValidUsername(text) {
                return DineTextInputError(localizedDescription: "Username must be 3-20 characters, only letters, numbers, and underscores.")
            }
        }
        
        if textfield == passwordDineTextField {
            guard !text.isEmpty else { return nil }
            
            if !AuthenticationValidator.isStrongPassword(text) {
                return DineTextInputError(localizedDescription: "Password must be 8+ characters, with letters, numbers, and special characters.")
            }
        }
        
        return nil
    }
    
    let usernameDineTextField: DineTextField = {
        let field = DineTextField()
        field.keyboardType = .emailAddress
        field.titleText = "Username"
        field.placeholder = "e.g. John Dean"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let passwordDineTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Password"
        field.textfield.isSecureTextEntry = true
        field.placeholder = "Your secure password"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    func onEditingChanged(_ textfield: DineTextField) {
        textfield.error = validateText(textfield)
    }
    
    func validateUsername(_ username: String) -> Bool {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let authController = AuthController(databaseAccess: databaseAccess)
            return authController.isUserPresent(username: username)
        } catch {
            return false
        }
    }
}

#Preview {
    UINavigationController(rootViewController: LoginViewController())
}
