//
//  FEResumenDos.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 08/02/21.
//  Copyright © 2021 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEResumenDos: EVObject {
    public var texto = Array<FETextoResumen>()
    public var imagen = Array<FEImagenResumen>()
    public var tabla = Array<FETablaResumen>()
}
