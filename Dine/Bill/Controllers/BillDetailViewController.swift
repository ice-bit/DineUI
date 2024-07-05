//
//  BillDetailViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 17/06/24.
//

import UIKit
import Toast

class BillDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let bill: Bill
    private var toast: Toast!
    
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var verticalStackView: UIStackView!
    private var horizontalStackView: UIStackView!
    private var paymentButton: UIButton!
    private var deleteButton: UIButton!
    
    // MARK: - Initialization
    
    init(bill: Bill) {
        self.bill = bill
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupSubviews()
    }
    
    // MARK: - Setup Methods
    
    private func setupViewController() {
        view.backgroundColor = .systemGroupedBackground
        title = "Bill"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupSubviews() {
        setupScrollView()
        setupVerticalStackView()
        setupHorizontalStackView()
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
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollContentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
    
    private func setupVerticalStackView() {
        verticalStackView = createVerticalStackView()
        
        let amountInfoView = createInfoView(title: "Amount", description: "$\(bill.getTotalAmount.rounded())")
        let tipInfoView = createInfoView(title: "Tip", description: "$\(bill.getTip.rounded())")
        let taxInfoView = createInfoView(title: "Tax", description: "$\(bill.getTax.rounded())")
        let dateInfoView = createInfoView(title: "Date", description: bill.date.formattedDateString())
        let billIdInfoView = createInfoView(title: "Bill ID", description: bill.billId.uuidString)
        let orderIdInfoView = createInfoView(title: "Order ID", description: bill.getOrderId.uuidString)
        let paymentStatusInfoView = createInfoView(title: "Payment Status", description: bill.paymentStatus.rawValue)
        
        verticalStackView.addArrangedSubview(amountInfoView)
        verticalStackView.addArrangedSubview(tipInfoView)
        verticalStackView.addArrangedSubview(taxInfoView)
        verticalStackView.addArrangedSubview(dateInfoView)
        verticalStackView.addArrangedSubview(billIdInfoView)
        verticalStackView.addArrangedSubview(orderIdInfoView)
        verticalStackView.addArrangedSubview(paymentStatusInfoView)
        
        scrollContentView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            verticalStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 20)
        ])
    }
    
    private func setupHorizontalStackView() {
        horizontalStackView = createHorizontalStackView()
        
        let paymentAction = UIAction { [weak self] _ in
            self?.showErrorToast()
        }
        
        let deleteAction = UIAction { [weak self] _ in
            self?.deleteBill()
        }
        
        paymentButton = createCustomButton(title: "Payment", type: .normal, primaryAction: paymentAction)
        deleteButton = createCustomButton(title: "Delete", type: .destructive, primaryAction: deleteAction)
        
        horizontalStackView.addArrangedSubview(deleteButton)
        horizontalStackView.addArrangedSubview(paymentButton)
        
        scrollContentView.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            horizontalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            horizontalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            horizontalStackView.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 20),
            horizontalStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func createVerticalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.layer.cornerRadius = 16
        stackView.layer.masksToBounds = true
        stackView.backgroundColor = .secondarySystemGroupedBackground
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func createHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func createInfoView(title: String, description: String) -> TitleAndDescriptionView {
        let infoView = TitleAndDescriptionView()
        infoView.configureView(title: title, description: description)
        return infoView
    }
    
    private func createCustomButton(title: String, type: CustomButtonType, primaryAction: UIAction? = nil) -> UIButton {
        var config = UIButton.Configuration.gray()
        config.cornerStyle = .large
        config.buttonSize = .large
        config.title = title
        config.baseBackgroundColor = .secondarySystemGroupedBackground
        
        switch type {
        case .normal:
            config.baseForegroundColor = .tintColor
        case .destructive:
            config.baseForegroundColor = .red
        }
        
        return UIButton(configuration: config, primaryAction: primaryAction)
    }
    
    private func showErrorToast() {
        if let toast = toast {
            toast.close(animated: false)
        }
        toast = Toast.text("Not functional!")
        toast.show(haptic: .warning)
    }
    
    private func deleteBill() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let billService = BillServiceImpl(databaseAccess: databaseAccess)
            try billService.delete(bill)
            let toast = Toast.text("Bill Deleted!")
            toast.show(haptic: .success)
            NotificationCenter.default.post(name: .billDidChangeNotification, object: nil)
            navigationController?.popViewController(animated: true)
        } catch {
            let toast = Toast.text("Failed to delete bill: \(error.localizedDescription)")
            toast.show(haptic: .error)
        }
    }
}


