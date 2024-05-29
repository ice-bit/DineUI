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
        setupDBTables()
        setupAppearance()
        setupTabBar()
    }
    
    // MARK: - Private methods
    
    private func setupDBTables() {
        let databaseService = DatabaseServiceImpl()
        databaseService.createMenuItemTable()
        databaseService.createAccountTable()
        databaseService.createBillTable()
        databaseService.createOrderItemTable()
        databaseService.createOrderTable()
        databaseService.createTableDataTable()
    }
    
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
        
        
        let viewControllers = [orderNavigationController, billNavigationController, tableNavigationController, menuNavigationController]
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

