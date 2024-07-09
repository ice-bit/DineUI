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
    private var scrollContentViewBottomConstraint: NSLayoutConstraint!
    
    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome Back!"
        label.font = .preferredFont(forTextStyle: .extraLargeTitle)
        label.numberOfLines = 0
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
        return textField
    }()

    private lazy var passwordTextField: UITextField = {
        let textField = DTextField()
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(loginButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var forgotPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Forgot Password?"
        label.textAlignment = .right
        label.font = .preferredFont(forTextStyle: .footnote)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account? Sign Up"
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
        navigationController?.navigationBar.prefersLargeTitles = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        fetchAccounts()
        
        // Keyboard notification listeners
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        print("Keyboard height: \(keyboardFrame.cgRectValue.height)")
        let keyboardHeight = keyboardFrame.cgRectValue.height
        scrollContentViewBottomConstraint.constant = -keyboardHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollContentViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollContentView = UIView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the bottom constraint for scrollContentView
        scrollContentViewBottomConstraint = scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollContentViewBottomConstraint,
            
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupPasswordVisibiltyToggle() {
        toggleButton = UIButton(type: .custom)
        // Configure the toggle button
        toggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        toggleButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        // Add the button to the right view of the text field
        passwordTextField.rightView = toggleButton
        passwordTextField.rightViewMode = .always
    }
    
    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let buttonImageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
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
        guard let username = usernameTextField.text,
              let password = passwordTextField.text,
            !password.isEmpty,
              !username.isEmpty else {
            showToast(message: "Missing Credentials")
            return
        } // Enable shake if text field is empty
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
        verticalStackView.addArrangedSubview(introLabel)
        verticalStackView.addArrangedSubview(usernameTextField)
        verticalStackView.addArrangedSubview(passwordTextField)
        verticalStackView.addArrangedSubview(forgotPasswordLabel)
        verticalStackView.addArrangedSubview(loginButton)
        verticalStackView.addArrangedSubview(signUpLabel)

        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.8),
            verticalStackView.topAnchor.constraint(lessThanOrEqualTo: scrollContentView.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),

            usernameTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            forgotPasswordLabel.heightAnchor.constraint(equalToConstant: 14),
            loginButton.heightAnchor.constraint(equalToConstant: 55),
            signUpLabel.heightAnchor.constraint(equalToConstant: 14),
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
    
}

#Preview {
    LoginViewController()
}
