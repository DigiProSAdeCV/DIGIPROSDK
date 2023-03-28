//
//  Constants.swift
//  DigiproEssentials
//
//  Created by Jonathan Viloria M on 4/18/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UserNotifications
import CFNetwork
import SystemConfiguration
import LocalAuthentication
import CoreTelephony
import PDFKit

// MARK: - Global Constants
public struct Cnstnt{
    
    public struct Color{
        public static let dark = UIColor(hexFromString: "#202020", alpha: 1.0)
        public static let blue = UIColor(hexFromString: "#50B8F0", alpha: 1.0)
        public static let bluedark = UIColor(hexFromString: "#445762", alpha: 1.0)
        public static let gray = UIColor(hexFromString: "#444444", alpha: 1.0)
        public static let green = UIColor(hexFromString: "#68B847", alpha: 1.0)
        public static let green2 = UIColor(hexFromString: "#50B848", alpha: 1.0)
        public static let pushEConsubanco = UIColor(hexFromString: "#979CB9", alpha: 1.0)
        public static let red = UIColor(hexFromString: "#D93829", alpha: 1.0)
        public static let red2 = UIColor(hexFromString: "#D32E2E", alpha: 1.0)
        public static let white = UIColor(hexFromString: "#FFFFFF", alpha: 1.0)
        public static let whitelight = UIColor(hexFromString: "#EFEFF4", alpha: 1.0)
        public static let yellow = UIColor(hexFromString: "#FFD500", alpha: 1.0)
        public static let yellow2 = UIColor(hexFromString: "#FFD365", alpha: 1.0)
        
    }
    
    public struct Path{
        public static let main = Bundle(identifier: "com.digipro.movil")
        public static let framework = Bundle(identifier: "com.digipro.movil.DIGIPROSDK")
    }
    
    public struct Tree{
        
        // Folder & Files Structure
        public static let main = "Digipro"
        public static let collector = "\(Cnstnt.Tree.main)/Collector"
        public static let codigos = "\(Cnstnt.Tree.main)/Codigos"
        public static let usuarios = "\(Cnstnt.Tree.main)/Usuarios"
        public static let anexos = "\(Cnstnt.Tree.main)/Anexos"
        public static let presets = "\(Cnstnt.Tree.main)/Presets"
        public static let customBorrador = "\(Cnstnt.Tree.main)/Borrador"
        
        public static let servicios = "Servicios"
        public static let plantillas = "Plantillas"
        public static let formatos = "Formatos"
        public static let catalogos = "Catalogos"
        public static let componentes = "Componentes"
        
        public static let imageProfile = "\(Cnstnt.Tree.anexos)/ImageProfile"

        public static let logs = "\(Cnstnt.Tree.main)/Logs"
        
    }
    
    public struct BundlePrf{
        public static let version =         "version_preference"
        public static let bundle =          "bundle_preference"
        public static let data =            "data_preference"
        public static let delete =          "delete_data_preference"
        public static let member =          "member_app"
        public static let memberSwitch =    "member_switch"
        public static let codigo =          "codigo_preference"
        public static let usuario =         "usuario_preference"
        
        public static let nombre =          "nombre_validacion"
        public static let paterno =         "apellido_paterno_validacion"
        public static let materno =         "apellido_materno_validacion"
        public static let email =           "correo_electronico_validacion"
        public static let tel =             "telefono_celular_validacion"
        public static let estado =          "estado_validacion"
        
        public static let tutorial =        "data_tutorial"
        public static let touchid =         "touchid_auth"
        public static let faceid =          "faceid_auth"
        public static let calculadora =     "calculadora"
        
        public static let log =             "data_log"
        public static let serial =          "serial_developer"
        public static let tester =          "tester_developer"
        public static let credifiel =       "tester_credifiel"
        public static let ventas =          "ventas_developer"
        public static let implantacion =    "imp_developer"
        public static let debugger =        "debugger_developer"
        public static let unittest =        "unittest_developer"

        public static let debugCode =       "debug_code"
        public static let debugUser =       "debug_user"
        public static let debugPass =       "debug_pass"

        public static let licenceCode =     "licence_code"
        public static let licenceUser =     "licence_user"
        public static let licenceMode =     "mode_app"
    }
    
    public struct ThemeDefault{
        public static let blueHex = UIColor(hexString: "#00B2F2")
        public static let blueRGB = UIColor(red: 0/255, green: 178/255, blue: 242/255, alpha: 1.0)
        
        public static let greenHex = UIColor(hexString: "#68B848")
        public static let greenRGB = UIColor(red: 104/255, green: 184/255, blue: 72/255, alpha: 1.0)
        
        public static let grayHex = UIColor(hexString: "#E8ECEE")
        public static let grayRGB = UIColor(red: 232/255, green: 236/255, blue: 238/255, alpha: 1.0)
        
        public static let blackHex = UIColor(hexString: "#000000")
        public static let blackRGB = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        
        public static let blueDarkHex = UIColor(hexString: "#011520")
        public static let blueDarkRGB = UIColor(red: 1/255, green: 21/255, blue: 32/255, alpha: 1.0)
        
        public static let redHex = UIColor(hexString: "#D3342C")
        public static let redRGB = UIColor(red: 211/255, green: 52/255, blue: 44/255, alpha: 1.0)
        
        public static let socialBlueHex = UIColor(hexString: "#374E8A")
        public static let socialBlueRGB = UIColor(red: 55/255, green: 78/255, blue: 138/255, alpha: 1.0)
        
        public static let socialGreenHex = UIColor(hexString: "#266497")
        public static let socialGreenRGB = UIColor(red: 38/255, green: 100/255, blue: 151/255, alpha: 1.0)
    }
    
}
public struct Fnts{
    public static let generic = "ArialMT"
    public static let android = "Roboto-Regular"
    public static let jll = "SourceSansPro-Regular"
    public static let latoBlack = "Lato-Black"
    public static let latoBlod = "Lato-Bold"
    public static let latoRegular = "Lato-Regular"
    public static let latoLight = "Lato-Light"
}

public struct FontSize{
    public static let small = 10
    public static let normal = 16
    public static let hight = 18
    public static let big = 40
}
// MARK: - API Configuration
public class ConfigurationManager{
    
    public static let shared = ConfigurationManager()
    
    public var developerMode: Bool = false
    
    public let request = Requests()
    public var requestData: String = ""
    public var timeInterval: Double = 200 // Set by default
    public var debugNetwork: Bool = false
    public var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    public var isCodePresented = false
    public var isInitiated = false
    
    public var isShortcutItemLaunchActived = false
     
    public var hasNewFormat = false
    public var isConsubanco = false
    public var isMiConsubanco = false
    public var isDismissable = false
    public var isNotification = false
    public var webSecurity = false
    public var ifLogSent = false
    public var ifDataSent = false
    public var initialmethod = ""
    public var assemblypath = ""
    public var elementosArray:NSMutableDictionary = NSMutableDictionary()
    
    public var deviceToken = ""
    public var deviceTokenRemote = ""
    
    // Active license of Veridium
    public var veridiumLicense = false
    
    // All public variables from file structure
    public var licenciaUIAppDelegate: FELicencia?
    public var codigoUIAppDelegate = FECodigo()
    public var skinUIAppDelegate = FEAppSkin()
    public var usuarioUIAppDelegate = FEUsuario()
    public var plantillaUIAppDelegate = FEConsultaPlantilla()
    public var plantillaDataUIAppDelegate = FEPlantillaData()
    public var variablesUIAppDelegate = FEConsultaVariable()
    public var variablesDataUIAppDelegate = FEVariablesData()
    public var catRemotoUIAppDelegate = FECatRemoto()
    public var openPlantilla = [FEOpenPlantilla]()
    public var registroUIAppDelegate = FERegistro()
    public var consultasUIAppDelegate = Array<FETipoReporte>()
    public var flujosOrdered = Array<FEPlantillaMerge>()
    public var procesosOrdered = Array<FEProcesos>()
    public var utilities = Utilities()
    public var jsonCalculadora = [FEJsonCalculadora()]
    public var consultaSum: Int = 0
    public var consultaHackPage: Int = 0
    public var isInEditionMode: Bool = false
    public var isUnitTestMode: Bool = false
    public var fontApp: String = Fnts.generic
    public var fontLatoBlack : String = Fnts.latoBlack
    public var fontLatoBlod : String = Fnts.latoBlod
    public var fontLatoLight : String = Fnts.latoLight
    public var fontLatoRegular : String = Fnts.latoRegular
    public var fontSizeNormal : Int = FontSize.normal
    public var fontSizeBig : Int = FontSize.big
    public var fontSizeSmall : Int = FontSize.small
    public var fontSizeHeight : Int = FontSize.hight
    public var tagElement: String = ""
    public var extensionDoc: [FEDocumento] = [FEDocumento]()
    public var keyaes: String = ""
    public var ivaes: String = ""
    
    // Console for uploading formats and attachments
    public var viewConsole: UIView?
    public var textConsole: UITextView?
    public var console = Console()
    
    public var mainTab: UITabBarController?
    
    // Garbage Collector
    public var garbageCollector = [(id: String, value: String, desc: String)]()
    
    // public guid for attachments
    public var guid = ""
    public var longitud = ""
    public var latitud = ""
    
    // IPAD ambient
    public var isLoading = false
    public var isContentDownloaded = false
    
    // public init
    public init(){}
    
    public func configure(){
        UIFont.loadAllFonts()
        plist.idportal.rawValue.dataSSet("53")
        ConfigurationManager.shared.utilities.resetAppForNewVersion()
        ConfigurationManager.shared.utilities.settingFolderTree()
        ConfigurationManager.shared.utilities.registerNotification(0)
        ConfigurationManager.shared.utilities.registerShorcutItems()
        ConfigurationManager.shared.utilities.setEVReflection()
        ConfigurationManager.shared.utilities.settingGlobalPreferencesInfo()
    }

}

// MARK: - Functions Utilities
public struct Utilities{
    
    public func save(info: String, path:String) -> Bool{
        let d = info.data(using: .utf8)
        if ConfigurationManager.shared.developerMode{
            guard let i = d else{ return false }
            FCFileManager.createFile(atPath: path, withContent: i as NSObject, overwrite: true); return true
        }else{
            guard let i = d?.deflate() else{ return false }
            FCFileManager.createFile(atPath: path, withContent: i as NSObject, overwrite: true); return true
        }
    }
    
    public func saveLog(info: String, path:String) -> Bool{
        let d = info.data(using: .utf8)
        if ConfigurationManager.shared.developerMode{
            guard let i = d else{ return false }
            FCFileManager.createFile(atPath: path, withContent: i as NSObject, overwrite: true); return true
        }else{
            guard let i = d?.deflate() else{ return false }
            FCFileManager.createFile(atPath: path, withContent: i as NSObject, overwrite: true); return true
        }
    }
    
    public func save(object: Data, path:String) -> Bool{
        if ConfigurationManager.shared.developerMode{
            FCFileManager.createFile(atPath: path, withContent: object as NSObject, overwrite: true); return true
        }else{
            guard let i = object.deflate() else{ return false }
            FCFileManager.createFile(atPath: path, withContent: i as NSObject, overwrite: true); return true
        }
    }
    
    public func read(asData: String) -> Data?{
        guard let d = FCFileManager.readFileAtPath(asData: asData) else{ return nil }
        if ConfigurationManager.shared.developerMode{
            return d
        }else{
            guard let i = d.inflate() else{ return nil }; return i
        }
    }
    
    public func read(asString: String) -> String? {
        guard let d = FCFileManager.readFileAtPath(asData: asString) else{ return nil }
        if ConfigurationManager.shared.developerMode{
            guard let s = String(data: d, encoding: .utf8) else{return nil }; return s
        }else{
            guard let i = d.inflate() else{return nil }
            guard let s = String(data: i, encoding: .utf8) else{return nil }; return s
        }
    }
    
    public func getLL() -> (l: String, ll: String){ return self.l() }
    
    private func l() -> (l: String, ll: String){
        if "L".dataS() == "" && "LL".dataS() == "" {
            let m = UUID().uuidString
            let s = m.split(separator: "-")
            "L".dataSSet("\(s[1])FF\(s[2])00\(s[3])")
            "LL".dataSSet("\(s[0])FF\(s[1])00")
        }
        return (l: "L".dataS(), ll: "LL".dataS())
    }
    
    func DGSDKLicence(){
        let semaphore = DispatchSemaphore (value: 0)
        let request = Requests()
        let mutableRequest: URLRequest
        mutableRequest = request.genericJsonRequest(url: Obfuscator().reveal(key: ObfuscatedCnstnt.cdl), httpMethod: "POST", parameters: "{\"BundleId\": \"com.digipro.movil\"}")
        let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
            guard data != nil && error == nil else { return; }

            let jsonString = String(decoding: data!, as: UTF8.self)
            let response = AjaxResponse(json: jsonString)
            if response.Success{
                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)\r\n", .info)
                let licencia = FELicencia(dictionary: response.ReturnedObject!)
                ConfigurationManager.shared.licenciaUIAppDelegate = licencia
                semaphore.signal()
            }else{
                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)\r\n", .error)
                semaphore.signal()
            }
            
        })
        task.resume()
        semaphore.wait()
    }
    
    public func resetAppForNewVersion(){
        // Getting old version of app
        let getUsers = FCFileManager.listDirectoriesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)")
        for user in getUsers!{
            let codigoUsuario = (user as! String).split{$0 == "/"}.map(String.init)
            let formatos = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(codigoUsuario.last!)/Formatos/")
            if (formatos?.count)! > 0{
                FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.main)/")
                break
            }
        }
        let folderAnexo = FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/Imagenes/")
        if folderAnexo{
            FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.main)/")
        }
    }
    
    public func setEVReflection(){
        EVReflection.setBundleIdentifier(Atributos.self)
        EVReflection.setBundleIdentifier(Atributos_formula.self)
        EVReflection.setBundleIdentifier(Eventos.self)
        EVReflection.setBundleIdentifier(Expresion.self)
        EVReflection.setBundleIdentifier(Atributos_Expresion.self)
        EVReflection.setBundleIdentifier(Elemento.self)
        EVReflection.setBundleIdentifier(Elementos.self)
        EVReflection.setBundleIdentifier(Validacion.self)
        EVReflection.setBundleIdentifier(FECodigo.self)
        EVReflection.setBundleIdentifier(FECatalogo.self)
        EVReflection.setBundleIdentifier(FEAppSkinSplash.self)
        EVReflection.setBundleIdentifier(FEConsultaPlantilla.self)
        EVReflection.setBundleIdentifier(FEOpenPlantilla.self)
        EVReflection.setBundleIdentifier(FEItemCatalogoEsquema.self)
        EVReflection.setBundleIdentifier(FEVariablesData.self)
        EVReflection.setBundleIdentifier(FEEstadistica.self)
        EVReflection.setBundleIdentifier(FEEstadistica2.self)
        EVReflection.setBundleIdentifier(FEReporteEstadistico.self)
        EVReflection.setBundleIdentifier(FEHistoria.self)
        EVReflection.setBundleIdentifier(FEConsultaAnexo.self)
        EVReflection.setBundleIdentifier(FEPlantillaData.self)
        EVReflection.setBundleIdentifier(FEItemCatalogo.self)
        EVReflection.setBundleIdentifier(FEFormatoData.self)
        EVReflection.setBundleIdentifier(FEConsultaVariable.self)
        EVReflection.setBundleIdentifier(FECatRemoto.self)
        EVReflection.setBundleIdentifier(FECatRemotoData.self)
        EVReflection.setBundleIdentifier(FELicencia.self)
        EVReflection.setBundleIdentifier(FERegistro.self)
        EVReflection.setBundleIdentifier(FEAnexoData.self)
        EVReflection.setBundleIdentifier(FEUsuario.self)
        EVReflection.setBundleIdentifier(FEVariableData.self)
        EVReflection.setBundleIdentifier(FEAppSkinLogin.self)
        EVReflection.setBundleIdentifier(FEEventosFlujo.self)
        EVReflection.setBundleIdentifier(FEAppSkin.self)
        EVReflection.setBundleIdentifier(FESkin.self)
        EVReflection.setBundleIdentifier(FEConsultaFormato.self)
        EVReflection.setBundleIdentifier(FETipoReporte.self)
        EVReflection.setBundleIdentifier(FECampoReporte.self)
        EVReflection.setBundleIdentifier(FELogError.self)
        EVReflection.setBundleIdentifier(AjaxResponse.self)
        EVReflection.setBundleIdentifier(FolioAutomaticoResult.self)
        EVReflection.setBundleIdentifier(FolioResponse.self)
        EVReflection.setBundleIdentifier(HuellaDigitalRespuesta.self)
        EVReflection.setBundleIdentifier(FingerPrintsData.self)
        EVReflection.setBundleIdentifier(CaptureDateData.self)
        EVReflection.setBundleIdentifier(FingerImpressionImageData.self)
        EVReflection.setBundleIdentifier(OcrIneFormulas.self)
        EVReflection.setBundleIdentifier(OcrIneObject.self)
        EVReflection.setBundleIdentifier(SmsServicio.self)
        EVReflection.setBundleIdentifier(CorreoServicio.self)
        EVReflection.setBundleIdentifier(FEJsonCalculadora.self)
        EVReflection.setBundleIdentifier(FEBranchCalculadora.self)
        EVReflection.setBundleIdentifier(FEDistributorCalculadora.self)
        EVReflection.setBundleIdentifier(FEDocumentCalculadora.self)
        EVReflection.setBundleIdentifier(FEEnterpriseCalculadora.self)
        EVReflection.setBundleIdentifier(FEFieldCalculadora.self)
        EVReflection.setBundleIdentifier(FEPlazoCalculadora.self)
        EVReflection.setBundleIdentifier(FEGruposConvenio.self)
        EVReflection.setBundleIdentifier(FEConvenioCalculadora.self)
        EVReflection.setBundleIdentifier(FEProductCalculadora.self)
        EVReflection.setBundleIdentifier(FEProductsCalculadora.self)
        EVReflection.setBundleIdentifier(FECotizaciones.self)
        EVReflection.setBundleIdentifier(FEQuotations.self)
        EVReflection.setBundleIdentifier(FEConsultasFinalizados.self)
    }
    
    // MARK: - Register App for Push Notifications
    public func registerNotification(_ number: Int){
        let badgeCount: Int = 0
        let application = UIApplication.shared
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // TODO: - Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = badgeCount
    }
    
    
    
    // MARK: - Register shorcut items for the app
    public func registerShorcutItems(){
        if let shortcutItem = ConfigurationManager.shared.launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            if shortcutItem.type == "nuevo.formato" {
                ConfigurationManager.shared.isShortcutItemLaunchActived = true
            }
        }
    }
    
    // MARK: - Restart all services
    public func restartAllServices(){
        // This is to restore and reset Workflow in App for security reasons
        ConfigurationManager.shared.isInitiated = false
        ConfigurationManager.shared.usuarioUIAppDelegate = FEUsuario()
        ConfigurationManager.shared.plantillaUIAppDelegate = FEConsultaPlantilla()
        ConfigurationManager.shared.plantillaDataUIAppDelegate = FEPlantillaData()
    }
    
    // MARK: - Check Preferences
    public func checkPreferences(){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "checkPreferences"), .info)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let appBundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        plist.version.rawValue.dataSSet(appVersion ?? "")
        plist.bundle.rawValue.dataSSet(appBundle ?? "")
        
        // Detecting if we need to delete all data of the App no matter the user, clear all up
        let reset = plist.delete.rawValue.dataB()
        if(reset){
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "checkPreferencesReset"), .info)

            ConfigurationManager.shared.isInitiated = false
            
            ConfigurationManager.shared.codigoUIAppDelegate = FECodigo()
            ConfigurationManager.shared.skinUIAppDelegate = FEAppSkin()
            ConfigurationManager.shared.usuarioUIAppDelegate = FEUsuario()
            ConfigurationManager.shared.plantillaUIAppDelegate = FEConsultaPlantilla()
            ConfigurationManager.shared.plantillaDataUIAppDelegate = FEPlantillaData()
            
            plist.serial.rawValue.dataSSet("")
            plist.data.rawValue.dataSSet("0")
            plist.log.rawValue.dataSSet("0")
            plist.codigo.rawValue.dataSSet("")
            plist.usuario.rawValue.dataSSet("")
            plist.nombre.rawValue.dataSSet("")
            plist.paterno.rawValue.dataSSet("")
            plist.materno.rawValue.dataSSet("")
            plist.email.rawValue.dataSSet("")
            plist.tel.rawValue.dataSSet("")
            plist.estado.rawValue.dataSSet("")
            plist.tutorial.rawValue.dataSSet(true)
            plist.touchid.rawValue.dataSSet(false)
            plist.serial.rawValue.dataSSet("")
            
            if ConfigurationManager.shared.isConsubanco{
                plist.licenceCode.rawValue.dataSSet("CSBPRO")
            }else{
                plist.licenceCode.rawValue.dataSSet("")
            }
            plist.licenceUser.rawValue.dataSSet("")
            plist.licenceMode.rawValue.dataSSet("Normal")
            
            FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.main)")
        }
        
        if plist.serial.rawValue.dataS() == ""{ plist.serial.rawValue.dataSSet(""); return }
    }
    
    // MARK: - Get IP Address
    public func getIPAddress() -> String {
        
        return "0.0.0.0"
    }
    
    // MARK: - Check Internet Connection
    public func checkNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { return false }
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) { return false }
        if flags.isEmpty { return false }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    public func isConnectedToNetwork() -> Promise<Bool> {
        
        return Promise<Bool>{ resolve, reject in
            
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                reject(APIErrorResponse.InternetConnectionError)
                return
            }
            
            var flags: SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                reject(APIErrorResponse.InternetConnectionError)
            }
            if flags.isEmpty {
                reject(APIErrorResponse.InternetConnectionError)
            }
            
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            
            resolve((isReachable && !needsConnection))
        }
        
    }
    
    public func isConnected() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { return false }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) { return false }
        if flags.isEmpty { return false }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    // MARK: - REFRESH|UPDATE Folder capacity
    public func refreshFolderCapacity(){
        
        let codigoFolderExists = FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.codigos)")
        let usuarioFolderExists = FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.usuarios)")
        let anexosFolderExists = FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)")
        
        let codigoSizeFolder = FCFileManager.sizeOfDirectory(atPath: "\(Cnstnt.Tree.codigos)")
        let usuarioSizeFolder = FCFileManager.sizeOfDirectory(atPath: "\(Cnstnt.Tree.usuarios)")
        let anexoSizeFolder = FCFileManager.sizeOfDirectory(atPath: ".\(Cnstnt.Tree.anexos)")
        
        let codigosSize: Int64
        if codigoFolderExists && codigoSizeFolder != nil{
            codigosSize = Int64(truncating: codigoSizeFolder!) }else{ codigosSize = Int64(0) }
        let usuariosSize: Int64
        if usuarioFolderExists && usuarioSizeFolder != nil{
            usuariosSize = Int64(truncating: usuarioSizeFolder!) }else{ usuariosSize = Int64(0) }
        let anexosSize: Int64
        if anexosFolderExists && anexoSizeFolder != nil{
            anexosSize = Int64(truncating: anexoSizeFolder!) }else{ anexosSize = Int64(0) }
        let fileSizeWithUnit = ByteCountFormatter.string(fromByteCount: (codigosSize + usuariosSize + anexosSize), countStyle: .file)
        plist.data.rawValue.dataSSet(fileSizeWithUnit)
        
        refreshFileLogCapacity()
        
        return
    }
    
    public func settingGlobalPreferencesInfo(){
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor.darkGray
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.right
        EasyTipView.globalPreferences = preferences
    }
    
    public func refreshFileLogCapacity(){
        let logFileExists = FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.logs)/log.txt")
        let logFileSize: Int64
        if logFileExists {
            logFileSize = Int64(truncating: FCFileManager.sizeOfFile(atPath: "\(Cnstnt.Tree.logs)/log.txt"))
        } else { logFileSize = Int64(0) }
        let fileSizeWithUnit = ByteCountFormatter.string(fromByteCount: (logFileSize), countStyle: .file)
        plist.log.rawValue.dataSSet(fileSizeWithUnit)
        return
    }
    
    public func getCodeInLibrary() -> Bool{
        let codigo = plist.codigo.rawValue.dataS()
        if(codigo != "" && codigo != "default"){
            guard let codeJson = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.codigos)/\(codigo)/Codigo.cod") else {
                ConfigurationManager.shared.codigoUIAppDelegate = FECodigo()
                ConfigurationManager.shared.utilities.writeLogger("apimng_log_nofile".langlocalized(), .error)
                return false
            }
            ConfigurationManager.shared.codigoUIAppDelegate = FECodigo(json: codeJson)
            return true
        }
        ConfigurationManager.shared.utilities.writeLogger("apimng_log_preference".langlocalized(), .error)
        return false
    }
    
    public func getSkinInLibrary() -> Bool{
        let codigo = plist.codigo.rawValue.dataS()
        guard let skinJson = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.codigos)/\(codigo)/Skin.ski") else{
            ConfigurationManager.shared.skinUIAppDelegate = FEAppSkin()
            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nofile".langlocalized(), .error)
            return false
        }
        ConfigurationManager.shared.skinUIAppDelegate = FEAppSkin(json: skinJson)
        return true
    }
    
    public func getUserInLibrary() -> Bool{
        let codigo = plist.codigo.rawValue.dataS()
        let user = plist.usuario.rawValue.dataS()
        if(user != "" && codigo != ""){
            guard let usuarioJson = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(codigo)_\(user)/Usuario.usu") else{
                ConfigurationManager.shared.usuarioUIAppDelegate = FEUsuario()
                ConfigurationManager.shared.utilities.writeLogger("apimng_log_nofile".langlocalized(), .error)
                return false
            }
            ConfigurationManager.shared.usuarioUIAppDelegate = FEUsuario(json: usuarioJson)
            return true
        }
        ConfigurationManager.shared.utilities.writeLogger("apimng_log_preference".langlocalized(), .error)
        return false
    }
    
    public func getPlantillaInLibrary() -> Bool{
        let codigo = plist.codigo.rawValue.dataS()
        let user = plist.usuario.rawValue.dataS()
        guard let plantillaJson = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(codigo)_\(user)/Plantilla.pla") else{
            ConfigurationManager.shared.plantillaUIAppDelegate = FEConsultaPlantilla()
            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nofile".langlocalized(), .error)
            return false
        }
        ConfigurationManager.shared.plantillaUIAppDelegate = FEConsultaPlantilla(json: plantillaJson)
        return true
    }
    
    public func getVariableInLibrary() -> Bool{
        let codigo = plist.codigo.rawValue.dataS()
        let user = plist.usuario.rawValue.dataS()
        guard let plantillaJson = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(codigo)_\(user)/Variables.var") else{
            ConfigurationManager.shared.variablesDataUIAppDelegate = FEVariablesData()
            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nofile".langlocalized(), .error)
            return false
        }
        let response = AjaxResponse(json: plantillaJson)
        ConfigurationManager.shared.variablesDataUIAppDelegate = FEVariablesData(dictionary: response.ReturnedObject ?? NSDictionary())
        return true
    }
    
    public func getCatalogoInLibrary(_ catId: String) -> FEItemCatalogoEsquema?{
        let codigo = plist.codigo.rawValue.dataS()
        guard var catalogoJson = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.codigos)/\(codigo)/Catalogos/\(catId).cat") else{
            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nofile".langlocalized(), .error)
            return nil
        }
        catalogoJson = catalogoJson.replaceLineBreakJson()
        return FEItemCatalogoEsquema(json: catalogoJson)
    }
    
    // MARK: - Getting info from format
    public func getXML(flujo: String, exp: String, doc: String) -> String{
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).xml") else { return "" }
        return xmlString
    }
    public func getFormatoJson(_ formato: FEFormatoData) -> String?{
        let stringJson = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(formato.FlujoID)/\(formato.PIID)/\(formato.Guid)_\(formato.ExpID)_\(formato.TipoDocID)-\(formato.FlujoID)-\(formato.PIID).json")
        return stringJson
    }
    public func getAdditionals(_ formato: FEFormatoData) -> String?{
        let f = String(formato.FlujoID)
        let e = String(formato.ExpID)
        let d = String(formato.TipoDocID )
        var string = "\r\n\r\n --- SERVICES --- \r\n\r\n"
        string += getSERVICES(flujo: f, exp: e, doc: d) ?? ""
        string += "\r\n\r\n --- COMPONENTS --- \r\n\r\n"
        string += getCOMPONENTS(flujo: f, exp: e, doc: d) ?? ""
        string += "\r\n\r\n --- MATHEMATICS --- \r\n\r\n"
        string += getMATHEMATICS(flujo: f, exp: e, doc: d) ?? ""
        string += "\r\n\r\n --- PREFILL --- \r\n\r\n"
        string += getPREFILLEDDATA(flujo: f, exp: e, doc: d) ?? ""
        return string
    }
    
    func getSERVICES(flujo: String, exp: String, doc: String) -> String?{
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).srv") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc.xmlSpaces; } catch { return nil; }
    }
    
    func getCOMPONENTS(flujo: String, exp: String, doc: String) -> String?{
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).cmp") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc.xmlSpaces; } catch { return nil; }
    }
    
    func getMATHEMATICS(flujo: String, exp: String, doc: String) -> String?{
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).mat") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc.xmlSpaces; } catch { return nil; }
    }
    
    func getPREFILLEDDATA(flujo: String, exp: String, doc: String) -> String?{
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).prf") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc.xmlSpaces; } catch { return nil; }
    }
    
    func getPDFMAPPING(flujo: String, exp: String, doc: String) -> String?{
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).map") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc.xmlSpaces; } catch { return nil; }
    }
    
    public func resetFolderTree(_ path: String){
        FCFileManager.removeItem(atPath: "\(path)");
        refreshFolderCapacity()
    }
    
    public func settingFolderTree(){
        
        FCFileManager.createDirectories(forPath: "\(Cnstnt.Tree.main)")
        FCFileManager.createDirectories(forPath: "\(Cnstnt.Tree.anexos)")
        FCFileManager.createDirectories(forPath: "\(Cnstnt.Tree.codigos)")
        FCFileManager.createDirectories(forPath: "\(Cnstnt.Tree.usuarios)")
        FCFileManager.createDirectories(forPath: "\(Cnstnt.Tree.logs)")
        FCFileManager.createDirectories(forPath: "\(Cnstnt.Tree.collector)")
        
        
        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.logs)/error.txt")
        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.logs)/log.txt")
        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.logs)/notifications.txt")
        FCFileManager.createFile(atPath: "\(Cnstnt.Tree.logs)/error.txt")
        FCFileManager.createFile(atPath: "\(Cnstnt.Tree.logs)/log.txt")
        FCFileManager.createFile(atPath: "\(Cnstnt.Tree.logs)/notifications.txt")
    }
    
    public func initLogFormat(){
        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.logs)/format.txt")
        FCFileManager.createFile(atPath: "\(Cnstnt.Tree.logs)/format.txt")
    }
    
    public func globalWritterLoggerForServices(_ method: String, _ type: enumErrorType){
        
    }
    // MARK: WRITELOG
    public func writeLogger(_ string: String, _ type: enumErrorType){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        var logTime = formatter.string(from: Date())
        var path = ""
        switch type{
        case .error: logTime = "ERROR: \(logTime) - \(string)\n"
            path = "\(Cnstnt.Tree.logs)/log.txt"; break;
        case .info: logTime = "INFO: \(logTime) - \(string)\n"
            path = "\(Cnstnt.Tree.logs)/log.txt"; break;
        case .success: logTime = "SUCCESS: \(logTime) - \(string)\n"
            path = "\(Cnstnt.Tree.logs)/log.txt"; break;
        case .warning: logTime = "WARNING: \(logTime) - \(string)\n"
            path = "\(Cnstnt.Tree.logs)/log.txt"; break;
        case .format: logTime = "\(logTime) - \(string)\n"
        path = "\(Cnstnt.Tree.logs)/format.txt"; break;
        }
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(path)
            do {
                let handle = try FileHandle(forWritingTo: fileURL)
                handle.seekToEndOfFile()
                handle.write(logTime.data(using: .utf8)!)
                handle.closeFile()
            } catch { return }
        }
    }
    
    public func logMessage(_ message: String,
                    fileName: String = #file,
                    functionName: String = #function,
                    lineNumber: Int = #line,
                    columnNumber: Int = #column) -> String {
        return "📱ViewController: \(fileName) - FunctionName: \(functionName)  Code Line: \(lineNumber) -- Column: [\(columnNumber)]"
    }

    
    // MARK: Console Log
    public func log(_ logType:LogType,_ message:String){
        let userDefaults_serial = String(UserDefaults.standard.string(forKey: Cnstnt.BundlePrf.serial) ?? "")
        if userDefaults_serial.sha512() == "07eeb356a2b2297563b4e7cb245387b19b341afd31e58d0bed678449062aa462fd28d78732c62ffeeb73ccbbf45c077d271f4a8f10803dab48597f477e76eaf2"{
            switch logType {
            case LogType.error: print("📕 \(message)")
            case LogType.warning: print("📙 \(message)")
            case LogType.success: print("📗 \(message)")
            case LogType.action: print("📘 \(message)")
            case LogType.canceled: print("📓 \(message)")
            case LogType.log: print("📄 \(message)") }
        }
    }

    // MARK: WRITE NOTIFICATIONS
    public func writeNotifications(_ string: String){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        var logTime = formatter.string(from: Date())
        var path = ""
        logTime = "\(logTime) - \(string)"
        path = "\(Cnstnt.Tree.logs)/notifications.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(path)
            do {
                let handle = try FileHandle(forWritingTo: fileURL)
                handle.seekToEndOfFile()
                handle.write(logTime.data(using: .utf8)!)
                handle.closeFile()
            } catch { return }
        }
        
    }
    
    /// Detect Attachment extension
    /// - Parameter ext: extension string
    /// - Returns: 1 == is Image 0 == nor image
    public func detectExtension(ext: String) -> Int{
        var xt = ext.lowercased()
        xt = xt.replacingOccurrences(of: ".", with: "")
        if xt == "jpg" || xt == "gif" || xt == "jpge" || xt == "png" || xt == "tiff" || xt == "tif" { return 1 }else{ return 0 }
    }
    // MARK: READLOG
    public func readLogger(_ file: String) -> String{
        var string = ""
        let path = "\(Cnstnt.Tree.logs)/\(file)"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(path)
            do {
                string = try String(contentsOf: fileURL, encoding: .utf8)
            } catch { return "apimng_log_nofile".langlocalized() }
        }
        return string
    }
    
    // MARK: SAVE IMAGE PROFILE TO FOLDER
    public func saveImageProfile(_ image: UIImage, _ folder: String, name: String) -> String{
        guard let object = image.pngData() else{ return "not_data_invalid".langlocalized() }
        _ = ConfigurationManager.shared.utilities.save(object: object, path: "\(Cnstnt.Tree.anexos)/\(folder)/\(name)")
        refreshFolderCapacity()
        return "apimng_log_datasaved".langlocalized()
    }
    
    // MARK: SAVE WSQ TO FOLDER
    public func saveWSQToFolder(_ data: String, _ name: String) -> String{
        _ = ConfigurationManager.shared.utilities.save(info: data, path: "\(Cnstnt.Tree.anexos)/\(name)")
        refreshFolderCapacity()
        return "apimng_log_datasaved".langlocalized()
    }
    
    // MARK: SAVE ANEXO TO FOLDER
    public func saveAnexoToFolder(_ data: NSData, _ name: String) -> String{
        _ = ConfigurationManager.shared.utilities.save(object: data as Data, path: "\(Cnstnt.Tree.anexos)/\(name)")
        refreshFolderCapacity()
        return "apimng_log_datasaved".langlocalized()
    }
    
    // MARK: SAVE IMAGE TO FOLDER
    public func saveImageToFolder(_ image: UIImage, _ name: String) -> String{
        guard let object = image.pngData() else{ return "not_data_invalid".langlocalized() }
        _ = ConfigurationManager.shared.utilities.save(object: object, path: "\(Cnstnt.Tree.anexos)/\(name)")
        refreshFolderCapacity()
        return "apimng_log_datasaved".langlocalized()
    }
    
    // MARK: SAVE VIDEO TO FOLDER
    public func saveVideoToFolder(_ video: Data, _ name: String) -> String{
        _ = ConfigurationManager.shared.utilities.save(object: video, path: "\(Cnstnt.Tree.anexos)/\(name)")
        refreshFolderCapacity()
        return "apimng_log_datasaved".langlocalized()
    }
    
    // MARK: SAVE PDF TO FOLDER
    public func savePDFToFolder(_ document: PDFDocument, _ name: String) -> String{
        guard let object = document.dataRepresentation() else{ return "not_data_invalid".langlocalized() }
        _ = ConfigurationManager.shared.utilities.save(object: object, path: "\(Cnstnt.Tree.anexos)/\(name)")
        refreshFolderCapacity()
        return "apimng_log_datasaved".langlocalized()
    }
    
    fileprivate func sharedContainerURL() -> URL? {
        var groupURL: URL?
        if ConfigurationManager.shared.isConsubanco{
            groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "com.consubanco.consullave.Consultas")
        }else{
            groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.digipro.movil.Widgets")
        }
        return groupURL
    }
    
    func writeSharedData(data:Data, to fileNamed:String) -> Bool {
        guard let url = sharedContainerURL() else { return false }
        let filePath = url.appendingPathComponent(fileNamed)
        do {
            try data.write(to: filePath); return true
        } catch { return false }
    }
    
    // MARK: REMOVE ALL FILES FROM FORMAT
    public func removeFilesForFormat(_ formato: FEFormatoData){
        // MARK: TODO - DELETE ALL FILES AND FOLDER
        let url = "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Formatos/\(formato.FlujoID)/\(formato.PIID)/\(formato.Guid)_\(formato.ExpID)_\(formato.TipoDocID)-\(formato.FlujoID)-\(formato.PIID)"
        
        if FCFileManager.existsItem(atPath: "\(url).bor"){
            FCFileManager.removeItem(atPath: "\(url).bor")
        }
        if FCFileManager.existsItem(atPath: "\(url).json"){
            FCFileManager.removeItem(atPath: "\(url).json")
        }
    }
    
    // MARK: DETECT FILE IN FOLDER
    public func detectIfFileExistInLibrary(_ url: String) -> Bool{
        return FCFileManager.existsItem(atPath: url)
    }
    
    // MARK: GET DATA FROM FILE
    public func getDataFromFile(_ url: String) -> Data?{
        if FCFileManager.existsItem(atPath: url) {
            return ConfigurationManager.shared.utilities.read(asData: url)
        } else {
            return nil
        }
    }
    
    // MARK: DATE FOR ELEMENTS
    public func getFormatDate() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd hh:mm:ss"
        return formatter.string(from: Date())
    }
    
    // MARK: DATE
    public func getCurrentDate() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmss"
        return formatter.string(from: Date())
    }
    
    // MARK: GUID GENERATOR
    public func guid() -> String {
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        dateFormatter.timeZone = NSTimeZone.local
        let timeStamp = dateFormatter.string(from: date as Date)
        var milli = String(date.timeIntervalSince1970 * 1000)
        milli = milli.replacingOccurrences(of: ".", with: "")
        return "\(timeStamp)\(String(milli.suffix(5)))"
    }
    
    // MARK: REMOVE RESOURCE
    public func removeFromDeviceFolder(_ path: String){
        FCFileManager.removeItem(atPath: "\(path)");
        refreshFolderCapacity()
    }
    
    // HUD Loading
    public func incrementHUD(_ hud: JGProgressHUD, _ view: UIView, progress previousProgress: Int, _ label: String) {
        
        if previousProgress == 100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                UIView.animate(withDuration: 0.1, animations: {
                    hud.textLabel.text = NSLocalizedString("hud_success", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: "")
                    hud.detailTextLabel.text = nil
                    hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                })
                hud.dismiss(afterDelay: 1.0)
            }
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                UIView.animate(withDuration: 0.1, animations: {
                    let progress = previousProgress
                    hud.progress = Float(progress)/100.0
                    hud.textLabel.text = label
                    hud.detailTextLabel.text = String(format: NSLocalizedString("hud_progress", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), String(progress))
                })
            }
        }
        
    }
    
    // Banner Notification
    public func setNotificationBanner(_ title: String, _ subtitle: String, _ style: BannerStyle, _ direction: BannerPosition) -> NotificationBanner{
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: style)
        return banner
    }
    public func setStatusBarNotificationBanner(_ title: String, _ style: BannerStyle, _ direction: BannerPosition) -> StatusBarNotificationBanner{
        let banner = StatusBarNotificationBanner(title: title, style: style)
        return banner
    }
    
    // TouchID Authentication
    public func authenticationWithTouchID() -> Promise<Bool> {
        
        return Promise<Bool>{ resolve, reject in
            
            let localAuthenticationContext = LAContext()
            localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
            
            var authError: NSError?
            let reasonString = "Para acceder de manera fácil y segura a la cuenta configurada en el dispositivo."
            
            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                
                localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                    
                    if success {
                        resolve(true)
                    } else {
                        guard evaluateError != nil else { reject(APIErrorResponse.defaultError); return }
                        reject(APIErrorResponse.defaultError)
                    }
                }
            } else {
                guard authError != nil else { return }
            }
            
        }
        
    }
    
    public func configureDirectAccess() -> Promise<Bool>{
        
        return Promise<Bool>{ resolve, reject in
            
            ConfigurationManager.shared.utilities.authenticationWithTouchID()
                .then { response in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
                        // Perform access to Plantillas only
                        resolve(true)
                    })
                    
                }.catch { error in reject(error) }
            
        }
        
    }
    
    public func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    public func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
    public func errorGen(_ domain: Domain, _ code: ApiErrors, _ success: Bool, _ message: String?, _ localized: String?) -> NSError{
        if localized != nil{
            return NSError(domain: domain.rawValue, code: code.rawValue, userInfo: ["success": success, "message": NSLocalizedString("\(localized ?? "")", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: "")])
        }
        return NSError(domain: domain.rawValue, code: code.rawValue, userInfo: ["success": success, "message": message ?? ""])
    }

}

public struct Console{
    
    public func initConsole(_ ex: CGFloat, _ ye: CGFloat, _ w: CGFloat, _ h: CGFloat, _ guide: UILayoutGuide? = nil){
        
        ConfigurationManager.shared.viewConsole = UIView.init(frame: CGRect(x: ex, y: ye, width: w, height: h))
        ConfigurationManager.shared.viewConsole?.backgroundColor = UIColor.black
        ConfigurationManager.shared.textConsole = UITextView.init(frame: CGRect(x: 0, y: 0, width: ex, height: ye))
        ConfigurationManager.shared.textConsole?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 9.0)
        ConfigurationManager.shared.textConsole?.backgroundColor = UIColor.black
        ConfigurationManager.shared.textConsole?.textColor = UIColor.white
        ConfigurationManager.shared.textConsole?.isEditable = false
        ConfigurationManager.shared.viewConsole?.addSubview(ConfigurationManager.shared.textConsole!)
        
        let layout = ConfigurationManager.shared.viewConsole?.layoutMarginsGuide
        
        ConfigurationManager.shared.textConsole!.translatesAutoresizingMaskIntoConstraints = false
        ConfigurationManager.shared.textConsole!.leadingAnchor.constraint(equalTo: layout!.leadingAnchor, constant: 0).isActive = true
        ConfigurationManager.shared.textConsole!.topAnchor.constraint(equalTo: layout!.topAnchor, constant: 0).isActive = true
        ConfigurationManager.shared.textConsole!.heightAnchor.constraint(equalTo: layout!.heightAnchor, constant: 0).isActive = true
        ConfigurationManager.shared.textConsole!.widthAnchor.constraint(equalTo: layout!.widthAnchor, constant: 0).isActive = true
        
    }
    
    public func addTextConsole(_ string: String, _ typeConsole: String){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss a"
        let logTime = formatter.string(from: Date())
        switch typeConsole{
        case "error":
            let string1 = ConfigurationManager.shared.textConsole?.attributedText
            let string2 = NSAttributedString(string: "\(logTime) Error - \(string) \r\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            let newMutableString = string1?.mutableCopy() as! NSMutableAttributedString
            newMutableString.append(string2)
            ConfigurationManager.shared.textConsole?.attributedText = newMutableString.copy() as? NSAttributedString
            let bottom = NSMakeRange(newMutableString.length - 0, 0)
            ConfigurationManager.shared.textConsole!.scrollRangeToVisible(bottom)
            break
        case "log":
            let string1 = ConfigurationManager.shared.textConsole?.attributedText
            let string2 = NSAttributedString(string: "\(logTime) - \(string) \r\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            let newMutableString = string1?.mutableCopy() as! NSMutableAttributedString
            newMutableString.append(string2)
            ConfigurationManager.shared.textConsole?.attributedText = newMutableString.copy() as? NSAttributedString
            let bottom = NSMakeRange(newMutableString.length - 0, 0)
            ConfigurationManager.shared.textConsole!.scrollRangeToVisible(bottom)
            break
        default:
            let string1 = ConfigurationManager.shared.textConsole?.attributedText
            let string2 = NSAttributedString(string: "\(logTime) Unknown - \(string) \r\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            let newMutableString = string1?.mutableCopy() as! NSMutableAttributedString
            newMutableString.append(string2)
            ConfigurationManager.shared.textConsole?.attributedText = newMutableString.copy() as? NSAttributedString
            let bottom = NSMakeRange(newMutableString.length - 0, 0)
            ConfigurationManager.shared.textConsole!.scrollRangeToVisible(bottom)
            break
        }
    }
}
