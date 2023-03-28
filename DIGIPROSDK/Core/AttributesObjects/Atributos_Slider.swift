//
//  Atributos_Slider.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 6/19/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class Atributos_Slider: Atributos_Generales
{
    public var alineadotexto: String = ""               // left, center, right, justify
    public var ayuda: String = ""
    public var campo: String = ""
    public var decoraciontexto: String = ""             // none, underline, line-through
    public var divisionesrango: Int = 0                 // NO Aplica
    public var estilos: String = ""                     // flat, big, modern, round, square, sharp
    public var estilotexto: String = ""                 // normal, italic
    public var habilitado: Bool = false
    public var intervalo: Int = 0
    public var metadato: String = ""
    public var mostrarrango: Bool = false               // NO Aplica
    public var numeromaximo: Int = 0
    public var numerominimo: Int = 0
    public var ocultarsubtitulo: Bool = false
    public var postfijo: String = ""
    public var prefijo: String = ""
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var valor: String = ""
    public var valormetadato: String = ""
    public var visible: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var colorfondo = ""
    public var colortexto: String = ""
    public var eventos: Eventos = Eventos ()
    
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
