//
//  Applications.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 9/18/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

internal extension UIApplication {
    class func safeAreaBottom() -> CGFloat {
        let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
        let bottomPadding: CGFloat
        if #available(iOS 11.0, *) {
            bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
        } else {
            bottomPadding = 0.0
        }
        return bottomPadding
    }
    
    class func safeAreaTop() -> CGFloat {
        let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
        let bottomPadding: CGFloat
        if #available(iOS 11.0, *) {
            bottomPadding = window?.safeAreaInsets.top ?? 0.0
        } else {
            bottomPadding = 0.0
        }
        return bottomPadding
    }
}


