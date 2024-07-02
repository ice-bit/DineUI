//
//  AddTablesViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 16/05/24.
//

import UIKit
import Toast

class AddTablesViewController: UIViewController {
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Table"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var locationIdTextField: UITextField = {
        let textField = DTextField()
        textField.placeholder = "Location Identifier"
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var capacityTextField: UITextField = {
        let textField = DTextField()
        textField.placeholder = "Capacity"
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Table", for: .normal)
        button.setTitleColor(.black, for: .normal)
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
        navigationController?.navigationBar.prefersLargeTitles = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setupSubviews()
    }
    
    @objc private func addButtonAction(_ sender: UIButton) {
        print(#function)
        guard let locationIdText = locationIdTextField.text,
              let maxCapacityText = capacityTextField.text else {
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
    
    private func setupSubviews() {
        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(locationIdTextField)
        verticalStackView.addArrangedSubview(capacityTextField)
        verticalStackView.addArrangedSubview(addButton)

        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

            locationIdTextField.heightAnchor.constraint(equalToConstant: 44),
            capacityTextField.heightAnchor.constraint(equalToConstant: 44),
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
        let toast = Toast.text(message)
        toast.show(haptic: .error)
    }
}
