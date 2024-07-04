//
//  BillDetailViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 17/06/24.
//

import UIKit
import Toast

class BillDetailViewController: UIViewController {
    
    private let bill: Bill
    
    private var scrollView: UIScrollView!
    /// View to hold the scrollable content
    private var scrollContentView: UIView!
    
    // StackView that holds info about bill
    private var verticalStackView: UIStackView!
    
    // Stack view that holds button at the bottom of the screen
    private var horizontalStackView: UIStackView!
    
    private var paymentButton: UIButton! // Button for payment action
    private var deleteButton: UIButton! // Button for delete action
    
    init(bill: Bill) {
        self.bill = bill
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Bill"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        setupScrollView()
        setupVStackView()
        setupButtonHStackView()
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollContentView = UIView()
        
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        // Set up constraints for the UIScrollView to match the view's size
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
    
    private func setupVStackView() {
        verticalStackView = UIStackView()
        verticalStackView.layer.cornerRadius = 16
        verticalStackView.layer.masksToBounds = true
        verticalStackView.backgroundColor = .secondarySystemGroupedBackground
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let amountInfoView = TitleAndDescriptionView()
        let tipInfoView = TitleAndDescriptionView()
        let taxInfoView = TitleAndDescriptionView()
        let dateInfoView = TitleAndDescriptionView()
        let billIdInfoView = TitleAndDescriptionView()
        let orderIdInfoView = TitleAndDescriptionView()
        let paymentStatusInfoView = TitleAndDescriptionView()
        
        amountInfoView.configureView(title: "Amount", description: "$\(bill.getTotalAmount.rounded())")
        tipInfoView.configureView(title: "Tip", description: "$\(bill.getTip.rounded())")
        taxInfoView.configureView(title: "Tax", description: "$\(bill.getTax.rounded())")
        dateInfoView.configureView(title: "Date", description: bill.date.formattedDateString())
        billIdInfoView.configureView(title: "Bill ID", description: bill.billId.uuidString)
        orderIdInfoView.configureView(title: "Order ID", description: bill.getOrderId.uuidString)
        paymentStatusInfoView.configureView(title: "Payment Status", description: bill.paymentStatus.rawValue)
        
        scrollContentView.addSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(amountInfoView)
        verticalStackView.addArrangedSubview(tipInfoView)
        verticalStackView.addArrangedSubview(taxInfoView)
        verticalStackView.addArrangedSubview(dateInfoView)
        verticalStackView.addArrangedSubview(billIdInfoView)
        verticalStackView.addArrangedSubview(orderIdInfoView)
        verticalStackView.addArrangedSubview(paymentStatusInfoView)
        
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            verticalStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 20)
        ])
    }
    
    private func setupButtonHStackView() {
        horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 12
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.addSubview(horizontalStackView)
        
        paymentButton = UIButton()
        paymentButton.setTitle("Pay*", for: .normal)
        paymentButton.setTitleColor(.label, for: .normal)
        paymentButton.backgroundColor = .secondarySystemGroupedBackground
        paymentButton.layer.cornerRadius = 12
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        paymentButton.addTarget(self, action: #selector(paymentButtonAction(_:)), for: .touchUpInside)
        
        deleteButton = UIButton()
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.backgroundColor = .secondarySystemGroupedBackground
        deleteButton.layer.cornerRadius = 14
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        
        horizontalStackView.addArrangedSubview(deleteButton)
        horizontalStackView.addArrangedSubview(paymentButton)
        
        NSLayoutConstraint.activate([
            horizontalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            horizontalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            horizontalStackView.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 20),
            horizontalStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor)
        ])
    }
    
    @objc private func paymentButtonAction(_ sender: UIButton) {
        print(#function)
        let toast = Toast.text("Not functional!")
        toast.show(haptic: .warning)
    }
    
    @objc private func deleteAction(_ sender: UIButton) {
        print(#function)
        do {
            let databaseAccess  = try SQLiteDataAccess.openDatabase()
            let billService = BillServiceImpl(databaseAccess: databaseAccess)
            try billService.delete(bill)
            let toast = Toast.text("Bill Deleted!")
            toast.show(haptic: .success)
            NotificationCenter.default.post(name: .billDidChangeNotification, object: nil)
            // Pop the current view controller
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to perform \(#function) - \(error)")
            fatalError("Failed to perform \(#function) - \(error)")
        }
    }
}
