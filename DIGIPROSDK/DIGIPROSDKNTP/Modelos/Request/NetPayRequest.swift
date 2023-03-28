//
//  NetPayRequest.swift
//  DIGIPROSDKNTP
//
//  Created by Alberto Echeverri Carrillo on 22/04/21.
//

import Foundation

public struct NetPayRequest : Codable { //Prueba
    var description: String
    var source: String ///Token recibido de NetPaySDK
    var paymentMethod: String
    var amount: Double
    var currency: String
    var billing: NetPayBilling
    var ship: NetPayShipping
    var redirect3dsUri: String
}
