//
//  FEConsultaPlantilla.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 23/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEConsultaPlantilla: EVObject{
    public var User = ""
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var FechaSincronizacionPlantilla = 0
    public var ListPlantillasPermiso = Array<FEPlantillaData>()
    public var ListPlantillas = Array<FEPlantillaData>()
    public var ListCatalogos = Array<FEItemCatalogoEsquema>()
    public var ListServicios = Array<FEListaServicios>()
    public var ListComponentes = Array<FEListaComponentes>()
    
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
