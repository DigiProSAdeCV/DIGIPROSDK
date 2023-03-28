//
//  Atributos_listatemporal.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 6/27/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class Atributos_listatemporal: Atributos_Generales
{
    public var alineadotexto: String = ""               // left, right, center, justify
    public var campo: String = ""                       // nano, micro, small, normal, big ---->
    public var catalogodestino: String = ""
    public var decoraciontexto: String = ""             // none, underline, line-through
    public var elementoligado: String = ""
    public var estilotexto: String = ""                 // normal, italic
    public var grosortexto: String = ""                 // normal, bold
    public var valor: String = ""
    public var visible: Bool = false
    public var atributodescripcion: String = ""
    public var atributovalor: String = ""
    public var atributocombomostrar: String = ""
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var habilitado: Bool = true
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO//////////////////////////////////
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "comboboxtemporal"
    public var validationerror: String = ""
    public var subtitulo: String = ""
    public var ocultarsubtitulo: Bool = false
    
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
