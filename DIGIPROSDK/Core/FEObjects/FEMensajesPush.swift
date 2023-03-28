//
//  FEMensajesPush.swift
//  DIGIPROSDK
//
//  Created by Desarrollo JBH on 04/06/20.
//  Copyright © 2020 Digipro Movil . All rights reserved.
//

import Foundation

public class FEMensajesPush: EVObject {
    public var ID = ""
    public var UsrID =  ""
    public var FechaCreacion = ""
    public var Mensaje = ""
    public var Enviado = false
    public var Visto = false
    public var Borrado = false
    
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.count == 0 || value == "null" {
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            return true
        } else if value is NSNull {
            return true
        }
        // MARK - Override to clean console from missing attributes warnings
        return false
    }
}
