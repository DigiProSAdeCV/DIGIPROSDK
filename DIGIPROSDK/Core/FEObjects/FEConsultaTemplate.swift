//
//  FEConsultaTemplate.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 1/29/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public class FEConsultaTemplate: EVObject{
    public var User = ""
    public var Password = ""
    public var IP = ""
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var GrupoAdminID = 0
    public var LastID = ""
    public var NumberToGo = 0
    public var Consulta = FETipoReporte()
    public var TotalRegistros = 0
    public var RegistrosPorPagina = 30
    public var JsonConsulta = ""
    public var Filtro = ""
    
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
