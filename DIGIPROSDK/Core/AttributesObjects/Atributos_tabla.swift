//
//  Atributos_tabla.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 9/26/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_tabla: Atributos_Generales
{
    public var alineadotexto: String = ""
    public var botonagregarcerrartexto: String = ""
    public var botonagregartexto: String = ""
    public var botoncerrartexto: String = ""
    public var botoneditartexto: String = ""
    public var botonimportartexto: String = ""
    public var botonlimpiartexto: String = ""
    public var botonnuevotexto: String = ""
    public var campo: String = ""
    public var colorborde: String = ""
    public var colorbotonagregar: String = ""
    public var colorbotonagregarcerrar: String = ""
    public var colorbotonagregarcerrartexto: String = ""
    public var colorbotonagregartexto: String = ""
    public var colorbotoncerrar: String = ""
    public var colorbotoncerrartexto: String = ""
    public var colorbotoneditar: String = ""
    public var colorbotoneditartexto: String = ""
    public var colorbotonlimpiar: String = ""
    public var colorbotonlimpiartexto: String = ""
    public var colorbotonnuevo: String = ""
    public var colorbotonnuevotexto: String = ""
    public var colorencabezadotabla: String = ""
    public var colorencabezadotextotabla: String = ""
    public var colorheader: String = ""
    public var colorheadertexto: String = ""
    public var decoraciontexto: String = ""
    public var estilotexto: String = ""
    public var eventos : Eventos = Eventos ()   //  "alagregareditar"
    public var evitarduplicado: Bool = false
    public var filasmax: Int = 0
    public var filasmin: Int = 0
    public var grosorborde: Int = 0
    public var metadato: String = ""
    public var mostrarconsecutivofila: Bool = false
    public var ocultarsubtitulo: Bool = false
    public var ordenamiento: String = ""
    public var permisotablaagregarcerrarr: Bool = false
    public var permisotablaagregarr: Bool = false
    public var permisotablacerrar: Bool = false
    public var permisotablaeditarr: Bool = false
    public var permisotablaeliminarr: Bool = false
    public var permisotablaimportarr: Bool = false
    public var permisotablalimpiar: Bool = false
    public var permisotablamostrar: Bool = false
    public var permisotablamultiedicion: Bool = false
    public var permisotablaseleccionarr: Bool = false
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var tipodoc: String = ""
    public var tipo: String = ""
    public var valor: String = ""
    public var valormetadato: String = ""
    public var vertotales: Bool = false
    public var visible: Bool = false
    public var vistamovil: String = ""
    public var columnasvisualizar: [String:Any] = [:]
    public var columnastotalizar: [String:Any] = [:]
    public var operaciontotal: String = ""
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var ayuda: String = ""
    public var alineadocampo: String = ""
    public var configcolumnas: String = ""
    public var filas: Int = 0
    public var filasVisibles: Int = 0
    public var habilitado: Bool = false
    public var mostrarmensajerequerido: Bool = false
    public var publicaranexo: Bool = false
    public var ordenFilas: Array<Int> = [0]
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO//////////////////////////////////
    public var addrow: Bool = false
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var clickedWizardRow: Int = -1
    public var columnasmultieditar: Array<Int> = [0]
    public var configuracioncargatabla: Array<Int> = [0]
    public var elementrendered: Bool = false
    public var errorjson: Array<String> = []
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var importartemplatetabla: String = ""
    public var lastrownumber: Int = 0
    public var modeedit: Bool = false
    public var nombretemplatecarga: String = ""
    public var rowcheckeds: String = ""
    public var rowediting: String = ""
    public var validationerror: String = ""
    public var valorjson: String = ""
    public var nombrecolumnas: [String:Any] = [:]
    
    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        
        guard let dict = value as? NSDictionary else{
            return
        }
        if key == "columnasvisualizar"{
            self.columnasvisualizar = dict as! [String : Any]
        }
        
        if key == "columnastotalizar"{
            self.columnastotalizar = dict as! [String : Any]
        }
        
    }
    
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
