//
//  Atributos_espacio.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 2/18/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_espacio: Atributos_Generales
{
    public var campo: String = ""
    public var visible: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var ayuda: String = ""
    public var ocultarsubtitulo: Bool = false
    public var subtitulo: String = ""
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "espacio"
    public var validationerror: String = ""
    
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
