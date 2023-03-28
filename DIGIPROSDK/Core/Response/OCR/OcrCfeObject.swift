//
//  OcrCfeObject.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 9/9/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class OcrCfeObject: EVObject{
    // Anchors
    public var anchornombre: String =           "" // Nombre y Domicilio
    public var motor: String =                  ""
    
    // Validation Anchors
    public var detecteddomicilio: Bool =        false
    public var detectednombre: Bool =           false
    
    public var nombre: String =                 ""
    public var calle: String =                  ""
    public var colonia: String =                ""
    public var delegacion: String =             ""
    public var ciudad: String =                 ""
    public var cP: String =                     ""
    public var rmu: String =                    ""
}
