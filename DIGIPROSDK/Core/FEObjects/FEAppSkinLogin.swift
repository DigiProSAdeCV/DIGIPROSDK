//
//  FEAppSkinLogin.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 01/08/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEAppSkinLogin: EVObject {
    public var NombreLogo = ""
    public var Logo = ""
    public var LogoHeight = ""
    public var LogoWidth = ""
    public var NombreBackGround = ""
    public var BackGround = ""
    public var BienvenidosTexto = ""
    public var BienvenidosTamano = ""
    public var BienvenidosColor = ""
    public var SubtituloTexto = ""
    public var SubtituloTamano = ""
    public var SubtituloColor = ""
    public var EtiquetaUsuario = ""
    public var EtiquetaUsuarioColor = ""
    public var EtiquetaPassword = ""
    public var EtiquetaPasswordColor = ""
    public var BotonTexto = ""
    public var BotonColor = ""
    
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.count == 0 || value == "null" {
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            return true
        } else if value is NSNull {
            return true
        }
        return false
    }
}
