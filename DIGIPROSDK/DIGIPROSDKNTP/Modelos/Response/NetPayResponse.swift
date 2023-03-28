//
//  NetPayResponse.swift
//  DIGIPROSDKNTP
//
//  Created by Alberto Echeverri Carrillo on 22/04/21.
//

import Foundation

public struct NetPayResponse: Codable {
    var client: String?
    var source: String?
    var amount: Int?
    var description: String?
    var status: String?
    public var transactionTokenId: String?
    var redirect3dsUri: String?
    var returnUrl: String?
    var paymentMethod: String?
    var currency: String?
    var createdAt: String?
    var error: String?
    var installments: String?
    var ship: NetPayShipping?
    var paymentSource: NetPayPaymentSource?
    var billing: NetPayResponseBilling?
}
