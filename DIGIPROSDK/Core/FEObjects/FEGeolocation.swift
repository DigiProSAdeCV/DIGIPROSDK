//
//  FEGeolocation.swift
//  DIGIPROSDK
//
//  Created by Desarrollo on 13/01/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEGeolocation: EVObject
{
    public var Referencias = Array<FEGeolocationData>()
    public var UsrID = ""
    public var DeviceID = ""
    
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.count == 0 || value == "null" {
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            return true
        } else if value is NSNull {
            return true
        }
        // MARK - Override to clean console from missing attributes warnings
        return false
    }
}

public class FEGeolocationData: EVObject
{
    public var FechaHoraIni = ""
    public var FechaHoraFin = ""
    public var Ubicacion = ""
        
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.count == 0 || value == "null" {
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            return true
        } else if value is NSNull {
            return true
        }
        // MARK - Override to clean console from missing attributes warnings
        return false
    }
}
