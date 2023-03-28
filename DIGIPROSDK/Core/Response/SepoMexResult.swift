//
//  SepoMexResult.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 10/1/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class SepoMexResult: EVObject{
    public var CodigoPostal = "";
}

public class SepomexResponse: EVObject{
    public var folio = ""
    public var Item1 = ""
    public var Item2 = ""
    public var Item3 = ""
    public var mensaje = ""
    public var accioncorrecta = ""
    public var accionincorrecta = ""
    public var estado = ""
    public var colonias = ""
    public var delegacion = ""
}

public class SepomexJson: EVObject{
    public var cp: String = ""
}
