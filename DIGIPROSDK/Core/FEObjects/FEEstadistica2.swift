//
//  FEEstadistica2.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 10/08/21.
//  Copyright © 2021 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEEstadistica2: EVObject{
    public var IdElemento: String = ""
    public var Titulo: String = ""
    public var ValorFinal: String = ""
    public var Pagina: String = ""
    public var IdPagina: String = ""
    public var Cambios: Int = 0
    public var FechaValorFinal: UInt64 = 0
    
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
