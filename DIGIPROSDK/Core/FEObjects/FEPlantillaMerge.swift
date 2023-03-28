//
//  FEPlantillaMerge.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 1/21/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public class FEPlantillaMerge: EVObject {
    public var FlujoID = 0
    
    public var ExpID = 0
    public var TipoDocID = 0
    
    public var MostrarExp = false
    public var MostrarTipoDoc = false
    
    public var FechaActualizacion = ""
    public var NombreFlujo = ""
    
    public var Procesos = Array<String>()
    public var PProcesos = [FEProcesos]()
    public var ExpDoc = [FEExpDoc]()
    
    public var HasNewVersion: Bool = false
    public var CounterFormats: Int = 0

    public var VerNuevaCapturaMovil: Bool = true
    
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
