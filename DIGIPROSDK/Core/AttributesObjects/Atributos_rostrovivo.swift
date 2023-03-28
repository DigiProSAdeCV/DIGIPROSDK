//
//  Atributos_rostrovivo.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 11/20/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_rostrovivo: Atributos_Generales
{
    public var acciones: String = ""
    public var alineadotexto: String = ""
    public var anteriornombrearchivo: String = ""
    public var ayuda: String = ""
    public var campo: String = ""
    public var decoraciontexto: String = ""
    public var estilotexto: String = ""
    public var eventos: Eventos = Eventos ()    //  "alterminarcaptura"
    public var habilitado: Bool = false
    public var nombrearchivo: String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampoanexo: String = ""
    public var proveedor: String = ""// faceplusplus, veridium
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var tipodoc: Int = 0
    public var visible: Bool = false
    public var permisotipificar: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var alineadocampo: String = ""
    public var anteriorguid: String = ""
    public var anteriordocid: String = ""
    public var docid: Int = 0
    public var downloadanexo: Bool = false
    public var facetocompare: String = ""
    public var isliveperson: String = ""
    public var mostrarmensajerequerido: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var anexo: String = ""
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "rostrovivo"
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
