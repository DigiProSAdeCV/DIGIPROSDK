//
//  FEAnexoData.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 17/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEAnexoData: EVObject{
    public var Guid = ""
    public var FileName = ""
    public var ElementoId = ""
    public var Datos = ""
    public var TareaSiguiente = FEEventosFlujo()
    public var Movil = true
    public var DocID = 0
    public var InstanciaId = 0
    public var ExpID: Int? = 0
    public var TipoDocID = 0
    public var Extension = ""
    public var Separador = false
    public var OrdenVisor = 0
    public var Error = 0
    public var GuidAnexo = ""
    public var Borrado = false
    public var Reemplazado = false
    public var Descargado = false
    public var Editado = false
    public var DocIDAnexo = 0
    public var Completado = 0
    public var Publicado = false
    public var NombreOriginal = ""
    
    public var isReemplazo = false
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
