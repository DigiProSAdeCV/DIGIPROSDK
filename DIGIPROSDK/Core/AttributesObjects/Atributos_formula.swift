//
//  Atributos_formula.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/10/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_formula: EVObject{
    
    public var value = ""
    public var type = ""
    public var id = ""
    public var tipo = ""
    
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

public enum Typeformula : String {
    // Elementos
    case elementovariable = "elementovariable"
    // De propiedad
    case point = "point"
    // De valor
    case propiedadvariable = "propiedadvariable"
    // Operadores
    case equal = "equal"
    // Tipo de asignacion
    case character = "character"
    public var label:String? {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first?.label
    }
    
}
