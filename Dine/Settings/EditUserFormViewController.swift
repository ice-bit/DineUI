//
//  EditUserFormViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 08/08/24.
//

import UIKit
import LocalAuthentication
import Toast

class EditUserFormViewController: UIViewController {
    
    private let account: Account
    private var toast: Toast!
    
    private var activeTextField: DineTextField?
    
    private var toggleButton: UIButton!
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var editButton: UIBarButtonItem!
    private var selectedUserRole: UserRole? {
        didSet {
            if let selectedUserRole {
                dinePicker.text = selectedUserRole.rawValue
            }
        }
    }
    var onDidEditUser: ((Account) -> Void)?
    
    private var inEditMode: Bool = false {
        didSet {
            didChangeEditMode()
        }
    }
    
    /// An authentication context stored at class scope so it's available for use during UI updates.
    var context = LAContext()
    
    private var state: AuthenticationState = .unauthenticated {
        didSet {
            switch state {
            case .authenticated:
                inEditMode = true
            case .unauthenticated:
                inEditMode = false
            }
        }
    }
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
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
    
    enum AuthenticationState {
        case authenticated, unauthenticated
    }
    
    init(account: Account) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        
        setupScrollView()
        setupSubviews()
        setupPasswordVisibiltyToggle()
        setupForgetLabelGesture()
        fetchAccounts()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
        setupPicker()
        setupNavigationBar()
        
        configTextFieldDelegates()
        
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
    
    private func configTextFieldDelegates() {
        usernameDineTextField.inputText = account.username
        passwordDineTextField.inputText = account.password
        selectedUserRole = account.userRole
        
        usernameDineTextField.onEditingChanged = textFieldDidChangeEditing
        passwordDineTextField.onEditingChanged = textFieldDidChangeEditing
        
        usernameDineTextField.onDidBeginEditing = textFieldDidBeginEditing
        passwordDineTextField.onDidBeginEditing = textFieldDidBeginEditing
        
        usernameDineTextField.onDidEndEditing = textFieldDidEndEditing
        passwordDineTextField.onDidEndEditing = textFieldDidEndEditing
        
        usernameDineTextField.onShouldEndEditing = textFieldShouldEndEditing
        passwordDineTextField.onShouldEndEditing = textFieldShouldEndEditing
        
        usernameDineTextField.onReturn = textFieldShouldReturn
        passwordDineTextField.onReturn = textFieldShouldReturn
    }
    
    private func setupNavigationBar() {
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonAction))
        navigationItem.rightBarButtonItem = editButton
    }
    
    @objc private func editButtonAction() {
        if state == .authenticated {
            // Set to unauthenticated state
            state = .unauthenticated
        } else {
            context = LAContext()
            
            context.localizedCancelTitle = "Enter Passcode"
            // First check if we have the needed hardware support.
            var error: NSError?
            guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
                print(error?.localizedDescription ?? "Can't evaluate policy")

                // Fall back to a asking for username and password.
                // ...
                return
            }
            Task {
                do {
                    try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in to your account")
                    state = .authenticated
                } catch let error {
                    print(error.localizedDescription)

                    // Fall back to a asking for username and password.
                    // ...
                }
            }
        }
    }
    
    private func didChangeEditMode() {
        if inEditMode {
            saveButton.isHidden = false
            usernameDineTextField.textfield.isUserInteractionEnabled = true
            usernameDineTextField.textfield.becomeFirstResponder()
            usernameDineTextField.textfield.rightView?.isHidden = false
            passwordDineTextField.textfield.rightView?.isHidden = false
            passwordDineTextField.textfield.isUserInteractionEnabled = true
            dinePicker.trailingPickerButton.isHidden = false
            editButton.title = "Cancel"
        } else {
            saveButton.isHidden = true
            usernameDineTextField.textfield.isUserInteractionEnabled = false
            usernameDineTextField.textfield.rightView?.isHidden = true
            passwordDineTextField.textfield.rightView?.isHidden = true
            passwordDineTextField.textfield.isUserInteractionEnabled = false
            dinePicker.trailingPickerButton.isHidden = true
            editButton.title = "Edit"
            usernameDineTextField.inputText = account.username
            passwordDineTextField.inputText = account.password
            dinePicker.text = account.userRole.rawValue
            activeTextField?.textfield.resignFirstResponder()
        }
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
    
    private func showToast(_ message: String) {
        if let toast {
            toast.close(animated: false)
        }
        toast = Toast.text(message)
        toast.show(haptic: .warning)
    }
    
    @objc private func saveButtonAction(_ sender: UIButton) {
        print(#function)
        guard let username = usernameDineTextField.inputText,
              let password = passwordDineTextField.inputText,
              let userRole = selectedUserRole,
              !password.isEmpty,
              !username.isEmpty else {
            showToast("Missing Credentials")
            return
        }
        
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let accountService = AccountServiceImpl(databaseAccess: databaseAccess)
            let resultAccounts = try accountService.fetch()
            if let resultAccounts {
                if let user = resultAccounts.first(where: { $0.username == username }) {
                    if !(user.username == account.username) {
                        showToast("Username already taken")
                        return
                    }
                }
            }
            account.updateUsername(username)
            account.updatePassword(password)
            account.updateRole(userRole)
            try accountService.update(account)
            // inform the changes
            onDidEditUser?(account)
            // change the authentication state (face id)
            state = .unauthenticated
            // show toast for visual indication
            showSuccessToast("User credentials updated")
        } catch {
            fatalError("Failed to update credentials: \(error.localizedDescription)")
        }
    }
    
    private func showSuccessToast(_ message: String) {
        if let toast {
            toast.close(animated: false)
        }
        toast = Toast.text(message)
        toast.show(haptic: .success)
    }
    
    private func isUserAvaialable(_ username: String) -> Bool {
        guard !(username == account.username) else {
            return false
        }
        do {
            let dbAccess = try SQLiteDataAccess.openDatabase()
            let accountService = AccountServiceImpl(databaseAccess: dbAccess)
            let account = try accountService.fetch()
            if let account {
                if account.first(where: { $0.username == username }) != nil {
                    return true // true since there is some user associated with this username
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

    private func setupSubviews() {
        scrollContentView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(usernameDineTextField)
        verticalStackView.addArrangedSubview(passwordDineTextField)
        verticalStackView.addArrangedSubview(dinePicker)
        verticalStackView.addArrangedSubview(saveButton)
        
        // Custom spacing
        verticalStackView.setCustomSpacing(20, after: forgotPasswordLabel)
        
        
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            verticalStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 20),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 55),
        ])
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
            if isUserAvaialable(text) {
                return DineTextInputError(localizedDescription: "Username is already taken.")
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
        field.textfield.isUserInteractionEnabled = false
        field.placeholder = "e.g. John Dean"
        field.textfield.returnKeyType = .next
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let passwordDineTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Password"
        field.textfield.isUserInteractionEnabled = false
        field.textfield.isSecureTextEntry = true
        field.placeholder = "Set New Password"
        field.textfield.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let dinePicker: DineUserSelector = {
        let picker = DineUserSelector()
        picker.trailingPickerButton.isHidden = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private func animateErrorMessage(for textField: DineTextField) {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension EditUserFormViewController {
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
        if let validator = validateText(textField) {
            textField.error = validator
            animateErrorMessage(for: textField)
            return false
        } else {
            return true
        }
    }
    
    private func textFieldShouldReturn(_ textField: DineTextField) -> Bool {
        if textField == usernameDineTextField {
            passwordDineTextField.textfield.becomeFirstResponder()
        } else if textField == passwordDineTextField {
            passwordDineTextField.textfield.resignFirstResponder()
        }
        return true
    }
}

#Preview {
    UINavigationController(rootViewController: EditUserFormViewController(account: .default))
}
