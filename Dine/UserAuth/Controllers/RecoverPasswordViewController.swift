//
//  RecoverPasswordViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/06/24.
//

import UIKit
import Toast

class RecoverPasswordViewController: UIViewController {
    
    private var doneBarButton: UIBarButtonItem!
    // private var cancelBarButton: UIBarButtonItem!
    
    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter Username"
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
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = DTextField()
        textField.backgroundColor = .secondarySystemBackground
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        return textField
    }()
    
    private lazy var userCheckButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(userCheckButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var changePasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(changePasswordButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        isModalInPresentation = true
        view.backgroundColor = .systemBackground
        title = "Reset Password"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        
        setupBarButton()
        setupSubviews()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupBarButton() {
        doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction(_:)))
        navigationItem.rightBarButtonItem = doneBarButton
        // cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: cancelButtonAction(_:))
    }
    
    @objc private func doneButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    // @objc private func cancelButtonAction(_ sender: UIBarButtonItem) {}
    
    @objc private func userCheckButtonAction(_ sender: UIButton) {
        print(#function)
        
        if isUserAvailable() {
            verticalStackView.addArrangedSubview(passwordTextField)
            verticalStackView.addArrangedSubview(changePasswordButton)
            // verticalStackView.removeArrangedSubview(userCheckButton)
            userCheckButton.isHidden = true
        } else {
            handleLoginError(.noUserFound)
        }
    }
    
    @objc private func changePasswordButtonAction(_ sender: UIButton) {
        print(#function)
        guard let username = usernameTextField.text,
              let password = passwordTextField.text,
            !password.isEmpty,
            !username.isEmpty else { return } // Enable shake if text field is empty
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let accountService = AccountServiceImpl(databaseAccess: databaseAccess)
            let adminController = AdminController(accountService: accountService)
            try adminController.changePassword(for: username, to: password)
            
            self.dismiss(animated: true)
            
            let toast = Toast.default(image: UIImage(systemName: "checkmark")!, title: "Password Changed")
            toast.show(haptic: .success)
        }  catch let error as AuthenticationError {
            handleLoginError(error)
        } catch {
            handleLoginError(.other(error))
        }
    }
    
    private func isUserAvailable() -> Bool {
        guard let username = usernameTextField.text,
            !username.isEmpty else { return false } // Enable shake if text field is empty
        
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let authController = AuthController(databaseAccess: databaseAccess)
            if authController.isUserPresent(username: username) {
                return true
            } else {
                return false
            }
        }  catch let error as AuthenticationError {
            handleLoginError(error)
        } catch {
            handleLoginError(.other(error))
        }
        
        return false
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
        case .incorretPassword:
            showToast(message: "Incorrect password")
        case .notStrongPassword:
            showToast(message: "Provide a strong password")
        }
    }

    func showToast(message: String) {
        let toast = Toast.default(image: UIImage(systemName: "exclamationmark.triangle.fill")!, title: message)
        toast.show(haptic: .error)
    }
    
    private func setupSubviews() {
        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(introLabel)
        verticalStackView.addArrangedSubview(usernameTextField)
        verticalStackView.addArrangedSubview(userCheckButton)
        
        verticalStackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            verticalStackView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0.2),
            verticalStackView.bottomAnchor.constraint(greaterThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -300),

            usernameTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            userCheckButton.heightAnchor.constraint(equalToConstant: 44),
            changePasswordButton.heightAnchor.constraint(equalToConstant: 44),
            
        ])
    }

}

#Preview {
    RecoverPasswordViewController()
}
