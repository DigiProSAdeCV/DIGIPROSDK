//
//  Atributos_huelladigital.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 17/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_huelladigital: Atributos_Generales
{
    public var alineadotexto: String = ""
    public var anteriornombrearchivo: String = ""
    public var ayuda: String = ""
    public var campo: String = ""
    public var cantidadhuellas: String = "0"
    public var colorbotonescanear: String = ""
    public var colortextobotoneliminar: String = ""
    public var decoraciontexto: String = ""
    public var estilotexto: String = ""
    public var eventos: Eventos = Eventos ()    //  "alterminarcaptura" 
    public var habilitado: Bool = false
    public var huellasacapturar: String = ""
    public var nombrearchivo: String = ""
    public var ocultarsubtitulo: Bool = false
    public var requerido: Bool = false
    public var scorehuellas: String = ""
    public var scoremin: String = ""
    public var scorepromedio: String = ""
    public var subtitulo: String = ""
    public var tipodoc: Int = 0
    public var tipoescaneo: String = ""// enroll
    public var tipoescaner: String = ""// futronic, morpho, veridium
    public var verscore: Bool = false
    public var visible: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var alineadocampo: String = ""
    public var docid: String = ""
    public var fingernumber: Int = 0
    public var huellascapturadasr: String = ""
    public var huellascapturadasl: String = ""
    public var mostrarmensajerequerido: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var anexo: String = ""
    public var bindcondition: Bool = false
    public var campocss: String = ""            //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "huelladigital"
    public var tipoescaneoObject: [String:Any] = [:]
    
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
