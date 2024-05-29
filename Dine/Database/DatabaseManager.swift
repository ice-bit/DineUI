//
//  DatabaseManager.swift
//  Dine
//
//  Created by doss-zstch1212 on 28/05/24.
//

import Foundation
import SQLite

final class DatabaseManager {
    var db: Connection?
    
    init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/db.sqlite3")
        } catch {
            print("Unable to open database")
        }
    }
    
    /*func createTable(_ table: Table, columns: [Expression<Value>]) {
        do {
            try db?.run(table.create { t in
                for column in columns {
                    t.column(column)
                }
            })
        }
    }*/
}
