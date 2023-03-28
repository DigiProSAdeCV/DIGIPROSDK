//
//  StringExtensions.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 01/08/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

public extension String {
        
    /* Info Preferences */
    func dataS() -> String {
        return UserDefaults.standard.string(forKey: self) ?? ""
    }
    
    func dataB() -> Bool {
        return UserDefaults.standard.bool(forKey: self)
    }
    
    func dataI() -> Int {
        return Int(UserDefaults.standard.string(forKey: self) ?? "0") ?? 0
    }
    
    func dataSSet(_ data: Any) {
        UserDefaults.standard.set(data, forKey: self)
        UserDefaults.standard.synchronize()
    }
    
    func dataRemove(){
        UserDefaults.standard.removeObject(forKey: self)
        UserDefaults.standard.synchronize()
    }
    
    /* Localization */
    func langlocalized(_ comment: String = "") -> String {
        return NSLocalizedString(self, bundle: Cnstnt.Path.framework ?? Bundle.main, comment: comment)
        /*let path = Cnstnt.Path.framework?.path (forResource: "es", ofType: "lproj") Solo español
        let languageBundle = Bundle (path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: languageBundle!, value: "", comment: comment)*/
    }
    
    /* Truncate Long String */
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
    
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    // REGEX
    func regexReplace(regEx : String) -> String {
        let regex = try! NSRegularExpression(pattern: regEx, options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, self.count)
        let modString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
        return modString
    }
    
    func regexMatches(regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch { return [] }
    }
    
    // String Base64 to NSData
    func stringBase64EncodeToData() -> NSData{
        let base64String = self
        let dataDecoded:NSData = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0))!
        return dataDecoded
    }
    
    // String Base64 To Image
    func stringBase64EncodeToImage() -> UIImage{
        let base64String = self
        let dataDecoded:NSData = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        return decodedimage
    }
    
    func stringbase64ToImage() -> UIImage?{
        /* Getting Logo Image to Splash Screen */
        var base64String = self
        
        if base64String.contains("data:image/png;base64,"){
            base64String = base64String.replacingOccurrences(of: "data:image/png;base64,", with: "")
        }else if base64String.contains("data:image/jpg;base64,"){
            base64String = base64String.replacingOccurrences(of: "data:image/jpg;base64,", with: "")
        }else if base64String.contains("data:image/jpeg;base64,"){
            base64String = base64String.replacingOccurrences(of: "data:image/jpeg;base64,", with: "")
        }else {
            base64String = ""
        }
        
        if base64String != ""{
            let dataDecoded:NSData = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            return decodedimage
        }
        let decodedimage:UIImage? = nil
        return decodedimage
    }
    
    // ENCODE DECODE URLS
    func encodeUrl() -> String?{
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    
    func decodeUrl() -> String?{
        return self.removingPercentEncoding
    }
    
    // SUBSTRING
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        let range = startIndex..<endIndex
        return String(self[range])
    }
    
    // Ranges
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
   
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(in: CGRect(origin: .zero, size: size),
                                    withAttributes: attributes)
        }
    }
    
    // Upper, Lower
    func upperLower(_ cased: String) -> String{
        switch cased {
        case "normal": return self
        case "upper": return self.uppercased()
        case "lower": return self.lowercased()
        default: return self
        }
    }
    
    // Replacing Ocurrences
    func replaceFormElec() -> String{
        return self.replacingOccurrences(of: "formElec_element", with: "")
    }
    
    func cleanAnexosDocPath() -> String{
        return self.replacingOccurrences(of: "Digipro/Anexos/", with: "")
    }
    
    func cleanFormulaResolveString() -> String{
        var replace = self
        replace = replace.replacingOccurrences(of: "\\r\\n", with: "")
        replace = replace.replacingOccurrences(of: "\\r", with: "")
        replace = replace.replacingOccurrences(of: "\\n", with: "")
        replace = replace.replacingOccurrences(of: "\\t", with: "")
        return replace
    }
    
    func cleanURLString() -> String{
        var replace = self
        replace = replace.replacingOccurrences(of: "\r\n", with: "")
        replace = replace.replacingOccurrences(of: "\r", with: "")
        replace = replace.replacingOccurrences(of: "\n", with: "")
        replace = replace.replacingOccurrences(of: " ", with: "")
        return replace
    }
    
    func cleanFormulaString() -> String{
        var replace = self
        replace = replace.replacingOccurrences(of: "\"", with: "")
        replace = replace.replacingOccurrences(of: " ", with: "")
        replace = replace.replacingOccurrences(of: "\r\n", with: "")
        replace = replace.replacingOccurrences(of: "\r", with: "")
        replace = replace.replacingOccurrences(of: "\n", with: "")
        replace = replace.replacingOccurrences(of: "\t", with: "")
        return replace
    }
    
    func cleanFormulaStringWithoutSpaces() -> String{
        var replace = self
        replace = replace.replacingOccurrences(of: "\"", with: "")
        replace = replace.replacingOccurrences(of: "\r\n", with: "")
        replace = replace.replacingOccurrences(of: "\r", with: "")
        replace = replace.replacingOccurrences(of: "\n", with: "")
        replace = replace.replacingOccurrences(of: "\t", with: "")
        return replace
    }
    
    func replaceLineBreak() -> String{
        var replace = self
        replace = replace.replacingOccurrences(of: "\r\n", with: "|")
        replace = replace.replacingOccurrences(of: "\r", with: "|")
        replace = replace.replacingOccurrences(of: "\n", with: "|")
        replace = replace.replacingOccurrences(of: "\t", with: "|")
        replace = replace.replacingOccurrences(of: "\"", with: "\\\"")
        return replace
    }
    
    func replaceLineBreakEstadistic() -> String{
        var replace = self
        replace = replace.replacingOccurrences(of: "\r\n", with: "|")
        replace = replace.replacingOccurrences(of: "\r", with: "|")
        replace = replace.replacingOccurrences(of: "\n", with: "|")
        replace = replace.replacingOccurrences(of: "\t", with: "|")
        replace = replace.replacingOccurrences(of: "\"", with: "|")
        return replace
    }
    
    func replaceLineBreakJson() -> String{
        var replace = self
        replace = replace.replacingOccurrences(of: "\r\n", with: "")
        replace = replace.replacingOccurrences(of: "\r\t", with: "")
        replace = replace.replacingOccurrences(of: "\r", with: "")
        replace = replace.replacingOccurrences(of: "\n", with: "")
        replace = replace.replacingOccurrences(of: "\t", with: "")
        return replace
    }
    
    func replaceTextInNumberField() -> String{
        let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = self.components(separatedBy: aSet)
        return compSepByCharInSet.joined(separator: "")
    }
    
    func replaceRegex() -> String{
        if self == "*" || self == "." || self == ".*"  || self == "*." || self == "\\w"{
            return ".*+"
        }else{
            return self
        }
    }
    
    func replaceZeros() -> String{
        return self.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
    }
    
    func setDecoration(_ decor: String) -> NSAttributedString?{
        switch decor {
        case "underline": return NSAttributedString(string: "\(self)", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        case "line-through": return NSAttributedString(string: "\(self)", attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        default: return NSMutableAttributedString(string: "\(self)")
        }
    }
    
    // OCR
    /* Override or replace characters */
    func intToString() -> String {
        var newString = ""
        for char in self{
            switch char{
            case "0":
                newString += "o"
                break
            default:
                newString += newString
                break
            }
        }
        return newString
    }
    
    func fileName() -> String {
        return NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent ?? ""
    }
    
    func fileExtension() -> String {
        return NSURL(fileURLWithPath: self).pathExtension ?? ""
    }
    
    func `subscript`(_ range: CountableRange<Int>) -> String {
         let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
         let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
         return String(self[idx1..<idx2])
     }
    
    func currencyFormatter() -> String{
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.perMillSymbol = ","
        var amountWithPrefix = self
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, amountWithPrefix.count), withTemplate: "")
        let ent = Int(amountWithPrefix)
        number = NSNumber(value: (ent ?? 0))
        return formatter.string(from: number)!
    }
    
    // formatting text for currency textField
    func currencyInputFormatting(_ min: Double, _ max: Double) -> String {

        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.perMillSymbol = ","

        var amountWithPrefix = self

        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, amountWithPrefix.count), withTemplate: "")

        let double = Double(amountWithPrefix)?.roundToDecimal(2)
        number = NSNumber(value: (double ?? 0.0))
        // if first number is 0 or all numbers were deleted
        if double ?? 0.0 < min && min != 0{
            number = NSNumber(value: min)
        }
        if double ?? 0.0 > max && max != 0{
            number = NSNumber(value: max)
        }
        guard number ?? 0.0 != 0.0 else {
            return ""
        }
        return formatter.string(from: number)!
    }
    
    func currencyInputFormattingNew() -> String {

         var number: NSNumber!
               let formatter = NumberFormatter()
               formatter.numberStyle = .currencyAccounting
               formatter.currencySymbol = "$"
               formatter.maximumFractionDigits = 2
               formatter.minimumFractionDigits = 2

               var amountWithPrefix = self

               // remove from String: "$", ".", ","
               let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
               amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, amountWithPrefix.count), withTemplate: "")

               let double = (amountWithPrefix as NSString).doubleValue
               number = NSNumber(value: (double / 100))

               // if first number is 0 or all numbers were deleted
               guard number != 0 as NSNumber else {
                   return ""
               }

               return formatter.string(from: number)!
    }
    
    func convertDoubleToCurrency() -> String{
        let amount1 = Double(self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "es_MX")
        if let amount = amount1{
           return numberFormatter.string(from: NSNumber(value: amount))!
        }else{
            return numberFormatter.string(from: NSNumber(value: 0.0))!
        }
    }
    
    func removeFormatAmount() -> Double {
        let formatter = NumberFormatter()

        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.decimalSeparator = ","

        return formatter.number(from: self) as! Double? ?? 0
     }
   
    func toHexEncodedString(uppercase: Bool = true, prefix: String = "", separator: String = "") -> String {
            return unicodeScalars.map { prefix + .init($0.value, radix: 16, uppercase: uppercase) } .joined(separator: separator)
    }
    
    
    func sha512Base64(string: String) -> String {
        let digest = NSMutableData(length: Int(CC_SHA512_DIGEST_LENGTH))!
        if let data = string.data(using: String.Encoding.utf8) {

            let value =  data as NSData
            let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: digest.length)
            CC_SHA512(value.bytes, CC_LONG(data.count), uint8Pointer)

        }
        return digest.base64EncodedString(options: NSData.Base64EncodingOptions([]))
    }
    
    
   

        func fromBase64() -> String? {
            guard let data = Data(base64Encoded: self) else {
                return nil
            }

            return String(data: data, encoding: .utf8)
        }

        func toBase64() -> String {
            return Data(self.utf8).base64EncodedString()
        }
    
}

