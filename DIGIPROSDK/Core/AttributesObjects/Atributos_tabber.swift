//
//  Atributos_tabber.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 2/20/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_tabber: Atributos_Generales
{
    public var campo: String = ""
    public var colorborde: String = ""
    public var grosorborde: Int = 0
    public var visible: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var ayuda: String = ""
    public var ocultarsubtitulo: Bool = false
    public var subtitulo: String = ""
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO//////////////////////////////////
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tabids: Array<String> = []
    public var tipo: String = "tabber"
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
