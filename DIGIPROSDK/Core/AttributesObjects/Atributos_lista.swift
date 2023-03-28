//
//  Atributos_lista.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 13/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_lista: Atributos_Generales
{
    public var alineadotexto: String = "";                          // left, center, right, justify
    public var ayuda: String = ""
    public var campo: String = "";
    public var cascadahijo: String = "";
    public var cascadapadre: Bool = false;
    public var catalogodestino: Bool = false
    public var catalogoorigen: String = ""
    public var catalogossistema: String = ""
    public var configjson: String = ""
    public var configuracioncascada: String = ""
    public var decoraciontexto: String = "";                        // none, underline, line-through
    public var estilotexto: String = "";                            // normal, italic
    public var eventos: Eventos = Eventos()                         //  "alcambiar"
    public var filtrarcatalogo: FiltrarCatalogo = FiltrarCatalogo()
    public var fuentedatos: String = "";
    public var grosortexto: String = "";
    public var habilitado: Bool = false
    public var maxopcionesseleccionar: Int = 0
    public var metadato: String = ""
    public var minopcionesseleccionar: Int = 0
    public var modobusqueda: Bool = false
    public var ocultarsubtitulo: Bool = false
    public var ordenitems: String = ""
    public var orientacion: String = "";
    public var pdfcampo: String = ""
    public var requerido: Bool = false
    public var subtitulo: String = ""
    public var textoconid: String = ""
    public var imageposition: String = ""
    public var tieneesquema: Bool = false
    public var tipoasociacion: String = ""
    public var tipolista: String = ""
    public var valor: String = ""
    public var valorlista: Bool = false
    public var valormetadato: Bool = false
    public var visible: Bool = false
    public var todasopcionesrequeridas: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var alineadocampo: String = ""
    public var ordenenresumen: Int = 0
    public var usarcomocampoexterno: Bool = false
    public var usarcomoresumen: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var bindcondition: Bool = false                          //  NO Aplica
    public var campocss: String = ""                                //  NO Aplica
    public var elementrendered: Bool = false                        //  NO Aplica
    public var executeonce: Bool = false                            //  NO Aplica
    public var haserror: Bool = false                               //  NO Aplica
    public var tipo: String = "lista"
    public var validationerror: String = ""                         //  NO Aplica
    public var tipoasociacionObject: [String:Any] = [:]
    
    public var tipolistaObject: [String:Any] = [:]
    
    public var optionselected: String = ""
    
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

//////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
public class FiltrarCatalogo: EVObject
{
    public var filtrar: Bool = false
    public var idfiltrados: String = ""
    public var rangofiltrado: String = ""
}
