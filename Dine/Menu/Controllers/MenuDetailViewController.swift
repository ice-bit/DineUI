//
//  MenuDetailViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 10/05/24.
//

import UIKit

class MenuDetailViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    
    private var menu: MenuItem
    
    private var itemImageView: UIImageView!
    private var nameTag: UILabel!
    private var priceTag: UILabel!
    private var staticAboutTag: UILabel!
    private var descriptionTag: UILabel!
    
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
        navigationController?.navigationBar.prefersLargeTitles = true
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
        configureContents()
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
    
    private func setupNavbar() {
        let editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonAction(_:)))
        navigationItem.rightBarButtonItem = editBarButton
    }
    
    @objc private func editButtonAction(_ sender: UIBarButtonItem) {
        let editViewController = ItemFormViewController(menuItem: menu)
        editViewController.menuItemDelegate = self
        self.present(UINavigationController(rootViewController: editViewController), animated: true)
        
    }
    
    private func setupMenuImage() {
        itemImageView = UIImageView()
        Task {
            itemImageView.image = await menu.renderedImage
        }
        itemImageView.layer.cornerRadius = 14
        itemImageView.clipsToBounds = true
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.addSubview(itemImageView)
    }
    
    private func setupItemTitle() {
        nameTag = UILabel()
        nameTag.text = menu.name
        nameTag.numberOfLines = 2
        nameTag.textAlignment = .center
        nameTag.font = .systemFont(ofSize: 28, weight: .bold)
        nameTag.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.addSubview(nameTag)
    }
    
    private func setupPriceLabel() {
        priceTag = UILabel()
        priceTag.text = "$\(String(menu.price))"
        priceTag.font = .systemFont(ofSize: 20)
        priceTag.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.addSubview(priceTag)
    }
    
    private func setupAboutTag() {
        staticAboutTag = UILabel()
        staticAboutTag.text = "About"
        staticAboutTag.font = .systemFont(ofSize: 19, weight: .semibold)
        staticAboutTag.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.addSubview(staticAboutTag)
    }
    
    private func setupDescriptionTag() {
        descriptionTag = UILabel()
        descriptionTag.numberOfLines = 0
        descriptionTag.textAlignment = .center
        descriptionTag.text = menu.description
        descriptionTag.font = .systemFont(ofSize: 16)
        descriptionTag.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.addSubview(descriptionTag)
    }
    
    private func configureContents() {
        scrollContentView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(itemImageView)
        horizontalStackView.addArrangedSubview(nameTag)
        horizontalStackView.addArrangedSubview(priceTag)
        horizontalStackView.addArrangedSubview(staticAboutTag)
        horizontalStackView.addArrangedSubview(descriptionTag)
        
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 20),
            horizontalStackView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.88),
            horizontalStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20),
            horizontalStackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            itemImageView.heightAnchor.constraint(equalToConstant: 150),
            itemImageView.widthAnchor.constraint(equalToConstant: 150),
        ])
    }
    
    private lazy var horizontalStackView: UIStackView = {
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .vertical
        horizontalStackView.distribution = .fill
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 8
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        return horizontalStackView
    }()
    
}

extension MenuDetailViewController: MenuItemDelegate {
    func menuDidChange(_ item: MenuItem) {
        itemImageView.image = item.image
        nameTag.text = item.name
        priceTag.text = String(item.price)
        descriptionTag.text = item.description
    }
}

#Preview {
    let menu = MenuItem(name: "Chicken", price: 8.99, category: MenuCategory(id: UUID(), categoryName: "Main Course"), description: "dewirgbvhsevfygv fgeru gefgvegv gdsv suvgjsdbhv vbsfjv gsdihvg sydvb dsvjgvcsgv hsdvcjhsdv vbsdgvhdsbv vcshkvhd b")
    return UINavigationController(rootViewController: MenuDetailViewController(menu: menu))
}
