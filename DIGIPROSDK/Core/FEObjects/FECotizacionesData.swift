//
//  FECotizacionesData.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 05/04/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FECotizacionesData: EVObject {
    public var status: String = ""
    public var ProductId: Int = 0
    public var response: String = ""
    public var code: Int = 0
    public var quotations = Array<FECotizaciones>()
}
