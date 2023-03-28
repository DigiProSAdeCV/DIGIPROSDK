//
//  Atributos_metodo.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 9/26/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public enum enum_metodo{
    case undefined
    case separarfecha
}

public class Atributos_metodo: Atributos_Generales
{
    public var tipometodo = ""
    public var parametrosentrada = ""
    public var parametrossalida = ""
    public var ayuda: String = ""
    public var ocultarsubtitulo: Bool = false
    public var subtitulo: String = ""
    
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
