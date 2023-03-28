//
//  AjaxResponse.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 19/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class AjaxResponse: EVObject{
    public var Success = false
    public var Mensaje = ""
    public var ReturnedObject:NSDictionary? = nil
    public required init() {}
}

public class AjaxResponseSimple: EVObject{
    public var Success = false
    public var Mensaje = ""
    public var ReturnedObject:String? = nil
    public required init() {}
}
