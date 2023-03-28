//
//  FEGenericResponse.swift
//  DIGIPROSDK
//
//  Created by Carlos Mendez Flores on 02/12/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEConsultaBuroCredito: EVObject {
    public var id : String? = ""
    public var initialmethod : String? = ""
    public var assemblypath : String? = ""
    public var prefijoentrada : String? = ""
    public var prefijosalida : String? = ""
    public var pin : FEPin? = nil
    public var pout : [String]? = []
    public var response : FEResponse? = nil
    public var data : FEData? = nil
}

public class FEData : EVObject {
    public var numeroControlConsulta : String = ""
    public var valorScore : String = ""
    public var descripcion : String = ""
    public var aprobado : Bool = false
}

public class FEPin : EVObject {
    public var method : [String]? = []
    public var system : [String]? = []
}

public class FEResponse : EVObject {
    public var success : Bool? = false
    public var error : String? = ""
    public var servicesuccess : Bool? = false
    public var servicemessage : String? = ""
    public var showmessage : Bool? = false
    public var messagetype : String? = ""
    public var rulesuccess : String? = ""
    public var ruleerror : String? = ""
}
