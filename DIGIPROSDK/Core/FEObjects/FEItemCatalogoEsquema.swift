//
//  FEItemCatalogoEsquema.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 27/08/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEItemCatalogoEsquema: EVObject {
    public var TipoCatalogoID = 0
    public var Catalogo: Array<FEItemCatalogo> = [FEItemCatalogo]()
    public var Esquema = ""
    
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
