//
//  FEListMetadatosHijos.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 9/4/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEListMetadatosHijos: EVObject {
    public var Accion: String = ""
    public var EsEditable: Bool = false
    public var Expresion_Regular: String = ""
    public var FolioAut: Int = 0
    public var Longitud_Maxima: Int = 0
    public var Longitud_Minima: Int = 0
    public var Mascara: String = ""
    public var MetadatoId: Int = 0
    public var Nombre: String = ""
    public var NombreCampo: String = ""
    public var Obligatorio: Bool = false
    public var TipoDato: String = ""
    public var TipoDatoId: Int = 0
    public var TipoDoc: Int = 0
    
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

public class FEDocumento: EVObject{
    public var isKindImage: Bool = false
    public var guid: String = ""
    public var URL: String = ""
    public var Path: String = ""
    public var Nombre: String = ""
    public var Ext: String = ""
    public var TipoDoc: String = ""
    public var TipoDocID: Int?
    public var ImageString: String = ""
    public var isReemplazo: Bool = false
    public var DocID: Int = 0
    public var Metadatos: [FEListMetadatosHijos] = []
    
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

public class FEOpenPlantilla: EVObject{
    public var Guid: String = ""
    public var ExoID: Int = 0
    public var TipoDocID: Int = 0
    public var FlujoID: Int = 0
    public var PIID: Int = 0
    
}
