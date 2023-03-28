//
//  HeightLabel.swift
//  FE
//
//  Created by Jonathan Viloria M on 11/26/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation
import UIKit

public extension UITextView{
    
    var optimalHeight : CGFloat {
        get
        {
            let label = UITextView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
            label.font = self.font
            label.text = self.text
            label.sizeToFit()
            return label.frame.height + 30
        }
    }
    
    func calculateMaxLines(_ width: CGFloat? = nil) -> Int {
        let maxSize = CGSize(width: width ?? self.frame.width, height: CGFloat(Float.infinity))
        let charSize = self.font?.lineHeight ?? 0.0
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
