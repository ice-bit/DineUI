//
//  AuthenticationError.swift
//  Dine
//
//  Created by doss-zstch1212 on 15/02/24.
//

import Foundation

enum AuthenticationError: Error {
    case invalidUsername(reason: String)
    case invalidPassword(reason: String)
    case incorrectPassword
    case notStrongPassword
    case inactiveAccount
    case userAlreadyExists
    case noUserFound
    case other(Error)
}
