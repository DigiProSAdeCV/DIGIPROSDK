//
//  Atributos_codigobarras.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 17/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_codigobarras: Atributos_Generales
{
    public var alineadotexto: String = ""           // left, right, center, justify
    public var alto: Int = 0                        // No Aplica
    public var ancho: Int = 0                       // No Aplica
    public var ayuda: String = ""
    public var campo: String = ""                   // No Aplica
    public var decoraciontexto: String = ""         // none, underline, line-through
    public var estilotexto: String = ""             // normal, italic
    public var eventos: Eventos = Eventos ()        // alentrar, alcambiar
    public var expresionregular: String = ""
    public var generarcodigo: Bool = false
    public var habilitado: Bool = false
    public var mayusculasminusculas: String = ""    // upper, lower
    public var metadato: String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampo: String = ""
    public var pdfcampocodigo: String = ""
    public var regexconfigmsg: String = ""
    public var regexrerror: Bool = false
    public var regexrerrormsg: String = ""
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var tipocodigo: String = ""              // CODE128, CODE11, Interleaved2of5 ,CODE39 ,QRLIB
    public var valor: String = ""
    public var valormetadato: String = ""
    public var visible: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var alineadocampo: String = ""
    public var mostrarmensajerequerido: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var bindcondition: Bool = false          //  NO Aplica
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false        //  NO Aplica
    public var executeonce: Bool = false            //  NO Aplica
    public var haserror: Bool = false               //  NO Aplica
    public var tipo: String = "codigobarras"
    public var validationerror: String = ""         //  NO Aplica
    
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

