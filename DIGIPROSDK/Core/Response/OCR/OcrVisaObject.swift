//
//  OcrVisaObject.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 18/11/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class OcrVisaObject: EVObject{
        
    // Anchors
    public var anchorvisa: String =                         ""
    public var anchorsurname: String =                      ""
    public var anchorgivennames: String =                   ""
    public var anchordatebirth: String =                    ""
    public var anchornationality: String =                  ""
    public var anchorsex: String =                          ""
    public var anchordateissue: String =                    ""
    public var anchorexpireson: String =                    ""
    public var anchorequivalencevalue: String =             ""
    public var anchordocumenttype: String =                 ""
    public var anchorcountryissuance: String =              ""
    public var anchordocumentnumber: String =               ""
    public var anchorinventorycontrolnumber: String =       ""
    public var motor: String =                              ""
    
    // Validation Anchors
    public var detectedvisa: Bool =                         false
    public var detectedsurname: Bool =                      false
    public var detectedgivennames: Bool =                   false
    public var detecteddatebirth: Bool =                    false
    public var detectednationality: Bool =                  false
    public var detectedsex: Bool =                          false
    public var detecteddateissue: Bool =                    false
    public var detectedexpireson: Bool =                    false
    public var detectedequivalencevalue: Bool =             false
    public var detecteddocumenttype: Bool =                 false
    public var detectedcountryissuance: Bool =              false
    public var detecteddocumentnumber: Bool =               false
    public var detectedinventorycontrolnumber: Bool =       false
    
    public var visaClass: String =                  ""
    public var visaType: String =                   ""
    public var apellidos: String =                  ""
    public var aPaterno: String =                   ""
    public var aMaterno: String =                   ""
    public var nombre: String =                     ""
    public var fecha: String =                      ""
    public var nacionalidad: String =               ""
    public var sexo: String =                       ""
    public var dateIssue: String =                  ""
    public var expiresOn: String =                  ""
    public var equivalenceValue: String =           ""
    public var documentType: String =               ""
    public var countryIssuance: String =            ""
    public var documentNumber: String =             ""
    public var inventoryControlNumber: String =     ""

    public var detectados: Int =                0
    public var totales: Int =                   0
    public var obtenerFrontal: Bool =           false
    public var obtenerReverso: Bool =           false
    
}
