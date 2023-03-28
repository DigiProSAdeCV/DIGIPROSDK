//
//  Atributos_servicio.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 9/26/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public enum enum_servicio
{
    case undefined
    case sepomex
    case enrollfinger
    case verifyfinger
    case identifyfinger
    case enrollface
    case verifyface
    case identifyface
    case comparefaces
    case ocrine
    case ocrcfe
    case ocrtelmex
    case ocrcea
    case ocratt
    case inebydata
    case inebyfinger
    case sendsms
    case validatesmscode
    case obtenercurp
    case validarcurp
    case confirmmail
    case callvideochat
    case saassirh
    case folioautomatico
}

public class Atributos_servicio: Atributos_Generales
{
    public var mensajeservicio: String = ""
    public var parametrosentrada: String = ""
    public var parametrossalida: String = ""
    public var requerido: Bool = false
    public var respuestacorrecta: Bool = false
    public var tiposervicio: String = ""
        
    public var ayuda: String = ""
    public var Item1: String = ""
    public var mensajeerrorservicio: String = ""
    public var mensajeexitoservicio: String = ""
    public var ocultarsubtitulo: Bool = false
    public var subtitulo: String = ""
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var bindcondition: Bool = false
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "servicio"
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
