//
//  AlertExt.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 13/06/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import UIKit

extension UIAlertAction {
    public var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}
