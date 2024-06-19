//
//  UIWindow+setRootViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 18/06/24.
//

import UIKit

extension UIWindow {
    
    /// This asynchronous method sets a new root view controller for the UIWindow with an optional animation.
    /// - Parameters:
    ///   - newRootViewController: The UIViewController instance to be set as the new root view controller
    ///   - animated: A Boolean value indicating whether to animate the transition to the new view controller.
    ///
    /// - Behavior:  If animated is false, the new view controller is immediately set as the root view controller without any animation.
    /// If animated is true, the method uses UIView.transition with a cross-dissolve animation to smoothly transition from the old view controller to the new one.
    ///
    /// - Note: This extension utilizes @MainActor to ensure the method is called on the main thread.
    /// The animation is performed with animations disabled to prevent conflicts with other animations within the view hierarchy.
    /// This method uses withCheckedContinuation to handle the asynchronous nature of the animation.
    /// The continuation is resumed after the animation completes.
    @MainActor
    func setRootViewController(_ newRootViewController: UIViewController, animated: Bool = true) async {
        guard animated else {
            rootViewController = newRootViewController
            return
        }

        await withCheckedContinuation({ (continuation: CheckedContinuation<Void, Never>) in
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                self.rootViewController = newRootViewController
                UIView.setAnimationsEnabled(oldState)
            } completion: { _ in
                continuation.resume()
            }
        })
    }
}
