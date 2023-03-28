//
//  Atributos_moneda.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 16/08/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_moneda: Atributos_Generales
{
    public var alineadotexto: String = ""                   // left, center, right, justify
    public var ayuda: String = ""
    public var campo: String = ""
    public var contenidoestatico: Bool = false
    public var cultura: String = ""
    public var decimales: String = ""
    public var decoraciontexto: String = ""                 // none, underline, line-through
    public var estilotexto: String = ""                     // normal, italic
    public var eventos: Eventos = Eventos ()                // alentrar, alcambiar
    public var habilitado: Bool = false
    public var mascara: String = ""
    public var metadato: String = ""
    public var numeromaximo: Int = 0
    public var numerominimo: Int = 0
    public var ocultarsubtitulo: Bool = false
    public var pdfcampo: String = ""
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var valor: String = ""
    public var valormetadato: String = ""
    public var visible: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var alineadocampo: String = ""
    public var elementoprellenadoexterno: Array<String> = [""]
    public var expresionregular: String = ""
    public var longitudmaxima: Int = 0
    public var longitudminima: Int = 0
    public var mayusculasminusculas: String = ""
    public var ordenenresumen: Int = 0
    public var regexrerror: Bool = false
    public var regexrerrormsg: String = ""
    public var usarcomocampoexterno: Bool = false
    public var usarcomoresumen: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO//////////////////////////////////
    public var bindcondition: Bool = false                  //  NO Aplica
    public var campocss: String = ""                        //  NO Aplica
    public var elementrendered: Bool = false                //  NO Aplica
    public var executeonce: Bool = false                    //  NO Aplica
    public var haserror: Bool = false                       //  NO Aplica
    public var tipo: String = "moneda"
    public var validationerror: String = ""                 //  NO Aplica
    
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
