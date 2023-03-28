//
//  FEListTipoDoc.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 8/14/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEListTipoDoc: EVObject {
    public var Activo: Bool = false
    public var TipoCatalogoID = 0
    public var CVECatalogoPID: String = ""
    public var Descripcion: String = ""
    public var CVECatalogo: String = ""
    public var CatalogoId = 0
    public var Json: String = ""
    public var min: Int = 0
    public var max: Int = 0
    public var current: Int = 0
    
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
