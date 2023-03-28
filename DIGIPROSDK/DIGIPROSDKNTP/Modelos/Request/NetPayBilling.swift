//
//  NetPayBilling.swift
//  DIGIPROSDKNTP
//
//  Created by Alberto Echeverri Carrillo on 22/04/21.
//

import Foundation

public struct NetPayBilling: Codable {
    var firstName: String?
    var lastName: String?
    var email: String?
    var phone: String?
    var address: NetPayBillingAddress?
    var merchantReferenceCode: String?
}

public struct NetPayResponseBilling: Codable {
    var firstName: String?
    var lastName: String?
    var email: String?
    var phone: String?
    var address: NetPayBillingAddress?
    var ipAddress: String?
    var merchantReferenceCode: String?
}

struct NetPayBillingAddress: Codable {
    var city: String?
    var country: String?
    var postalCode: String?
    var state: String?
    var street1: String?
    var street2: String?
}
