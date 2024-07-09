//
//  ViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit
import SwiftUI

class TabBarHostingController: UITabBarController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabBar()
    }
    
    // MARK: - Private methods
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
        tabBar.tintColor = UIColor(named: "AppColor")
    }
    
    private func setupTabBar() {
        let vcFactory = ViewControllerFactory()
        guard let databaseAccess = try? SQLiteDataAccess.openDatabase() else {
            print("Failed to open database connection")
            return
        }
        let orderService = OrderServiceImpl(databaseAccess: databaseAccess)
        let menuService = MenuServiceImpl(databaseAccess: databaseAccess)
        let tableService = TableServiceImpl(databaseAccess: databaseAccess)
        
        let orderViewController = OrderViewController(orderService: orderService, menuService: menuService)
        orderViewController.tabBarItem = UITabBarItem(title: "Orders", image: UIImage(systemName: "cart"), selectedImage: UIImage(systemName: "cart.fill"))
        let billViewController = BillViewController()
        billViewController.tabBarItem = UITabBarItem(title: "Bills", image: UIImage(systemName: "newspaper"), selectedImage: UIImage(systemName: "newspaper.fill"))
        let tableViewController = TablesViewController(tableService: tableService)
        tableViewController.tabBarItem = UITabBarItem(title: "Tables", image: UIImage(systemName: "table.furniture"), selectedImage: UIImage(systemName: "table.furniture.fill"))
        
        guard let menuSectionViewController = vcFactory.createMenuSectionViewController() else {
            print("Error: Failed to create instance of MenuSectionViewController.")
            return
        }
        
        menuSectionViewController.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(systemName: "menucard"), selectedImage: UIImage(systemName: "menucard.fill"))
        
        let orderNavigationController = UINavigationController(rootViewController: orderViewController)
        let billNavigationController = UINavigationController(rootViewController: billViewController)
        let tableNavigationController = UINavigationController(rootViewController: tableViewController)
        let menuNavigationController = UINavigationController(rootViewController: menuSectionViewController)
        
        let metricViewController = MetricViewController()
        metricViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        let metricNavigationController = UINavigationController(rootViewController: metricViewController)
        
        let editViewController = EditViewController()
        editViewController.tabBarItem = UITabBarItem(title: "Edit", image: UIImage(systemName: "pencil"), selectedImage: UIImage(systemName: "pencil.and.scribble"))
        
        let viewControllers = [
            metricNavigationController,
            orderNavigationController,
            billNavigationController,
            tableNavigationController,
            menuNavigationController,
            //UINavigationController(rootViewController: editViewController)
        ]
        self.viewControllers = viewControllers
        hidesBottomBarWhenPushed = false
        
    }


}

struct ViewControllerFactory {
    private var databaseAccess: DatabaseAccess? = {
        do {
            return try SQLiteDataAccess.openDatabase()
        } catch {
            fatalError("Error: Unable to open the database. Please check if the database file exists and is accessible.")
        }
        return nil
    }()
    
    func createMenuSectionViewController() -> MenuSectionViewController? {
        guard let databaseAccess else {
            print("Error: 'databaseAccess' object not found. Unwrapping failed due to missing or null reference.")
            return nil
        }
        
        let menuService = MenuServiceImpl(databaseAccess: databaseAccess)
        
        return MenuSectionViewController(menuService: menuService)
    }
}

#Preview {
    TabBarHostingController()
}

