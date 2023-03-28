//
//  FolioAutomaticoResult.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/25/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FolioAutomaticoResult: EVObject{
    public var DescripcionRespuesta = ""
    public var RespuestaServicio = ""
    public var Provedor = ""
    public var Proveedor = ""
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var ExpId = 0
    public var GrupoId = 0
    public var Folio = ""
    public var User = ""
    public var Item1 = ""
}

public class FolioResponse: EVObject{
    public var folio = ""
    public var Item1 = ""
    public var mensaje = ""
    public var accioncorrecta = ""
    public var accionincorrecta = ""
}
