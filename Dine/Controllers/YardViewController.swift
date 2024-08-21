//
//  YardViewController.swift
//  Dine
//
//  Created by ice on 14/08/24.
//

import UIKit

class YardController {
    func requestBaseScene() -> UIViewController? {
        guard let account = UserSessionManager.shared.loadAccount() else {
            fatalError("Invalid User session")
        }
        
        let managerBaseScene = CreateManagerBaseApp()
        let waitstaffBaseScene = CreateWaitStaffBaseApp()
        
        switch account.userRole {
        case .admin:
            return managerBaseScene.requestViewController()
        case .manager:
            return managerBaseScene.requestViewController()
        case .waitStaff:
            return waitstaffBaseScene.requestViewController()
        case .kitchenStaff:
            return waitstaffBaseScene.requestViewController()
        case .employee:
            return waitstaffBaseScene.requestViewController()
        }
    }
}

protocol RequestViewControllerProtocol {
    func requestViewController() -> UIViewController?
}

struct CreateManagerBaseApp: RequestViewControllerProtocol {
    
    func requestViewController() -> UIViewController? {
      do {
        let databaseAccess = try SQLiteDataAccess.openDatabase()
        let services = createServices(with: databaseAccess)
        let viewControllers = createViewControllers(with: services)
        let tabBarController = createTabBarController(with: viewControllers)
        return tabBarController
      } catch {
        print("Failed to create view controller: \(error)")
        return nil
      }
    }

    private func createServices(with databaseAccess: SQLiteDataAccess) -> (orderService: OrderService, menuService: MenuService, tableService: TableService) {
      let orderService = OrderServiceImpl(databaseAccess: databaseAccess)
      let menuService = MenuServiceImpl(databaseAccess: databaseAccess)
      let tableService = TableServiceImpl(databaseAccess: databaseAccess)
      return (orderService, menuService, tableService)
    }

    private func createViewControllers(with services: (orderService: OrderService, menuService: MenuService, tableService: TableService)) -> [UIViewController] {
      let orderViewController = OrderViewController(orderService: services.orderService, menuService: services.menuService)
      orderViewController.tabBarItem = UITabBarItem(title: "Orders", image: UIImage(systemName: "cart"), selectedImage: UIImage(systemName: "cart.fill"))
      
      let billViewController = BillViewController()
      billViewController.tabBarItem = UITabBarItem(title: "Bills", image: UIImage(systemName: "newspaper"), selectedImage: UIImage(systemName: "newspaper.fill"))
      
      let tableViewController = TablesViewController(tableService: services.tableService)
      tableViewController.tabBarItem = UITabBarItem(title: "Tables", image: UIImage(systemName: "table.furniture"), selectedImage: UIImage(systemName: "table.furniture.fill"))
      
      let menuListingViewController = MenuListingViewController()
      menuListingViewController.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(systemName: "menucard"), selectedImage: UIImage(systemName: "menucard.fill"))
      
      let controlViewController = ManagerSettingsViewController()
      controlViewController.tabBarItem = UITabBarItem(title: "Controls", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear.circle"))
      
      let metricViewController = MetricViewController()
      metricViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
      let metricNavigationController = UINavigationController(rootViewController: metricViewController)
      
      let editViewController = EditViewController()
      editViewController.tabBarItem = UITabBarItem(title: "Edit", image: UIImage(systemName: "pencil"), selectedImage: UIImage(systemName: "pencil.and.scribble"))
      
      let orderNavigationController = UINavigationController(rootViewController: orderViewController)
      let billNavigationController = UINavigationController(rootViewController: billViewController)
      let tableNavigationController = UINavigationController(rootViewController: tableViewController)
      let menuNavigationController = UINavigationController(rootViewController: menuListingViewController)
      let controlNavigationController = UINavigationController(rootViewController: controlViewController)
      
        return [metricNavigationController, billNavigationController, tableNavigationController, menuNavigationController, controlNavigationController]
    }

    private func createTabBarController(with viewControllers: [UIViewController]) -> UITabBarController {
      let tabBarController = UITabBarController()
      tabBarController.viewControllers = viewControllers
      tabBarController.selectedIndex = 0
      return tabBarController
    }
}

struct CreateWaitStaffBaseApp: RequestViewControllerProtocol {
    func requestViewController() -> UIViewController? {
      do {
        let databaseAccess = try SQLiteDataAccess.openDatabase()
        let services = createServices(with: databaseAccess)
        let viewControllers = createViewControllers(with: services)
        let tabBarController = createTabBarController(with: viewControllers)
        return tabBarController
      } catch {
        print("Failed to create view controller: \(error)")
        return nil
      }
    }

    private func createServices(with databaseAccess: SQLiteDataAccess) -> (orderService: OrderService, menuService: MenuService, tableService: TableService) {
      let orderService = OrderServiceImpl(databaseAccess: databaseAccess)
      let menuService = MenuServiceImpl(databaseAccess: databaseAccess)
        let tableService = TableServiceImpl(databaseAccess: databaseAccess)
        return (orderService, menuService, tableService)
    }
    
    private func createViewControllers(with services: (orderService: OrderService, menuService: MenuService, tableService: TableService)) -> [UIViewController] {
        let orderViewController = OrderViewController(orderService: services.orderService, menuService: services.menuService)
        orderViewController.tabBarItem = UITabBarItem(title: "Orders", image: UIImage(systemName: "cart"), selectedImage: UIImage(systemName: "cart.fill"))
        
        let billViewController = BillViewController()
        billViewController.tabBarItem = UITabBarItem(title: "Bills", image: UIImage(systemName: "newspaper"), selectedImage: UIImage(systemName: "newspaper.fill"))
        
        let settingsViewController = SettingsViewController()
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear"))
        
        
        let orderNavigationController = UINavigationController(rootViewController: orderViewController)
        let billNavigationController = UINavigationController(rootViewController: billViewController)
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        
        return [orderNavigationController, billNavigationController, settingsNavigationController]
    }
    
    private func createTabBarController(with viewControllers: [UIViewController]) -> UITabBarController {
        let tabBarController = UITabBarController()
      tabBarController.viewControllers = viewControllers
      tabBarController.selectedIndex = 0
      return tabBarController
    }
}

