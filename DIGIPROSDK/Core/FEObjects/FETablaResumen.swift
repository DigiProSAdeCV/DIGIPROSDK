//
//  FETablaResumen.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 08/02/21.
//  Copyright © 2021 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FETablaResumen: EVObject{
    ///Por defecto es 0 para la tabla ya que el servicio no acepta una tabla sin orden aunque el formato no tenga tabla en el resumen.
    public var valor: String = ""
    public var orden: String = "0"
    public var filas = Array<FETablaFilas>()
}


public class FETablaFilas: EVObject{
    public var valores = Array<FETablaValores>()
}

public class FETablaValores: EVObject{
    public var columna: String = ""
    public var valor: String = ""
    public var orden: String = ""
}
