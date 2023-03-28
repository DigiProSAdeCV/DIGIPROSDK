//
//  Atributos_georeferencia.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 9/26/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_georeferencia: Atributos_Generales
{
    public var alineadotexto: String = ""
    public var anteriornombrearchivo: String = ""
    public var ayuda: String = ""
    public var campo: String = ""
    public var decoraciontexto: String = ""
    public var estilotexto: String = ""
    public var eventos : Eventos = Eventos ()   //  "alterminarcaptura"
    public var habilitado: Bool = false
    public var metadato: String = ""
    public var nombrearchivo: String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampo: String = ""
    public var pdfcampoanexo: String = ""
    public var pedirmapa: Bool = false
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var tipodoc: Int = 0
    public var valor: String = ""
    public var valormetadato: Bool = false
    public var visible: Bool = false
    public var permisotipificar: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var anexo: String = ""
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var map: String = ""
    public var tipo: String = "georeferencia"
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
