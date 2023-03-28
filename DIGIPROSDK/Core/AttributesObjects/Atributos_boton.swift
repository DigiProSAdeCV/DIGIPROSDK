//
//  Atributos_boton.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 12/08/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_boton: Atributos_Generales
{
    public var alineadotexto: String = ""       // left, right, center, justify
    public var ancho: String = ""               //completo, normal
    public var ayuda: String = ""
    public var campo: String = ""               //normal
    public var colorfondo: String = ""          //hexadecimal
    public var colortexto: String = ""          //hexadecimal
    public var eventos: Eventos = Eventos ()    //  "aldarclick"
    public var habilitado: Bool = false
    public var tamanio: String = ""             //normal, mini, chico, grande
    public var urllink: String = ""
    public var valor: String = ""
    public var visible: Bool = false
    public var vercomoregistro: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var ocultarsubtitulo: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var bindcondition: Bool = false          //  NO Aplica
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false        //  NO Aplica
    public var executeonce: Bool = false            //  NO Aplica
    public var haserror: Bool = false               //  NO Aplica
    public var isclick: Bool = false
    public var tamaniocss: String = ""              //  NO Aplica
    public var tipo: String = "boton"
    public var validationerror: String = ""         //  NO Aplica
    public var cantidadmaximaclic: Int = 0
    
    public var urlnuevapagina : Bool = false        //  NO Aplica
    
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
