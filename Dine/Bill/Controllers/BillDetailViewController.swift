//
//  BillDetailViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 17/06/24.
//

import UIKit

class BillDetailViewController: UIViewController {
    
    private let bill: Bill
    
    private var scrollView: UIScrollView!
    /// View to hold the scrollable content
    private var contentView: UIView!
    
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
        view.backgroundColor = .systemBackground
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
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Set up constraints for the UIScrollView to match the view's size
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup content view
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Due to referring to tableView and stackView before initializing, the app crashes!
        /*let totalSubviewHeight: CGFloat = tableView.frame.height + cardStackView.frame.height
        var contentViewHeight: CGFloat = view.frame.height
        
        if totalSubviewHeight > contentViewHeight {
            contentViewHeight = view.frame.height + totalSubviewHeight + 100 // 100 is the extra offset ignoring the spacing between the subviews.
        }*/
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Set the width and height constraints for the content view
            // These constraints define the scrollable area
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 1000) // Set a height to make the content scrollable
        ])
    }
    
    private func setupVStackView() {
        verticalStackView = UIStackView()
        verticalStackView.layer.cornerRadius = 16
        verticalStackView.layer.masksToBounds = true
        verticalStackView.backgroundColor = .app
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
        
        contentView.addSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(amountInfoView)
        verticalStackView.addArrangedSubview(tipInfoView)
        verticalStackView.addArrangedSubview(taxInfoView)
        verticalStackView.addArrangedSubview(dateInfoView)
        verticalStackView.addArrangedSubview(billIdInfoView)
        verticalStackView.addArrangedSubview(orderIdInfoView)
        verticalStackView.addArrangedSubview(paymentStatusInfoView)
        
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.88),
            verticalStackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func setupButtonHStackView() {
        horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 12
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(horizontalStackView)
        
        paymentButton = UIButton()
        paymentButton.setTitle("Pay", for: .normal)
        paymentButton.setTitleColor(.systemBackground, for: .normal)
        // billButton.setTitleColor(.lightGray, for: .disabled)
        paymentButton.backgroundColor = .label
        paymentButton.layer.cornerRadius = 12
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        paymentButton.addTarget(self, action: #selector(paymentButtonAction(_:)), for: .touchUpInside)
        horizontalStackView.addArrangedSubview(paymentButton)
        
        deleteButton = UIButton()
        deleteButton.setTitle("Edit", for: .normal)
        deleteButton.setTitleColor(.systemBackground, for: .normal)
        deleteButton.backgroundColor = .label
        deleteButton.layer.cornerRadius = 14
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        horizontalStackView.addArrangedSubview(deleteButton)
 
        NSLayoutConstraint.activate([
            horizontalStackView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            horizontalStackView.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.88),
            horizontalStackView.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 20),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    @objc private func paymentButtonAction(_ sender: UIButton) {
        print(#function)
    }
    
    @objc private func deleteAction(_ sender: UIButton) {
        print(#function)
    }
}
