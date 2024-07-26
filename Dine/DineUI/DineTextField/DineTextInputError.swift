//
//  DineTextInputError.swift
//  Dine
//
//  Created by doss-zstch1212 on 25/07/24.
//

import Foundation

/// An error object with a localized description used by the `DineTextField`.
open class DineTextInputError: NSObject {
    public init(localizedDescription: String) {
        self.localizedDescription = localizedDescription
    }
    
    public let localizedDescription: String
}
