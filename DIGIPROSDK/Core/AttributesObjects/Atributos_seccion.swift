//
//  Atributos_seccion.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 12/08/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_seccion: Atributos_Generales
{
    public var alineadotexto: String = ""
    public var campo: String = ""
    public var colorborde: String = ""
    public var colorheader: String = ""
    public var colorheadertexto: String = ""
    public var decoraciontexto: String = ""
    public var estilotexto: String = ""
    public var grosorborde: Int = 0
    public var grosortexto: String = ""
    public var habilitado: Bool = false
    public var permitemodal: Bool = false
    public var visible: Bool = false
    
    ///////////////////////// ESTAN AQUÍ Y NO EN WEB ///////////////////////////////
    public var ocultarsubtitulo: Bool = false
    public var subtitulo: String = ""
    public var ayuda: String = ""
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO///////////////////////////////
    public var activo: Bool = false
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var modotab: Bool = false
    public var mostrar: Bool = false
    public var mostrarmodal: Bool = false
    public var sectioncollapsed: Bool = false
    public var tipo: String = "seccion"
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
