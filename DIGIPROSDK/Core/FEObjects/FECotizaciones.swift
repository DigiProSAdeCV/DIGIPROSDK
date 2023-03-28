//
//  FECotizaciones.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 26/03/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FECotizaciones: EVObject {
    public var cat: Double = 0.0
    public var discountAmount: Double = 0.0
    public var estimatedCommision: Int = 0
    public var frequencyDescription: String = ""
    public var interestRate: Double = 0.0
    public var plazo: Int = 0
    public var priceGroupId: String = ""
    public var requestedAmount: Double = 0.0
    public var totalAmount: Double = 0.0
    public var tasaanual: Double = 0.0
    public var tasamensual: Double = 0.0
    public var descx: Double = 0.0
}
