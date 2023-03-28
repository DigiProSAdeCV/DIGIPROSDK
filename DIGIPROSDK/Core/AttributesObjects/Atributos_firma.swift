//
//  Atributos_firma.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 06/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_firma_hash: EVObject{
    // HASH
    public var tiempo: String = ""
    public var imagebase64: String = ""
    public var videobase64: String = ""
    public var imagevideobase64: String = ""
    public var gps: String = ""
    public var personafirma : String  = ""
    public var acuerdofirma : String = ""
    public var deviceDesc: String = ""
}

public class Atributos_firma_Anexo: EVObject{
    public var localizacion: String = ""
    public var tiempo: String = ""
    public var personafirma : String  = ""
    public var acuerdofirma : String = ""
    public var hashCrypt: String = ""
    public var timestamp: String = ""
    public var dispositivo: String = ""
}


public class Atributos_firma: Atributos_Generales
{
    public var acuerdofirma : String = ""
    public var alineadotexto : String = ""
    public var anteriornombrearchivo: String = ""
    public var ayuda: String = ""
    public var campo : String = ""
    public var decoraciontexto : String = ""
    public var estilotexto : String = ""
    public var eventos : Eventos = Eventos ()   //  "alterminarcaptura"
    public var habilitado: Bool = false
    public var nombrearchivo : String  = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampoanexo : String  = ""
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var tipodoc : Int = 0
    public var visible: Bool = false
    public var personafirma: String  = ""
    public var hashCrypt: String = ""
    public var colorfirma: String = ""
    public var colorborrar: String = ""
    public var colorreemplazar: String = ""
    public var permisotipificar: Bool = false
    
    
    ///Homologacion con Android:
    public var dispositivo: String = ""
    public var fecha: String = ""
    public var georeferencia: String = ""
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var anexo: String = ""
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "firma"
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
