//
//  FEEstadistica.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/22/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEEstadistica: EVObject{
    public var Campo = ""
    public var FechaEntrada = ""
    public var FechaSalida = ""
    public var Resultado = ""
    public var Latitud = ""
    public var Usuario = ""
    public var KeyStroke = 0
    public var Longitud = ""
    public var Dispositivo = ""
    public var TipoDispositivo = 0
    public var NombrePlantilla = ""
    public var NombrePagina = ""
    public var NombreSeccion = ""
    public var CapturaOk = false
    public var CapturaError = false
    public var CapturaAyuda = false
    public var OrdenCampo = 0
    public var Sesion = ""  //  Guid formato
    public var PlantillaID = 0 // 0
    public var PaginaID = 0 // #id pagina
    public var SeccionID = 0 // #id pagina o 0
    public var CampoID = 0 // #id campo
    
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
