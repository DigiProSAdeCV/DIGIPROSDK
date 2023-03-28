//
//  NetPayShipping.swift
//  DIGIPROSDKNTP
//
//  Created by Alberto Echeverri Carrillo on 22/04/21.
//

import Foundation

public struct NetPayShipping: Codable {
    var city: String?
    var country: String?
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var postalCode: String?
    var state: String?
    var street1: String?
    var street2: String?
    var shippingMethod: String = "flatrate_flatrate"
}
