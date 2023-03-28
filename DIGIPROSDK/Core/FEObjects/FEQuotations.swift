//
//  FEQuotations.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 15/04/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEQuotations: EVObject {
    public var status: String = ""
    public var code: String = ""
    public var response: String = ""
    public var ProductId: String = ""
    public var Order: Int = 0
    public var Plazo: Int = 0
    public var Interest: Double = 0.0
    public var quotations = Array<FECotizaciones>()

}

