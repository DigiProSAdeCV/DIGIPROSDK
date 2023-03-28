//
//  FEUsuario.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 20/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEUserAddress: EVObject{
    public var DomicilioID: Int = 0
    public var Descripcion: String = ""
    public var CalleNumero: String = ""
    public var Colonia: String = ""
    public var DelMun: String = ""
    public var Estado: String = ""
    public var CP: String = ""
    public var Pais: String = ""
}

public class FEUsuario: EVObject{
    public var User = ""
    public var Password = ""
    public var IP = ""
    public var ProyectoID = 0
    public var AplicacionID = 0
    public var Nombre = ""
    public var ApellidoP = ""
    public var ApellidoM = ""
    public var NombreCompleto = ""
    public var GrupoAdminID = 0 // 10 - Administrador 13 - SiteManager
    public var Foto = ""
    public var PermisoScreenshot = false
    public var PermisoEditarFormato = false
    public var PermisoDescargarAnexos = false
    public var PendientesEstadoMapa = 0
    public var PermisoValidarFormato = false
    public var PermisoVerMapa = false
    public var PermisoBorrarFormato = false
    public var PermisoPendientesPorEnviar = false
    public var PermisoNuevoFormato = false
    public var PermisoSalirConCambios = false
    public var PermisoVisualizarFormato = false
    public var PerfilUsuarioID: Int = 0
    public var PasswordEncoded = ""
    public var CurrentPasswordEncoded = ""
    public var PasswordNuevo = ""
    public var NewPasswordEncoded = "" 
    public var Consultas: Array<FETipoReporte> = [FETipoReporte]()
    public var HasDownloadedContent: Bool = false
    public var UserThumbnail: String = ""
    public var UserAddress: String = ""
    public var Email: String = ""
    public var TokenDispositivo : String = "" // Token interno del dispositivo
    public var ProveedorPush : String  = "" // "IOS"
    public var Mensajes : String  = ""
    public var AceptoTerminos: Bool = false
    public var Token: FETokenSeguridad = FETokenSeguridad()
}
