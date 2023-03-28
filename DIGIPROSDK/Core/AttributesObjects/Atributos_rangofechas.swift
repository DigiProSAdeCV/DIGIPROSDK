//
//  Atributos_rangofechas.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 11/20/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_rangofechas: Atributos_Generales
{
    public var alineadotexto: String = ""
    public var ayuda: String = ""
    public var campo: String = ""                   // NO Aplica
    public var decoraciontexto: String = ""
    public var estilotexto: String = ""
    public var eventos: Eventos = Eventos ()        // alentrar, alcambiar
    public var fechamax: Int = 0
    public var fechamin: Int = 0
    public var formato: String = ""
    public var habilitado: Bool = false
    public var mascara: String = ""
    public var metadatofinal: String = ""
    public var metadatoinicial: String = ""
    public var metadatorango: String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampo: String = ""                    
    public var requerido: Bool = false
    public var separador: String = ""
    public var subtitulo: String = ""
    public var valorfinal: String = ""
    public var valorinicial: String = ""
    public var valormetadatofinal: String = ""
    public var valormetadatoinicial: String = ""
    public var valormetadatorango: String = ""  //separado por "a", ex: ValorIncial"a"ValorFinal
    public var valorrango: String = ""
    public var visible: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO///////////////////////////////
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "texto"
    public var validationerror: String = ""
    public var formatoObject: [String:Any] = [:]
    
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
