//
//  TipoElemento.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 25/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//
import Foundation

// LogType
public enum LogType: String{
    case error
    case warning
    case success
    case action
    case canceled
    case log
}
// Tipo Color Theme
public enum enumColorDefault: String {
    case black = "black"
    case blue = "blue"
    case bluedark = "bluedark"
    case green = "green"
    case red = "red"
    case white = "white"
    case whitelight = "whitelight"
    case yellow = "yellow"
}
// Tipo SMS
public enum EnumTipoSms: Int {
    case ninguno = -1
    case registro = 1
    case credito = 2
}
/// Language description enumerator
public enum Language: String {
    case none = ""
    case en = "English"
    case es = "Spanish"
}
/// Enumerator for kind of errors: .info, .success, .warning, .error
@objc public enum enumErrorType: Int{
    case info       = 0
    case success    = 1
    case warning    = 2
    case error      = 3
    case format     = 4
}
/// Enumerator for https methods used in web services like SOAP and REST: POST & GET
public enum httpMethod: String{
    case POST       = "POST"
    case GET        = "GET"
}
/// Plist Preferences App
public enum plist: String{
    case version =         "version_preference"
    case bundle =          "bundle_preference"
    case idportal =        "bundle_idportal"
    case data =            "data_preference"
    case delete =          "delete_data_preference"
    case member =          "member_app"
    case memberSwitch =    "member_switch"
    case codigo =          "codigo_preference"
    case usuario =         "usuario_preference"
    
    case nombre =          "nombre_validacion"
    case paterno =         "apellido_paterno_validacion"
    case materno =         "apellido_materno_validacion"
    case email =           "correo_electronico_validacion"
    case tel =             "telefono_celular_validacion"
    case estado =          "estado_validacion"
    
    case tutorial =        "data_tutorial"
    case touchid =         "touchid_auth"
    case faceid =          "faceid_auth"
    case calculadora =     "calculadora"
    
    case log =             "data_log"
    case serial =          "serial_developer"
    case tester =          "tester_developer"
    case credifiel =       "tester_credifiel"
    case ventas =          "ventas_developer"
    case implantacion =    "imp_developer"
    case debugger =        "debugger_developer"
    case unittest =        "unittest_developer"

    case debugCode =       "debug_code"
    case debugUser =       "debug_user"
    case debugPass =       "debug_pass"

    case licenceCode =     "licence_code"
    case licenceUser =     "licence_user"
    case licenceMode =     "mode_app"
    
    // Registration data
    case regCell = "CELREG"
    case regMail = "MAILREG"
    case regName = "NAMEREG"
    case regValidate = "VALIDATE"
    case regPass = "PASSREG"
    case regLogin = "LOGINREG"
    
    var label:String? {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first?.label
    }
}


/// Enumerator for all types of elements used in electronic formats: DIGIPROSDK, DIGIPROSDKSO, DIGIPROSDKATO, DIGIPROSDKVO, DIGIPROSDKFO
public enum TipoElemento : String {
    // DIGIPROSDK
    case eventos = "eventos"
    case plantilla = "plantilla"
    case pagina = "pagina"
    case seccion = "seccion"
    // DIGIPROSDKSO
    case boton = "boton"
    case comboboxtemporal = "comboboxtemporal"
    case combodinamico = "combodinamico"
    case deslizante = "deslizante"
    case espacio = "espacio"
    case fecha = "fecha"
    case hora = "hora"
    case leyenda = "leyenda"
    case lista = "lista"
    case logico = "logico"
    case logo = "logo"
    case moneda = "moneda"
    case numero = "numero"
    case password = "password"
    case rangofechas = "rangofechas"
    case semaforotiempo = "semaforotiempo"
    case tabber = "tabber"
    case tabla = "tabla"
    case texto = "texto"
    case textarea = "textarea"
    case wizard = "wizard"
    case metodo = "metodo"
    case servicio = "servicio"
    case marcadodocumentos = "marcadodocumentos"
    // DIGIPROSDKATO
    case audio = "audio"
    case calculadora = "calculadorafinanciera"
    case codigobarras = "codigobarras"
    case codigoqr = "codigoqr"
    case nfc = "nfc"
    case firma = "firma"
    case firmafad = "firmafad"
    case georeferencia = "georeferencia"
    case imagen = "imagen"
    case pdfocr = "pdfocr"
    case mapa = "mapa"
    case video = "video"
    case videollamada = "videollamada"
    case voz = "voz"
    case documento = "documento"
    // DIGIPROSDKVO
    case huelladigital = "huelladigital"
    // DIGIPROSDKFO
    case rostrovivo = "rostrovivo"
    case capturafacial = "capturaFacial"
    // DIGIPROSDKVERIDAS
    case ocr = "ocr"
    case veridasdocumentcapture = "veridasdocumentcapture"
    case veridasphotoselfie = "veridasphotoselfie"
    case veridasvideoselfie = "veridasvideoselfie"
    // DGPJumioKit
    case jumio = "jumio"
    case other = ""
    
    var label:String? {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first?.label
    }
}
/// Enumerator for all types of success posibilities
@objc public enum APISuccessResponse: Int{
    case success = 200
    var errorCode: Int {
        switch self {
        case .success: return 200
        }
    }
    var description: String {
        switch self {
        case .success: return "Se ha completado exitosamente."
        }
    }
}
/// Enumerator for all types of errors
/// - Parameters:
/// - case success = 200
/// - case malfunction = 400
/// - case changePassword = 401
/// - case noSession = 403
/// - case disabledAccount = 405
/// - case unknown = 500
/// - case data = 300
/// - case xml = 301
/// - case request = 302
/// - case noFormat = 410
public enum ApiErrors: Int{
    
    case success = 200
    case terms = 300
    case malfunction = 400
    case changePassword = 401
    case noSession = 403
    case disabledAccount = 405
    case misConfiguration = 406
    case unknown = 500
    
    case data = 301 // Success False in message
    case xml = 302 // Error parsing xml
    case request = 303 // Error parsin URLRequest
    case nofile = 304 // No file encountered
    case notask = 305 // No task to transit
    
    case noFormat = 410 // No format saved
    case noData = 411 // No data encountered
    case connection = 501 // No internet or limited access or no data from internet
    case errorTotal = 600
}
/// Enumerator for all domains in SDK
public enum Domain: String{
    case sdk = "COM.DIGIPROSDK"
    case so = "COM.DIGIPROSDKSO"
    case ato = "COM.DIGIPROSDKATO"
    case fo = "COM.DIGIPROSDKFO"
    case vo = "COM.DIGIPROSDKVO"
}

/// Enumerator for all errors that can occur in each method inside the SDK
public enum APIErrorResponse: Error{
    case DetectLicenceError

    case InternetConnectionError
    
    // ERRORS FOR ONLINE
    case LoginCodeError(Int)
    // 300 - Código no válido
    // 301 - Error al parsear el XML
    // 302 - No hubo conexión al servidor
    case LoginUserError(Int)
    // 300 - Código no válido
    // 301 - Error al parsear el XML
    // 302 - No hubo conexión al servidor
    case TemplatesError(Int)
    // 300 - Código no válido
    // 301 - Error al parsear el XML
    // 302 - No hubo conexión al servidor
    case VariablesError(Int)
    // 300 - Código no válido
    // 301 - Error al parsear el XML
    // 302 - No hubo conexión al servidor
    case FormatsError(Int)
    // 300 - Código no válido
    // 301 - Error al parsear el XML
    // 302 - No hubo conexión al servidor
    
    case CodigoOnlineError
    case SkinOnlineError
    case UsuarioOnlineError
    case PlantillasOnlineError
    case VariablesOnlineError
    case FormatosOnlineError
    case FlujosAndProcesosOnlineError
    
    case RegistroOnlineError
    case RegistroRegistradoOnlineError
    
    case SMSOnlineError
    
    // ERRORS FOR OFFLINE
    case CodigoOfflineError
    case SkinOfflineError
    case UsuarioOfflineError
    case PlantillasOfflineError
    case VariablesOfflineError
    
    
    // General errors
    case CodigoError
    case LoginError
    case SkinError
    
    case XMLError
    case ParseError
    case ServerError
    
    // Transited
    case TransitedError
    case NoTransitedOptions
    
    // Retrive Formularios
    case FormsError
    
    case defaultError
    
}
// MARK: FormularioUtilities
public enum ReturnFormulaType {
    case typeString(String)
    case typeInt(Int)
    case typeArray(NSArray)
    case typeDictionary(NSDictionary)
    case typeNil(String?)
}

public enum ReturnOperacionType{
    case typeString(String)
    case typeInt(Int)
    case typeBoolean(Bool)
}

public enum ObfuscatedCnstnt{
    
    // https://digipro.com.mx/
    public static let dgp: [UInt8] = [41, 26, 13, 63, 17, 80, 74, 76, 16, 39, 52, 38, 18, 24, 10, 77, 23, 46, 3, 87, 34, 26, 69]
    // https://graph.facebook.com/
    public static let fcl: [UInt8] = [41, 26, 13, 63, 17, 80, 74, 76, 19, 60, 50, 63, 10, 68, 3, 2, 23, 36, 12, 22, 32, 9, 68, 6, 12, 25, 97]
    // /picture?type=large&width=300&height=300
    public static let fcll: [UInt8] = [110, 30, 16, 44, 22, 31, 23, 6, 75, 58, 42, 63, 7, 87, 9, 2, 6, 38, 11, 95, 56, 11, 14, 17, 11, 73, 125, 99, 127, 68, 2, 0, 10, 19, 41, 26, 68, 124, 82, 90]
    // https://www.facebook.com/DigiProMX
    public static let rln: [UInt8] = [41, 26, 13, 63, 17, 80, 74, 76, 3, 57, 36, 97, 4, 11, 6, 6, 22, 46, 1, 18, 97, 1, 5, 8, 76, 48, 39, 52, 38, 50, 24, 10, 46, 44]
    // https://www.linkedin.com/company/digipro/
    public static let rfb: [UInt8] = [41, 26, 13, 63, 17, 80, 74, 76, 3, 57, 36, 97, 14, 3, 11, 8, 17, 37, 7, 23, 97, 1, 5, 8, 76, 23, 33, 62, 63, 3, 4, 28, 76, 16, 40, 9, 16, 63, 16, 5, 74]
    // http://52.167.225.74/Movil/Portal/
    public static let uptl: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 86, 70, 96, 98, 121, 85, 68, 87, 81, 65, 111, 89, 77, 96, 47, 5, 19, 10, 24, 97, 3, 32, 16, 30, 4, 15, 91]
    // https://cloud.digipromovil.com/WCFCodigo/WcfCodigo.svc
    public static let hac: [UInt8] = [41, 26, 13, 63, 17, 80, 74, 76, 23, 34, 60, 58, 6, 68, 1, 10, 19, 40, 30, 11, 32, 15, 5, 19, 10, 24, 96, 48, 32, 15, 69, 50, 32, 50, 2, 1, 29, 38, 5, 5, 74, 52, 23, 40, 16, 32, 6, 3, 2, 12, 90, 50, 24, 26]
    // http://192.168.201.3:5001/app.svc
    public static let had: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 82, 77, 124, 125, 126, 84, 82, 75, 81, 68, 112, 64, 74, 117, 87, 90, 85, 82, 91, 47, 35, 63, 76, 25, 19, 0]
    // http://52.167.0.136:8023/WCFCODIGO/WcfCodigo.svc/json/CheckLicenseSDK
    public static let cdl: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 86, 70, 96, 98, 121, 85, 68, 85, 77, 69, 114, 88, 67, 119, 82, 88, 86, 76, 35, 13, 21, 12, 45, 46, 44, 36, 59, 110, 57, 26, 41, 33, 5, 1, 10, 19, 33, 125, 60, 20, 9, 74, 9, 7, 46, 0, 86, 12, 10, 15, 6, 8, 56, 39, 48, 42, 12, 25, 0, 48, 48, 10]
    // http://tempuri.org/
    public static let tmp: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65]
    // http://schemas.xmlsoap.org/soap/envelope/
    public static let spen: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 16, 23, 38, 54, 34, 3, 25, 75, 27, 25, 45, 29, 22, 46, 18, 68, 10, 17, 19, 97, 32, 32, 3, 26, 74, 6, 26, 55, 11, 21, 32, 18, 15, 74]
    // http://schemas.datacontract.org/2004/07/GenericClass
    public static let cntr: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 16, 23, 38, 54, 34, 3, 25, 75, 7, 21, 53, 15, 26, 32, 12, 30, 23, 2, 23, 58, 125, 32, 16, 13, 74, 81, 68, 113, 90, 86, 127, 85, 69, 34, 6, 26, 43, 33, 38, 1, 41, 9, 2, 7, 50]
    // http://52.167.0.136:8023/WCFServicios/WcfServicios.svc
    public static let srvc: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 86, 70, 96, 98, 121, 85, 68, 85, 77, 69, 114, 88, 67, 119, 82, 88, 86, 76, 35, 13, 21, 28, 7, 24, 19, 10, 23, 40, 1, 10, 96, 53, 9, 3, 48, 17, 60, 37, 38, 1, 3, 10, 16, 90, 50, 24, 26]
    // http://tempuri.org/IWcfCodigo/CheckCodigo
    public static let tmprco: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 1, 12, 38, 12, 16, 39, 52, 32, 77, 41, 13, 6, 23, 42, 45, 22, 43, 11, 13, 10]
    // http://tempuri.org/IApp/ObtieneSkin
    public static let tmprsk: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 44, 22, 58, 58, 42, 12, 15, 54, 8, 29, 47]
    // http://tempuri.org/IApp/Login
    public static let tmprlg: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 47, 27, 41, 58, 33]
    // http://tempuri.org/IApp/SendUsrThumbnail
    public static let tmprsnd: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 48, 17, 32, 55, 26, 17, 24, 49, 11, 1, 44, 12, 23, 46, 11, 6]
    // http://tempuri.org/IApp/SendUserInformation
    public static let tmpusri: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 48, 17, 32, 55, 26, 17, 15, 23, 42, 26, 39, 1, 11, 34, 3, 30, 12, 12, 26]
    // http://tempuri.org/IApp/Registro
    public static let tmprrg: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 49, 17, 41, 58, 60, 22, 24, 10]
    // http://tempuri.org/IWCFServicios/Registro
    public static let tmprrgo: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 38, 36, 9, 16, 60, 22, 24, 10]
    // http://tempuri.org/IApp/ActivarRegistro
    public static let tmprarg: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 34, 23, 58, 58, 57, 3, 24, 55, 6, 19, 40, 29, 13, 61, 13]
    // http://tempuri.org/IWCFServicios/ActivarRegistro
    public static let tmprarco: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 53, 34, 26, 16, 57, 3, 24, 55, 6, 19, 39, 32, 59, 16, 5]
    // http://tempuri.org/IApp/CambiarPassword
    public static let tmprcpss: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 32, 21, 35, 49, 38, 3, 24, 53, 2, 7, 50, 25, 22, 61, 6]
    // http://tempuri.org/IWCFServicios/CambiarPassword
    public static let tmprcpsso: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 55, 32, 3, 27, 38, 3, 24, 53, 2, 7, 61, 36, 32, 16, 14]
    // http://tempuri.org/IWCFServicios/ResetearPassword
    public static let tmprrstpss: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 38, 36, 29, 28, 59, 7, 11, 23, 51, 21, 61, 32, 56, 13, 24, 1]
    // http://tempuri.org/IWCFServicios/ObtenerCodigoPostal
    public static let tmprcdpl: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 59, 35, 26, 28, 33, 7, 24, 38, 12, 16, 39, 52, 32, 50, 5, 22, 23, 21, 45]
    // http://tempuri.org/IApp/ObtienePlantillas
    public static let tmprobpl: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 44, 22, 58, 58, 42, 12, 15, 53, 15, 21, 47, 26, 16, 35, 14, 11, 22]
    // http://tempuri.org/IApp/ObtieneVariables
    public static let tmprobvr: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 44, 22, 58, 58, 42, 12, 15, 51, 2, 6, 40, 15, 27, 35, 7, 25]
    // http://tempuri.org/IApp/ConsultaFormatos
    public static let tmprcnfr: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 32, 27, 32, 32, 58, 14, 30, 4, 37, 27, 51, 3, 24, 59, 13, 25]
    // http://tempuri.org/IApp/BorraFormatoBorrador
    public static let tmprbfor: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 33, 27, 60, 33, 46, 36, 5, 23, 14, 21, 53, 1, 59, 32, 16, 24, 4, 7, 27, 60]
    // http://tempuri.org/IApp/EnviaFormato
    public static let tmprenf: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 38, 26, 56, 58, 46, 36, 5, 23, 14, 21, 53, 1]
    // http://tempuri.org/IApp/EnviaAnexo
    public static let tmprena: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 38, 26, 56, 58, 46, 35, 4, 0, 27, 27]
    // http://tempuri.org/IApp/ConsultaAnexo
    public static let tmprcnan: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 32, 27, 32, 32, 58, 14, 30, 4, 34, 26, 36, 22, 22]
    // http://tempuri.org/IApp/TransitaFormato
    public static let tmprtrf: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 55, 6, 47, 61, 60, 11, 30, 4, 37, 27, 51, 3, 24, 59, 13]
    // http://tempuri.org/IApp/ConsultaTemplate
    public static let tmprcnt: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 32, 27, 32, 32, 58, 14, 30, 4, 55, 17, 44, 30, 21, 46, 22, 15]
    // http://tempuri.org/IApp/DescargaPDF
    public static let tmprpdf: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 39, 17, 61, 48, 46, 16, 13, 4, 51, 48, 7]
    // http://tempuri.org/IWCFServicios/CompareFaces
    public static let tmprcmfa: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 55, 46, 3, 9, 46, 16, 15, 35, 2, 23, 43, 32]
    // http://tempuri.org/IWCFServicios/FolioAutomatico
    public static let tmprfol: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 50, 46, 2, 16, 32, 35, 31, 17, 12, 25, 47, 39, 38, 1, 5]
    // http://tempuri.org/IWCFServicios/SendSms
    public static let tmprsms: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 39, 36, 0, 29, 28, 15, 25]
    // http://tempuri.org/IWCFServicios/RegistroPinSms
    public static let tmprpnsms: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 38, 36, 9, 16, 60, 22, 24, 10, 51, 29, 32, 0, 34, 17]
    // http://tempuri.org/IWCFServicios/ValidateSmsCode
    public static let tmprvlsms: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 34, 32, 2, 16, 43, 3, 30, 0, 48, 25, 61, 16, 32, 6, 15]
    // http://tempuri.org/IWCFServicios/SendMail
    public static let tmprsndml: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 39, 36, 0, 29, 2, 3, 3, 9]
    // http://tempuri.org/IWCFServicios/ServicioGenerico
    public static let tmprsrgn: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 39, 36, 28, 15, 38, 1, 3, 10, 36, 17, 32, 54, 61, 11, 9, 10]
    // http://tempuri.org/IWCFServicios/ServicioGenericoString
    public static let tmprsrgns: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 24, 33, 44, 54, 6, 6, 56, 58, 44, 11, 5, 22, 76, 39, 36, 28, 15, 38, 1, 3, 10, 36, 17, 32, 54, 61, 11, 9, 10, 48, 0, 51, 7, 23, 40]
    // http://tempuri.org/IApp/GeneraPeticionLogalty
    public static let tmprgnlg: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 36, 17, 32, 54, 61, 3, 58, 0, 23, 29, 34, 7, 22, 33, 46, 5, 2, 2, 24, 58, 42]
    // http://tempuri.org/IApp/GeneraSaml
    public static let tmprgnsl: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 36, 17, 32, 54, 61, 3, 57, 4, 14, 24]
    // http://tempuri.org/IApp/TerminaProcesoLogalty
    public static let tmprtmply: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 55, 17, 60, 62, 38, 12, 11, 53, 17, 27, 34, 11, 10, 32, 46, 5, 2, 2, 24, 58, 42]
    // http://tempuri.org/IApp/CargaCatalogoRemoto
    public static let tmprccrm: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 32, 21, 60, 52, 46, 33, 11, 17, 2, 24, 46, 9, 22, 29, 7, 7, 10, 23, 27]
    // http://tempuri.org/IApp/ConsultaArchivoPublicado
    public static let tmprpdfpublicado: [UInt8] = [41, 26, 13, 63, 88, 69, 74, 23, 17, 35, 35, 58, 16, 3, 75, 12, 6, 38, 65, 48, 14, 18, 26, 74, 32, 27, 32, 32, 58, 14, 30, 4, 34, 6, 34, 6, 16, 57, 13, 58, 16, 1, 24, 39, 48, 46, 6, 5]
}
