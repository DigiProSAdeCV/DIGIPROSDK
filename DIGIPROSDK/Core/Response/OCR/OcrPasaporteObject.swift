//
//  OcrPasaporteObject.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 9/9/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class OcrPasaporteObject: EVObject{
    
    // Anchors
    public var anchortipo: String =                         ""
    public var anchorclavedelpais: String =                 ""
    public var anchorpasaportenumero: String =              ""
    public var anchoraPaterno: String =                     ""
    public var anchoraMaterno: String =                     ""
    public var anchornombres: String =                      ""
    public var anchornacionalidad: String =                 ""
    public var anchorobservaciones: String =                ""
    public var anchorfechanacimiento: String =              ""
    public var anchorcurp: String =                         ""
    public var anchorsexo: String =                         ""
    public var anchorlugarnacimiento: String =              ""
    public var anchorfechaexpedicion: String =              ""
    public var anchorfechacaducidad: String =               ""
    public var anchorautoridad: String =                    ""
    public var motor: String =                              ""
    
    // Validation Anchors
    public var detectedtipo: Bool =                         false
    public var detectedclavedelpais: Bool =                 false
    public var detectedpasaportenumero: Bool =              false
    public var detectedaPaterno: Bool =                     false
    public var detectedaMaterno: Bool =                     false
    public var detectednombres: Bool =                      false
    public var detectednacionalidad: Bool =                 false
    public var detectedobservaciones: Bool =                false
    public var detectedfechanacimiento: Bool =              false
    public var detectedcurp: Bool =                         false
    public var detectedsexo: Bool =                         false
    public var detectedlugarnacimiento: Bool =              false
    public var detectedfechaexpedicion: Bool =              false
    public var detectedfechacaducidad: Bool =               false
    public var detectedautoridad: Bool =                    false
    
    public var tipo: String =                               ""
    public var clavedelpais: String =                       ""
    public var pasaportenumero: String =                    ""
    public var aPaterno: String =                           ""
    public var aMaterno: String =                           ""
    public var nombres: String =                            ""
    public var nacionalidad: String =                       ""
    public var observaciones: String =                      ""
    public var fechanacimiento: String =                    ""
    public var curp: String =                               ""
    public var sexo: String =                               ""
    public var lugarnacimiento: String =                    ""
    public var fechaexpedicion: String =                    ""
    public var fechacaducidad: String =                     ""
    public var autoridad: String =                          ""

    public var detectados: Int =                            0
    public var totales: Int =                               0
    public var obtenerFrontal: Bool =                       false
    public var obtenerReverso: Bool =                       false
    
}
