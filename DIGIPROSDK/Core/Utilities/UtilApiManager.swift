//
//  UtilApiManager.swift
//  DIGIPROSDK
//
//  Created by Carlos Mendez Flores on 24/08/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import CommonCrypto

enum EncriptError: Error {
    case invalidData
    case InvalidParameters
    case InvalidXml
}

public extension APIManager {
    
    func decodeReturnSoap(_ getEncodeData: String) throws -> String {
        guard let decodedData = Data(base64Encoded: getEncodeData) else {  throw EncriptError.invalidData }
        let decryptSoap = decodedData.aesEncrypt(keyData: ConfigurationManager.shared.keyaes.data(using: .utf8, allowLossyConversion: false)!, ivData: ConfigurationManager.shared.ivaes.data(using: .utf8, allowLossyConversion: false)!, operation: kCCDecrypt)
        
        if decryptSoap.isEmpty {
            throw EncriptError.invalidData
        }
        
        //guard let encodingSoap = String(bytes: decryptSoap, encoding: .utf8)  else {  throw EncriptError.invalidData }
        var encodingSoap : String = ""
        if let Soap = String(bytes: decryptSoap, encoding: .utf8) {
            print("La conversión de bytes a string es exitosa: \(encodingSoap)")
            encodingSoap = Soap
            
        } else if let Soap = String(bytes: decryptSoap, encoding: .isoLatin1) {
            print("La conversión de bytes a string es exitosa: \(encodingSoap)")
            encodingSoap = Soap
        } else {
            print("La conversión de bytes a string falló")
        }
        return encodingSoap
    }
    
}

public extension Date {
    private static let CTicksAt1970 : UInt64 = 621_355_968_000_000_000
    private static let CTicksPerSecond : Double = 10_000_000
    
    private static let CTicksMinValue : UInt64 = 0
    private static let CTicksMaxValue : UInt64 = 3_155_378_975_999_999_999
    
    
    // Method to create a Swift Date struct to reflect the instant in time specified by a "ticks"
    // value, as used in .Net DateTime structs.
//    internal static func swiftDateFromDotNetTicks(_ dotNetTicks : Int64) -> Date {
//
//        if dotNetTicks == CTicksMinValue {
//            return Date.distantPast
//        }
//
//        if dotNetTicks == CTicksMaxValue {
//            return Date.distantFuture
//        }
//
//        let dateSeconds = Double(dotNetTicks - CTicksAt1970) / CTicksPerSecond
//        return Date(timeIntervalSince1970: dateSeconds)
//    }
//
    
    // Method to "convert" a Swift Date struct to the corresponding "ticks" value, as used in .Net
    // DateTime structs.
    static func getTicks() -> UInt64 {
        let date = Date().getCurrentLocalDate()
        let dateSeconds = Double(date.timeIntervalSince1970)
        let ticksSince1970 = UInt64(round(dateSeconds * CTicksPerSecond))
        return CTicksAt1970 + ticksSince1970
    }
    
    func getCurrentLocalDate()-> Date {
        var now = Date()
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: now)
        nowComponents.month = Calendar.current.component(.month, from: now)
        nowComponents.day = Calendar.current.component(.day, from: now)
        nowComponents.hour = Calendar.current.component(.hour, from: now)
        nowComponents.minute = Calendar.current.component(.minute, from: now)
        nowComponents.second = Calendar.current.component(.second, from: now)
        nowComponents.timeZone = TimeZone(abbreviation: "GMT")!
        now = calendar.date(from: nowComponents)!
        return now as Date
    }
    
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 621_355_968) * 10_000_000)
    }
}
