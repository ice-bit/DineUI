//
//  RootViewManager.swift
//  Dine
//
//  Created by doss-zstch1212 on 18/06/24.
//

import UIKit
import Toast

struct RootViewManager {
    static func didSignInSuccessfully(with account: Account) {
        UserSessionManager.shared.saveAccount(account)
        // Create the new root view controller
        let mainAppController: UIViewController? = YardController().requestBaseScene()
        
        guard let mainAppController else { return }
        
        // Optionally add a transition animation
        let window = UIApplication.shared.windows.first
        let options: UIView.AnimationOptions = .transitionFlipFromRight
        let duration: TimeInterval = 0.5
        
        
        // Ensure the window is key and visible
        window?.makeKeyAndVisible()
        
        // Update the root view controller with animation
        UIView.transition(with: window!,
                          duration: duration,
                          options: options,
                          animations: {
            window?.rootViewController = mainAppController
        },
                          completion: nil)
        
        
        // Set isUserLoggedIn -> true
        UserDefaultsManager.shared.isUserLoggedIn = true
        // set the 'isManagerAccountSet' to true
        if account.userRole == .manager {
            UserDefaultsManager.shared.isManagerAccountSet = true
        }
        let toast = Toast.default(image: UIImage(systemName: "person.fill.checkmark")!, title: "Logged In")
        toast.show(haptic: .success)
    }
    
    static func didLoggedOutSuccessfully() {
        // Create the new root view controller
        let loginViewController = LoginViewController()
        
        // Optionally add a transition animation
        let window = UIApplication.shared.windows.first
        let options: UIView.AnimationOptions = .transitionFlipFromLeft
        let duration: TimeInterval = 0.5
        
        // Ensure the window is key and visible
        window?.makeKeyAndVisible()
        
        // Update the root view controller with animation
        UIView.transition(with: window!,
                          duration: duration,
                          options: options,
                          animations: {
            window?.rootViewController = UINavigationController(rootViewController: loginViewController) // embed inside a nav con 
        },
                          completion: nil)
        // Set isUserLoggedIn -> false
        UserDefaultsManager.shared.isUserLoggedIn = false
        let toast = Toast.default(image: UIImage(systemName: "checkmark")!, title: "Logged out")
        toast.show(haptic: .success)
    }
}
