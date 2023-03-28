//
//  FELicencia.swift
//  FE
//
//  Created by Jonathan Viloria M on 12/11/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FELicencia: EVObject{
    public var NombreProyecto: String = ""
    public var BundleId: String = ""
    public var Fecha_Creacion: Date?
    public var Activo: Bool = false
    public var JsonLicencia: NSMutableDictionary?
    
    override public func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        
        return [ ( key: "Fecha_Creacion"
              , decodeConverter: {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                formatter.locale = NSLocale.current
                self.Fecha_Creacion = formatter.date(from: $0 as! String) ?? nil
                }
              , encodeConverter: { return self.Fecha_Creacion }) ]
    }
    
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
