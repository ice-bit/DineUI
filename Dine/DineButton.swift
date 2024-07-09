//
//  DineButton.swift
//  Dine
//
//  Created by doss-zstch1212 on 05/07/24.
//

import UIKit

import UIKit

/// A custom UIButton subclass designed for the 'Dine' app, providing a consistent button style and behavior.
class DineButton: UIButton {

    /// Initializes a new DineButton with a title and an optional primary action.
    /// - Parameters:
    ///   - title: The title to display on the button.
    ///   - primaryAction: An optional UIAction to be triggered when the button is pressed.
    init(title: String, primaryAction: UIAction? = nil) {
        super.init(frame: .zero)
        configure(title: title, primaryAction: primaryAction)
    }

    /// Initializes a new DineButton from a storyboard or XIB.
    /// - Parameter coder: The coder used to initialize the button.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure(title: "Button")
    }

    /// Configures the button with a title and an optional primary action.
    /// - Parameters:
    ///   - title: The title to display on the button.
    ///   - primaryAction: An optional UIAction to be triggered when the button is pressed.
    private func configure(title: String, primaryAction: UIAction? = nil) {
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .large
        configuration.buttonSize = .large
        configuration.title = title
        configuration.baseBackgroundColor = .blue
        self.configuration = configuration
        if let action = primaryAction {
            self.addAction(action, for: .primaryActionTriggered)
        }
    }

    /// Updates the button's configuration using the provided closure.
    /// - Parameter updates: A closure that modifies the current configuration.
    func updateConfiguration(_ updates: (inout UIButton.Configuration) -> Void) {
        if var currentConfiguration = self.configuration {
            updates(&currentConfiguration)
            self.configuration = currentConfiguration
        }
    }
}
