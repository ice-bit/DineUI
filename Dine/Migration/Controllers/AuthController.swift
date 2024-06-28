//
//  AuthController.swift
//  Dine
//
//  Created by doss-zstch1212 on 10/01/24.
//
import Foundation
import NotificationCenter

protocol ApplicationModeDelegate: AnyObject {
    func applicationModeDidChange(to state: ApplicationMode)
}

protocol Authentication {
    func createAccount(username: String, password: String, userRole: UserRole) throws
    func login(username: String, password: String) throws -> Account?
}

class AuthController: Authentication {
    private let databaseAccess: DatabaseAccess
    init(databaseAccess: DatabaseAccess) {
        self.databaseAccess = databaseAccess
    }
    weak var applicationModeDelegate: ApplicationModeDelegate?
    
    func createAccount(username: String, password: String, userRole: UserRole) throws {
        guard !isUserPresent(username: username) else { throw AuthenticationError.userAlreadyExists }
        guard AuthenticationValidator.isValidUsername(username) else {
            throw AuthenticationError.invalidUsername(reason: "Username format invalid!")
        }
        guard AuthenticationValidator.isStrongPassword(password) else {
            throw AuthenticationError.notStrongPassword
        }
        
        let account = Account(username: username, password: password, accountStatus: .active, userRole: userRole)
        
        // Add the new user to the DB
        try databaseAccess.insert(account)
    }
    
    func isUserPresent(username: String) -> Bool {
        let fetchQuery = "SELECT * FROM \(DatabaseTables.accountTable.rawValue) WHERE Username = '\(username)';"
        guard let _ = try? databaseAccess.retrieve(query: fetchQuery, parseRow: Account.parseRow).first as? Account else { return false }
        
        return true
    }
    
    func login(username: String, password: String) throws -> Account? {
        let result = isLoginValid(username: username, password: password)

        switch result {
        case .success(let account):
            return account
        case .failure(let error):
            throw error
        }
    }
    
    private func handleLoginError(_ error: AuthenticationError, username: String) {
        switch error {
        case .invalidUsername:
            print("Invalid username")
        case .invalidPassword:
            print("Invalid password")
        case .userAlreadyExists:
            print("User already exists")
        case .inactiveAccount:
            print("Inactive account")
        case .noUserFound:
            print("No user found under username: \(username)")
        case .other(let error):
            print("An error occurred: \(error.localizedDescription)")
        case .incorretPassword:
            print("Incorrect Password")
        case .notStrongPassword:
            print("Password is not strong")
        }
    }
    
    private func isLoginValid(username: String, password: String) -> Result<Account, AuthenticationError> {
        let fetchQuery = "SELECT * FROM \(DatabaseTables.accountTable.rawValue) WHERE Username = '\(username)';"
        do {
            guard let user = try databaseAccess.retrieve(query: fetchQuery, parseRow: Account.parseRow).first as? Account else {
                throw AuthenticationError.noUserFound
            }
            
            guard user.accountStatus == .active else {
                throw AuthenticationError.inactiveAccount
            }
            
            guard user.password == password else {
                throw AuthenticationError.incorretPassword
            }
            return .success(user)
        } catch let error as AuthenticationError {
            return .failure(error)
        } catch {
            return .failure(.other(error))
        }
    }
}

enum ApplicationMode: String {
    case signedIn
    case signedOut
}

struct ApplicationModeStore {
    static func getCurrentMode() -> ApplicationMode? {
        if let storedMode = UserDefaults.standard.string(forKey: "applicationMode"),
           let applicationMode = ApplicationMode(rawValue: storedMode) {
            return applicationMode
        } else {
            return nil
        }
    }
    
    static func setMode(_ mode: ApplicationMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: "applicationMode")
    }
}
