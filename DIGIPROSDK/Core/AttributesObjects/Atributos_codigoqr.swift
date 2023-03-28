//
//  Atributos_codigoqr.swift
//  DIGIPROSDK
//
//  Created by Desarrollo JBH. on 16/12/19.
//  Copyright © 2019 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_codigoqr: Atributos_Generales
{
    //OK
    public var alineadotexto: String = ""           // left, right, center, justify
    public var ayuda: String = ""
    public var campo: String = ""                   // No Aplica
    public var decoraciontexto: String = ""         // none, underline, line-through
    public var estilotexto: String = ""             // normal, italic
    public var generarcodigo: Bool = false
    public var generarcodigoautomatico: Bool = false
    public var habilitado: Bool = false
   
    public var mayusculasminusculas: String = ""    // upper, lower
    public var metadato: String = ""
    public var ocultarsubtitulo: Bool = false
    public var pdfcampo: String = ""
    public var pdfcampocodigo: String = ""
    public var permisoescaner: Bool = false
    public var permitirprellenadoexterno: Bool = false
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var valor: String = ""
    public var valormetadato: String = ""
    public var visible: Bool = false
    public var prellenadomapeocampos: String = ""
    
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var lado: Int = 0                        //  NO Aplica
    public var margenderecho: String = "0%"
    public var margenizquierdo: String = "0%"
          //  NO Aplica
}
