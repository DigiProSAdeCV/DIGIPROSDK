//
//  FECatRemoto.swift
//  DIGIPROSDK
//
//  Created by Desarrollo JBH on 15/01/20.
//  Copyright © 2020 Digipro Movil. All rights reserved.
//

import Foundation

public class FECatRemoto: EVObject {
    public var Filtros = Array<FECatRemotoFiltros>()
    public var CatDocId = 0
    public var ProyectoId = 0
    public var GrupoAdminID = 0
    public var Top = 0
}

public class FECatRemotoData: EVObject
{
    public var RowError = ""
    public var RowState = 0
    public var Table = Array<NSDictionary>()
    public var ItemArray = Array<Any>()
    public var HasErrors = false
        
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

public class FECatRemotoFiltros: EVObject {
    public var Operador = ""
    public var Tabla = ""
    public var Valor = ""
}
