//
//  Eventos.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 25/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Eventos: EVObject{
    public var expresion: Array<Expresion> = []
}

public class Expresion: EVObject{
    
    public var _categoria = ""
    public var _idexpression = ""
    public var _tipoexpression = ""
    public var atributos: Atributos_Expresion?
    public var expresion: Array<Expresion>?
    public var parent = ""
    
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

public class Atributos_Expresion: EVObject{
    
    public var estilo = ""
    public var nombre = ""
    public var formula = ""
    public var alternativa: Array<Expresion> = []
    public var coincidencia: Array<Expresion> = []
    public var condicion: Array<Expresion> = []
    
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
