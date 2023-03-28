//
//  FEHistoria.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 10/08/21.
//  Copyright © 2021 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEHistoria: EVObject{
    public var Descripcion: String = ""
    public var Categoria: String = ""
    public var FechaHistoria: UInt64 = 0
    
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
