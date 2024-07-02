//
//  SceneDelegate.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let hasLaunchedBeforeKey = "hasLaunchedBefore"

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey)
        
        let databaseService = DatabaseServiceImpl()
        let tableToCreate = [
            databaseService.createMenuItemTable,
            databaseService.createAccountTable,
            databaseService.createBillTable,
            databaseService.createOrderItemTable,
            databaseService.createOrderTable,
            databaseService.createTableDataTable,
            databaseService.createCategoryTable,
        ]
        
        DispatchQueue.global(qos: .background).async {
            tableToCreate.forEach { $0() }
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        guard hasLaunchedBefore else {
            print("This is the first launch.")
            let rootViewController = SignUpViewController()
            rootViewController.isInitialScreen = true
            window?.rootViewController = rootViewController
            window?.makeKeyAndVisible()
            UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
            return
        }
        
        let rootViewController = determineRootViewController(isUserLoggedIn: UserDefaults.standard.bool(forKey: "isUserLoggedIn"))
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    /// Determines the root view controller based on the user's login status.
    /// - Parameter isUserLoggedIn: A boolean value indicating the user's login status. Pass `true` if the user is logged in, and `false` otherwise.
    /// - Returns: An instance of `UIViewController`. If the user is logged in, a `TabBarHostingController` is returned. If the user is not logged in, a `UINavigationController` with `LoginViewController` as its root view controller is returned.
    private func determineRootViewController(isUserLoggedIn: Bool) -> UIViewController {
      if isUserLoggedIn {
        return TabBarHostingController()
      } else {
        return UINavigationController(rootViewController: LoginViewController())
      }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

