//
//  Atributos_PDFOCR.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 02/01/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class Atributos_PDFOCR: Atributos_Generales {
    public var alineadotexto : String = ""
    public var anteriornombrearchivo: String = ""
    public var ayuda: String = ""
    public var campo : String = ""
    public var colorborrar : String = ""
    public var colorescaner : String = ""
    public var colorimportar : String = ""
    public var colorreemplazar : String = ""
    public var colortextoborrar : String = ""
    public var colortextoescaner : String = ""
    public var colortextoimportar : String = ""
    public var colortextoreemplazar : String = ""
    public var colortextotomarfoto : String = ""
    public var colortextovisualizar : String = ""
    public var colortomarfoto : String = ""
    public var colorvisualizar : String = ""
    public var crop : Bool = false
    public var decoraciontexto : String = ""
    public var estilotexto : String = ""
    public var eventos : Eventos = Eventos ()   //  "alterminarcaptura" 99
    public var habilitado: Bool = false
    public var modocamara: String = ""// front, rear
    public var nombrearchivo : String = ""
    public var normalizacion : String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampoanexo : String = "" ///9
    public var permisocamara = false
    public var permisoescanear = false
    public var permisoimportar = false
    public var permisotipificar: Bool = false
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var tipocamara : String = ""
    public var tipodoc : Int = 0
    public var visible: Bool = false
    public var Tipo : String = ""
    
    /////////////////////////  NO APLICA /////////////////////////////////
    public var anexo: String = ""
    public var bindcondition: Bool = false
    public var campocss: String = ""
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var margenderecho: String = ""
    public var margenizquierdo: String = ""
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
