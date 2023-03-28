//
//  Atributos_textarea.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 11/08/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_textarea: Atributos_Generales
{
    public var alineadotexto: String = ""
    public var alturacampo: Int = 0
    public var ayuda: String = ""
    public var campo: String = ""
    public var contenidoestatico: Bool = false
    public var decoraciontexto: String = ""
    public var estilotexto: String = ""
    public var eventos: Eventos = Eventos () // alentrar, alcambiar
    public var expresionregular: String = ""
    public var habilitado: Bool = false
    public var longitudmaxima: Int = 0
    public var longitudminima: Int = 0
    public var mascara: String = ""
    public var mayusculasminusculas: String = "";
    public var metadato: String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampo: String = ""
    public var regexconfigmsg: String = ""
    public var regexrerror: Bool = false
    public var regexrerrormsg: String = ""
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var valor: String = ""
    public var valormetadato: String = ""
    public var visible: Bool = false
    
    public var alineadocampo: String = ""                       //-------> No se usa en ningun método
    public var elementoprellenadoexterno: Array<String> = [""]  //-------> Se usa en nueva plantilla
    public var ordenenresumen: Int = 0                          //-------> No se usa en ningun método
    public var usarcomocampoexterno: Bool = false               //-------> No se usa en ningun método
    public var usarcomoresumen: Bool = false                    //-------> No se usa en ningun método
    public var mostrarmensajerequerido: Bool = false            //-------> No se usa en ningun método
    public var mostrarmensajelonmax: Bool = false               //-------> No se usa en ningun método
    public var mostrarmensajelonmin: Bool = false               //-------> No se usa en ningun método
    public var mostrarmensajeexpreg: Bool = false               //-------> No se usa en ningun método
    public var mensajelonmax: String = ""                       //-------> No se usa en ningun método
    public var mensajelonmin: String = ""                       //-------> No se usa en ningun método
    
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

public class Atributos_textarea_unit: EVObject
{
    // Atributos
    public var nombre = "" // si aplica
    
    // Atributos Generales
    public var icono: String = ""                       ////// No aplica //////
    public var iscontainer: Bool = false                /// si aplica
    public var mensajerespuestaservicio: String = ""    /// si aplica
    public var mensajerespuestaserviciotipo: String = ""   ////si aplica
    public var ocultartitulo: Bool = false              /// si aplica
    public var ordencampo: Int = 0;                     /// si aplica
    public var titulo: String = "Titulo de demostración"                      /// si aplica
    
    public var alineadotexto: String = "left"
    public var alturacampo: Int = 50
    public var ayuda: String = "Esto es un texto de ayuda simulado"
    public var campo: String = ""
    public var contenidoestatico: Bool = false
    public var decoraciontexto: String = "none"
    public var elementopadre: String = ""
    public var estilotexto: String = "normal"
    public var eventos: Eventos = Eventos () // alentrar, alcambiar
    public var expresionregular: String = "[a-zA-Z]"
    public var habilitado: Bool = false
    public var longitudmaxima: Int = 20
    public var longitudminima: Int = 0
    public var mascara: String = "Nuestras palabras son el arma más poderosa"
    public var mayusculasminusculas: String = "normal";
    public var metadato: String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampo: String = ""
    public var regexconfigmsg: String = ""
    public var regexrerror: Bool = false
    public var regexrerrormsg: String = "La expresión regular no se cumple"
    public var requerido: Bool = false
    public var subtitulo: String = "Este es un subtítulo de demostración para el elemento"
    public var valor: String = ""
    public var valormetadato: String = ""
    public var visible: Bool = false

    public var alineadocampo: String = ""                       //-------> No se usa en ningun método
    public var elementoprellenadoexterno: Array<String> = [""]  //-------> Se usa en nueva plantilla
    public var ordenenresumen: Int = 0                          //-------> No se usa en ningun método
    public var usarcomocampoexterno: Bool = false               //-------> No se usa en ningun método
    public var usarcomoresumen: Bool = false                    //-------> No se usa en ningun método
    public var mostrarmensajerequerido: Bool = false            //-------> No se usa en ningun método
    public var mostrarmensajelonmax: Bool = false               //-------> No se usa en ningun método
    public var mostrarmensajelonmin: Bool = false               //-------> No se usa en ningun método
    public var mostrarmensajeexpreg: Bool = false               //-------> No se usa en ningun método
    public var mensajelonmax: String = ""                       //-------> No se usa en ningun método
    public var mensajelonmin: String = ""                       //-------> No se usa en ningun método
    
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
