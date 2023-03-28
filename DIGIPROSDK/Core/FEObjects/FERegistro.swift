//
//  FERegistro.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/24/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FERegistro: EVObject{
    public var User = ""
    public var Password = ""
    public var Nombre = ""
    public var ApellidoP = ""
    public var ApellidoM = ""
    public var Email = ""
    public var IP = ""
    public var Operacion = ""// operAlta
    public var GrupoId = 0
    public var Perfiles = ""
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var ExisteUsuario = false
    public var CuentaActiva = false
    
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

