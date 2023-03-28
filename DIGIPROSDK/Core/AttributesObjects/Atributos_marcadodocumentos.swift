//
//  Atributos_marcadodocumentos.swift
//  DIGIPROSDK
//
//  Created by Desarrollo JBH on 11/05/20.
//  Copyright © 2020 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_marcadodocumentos: Atributos_Generales
{
    public var alineadotexto: String = ""
    public var ayuda: String = ""
    public var bindcondition: Bool = false
    public var campo: String = ""
    public var campocss: String = ""
    public var cargacamara: String = ""
    public var cargaimportacion: String = ""
    public var catalogodestino: [Any] = []
    public var catalogoorigen: String = ""
    public var catalogoupdated: Bool = false
    public var chosenitems: [Any] = []
    public var decoraciontexto: String = ""
    public var elementodocumento: [Any] = []
    public var elementrendered: Bool = false
    public var estilotexto: String = ""
    public var executeonce: Bool = false
    public var filtrarcatalogo: NSMutableDictionary = NSMutableDictionary()
    public var fuentedatos: String = ""
    public var grosortexto: String = ""
    public var habilitado: Bool = false
    public var haserror: Bool = false
    public var isRule: Bool = false
    public var margenderecho: String = ""
    public var margenizquierdo: String = ""
    public var mostraranimacion: Bool = false
    public var ocultarsubtitulo: Bool = false
    public var opcionrequerida: String = ""
    public var orientacion: String = ""
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var textoopcioncatalogo: String = ""
    public var tipo: String = ""
    public var tipoasociacion: String = ""
    public var tipolista: String = ""
    public var validationerror: String = ""
    public var valor: String = ""
    public var valormetadato: String = ""
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

