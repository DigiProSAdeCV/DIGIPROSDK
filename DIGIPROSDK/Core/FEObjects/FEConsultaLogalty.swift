//
//  FEConsultaLogalty.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 5/10/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEConsultaLogalty: EVObject{
    public var User = ""
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var Password = ""
    public var IP = ""
    public var Saml = FELogaltySaml()
    public var Formato = FEFormatoData()
    public var FechaSincronizacionIncidencia = 0
    public var FechaSincronizacionReserva = 0
    public var FechaSincronizacionBorradores = 0
    public var CheckSync = false
    
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
