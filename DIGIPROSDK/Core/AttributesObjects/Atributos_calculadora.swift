//
//  Atributos_calculadora.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 7/1/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class Atributos_calculadora: Atributos_Generales
{
    public var alineadotexto: String = ""
    public var campo: String = ""
    public var decimalesresultado: Int = 0
    public var estilotexto: String = ""
    public var formulaimportecuota: String = ""
    public var formulaplazocuota: String = ""
    public var formulaplazoimporte: String = ""
    public var formulatea: String = ""
    public var formulatem: String = ""
    public var habilitado: Bool = false
    public var idcuota: String = ""
    public var idimporte: String = ""
    public var idplazo: String = ""
    public var intervaloimporte: Int = 0
    public var intervalomeses: Int = 0
    public var maximporte: Int = 0
    public var maxmes: Int = 0
    public var minimporte: Int = 0
    public var minmes: Int = 0
    public var ocultarsubtitulo: Bool = false
    public var opcionmostrar: String = ""
    public var resultadocalculoactual: Int = 0
    public var subtitulo: String = ""
    public var tasaefectivaanual: Double = 0.0
    public var tasaefectivamensual: Double = 0.0
    public var tasanominalanual: Double = 0.0
    public var valorcuota: Int = 0
    public var valorimporte: Int = 0
    public var valorplazo: Int = 0
    public var visible: Bool = false
    
    //////////////////////// ESTAN AQUÍ Y NO EN WEB //////////////////////////////////
    public var colorborde: String = ""
    public var decoraciontexto: String = ""
    public var grosorborde: Int = 0
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO/////////////////////////////////
    public var bindcondition: Bool = false
    public var campocss: String = ""                //  NO Aplica
    public var colorcalculadora: String = ""
    public var colortextoencabezadocalculadora: String = ""
    public var elementrendered: Bool = false
    public var executeonce: Bool = false
    public var haserror: Bool = false
    public var interes: Int = 0
    public var prestamo: Int = 0
    public var prestamototal: Int = 0
    public var tipo: String = "calculadorafinanciera"
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
