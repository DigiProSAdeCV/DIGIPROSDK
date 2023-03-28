//
//  FEVariableData.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 23/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEVariableData: EVObject {
    public var Nombre = ""
    public var Valor = ""
    public var UserId = 0
    public var ForRules = false
    
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
