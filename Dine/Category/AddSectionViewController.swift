//
//  AddSectionViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/06/24.
//

import UIKit
import Toast

class AddSectionViewController: UIViewController {
    
    private var toast: Toast!
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /*private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Section"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()*/
    
    let categoryDineTextField: DineTextField = {
        let field = DineTextField()
        field.titleText = "Category"
        field.placeholder = "e.g. Appetizers"
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
        view.backgroundColor = .systemGroupedBackground
        title = "Add Section"
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        setupScrollView()
        navigationController?.navigationBar.prefersLargeTitles = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setupSubviews()
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
        guard let categoryName = categoryDineTextField.inputText,
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
        verticalStackView.addArrangedSubview(categoryDineTextField)
        verticalStackView.addArrangedSubview(addButton)
        verticalStackView.setCustomSpacing(34, after: categoryDineTextField)
        
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            verticalStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 40),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 55),
        ])
    }
}

#Preview {
    UINavigationController(rootViewController: AddSectionViewController())
}
