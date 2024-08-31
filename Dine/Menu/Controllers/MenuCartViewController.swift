//
//  MenuCartViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 28/08/24.
//

import UIKit
import Combine

class MenuCartViewController: UIViewController {

    private let viewModal: CartViewModel

    private let reuseIdentifier = "cell"
    private var tableView: UITableView!
    private var bottomSheetView: UIView!
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModal: CartViewModel) {
        self.viewModal = viewModal
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"
        view.backgroundColor = .systemGroupedBackground
        setupBottomSheet()
        setupTableView()
        bindViewModal()
    }
    
    private func bindViewModal() {
        viewModal.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupBottomSheet() {
        bottomSheetView = UIView()
        bottomSheetView.backgroundColor = .secondarySystemGroupedBackground
        bottomSheetView.layer.cornerRadius = 18
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        view.addSubview(bottomSheetView)
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Select table"
        configuration.buttonSize = .large
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = .app
        configuration.baseForegroundColor = .white
        
        let proceedButton = UIButton(configuration: configuration, primaryAction: didTapProceedButton())
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        
        let infoLabel = UILabel()
        infoLabel.text = "Where do you want to deliver this order?"
        infoLabel.textColor = .label
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = .boldSystemFont(ofSize: 17)
        
        let locationIconImageView = UIImageView()
        locationIconImageView.image = UIImage(systemName: "location.fill")
        locationIconImageView.tintColor = .app
        locationIconImageView.contentMode = .scaleAspectFit
        locationIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let textStactView = UIStackView(arrangedSubviews: [locationIconImageView, infoLabel])
        textStactView.axis = .horizontal
        textStactView.spacing = 8
        textStactView.alignment = .firstBaseline
        textStactView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerStackView = UIStackView(arrangedSubviews: [textStactView, proceedButton])
        containerStackView.axis = .vertical
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.spacing = 14
        
        bottomSheetView.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerStackView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            containerStackView.widthAnchor.constraint(equalTo: bottomSheetView.widthAnchor, multiplier: 0.9),
            containerStackView.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 20),
            containerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func showNoTablesAlert() {
        let alert = UIAlertController(
            title: "No Tables Available",
            message: "Please reach out to your admin or manager for assistance.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    private func didTapProceedButton() -> UIAction? {
        let cart = viewModal.cart
        return UIAction { [weak self] _ in
            print(#function)
            let chooseTableVC = ChooseTableViewController(selectedMenuItems: cart)
            if chooseTableVC.isTablesAvailable() {
                self?.navigationController?.pushViewController(chooseTableVC, animated: true)
            } else {
                self?.showNoTablesAlert()
            }
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomSheetView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension MenuCartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Cart"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModal.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let item = viewModal.items[indexPath.row]
        
        /*let stepper = UIStepper()
        stepper.value = Double(item.quantity)
        stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
        stepper.minimumValue = 1
        stepper.tag = indexPath.row*/
        // Create a UILabel
        let accessoryLabel = UILabel()
        let count = String(item.quantity)
        accessoryLabel.text = "x\(count)"
        accessoryLabel.textColor = .label
        accessoryLabel.font = .preferredFont(forTextStyle: .body)
        accessoryLabel.sizeToFit()
        cell.accessoryView = accessoryLabel
        
        var content = cell.defaultContentConfiguration()
        content.text = item.menuItemName
        cell.contentConfiguration = content
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    @objc private func stepperValueChanged(_ sender: UIStepper) {
        let row = sender.tag
        let newQuantity = Int(sender.value)
        let item = viewModal.items[row]
        
        viewModal.updateQuantity(for: item.menuItem, by: newQuantity)
    }
}
