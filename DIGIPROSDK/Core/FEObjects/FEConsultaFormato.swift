//
//  FEConsultaFormato.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 31/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEConsultaFormato: EVObject {
    public var Ticket = ""
    public var EstadisticasGuardadas = 0
    public var User = ""
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var Password = ""
    public var IP = ""
    public var Formato = FEFormatoData()
    public var FechaSincronizacionIncidencia = 0
    public var FechaSincronizacionReserva = 0
    public var FechaSincronizacionBorradores = 0
    public var CheckSync = false
    public var IdDel = 0
    public var Incidencias = Array<FEFormatoData>()
    
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
