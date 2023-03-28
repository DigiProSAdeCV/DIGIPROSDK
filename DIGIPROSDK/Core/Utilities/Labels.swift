//
//  Labels.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 7/18/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

extension UILabel{
    
    public func setAlignment(_ align: String) -> NSTextAlignment{
        switch align {
        case "left": return .left
        case "center": return .center
        case "right": return .right
        case "justify": return .justified
        default: return .left
        }
    }
    
    public func calculateMaxHeight() -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.size.height
    }
    
    public func calculateMaxLines(_ width: CGFloat? = nil) -> Int {
        let maxSize = CGSize(width: width ?? self.frame.width, height: CGFloat(Float.infinity))
        let charSize = self.font?.lineHeight ?? 0.0
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
    public func calculateMaxLines2(_ width: CGFloat? = nil, aux: UIFont) -> Int {
        let maxSize = CGSize(width: width ?? self.frame.width, height: CGFloat(Float.infinity))
        let charSize = aux.pointSize
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: aux], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
    public func calculateMaxLinesTransition (widthH: CGFloat) -> Int {
        let maxSize = CGSize(width: widthH, height: CGFloat(Float.infinity))
        let charSize = self.font?.lineHeight ?? 0.0
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
    public func setText(_ text: String, withColorPart colorTextPart: String, color: UIColor) {
        attributedText = nil
        let result =  NSMutableAttributedString(string: text)
        result.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSString(string: text.lowercased()).range(of: colorTextPart.lowercased()))
        attributedText = result
    }
}
