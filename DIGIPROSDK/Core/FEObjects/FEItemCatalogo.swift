//
//  FECatalogo.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 24/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEItemCatalogo: EVObject {
    public var TipoCatalogoID = 0
    public var CatalogoId = 0 // ID
    public var Descripcion = "" // Descripcion
    public var CVECatalogoPID = "" // Clave Catalogo Padre
    public var CVECatalogo = "" // Clave Catalogo
    public var Activo = 0  // Activo/Inactivo
    public var Json = "" // json value
    
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
