//
//  FECampoReporte.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 1/9/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public enum TipoCampo: Int {
    case Default = 0
    case BigInt = 1
    case DateTime = 2
    case DateddmmaaaaDiag = 3
    case DateaaammddDiag = 4
    case DateddmmaaaaGuion = 5
    case DateaaammddGuion = 6
    case VarChar = 7
    case Char = 8
    case Int = 9
    case TinyInt = 10
    case Check = 11
    case DynamicList = 12
    case Money = 13
}

public class FECampoReporte: EVObject{
    public var Nombre = ""
    public var MaxLength = ""
    public var MinLength = ""
    public var Required = 0
    public var Validate = ""
    public var TypeId = ""
    public var Accion = ""
    public var Regla = ""
    public var Mascara = ""
    public var Preguntar = 0
    public var FiltroFijo = ""
    public var TipoConsulta = ""
    public var OrdenMostrar = ""
    public var PermisoId = ""
    public var Valor = ""
    public var Catalogo = Array<FEItemCatalogo>()
    public var ReportePAdre = ""
    
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
