//
//  Colors.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 3/6/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

extension UIColor {
    
    public convenience init(hexFromString:String, alpha:CGFloat = 1.0) {
        var cString:String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 3) {
            cString = "\(cString)\(cString)"
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    
    // Kind of Colors
    public func setStateMessage(_ state: String)->UIColor{
        switch state {
        case "message": return UIColor(red: 49/255, green: 130/255, blue: 217/255, alpha: 1.0)
        case "valid": return UIColor(red: 59/255, green: 198/255, blue: 81/255, alpha: 1.0)
        case "alert": return UIColor(red: 249/255, green: 154/255, blue: 0/255, alpha: 1.0)
        case "error": return UIColor(red: 227/255, green: 90/255, blue: 102/255, alpha: 1.0)
        default: return UIColor(red: 49/255, green: 130/255, blue: 217/255, alpha: 1.0)
        }
    }
    
    
    
}
