//
//  FELogaltyDocuments.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 5/10/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FELogaltyDocuments: EVObject {
    public var type = ""
    public var base64 = ""
    
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
