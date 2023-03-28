//
//  IneResultOcr.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/17/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class OcrIneObject: EVObject{
    // Anchors
    public var anchorcic: String =              ""
    public var anchorclaveelector: String =     ""
    public var anchorcurp: String =             ""
    public var anchordomicilio: String =        ""
    public var anchoremision: String =          ""
    public var anchorestado: String =           ""
    public var anchorfolio: String =            ""
    public var anchorlocalidad: String =        ""
    public var anchormunicipio: String =        ""
    public var anchornombre: String =           ""
    public var anchorregistro: String =         ""
    public var anchorseccion: String =          ""
    public var anchorsexo: String =             ""
    public var anchorvigencia: String =         ""
    public var motor: String =                  ""
    
    // Validation Anchors
    public var detectedcic: Bool =              false
    public var detectedocr: Bool =              false
    public var detectedclaveelector: Bool =     false
    public var detectedcurp: Bool =             false
    public var detecteddomicilio: Bool =        false
    public var detectedemision: Bool =          false
    public var detectedestado: Bool =           false
    public var detectedfolio: Bool =            false
    public var detectedlocalidad: Bool =        false
    public var detectedmunicipio: Bool =        false
    public var detectednombre: Bool =           false
    public var detectedregistro: Bool =         false
    public var detectedseccion: Bool =          false
    public var detectedsexo: Bool =             false
    public var detectedvigencia: Bool =         false
    public var detectedfecha: Bool =            false
    
    public var nombre: String =                 ""
    public var aPaterno: String =               ""
    public var aMaterno: String =               ""
    public var calle: String =                  ""
    public var colonia: String =                ""
    public var delegacion: String =             ""
    public var ciudad: String =                 ""
    public var cP: String =                     ""
    public var curp: String =                   ""
    public var rfc: String =                    ""
    public var seccion: String =                ""
    public var claveElector: String =           ""
    public var vigencia: String =               ""
    public var fecha: String =                  ""
    public var edad: String =                   ""
    public var sexo: String =                   ""
    public var folio: String =                  ""
    public var registro: String =               ""
    public var municipio: String =              ""
    public var localidad: String =              ""
    public var reposicion: String =             ""
    public var estado: String =                 ""
    public var cic: String =                    ""
    public var ocr: String =                    ""
    public var emision: String =                ""
    public var ineanverso: String =             ""
    public var inereverso: String =             ""

    public var detectados: Int =                0
    public var totales: Int =                   0
    public var obtenerFrontal: Bool =           false
    public var obtenerReverso: Bool =           false
    
}
