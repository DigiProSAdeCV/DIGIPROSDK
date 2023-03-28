//
//  FEReporteEstadistico.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 10/08/21.
//  Copyright © 2021 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEReporteEstadistico: EVObject{
    public var FechaComienzo: UInt64 = 0
    public var FechaTermino: UInt64 = 0
    public var Plataforma: String = "iOS"
    public var VersiónPlantilla: String = ""
    public var FechaPlantilla: String = ""
    public var Resultado: String = ""
    public var DocId: Int = 0
    public var Usuario: String = ""
    public var Estadisticas = Array<FEEstadistica2>()
    public var Historia = Array<FEHistoria>()
    
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
