//
//  Atributos_audio.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_audio: Atributos_Generales
{
    public var alineadotexto: String = ""
    public var anteriornombrearchivo: String = ""
    public var ayuda: String = ""
    public var campo: String = ""
    public var decoraciontexto : String = ""
    public var estilotexto: String = ""                    
    public var eventos: Eventos = Eventos ()    //  "alterminarcaptura"
    public var habilitado: Bool = false
    public var leyendaaudio: String = ""
    public var nombrearchivo: String = ""
    public var ocultarsubtitulo: Bool = false
    public var permisograbar: Bool = false
    public var permisoimportar: Bool = false
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var tipodoc: Int = 0
    public var visible: Bool = false
    public var coloraudio: String = ""
    public var colorborrar: String = ""
    public var colorimportar: String = ""
    public var colorvisualizar: String = ""
    public var colorreemplazar: String = ""
    public var colortextoaudio: String = ""
    public var colortextoborrar: String = ""
    public var colortextoimportar: String = ""
    public var colortextoreemplazar: String = ""
    public var permisotipificar: Bool = false
    
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var anexo: String = ""
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "audio"
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
