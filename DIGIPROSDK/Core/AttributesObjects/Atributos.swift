//
//  Atributos.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 25/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

/// Atributos
public class Atributos: EVObject{
    public var nombre = "" // si aplica
    
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

/// Atributos Generales
public class Atributos_Generales: Atributos{
    public var icono: String = ""
    public var idunico: String = ""
    public var elementopadre: String = ""
    public var incluirenpdf: Bool = true
    public var iscontainer: Bool = false
    public var mensajerespuestaservicio: String = ""
    public var mensajerespuestaserviciotipo: String = ""
    public var mostrarloader: Bool = false
    public var ocultartitulo: Bool = false
    public var ordencampo: Int = 0
    public var textoloader: String = ""
    public var tipoloader: String = ""
    public var titulo: String = ""
    
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
