//
//  AtributosJumio.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 27/02/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class AtributosJumio: Atributos_Generales{
    public var alineadotexto: String = ""
    public var assemblypath: String = ""
    public var ayuda: String = ""
    public var bindcondition: Bool = false
    public var campo: String = ""
    public var campocss: String = ""
    public var colorbotoncorreccion: String = ""
    public var colorbotoncorrecciontexto: String = ""
    public var colorbotonocr: String = ""
    public var colorbotonocrtexto: String = ""
    public var currentOCR: String = ""
    public var decoraciontexto: String = ""
    public var documents: String = ""
    public var documentsminimal: String = ""
    public var documentspaper: String = ""
    public var elementrendered: Bool = false
    public var estilotexto: String = ""
    public var executeonce: Bool = false
    public var habilitado: Bool = false
    public var haserror: Bool = false
    public var idvalidation: String = ""
    public var margenderecho: String = ""
    public var margenizquierdo: String = ""
    public var ocrgenerado: Bool = false
    public var ocultarsubtitulo: String = ""
    public var passport: String = ""
    public var permitircorreccion: Bool = false
    public var prefijo: String = ""
    public var subtitulo: String = ""
    public var textocorreccion: String = ""
    public var textoocr: String = ""
    public var tipo: String = ""
    public var validationerror: String = ""
    public var visible: Bool = false
    public var proveedor: String = ""
    public var imagenanverso: String = ""
    public var imagenreverso: String = ""
    public var formasvalidacion: String = ""
    public var tokenshared: String = ""
    public var paisdocumentos: String = ""
    public var videodocumentosselfie: String = ""
    //selfie
    public var imagenselfie: String = ""
    public var videoselfie: String = ""
    public var mappingscore: NSMutableDictionary = NSMutableDictionary()
    public var mappingocr: NSMutableDictionary = NSMutableDictionary()
    
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
