//
//  Atributos_comboDinamico.swift
//  DIGIPROSDK
//
//  Created by Desarrollo JBH on 10/01/20.
//  Copyright © 2020 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_comboDinamico: Atributos_Generales
{
    //OK
    public var alineadotexto: String = "";                          // left, center, right, justify
    public var ayuda: String = ""
    public var campo: String = "";
    public var campobusqueda: String = "";
    public var camposfiltros: Array<NSMutableDictionary> = Array<NSMutableDictionary>()
    public var cantidadopciones: Int = 0
    public var catalogodestino: [Any] = []
    public var catalogofuente: String = ""
    public var decoraciontexto: String = "";                        // none, underline, line-through
    public var estilotexto: String = "";                            // normal, italic
    public var grosortexto: String = "";                            // normal, bold
    public var habilitado: Bool = false
    public var metadato: String = ""
    public var modocolumnas: Bool = false
    public var ocultarsubtitulo: Bool = false
    public var ordenitems: String = ""                              // alphaasc, alphadesc, idasc, iddesc
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var textoconid: String = ""                              // {i}: numItem, {t}: desc, {cv} : clvCat
    public var tipoasociacion: String = ""
    public var tipolista: String = "combo"
    public var valor: String = ""
    public var valordescripcion: String = ""
    public var valorid: String = ""
    public var valormetadato: String = ""
    public var visible: Bool = false
    public var configjson: String = ""

    
    
    ///////////////////////// ESTAN EN WEB /////////////////////////////////
    public var bindcondition: Bool = false                          //  NO Aplica
    public var campocss: String = ""                                //  NO Aplica
    public var elementrendered: Bool = false                        //  NO Aplica
    public var executeonce: Bool = false                            //  NO Aplica
    public var haserror: Bool = false                               //  NO Aplica
    public var margenderecho: String = "0%"                         //  NO Aplica
    public var margenizquierdo: String = "0%"                       //  NO Aplica
    public var tipo: String = "combodinamico"                       //  NO Aplica
    public var validationerror: String = ""                         //  NO Aplica
    
    
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
