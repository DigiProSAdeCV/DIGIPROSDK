//
//  Atributos_escanerNFC.swift
//  DIGIPROSDK
//
//  Created by Desarrollo JBH on 17/12/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_escanerNFC: Atributos_Generales
{
    //OK
    public var metadato: String = ""
    public var subtitulo: String = ""
    public var ocultarsubtitulo: Bool = false
    public var alineadotexto: String = ""
    public var decoraciontexto: String = ""
    public var estilotexto: String = ""
    public var mayusculasminusculas: String = ""
    public var ayuda: String = ""
    public var habilitado: Bool = false
    public var requerido: Bool = false
    public var visible: Bool = false
    public var valor: String = ""
    public var valormetadato: String = ""
    public var permisoescaner: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var lado: Int = 0                        //  NO Aplica
    public var margenderecho: String = "0%"
    public var margenizquierdo: String = "0%"       //  NO Aplica
    public var colorescaner: String = ""            //  NO Aplica
    public var colortextoescaner: String = ""       //  NO Aplica
    public var campo: String = ""                   //  NO Aplica
}
