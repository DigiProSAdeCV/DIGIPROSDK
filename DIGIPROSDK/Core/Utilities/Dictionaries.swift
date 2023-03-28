//
//  Dictionaries.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 7/26/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public extension Dictionary {
    func nullKeyRemoval() -> Dictionary {
        var dict = self
        
        let keysToRemove = Array(dict.keys).filter { dict[$0] is NSNull }
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }        
        return dict
    }
}
