//
//  SmsServicio.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 1/9/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public class SmsServicio: EVObject{
    public var Usuario = ""
    public var Telefono = ""
    public var Codigo = ""
    public var Enviado = false
    public var Validado = false
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var TipoSms = 1
}
