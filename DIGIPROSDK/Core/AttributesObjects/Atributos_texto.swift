//
//  Atributos_texto.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 26/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

public class Atributos_texto: Atributos_Generales{
    // Atributos versión 0.99.100.11
    // Atributos versión 10.36.1.0
    // Si aplica solo en título y subtítulo
    public var alineadotexto: String = "" // left, center, right, justify
    // Si aplica, se muestra si trae texto
    public var ayuda: String = ""
    // No aplica campo ya que es para hacer más grande o pequeño el componente
    public var campo: String = ""
    // Si aplica contenidoestatico
    public var contenidoestatico: Bool = false
    // Si aplica solo solo en título y subtítulo
    public var decoraciontexto: String = "" // none, underline, line-through
    // Si aplica solo en título y subtítulo
    public var estilotexto: String = "" // normal, italic
    // Eventos #JATZY
    public var eventos: Eventos = Eventos() // alentrar, alcambiar
    // Si aplica expresionregular #JATZY
    public var expresionregular: String = "" //
    // Si aplica a toda la celda
    public var habilitado: Bool = false
    // Si aplica al input
    public var longitudmaxima: Int = 0
    // Si aplica al input
    public var longitudminima: Int = 0
    // Si aplica al input si trae texto
    public var mascara: String = ""
    // Si aplica al input
    public var mayusculasminusculas: String = "normal" // normal, upper, lower
    // No aplica
    public var metadato: String = ""
    // Si aplica ocultarsubtitulo
    public var ocultarsubtitulo: Bool = false
    // Si aplica pdfcampo #JATZ
    public var pdfcampo: String = ""
    // Si aplica regexconfigmsg #JATZ
    public var regexconfigmsg: String = ""
    // Si aplica regexrerror #JATZ
    public var regexrerror: Bool = false
    // Si aplica regexrerrormsg
    public var regexrerrormsg: String = ""
    // Si aplica requerido
    public var requerido: Bool = false
    // Si aplica si trae texto
    public var subtitulo: String = ""
    // Si aplica si trae texto
    public var valor: String = ""
    // Si aplica valormetadato #JATZ
    public var valormetadato: String = ""
    // Si aplica visible
    public var visible: Bool = false
    // Esqueleto máscara
    public var esqueletoformato: String? = nil
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    // Atributos adicionales
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
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO//////////////////////////////////
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var tipo: String = "texto"
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

public class Atributos_texto_unit: EVObject{
    
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
    
    public var alineadotexto: String = "left" // left, center, right, justify
    public var ayuda: String = "Esto es un texto de ayuda simulado"
    public var campo: String = ""
    public var contenidoestatico: Bool = false
    public var decoraciontexto: String = "none" // none, underline, line-through
    public var elementopadre: String = ""
    public var estilotexto: String = "normal" // normal, italic
    public var eventos: Eventos = Eventos() // alentrar, alcambiar
    public var expresionregular: String = "[a-zA-Z]" //
    public var habilitado: Bool = false
    public var idunico: String = ""
    public var longitudmaxima: Int = 20
    public var longitudminima: Int = 0
    public var mascara: String = "Nuestras palabras son el arma más poderosa"
    public var mayusculasminusculas: String = "normal" // normal, upper, lower
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
