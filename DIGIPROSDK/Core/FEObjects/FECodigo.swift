//
//  FECodigo.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 19/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FECodigo: EVObject{
    public var Codigo = ""
    public var WcfFileTransfer = ""
    public var AplicacionID = 0
    public var ProyectoID = 0
    public var GrupoRegistro = 0
    public var Perfiles = ""
    public var WcfServicios = ""
    public var PermisoRegresarCodigo = false
    public var PermisoRegistrar = false
    
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
