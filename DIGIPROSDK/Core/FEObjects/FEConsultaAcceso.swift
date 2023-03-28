//
//  FEConsultaAcceso.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 12/06/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEConsultaAcceso: EVObject{
    public var actualizacion: String = ""
    public var accesos: [FEAcceso] = []
}

public class FEAcceso: EVObject{
    public var clave: String = "";
    public var codigo: String = "";
    public var descripcion: String = "";
    public var titulo: String = "";
    public var usuario: String = ""
}
