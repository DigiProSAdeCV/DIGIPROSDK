//
//  Atributos_wizard.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 17/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_wizard: Atributos_Generales
{
    public var alineadotexto = ""
    public var ancho = ""
    public var autoredireccionar: Bool = false
    public var campo = ""
    public var cantidadformatosabrir: Int = 0
    public var colorfondoavanzar: String = "#3c8dbc"
    public var colorfondofinalizar: String = "#3c8dbc"
    public var colorfondoregresar: String = "#3c8dbc"
    public var colortextoavanzar: String = "#ffffff"
    public var colortextofinalizar: String = "#ffffff"
    public var colortextoregresar: String = "#ffffff"
    public var confirmarguardadoprellenado: Bool = false
    public var decoraciontexto = ""
    public var ejecutarreglas: Bool = false
    public var elementoavalidar: String = ""
    public var estilotexto = ""
    public var eventos : Eventos = Eventos ()   //  "alclickfinalizar"
    public var habilitado: Bool = false
    public var paginaavanzar = ""
    public var paginaregresar = ""
    public var plantillaabrir = ""
    public var prefilleddata:NSMutableDictionary = [:]
    public var redireccionar: Bool = false
    public var tareafinalizar = ""
    public var textoavanzar = ""
    public var textofinalizar = ""
    public var textoregresar = ""
    public var tipoguardado: String = ""
    public var validacion = false
    public var vericonos: Bool = false
    public var visible = false
    public var visibleavanzar = false
    public var visiblefinalizar = false
    public var visibleregresar = false
    public var navegacion:[String] = []
    public var visiblepaginado: Bool = false
    public var publicarautomatico : Bool = false
    public var usuarioasignar: String = ""
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var ayuda: String = ""
    public var cerraralfinalizar: Bool = false
    public var coloravanzar: String = ""
    public var colorfinalizar: String = ""
    public var colorregresar: String = ""
    public var ocultarsubtitulo: Bool = false
    public var subtitulo: String = ""
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var cantidadformatosabrircounter: Int = 0 //-1
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var isafterfinish: Bool = false
    public var isbackward: Bool = false
    public var isbeforefinish: Bool = false
    public var isforward: Bool = false
    public var tipo: String = "wizard"
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
