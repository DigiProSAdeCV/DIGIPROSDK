//
//  FEProductCalculadora.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 17/03/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEProductCalculadora: EVObject {
    public var productId: String = ""
    public var productName: String = ""
    public var productShortname: String = ""
    public var productCategory: String = ""
    public var productBRMSCode: String = ""
    public var plazoMinimo: String = ""
    public var plazoMaximo: String = ""
    public var montoMinimo: String = ""
    public var montoMaximo: String = ""
    public var openingCommissionAmount: String = ""
    public var openingCommissionPercentage: Double = 0.0
    public var productFrequency: String = ""
    public var productFrequencyCode: String = ""
    public var order: Int = -1
    public var flagCot: Bool = false
}
