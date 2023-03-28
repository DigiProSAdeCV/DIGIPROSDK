//
//  FEProcesos.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 3/14/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public class FEProcesos: EVObject{
    public var FlujoID = 0
    public var NombreProceso = ""
    public var PIID = 0
    public var CounterFormats: Int = 0
    
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.count == 0 || value == "null" {
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            return true
        } else if value is NSNull {
            return true
        }
        return false
    }
}
