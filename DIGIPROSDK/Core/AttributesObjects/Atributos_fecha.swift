//
//  Atributos_fecha.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 12/08/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_fecha: Atributos_Generales
{
    public var alineadotexto: String = ""                   // left, right, center, justify
    public var ayuda: String = ""
    public var campo: String = ""                           // NO Aplica
    public var decoraciontexto: String = ""                 // none, underline, line-through
    public var estilotexto: String = ""                     // normal, italic
    public var eventos: Eventos = Eventos ()                // alentrar, alcambiar
    public var fechamax: String = ""                        // -9999, (negativo), (positivo)
    public var fechamin: String = ""                        // -9999, (negativo), (positivo)
    public var formato: String = ""
    public var habilitado: Bool = false
    public var mascara: String = ""
    public var metadato: String = ""                        //  NO Aplica
    public var ocultarsubtitulo: Bool = false
    public var pdfcampo: String = ""                        //  NO Aplica
    public var requerido: Bool = false
    public var separador: String = ""
    public var subtitulo: String = ""
    public var valor: String = ""
    public var valormetadato: String = ""                   //  NO Aplica
    public var visible: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var alineadocampo: String = ""
    public var elementoprellenadoexterno: Array<String> = [""]
    public var ordenenresumen: Int = 0
    public var usarcomocampoexterno: Bool = false
    public var usarcomoresumen: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO//////////////////////////////////
    public var bindcondition: Bool = false                  //  NO Aplica
    public var campocss: String = ""                        //  NO Aplica
    public var elementrendered: Bool = false                //  NO Aplica
    public var executeonce: Bool = false                    //  NO Aplica
    public var formatoObject: [String:Any] = [:]
    
    public var haserror: Bool = false                       //  NO Aplica
    public var tipo: String = "fecha"
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
