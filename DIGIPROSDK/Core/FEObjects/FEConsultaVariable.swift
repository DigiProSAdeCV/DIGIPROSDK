//
//  FEConsultaVariable.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/23/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEConsultaVariable: EVObject{
    public var User = ""
    public var Password = ""
    public var IP = ""
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var ListVariables = Array<FEVariableData>();
    public var ListLog = Array<FELogError>();
    public var LogsSincronizados = false
    public var Dispositivo = ""
    public var GeoPosicion = ""

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
