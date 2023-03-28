//
//  FEConsultaAnexo.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 21/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEConsultaAnexo: EVObject{
    public var User = ""
    public var Password = ""
    public var IP = ""
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var anexo = FEAnexoData()
    public var IdsDel = ""
    public var datos = ""
    public var EstadoApp = 0
    public var TipoReemplazo = 0
    public var Accion = 0
    
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
