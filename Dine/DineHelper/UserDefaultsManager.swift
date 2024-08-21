//
//  UserDefaultsManager.swift
//  Dine
//
//  Created by doss-zstch1212 on 13/08/24.
//

/// Doc avaliable @https://gist.github.com/ice-bit/69648827c2425dcc7a0f1cad76c5fa00

import Foundation

/// A singleton class that manages the app's settings using `UserDefaults`.
/// This class provides a convenient interface for storing and retrieving
/// user-specific settings like login status and feature availability.
class UserDefaultsManager {
    
    /// The shared instance of `UserDefaultsManager`.
    /// Use this instance to access the stored values.
    static let shared = UserDefaultsManager()
    
    /// The `UserDefaults` instance used to store and retrieve values.
    private let defaults = UserDefaults.standard
    
    /// Private initializer to prevent the creation of multiple instances.
    private init() {}
    
    /// A collection of keys used to store and retrieve values in `UserDefaults`.
    enum Keys {
        /// Key to check if the manager account has been set.
        static let isManagerAccountSet = "isManagerAccountSet"
        /// Key to check if the user is logged in.
        static let isUserLoggedIn = "isUserLoggedIn"
        /// Key to check if billing is enabled.
        static let isBillingEnabled = "isBillingEnabled"
        /// Key to check if payment is enabled.
        static let isPaymentEnabled = "isPaymentEnabled"
        /// Key to check if mock data is enabled.
        static let isMockDataEnabled = "isMockDataEnabled"
    }
    
    /// A Boolean value indicating whether the user is logged in.
    ///
    /// - Returns: `true` if the user is logged in, otherwise `false`.
    var isUserLoggedIn: Bool {
        get { defaults.bool(forKey: Keys.isUserLoggedIn) }
        set { defaults.setValue(newValue, forKey: Keys.isUserLoggedIn) }
    }
    
    /// A Boolean value indicating whether the manager account is set.
    ///
    /// - Returns: `true` if the manager account is set, otherwise `false`.
    var isManagerAccountSet: Bool {
        get { defaults.bool(forKey: Keys.isManagerAccountSet) }
        set { defaults.setValue(newValue, forKey: Keys.isManagerAccountSet) }
    }
    
    /// A Boolean value indicating whether billing is enabled.
    ///
    /// - Returns: `true` if billing is enabled, otherwise `false`.
    var isBillingEnabled: Bool {
        get { defaults.bool(forKey: Keys.isBillingEnabled) }
        set { defaults.setValue(newValue, forKey: Keys.isBillingEnabled) }
    }
    
    /// A Boolean value indicating whether payment is enabled.
    ///
    /// - Returns: `true` if payment is enabled, otherwise `false`.
    var isPaymentEnabled: Bool {
        get { defaults.bool(forKey: Keys.isPaymentEnabled) }
        set { defaults.setValue(newValue, forKey: Keys.isPaymentEnabled) }
    }
    
    /// A Boolean value indicating whether mock data is enabled.
    ///
    /// - Returns: `true` if mock data is enabled, otherwise `false`.
    var isMockDataEnabled: Bool {
        get { defaults.bool(forKey: Keys.isMockDataEnabled) }
        set { defaults.setValue(newValue, forKey: Keys.isMockDataEnabled) }
    }
    
}
