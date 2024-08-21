//
//  UserSessionManager.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/06/24.
//

/*// Usage Example:
 
 let loggedInUser = Account(username: "exampleUser", password: "securePassword", accountStatus: .active, userRole: .employee)

 // Save account
 UserSessionManager.shared.saveAccount(loggedInUser)

 // Load account
 if let loadedUser = UserSessionManager.shared.loadAccount() {
     print("Loaded user: \(loadedUser)")
 }

 // Clear account
 UserSessionManager.shared.clearAccount()*/

import Foundation

class UserSessionManager {
    static let shared = UserSessionManager()
    private let userDefaultsKey = "loggedInUser"

    private init() {}

    func saveAccount(_ account: Account) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(account)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            UserDefaultsManager.shared.isUserLoggedIn = true
        } catch {
            print("Error encoding user: \(error.localizedDescription)")
        }
    }

    func loadAccount() -> Account? {
        if let storedData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let decoder = JSONDecoder()
                let account = try decoder.decode(Account.self, from: storedData)
                return account
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }

    func clearAccount() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaultsManager.shared.isUserLoggedIn = false
    }
}
