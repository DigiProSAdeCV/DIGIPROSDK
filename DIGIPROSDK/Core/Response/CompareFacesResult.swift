//
//  CompareFacesResult.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 4/3/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public class CompareFacesJson: EVObject{
    public var imagen1 = ""
    public var imagen2 = ""
    public var proveedor = ""
}

public class CompareFacesResult: EVObject{
    public var DescripcionRespuesta = ""
    public var RespuestaServicio = ""
    public var Provedor = ""
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var User = ""
    public var Rostro1 = ""
    public var Rostro2 = ""
    public var Score = ""
}

public class CompareFacesResponse: EVObject{
    public var accioncorrecta = ""
    public var accionincorrecta = ""
    public var mensaje = ""
    public var score = ""
}
