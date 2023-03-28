//
//  Atributos_pagina.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 26/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_pagina: Atributos_Generales
{
    public var idelemento: String = ""
    public var eventos: Eventos = Eventos ()         //Si aplica : "almostrarpagina"
    public var habilitado: Bool = false              //si aplica
    public var visible: Bool = false                 //si aplica
    
    ///////////////////////// ESTAN AQUÍ Y NO EN WEB ///////////////////////////////
    public var validado: Bool = false                //si aplica
    public var paginaseleccionada: Bool = false;     //si aplica
    public var disableAll: Bool = false;             //si aplica
    public var subtitulo: String = ""                //si aplica
    public var ocultarsubtitulo: Bool = false        //si aplica
    public var ayuda: String = ""                    //si aplica
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO///////////////////////////////
    public var activo: Bool = false
    public var bindcondition: Bool = false
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "Pagina"
    public var validationerror: String = ""
    public var vertab: Bool = false
    
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
