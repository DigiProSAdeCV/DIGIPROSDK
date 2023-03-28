//
//  Atributos_logico.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 17/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_logico: Atributos_Generales
{
    public var alineadotexto: String = ""
    public var ayuda: String = ""
    public var campo: String = ""
    public var decoraciontexto: String = ""
    public var estilotexto: String = ""
    public var eventos: Eventos = Eventos ()    //  "aldarclick"
    public var habilitado: Bool = false
    public var imagenlogico: String = ""
    public var metadato: String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampo: String = ""
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var valor: Bool = false
    public var valormetadato: String = ""
    public var visible: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "logico"
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
