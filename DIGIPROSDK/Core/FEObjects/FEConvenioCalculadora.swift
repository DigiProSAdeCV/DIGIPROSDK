//
//  FEConvenioCalculadora.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 17/03/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEConvenioCalculadora: EVObject {
    
    public var convenioId: String = ""
    public var convenioName: String = ""
    public var convenioShortname: String = ""
    public var convenioNombre: String = ""
    public var convenioGoup: String = ""
    public var convenioBRMSCode: String = ""
    public var enterpriseName: String = ""
    public var Productos = Array<FEProductCalculadora>()
    public var montoMaximo: Int = 0
    public var montoMinimo: Int = 0
    public var aplicaOriginacionPaperless: Bool = false
    public var branchName: String = ""
}
