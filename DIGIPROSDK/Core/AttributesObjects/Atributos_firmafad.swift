//
//  Atributos_firmafad.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 27/12/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation



public class Atributos_firmafad: Atributos_Generales {
        //OK
        public var acuerdofirma : String = ""
        public var alineadotexto : String = ""
        public var anteriornombrearchivo: String = ""
        public var ayuda: String = ""
        public var campo : String = ""
        public var decoraciontexto : String = ""
        public var dispositivo: String = ""
        public var estilotexto : String = ""
        public var eventos : Eventos = Eventos ()   //  "alterminarcaptura"
        public var fecha: String = ""
        public var georeferencia: String = ""
        public var guidtimestamp: String = ""
        public var habilitado: Bool = false
        public var mostraranimacion: Bool = false
        public var nombrearchivo : String  = ""
        public var nombrefirmante: String = ""
        public var ocultarsubtitulo: Bool = false
        public var pdfcampoanexo : String  = ""
        public var proveedor: String = ""
        public var requerido: Bool = false
        public var subtitulo: String = ""
        public var tipodoc : String = ""
        public var visible: Bool = false
        public var personafirma: String  = ""
        public var tipocodificacion: String = ""
        public var obtenerhash: Bool = false
        public var obtenerpruebasvideo: Bool = false
        public var hashCrypt: String = ""
        public var colorfirma: String = ""
        public var colorborrar: String = ""
        public var colorreemplazar: String = ""
        public var permisotipificar: Bool = false
        public var intervalomaximo: Int = 0
        public var tipovalidacion: String = "video"
        //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
        
        
        ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
        public var anexo: String = ""
        public var bindcondition: Bool = false
        public var campocss: String = ""                //  NO Aplica
        public var elementrendered: Bool = false
        public var executeonce: Bool = false
        public var haserror: Bool = false
        public var tipo: String = "firmafad"
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
