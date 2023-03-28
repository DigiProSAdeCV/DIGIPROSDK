//
//  NetPayPaymentSource.swift
//  DIGIPROSDKNTP
//
//  Created by Alberto Echeverri Carrillo on 22/04/21.
//

import Foundation

public struct NetPayPaymentSource: Codable {
    
    var cardDefault: Bool?
    var card: NetPayCard?
    var source: String?
    var type: String?
    
    struct NetPayCard: Codable {
       var token: String?
       var expYear: String?
       var expMonth: String?
       var lastFourDigits: String?
       var cardHolderName: String?
       var brand: String?
       var deviceFingerPrint: String?
       var ipAddress: String?
       var bank: String?
       var type: String?
       var country: String?
       var scheme: String?
       var cardPrefix: String?
    }
}

