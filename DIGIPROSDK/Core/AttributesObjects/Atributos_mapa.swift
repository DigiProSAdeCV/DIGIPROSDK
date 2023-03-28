//
//  Atributos_mapa.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_mapa: Atributos_Generales
{
    public var alineadotexto : String = ""
    public var anteriornombrearchivo: String = ""
    public var ayuda: String = ""
    public var campo : String = ""
    public var cargadomapa: Bool = false
    public var decoraciontexto : String = ""
    public var direccion: String = ""
    public var estilotexto : String = ""
    public var eventos: Eventos = Eventos ()
    public var habilitado : Bool = false
    public var metadato : String = ""
    public var nombrearchivo : String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampo : String = ""
    public var pdfcampoanexo : String = ""
    public var requerido : Bool = false
    public var subtitulo: String = ""
    public var tipodoc : Int = 0
    public var valor : String = ""
    public var valormetadato : String = ""
    public var visible : Bool = false
    public var permisotipificar: Bool = false
    
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
