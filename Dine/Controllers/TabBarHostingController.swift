//
//  ViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

/// file:///Users/doss-zstch1212/Library/Developer/CoreSimulator/Devices/577868CC-D185-4E22-A9D5-8CC5C04C3B10/data/Containers/Data/Application/A4E807C9-9E80-46D3-8B57-7B14A23B5E6A/Documents/dine.sqlite

import UIKit

class TabBarHostingController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabBar()
    }
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupTabBar() {
        guard let databaseAccess = try? SQLiteDataAccess.openDatabase() else {
            print("Failed to open database connection")
            return
        }
        let orderService = OrderServiceImpl(databaseAccess: databaseAccess)
        let menuService = MenuServiceImpl(databaseAccess: databaseAccess)
        
        let orderViewController = OrderViewController(orderService: orderService, menuService: menuService)
        orderViewController.tabBarItem = UITabBarItem(title: "Orders", image: UIImage(systemName: "cart"), selectedImage: UIImage(systemName: "cart.fill"))
        let billViewController = BillViewController()
        billViewController.tabBarItem = UITabBarItem(title: "Bills", image: UIImage(systemName: "newspaper"), selectedImage: UIImage(systemName: "newspaper.fill"))
        let tableViewController = TablesViewController()
        tableViewController.tabBarItem = UITabBarItem(title: "Tables", image: UIImage(systemName: "table.furniture"), selectedImage: UIImage(systemName: "table.furniture.fill"))
        
        let menuViewController = MenuViewController(menuService: menuService)
        menuViewController.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(systemName: "menucard"), selectedImage: UIImage(systemName: "menucard.fill"))
        
        let orderNavigationController = UINavigationController(rootViewController: orderViewController)
        let billNavigationController = UINavigationController(rootViewController: billViewController)
        let tableNavigationController = UINavigationController(rootViewController: tableViewController)
        let menuNavigationController = UINavigationController(rootViewController: menuViewController)
        
        
        let viewControllers = [orderNavigationController, billNavigationController, tableNavigationController, menuNavigationController]
        self.viewControllers = viewControllers
        hidesBottomBarWhenPushed = false
        
    }


}

