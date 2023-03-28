//
//  FELogs.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 12/03/21.
//  Copyright © 2021 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FELogs: EVObject{
    public var Servicio: String = ""
    public var Dispositivo: String = ""
    public var Codigo: String = ""
    public var FechaRequest: String = ""
    public var FechaResponse: String = ""
    public var TiempoDeRespuesta: String = ""
    public var Error: String = ""
    public var LineError: String = ""
    public var RequestData: String = ""
    public var ResponseData: String = ""
    public var Usuario: String = ""
    
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
