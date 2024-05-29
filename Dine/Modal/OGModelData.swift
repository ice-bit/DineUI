//
//  OGModelData.swift
//  Dine
//
//  Created by doss-zstch1212 on 22/05/24.
//

import Foundation

class OGModelData {
    var menuService: MenuService? = createMenuService()
}

fileprivate func createMenuService() -> MenuService? {
    do {
        let databaseAccess = try SQLiteDataAccess.openDatabase()
        return MenuServiceImpl(databaseAccess: databaseAccess)
    } catch {
        print("Failed to initialize database: \(error)")
    }
    return nil
}
