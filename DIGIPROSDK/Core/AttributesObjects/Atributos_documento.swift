//
//  Atributos_documento.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 8/28/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class Atributos_documento: Atributos_Generales{

    public var alineadotexto: String = ""
    public var ayuda: String = ""
    public var colortextoimportar: String = ""
    public var colortextotomarfoto: String = ""
    public var colortomarfoto: String = ""
    public var colorimportar: String = ""
    public var decoraciontexto: String = ""
    public var estilotexto: String = ""
    public var extensionespermitidas: String = ""
    public var habilitado: Bool = false
    public var maximodocumentos: Int = 0
    public var minimodocumentos: Int = 0
    public var modocamara: String = ""
    public var nombrearchivo: String = ""
    public var normalizacion: String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampoanexo: String = ""
    public var permisocamara: Bool = false
    public var permisoimportar: Bool = false
    public var permisotipificar: Bool = false
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var textobotonsubirarchivo: String = ""
    public var textobotontomarfoto: String = ""
    public var tipificacionpermitida: [NSMutableDictionary] = [NSMutableDictionary()]
    public var tipificacionunica: NSMutableDictionary = NSMutableDictionary()
    public var tipocamara: String = ""
    public var tipodoc: Int = 0
    public var visible: Bool = false

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
