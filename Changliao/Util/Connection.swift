//
//  Connection.swift
//  boxin
//
//  Created by guduzhonglao on 7/3/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import SQLite
extension Connection {
    public func exists(column: String, in table: String) throws -> Bool {
        let str = "PRAGMA table_info('\(table)')"
        let stmt = try prepare(str)
        
        let columnNames = stmt.makeIterator().map { (row) -> String in
            return row[1] as? String ?? ""
        }
        
        return columnNames.contains(where: { dbColumn -> Bool in
            return dbColumn.caseInsensitiveCompare(column) == ComparisonResult.orderedSame
        })
    }
}
