//
//  MenuDetailViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 10/05/24.
//

import UIKit

class MenuDetailViewController: UIViewController {
    
    private let menu: MenuItem
    
    private var itemImageView: UIImageView!
    private var nameTag: UILabel!
    private var priceTag: UILabel!
    private var staticAboutTag: UILabel!
    private var descriptionTag: UILabel!
    private var scrollView: UIScrollView!
//    private var addButton:
    
    init(menu: MenuItem) {
        self.menu = menu
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Item"
        setupNavbar()
        setupSubview()
        configView()
    }
    
    private func configView() {
        view.backgroundColor = /*UIColor(named: "primaryBgColor")*/.systemBackground
    }
    
    private func setupSubview() {
        setupScrollView()
        view.addSubview(scrollView)
        setupMenuImage()
        setupItemTitle()
        setupPriceLabel()
        setupAboutTag()
        setupDescriptionTag()
        setupConstraints()
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 1500),
        ])
    }
    
    private func setupNavbar() {
        let editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonAction(_:)))
        navigationItem.rightBarButtonItem = editBarButton
    }
    
    @objc private func editButtonAction(_ sender: UIBarButtonItem) {
        
    }
    
    private func setupMenuImage() {
        itemImageView = UIImageView()
        itemImageView.image = UIImage(named: "burger")
        itemImageView.layer.cornerRadius = 14
        itemImageView.clipsToBounds = true
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(itemImageView)
    }
    
    private func setupItemTitle() {
        nameTag = UILabel()
        nameTag.text = menu.name
        nameTag.numberOfLines = 2
        nameTag.textAlignment = .center
        nameTag.font = .systemFont(ofSize: 28, weight: .bold)
        nameTag.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(nameTag)
    }
    
    private func setupPriceLabel() {
        priceTag = UILabel()
        priceTag.text = "$\(String(menu.price))"
        priceTag.font = .systemFont(ofSize: 20)
        priceTag.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(priceTag)
    }
    
    private func setupAboutTag() {
        staticAboutTag = UILabel()
        staticAboutTag.text = "About"
        staticAboutTag.font = .systemFont(ofSize: 19, weight: .semibold)
        staticAboutTag.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(staticAboutTag)
    }
    
    private func setupDescriptionTag() {
        descriptionTag = UILabel()
        descriptionTag.numberOfLines = 0
        descriptionTag.textAlignment = .center
        descriptionTag.text = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
        """
        descriptionTag.font = .systemFont(ofSize: 16)
        descriptionTag.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(descriptionTag)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            itemImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            itemImageView.heightAnchor.constraint(equalToConstant: 241),
            itemImageView.widthAnchor.constraint(equalToConstant: 241),
            itemImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            nameTag.topAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: 12),
            nameTag.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTag.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            
            priceTag.topAnchor.constraint(equalTo: nameTag.bottomAnchor, constant: 8),
            priceTag.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            staticAboutTag.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            staticAboutTag.topAnchor.constraint(equalTo: priceTag.bottomAnchor, constant: 8),
            
            descriptionTag.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionTag.topAnchor.constraint(equalTo: staticAboutTag.bottomAnchor, constant: 8),
            descriptionTag.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
        ])
    }
    
}
