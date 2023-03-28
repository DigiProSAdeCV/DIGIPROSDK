//
//  RoundNumber.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/30/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public extension Double{
    
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
}
