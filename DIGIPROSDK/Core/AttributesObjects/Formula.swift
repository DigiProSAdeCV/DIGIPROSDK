//
//  Formula.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 2/25/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public class Formula: EVObject {
    public var id: String = ""
    public var tipo: String = ""
    public var type: String = ""
    public var value: String = ""
    
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.count == 0 || value == "null" {
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            return true
        } else if value is NSNull {
            return true
        }
        return false
    }
    
}
