//
//  APIManager.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 20/08/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation
import Eureka
import FirebaseFirestore
import CommonCrypto
// MARK: API PROTOCOLS
/// Protocol used to callback inside SDK methods
public protocol ControllerDelegate: class {
    func performConsultaViewController(_ index: Int)
    func performNuevoFeViewController(_ plantilla: FEPlantillaData, _ index: Int)
    func performFlowSelection(_ index: Int)
    func updatePlantillas()
}
/// Generic Protocol for calling protocol (ControllerDelegate) in all ViewControllers
public final class ControllersManager<Del: ControllerDelegate>: NSObject {
    public weak var delegate: Del?
}

public protocol FormularioDelegate: class {
    // Access to all Resolve functions
    func resolveValor(_ id: String, _ mode: String, _ string: String, _ category: String?) -> Bool
    func resolveVisible(_ id: String, _ mode: String, _ string: String) -> Bool
    func resolveRequerido(_ id: String, _ mode: String, _ string: String) -> Bool
    func resolveHabilitado(_ id: String, _ mode: String, _ string: String) -> Bool
    func resolveValorQR(_ namePrellenado: String, _ idQRgenerado: String) -> Bool
    
    // Rules
    func obtainMathematics(_ element: String, _ isForced: Bool?)
    func valueElementRow (_ idElem: String ) -> String
    func valueMetaElementRow (_ idElem: String, _ isCombo: String?) -> (value: String, row: BaseRow)
    func updateDataComboDinamico (idsCombo : [(id: String, row: BaseRow)] )
    func isfilter (idElement : String )-> String
    
    // Getting information
    func setDataAttributes(valor l:String, metadato m:String, habilitado h:Bool, visible v:Bool) -> NSMutableDictionary
    func setTablaDataAttributes(valor l: String, metadato m:String, idunico i:String, titulo t: String) -> NSMutableDictionary
    func setComboboxTempAttributes(valor l:String, metadato m:String, idunico i:String, catalogoDestino cd:String) -> NSMutableDictionary
    func setMetaAttributes(_ e: Elemento, _ isPrellenado: Bool)
    
    func setTipoDoc(_ e: Elemento) -> Int
    func detectValidation(elem: Elemento, route: String)->[String]?
    func setPrefilledDataToNewForm(_ id: String, json: String, elements: NSMutableDictionary?)
    
    // Location
    func checkLocationPermission()
    func openSettingApp(message: String)
    
    // Exclusive FormViewController
    func getFormatoDataObject() -> FEFormatoData
    func getFormViewControllerDelegate() -> FormViewController?
    func getNestedForm() -> FormViewController?
    func setNestedForm(_ nav: FormViewController?)
    func getAllRowsFromCurrentForm() -> [BaseRow]
    func reloadTableViewFormViewController()
    func detectAttrVisibility(_ row: BaseRow) -> Bool
    func setVisibleEnableElementsFromSection(_ tag: String, _ atributos: Atributos_seccion, _ forced: Bool, _ isUserAction: Bool)
    func getParentsection(_ rowString: String) -> Atributos_seccion?
    func getPageTitle(_ rowString: String) -> String
    func getPageID(_ rowString: String) -> String
    func getPlantillaTitle() -> String
    func getWizardFunctionalityFromTable(_ tag: String)
    
    func getRowByIdInAllForms(_ id: String) -> (element: TipoElemento, row: BaseRow?)
    
    func getElementByIdInAllForms(_ id: String) -> BaseRow?
    func getSectionByIdInCurrentForm(_ id: String) -> Section?
    func getElementByIdInCurrentForm(_ id: String) -> BaseRow?
    func getElementByIdsInCurrentForm(_ ids: [String]) -> [BaseRow?]
    func getColorsErrors(_ type: enumErrorType) -> [UIColor]
    func getCurrentPage() -> Int
    // Actions
    
    func setOCRDetails(_ service: Int, _ object: AnyObject, _ element: String)
    
    func wizardAction(id: String, validar: Bool, tipo: String, atributos: Atributos_wizard) -> Bool
    func openForm(tipoDoc: Int, expId: Int, flujoId: Int, piid: Int, guid: String)
    func wizardActionTabla(id: String, validar: Bool, tipo: String, atributos: Atributos_wizard)
    func addEventAction(_ expresion: Expresion)
    //func obtainRules(rString rlString: String?, eString element: String?, vString vrb: String?)
    func obtainRules(rString rlString: String?, eString element: String?, vString vrb: String?, forced isForced: Bool?, override isOverrided: Bool?)->Promise<Bool>
    func obtainerLocation() -> String
    func getValueFromTitleComponent(_ id: String) -> String
    func getValueFromComponent(_ id: String) -> String
    func getImagesFromElement(_ compareFaces: CompareFacesJson) -> CompareFacesResult?
    func getColoniasElement(_ sepomex: SepomexJson) -> SepoMexResult?
    func getLeyendaText(leyenda: String) -> String
    
    func recursiveTokenFormula(_ formul: String?,_ dict: [Formula]?, _ typefrml: String, _ encoded: Bool) -> ReturnFormulaType
    func setNotificationBanner(_ title: String, _ subtitle: String, _ style: BannerStyle, _ direction: BannerPosition)
    func setStatusBarNotificationBanner(_ title: String, _ style: BannerStyle, _ direction: BannerPosition)
    func getElementService(_ prefijo: String, _ isSalida: Bool) -> [String:Any]
    func configButton(tipo : String, btnStyle : UIButton, nameIcono : String, titulo : String, colorFondo : String, colorTxt : String ) -> UIButton
}

public final class FormManager<Del: FormularioDelegate>: NSObject {
    public weak var delegate: Del?
}

public protocol APIDelegate: class {
    
}

public final class APIManager<Delegate: APIDelegate>: NSObject, NSURLConnectionDelegate {
    public weak var delegate: Delegate?
    public var dispatchForms = DispatchGroup()
    public var dispatchAttachments = DispatchGroup()
    public func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print("Timeout reached or server is no available")
    }
}

@objc public protocol TemplateDelegate: class {
    func didFormatViewFinish(error: NSError?, success: [String : Any]?)
    @objc optional func onFinishFormat_Cancelado(error: NSError?)
    @objc optional func onFinishFormat_Borrador(guid: String, error: NSError?, success: [String : Any]?)
    @objc optional func onFinishFormat_Publicar(guid: String, error: NSError?, success: [String : Any]?)
    @objc optional func onFinishFormat_WaitUIFromUser(guid: String, error: NSError?, success: [String : Any]?)
}

public final class TemplateManager<Delegate: TemplateDelegate>: NSObject {
    public weak var delegate: Delegate?
}
// MARK: - API MANAGER
// MARK: - CODIGO
public extension APIManager{
    
    enum requestMode{
        case sync
        case async
    }
    func setTimerLogForRequest(mode: requestMode, request: URLRequest, launcher: String, debug: Bool = false) -> Promise<Data>{
        
        return Promise<Data>{ resolve, reject in
            // Set Timer
            var timer: Timer = Timer()
            var seconds: Int = 0
            if debug{
                print("\(launcher) - Ping Server... \r")
                seconds += 1
                timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true){ timer in
                    print("\(launcher) - Ping Server... \r")
                    seconds += 1
                }
            }
            
            switch mode {
            case .sync:
                
                let semaphore = DispatchSemaphore(value: 0)
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    
                    guard data != nil && error == nil else{
                        if debug{
                            print("\(launcher) - \(error?.localizedDescription ?? "No data in Request")\r")
                        }
                        semaphore.signal()
                        timer.invalidate()
                        reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"))
                        return
                    }
                    if debug{
                        print("\(launcher) - Server send data successfully in \(seconds) seconds\r")
                    }
                    timer.invalidate()
                    resolve(data!)
                }
                task.resume()
                semaphore.wait()
                
                break;
            case .async:
                DispatchQueue.global(qos: .background).async {
                    
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        
                        guard data != nil && error == nil else{
                            if debug{
                                print("\(launcher) - \(error?.localizedDescription ?? "No data in Request")\r")
                            }
                            timer.invalidate()
                            
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"))
                            return
                        }
                        if debug{
                            print("\(launcher) - Server send data successfully in \(seconds) seconds\r")
                        }
                        timer.invalidate()
                        resolve(data!)
                    }
                    task.resume()
                }
                break;
            }
            
        }
        
    }
    
    func DGSDKDebugUserRequest() -> Promise<FEConsultaAcceso>{
        
        return Promise<FEConsultaAcceso>{ resolve, reject in
            var mutableRequest: URLRequest
            
            mutableRequest = URLRequest(url: URL(string: "https://dgp-access-console.herokuapp.com/uZ7n4L7CYzkp4GzFGT60_i4kTqmUKS7afJLUQRuEb.php")!,timeoutInterval: Double.infinity)
            mutableRequest.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                guard data != nil && error == nil else {
                    ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata")); return; }
                
                let bodyData = Data(base64Encoded: data ?? Data())!
                let decodedString = String(data: bodyData, encoding: .utf8)!
                let object = FEConsultaAcceso(json: decodedString)
                resolve(object)
            }); task.resume()
        }
        
    }
    
    // MARK: - Check Licence
    /// DGSDKLicence Allows to connect the server to verify if the app has access to download content and use the SDK within the app of the user
    ///
    /// - Parameters:
    ///   - innerkey: BundleID of the app in use
    ///   - innersecret: Licence string to send data to the server
    /// - Returns: return true/false if the Licence is valid
    func DGSDKLicenceWith(appkey innerKey: String, secretid innersecret: String, completionHandler: (_ resolve: Bool, _ reject: Error) -> Void){
        
        let _ = Bundle.main.bundleIdentifier
        completionHandler(true, APIErrorResponse.defaultError)
        
    }
    
    func DGSDKLogin(code innerCode: String, user innerUser: String, pass innerPass: String, delegate innerDelegate: Delegate?) -> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            self.DGSDKLoginCode(code: innerCode, delegate: innerDelegate)
            .then { response in
                self.DGSDKLoginUser(user: innerUser, pass: innerPass, delegate: innerDelegate)
                .then { response in resolve(response)
                        }.catch { error in reject(error) }
                }.catch { error in reject(error) }
        }
    }
    
    // MARK: - CheckCodeOnline
    /// Method to call LoginCode method and request code authorization
    /// - Parameters:
    ///   - innerCode: code setted to login
    ///   - innerDelegate: delegate viewcontroller
    /// - Returns:
    ///   - APISuccessResponse: Object with message for success or failure
    func DGSDKLoginCode(code innerCode: String, delegate innerDelegate: Delegate?) -> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            let typeName: String = #function
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)
            ConfigurationManager.shared.codigoUIAppDelegate.Codigo = innerCode
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                if self.validCodeOffline(delegate: self.delegate){
                    resolve(APISuccessResponse.success)
                    return
                }else{
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
                    return
                }
            }
            do{
                let mutableRequest: URLRequest
                mutableRequest = try ConfigurationManager.shared.request.codigoRequest()
                setTimerLogForRequest(mode: .async, request: mutableRequest, launcher: typeName, debug: ConfigurationManager.shared.debugNetwork)
                    .then { data in
                        
                        do{
                            
                            let doc = try AEXMLDocument(xml: data)
                            
                            let getCodeResult = doc["s:Envelope"]["s:Body"]["CheckCodigoResponse"]["CheckCodigoResult"].string
                            
                            let response = AjaxResponse(json: getCodeResult)
                            ConfigurationManager.shared.utilities.writeLogger("Mensaje: \(response.Mensaje)", .info)
                            if(response.Success){
                                ConfigurationManager.shared.utilities.writeLogger("\(typeName): 200", .success)
                                
                                guard let rObject = response.ReturnedObject else{
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, "Objeto nulo o sin información"))
                                    return
                                }
                                ConfigurationManager.shared.utilities.writeLogger("\(rObject)", .info)
                                let codeObject = FECodigo(dictionary: rObject)
                                
                                ConfigurationManager.shared.codigoUIAppDelegate = codeObject
                                ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer = codeObject.WcfFileTransfer.cleanURLString()
                                ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios = codeObject.WcfServicios.cleanURLString()
                                
                                self.salvarCodigo(delegate: innerDelegate)
                                resolve(APISuccessResponse.success)
                            }else{
                                ConfigurationManager.shared.utilities.writeLogger(response.Mensaje, .info)
                                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, response.Mensaje))
                                if ConfigurationManager.shared.isConsubanco{
                                    ConfigurationManager.shared.utilities.log(.error, response.Mensaje)
                                }
                            }
                            
                        }catch let e{
                            ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
                            ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .info)
                            if ConfigurationManager.shared.isConsubanco{
                            }
                        }
                        
                    }.catch { error in
                        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_timeout".langlocalized(), typeName), .info)
                        reject(error)
                    }
            }catch let e{
                ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
            }
            
        }
        
    }
    
    // MARK: - CheckCodeOffline
    /// Method to call CodeOffline and request from library
    /// - Parameter delegate: delegate viewcontroller
    func validCodeOffline(delegate: Delegate?) -> Bool{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "validCodeOffline"), .info)
        
        ConfigurationManager.shared.codigoUIAppDelegate.Codigo = ConfigurationManager.shared.codigoUIAppDelegate.Codigo.uppercased()
        
        ConfigurationManager.shared.utilities.writeLogger("\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo.uppercased())", .info)
        
        if(ConfigurationManager.shared.codigoUIAppDelegate.Codigo != "" && ConfigurationManager.shared.codigoUIAppDelegate.Codigo != "default"){
            /* Checking a the Local Code settings */
            
            guard let codigoOffline = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/Codigo.cod") else {
                ConfigurationManager.shared.utilities.writeLogger("Archivo Código no encontrado en el dispositivo.", .error)
                return false
            }
            // Set Codigo as saved in File
            if codigoOffline == ""{ return false }
            ConfigurationManager.shared.utilities.writeLogger("\(codigoOffline)", .info)
            ConfigurationManager.shared.codigoUIAppDelegate =  FECodigo(json: codigoOffline)
            ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
            ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
            plist.codigo.rawValue.dataSSet(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)
            
            return true
        }
        ConfigurationManager.shared.utilities.writeLogger("apimng_log_preference".langlocalized(), .error)
        return false
    }
    
    // MARK: - SalvarCodigo
    /// Method to call CodeSave, update and save Code in library
    /// - Parameter delegate: delegate viewcontroller
    func salvarCodigo(delegate: Delegate?){
        
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "salvarCodigo"), .info)
        
        let json = JSONSerializer.toJson(ConfigurationManager.shared.codigoUIAppDelegate)
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/Codigo.cod")
        plist.codigo.rawValue.dataSSet(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)
        // Function to reasing the value (FILES IN MB) in the Settings Bundle
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
        
    }
}

// MARK: - SKIN
public extension APIManager{
    
    // MARK: - CheckSkinOnline
    /// Method to call Skin method and request skin for templating
    /// - Parameter delegate: delegate viewcontroller
    func DGSDKSkin(delegate: Delegate?) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            
            let typeName: String = #function
            
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)
            
            if self.validSkinOffline(delegate: delegate){
                resolve(APISuccessResponse.success)
            }
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
            }
            
            do{
                let mutableRequest: URLRequest
                mutableRequest = try ConfigurationManager.shared.request.skinRequest()
                
                setTimerLogForRequest(mode: .async, request: mutableRequest, launcher: typeName, debug: ConfigurationManager.shared.debugNetwork)
                    .then { data in
                        
                        do{
                            let doc = try AEXMLDocument(xml: data)
                            // Exclusive IDportal Number for Security
                            
                            let getCodeResult = doc["s:Envelope"]["s:Body"]["ObtieneSkinResponse"]["ObtieneSkinResult"].string
                            let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                            let decompressedData: Data
                            if bodyData.isGzipped {
                                decompressedData = try! bodyData.gunzipped()
                            } else {
                                decompressedData = bodyData
                            }
                            let decodedString = String(data: decompressedData, encoding: .utf8)!
                            let response = AjaxResponse(json: decodedString)
                            ConfigurationManager.shared.utilities.writeLogger("Mensaje: \(response.Mensaje)", .info)

                            if(response.Success){
                                ConfigurationManager.shared.utilities.writeLogger("\(typeName): 200", .success)

                                guard let rObject = response.ReturnedObject else{
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, "Objeto nulo o sin información"))
                                    return
                                }
                                ConfigurationManager.shared.utilities.writeLogger("\(rObject)", .info)
                                ConfigurationManager.shared.skinUIAppDelegate = FEAppSkin(dictionary: rObject)
                                self.salvarSkin(delegate: delegate)
                                resolve(APISuccessResponse.success)
                            }
                            
                        }catch let e{
                            ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
                        }
                        
                    }.catch { error in
                        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_timeout".langlocalized(), typeName), .info)
                        reject(error)
                    }
                
            }catch let e{
                ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
            }
            
        }
        
    }
    
    // MARK: - CheckSkinOffline
    /// Method to call SkinOffline and request from library
    /// - Parameter delegate: delegate viewcontroller
    func validSkinOffline(delegate: Delegate?) -> Bool{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "validSkinOffline"), .info)
        
        if(ConfigurationManager.shared.codigoUIAppDelegate.Codigo != "" && ConfigurationManager.shared.codigoUIAppDelegate.Codigo != "default"){
            /* Checking a the Local Code settings */
            guard let skinOffline = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/Skin.ski")else {
                ConfigurationManager.shared.utilities.writeLogger("Archivo SKIN de: \(ConfigurationManager.shared.codigoUIAppDelegate.Codigo) no ha sido encontrado en el dispositivo.", .error)
                return false
            }
            // Set Codigo as saved in File
            if skinOffline == ""{ return false }
            ConfigurationManager.shared.utilities.writeLogger("\(skinOffline)", .info)
            ConfigurationManager.shared.skinUIAppDelegate =  FEAppSkin(json: skinOffline)
            return true
        }
        ConfigurationManager.shared.utilities.writeLogger("apimng_log_preference".langlocalized(), .error)
        return false
    }

    // MARK: - SalvarSkin
    /// Method to call SkinSave, update and save Skin in library
    /// - Parameter delegate: delegate viewcontroller
    func salvarSkin(delegate: Delegate?){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "salvarSkin"), .info)
        let json = JSONSerializer.toJson(ConfigurationManager.shared.skinUIAppDelegate)
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/Skin.ski")
        // Function to reasing the value (FILES IN MB) in the Settings Bundle
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
    }
    
}

// MARK: - Usuario
public extension APIManager{
    // MARK: - CheckUserOnline
    /// Method to request User information
    /// - Parameters:
    ///   - innerUser: user information
    ///   - innerPass: pass information
    ///   - innerDelegate: delegate viewcontroller
    func DGSDKLoginUser(user innerUser: String, pass innerPass: String, delegate innerDelegate: Delegate?) -> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            
            let typeName: String = #function
            
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                if self.validUserOffline(delegate: innerDelegate, user: innerUser, pass: innerPass){
                    resolve(APISuccessResponse.success)
                }else{
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
                }
            }
            
            // Setting password to security
            var password = Array(innerPass.utf8)
            password = password.sha512()
            let passwordString = password.toBase64()
            ConfigurationManager.shared.usuarioUIAppDelegate.Password = passwordString
            
            let pass = Array(innerPass.utf8)
            let passwordBase = pass.toBase64()
            ConfigurationManager.shared.usuarioUIAppDelegate.PasswordEncoded = passwordBase
            ConfigurationManager.shared.usuarioUIAppDelegate.User = innerUser
            ConfigurationManager.shared.usuarioUIAppDelegate.IP = ConfigurationManager.shared.utilities.getIPAddress()
            ConfigurationManager.shared.usuarioUIAppDelegate.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            ConfigurationManager.shared.usuarioUIAppDelegate.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            
            ConfigurationManager.shared.usuarioUIAppDelegate.TokenDispositivo = ConfigurationManager.shared.deviceTokenRemote
            ConfigurationManager.shared.usuarioUIAppDelegate.ProveedorPush = "IOS"
            //ConfigurationManager.shared.usuarioUIAppDelegate.Bundle = "com.myproperty.digipro"
            let startDate = Date()
            
            do{
                let mutableRequest: URLRequest
                mutableRequest = try ConfigurationManager.shared.request.usuarioRequest()
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                setTimerLogForRequest(mode: .async, request: mutableRequest, launcher: typeName, debug: ConfigurationManager.shared.debugNetwork)
                    .then { [self] data in
                        //var bodyData: Data
                        do{
                            let doc = try AEXMLDocument(xml: data)
                            // Exclusive IDportal Number for Security
                            let getCodeResult = doc["s:Envelope"]["s:Body"]["LoginResponse"]["LoginResult"].string
                            let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                            let decompressedData: Data
                            if bodyData.isGzipped {
                                decompressedData = try! bodyData.gunzipped()
                            } else {
                                decompressedData = bodyData
                            }
                            let decodedString = String(data: decompressedData, encoding: .utf8)!
                            
                            let response = AjaxResponse(json: decodedString)
                            if(response.Success){
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                ConfigurationManager.shared.usuarioUIAppDelegate = FEUsuario(dictionary: response.ReturnedObject!)
                                if  !ConfigurationManager.shared.usuarioUIAppDelegate.Token.Token.isEmpty{
                                    ConfigurationManager.shared.webSecurity = true
                                }else{ConfigurationManager.shared.webSecurity = false}
                                if ConfigurationManager.shared.usuarioUIAppDelegate.AceptoTerminos == false{
                                    let m = "not_terms_invalid".langlocalized()
                                    ConfigurationManager.shared.utilities.writeLogger("\(m)", .error)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.terms, false, nil, "\(m)"))

                                }else{
                                    self.salvarUsuario(delegate: innerDelegate)
                                    resolve(APISuccessResponse.success)
                                }
                            }else{
                                let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                                if response.Mensaje.lowercased().contains("usuario o contraseña incorrecta"){
                                    let m = "not_userpass_invalid".langlocalized()
                                    ConfigurationManager.shared.utilities.writeLogger("\(m)", .error)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.noSession, false, nil, "\(m)"))
                                    if ConfigurationManager.shared.isConsubanco{
                                    }
                                }else if response.Mensaje.lowercased().contains("error de configuración"){
                                    let m = "not_misconfiguration_invalid".langlocalized()
                                    ConfigurationManager.shared.utilities.writeLogger("\(m)", .error)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.misConfiguration, false, nil, "\(m)"))
                                    if ConfigurationManager.shared.isConsubanco{
                                    }
                                }else if response.Mensaje.lowercased().contains("el usuario debe cambiar la contraseña"){
                                    let m = "not_userchange_invalid".langlocalized()
                                    ConfigurationManager.shared.utilities.writeLogger("\(m)", .error)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.changePassword, false, nil, "\(m)"))
                                    if ConfigurationManager.shared.isConsubanco{
                                       
                                    }
                                }else if response.Mensaje.lowercased().contains("intento a cuenta deshabilitada"){
                                    let m = "not_useraccount_disabled".langlocalized()
                                    ConfigurationManager.shared.utilities.writeLogger("\(m)", .error)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.disabledAccount, false, nil, "\(m)"))
                                    if ConfigurationManager.shared.isConsubanco{
                                        
                                    }
                                }else if response.Mensaje.contains("Account blocked"){
                                    let m = "not_useraccount_disabled".langlocalized()
                                    ConfigurationManager.shared.utilities.writeLogger("\(m)", .error)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.disabledAccount, false, nil, "\(m)"))
                                    if ConfigurationManager.shared.isConsubanco{
                                        ConfigurationManager.shared.utilities.log(.error, response.Mensaje)
                                    }
                                }else if response.Mensaje.contains("Authentication error, check username or password."){
                                    let m = "not_useraccount_disabled".langlocalized()
                                    ConfigurationManager.shared.utilities.writeLogger("\(m)", .error)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.disabledAccount, false, nil, "\(m)"))
                                    if ConfigurationManager.shared.isConsubanco{
                                    }
                                    
                                }else{
                                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.xml , false, nil, "\(response.Mensaje)"))
                                    if ConfigurationManager.shared.isConsubanco{
                                    }
                                }
                            }
                        }catch let e{
                            ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.xml, false, nil, e.localizedDescription))
                        }
                    }.catch { error in
                        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_timeout".langlocalized(), typeName), .info)
                        reject(error)
                    }
                
            }catch let e{
                ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
            }
            
        }
        
    }
    
    /// Funcion que permite obtener el return Object del servicio
    /// - Parameter aexmlD: Obtención de XML para la respuesta
    /// - Parameter r: r descripion
    /// - Returns: valor de retorno string encriptado con la respuesta del servicio
    func getReturnObject(aexmlD: AEXMLDocument, r: String = "") -> String{
        var returnObj: String = ""
        do{
            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                let encodigSoapTest = try self.decodeReturnSoap(aexmlD["s:Envelope"]["s:Body"]["response"].string)
                let jsonDict = try JSONSerializer.toDictionary(encodigSoapTest)
                if let returnobj = jsonDict["ReturnedObject"] as? String{
                    returnObj = returnobj
                }
            }else{
                
                returnObj = r
            }
            
        }catch{
            let e = "alrt_error_try".langlocalized()
            ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
            
        }
        return returnObj
    }
    
    
    func logsService(log: Bool, responseData: AEXMLDocument, servicio: String, requestData: String, startDate: Date, endDate: Date, lineError: String, error: String, _ initialmethod: String = "", _ dll: String = ""){
        let semaphore = DispatchSemaphore(value: 0)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"//"yyyyMMddhhmmssSSS"
        let dateInfo = formatter.string(from: startDate)
        let logObject = FELogs()
        let device = Device()
        let deviceInfo = "Model: \(device.description) Name: \(device.name ?? "") OS: \(device.systemVersion ?? "")"
        logObject.Usuario = ConfigurationManager.shared.usuarioUIAppDelegate.User; logObject.Dispositivo = deviceInfo; logObject.Codigo = ConfigurationManager.shared.codigoUIAppDelegate.Codigo; logObject.Servicio = servicio
    
        let diffs = Calendar.current.dateComponents([.minute, .second, .nanosecond], from: startDate, to: endDate)
        logObject.TiempoDeRespuesta = "\(String(describing: diffs.minute ?? 0)):\(String(describing: diffs.second ?? 0)):\(String(describing: diffs.nanosecond ?? 0))"
        logObject.FechaRequest = dateInfo; logObject.FechaResponse = formatter.string(from: endDate);

        if ConfigurationManager.shared.ifLogSent{
            let db = Firestore.firestore()
            if log{
                
                let formatterFile = DateFormatter()
                formatterFile.dateFormat = "yyyyMMddHHmmssSSS"
                let name = formatterFile.string(from: startDate)
                let dataObject = JSONSerializer.toJson(logObject)
                _ = ConfigurationManager.shared.utilities.saveLog(info: dataObject, path: "\(Cnstnt.Tree.logs)/\(name).txt")
                var dictLog: [String:Any]  = [String:Any]()
                if initialmethod.isEmpty && dll.isEmpty{
                    if ConfigurationManager.shared.ifDataSent{
                        logObject.RequestData = requestData; logObject.ResponseData = responseData.xmlCompact
                        dictLog = ["\(name)":["Codigo":logObject.Codigo, "Dispositivo":logObject.Dispositivo, "FechaRequest":logObject.FechaRequest, "FechaResponse":logObject.FechaResponse, "Servicio":logObject.Servicio, "TiempoDeRespuesta":logObject.TiempoDeRespuesta, "Usuario":logObject.Usuario, "RequestData":logObject.RequestData, "ResponseData":logObject.ResponseData]]
                    }else{
                        dictLog = ["\(name)":["Codigo":logObject.Codigo, "Dispositivo":logObject.Dispositivo, "FechaRequest":logObject.FechaRequest, "FechaResponse":logObject.FechaResponse, "Servicio":logObject.Servicio, "TiempoDeRespuesta":logObject.TiempoDeRespuesta, "Usuario":logObject.Usuario]]
                    }
                }else{
                    if ConfigurationManager.shared.ifDataSent{
                        logObject.RequestData = requestData; logObject.ResponseData = responseData.xmlCompact
                        dictLog = ["\(name)":["Assemblypath":ConfigurationManager.shared.assemblypath, "Codigo":logObject.Codigo, "Dispositivo":logObject.Dispositivo, "FechaRequest":logObject.FechaRequest, "FechaResponse":logObject.FechaResponse, "Initialmethod":ConfigurationManager.shared.initialmethod, "Servicio":logObject.Servicio, "TiempoDeRespuesta":logObject.TiempoDeRespuesta, "Usuario":logObject.Usuario, "RequestData":logObject.RequestData, "ResponseData":logObject.ResponseData]]
                    }else{
                        dictLog = ["\(name)":["Assemblypath":ConfigurationManager.shared.assemblypath,"Codigo":logObject.Codigo, "Dispositivo":logObject.Dispositivo, "FechaRequest":logObject.FechaRequest, "FechaResponse":logObject.FechaResponse,"Initialmethod":ConfigurationManager.shared.initialmethod, "Servicio":logObject.Servicio, "TiempoDeRespuesta":logObject.TiempoDeRespuesta, "Usuario":logObject.Usuario]]
                    }
                }
                db.collection("logsIOS").document("\(logObject.Codigo)_\(logObject.Usuario)").setData(dictLog, merge: true){ err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        semaphore.signal()
                    } else {
                        print("Document successfully written!")
                        semaphore.signal()
                    }
                }
    //            let storageRef = Storage.storage().reference().child("logsIOS/\(logObject.Codigo)_\(logObject.Usuario)/\(name).txt")
    //            let data = dataObject.data(using: .utf8)
    //            _ = storageRef.putData(data!, metadata: nil) { (metadata, error) in
    //                guard metadata != nil else {
    //                    semaphore.signal()
    //                return
    //              }
    //                semaphore.signal()
    //            }
               
            }else{
                logObject.Error = error
                logObject.LineError = lineError
                let formatterFile = DateFormatter()
                formatterFile.dateFormat = "yyyyMMddHHmmssSSS"
                let name = formatterFile.string(from: startDate)
                let dataObject = JSONSerializer.toJson(logObject)
                _ = ConfigurationManager.shared.utilities.saveLog(info: dataObject, path: "\(Cnstnt.Tree.logs)/\(name).txt")
                var dictLog: [String:Any]  = [String:Any]()
                if initialmethod.isEmpty && dll.isEmpty{
                    if ConfigurationManager.shared.ifDataSent{
                        logObject.RequestData = requestData; logObject.ResponseData = responseData.xmlCompact
                        dictLog = ["\(name)":["Codigo":logObject.Codigo, "Dispositivo":logObject.Dispositivo, "Error":logObject.Error, "FechaRequest":logObject.FechaRequest, "FechaResponse":logObject.FechaResponse, "LineError":logObject.LineError, "Servicio":logObject.Servicio, "TiempoDeRespuesta":logObject.TiempoDeRespuesta, "Usuario":logObject.Usuario, "RequestData":logObject.RequestData, "ResponseData":logObject.ResponseData]]
                    }else{
                        dictLog = ["\(name)":["Codigo":logObject.Codigo, "Dispositivo":logObject.Dispositivo, "Error":logObject.Error, "FechaRequest":logObject.FechaRequest, "FechaResponse":logObject.FechaResponse, "LineError":logObject.LineError, "Servicio":logObject.Servicio, "TiempoDeRespuesta":logObject.TiempoDeRespuesta, "Usuario":logObject.Usuario]]
                    }
                }else{
                    if ConfigurationManager.shared.ifDataSent{
                        logObject.RequestData = requestData; logObject.ResponseData = responseData.xmlCompact
                        dictLog = ["\(name)":["Assemblypath":ConfigurationManager.shared.assemblypath,"Codigo":logObject.Codigo, "Dispositivo":logObject.Dispositivo, "Error":logObject.Error, "FechaRequest":logObject.FechaRequest, "FechaResponse":logObject.FechaResponse, "LineError":logObject.LineError,"Initialmethod":ConfigurationManager.shared.initialmethod, "Servicio":logObject.Servicio, "TiempoDeRespuesta":logObject.TiempoDeRespuesta, "Usuario":logObject.Usuario, "RequestData":logObject.RequestData, "ResponseData":logObject.ResponseData]]
                    }else{
                        dictLog = ["\(name)":["Assemblypath":ConfigurationManager.shared.assemblypath,"Codigo":logObject.Codigo, "Dispositivo":logObject.Dispositivo, "Error":logObject.Error, "FechaRequest":logObject.FechaRequest, "FechaResponse":logObject.FechaResponse, "LineError":logObject.LineError, "Initialmethod":ConfigurationManager.shared.initialmethod, "Servicio":logObject.Servicio, "TiempoDeRespuesta":logObject.TiempoDeRespuesta, "Usuario":logObject.Usuario]]
                    }
                }

                db.collection("logsErrorIOS").document("\(logObject.Codigo)_\(logObject.Usuario)").setData(dictLog, merge: true){ err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        semaphore.signal()
                    } else {
                        print("Document successfully written!")
                        semaphore.signal()
                    }
                }
    //            let storageRef = Storage.storage().reference().child("logsErrorIOS/\(logObject.Codigo)_\(logObject.Usuario)/\(name).txt")
    //            let data = dataObject.data(using: .utf8)
    //            _ = storageRef.putData(data!, metadata: nil) { (metadata, error) in
    //                guard metadata != nil else {
    //                    semaphore.signal()
    //                    // Uh-oh, an error occurred!
    //                    return
    //                }
    //                semaphore.signal()
    //            }
            }
        }

        
    }
    
    //SERVICIO GENERICO V2
    func DGSDKService(delegate: Delegate?, initialmethod: String, assemblypath: String, data: [String : Any] ) -> Promise<String>{
        return Promise<String>{ resolve, reject in
            
            var newDict = data
        
            newDict.updateValue("\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)", forKey: "ProyectoID")
            newDict.updateValue("\(ConfigurationManager.shared.usuarioUIAppDelegate.GrupoAdminID)", forKey: "GrupoID")
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, "Revise su conexión a Internet.", "apimng_log_nodata"));
            }
            let dictService = ["initialmethod":"\(initialmethod)","assemblypath":"\(assemblypath)", "data": newDict] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            let response = self.soapGenericJsonSync(delegate: delegate, jsonService: NSString(string: jsonString))
            let jsonService = response["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
            let responseDecode = self.decodeXML(aexmlD: response, r: jsonService ?? "")
            if let _ = responseDecode.data(using: .utf8){
                do{
                    let jsonDict = try JSONSerializer.toDictionary(responseDecode)
                    let dataService = jsonDict["data"] as! NSMutableDictionary
                    let responseService = jsonDict["response"] as! NSMutableDictionary
                    //let servicesuccess = responseService["servicesuccess"] as! Bool
                    let success = responseService["success"] as! Bool
                    if success{
                        _ = JSONSerializer.toJson(dataService)
                        _ = jsonDict["data"] as! NSMutableDictionary
                        let responseService = jsonDict["response"] as! NSMutableDictionary
                        //let servicesuccess = responseService["servicesuccess"] as! Bool
                        let success = responseService["success"] as! Bool
                        if success{
                            //let jsonResponse = JSONSerializer.toJson(dataService)
                            resolve(responseDecode)
                        }else{
                            let e = responseService["error"] as? String ?? "Error en el servicio"
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.xml, false, nil, "\(e)"))
                            
                        }
                       
                    }else{
                        let e = responseService["error"] as? String ?? "Error en el servicio"
                        reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.xml, false, nil, "\(e)"))
                    }
                }catch{
                    let e = "Error al deserealizar el JSON interno DGSDK"
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.xml, false, nil, "\(e)"))
                }
            }
        }
    }
    
    func DGSDKServicioGen(delegate: Delegate?, initialmethod: String, assemblypath: String, data: [String : Any] ) -> String{
        var newDict = data
        let semaphore = DispatchSemaphore(value: 0)
        newDict.updateValue("\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)", forKey: "ProyectoID")
        newDict.updateValue("\(ConfigurationManager.shared.usuarioUIAppDelegate.GrupoAdminID)", forKey: "GrupoID")
        let dictService = ["initialmethod":"\(initialmethod)","assemblypath":"\(assemblypath)", "data": newDict] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        let response = self.soapGenericJsonSync(delegate: delegate, jsonService: NSString(string: jsonString))
        let jsonService = response["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
        let responseDecode = self.decodeXML(aexmlD: response, r: jsonService ?? "")
        if let _ = responseDecode.data(using: .utf8){
            do {
                let jsonDict = try JSONSerializer.toDictionary(responseDecode)
                let dataService = jsonDict["data"] as! NSMutableDictionary
                let responseService = jsonDict["response"] as! NSMutableDictionary
                //let servicesuccess = responseService["servicesuccess"] as! Bool
                let success = responseService["success"] as! Bool
                if success{
                    semaphore.signal()
                    let jsonResponse = JSONSerializer.toJson(dataService)
                    return jsonResponse
                }else{
                    semaphore.signal()
                    return responseService["servicemessage"] as? String ?? "Error en servicio intente más tarde"
                    //delegate?.didSendError(message: (responseService["servicemessage"] as? String)!, error: .error)
                }
                
            }catch{
                semaphore.signal()
                return "Json Invalido"
                //delegate?.didSendError(message: "JSON invalido.", error: .error)
            }
            
        }
        semaphore.wait()
        return ""
    }
    
    func decodeXML(aexmlD: AEXMLDocument, r: String = "") -> String{
        var returnObj: String = ""
        do{
            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                let encodigSoapTest = try self.decodeReturnSoap(aexmlD["s:Envelope"]["s:Body"]["response"].string)
                let jsonDict = try JSONSerializer.toDictionary(encodigSoapTest)
                if let returnobj = jsonDict["ReturnedObject"] as? String{
                    returnObj = returnobj
                }
            }else{
                
                returnObj = r
            }

        }catch{
            let e = "alrt_error_try".langlocalized()
            ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
            
        }
        return returnObj
    }
    
    // SERVICIO PARA LA REGENERACION DE TOKEN DE SEGURIDAD VALMEX
    func DGSDKRestoreTokenSecurityV2(delegate: Delegate?) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
        
            if !ConfigurationManager.shared.webSecurity{ resolve(APISuccessResponse.success) }
            let typeName: String = #function
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)

            do{
                let mutableRequest: URLRequest
                mutableRequest = try ConfigurationManager.shared.request.tokenRequest()
                
                setTimerLogForRequest(mode: .async, request: mutableRequest, launcher: typeName, debug: ConfigurationManager.shared.debugNetwork)
                    .then { data in
                        
                        do{
                            let doc = try AEXMLDocument(xml: data)
                            let getTokenResult = doc["s:Envelope"]["s:Body"]["response"].string
                            let encodingSoap = try self.decodeReturnSoap(getTokenResult)
                                do {
                                    let jsonDict = try JSONSerializer.toDictionary(encodingSoap )
                                    let object = jsonDict.value(forKey: "ReturnedObject") as? String
                                    let jsonTimeAndToken = try JSONSerializer.toDictionary(object ?? "")
                                    let dataToken = FETokenSeguridad(dictionary: jsonTimeAndToken)
                                    ConfigurationManager.shared.usuarioUIAppDelegate.Token = dataToken
                                    resolve(APISuccessResponse.success)
                                }catch{
                                    ConfigurationManager.shared.utilities.writeLogger("Error al decodificar el generar token", .error)
                                    reject(error)
                                }
                            
                            let jsonToken = doc["s:Envelope"]["s:Body"]["RegeneraTokenResponse"]["RegeneraTokenResult"].string
                            
                                do {
                                    let jsonDict = try JSONSerializer.toDictionary(jsonToken)
                                    var dataToken: FETokenSeguridad = FETokenSeguridad()
                                    dataToken = FETokenSeguridad(dictionary: jsonDict)
                                    ConfigurationManager.shared.usuarioUIAppDelegate.Token = dataToken
                                    resolve(APISuccessResponse.success)
                                }catch{
                                    ConfigurationManager.shared.utilities.writeLogger("Error al decodificar el regenerar Token", .error)
                                    reject(error)
                                }
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("Error al decodificar la respuesta", .error)
                            reject(error)
                        }
                        
                    }.catch { error in
                        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_timeout".langlocalized(), typeName), .info)
                        reject(error)
                    }
                    
            }catch let e{
                ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
            }
        
        }
    }
    
    
    // MARK: - CheckUserOffline
    /// Method to obtain User info from library
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - user: user information
    ///   - pass: pass information
    func validUserOffline(delegate: Delegate?, user: String, pass: String) -> Bool{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "validUserOffline"), .info)
        
        var password = Array(pass.utf8)
        password = password.sha512()
        let passwordString = password.toBase64()
        ConfigurationManager.shared.usuarioUIAppDelegate.Password = passwordString
        
        let pass = Array(pass.utf8)
        let passwordBase = pass.toBase64()
        ConfigurationManager.shared.usuarioUIAppDelegate.PasswordEncoded = passwordBase
        ConfigurationManager.shared.usuarioUIAppDelegate.User = user
        ConfigurationManager.shared.usuarioUIAppDelegate.IP = ConfigurationManager.shared.utilities.getIPAddress()
        ConfigurationManager.shared.usuarioUIAppDelegate.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
        ConfigurationManager.shared.usuarioUIAppDelegate.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
        
        if(ConfigurationManager.shared.codigoUIAppDelegate.Codigo != "" && ConfigurationManager.shared.codigoUIAppDelegate.Codigo != "default" && ConfigurationManager.shared.usuarioUIAppDelegate.User != ""){
            /* Checking a the Local Code settings */
            guard let usuarioOffline = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Usuario.usu") else {
                ConfigurationManager.shared.utilities.writeLogger("apimng_log_nofile".langlocalized(), .error)
                return false
            }
            // Set Codigo as saved in File
            let localUser = FEUsuario(json: usuarioOffline)
            if ConfigurationManager.shared.usuarioUIAppDelegate.Password != localUser.Password || ConfigurationManager.shared.usuarioUIAppDelegate.User != localUser.User{
                return false
            }
            ConfigurationManager.shared.usuarioUIAppDelegate = localUser
            plist.usuario.rawValue.dataSSet(ConfigurationManager.shared.usuarioUIAppDelegate.User)
            return true
        }
        ConfigurationManager.shared.utilities.writeLogger("apimng_log_preference".langlocalized(), .error)
        return false
    }
    
    // MARK: - CheckConsultasOffline
    /// Method to retrieve Consultas Offline from library
    /// - Parameter delegate: delegate viewcontroller
    func validConsultasOffline(delegate: Delegate?) -> Bool{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "validConsultasOffline"), .info)
        if(ConfigurationManager.shared.codigoUIAppDelegate.Codigo != "" && ConfigurationManager.shared.codigoUIAppDelegate.Codigo != "default" && ConfigurationManager.shared.usuarioUIAppDelegate.User != ""){
            
            guard let consultasOffline = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Consultas.cons")else {
                ConfigurationManager.shared.utilities.writeLogger("apimng_log_nofile".langlocalized(), .error)
                return false
            }
            // Set Codigo as saved in File
            
            ConfigurationManager.shared.consultasUIAppDelegate = [FETipoReporte](json: consultasOffline)
            return true
        }
        ConfigurationManager.shared.utilities.writeLogger("apimng_log_preference".langlocalized(), .error)
        return false
        
    }
    
    // MARK: - SalvarUser
    /// Method to save User in library
    /// - Parameter delegate: delegate viewcontroller
    func salvarUsuario(delegate: Delegate?){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "salvarUsuario"), .info)
        let dummyUsuario = ConfigurationManager.shared.usuarioUIAppDelegate
        
        var consultas = JSONSerializer.toJson(dummyUsuario.Consultas)
        consultas = consultas.replacingOccurrences(of: "\\\"", with: "\\\\\"")
        consultas = consultas.replacingOccurrences(of: "\\", with: "\\\\")
        consultas = consultas.replacingOccurrences(of: "\\w", with: "*")
        consultas = consultas.replacingOccurrences(of: "\\*", with: "*")
        _ = ConfigurationManager.shared.utilities.save(info: consultas, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Consultas.cons")
        
        dummyUsuario.Consultas = [FETipoReporte]()
        if !dummyUsuario.UserAddress.contains("\\\"")
        {   dummyUsuario.UserAddress = dummyUsuario.UserAddress.replacingOccurrences(of: "\"", with: "\\\"")    }
        let json = JSONSerializer.toJson(dummyUsuario)
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Usuario.usu")
        
        plist.usuario.rawValue.dataSSet(ConfigurationManager.shared.usuarioUIAppDelegate.User)
        // Function to reasing the value (FILES IN MB) in the Settings Bundle
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
    }
    
    // MARK: - UpdateUser
    /// Method to update User info in the library
    /// - Parameter delegate: delegate viewcontroller
    func updateUsuario(delegate: Delegate?){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "updateUsuario"), .info)
        let usuario = ConfigurationManager.shared.usuarioUIAppDelegate
        if !usuario.UserAddress.contains("\\\"")
        {   usuario.UserAddress = usuario.UserAddress.replacingOccurrences(of: "\"", with: "\\\"")    }
        let json = JSONSerializer.toJson(usuario)
        
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Usuario.usu")
        
        plist.usuario.rawValue.dataSSet(ConfigurationManager.shared.usuarioUIAppDelegate.User)
        // Function to reasing the value (FILES IN MB) in the Settings Bundle
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
    }
    
    /// Update User Image Profile
    /// - Parameter innerDelegate: delegate viewcontroller
    func updateImageProfile(delegate innerDelegate: Delegate?) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            
            let typeName: String = #function
            
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)
            
            do{
                let mutableRequest: URLRequest
                mutableRequest = try ConfigurationManager.shared.request.imageProfileRequest()
                
                setTimerLogForRequest(mode: .async, request: mutableRequest, launcher: typeName, debug: ConfigurationManager.shared.debugNetwork)
                    .then { data in
                        var bodyData: Data
                        do{
                            let doc = try AEXMLDocument(xml: data)
                            // Exclusive IDportal Number for Security
                            if plist.idportal.rawValue.dataI() <= 39{
                                let encodingSoap = try self.decodeReturnSoap(doc["s:Envelope"]["s:Body"]["response"].string)
                                let jsonDict = try JSONSerializer.toDictionary(encodingSoap )
                                if let returnobj = jsonDict["ReturnedObject"] as? String {
                                    
                                }
                            }else{
                                let response = doc["s:Envelope"]["s:Body"]["SendUsrThumbnailResponse"]["SendUsrThumbnailResult"].string
                                if(Bool(response) ?? false){
                                    self.salvarUsuario(delegate: innerDelegate)
                                    resolve(APISuccessResponse.success)
                                }else{
                                    ConfigurationManager.shared.utilities.writeLogger("Error ", .error)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, "Error"))
                                }
                            }
                        }catch let e{
                            ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
                        }
                    }.catch { error in
                        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_timeout".langlocalized(), typeName), .info)
                        reject(error)
                    }
            }catch let e{
                ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
            }
            
        }
        
    }
    
    /// Update User Profile
    /// - Parameter innerDelegate: delegate viewcontroller
    /// - Returns: APISuccessResponse
    func updateUserProfile(delegate innerDelegate: Delegate?) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            
            let typeName: String = #function
            let startDate = Date()
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)
            
            do{
                let mutableRequest: URLRequest
                mutableRequest = try ConfigurationManager.shared.request.userProfileRequest()
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                setTimerLogForRequest(mode: .async, request: mutableRequest, launcher: typeName, debug: ConfigurationManager.shared.debugNetwork)
                    .then { data in
                        
                        do{
                            let doc = try AEXMLDocument(xml: data)
                            // Exclusive IDportal Number for Security
                            let getCodeResult = doc["s:Envelope"]["s:Body"]["SendUserInformationResponse"]["SendUserInformationResult"].string
                            let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                            let decompressedData: Data
                            if bodyData.isGzipped {
                                decompressedData = try! bodyData.gunzipped()
                            } else {
                                decompressedData = bodyData
                            }
                            let decodedString = String(data: decompressedData, encoding: .utf8)!
                            let response = AjaxResponse(json: decodedString)
                            
                            if(response.Success){
                                if response.Mensaje == ""{
                                    self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                    ConfigurationManager.shared.utilities.writeLogger("\(typeName): 200", .success)
                                    self.salvarUsuario(delegate: innerDelegate)
                                    resolve(APISuccessResponse.success)
                                }else{
                                    let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                    self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                                    ConfigurationManager.shared.utilities.writeLogger(response.Mensaje, .info)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, response.Mensaje))
                                }
                            }else{
                                let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                                ConfigurationManager.shared.utilities.writeLogger(response.Mensaje, .info)
                                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, response.Mensaje))
                            }
                        }catch let e{
                            ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
                        }
                    }.catch { error in
                        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_timeout".langlocalized(), typeName), .info)
                        reject(error)
                    }
                
            }catch let e{
                ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
            }
            
        }
        
    }
}

// MARK: - Nueva version Servicios
//  - Registro
public extension APIManager{
    
    // MARK: - Register Online
    /// Method to send request to register new user
    /// - Parameter delegate: delegate viewcontroller
    func DGSDKregistro(delegate: Delegate?, nombre: String, aPaterno: String, aMaterno: String, password: String, email: String) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "validRegistroOnlinePromise"), .info)
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
            }
            
            ConfigurationManager.shared.registroUIAppDelegate.Nombre = nombre
            ConfigurationManager.shared.registroUIAppDelegate.ApellidoP = aPaterno
            ConfigurationManager.shared.registroUIAppDelegate.ApellidoM = aMaterno
            var password = Array(password.utf8)
            password = password.sha512()
            let passwordString = password.toBase64()
            ConfigurationManager.shared.registroUIAppDelegate.Password = passwordString
            ConfigurationManager.shared.registroUIAppDelegate.Email = email
            ConfigurationManager.shared.registroUIAppDelegate.User = email
            ConfigurationManager.shared.registroUIAppDelegate.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            ConfigurationManager.shared.registroUIAppDelegate.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            ConfigurationManager.shared.registroUIAppDelegate.IP = ConfigurationManager.shared.utilities.getIPAddress()
            ConfigurationManager.shared.registroUIAppDelegate.GrupoId = ConfigurationManager.shared.codigoUIAppDelegate.GrupoRegistro
            ConfigurationManager.shared.registroUIAppDelegate.Perfiles = ConfigurationManager.shared.codigoUIAppDelegate.Perfiles
            
            DispatchQueue.global(qos: .background).async {
                
                let mutableRequest: URLRequest
                do{
                    mutableRequest = try ConfigurationManager.shared.request.registroRequest()
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else {
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata")); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            let getCodeResult = doc["s:Envelope"]["s:Body"]["RegistroResponse"]["RegistroResult"].string
                            let bodyData = self.getReturnObject(aexmlD: doc, r: getCodeResult)
                            let response = AjaxResponse(json: bodyData)
                            if(response.Success){
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                ConfigurationManager.shared.registroUIAppDelegate = FERegistro(dictionary: response.ReturnedObject!)
                                self.salvarRegistro(delegate: delegate)
                                resolve(APISuccessResponse.success)
                            }else{
                                if response.Mensaje.contains("Ya existe otro usuario con es nombre"){
                                    let m = "not_user_userexist".langlocalized()
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.data, false, nil, "\(m)"))
                                }else{
                                    let m = "not_user_invalidregister".langlocalized()
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.data, false, nil, "\(m)"))
                                }
                            }
                        }catch{
                            let e = "alrt_error_try".langlocalized()
                            ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.xml, false, nil, "\(e)"))
                        }
                    }); task.resume()
                }catch{
                    let e = "alrt_error_try".langlocalized()
                    ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, "\(e)"))
                }
                
            }
            
        }
        
    }
    
    // MARK: - Send SMS
    /// Method to send SMS request for register validation
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - sms: sms delegate
    func soapSMSPromise(delegate: Delegate?, sms: SmsServicio) -> Promise<AjaxResponse>{
        
        return Promise<AjaxResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapSMSPromise"), .info)
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapSMSRequest(sms: sms)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError); return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["RegistroPinSmsResponse"]["RegistroPinSmsResult"].string
                        let bodyData = self.getReturnObject(aexmlD: doc, r: getCodeResult)
                        let response = AjaxResponse(json: bodyData)
                        if(response.Success){
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            //let _ = SmsServicio(dictionary: response.ReturnedObject!)
                            resolve(response)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.SMSOnlineError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.SMSOnlineError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.SMSOnlineError)
            }
            
        }
        
    }
    
    // MARK: - Validate SMS
    /// Method to validate SMS in the meanwhile for registration
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - sms: sms delegate
    func soapValidateSMSPromise(delegate: Delegate?, sms: SmsServicio) -> Promise<AjaxResponse>{
        
        return Promise<AjaxResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapValidateSMSPromise"), .info)
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapValidateSMSRequest(sms: sms)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError); return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["ValidateSmsCodeResponse"]["ValidateSmsCodeResult"].string
                        let bodyData = self.getReturnObject(aexmlD: doc, r: getCodeResult)
                        let response = AjaxResponse(json: bodyData)
                        if(response.Success){
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            resolve(response)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.SMSOnlineError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.SMSOnlineError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.SMSOnlineError)
            }
            
        }
        
    }
    
    // MARK: - Active Register
    /// Method to activate the registration
    /// - Parameter delegate: delegate viewcontroller
    func activeRegistroPromise(delegate: Delegate?) -> Promise<AjaxResponse>{
        
        return Promise<AjaxResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "activeRegistroPromise"), .info)
            DispatchQueue.global(qos: .background).async {
                
                let mutableRequest: URLRequest
                do{
                    mutableRequest = try ConfigurationManager.shared.request.activarRegistroRequest()
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else {
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            let getCodeResult = doc["s:Envelope"]["s:Body"]["ActivarRegistroResponse"]["ActivarRegistroResult"].string
                            let bodyData = self.getReturnObject(aexmlD: doc, r: getCodeResult)
                            let response = AjaxResponse(json: bodyData)
                            if(response.Success){
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                resolve(response)
                            }else{
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                reject(APIErrorResponse.RegistroOnlineError)
                            }
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(APIErrorResponse.RegistroOnlineError)
                        }
                    }); task.resume()
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(APIErrorResponse.RegistroOnlineError)
                }
                
            }
            
        }
        
    }
    
    // MARK: - Change User Password
    /// Method to change the user password
    /// - Parameter delegate: delegate viewcontroller
    func DGSDKcambiarContrasenia(delegate: Delegate?, currentPass: String, newPass: String) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "cambiarUserContraseniaPromise"), .info)
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
            }
            var passwordOld = Array(currentPass.utf8)
            passwordOld = passwordOld.sha512()
            let passwordStringOld = passwordOld.toBase64()
            let passOld = Array(currentPass.utf8)
            let passwordBaseOld = passOld.toBase64()
            
            var password = Array(newPass.utf8)
            password = password.sha512()
            let passwordString = password.toBase64()
            let pass = Array(newPass.utf8)
            let passwordBase = pass.toBase64()
            
            ConfigurationManager.shared.usuarioUIAppDelegate.Password = passwordStringOld
            ConfigurationManager.shared.usuarioUIAppDelegate.PasswordEncoded = passwordBaseOld
            
            ConfigurationManager.shared.usuarioUIAppDelegate.PasswordNuevo = passwordString
            ConfigurationManager.shared.usuarioUIAppDelegate.NewPasswordEncoded = passwordBase
            
            ConfigurationManager.shared.usuarioUIAppDelegate.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            ConfigurationManager.shared.usuarioUIAppDelegate.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
            
            DispatchQueue.global(qos: .background).async {
                
                let mutableRequest: URLRequest
                do{
                    mutableRequest = try ConfigurationManager.shared.request.cambiarContraseniaRequest()
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else {
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata")); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            let getCodeResult = doc["s:Envelope"]["s:Body"]["CambiarPasswordResponse"]["CambiarPasswordResult"].string
                            let response = AjaxResponse(json: getCodeResult)
                            if(response.Success){
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Usuario.usu"){
                                    FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Usuario.usu")
                                }
                                resolve(APISuccessResponse.success)
                            }else{
                                let e = response.Mensaje
                                ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.xml, false, nil, "\(e)"))
                            }
                        }catch{
                            let e = "alrt_error_try".langlocalized()
                            ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.xml, false, nil, "\(e)"))
                        }
                        
                    }); task.resume()
                }catch{
                    let e = "alrt_error_try".langlocalized()
                    ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, "\(e)"))
                }
                
            }
            
        }
        
    }
    
    // MARK: - Reset User Password
    /// Method to reset the user password
    /// - Parameter delegate: delegate viewcontroller
    /// - Parameter user: current user to change passsword
    func DGSDKresetContrasenia(delegate: Delegate?, passwordReset: String, user: String) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "resetUserContraseniaPromise"), .info)
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
            }
            let startDate = Date()
            var password = Array(passwordReset.utf8)
            password = password.sha512()
            let passwordString = password.toBase64()
            let pass = Array(passwordReset.utf8)
            let passwordBase = pass.toBase64()
            
            
            let usr = FEUsuario()
            usr.Password = passwordString
            usr.PasswordEncoded = passwordBase
            usr.PasswordNuevo = passwordString
            usr.NewPasswordEncoded = passwordBase
            usr.CurrentPasswordEncoded = passwordBase
            usr.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            usr.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            usr.User = user
            
            DispatchQueue.global(qos: .background).async {
                
                let mutableRequest: URLRequest
                do{
                    mutableRequest = try ConfigurationManager.shared.request.resetContraseniaRequest(usr)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else {
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning);
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata")); return;
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            let getCodeResult = doc["s:Envelope"]["s:Body"]["ResetearPasswordResponse"]["ResetearPasswordResult"].string
                            
                            let bodyData = Data(base64Encoded: getCodeResult)!
                            let decompressedData: Data
                            if bodyData.isGzipped {
                                decompressedData = try! bodyData.gunzipped()
                            } else {
                                decompressedData = bodyData
                            }
                            let decodedString = String(data: decompressedData, encoding: .utf8)!
                            let response = AjaxResponse(json: decodedString)
                            if(response.Success){
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                self.salvarUsuario(delegate: delegate)
                                resolve(APISuccessResponse.success)
                            }else{
                                let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                                let m = "not_reset_passwordinvalid".langlocalized()
                                ConfigurationManager.shared.utilities.writeLogger("\(m)", .error)
                                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.data, false, nil, "\(m)"))
                            }
                        }catch{
                            let e = "alrt_error_try".langlocalized()
                            ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.xml, false, nil, "\(e)"))
                        }
                    }); task.resume()
                }catch{
                    let e = "alrt_error_try".langlocalized()
                    ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, "\(e)"))
                }
                
            }
            
        }
        
    }
    
    // MARK: - Validation Offline
    /// Method to obtain Old Registration
    /// - Parameter delegate: delegate viewcontroller
    func validRegistroOffline(delegate: Delegate?) -> Bool{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "validRegistroOffline"), .info)
        
        if(ConfigurationManager.shared.codigoUIAppDelegate.Codigo != "" && ConfigurationManager.shared.codigoUIAppDelegate.Codigo != "default" && ConfigurationManager.shared.usuarioUIAppDelegate.User != ""){
            /* Checking a the Local Code settings */
            guard let usuarioOffline = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Registro.reg") else {
                ConfigurationManager.shared.utilities.writeLogger("apimng_log_nofile".langlocalized(), .error)
                return false
            }
            // Set Codigo as saved in File
            let localUser = FERegistro(json: usuarioOffline)
            if ConfigurationManager.shared.usuarioUIAppDelegate.Password != localUser.Password || ConfigurationManager.shared.usuarioUIAppDelegate.User != localUser.User{
                return false
            }
            ConfigurationManager.shared.registroUIAppDelegate =  FERegistro(json: usuarioOffline)
            plist.usuario.rawValue.dataSSet(ConfigurationManager.shared.usuarioUIAppDelegate.User)
            return true
        }
        ConfigurationManager.shared.utilities.writeLogger("apimng_log_preference".langlocalized(), .error)
        return false
    }
    
    // MARK: - Save Registration
    /// Method to save current registration
    /// - Parameter delegate: delegate viewcontroller
    func salvarRegistro(delegate: Delegate?){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "salvarRegistro"), .info)
        let json = JSONSerializer.toJson(ConfigurationManager.shared.registroUIAppDelegate)
        
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/Registro.reg")
        
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
        
        self.salvarKeychain(account: ConfigurationManager.shared.registroUIAppDelegate.Email, password: ConfigurationManager.shared.registroUIAppDelegate.Password)
    }
    
    // MARK: - Save Keychain
    /// MEthod to save user info in the keychain
    /// - Parameters:
    ///   - account: account user
    ///   - password: password user
    func salvarKeychain(account: String, password: String){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "salvarKeychain"), .info)
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do{
            try passwordItem.savePassword(password)
        }catch let error{
            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
        }
    }
    
    // MARK: - Delete Keychain
    /// Method to delete keychain
    /// - Parameter account: account user
    func borrarKeychain(account: String) -> Bool{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "borrarKeychain"), .info)
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do{
            try passwordItem.deleteItem(); return true
        }catch let error{
            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error); return false
        }
    }
    
    // MARK: - Obtain Keychain
    /// Method to obtain keychain
    /// - Parameter account: account user
    func obtenerKeychain(account: String) -> String{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "obtenerKeychain"), .info)
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        var pass: String?
        do{
            pass = try passwordItem.readPassword()
        }catch let error{
            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
        }
        return pass ?? ""
    }
    
    // MARK: - Valid Keychain
    /// Method to valid keychain
    /// - Parameters:
    ///   - account: account user
    ///   - password: password user
    func validarKeychain(account: String, password: String) -> Bool{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "validarKeychain"), .info)
        let keychainpass = obtenerKeychain(account: account)
        if keychainpass == password{ return true
        }else{ return false }
    }
    
}

public extension APIManager{
    // MARK: - Download All Data
    /// Method to download templates, variables and formats
    /// - Parameter delegate: delegate viewcontroller
    func DGSDKdownloadData(delegate: Delegate?, forcedUpdate: Bool = false) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            
            let typeName: String = #function
            
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
            }
            
            self.DGSDKdownloadTemplates(delegate: delegate)
                .then{ response in
                    
                    self.DGSDKdownloadVariables(delegate: delegate)
                        .then { response in
                            
                            self.DGSDKdownloadFormats(delegate: delegate, initial: forcedUpdate)
                                .then { response in
                                    resolve(APISuccessResponse.success)
                                }.catch { error in
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.data, false, nil, "apimng_log_nodata"));
                                }
                            
                        }.catch { error in
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.data, false, nil, "apimng_log_nodata"));
                        }
                    
                }.catch{ error in
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.data, false, nil, "apimng_log_nodata"));
                }
            
        }
        
    }
    
    // MARK: - Download Templates
    /// Method to download templates from server
    /// - Parameter delegate: delegate viewcontroller
    func DGSDKdownloadTemplates(delegate: Delegate?) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            
            let typeName: String = #function
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
            }
            
            ConfigurationManager.shared.plantillaUIAppDelegate.ListPlantillasPermiso = self.validPlantillasOffline()
            ConfigurationManager.shared.plantillaUIAppDelegate.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
            ConfigurationManager.shared.plantillaUIAppDelegate.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            ConfigurationManager.shared.plantillaUIAppDelegate.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            
            self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                .then { result in
                    
                    let mutableRequest: URLRequest
                    mutableRequest = try ConfigurationManager.shared.request.plantillasRequest()

                    self.setTimerLogForRequest(mode: .async, request: mutableRequest, launcher: typeName, debug: ConfigurationManager.shared.debugNetwork)
                        .then { data in
                            
                            do{
                                let doc = try AEXMLDocument(xml: data)
                                // Exclusive IDportal Number for Security
                                let getCodeResult = doc["s:Envelope"]["s:Body"]["ObtienePlantillasResponse"]["ObtienePlantillasResult"].string
                                let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                                let decompressedData: Data
                                if bodyData.isGzipped {
                                    decompressedData = try! bodyData.gunzipped()
                                } else {
                                    decompressedData = bodyData
                                }
                                let decodedString = String(data: decompressedData, encoding: .utf8)!
                                let response = AjaxResponse(json: decodedString)
                                
                                if(response.Success){
                                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                    if self.salvarPlantillaData(dictionary: response.ReturnedObject, consultaPlantilla: nil){
                                        self.salvarPlantilla(delegate: delegate)
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        response.Mensaje = "apimng_log_templateupdate".langlocalized()
                                        ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                        resolve(APISuccessResponse.success)
                                    }
                                }else{
                                    let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                    ConfigurationManager.shared.utilities.writeLogger(response.Mensaje, .info)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, response.Mensaje))
                                }
                                
                            }catch let e{
                                ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
                            }
                        }.catch { error in
                            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_timeout".langlocalized(), typeName), .info)
                            reject(error)
                        }
                }.catch { error in
                    ConfigurationManager.shared.utilities.writeLogger("\(error.localizedDescription)\r", .error)
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, error.localizedDescription))
                }
            
        }
        
    }
    
    public func salvarPlantillaData(dictionary dict: NSDictionary?, consultaPlantilla cons: FEConsultaPlantilla?) -> Bool{
        
        var SANDBOX: FEConsultaPlantilla?
        
        if dict != nil{
            SANDBOX = FEConsultaPlantilla(dictionary: dict!)
        }else if cons != nil{
            SANDBOX = cons
        }
        
        guard let SANDBOX_Plantilla = SANDBOX else{ return false}
        
        let listPlantillasData = SANDBOX_Plantilla.ListPlantillas as [FEPlantillaData]
        let listServicios = SANDBOX_Plantilla.ListServicios as [FEListaServicios]
        let listComponentes = SANDBOX_Plantilla.ListComponentes as [FEListaComponentes]
        
        // Removing Services folder if there is a service out of order
        FCFileManager.removeItemsInDirectory(atPath: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/\(Cnstnt.Tree.servicios)/")
        for list in listServicios{
            _ = ConfigurationManager.shared.utilities.save(info: list.Descripcion, path: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/\(Cnstnt.Tree.servicios)/\(list.CatalogoId).ser")
            list.Descripcion = ""
        }
        
        // Removing Components folder if there is a component out of order
        FCFileManager.removeItemsInDirectory(atPath: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/\(Cnstnt.Tree.componentes)/")
        for comp in listComponentes{
            _ = ConfigurationManager.shared.utilities.save(info: comp.Descripcion, path: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/\(Cnstnt.Tree.componentes)/\(comp.CatalogoId).comp")
            comp.Descripcion = ""
        }
        
        var fullPlantillasMin = [FEPlantillaMerge]()
        
        if listPlantillasData.count > 0{
            // Removing Catalogs folder if there is a catalog out of order
            FCFileManager.removeItemsInDirectory(atPath: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/\(Cnstnt.Tree.catalogos)/")
            let listCatalogos = SANDBOX_Plantilla.ListCatalogos as [FEItemCatalogoEsquema]
            if listCatalogos.count > 0{
                // Deleting old data
                for esquema in listCatalogos{
                    let cod = esquema.TipoCatalogoID
                    for catalogo in esquema.Catalogo{
                        catalogo.Json = catalogo.Json.replacingOccurrences(of: "\"", with: "|")
                    }
                    esquema.Esquema = esquema.Esquema.replacingOccurrences(of: "\"", with: "|")
                    let json = JSONSerializer.toJson(esquema)
                    let jsonModify = json.replacingOccurrences(of: "|", with: "\\\"")
                    _ = ConfigurationManager.shared.utilities.save(info: jsonModify, path: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/\(Cnstnt.Tree.catalogos)/\(cod).cat")
                }
            }
            if listPlantillasData.count > 0{
                // Deleting old data
                for plantillasData in listPlantillasData{
                    // Verifying if there is no corrupted data in ListMetadatos
                    // Hack just for a period of time
                    for metadatos in plantillasData.ListMetadatosHijos{
                        metadatos.Expresion_Regular = ".*"
                    }
                    for docs in plantillasData.ListTipoDoc{
                        docs.Descripcion = docs.Descripcion.replacingOccurrences(of: "\t", with: "")
                    }
                    
                    var json = JSONSerializer.toJson(plantillasData)
                    _ = ConfigurationManager.shared.utilities.save(info: plantillasData.XmlPlantilla, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).xml")
                    // Getting Rules
                    do {
                        let xmlDoc = try AEXMLDocument(xml: plantillasData.XmlPlantilla)
                        
                        // Detect if we have any rules
                        if xmlDoc.root.children[0]["reglas"].children.count > 0{
                            // Saving Rules in file
                            _ = ConfigurationManager.shared.utilities.save(info: xmlDoc.root.children[0]["reglas"].xmlCompact, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).rls")
                        }else{ FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).rls") }
                        
                        // Detect if we have any services
                        if xmlDoc.root.children[0]["servicios"].children.count > 0{
                            // Saving Rules in file
                            _ = ConfigurationManager.shared.utilities.save(info: xmlDoc.root.children[0]["servicios"].xmlCompact, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).srv")
                        }else{ FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).srv") }
                        
                        // Detect if we have any components
                        if xmlDoc.root.children[0]["components"].children.count > 0{
                            // Saving Rules in file
                            _ = ConfigurationManager.shared.utilities.save(info: xmlDoc.root.children[0]["components"].xmlCompact, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).cmp")
                        }else{ FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).cmp") }
                        
                        // Detect if we have any mathematics
                        if xmlDoc.root.children[0]["operacionesmatematicas"].children.count > 0{
                            // Saving Rules in file
                            _ = ConfigurationManager.shared.utilities.save(info: xmlDoc.root.children[0]["operacionesmatematicas"].xmlCompact, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).mat")
                        }else{ FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).mat") }
                        
                        // Detect if we have any Prefilled Data
                        if xmlDoc.root.children[0]["prefilleddata"].children.count > 0{
                            // Saving Rules in file
                            _ = ConfigurationManager.shared.utilities.save(info: xmlDoc.root.children[0]["prefilleddata"].xmlCompact, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).prf")
                        }else{ FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).prf") }
                        
                        // Detect if we have any PDFMapping
                        if xmlDoc.root.children[0]["pdfmapping"].children.count > 0{
                            // Saving Rules in file
                            _ = ConfigurationManager.shared.utilities.save(info: xmlDoc.root.children[0]["pdfmapping"].xmlCompact, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).map")
                        }else{ FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).map") }
                        
                    } catch {  }
                    
                    plantillasData.XmlPlantilla = ""
                    json = JSONSerializer.toJson(plantillasData)
                    _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(plantillasData.FlujoID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID)/\(plantillasData.ExpID)_\(plantillasData.TipoDocID).pla")
                }
                
                // Settings Plantillas Data Merge
                let mainFolders = FCFileManager.listDirectoriesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/")
                
                for mainFolder in mainFolders!{
                    let flujoFolderPath = mainFolder as! String
                    let flujoFolder = flujoFolderPath.split{$0 == "/"}.map(String.init)
                    
                    let subFolders = FCFileManager.listDirectoriesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(flujoFolder.last!)/")
                    
                    let subFolder = subFolders?[0] as? String ?? ""
                    let flujoSubfolderPath = subFolder
                    let flujoSubfolder = flujoSubfolderPath.split{$0 == "/"}.map(String.init)
                    
                    let flujoInfo = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(flujoFolder.last!)/\(flujoSubfolder.last!)/\(flujoSubfolder.last!).pla")
                    let plantillaData = FEPlantillaData(json: flujoInfo)
                    
                    // Getting and retriving all data from plantillas
                    let minData = FEPlantillaMerge()
                    minData.ExpID = plantillaData.ExpID
                    minData.FechaActualizacion = plantillaData.FechaActualizacion
                    minData.FlujoID = plantillaData.FlujoID
                    minData.NombreFlujo = plantillaData.NombreFlujo
                    minData.TipoDocID = plantillaData.TipoDocID
                    minData.MostrarExp = plantillaData.MostrarExp
                    minData.MostrarTipoDoc = plantillaData.MostrarTipoDoc
                    minData.VerNuevaCapturaMovil = plantillaData.VerNuevaCapturaMovil
                    
                    for file in subFolders!{
                        let flujoSubfolderPath = file as! String
                        let flujoSubfolder = flujoSubfolderPath.split{$0 == "/"}.map(String.init)
                        let eD = flujoSubfolder.last!.components(separatedBy: "_")
                        let expDoc = FEExpDoc()
                        expDoc.expediente = eD.first!
                        expDoc.documento = eD.last!
                        minData.ExpDoc.append(expDoc)
                    }
                    
                    minData.Procesos.append("0")
                    let proceso = FEProcesos()
                    proceso.FlujoID = minData.FlujoID
                    proceso.NombreProceso = "datavw_local_flow".langlocalized()
                    proceso.PIID = 0
                    minData.PProcesos.append(proceso)
                    
                    for evento in plantillaData.EventosTareas{
                        
                        if !minData.Procesos.contains(String(evento.PIID)){
                            minData.Procesos.append("\(evento.PIID)")
                            let proceso = FEProcesos()
                            proceso.FlujoID = evento.FlujoID
                            proceso.NombreProceso = evento.NombreProceso
                            proceso.PIID = evento.PIID
                            minData.PProcesos.append(proceso)
                        }
                        
                    }
                    fullPlantillasMin.append(minData)
                    
                }
                let json = JSONSerializer.toJson(fullPlantillasMin)
                _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas.pla")
                
                SANDBOX_Plantilla.ListCatalogos = Array<FEItemCatalogoEsquema>()
                SANDBOX_Plantilla.ListPlantillas = Array<FEPlantillaData>()
                SANDBOX_Plantilla.ListPlantillasPermiso = Array<FEPlantillaData>()
                
                ConfigurationManager.shared.plantillaUIAppDelegate = SANDBOX_Plantilla
                ConfigurationManager.shared.plantillaUIAppDelegate.FechaSincronizacionPlantilla = SANDBOX_Plantilla.FechaSincronizacionPlantilla
            }
            self.salvarPlantilla(delegate: delegate)
            return true
        }else{
            let mensaje = "apimng_log_templateupdate".langlocalized()
            ConfigurationManager.shared.utilities.writeLogger("\(mensaje)", .info)
            return false
        }
        
    }
    
    // MARK: - Get Templates by Flow
    /// Method to obtain all templates by a flow selected
    /// - Parameter flujo: flow selected
    func DGSDKgetTemplates(_ flujo: String) -> Array<(String, Array<FEPlantillaData>)>{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getPlantillasBySections"), .info)
        let folders = FCFileManager.listDirectoriesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(flujo)/")
        var plantillas = Array<(String, Array<FEPlantillaData>)>()
        var nombreFlujo = ""
        var pln = Array<FEPlantillaData>()
        if folders?.count == 0 { return plantillas }
        for subFolders in folders!{
            let subFolder = FCFileManager.listFilesInDirectory(atPath: subFolders as? String, deep: true)
            for file in subFolder!{
                let archive = file as! NSString
                let pathExtention = archive.pathExtension
                if(pathExtention == "pla"){
                    let gettingXml = ConfigurationManager.shared.utilities.read(asString: file as? String ?? "")
                    let plantilla = FEPlantillaData(json: gettingXml)
                    let defaults = UserDefaults.standard
                    let serial = defaults.string(forKey: Cnstnt.BundlePrf.serial)
                    if serial != "QWEASDZXC"{
                        if plantilla.VerNuevaCapturaMovil == false { continue }
                    }
                    nombreFlujo = plantilla.NombreFlujo
                    pln.append(plantilla)
                }
            }
        }
        pln = pln.sorted(by: { (pl, pls) -> Bool in return pl.NombreExpediente < pls.NombreExpediente })
        plantillas.append((nombreFlujo, pln))
        return plantillas
    }
    
    // MARK: - Templates Offline
    /// Method to obtain all templates from library
    func validPlantillasOffline() -> Array<FEPlantillaData>{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "validPlantillasOffline"), .info)
        ConfigurationManager.shared.utilities.writeLogger("Obteniendo plantillas", .info)

        let folders = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/", deep: true)
        var arrayFilesPlantillas = Array<String>()
        var arrayPlantillaData = Array<FEPlantillaData>()
        ConfigurationManager.shared.utilities.writeLogger("Se encontraron \(folders?.count ?? 0) plantillas", .info)
        if folders?.count == 0 {
            return arrayPlantillaData
        }
        for files in folders!{
            let file = files as! NSString
            let pathExtention = file.pathExtension
            if(pathExtention == "pla"){
                arrayFilesPlantillas.append(files as! String)
                let gettingXml = ConfigurationManager.shared.utilities.read(asString: files as? String ?? "")
                let plantilla = FEPlantillaData(json: gettingXml)
                arrayPlantillaData.append(plantilla)
            }
        }
        return arrayPlantillaData
    }
    
    // MARK: - Save Template
    /// Method for saving template data in library
    /// - Parameter delegate: delegate viewcontroller
    func salvarPlantilla(delegate: Delegate?){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "salvarPlantilla"), .info)
        let json = JSONSerializer.toJson(ConfigurationManager.shared.plantillaUIAppDelegate)
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantilla.pla")
        
        // Function to reasing the value (FILES IN MB) in the Settings Bundle
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
    }
    
}

public extension APIManager{
    
    // MARK: - Variables Online
    /// Method for downloading variables from server
    /// - Parameter delegate: delegate viewcontroller
    func DGSDKdownloadVariables(delegate: Delegate?) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            
            let typeName: String = #function
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
            }
            
            ConfigurationManager.shared.variablesUIAppDelegate.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
            ConfigurationManager.shared.variablesUIAppDelegate.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
            ConfigurationManager.shared.variablesUIAppDelegate.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            ConfigurationManager.shared.variablesUIAppDelegate.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            ConfigurationManager.shared.variablesUIAppDelegate.IP = ConfigurationManager.shared.utilities.getIPAddress()
            
            self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                .then { result in
                    let mutableRequest: URLRequest
                    mutableRequest = try ConfigurationManager.shared.request.variablesRequest()
                    self.setTimerLogForRequest(mode: .async, request: mutableRequest, launcher: typeName, debug: ConfigurationManager.shared.debugNetwork)
                        .then { data in
                            do{
                                let doc = try AEXMLDocument(xml: data)
                                // Exclusive IDportal Number for Security
                                let getCodeResult = doc["s:Envelope"]["s:Body"]["ObtieneVariablesResponse"]["ObtieneVariablesResult"].string
                                let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                                let decompressedData: Data
                                if bodyData.isGzipped {
                                    decompressedData = try! bodyData.gunzipped()
                                } else {
                                    decompressedData = bodyData
                                }
                                let decodedString = String(data: decompressedData, encoding: .utf8)!
                                let response = AjaxResponse(json: decodedString)
                                
                                if(response.Success){
                                    if response.ReturnedObject != nil{
                                        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Variables.var")
                                        ConfigurationManager.shared.variablesDataUIAppDelegate = FEVariablesData(dictionary: response.ReturnedObject!)
                                        self.salvarVariable(delegate: delegate, data: decodedString)
                                    }
                                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                    resolve(APISuccessResponse.success)
                                }else{
                                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.data, false, nil, "\(response.Mensaje)"))
                                }
                                
                            }catch let e{
                                ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
                            }
                        }.catch { error in
                            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_timeout".langlocalized(), typeName), .info)
                            reject(error)
                        }
                }.catch { error in
                    ConfigurationManager.shared.utilities.writeLogger("\(error.localizedDescription)\r", .error)
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, error.localizedDescription))
                }
        }
        
    }
    
    // MARK: Download categories
    /// Method to download all categories
    /// - Parameter delegate: delegate viewcontroller
    func DGSDKdownloadCatRemoto(delegate: Delegate?) -> FECatRemotoData?
    {
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "DGSDKdownloadCatRemoto"), .info)
        let startDate = Date()
        let semaphore = DispatchSemaphore(value: 0)
        let mutableRequest: URLRequest
        var cat: FECatRemotoData?
        
        ConfigurationManager.shared.catRemotoUIAppDelegate.ProyectoId =
            ConfigurationManager.shared.usuarioUIAppDelegate.ProyectoID
        ConfigurationManager.shared.catRemotoUIAppDelegate.GrupoAdminID = ConfigurationManager.shared.usuarioUIAppDelegate.GrupoAdminID
        do{
            mutableRequest = try ConfigurationManager.shared.request.consultaRemoto(formato: ConfigurationManager.shared.catRemotoUIAppDelegate)
            let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
            let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                guard data != nil && error == nil else {
                    ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                    semaphore.signal()
                    return;
                }
                do{
                    let doc = try AEXMLDocument(xml: data!)
                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.webSecurity{
                        let encodigSoapTest = try
                            self.decodeReturnSoap(doc["s:Envelope"]["s:Body"]["response"].string)
                        let jsonDict = try JSONSerializer.toDictionary(encodigSoapTest)
                        if let returnobj = jsonDict["ReturnedObject"] as? String  {
                            let bodyData = Data(base64Encoded: returnobj)!
                            let decompressedData: Data
                            if bodyData.isGzipped {
                                decompressedData = try! bodyData.gunzipped()
                            } else {
                                decompressedData = bodyData
                            }
                            let decodedString = String(data: decompressedData, encoding: .utf8)!
                            let response = AjaxResponseSimple(json: decodedString)
                            if(response.Success){
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                if response.ReturnedObject != nil && response.ReturnedObject != "" && response.ReturnedObject != "null"
                                {
                                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                    cat = FECatRemotoData(json: response.ReturnedObject)
                                }
                                semaphore.signal()
                            }else{
                                let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                semaphore.signal()
                            }
                        }
                    }else{
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["CargaCatalogoRemotoResponse"]["CargaCatalogoRemotoResult"].string
                        let bodyData = Data(base64Encoded: getCodeResult)!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponseSimple(json: decodedString)
                        if(response.Success){
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                            if response.ReturnedObject != nil && response.ReturnedObject != "" && response.ReturnedObject != "null"
                            {
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                cat = FECatRemotoData(json: response.ReturnedObject)
                            }
                            semaphore.signal()
                        }else{
                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            semaphore.signal()
                        }
                    }
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    semaphore.signal()
                }
            });
            task.resume()
            semaphore.wait()
        }catch let error{
            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
            semaphore.signal()
        }
        return cat
    }
    
    // MARK: - Variables Offline
    /// Method to download variables from server
    func validVariablesOffline() -> Bool{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "validVariablesOffline"), .info)
        let gettingXml = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Variables.var")
        let response = AjaxResponse(json: gettingXml)
        ConfigurationManager.shared.variablesDataUIAppDelegate = FEVariablesData(dictionary: response.ReturnedObject!)
        if ConfigurationManager.shared.variablesDataUIAppDelegate.ListVariables.count > 0{ return true
        }else{ return false }
    }
    
    // MARK: - Save Variable
    /// MEthod to save variables in library
    /// - Parameter delegate: delegate viewcontroller
    func salvarVariable(delegate: Delegate?, data: String){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "salvarVariable"), .info)
        _ = ConfigurationManager.shared.utilities.save(info: data, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Variables.var")
        
        // Function to reasing the value (FILES IN MB) in the Settings Bundle
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
    }
    
}

public extension APIManager{
    // MARK: - NOTIFICACION
    // TODO: - Unify when every bor is actually been readed
    func getNotification(delegate: Delegate?) -> Promise<Int>{
        return Promise<Int> { resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getNotification"), .info)
            var arrayEstadoApp: [Int] = []
            DispatchQueue.global(qos: .background).async {
                let files = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)", deep: true)
                for file in files!{
                    let archive = file as! NSString
                    let pathExtention = archive.pathExtension
                    if(pathExtention == "bor"){
                        let gettingXml = ConfigurationManager.shared.utilities.read(asString: file as? String ?? "")
                        let formato = FEFormatoData(json: gettingXml)
                        let estadoApp = formato.EstadoApp
                        if estadoApp == 2{ arrayEstadoApp.append(estadoApp) }
                    }
                }
                if arrayEstadoApp.count > 0{
                    let msg = String(format: NSLocalizedString("ntfsvw_lbl_formats", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), String(arrayEstadoApp.count))
                    ConfigurationManager.shared.utilities.writeNotifications(msg)
                }
                resolve(arrayEstadoApp.count)
            }
        }
    }
}

public extension APIManager{
    
    // MARK: - RESUME
    /// Method to retrive information from format
    /// - Parameters:
    ///   - root: xml format
    ///   - object: object with data
    func loopResumen(_ root: AEXMLElement, _ object: [(id: String, valor: String, orden: Int)]) -> [(id: String, valor: String, orden: Int)]?{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "loopResumen"), .info)
        var objectResumen: [(id: String, valor: String, orden: Int)] = [(id: String, valor: String, orden: Int)]()
        if object.count > 0{ objectResumen = object }
        if root["elementos"].all?.count == 0 { return nil }
        if root["elementos"].error != nil{ return nil }
        if root["elementos"]["elemento"].all?.count == 0 { return nil}
        if root["elementos"]["elemento"].error != nil{ return nil }
        for elementos in (root["elementos"]["elemento"].all)!{
            if elementos["elementos"]["elemento"].all?.count ?? 0 > 0 {
                objectResumen = loopResumen(elementos, objectResumen)!
                continue
            }else{
                if elementos["atributos"]["usarcomocampoexterno"].error == nil{
                    if elementos["atributos"]["usarcomocampoexterno"].value == "true"{
                        objectResumen.append((id: elementos.attributes["idelemento"] ?? "", valor: elementos["atributos"]["valor"].value ?? "", orden: Int(elementos["atributos"]["ordenenresumen"].value ?? "0") ?? 0))
                        objectResumen.sort(by: { $0.orden < $1.orden })
                    }
                }
            }
        }
        return objectResumen
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    // MARK: - Verifying Format data
    /// Method to verify if the user has all data information from server
    /// - Parameter delegate: delegate viewcontroller
    func DGSDKverifyFormats(delegate: Delegate?) -> Promise<APISuccessResponse> {
        
        return Promise<APISuccessResponse> { resolve, reject in
            
            let typeName: String = #function
            let startDate = Date()
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
            }
            
            let consultaFormato = FEConsultaFormato()
            consultaFormato.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            consultaFormato.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            consultaFormato.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
            consultaFormato.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
            consultaFormato.IP = ConfigurationManager.shared.utilities.getIPAddress()
            
            
            guard FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Consulta.con")else {
                resolve(APISuccessResponse.success);
                return;
            }
            let consultaF = FEConsultaFormato(json: ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Consulta.con"))
            consultaFormato.FechaSincronizacionBorradores = consultaF.FechaSincronizacionBorradores
            consultaFormato.FechaSincronizacionIncidencia = consultaF.FechaSincronizacionIncidencia
            consultaFormato.FechaSincronizacionReserva = consultaF.FechaSincronizacionReserva
            consultaFormato.CheckSync = true
            // Solamente enviar
            // GUID
            // EstadoID
            consultaFormato.Incidencias = self.getFormatosSendToServer()
            
                
            do{
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                mutableRequest = try ConfigurationManager.shared.request.formatosRequest(formato: consultaFormato)
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                setTimerLogForRequest(mode: .async, request: mutableRequest, launcher: typeName, debug: ConfigurationManager.shared.debugNetwork)
                    .then { [self] data in
                        var _: Data
                        do{
                            let doc = try AEXMLDocument(xml: data)
                            // Exclusive IDportal Number for Security
                            let getCodeResult = doc["s:Envelope"]["s:Body"]["ConsultaFormatosResponse"]["ConsultaFormatosResult"].string
                            let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                            let decompressedData: Data
                            if bodyData.isGzipped {
                                decompressedData = try! bodyData.gunzipped()
                            } else {
                                decompressedData = bodyData
                            }
                            let decodedString = String(data: decompressedData, encoding: .utf8)!
                            let response = AjaxResponse(json: decodedString)
                            
                            if(response.Success){
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                let obj = FEConsultaFormato(dictionary: response.ReturnedObject ?? NSDictionary())
                                if obj.Incidencias.count > 0 {
                                    // Get differences and delete Format
                                    // Recorren las incidencias
                                    var sobrantes = [FEFormatoData]()
                                    for actual in consultaFormato.Incidencias{
                                        var founded = false
                                        for new in obj.Incidencias{
                                            if actual.Guid == new.Guid {
                                                founded = true;
                                            }
                                        }
                                        // Sobrantes
                                        if founded == false{
                                            sobrantes.append(actual)
                                        }
                                        
                                    }
                                    for formato in sobrantes{
                                        if formato.DocID > 0{
                                            self.removeFormato(formato: formato)
                                        }
                                    }
                                    
                                }
                                resolve(APISuccessResponse.success)
                            }else{
                                let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                                ConfigurationManager.shared.utilities.writeLogger(response.Mensaje, .info)
                                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, response.Mensaje))
                            }
                            
                        }catch let e{
                            ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                            reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
                        }
                        
                    }.catch { error in
                        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_timeout".langlocalized(), typeName), .info)
                        reject(error)
                    }
                
            }catch let e{
                ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
            }
            
        }
        
    }
    
    // MARK: - Download Formats
    /// Method to download all formats available in server
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - initial: forced to new data or existing
    func DGSDKdownloadFormats(delegate: Delegate?, initial: Bool = false) -> Promise<APISuccessResponse> {
        
        return Promise<APISuccessResponse> { resolve, reject in
            
            let typeName: String = #function
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), typeName), .info)
            
            if !ConfigurationManager.shared.utilities.checkNetwork(){
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, nil, "apimng_log_nodata"));
            }
            
            var isInitialDownload = false
            let consultaFormato = FEConsultaFormato()
            consultaFormato.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            consultaFormato.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            consultaFormato.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
            consultaFormato.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
            consultaFormato.IP = ConfigurationManager.shared.utilities.getIPAddress()
            
            // Reading if there is a Consulta.con file to read
            if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Consulta.con"){
                let consulta = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Consulta.con")
                let consultaF = FEConsultaFormato(json: consulta)
                consultaFormato.FechaSincronizacionBorradores = consultaF.FechaSincronizacionBorradores
                consultaFormato.FechaSincronizacionIncidencia = consultaF.FechaSincronizacionIncidencia
                consultaFormato.FechaSincronizacionReserva = consultaF.FechaSincronizacionReserva
            }else{
                consultaFormato.FechaSincronizacionBorradores = 0
                consultaFormato.FechaSincronizacionIncidencia = 0
                consultaFormato.FechaSincronizacionReserva = 0
                isInitialDownload = true
            }
            
            if initial{
                consultaFormato.FechaSincronizacionBorradores = 0
                consultaFormato.FechaSincronizacionIncidencia = 0
                consultaFormato.FechaSincronizacionReserva = 0
                isInitialDownload = true
            }
            
            consultaFormato.CheckSync = false
            consultaFormato.Incidencias = []
            
            self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                .then { result in
                    let mutableRequest: URLRequest
                    mutableRequest = try ConfigurationManager.shared.request.formatosRequest(formato: consultaFormato)
                    _ = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    self.setTimerLogForRequest(mode: .async, request: mutableRequest, launcher: typeName, debug: ConfigurationManager.shared.debugNetwork)
                        .then { data in
                            do{
                                let doc = try AEXMLDocument(xml: data)
                                // Exclusive IDportal Number for Security
                                let getCodeResult = doc["s:Envelope"]["s:Body"]["ConsultaFormatosResponse"]["ConsultaFormatosResult"].string
                                let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                                let decompressedData: Data
                                if bodyData.isGzipped {
                                    decompressedData = try! bodyData.gunzipped()
                                } else {
                                    decompressedData = bodyData
                                }
                                let decodedString = String(data: decompressedData, encoding: .utf8)!
                                let response = AjaxResponse(json: decodedString)
                                
                                if(response.Success){
                                    if response.ReturnedObject == nil || response.ReturnedObject?.count == 0{
                                        let e = "not_verifyformats_invalid".langlocalized()
                                        ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                                        reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, "\(e)"))
                                        return
                                    }
                                    // Deleting all formats
                                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                    let SANDBOX_FORMATO = FEConsultaFormato(dictionary: response.ReturnedObject!)
                                    var counter = 0
                                    if SANDBOX_FORMATO.Incidencias.count == 0 {
                                        resolve(APISuccessResponse.success)
                                    }
                                    
                                    if isInitialDownload{
                                        // Getting all formats and delete all less local
                                        let formatDirectories = FCFileManager.listDirectoriesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/", deep: true)
                                        
                                        for directory in formatDirectories!{
                                            let path = directory as! String
                                            let dir = path.components(separatedBy: "/Formatos/")
                                            let folder = dir[1].split{$0 == "/"}.map(String.init)
                                            if folder.count == 1{ continue }
                                            if folder[1] == "0"{
                                                // We need to read the content if the Format is Draft mode and we will not delete it
                                                let filesAtPath = FCFileManager.listFilesInDirectory(atPath: path)
                                                if filesAtPath?.count == 0{ continue }
                                                for files in filesAtPath!{
                                                    let file = files as! String
                                                    if file.contains(".bor"){
                                                        let pathAtCero = ConfigurationManager.shared.utilities.read(asString: file)
                                                        if pathAtCero == nil{ continue }
                                                        let formatoAtCero = FEFormatoData(json: pathAtCero)
                                                        if formatoAtCero.EstadoApp == 1{ continue }else{ FCFileManager.removeItem(atPath: file)
                                                            let rplc = file.replacingOccurrences(of: ".bor", with: ".json")
                                                            FCFileManager.removeItem(atPath: rplc)
                                                        }
                                                    }
                                                }
                                            }else{
                                                FCFileManager.removeItem(atPath: path)
                                            }
                                        }
                                    }
                                    
                                    for incidencias in SANDBOX_FORMATO.Incidencias{
                                        counter += 1
                                        
                                        // Saving JSON DATA
                                        _ = ConfigurationManager.shared.utilities.save(info: incidencias.JsonDatos, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(incidencias.FlujoID)/\(incidencias.PIID)/\(incidencias.Guid)_\(incidencias.ExpID)_\(incidencias.TipoDocID)-\(incidencias.FlujoID)-\(incidencias.PIID).json")
                                        
                                        //let customJson = incidencias.JsonDatos
                                        incidencias.JsonDatos = ""
                                        
                                        // Saving object Format
                                        let json = JSONSerializer.toJson(incidencias)
                                        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(incidencias.FlujoID)/\(incidencias.PIID)/\(incidencias.Guid)_\(incidencias.ExpID)_\(incidencias.TipoDocID)-\(incidencias.FlujoID)-\(incidencias.PIID).bor")
                                    }
                                    SANDBOX_FORMATO.Incidencias = Array<FEFormatoData>()
                                    self.salvarFormato(formato: SANDBOX_FORMATO, delegate: delegate)
                                    resolve(APISuccessResponse.success)
                                }else{
                                    ConfigurationManager.shared.utilities.writeLogger(response.Mensaje, .info)
                                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, response.Mensaje))
                                }
                                
                            }catch let e{
                                ConfigurationManager.shared.utilities.writeLogger("\(e.localizedDescription)\r", .error)
                                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, e.localizedDescription))
                            }
                            
                        }.catch { error in
                            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_timeout".langlocalized(), typeName), .info)
                            reject(error)
                        }
                }.catch { error in
                    ConfigurationManager.shared.utilities.writeLogger("\(error.localizedDescription)\r", .error)
                    reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.request, false, nil, error.localizedDescription))
                }
        }
        
    }
    
    // MARK: - Saving Format
    /// Method to save information about the format
    /// - Parameters:
    ///   - formato: object format
    ///   - delegate: delegate viewcontroller
    func salvarFormato(formato: FEConsultaFormato, delegate: Delegate?){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "salvarFormato"), .info)
        let json = JSONSerializer.toJson(formato)
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Consulta.con")
        
        if delegate != nil{
            // Function to reasing the value (FILES IN MB) in the Settings Bundle
            ConfigurationManager.shared.utilities.refreshFolderCapacity()
        }
    }
    
    // MARK: - Validate information Flows and Process
    /// Method to refresh information about the flows, process and created formats
    /// - Parameter delegate: delegate viewcontroller
    func DGSDKgetFlows(delegate: Delegate?) -> Promise<[FEPlantillaMerge]>{
        
        return Promise<[FEPlantillaMerge]>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "validFlujosAndProcesosPromise"), .info)
            let plantillaJson = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas.pla")
            var plantillas = [FEPlantillaMerge](json: plantillaJson)
           // ConfigurationManager.shared.flujosOrdered = plantillas
            
            for (index, proceso) in plantillas.enumerated(){
                let files = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(proceso.FlujoID)/", deep: true)
                if files?.count == 0 { continue }
                var cc = 0
                for file in files!{
                    let ff = file as? String ?? ""
                    if ff.contains(".bor"){ cc += 1 }
                }
                plantillas[index].CounterFormats = cc
            }
            resolve(plantillas)
        }
        
    }
    
    // MARK: - Get Formatos to Send
    /// Method to retrive all formats information to send to the server
    func getFormatosSendToServer() -> Array<FEFormatoData>{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getFormatosSendToServer"), .info)
        var arrayFormatoData = Array<FEFormatoData>()
        let files = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)", deep: true)
        for file in files!{
            let fileBor = file as! String
            if fileBor.contains(".bor"){
                let gettingXml = ConfigurationManager.shared.utilities.read(asString: fileBor)
                let formato = FEFormatoData(json: gettingXml)
                formato.JsonDatos = ""
                formato.Xml = ""
                formato.Anexos = [FEAnexoData]()
                arrayFormatoData.append(formato)
            }
        }
        return arrayFormatoData
    }
    
    // MARK: - Validate Flow and Process by Navigation
    /// Method to retrive information when user navigate from one process to another
    /// - Parameters:
    ///   - flujoId: flow id
    ///   - piid: process id
    func DGSDKgetFormatos(_ flujoId: Int, _ piid: Int) -> Array<FEFormatoData>{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getFormatosByFlujoAndProceso"), .info)
        var arrayFormatoData = Array<FEFormatoData>()
        let files = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(flujoId)/\(piid)/")
        
        for file in files!{
            let fileBor = file as! String
            if fileBor.contains(".bor"){
                let gettingXml = ConfigurationManager.shared.utilities.read(asString: fileBor)
                let formato = FEFormatoData(json: gettingXml)
                arrayFormatoData.append(formato)
            }
        }
        //arrayFormatoData.sort(by: { $0.Reserva && !$1.Reserva })
        arrayFormatoData.sort {
            if $0.Reserva == $1.Reserva {
                return $0.Guid < $1.Guid
            }
            return $0.Reserva && !$1.Reserva
        }
        //arrayFormatoData.sort(by: { $0.Guid > $1.Guid })
        return arrayFormatoData
    }
    
    // MARK: - Validate Flow by Navigation
    /// Method to retrive all information from one flow
    /// - Parameters:
    ///   - flujoId: flow id
    func DGSDKgetAllFormatos(_ flujoId: Int) -> Array<FEFormatoData>{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "DGSDKgetAllFormatos"), .info)
        var arrayFormatoData = Array<FEFormatoData>()
        let files = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(flujoId)/", deep: true)
        
        for file in files!{
            let fileBor = file as! String
            if fileBor.contains(".bor"){
                let gettingXml = ConfigurationManager.shared.utilities.read(asString: fileBor)
                let formato = FEFormatoData(json: gettingXml)
                arrayFormatoData.append(formato)
            }
        }
        arrayFormatoData.sort {
            if $0.Reserva == $1.Reserva {
                return $0.Guid < $1.Guid
            }
            return $0.Reserva && !$1.Reserva
        }
        return arrayFormatoData
    }
    
    // MARK: - Get Format Json
    /// Method to get current json data from format
    /// - Parameter formato: object format
    func DGSDKgetJson(_ formato: FEFormatoData) -> String?{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getFormatoJson"), .info)
        let stringJson = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(formato.FlujoID)/\(formato.PIID)/\(formato.Guid)_\(formato.ExpID)_\(formato.TipoDocID)-\(formato.FlujoID)-\(formato.PIID).json")
        return stringJson
    }
    
}

// MARK: - PLANTILLA DATA
public extension APIManager{
    
    /// DGSDKgetFlowTasks
    /// - Parameter formato: Current format to retrive all task can transit
    /// - Returns: error or array of tasks
    func DGSDKgetFlowTasks(formato: FEFormatoData) -> Promise<Array<String>>{
        
        return Promise<Array<String>>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "DGSDKgetFlowTasks"), .info)
            guard let plaString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(formato.FlujoID)/\(formato.ExpID)_\(formato.TipoDocID)/\(formato.ExpID)_\(formato.TipoDocID).pla") else {
                let e = "apimng_log_nofiletask".langlocalized()
                ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.nofile, false, nil, "\(e)"))
                return
            }
            let plantilla = FEPlantillaData(json: plaString)
            var tareas = [String]()
            for tarea in plantilla.EventosTareas{ if tarea.EstadoIniId == formato.EstadoID{ tareas.append(tarea.NombreTarea) } }
            if tareas.count == 0{
                let e = "apimng_log_notaskfound".langlocalized()
                ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.noData, false, nil, "\(e)"))
                return
            }
            resolve(tareas)
        }
    }
    
    /// DGSDKsetFlowTask
    /// - Parameters:
    ///   - formato: Current format to change task can transit
    ///   - nombreTarea: name of task
    /// - Returns: error or success
    func DGSDKsetFlowTask(delegate: Delegate?, formato: FEFormatoData, nombreTarea: String, needsReserved: Bool) -> Promise<Bool>{
        
        return Promise<Bool>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "DGSDKsetFlowTask"), .info)
            guard let plaString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(formato.FlujoID)/\(formato.ExpID)_\(formato.TipoDocID)/\(formato.ExpID)_\(formato.TipoDocID).pla") else {
                let e = "apimng_log_nofiletask".langlocalized()
                ConfigurationManager.shared.utilities.writeLogger("\(e)", .error)
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.nofile, false, nil, "\(e)"))
                return
            }
            let plantilla = FEPlantillaData(json: plaString)
            if needsReserved{
                self.DGSDKformatLockUnlock(delegate: delegate, formato)
                    .then{ response in
                        self.setTask(plantilla: plantilla, formato: formato, nombreTarea: nombreTarea); resolve(true);
                    }
                    .catch{ error in
                        let e = "apimng_log_notaskassigned".langlocalized();
                        reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.nofile, false, nil, "\(e)"));
                    }
            }else{
                self.setTask(plantilla: plantilla, formato: formato, nombreTarea: nombreTarea); resolve(true);
            }
            
            return
        }
        
    }
    
    func setTask(plantilla: FEPlantillaData, formato: FEFormatoData, nombreTarea: String){
        for tarea in plantilla.EventosTareas{
            if tarea.NombreTarea == nombreTarea && formato.EstadoID == tarea.EstadoIniId{
                formato.TareaSiguiente = tarea
                formato.EstadoApp = 2
                formato.Editado = true
                formato.Accion = 0
                formato.TipoReemplazo = 0
                self.salvarPlantillaData(formato: formato)
                return // 0 Transito Simple // 1 Normal publicación/reemplazar
            }
        }
    }
    
    
    // MARK: - GET XML
    /// Method to obtain xml of format
    /// - Parameters:
    ///   - flujo: flow id
    ///   - exp: exp id
    ///   - doc: doc id
    func getXML(flujo: String, exp: String, doc: String) -> Elemento{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getXML"), .info)
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).xml") else {
            return Elemento()
        }
        let plaString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).pla")
        ConfigurationManager.shared.plantillaDataUIAppDelegate = FEPlantillaData(json: plaString)
        let plantilla = Elemento(xmlString: xmlString)
        return plantilla!
    }
    
    // MARK: - GET PLANTILLA
    /// Method to get Plantilla in xml object
    /// - Parameters:
    ///   - flujo: flow id
    ///   - exp: exp id
    ///   - doc: doc id
    func getPLANTILLA(flujo: String, exp: String, doc: String)->AEXMLDocument?{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getPLANTILLA"), .info)
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).xml") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc; } catch { return nil; }
    }
    
    // MARK: - GET RULES
    /// Method to get Rules to interact with format
    /// - Parameters:
    ///   - flujo: flow id
    ///   - exp: exp id
    ///   - doc: doc id
    func getRULES(flujo: String, exp: String, doc: String) -> AEXMLDocument?{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getRULES"), .info)
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).rls") else { return nil }
        if xmlString.count < 10{ return nil }
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlString);
            return xmlDoc;
        } catch { return nil; }
    }
    
    // MARK: - GET SERVICES
    /// Method to get services to interact with format
    /// - Parameters:
    ///   - flujo: flow id
    ///   - exp: exp id
    ///   - doc: doc id
    func getSERVICES(flujo: String, exp: String, doc: String) -> AEXMLDocument?{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getSERVICES"), .info)
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).srv") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc; } catch { return nil; }
    }
    
    // MARK: - GET COMPONENTS
    /// Method to get components to interact with format
    /// - Parameters:
    ///   - flujo: flow id
    ///   - exp: exp id
    ///   - doc: doc id
    func getCOMPONENTS(flujo: String, exp: String, doc: String) -> AEXMLDocument?{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getCOMPONENTS"), .info)
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).cmp") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc; } catch { return nil; }
    }
    
    // MARK: - GET MATHEMATICS
    /// Method to get mathematics to interact with format
    /// - Parameters:
    ///   - flujo: flow id
    ///   - exp: exp id
    ///   - doc: doc id
    func getMATHEMATICS(flujo: String, exp: String, doc: String) -> AEXMLDocument?{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getMATHEMATICS"), .info)
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).mat") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc; } catch { return nil; }
    }
    
    // MARK: - GET PREFILL
    /// Method to get prefill information to fill new format based on the actual one
    /// - Parameters:
    ///   - flujo: flow id
    ///   - exp: exp id
    ///   - doc: doc id
    func getPREFILLEDDATA(flujo: String, exp: String, doc: String) -> AEXMLDocument?{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getPREFILLEDDATA"), .info)
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).prf") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc; } catch { return nil; }
    }
    
    // MARK: - GET PDFMAPPING
    /// Method to get prefill information to fill new format based on the actual one
    /// - Parameters:
    ///   - flujo: flow id
    ///   - exp: exp id
    ///   - doc: doc id
    func getPDFMAPPING(flujo: String, exp: String, doc: String) -> AEXMLDocument?{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "getPDFMAPPING"), .info)
        guard let xmlString = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(flujo)/\(exp)_\(doc)/\(exp)_\(doc).map") else { return nil }
        if xmlString.count < 10{ return nil }
        do { let xmlDoc = try AEXMLDocument(xml: xmlString); return xmlDoc; } catch { return nil; }
    }
    
    // MARK: - Save Format Data
    /// Method to save infromation about the format
    /// - Parameter formato: object template
    func salvarPlantillaData(formato: FEFormatoData){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "salvarPlantillaData"), .info)
        let json = JSONSerializer.toJson(formato)
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Formatos/\(formato.FlujoID)/\(formato.PIID)/\(formato.Guid)_\(formato.ExpID)_\(formato.TipoDocID)-\(formato.FlujoID)-\(formato.PIID).bor")
        
        // Function to reasing the value (FILES IN MB) in the Settings Bundle
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
    }
    
    // MARK: - Save Format and Json
    /// Method to save current format and json information
    /// - Parameters:
    ///   - formato: object format
    ///   - json: json data string
    func salvarPlantillaDataAndJson(formato: FEFormatoData, json: String){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "salvarPlantillaDataAndJson"), .info)
        let formatoString = JSONSerializer.toJson(formato)
        _ = ConfigurationManager.shared.utilities.save(info: formatoString, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Formatos/\(formato.FlujoID)/\(formato.PIID)/\(formato.Guid)_\(formato.ExpID)_\(formato.TipoDocID)-\(formato.FlujoID)-\(formato.PIID).bor")
        
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Formatos/\(formato.FlujoID)/\(formato.PIID)/\(formato.Guid)_\(formato.ExpID)_\(formato.TipoDocID)-\(formato.FlujoID)-\(formato.PIID).json")
        
        // Function to reasing the value (FILES IN MB) in the Settings Bundle
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
        
    }
}

// MARK: - UPDATE TO SERVER
public extension APIManager{
    
    // MARK: Send To Server Formats
    /// Method to get a loop of formats to send to server
    /// - Parameter delegate: delegate viewcontroller
    func DGSDKsendFormatos(delegate: Delegate?) -> Promise<[FEConsultaFormato]>{
        
        return Promise<[FEConsultaFormato]>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sendToServerFormatosPromise"), .info)
            
            
            let folders = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/", deep: true)
            var resultFormato = [FEConsultaFormato]()
            
            for files in folders!{
                let fileString = files as! String
                if fileString.contains(".bor"){
                    let gettingXml = ConfigurationManager.shared.utilities.read(asString: fileString)
                    let formato = FEFormatoData(json: gettingXml)
                    
                    if (formato.EstadoApp == 1 || formato.EstadoApp == 2) && formato.Editado{
                        let fileJson = fileString.replacingOccurrences(of: ".bor", with: ".json")
                        let contentJson = ConfigurationManager.shared.utilities.read(asString: fileJson)
                        formato.JsonDatos = contentJson!
                        let consultaFormato = FEConsultaFormato()
                        consultaFormato.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
                        consultaFormato.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
                        consultaFormato.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
                        consultaFormato.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
                        consultaFormato.IP = ConfigurationManager.shared.utilities.getIPAddress()
                        consultaFormato.Formato = formato
                        
                        resultFormato.append(consultaFormato)
                    }
                    
                }
            }
            
            if resultFormato.count > 0{
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                self.dispatchForms = DispatchGroup()
                
                for formato in resultFormato{
                    self.dispatchForms.enter()
                    _ = self.sendFormatoDataPromise(delegate: delegate, formato: formato)
                    _ = self.sendToServerAnexosPromise(delegate: delegate, formato: formato)
                    self.dispatchForms.leave()
                    
                }
                self.dispatchForms.notify(queue: .main) {
                    ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_formats".langlocalized(), String(resultFormato.count)), .info)
                    resolve(resultFormato)
                }
                
            }else{
                ConfigurationManager.shared.utilities.writeLogger("No hay formatos por enviar", .info)
                reject(APIErrorResponse.FormsError)
            }
            
        }
        
    }
    
    func DGSDKsendFormatosEC(delegate: Delegate?, formatoData: FEFormatoData?) -> Promise<FEConsultaFormato>{
        
        return Promise<FEConsultaFormato>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sendToServerFormatosPromise"), .info)
            
            var resultFormato = FEConsultaFormato()
            let folders = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/", deep: true)
            
            for files in folders!{
                let fileString = files as! String
                if fileString.contains(".bor"){
                    let gettingXml = ConfigurationManager.shared.utilities.read(asString: fileString)
                    let formato = FEFormatoData(json: gettingXml)
                    if formatoData!.Guid == formato.Guid{
                        let fileJson = fileString.replacingOccurrences(of: ".bor", with: ".json")
                        let contentJson = ConfigurationManager.shared.utilities.read(asString: fileJson)
                        formatoData!.JsonDatos = contentJson!
                    }
                }
            }
            if (formatoData!.EstadoApp == 1 || formatoData!.EstadoApp == 2) && formatoData!.Editado{
                
                let consultaFormato = FEConsultaFormato()
                consultaFormato.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
                consultaFormato.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
                consultaFormato.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
                consultaFormato.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
                consultaFormato.IP = ConfigurationManager.shared.utilities.getIPAddress()
                consultaFormato.Formato = formatoData!
                
                resultFormato = consultaFormato
            }
            
            if ConfigurationManager.shared.webSecurity || plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco{
                _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
            }
            
            Bluebirdreduce([resultFormato], 0) { promise, item in
                return self.loopSendFormatoPromise(delegate: delegate, element: item).then { response in
                    return 0
                }
            }.then { response in
                ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_formats".langlocalized(), "0"), .info)
                resolve(resultFormato)
            }.catch { error in
                ConfigurationManager.shared.utilities.writeLogger("apimng_log_errorFormats".langlocalized(), .error)
                reject(APIErrorResponse.ServerError)
            }
            
            
        }
        
    }
    
    // MARK: - Remove Format
    /// Method to remove format from aplication
    /// - Parameter formato: object format
    func removeFormato(formato: FEFormatoData){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "removeFormato"), .info)
        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Formatos/\(formato.FlujoID)/\(formato.PIID)/\(formato.Guid)_\(formato.ExpID)_\(formato.TipoDocID)-\(formato.FlujoID)-\(formato.PIID).bor")
        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Formatos/\(formato.FlujoID)/\(formato.PIID)/\(formato.Guid)_\(formato.ExpID)_\(formato.TipoDocID)-\(formato.FlujoID)-\(formato.PIID).json")
        for anexo in formato.Anexos{
            FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)")
        }
        // Function to reasing the value (FILES IN MB) in the Settings Bundle
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
    }
    
    // MARK: - Loop Send Format
    /// Method to loop array to send formats
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - element: consult format object
    func loopSendFormatoPromise(delegate: Delegate?, element: FEConsultaFormato) -> Promise<Bool>{
        return Promise<Bool>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "loopSendFormatoPromise"), .info)
            self.sendFormatoDataPromiseEC(delegate: delegate, formato: element)
                .then { response in
                    self.sendToServerAnexosPromiseEC(delegate: delegate, formato: element)
                        .then({ response in
                            resolve(true)
                        })
                        .catch({ error in
                            reject(error)
                        })
            }.catch { error in
                reject(error)
            }
        }
    }

    
    // MARK: - Send Format
    /// Method to get information about format and send to server
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - formato: consulta format object
    func sendFormatoDataPromiseEC(delegate: Delegate?, formato: FEConsultaFormato) -> Promise<FEConsultaFormato>{
        
        return Promise<FEConsultaFormato>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sendFormatoDataPromise"), .info)
            let startDate = Date()
            let mutableRequest: URLRequest
            
            
            do{
                if ConfigurationManager.shared.webSecurity || plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                mutableRequest = try ConfigurationManager.shared.request.sendFormatosRequest(formato: formato)
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError); return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["EnviaFormatoResponse"]["EnviaFormatoResult"].string
                        let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponse(json: decodedString)
                        if(response.Success){
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            let SANDBOX_FORMATO = FEConsultaFormato(dictionary: response.ReturnedObject!)
                            if SANDBOX_FORMATO.IdDel > 0{
                                self.removeFormato(formato: formato.Formato)
                            }else if response.Mensaje.contains("DocId") || response.Mensaje.contains("DocId\n"){
                                self.removeFormato(formato: formato.Formato)
                            }
                            if formato.Formato.EstadoApp != 2{
                                if response.Mensaje.contains("Documento respaldado") {
                                    formato.Formato.EstadoApp = 0
                                    self.salvarPlantillaData(formato: formato.Formato)
                                }
                            }
                            resolve(formato)
                        }else{
                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            resolve(formato)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    
    // MARK: - Send Attachments to Server
    /// Method to send attachments to server
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - formato: consulta format object
    
    func sendToServerAnexosPromiseEC(delegate: Delegate?, formato: FEConsultaFormato) -> Promise<[FEConsultaAnexo]>{
        
        return Promise<[FEConsultaAnexo]>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sendToServerAnexosPromise"), .info)
            
            var resultAnexo = [FEConsultaAnexo]()
            
            for anexo in formato.Formato.Anexos{
                if !anexo.Editado && !anexo.Publicado && !anexo.Reemplazado{ continue }
                
                let consultaAnexo = FEConsultaAnexo()
                consultaAnexo.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
                consultaAnexo.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
                consultaAnexo.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
                consultaAnexo.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
                consultaAnexo.IP = ConfigurationManager.shared.utilities.getIPAddress()
                consultaAnexo.EstadoApp = formato.Formato.EstadoApp
                consultaAnexo.TipoReemplazo = formato.Formato.TipoReemplazo
                consultaAnexo.Accion = formato.Formato.Accion
                
                if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
                    let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)")
                   
                    if anexo.Extension == ".WSQ"{
                        anexo.Datos = String(data: fileData!, encoding: .utf8)!
                    }else{
                        let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                        anexo.Datos = anexoBase64
                    }

                    anexo.TareaSiguiente = formato.Formato.TareaSiguiente
                    anexo.Guid = formato.Formato.Guid;
                    anexo.ExpID = formato.Formato.ExpID;
                    if anexo.isReemplazo {
                        var name = anexo.FileName
                        name = name.replacingOccurrences(of: "\(anexo.ElementoId)", with: "\(anexo.ElementoId)R\(anexo.DocID)")
                        anexo.FileName = name
                    }
                    anexo.DocID = formato.Formato.DocID;
                    consultaAnexo.anexo = anexo
                    if anexo.Datos != ""{
                        resultAnexo.append(consultaAnexo)
                    }
                }
                
            }
            
            if resultAnexo.count > 0{
                if ConfigurationManager.shared.webSecurity || plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                Bluebirdreduce(resultAnexo, 0) { promise, item in
                    return self.sendAnexoDataPromiseEC(delegate: delegate, consulta: item, formato: formato).then { response in
                        return 0
                    }
                }.then { response in
                    ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_attachments".langlocalized(), String(resultAnexo.count)), .info)
                    resolve(resultAnexo)
                }.catch { error in
                    ConfigurationManager.shared.utilities.writeLogger("apimng_log_errorattachments".langlocalized(), .error)
                    reject(APIErrorResponse.ServerError)
                }
            }else{
                ConfigurationManager.shared.utilities.writeLogger("apimng_log_noattachments".langlocalized(), .info)
                resolve(resultAnexo)
            }
            
        }
        
    }
    
    
    
    // MARK: - Send Attachment
    /// Method to send attachment to the server
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - consulta: consulta attachment object
    ///   - formato: consulta format object
    func sendAnexoDataPromiseEC(delegate: Delegate?, consulta: FEConsultaAnexo, formato: FEConsultaFormato) -> Promise<FEConsultaAnexo>{
    
    return Promise<FEConsultaAnexo>{ resolve, reject in
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sendAnexoDataPromise"), .info)
        let startDate = Date()
        let mutableRequest: URLRequest
        do{
            if ConfigurationManager.shared.webSecurity || plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco{
                _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
            }
            mutableRequest = try ConfigurationManager.shared.request.sendAnexosRequest(consulta: consulta)
            let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
            let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                guard data != nil && error == nil else {
                    ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                    reject(APIErrorResponse.ServerError); return
                }
                do{
                    let doc = try AEXMLDocument(xml: data!)
                    let getCodeResult = doc["s:Envelope"]["s:Body"]["EnviaAnexoResponse"]["EnviaAnexoResult"].string
                    let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                    let decompressedData: Data
                    if bodyData.isGzipped {
                        decompressedData = try! bodyData.gunzipped()
                    } else {
                        decompressedData = bodyData
                    }
                    let decodedString = String(data: decompressedData, encoding: .utf8)!
                    
                    let response = AjaxResponse(json: decodedString)
                    
                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                    
                    if response.Mensaje.lowercased().contains("enviando informacion, por favor espere"){
                        resolve(consulta)
                    }
                    if response.Mensaje.lowercased().contains("docid"){
                        self.removeFormato(formato: formato.Formato)
                        resolve(consulta)
                    }
                    if response.Success{
                        self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                        resolve(consulta)
                    }else{
                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                        self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                        reject(APIErrorResponse.ServerError)
                    }
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(APIErrorResponse.ServerError)
                }
            }); task.resume()
        }catch let error{
            ConfigurationManager.shared.utilities.writeLogger("\(error) ", .error)
            reject(APIErrorResponse.ServerError)
        }
        
    }
    
}
    
    // MARK: - Send Format
    /// Method to get information about format and send to server
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - formato: consulta format object
    func sendFormatoDataPromise(delegate: Delegate?, formato: FEConsultaFormato) -> Bool{
        
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sendFormatoDataPromise"), .info)
        let startDate = Date()
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        
        let mutableRequest: URLRequest
        /*DispatchQueue.main.async() {
            delegate?.didSendResponseHUD(message: "hud_send".langlocalized(), error: .error, porcentage: 0)
        }*/
        
        do{
            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
            }
            mutableRequest = try ConfigurationManager.shared.request.sendFormatosRequest(formato: formato)
            let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
            let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                guard data != nil && error == nil else {
                    ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                    semaphore.signal()
                    success = false
                    return
                }
                do{
                    let doc = try AEXMLDocument(xml: data!)
                    let getCodeResult = doc["s:Envelope"]["s:Body"]["EnviaFormatoResponse"]["EnviaFormatoResult"].string
                    let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                    let decompressedData: Data
                    if bodyData.isGzipped {
                        decompressedData = try! bodyData.gunzipped()
                    } else {
                        decompressedData = bodyData
                    }
                    let decodedString = String(data: decompressedData, encoding: .utf8)!
                    let response = AjaxResponse(json: decodedString)
                    if(response.Success){
                        self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                        ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                        let SANDBOX_FORMATO = FEConsultaFormato(dictionary: response.ReturnedObject!)
                        if SANDBOX_FORMATO.IdDel > 0{
                            self.removeFormato(formato: formato.Formato)
                        }else if response.Mensaje.contains("DocId") || response.Mensaje.contains("DocId\n"){
                            self.removeFormato(formato: formato.Formato)
                        }
                        if formato.Formato.EstadoApp != 2{
                            if response.Mensaje.contains("Documento respaldado") {
                                formato.Formato.EstadoApp = 0
                                self.salvarPlantillaData(formato: formato.Formato)
                            }
                        }
                        semaphore.signal()
                        success = true
                    }else{
                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                        self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                        ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                        semaphore.signal()
                        success = true
                    }
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    semaphore.signal()
                    success = false
                }
            });
            task.resume()
            semaphore.wait()
        }catch let error{
            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
            semaphore.signal()
            success = false
        }
        return success
    }
    
    // MARK: - Delete Format
    /// Method to delete format from server
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - formato: consulta format object
    func DGSDKformatoDelete(delegate: Delegate?, formato: FEFormatoData) -> Promise<FEFormatoData>{
        
        return Promise<FEFormatoData>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "deleteFormatoDataPromise"), .info)
            
            if formato.DocID == 0 && formato.EstadoApp == 2 || formato.DocID == 0 && formato.EstadoApp == 1{
                ConfigurationManager.shared.utilities.removeFilesForFormat(formato)
                resolve(formato)
            }
            
            let consultaFormato = FEConsultaFormato()
            consultaFormato.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            consultaFormato.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            consultaFormato.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
            consultaFormato.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
            consultaFormato.IP = ConfigurationManager.shared.utilities.getIPAddress()
            consultaFormato.Formato = FEFormatoData()
            consultaFormato.Formato.Guid = formato.Guid
            
            let mutableRequest: URLRequest
            /*DispatchQueue.main.async() {
                delegate?.didSendResponseHUD(message: "hud_delete".langlocalized(), error: .error, porcentage: 0)
            }*/
            do{
                mutableRequest = try ConfigurationManager.shared.request.deleteFormatoRequest(formato: consultaFormato)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError); return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["BorraFormatoBorradorResponse"]["BorraFormatoBorradorResult"].string
                        let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponse(json: decodedString)
                        if(response.Success){
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            ConfigurationManager.shared.utilities.removeFilesForFormat(formato)
                            resolve(formato)
                        }else{
                            if response.Mensaje.contains("No se encontro el formato con el Guid") || response.Mensaje.contains("No se tiene expediente y tipodoc para encontrar la plantilla") || response.Mensaje.contains("No se pudo borrar el formato ya que ya ha sido publicado y no es un borrador"){
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                ConfigurationManager.shared.utilities.removeFilesForFormat(formato)
                                resolve(formato)
                            }else{
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                reject(APIErrorResponse.ServerError)
                            }
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
}

// MARK: ENVIAR ANEXOS
public extension APIManager{
    
    // MARK: - Send Attachments to Server
    /// Method to send attachments to server
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - formato: consulta format object
    
    func sendToServerAnexosPromise(delegate: Delegate?, formato: FEConsultaFormato) -> Promise<[FEConsultaAnexo]>{
        
        return Promise<[FEConsultaAnexo]>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sendToServerAnexosPromise"), .info)
            
            var resultAnexo = [FEConsultaAnexo]()
            
            for anexo in formato.Formato.Anexos{
                if !anexo.Editado && !anexo.Publicado && !anexo.Reemplazado{ continue }
                
                let consultaAnexo = FEConsultaAnexo()
                consultaAnexo.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
                consultaAnexo.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
                consultaAnexo.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
                consultaAnexo.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
                consultaAnexo.IP = ConfigurationManager.shared.utilities.getIPAddress()
                consultaAnexo.EstadoApp = formato.Formato.EstadoApp
                consultaAnexo.TipoReemplazo = formato.Formato.TipoReemplazo
                consultaAnexo.Accion = formato.Formato.Accion
                
                if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
                    let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)")
                    if anexo.Extension == ".WSQ"{
                        anexo.Datos = String(data: fileData!, encoding: .utf8)!
                    }else{
                        let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                        anexo.Datos = anexoBase64
                    }
                    
                    anexo.TareaSiguiente = formato.Formato.TareaSiguiente
                    anexo.Guid = formato.Formato.Guid;
                    anexo.ExpID = formato.Formato.ExpID;
                    if anexo.isReemplazo {
                        var name = anexo.FileName
                        name = name.replacingOccurrences(of: "\(anexo.ElementoId)", with: "\(anexo.ElementoId)R\(anexo.DocID)")
                        anexo.FileName = name
                    }
                    anexo.DocID = formato.Formato.DocID;
                    consultaAnexo.anexo = anexo
                    if anexo.Datos != ""{
                        resultAnexo.append(consultaAnexo)
                    }
                }
                
            }
            
            if resultAnexo.count > 0{
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                self.dispatchAttachments = DispatchGroup()
                
                for anexo in resultAnexo{
                    self.dispatchAttachments.enter()
                    _ = self.sendAnexoDataPromise(delegate: delegate, consulta: anexo, formato: formato)
                    self.dispatchAttachments.leave()
                    
                }
                self.dispatchAttachments.notify(queue: .main) {
                    ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_formats".langlocalized(), String(resultAnexo.count)), .info)
                    resolve(resultAnexo)
                }
                
            }else{
                ConfigurationManager.shared.utilities.writeLogger("apimng_log_noattachments".langlocalized(), .info)
                reject(APIErrorResponse.FormsError)
            }
            
        }
        
    }
    
    // MARK: - Send Attachment
    /// Method to send attachment to the server
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - consulta: consulta attachment object
    ///   - formato: consulta format object
    func sendAnexoDataPromise(delegate: Delegate?, consulta: FEConsultaAnexo, formato: FEConsultaFormato) -> Bool{
        
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sendAnexoDataPromise"), .info)
        let startDate = Date()
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        let mutableRequest: URLRequest
        
        do{
            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
            }
            mutableRequest = try ConfigurationManager.shared.request.sendAnexosRequest(consulta: consulta)
            let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
            let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                guard data != nil && error == nil else {
                    ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                    semaphore.signal()
                    success = false
                    return
                }
                do{
                    let doc = try AEXMLDocument(xml: data!)
                    let getCodeResult = doc["s:Envelope"]["s:Body"]["EnviaAnexoResponse"]["EnviaAnexoResult"].string
                    let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                    let decompressedData: Data
                    if bodyData.isGzipped {
                        decompressedData = try! bodyData.gunzipped()
                    } else {
                        decompressedData = bodyData
                    }
                    let decodedString = String(data: decompressedData, encoding: .utf8)!
                    
                    let response = AjaxResponse(json: decodedString)
                    
                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                    
                    if response.Mensaje.lowercased().contains("enviando informacion, por favor espere"){
                        semaphore.signal()
                        success = true
                    }
                    if response.Mensaje.lowercased().contains("docid"){
                        self.removeFormato(formato: formato.Formato)
                        semaphore.signal()
                        success = true
                    }
                    if response.Success{
                        self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                        semaphore.signal()
                        success = true
                    }else{
                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                        self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                        semaphore.signal()
                        success = false
                    }
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    semaphore.signal()
                    success = false
                }
            });
            task.resume()
            semaphore.wait()
        }catch let error{
            ConfigurationManager.shared.utilities.writeLogger("\(error) ", .error)
            semaphore.signal()
            success = false
        }
        return success
    }
    
    // MARK: - Remove attachment
    /// Method to remove attachment from application
    /// - Parameter anexo: anexo object
    func removeAnexo(anexo: FEAnexoData){
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "removeAnexo"), .info)
        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.anexos)")
        // Function to reasing the value (FILES IN MB) in the Settings Bundle
        ConfigurationManager.shared.utilities.refreshFolderCapacity()
    }
    
}

// MARK: EDITAR FORMATO
public extension APIManager{
    
    /// Format Edit
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - formato: format to be edited
    ///   - reserva: If need to be reserved; reserved: true, released: false
    ///   - isInEdition: Edition mode; to be edited: false, to be viewed: true
    /// - Returns: This function is used to edit or view a format.
    func DGSDKformatEdit(delegate: Delegate?, formato: FEFormatoData, _ reserva: Bool, _ isInEdition: Bool) -> Promise<FEFormatoData>{
        return Promise<FEFormatoData>{ resolve, reject in
            if (!formato.Reserva && formato.DocID > 0) {
                self.DGSDKformatLockUnlock(delegate: delegate, formato)
                    .then{ response in
                        resolve(response)
                    }.catch{ error in
                        reject(APIErrorResponse.TransitedError)
                    }
            }else{
                resolve(formato)
            }
            
        }
    }
}


// MARK: TRANSITAR FORMATO
public extension APIManager{
    
    // MARK: - Obtain Transit Work
    /// Method to get next work to transit the format
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - index: index format
    ///   - formato: format object
    ///   - reserva: isReserved
    ///   - isInEdition: isInEditionMode
    func DGSDKformatLockUnlock(delegate: Delegate?, _ formato: FEFormatoData) -> Promise<FEFormatoData>{
        
        return Promise<FEFormatoData>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "obtenerEventosTareaPromise"), .info)
            
            guard let file = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/Plantillas/\(formato.FlujoID)/\(formato.ExpID)_\(formato.TipoDocID)/\(formato.ExpID)_\(formato.TipoDocID).pla") else {
                return
            }
            let p = FEPlantillaData(json: file)
            
            let dummyFormato = formato.copy(with: nil) as! FEFormatoData
            dummyFormato.JsonDatos = formato.JsonDatos.replacingOccurrences(of: "\\\"", with: "\"")
            dummyFormato.JsonDatos = formato.JsonDatos.replacingOccurrences(of: "\"", with: "\\\"")
            dummyFormato.NombreEstado = ""
            
            if (p.TipoDocID == formato.TipoDocID && p.ExpID == formato.ExpID) {
                var encontrado = false;
                for evento in p.EventosTareas {
                    if (formato.Reserva && evento.EstadoIniId == formato.EstadoID && evento.TareaID == 2) {
                        dummyFormato.TareaSiguiente = evento;
                        encontrado = true;
                        break;
                    }else if (formato.Reserva == false && evento.EstadoIniId == formato.EstadoID && evento.TareaID == 0) {
                        dummyFormato.TareaSiguiente = evento;
                        encontrado = true;
                        break;
                    }
                }
                if encontrado == false{
                    for evento in p.EventosTareas {
                        if (dummyFormato.Reserva == false && evento.EstadoIniId == dummyFormato.EstadoID && evento.TareaID == 2) {
                            dummyFormato.EstadoID = evento.EstadoFinId
                            dummyFormato.Reserva = !dummyFormato.Reserva;
                            break;
                        }
                    }
                    for evento in p.EventosTareas {
                        if (dummyFormato.Reserva && evento.EstadoIniId == dummyFormato.EstadoID && evento.TareaID == 0) {
                            formato.TareaSiguiente = evento;
                            formato.EstadoID = evento.EstadoFinId
                            formato.Reserva = !dummyFormato.Reserva;
                            encontrado = true;
                            resolve(formato)
                            return
                        }
                    }
                    if encontrado == false{
                        reject(APIErrorResponse.TransitedError)
                        return
                    }
                }
                
            }
                        
            isFormatoReservedPromise(delegate: delegate, dummyFormato, formato)
                .then{ response in
                    resolve(formato)
                }.catch{ error in
                    resolve(formato)
                }
        }
    }
    
    // MARK: - Reserve Format
    /// Method to reserve format to only used for curretn user
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - index: index format
    ///   - formato: format object
    ///   - reserva: isReserved
    ///   - isInEdition: isInEditionMode
    func isFormatoReservedPromise(delegate: Delegate?, _ formato: FEFormatoData, _ original: FEFormatoData) -> Promise<AjaxResponse>{
        
        return Promise<AjaxResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "isFormatoReservedPromise"), .info)
            let consultaFormato = FEConsultaFormato()
            consultaFormato.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            consultaFormato.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            consultaFormato.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
            consultaFormato.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
            consultaFormato.IP = ConfigurationManager.shared.utilities.getIPAddress()
            consultaFormato.Formato = formato
            consultaFormato.Formato.JsonDatos = ""
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.transitaRequest(formato: consultaFormato)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["TransitaFormatoResponse"]["TransitaFormatoResult"].string
                        let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponse(json: decodedString)
                        if(response.Success){
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            original.EstadoID = consultaFormato.Formato.TareaSiguiente.EstadoFinId
                            original.Reserva = !formato.Reserva;
                            self.salvarPlantillaData(formato: original)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                                resolve(response)
                            })
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.ParseError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.XMLError)
                    }
                    
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error) ", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
}

extension Int {
    var byteSize: String {
        return ByteCountFormatter().string(fromByteCount: Int64(self))
    }
}


public extension APIManager{
    
    // Todos FEFormatoData
    func DGSDKverAnexo(formato: FEFormatoData) -> Promise<Bool>{
        
        return Promise<Bool>{ resolve, reject in
            
            Bluebirdreduce(formato.Anexos, 0) { promise, item in
                return self.DGSDKverAnexo(anexo: item, formato: formato).then { response in
                    return 0
                }
            }.then { response in
                ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_formats".langlocalized(), "0"), .info)
                formato.AnexosDescargados = true
                self.salvarPlantillaData(formato: formato)
                resolve(true)
            }.catch { error in
                ConfigurationManager.shared.utilities.writeLogger("apimng_log_errorFormats".langlocalized(), .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func DGSDKverAnexo(anexo: FEAnexoData, formato: FEFormatoData) -> Promise<String>{
        
        return Promise<String>{ resolve, reject in
            let startDate = Date()
            // We are detecting if the file exists
          /*  if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
                let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)")
                let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                resolve(anexoBase64)
                return
            }*/
            
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "DGSDKverAnexo"), .info)
            
            let consultaAnexo = FEConsultaAnexo()
            consultaAnexo.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            consultaAnexo.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            consultaAnexo.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
            consultaAnexo.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
            consultaAnexo.IP = ConfigurationManager.shared.utilities.getIPAddress()
            consultaAnexo.EstadoApp = formato.EstadoApp
            consultaAnexo.anexo = anexo
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.consultaAnexosRequest(consulta: consultaAnexo)
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError); return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["ConsultaAnexoResponse"]["ConsultaAnexoResult"].string
                        let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponse(json: decodedString)
                        if(response.Success){
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            let consulta = FEConsultaAnexo(dictionary: response.ReturnedObject!)
                            let data:NSData = NSData(base64Encoded: consulta.datos, options: NSData.Base64DecodingOptions(rawValue: 0)) ?? NSData(base64Encoded: consulta.datos, options: .ignoreUnknownCharacters)!
                            let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(data, "\(anexo.FileName)")
                            
                            resolve(consulta.datos)
                        }else{
                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.ParseError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.XMLError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error) ", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    // MARK: - Consult Attachments
    /// Method to consult attachments in server
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - anexo: consulta attachment object
    func DGSDKformatoAnexos(delegate: Delegate?, anexo: FEAnexoData, estado: Int) -> Promise<FEAnexoData>{
        
        return Promise<FEAnexoData>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "consultaAnexoDataPromise"), .info)
            let startDate = Date()
            // TODO: Validación si existe el usuario
            
            let consultaAnexo = FEConsultaAnexo()
            consultaAnexo.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            consultaAnexo.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            consultaAnexo.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
            consultaAnexo.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
            consultaAnexo.IP = ConfigurationManager.shared.utilities.getIPAddress()
            consultaAnexo.EstadoApp = estado
            consultaAnexo.anexo = anexo
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.consultaAnexosRequest(consulta: consultaAnexo)
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError); return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["ConsultaAnexoResponse"]["ConsultaAnexoResult"].string
                        let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponse(json: decodedString)
                        if(response.Success){
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            let consulta = FEConsultaAnexo(dictionary: response.ReturnedObject!)
                            let data:NSData = NSData(base64Encoded: consulta.datos, options: NSData.Base64DecodingOptions(rawValue: 0)) ?? NSData(base64Encoded: consulta.datos, options: .ignoreUnknownCharacters)!
                            let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(data, "\(anexo.FileName)")
                            resolve(anexo)
                        }else{
                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.ParseError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.XMLError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error) ", .error)
                reject(APIErrorResponse.ServerError)
            }
        }
    }
    
    func DGSDKdownloadAttachmentSync(delegate: Delegate?, anexo: FEAnexoData) -> Bool{
        
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "consultaAnexoDataPromise"), .info)
        let startDate = Date()
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        let consultaAnexo = FEConsultaAnexo()
        consultaAnexo.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
        consultaAnexo.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
        consultaAnexo.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
        consultaAnexo.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
        consultaAnexo.IP = ConfigurationManager.shared.utilities.getIPAddress()
        consultaAnexo.anexo = anexo
        
        let mutableRequest: URLRequest
        do{
            mutableRequest = try ConfigurationManager.shared.request.consultaAnexosRequest(consulta: consultaAnexo)
            let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
            let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                guard data != nil && error == nil else {
                    ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                    semaphore.signal()
                    success = false
                    return
                }
                do{
                    let doc = try AEXMLDocument(xml: data!)
                    let getCodeResult = doc["s:Envelope"]["s:Body"]["ConsultaAnexoResponse"]["ConsultaAnexoResult"].string
                    let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                    let decompressedData: Data
                    if bodyData.isGzipped {
                        decompressedData = try! bodyData.gunzipped()
                    } else {
                        decompressedData = bodyData
                    }
                    let decodedString = String(data: decompressedData, encoding: .utf8)!
                    let response = AjaxResponse(json: decodedString)
                    if(response.Success){
                        self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                        ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                        let consulta = FEConsultaAnexo(dictionary: response.ReturnedObject!)
                        if anexo.Extension == ".PNG" || anexo.Extension == ".png" || anexo.Extension == "PNG" || anexo.Extension == "png" || anexo.Extension == ".JPEG" || anexo.Extension == ".jpeg" || anexo.Extension == "JPEG" || anexo.Extension == "jpeg" || anexo.Extension == ".JPG" || anexo.Extension == ".jpg" || anexo.Extension == "JPG" || anexo.Extension == "jpg"{
                            if consulta.datos.isEmpty{
                            }else{
                                let data:NSData = NSData(base64Encoded: consulta.datos, options: NSData.Base64DecodingOptions(rawValue: 0)) ?? NSData(base64Encoded: consulta.datos, options: .ignoreUnknownCharacters)!
                                let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(data, "\(anexo.FileName)")
                            }
                            semaphore.signal()
                            success = true
                        }else{
                            let data:NSData = NSData(base64Encoded: consulta.datos, options: NSData.Base64DecodingOptions(rawValue: 0)) ?? NSData(base64Encoded: consulta.datos, options: .ignoreUnknownCharacters)!
                            let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(data, "\(anexo.FileName)")
                            semaphore.signal()
                            success = true
                        }
                    }else{
                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                        self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                        ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                        semaphore.signal()
                        success = false
                    }
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    semaphore.signal()
                    success = false
                }
            });
            task.resume()
            semaphore.wait()
        }catch let error{
            ConfigurationManager.shared.utilities.writeLogger("\(error) ", .error)
            semaphore.signal()
            success = false
        }
        return success
    }
    
    // MARK: - Consult PDF
    /// Method to get PDF file created by information uploaded in the format
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - anexo: consulta attachment object
    func DGSDKformatPDF(delegate: Delegate?, formato: FEFormatoData) -> Promise<String>{
        
        return Promise<String>{ resolve, reject in
            let startDate = Date()
            let anexo = FEConsultaAnexo()
            anexo.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
            anexo.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
            anexo.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
            anexo.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
            anexo.IP = ConfigurationManager.shared.utilities.getIPAddress()
            anexo.EstadoApp = FormularioUtilities.shared.currentFormato.EstadoApp
            anexo.anexo.DocID = formato.DocID
            
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "consultaPDFDataPromise"), .info)
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.consultaAnexosRequest(consulta: anexo)
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError); return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["ConsultaAnexoResponse"]["ConsultaAnexoResult"].string
                        let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponse(json: decodedString)
                        
                        if(response.Success){
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            let consulta = FEConsultaAnexo(dictionary: response.ReturnedObject!)
                            resolve(consulta.datos)
                        }else{
                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.ParseError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.XMLError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error) ", .error)
                reject(APIErrorResponse.ServerError)
            }
        }
    }
    
}

// MARK: - CONSULTA CONSULTAS
public extension APIManager{
    
    // MARK: - Consult search
    /// Method to consult, search and create a data research
    /// - Parameters:
    ///   - delegate: delegate viewcontroller
    ///   - reporte: report object
    ///   - consulta: consulta object
    func consultaConsultasPromise(delegate: Delegate?, reporte: FETipoReporte?, consulta: FEConsultaTemplate?) -> Promise<FEConsultaTemplate>{
        
        return Promise<FEConsultaTemplate>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "consultaConsultasPromise"), .info)
            let startDate = Date()
            let mutableRequest: URLRequest
            do{
                var consultaT = FEConsultaTemplate()
                if (reporte != nil){
                    
                    consultaT.Consulta = reporte!
                    consultaT.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
                    consultaT.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
                    consultaT.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
                    consultaT.GrupoAdminID = ConfigurationManager.shared.usuarioUIAppDelegate.GrupoAdminID
                    consultaT.Password = ConfigurationManager.shared.usuarioUIAppDelegate.Password
                    consultaT.IP = ConfigurationManager.shared.utilities.getIPAddress()
                    
                    if ConfigurationManager.shared.isConsubanco{
                        consultaT.RegistrosPorPagina = ConfigurationManager.shared.consultaSum + 30
                    }
                    
                }else{
                    consultaT = consulta!
                }
                
                for consul in consultaT.Consulta.Campos {
                    consul.Regla = ""
                }
                
                mutableRequest = try ConfigurationManager.shared.request.consultaRequest(consulta: consultaT)
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["ConsultaTemplateResponse"]["ConsultaTemplateResult"].string
                        let bodyData = Data(base64Encoded: self.getReturnObject(aexmlD: doc, r: getCodeResult))!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponse(json: decodedString)
                        if(response.Success){
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            let consulta = FEConsultaTemplate(dictionary: response.ReturnedObject!)
                            resolve(consulta)
                            
                        }else{
                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.ParseError)
                        }
                        
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.XMLError)
                        
                    }
                    
                }); task.resume()
            }catch (let error){
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
}

// MARK: - SOAP SERVICIOS
public extension APIManager{
    
    func compareFacesPromise(delegate: Delegate?, compareFaces: CompareFacesResult) -> Promise<AjaxResponse>{
        
        return Promise<AjaxResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "compareFacesPromise"), .info)
            let startDate = Date()
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.compareFacesRequest(compareFaces: compareFaces)
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["CompareFacesResponse"]["CompareFacesResult"].string
                        let bodyData =  self.getReturnObject(aexmlD: doc, r: getCodeResult)
                        let response = AjaxResponse(json: bodyData)
                        if(response.Success){
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            let mensajeResultado = CompareFacesResult(dictionary: response.ReturnedObject!)
                            resolve(response)
                        }else{
                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapNewcompareFacesPromise(delegate: Delegate?, mParams mparams: [String], poutParams poutparams:[String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapNewcompareFacesPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapNewCompareFacesRequest(mParams: mparams, poutParams: poutparams)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        
                        //                        if  let responseEncrypt = doc["s:Envelope"]["s:Body"]["response"].value{
                        //                            let decodedData = Data(base64Encoded: responseEncrypt)
                        //                            let decryptSoap = decodedData!.aesEncrypt(keyData: ConfigurationManager.shared.keyaes.data(using: .utf8, allowLossyConversion: false)!, ivData: ConfigurationManager.shared.ivaes.data(using: .utf8, allowLossyConversion: false)!, operation: kCCDecrypt)
                        //                            let encodingSoap = String(bytes: decryptSoap, encoding: .utf8)
                        //
                        //
                        //                            let jsonDict = try JSONSerializer.toDictionary(encodingSoap ?? "")
                        //                            if let returnobj = jsonDict["ReturnedObject"]{}
                        //                        }
                        
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                })
                task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapNewFolioPromise(delegate: Delegate?, mParams mparams: [String], sParams sparams:[String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapNewFolioPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapNewFolioRequest(mParams: mparams, sParams: sparams)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        
                        //                        if  let responseEncrypt = doc["s:Envelope"]["s:Body"]["response"].value{
                        //                            let decodedData = Data(base64Encoded: responseEncrypt)
                        //                            let decryptSoap = decodedData!.aesEncrypt(keyData: ConfigurationManager.shared.keyaes.data(using: .utf8, allowLossyConversion: false)!, ivData: ConfigurationManager.shared.ivaes.data(using: .utf8, allowLossyConversion: false)!, operation: kCCDecrypt)
                        //                            let encodingSoap = String(bytes: decryptSoap, encoding: .utf8)
                        //
                        //
                        //                            let jsonDict = try JSONSerializer.toDictionary(encodingSoap ?? "")
                        //                            if let returnobj = jsonDict["ReturnedObject"]{}
                        //                        }
                        
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapNewSMSPromise(delegate: Delegate?, mParams mparams: [String], sParams sparams:[String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapNewSMSPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapNewSMSRequest(mParams: mparams, sParams: sparams)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        
                        //                        if  let responseEncrypt = doc["s:Envelope"]["s:Body"]["response"].value{
                        //                            let decodedData = Data(base64Encoded: responseEncrypt)
                        //                            let decryptSoap = decodedData!.aesEncrypt(keyData: ConfigurationManager.shared.keyaes.data(using: .utf8, allowLossyConversion: false)!, ivData: ConfigurationManager.shared.ivaes.data(using: .utf8, allowLossyConversion: false)!, operation: kCCDecrypt)
                        //                            let encodingSoap = String(bytes: decryptSoap, encoding: .utf8)
                        //
                        //
                        //                            let jsonDict = try JSONSerializer.toDictionary(encodingSoap ?? "")
                        //                            if let returnobj = jsonDict["ReturnedObject"]{}
                        //                        }
                        
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                })
                task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapNewValidateSMSPromise(delegate: Delegate?, mParams mparams: [String], sParams sparams:[String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapNewValidateSMSPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapNewValidateSMSRequest(mParams: mparams, sParams: sparams)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        //                        if  let responseEncrypt = doc["s:Envelope"]["s:Body"]["response"].value{
                        //                            let decodedData = Data(base64Encoded: responseEncrypt)
                        //                            let decryptSoap = decodedData!.aesEncrypt(keyData: ConfigurationManager.shared.keyaes.data(using: .utf8, allowLossyConversion: false)!, ivData: ConfigurationManager.shared.ivaes.data(using: .utf8, allowLossyConversion: false)!, operation: kCCDecrypt)
                        //                            let encodingSoap = String(bytes: decryptSoap, encoding: .utf8)
                        //
                        //
                        //                            let jsonDict = try JSONSerializer.toDictionary(encodingSoap ?? "")
                        //                            if let returnobj = jsonDict["ReturnedObject"]{}
                        //                        }
                        
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapNewSepomexPromise(delegate: Delegate?, mParams mparams: [String], sParams sparams:[String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapNewSepomexPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapNewSepomexRequest(mParams: mparams, sParams: sparams)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapNewRegistroPromise(delegate: Delegate?, mParams mparams: [String], sParams sparams:[String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapNewRegistroPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapNewRegistroRequest(mParams: mparams, sParams: sparams)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapNewActivacionCorreoPromise(delegate: Delegate?, mParams mparams: [String], sParams sparams:[String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapNewActivacionCorreoPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapNewActivacionCorreoRequest(mParams: mparams, sParams: sparams)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapNewExisteUsuarioPromise(delegate: Delegate?, mParams mparams: [String], sParams sparams:[String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapNewExisteUsuarioPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapNewExisteUsuarioRequest(mParams: mparams, sParams: sparams)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)r\n", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapNewActivarUsuarioPromise(delegate: Delegate?, mParams mparams: [String], sParams sparams:[String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapNewActivarUsuarioPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapNewActivarUsuarioRequest(mParams: mparams, sParams: sparams)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapNewSassSirhPromise(delegate: Delegate?, mParams mparams: [String], sParams sparams:[String], poutParams poutparams: [String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapNewSassSirhPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapNewSassSirhRequest(mParams: mparams, sParams: sparams, poutParams: poutparams)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapFolioPromise(delegate: Delegate?, folio: FolioAutomaticoResult) -> Promise<AjaxResponse>{
        
        return Promise<AjaxResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapFolioPromise"), .info)
            let startDate = Date()
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapFolioRequest(folio: folio)
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.webSecurity{
                            let encodigSoapTest = try self.decodeReturnSoap(doc["s:Envelope"]["s:Body"]["response"].string)
                            let jsonDict = try JSONSerializer.toDictionary(encodigSoapTest)
                            if let returnobj = jsonDict["ReturnedObject"] as? String{
                                let response = AjaxResponse(json: returnobj)
                                if(response.Success){
                                    self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                    let mensajeResultado = FolioAutomaticoResult(dictionary: response.ReturnedObject!)
                                    resolve(response)
                                }else{
                                    let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                    self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                    reject(APIErrorResponse.ServerError)
                                }
                            }
                        }else{
                            let getCodeResult = doc["s:Envelope"]["s:Body"]["FolioAutomaticoResponse"]["FolioAutomaticoResult"].string
                            
                            
                            let response = AjaxResponse(json: getCodeResult)
                            if(response.Success){
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                let mensajeResultado = FolioAutomaticoResult(dictionary: response.ReturnedObject!)
                                resolve(response)
                            }else{
                                let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                reject(APIErrorResponse.ServerError)
                            }
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func sepomexPromise(delegate: Delegate?, sepomex: SepoMexResult) -> Promise<AjaxResponse>{
        
        return Promise<AjaxResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sepomexPromise"), .info)
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                
                let mutableRequest: URLRequest
                do{
                    mutableRequest = try ConfigurationManager.shared.request.sepomexRequest(sepomex: sepomex)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else {
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            reject(APIErrorResponse.ServerError)
                            return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.webSecurity{
                                let encodigSoapTest = try self.decodeReturnSoap(doc["s:Envelope"]["s:Body"]["response"].string)
                                let jsonDict = try JSONSerializer.toDictionary(encodigSoapTest)
                                if let returnobj = jsonDict["ReturnedObject"] as? String{
                                    let response = AjaxResponse(json: returnobj)
                                    if(response.Success){
                                        self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                        ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                        resolve(response)
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                                        ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                        reject(APIErrorResponse.ServerError)
                                    }
                                }
                            }else{
                                let getCodeResult = doc["s:Envelope"]["s:Body"]["ObtenerCodigoPostalResponse"]["ObtenerCodigoPostalResult"].string
                                
                                
                                let response = AjaxResponse(json: getCodeResult)
                                if(response.Success){
                                    self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                                    resolve(response)
                                }else{
                                    let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                    self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                                    ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                                    reject(APIErrorResponse.ServerError)
                                }
                            }
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }); task.resume()
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(APIErrorResponse.ServerError)
                }
                
            }
            
        }
    }
    
    // MARK: - SERVICIOS CREDIFIEL-PROMISE
    func soapGenericJsonSync(delegate: Delegate?, jsonService jsonservice: NSString) -> AEXMLDocument{
        let startDate = Date()
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericJsonSync"), .info)
        let semaphore = DispatchSemaphore(value: 0)
        let mutableRequest: URLRequest
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
        }
        var aexml = AEXMLDocument()
        do{
            mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
            let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
            let task = URLSession.shared.dataTask(with: mutableRequest) { (data, response, error) in
                guard data != nil && error == nil else{
                    ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                    semaphore.signal()
                    return
                }
                do{
                    let doc = try AEXMLDocument(xml: data!)
                    let jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                    let decodeJson = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                    
                    if let _ = decodeJson.data(using: .utf8){
                        do {
                            let jsonDict = try JSONSerializer.toDictionary(decodeJson)
                            self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                            let responseService = jsonDict["response"] as! NSMutableDictionary
                            _ = responseService["servicesuccess"] as! Bool
                            aexml = doc
                            semaphore.signal()
                        }catch let error{
                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                            self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(error)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            semaphore.signal()
                        }
                    }
                    
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    semaphore.signal()
                }
            }
            task.resume()
            semaphore.wait()
        }catch let error{
            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
            semaphore.signal()
        }
        
        return aexml
    }
    
    func soapGenericSync(delegate: Delegate?,idService idservice: String?, mParams mparams: [[String: Any]]?, sParams sparams: [[String: Any]]?, poutParams poutparams: [[String: Any]]?, jsonService: String)->AEXMLDocument{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericSync"), .info)
        let startDate = Date()
        let semaphore = DispatchSemaphore(value: 0)
        let mutableRequest: URLRequest
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
        }
        var aexml = AEXMLDocument()
        do{
            mutableRequest = try ConfigurationManager.shared.request.soapGenericRequest(idService: idservice, mParams: mparams, sParams: sparams, poutParams: poutparams, jsonService: jsonService)
            let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
            let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                guard data != nil && error == nil else {
                    ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                    semaphore.signal()
                    return
                }
                do{
                    let doc = try AEXMLDocument(xml: data!)
                    _ = self.getReturnObject(aexmlD: doc, r: "")
                    
                    if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                        self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, "")
                        ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                        aexml = doc
                        semaphore.signal()
                    }else{
                        ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", ConfigurationManager.shared.initialmethod, "")
                        aexml = doc
                        semaphore.signal()
                    }
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    semaphore.signal()
                }
            })
            task.resume()
            semaphore.wait()
        }catch let error{
            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
            semaphore.signal()
        }
        return aexml
    }
    
    func soapGenericPromise(delegate: Delegate?,idService idservice: String?, mParams mparams: [[String: Any]]?, sParams sparams: [[String: Any]]?, poutParams poutparams: [[String: Any]]?, jsonService: String) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericPromise"), .info)
            
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapGenericRequest(idService: idservice, mParams: mparams, sParams: sparams, poutParams: poutparams, jsonService: jsonService)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                })
                task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
    }
    
    func soapVerificaCurpRfcCredifielPromise(delegate: Delegate?, mParams mparams: [String]) -> Promise<AEXMLDocument>{
        
        return Promise<AEXMLDocument>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapVerificaCurpRfcCredifielPromise"), .info)
            let startDate = Date()
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapVerificaCurpRfcCredifielRequest(mParams: mparams)
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        
                        if doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:success"].string == "true" && doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].string == "true"{
                            self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .info)
                            resolve(doc)
                        }else{
                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                            self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)")
                            ConfigurationManager.shared.utilities.writeLogger("\(doc["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].string)", .error)
                            reject(APIErrorResponse.ServerError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func soapCorreoPromise(delegate: Delegate?, correo: CorreoServicio) -> Promise<AjaxResponse>{
        
        return Promise<AjaxResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapCorreoPromise"), .info)
            let startDate = Date()
            let mutableRequest: URLRequest
            do{
                mutableRequest = try ConfigurationManager.shared.request.soapCorreoRequest(correo: correo)
                let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["SendMailResponse"]["SendMailResult"].string
                        let response = AjaxResponse(json: getCodeResult)
                        if(response.Success){
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            let _ = CorreoServicio(dictionary: response.ReturnedObject!)
                            resolve(response)
                        }else{
                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                            self.logsService(log: response.Success, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: response.Mensaje)
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.SMSOnlineError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.SMSOnlineError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.SMSOnlineError)
            }
            
        }
        
    }
    
}

// MARK: - LOGALTY SERVICES
extension APIManager{
    
    func sendFormatoDataLogaltyPromise(delegate: Delegate?, formato: FEConsultaFormato) -> Promise<FELogaltySaml>{
        
        return Promise<FELogaltySaml>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sendFormatoDataLogaltyPromise"), .info)
            
            let mutableRequest: URLRequest
            
            do{
                mutableRequest = try ConfigurationManager.shared.request.sendFormatosRequestLogalty(formato: formato)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["GeneraPeticionLogaltyResponse"]["GeneraPeticionLogaltyResult"].string
                        let bodyData = Data(base64Encoded: getCodeResult)!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponse(json: decodedString)
                        if(response.Success){
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            // FORMATO POR BORRAR
                            let SANDBOX_FORMATO = FELogaltySaml(dictionary: response.ReturnedObject!)
                            
                            let feLogaltySaml = FELogaltySaml()
                            feLogaltySaml.Uuid = SANDBOX_FORMATO.Uuid
                            feLogaltySaml.Guid = SANDBOX_FORMATO.Guid
                            feLogaltySaml.Url = SANDBOX_FORMATO.Url
                            feLogaltySaml.GuidFormato = formato.Formato.Guid
                            
                            resolve(feLogaltySaml)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.FormatosOnlineError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
    func sendFormatoDataLogaltyEndPromise(delegate: Delegate?, formato: FELogaltySaml) -> Promise<FELogaltySaml>{
        
        return Promise<FELogaltySaml>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "sendFormatoDataLogaltyEndPromise"), .info)
            
            let mutableRequest: URLRequest
            
            do{
                mutableRequest = try ConfigurationManager.shared.request.sendFormatosRequestEndLogalty(formato: formato)
                let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                    guard data != nil && error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do{
                        let doc = try AEXMLDocument(xml: data!)
                        let getCodeResult = doc["s:Envelope"]["s:Body"]["TerminaProcesoLogaltyResponse"]["TerminaProcesoLogaltyResult"].string
                        let bodyData = Data(base64Encoded: getCodeResult)!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponse(json: decodedString)
                        if(response.Success){
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .info)
                            // FORMATO POR BORRAR
                            let _ = FELogaltySaml(dictionary: response.ReturnedObject!)
                            // GUARDAR Objetos PDF y CERT
                            resolve(formato)
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)", .error)
                            reject(APIErrorResponse.FormatosOnlineError)
                        }
                    }catch let error{
                        ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                        reject(APIErrorResponse.ServerError)
                    }
                }); task.resume()
            }catch let error{
                ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                reject(APIErrorResponse.ServerError)
            }
            
        }
        
    }
    
}

// MARK: - SERVICES 2.0
public extension APIManager{
    
    /// metodo para registro de servicios V2
    /// - Parameters:
    ///   - delegate: ViewController a utilizar
    ///   - nombre: nombre description
    ///   - aPaterno: aPaterno description
    ///   - aMaterno: aMaterno description
    ///   - password: password description
    ///   - email: email description
    /// - Returns: description Valor de retorno Bool
    func DGSDKRegistroV2(delegate: Delegate?, nombre: String, aPaterno: String, aMaterno: String, password: String, email: String) -> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericJsonSync"), .info)
            var password = Array(password.utf8)
            password = password.sha512()
            let passwordString = password.toBase64()
            
            let dictService = ["initialmethod":"ServiciosDigipro.ServicioUsuario.Registro", "assemblypath": "ServiciosDigipro.dll", "data": ["user": "\(email)", "password":"\(passwordString)", "nombre":"\(nombre)", "apellidop":"\(aPaterno)", "apellidom":"\(aMaterno)", "email":"\(email)" , "proyid": ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID, "grupoid":"1", "perfiles":ConfigurationManager.shared.codigoUIAppDelegate.Perfiles]] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                do{
                    //try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonString)
                    let task = URLSession.shared.dataTask(with: mutableRequest) { (data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["response"].value
                            if let _ = jsonString?.data(using: .utf8){
                                do {
                                    ConfigurationManager.shared.webSecurity = true
                                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                        let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                        jsonString = jsonDecode
                                        ConfigurationManager.shared.webSecurity = false
                                    }
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    let mssg = responseService["servicemessage"] as? String ?? ""
                                    let success = responseService["success"] as! Bool
                                    if success{
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.noData.rawValue, userInfo: ["success": false, "message": "\(mssg)"]))
                                    }
                                }catch let error{
                                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                                    reject(error)
                                }
                            }else{
                                ConfigurationManager.shared.utilities.writeLogger("Acceso denegado falta de Token.", .error)
                                reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "Acceso denegado falta de Token."]))
                            }
                            
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(error)
                            
                        }
                    }
                    task.resume()
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(error)
                    
                }
            }
        }
    }
    
    
    
    // metodo para enviar el PIN SMS del registro
    func DGSDKRegistroPinSMSV2(delegate: Delegate?, user: String, phoneNumber: String)-> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericJsonSync"), .info)
            let dictService = ["initialmethod":"ServiciosDigipro.ServicioSms.RegistroPinSms", "assemblypath": "ServiciosDigipro.dll", "data": ["user": "\(user)" , "telefono":"\(phoneNumber)", "proyid": ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID]] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                do{
                    //try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonString)
                    let task = URLSession.shared.dataTask(with: mutableRequest) { (data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["response"].value
                            if let _ = jsonString?.data(using: .utf8){
                                do {
                                    ConfigurationManager.shared.webSecurity = true
                                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                        let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                        jsonString = jsonDecode
                                        ConfigurationManager.shared.webSecurity = false
                                    }
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    let mssg = responseService["servicemessage"] as? String ?? ""
                                    let success = responseService["success"] as! Bool
                                    if success{
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.noData.rawValue, userInfo: ["success": false, "message": "\(mssg)"]))
                                    }
                                }
                            }else{
                                ConfigurationManager.shared.utilities.writeLogger("Acceso denegado falta de Token.", .error)
                                reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.noData.rawValue, userInfo: ["success": false, "message": "Acceso denegado falta de Token."]))
                            }
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(error)
                            
                        }
                        
                    }
                    task.resume()
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(error)
                    
                }
            }
        }
    }
    
    // metodo para validar el pin que llego por medio de SMS
    func DGSDKValidateSmsCodeV2(delegate: Delegate?, user: String, phoneNumber: String, codeSMS: String)-> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericJsonSync"), .info)
            let dictService = ["initialmethod":"ServiciosDigipro.ServicioSms.ValidateSmsCode", "assemblypath": "ServiciosDigipro.dll", "data": ["user": "\(user)" , "telefono":"\(phoneNumber)", "codigo":"\(codeSMS)", "proyid": ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID]] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                do{
                    //try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonString)
                    let task = URLSession.shared.dataTask(with: mutableRequest) { (data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["response"].value
                            if let _ = jsonString?.data(using: .utf8){
                                do {
                                    ConfigurationManager.shared.webSecurity = true
                                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                        let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                        jsonString = jsonDecode
                                        ConfigurationManager.shared.webSecurity = false
                                    }
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    let mssg = responseService["servicemessage"] as? String ?? ""
                                    let success = responseService["success"] as! Bool
                                    if success{
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.noData.rawValue, userInfo: ["success": false, "message": "\(mssg)"]))
                                    }
                                }
                            }else{
                                ConfigurationManager.shared.utilities.writeLogger("Acceso denegado falta de Token.", .error)
                                reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.noData.rawValue, userInfo: ["success": false, "message": "Acceso denegado falta de Token."]))
                            }
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(error)
                            
                        }
                        
                    }
                    task.resume()
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(error)
                    
                }
            }
        }
    }
    
    // metodo para Activar usuario cuando termina un registro
    func DGSDKActivateUserV2(delegate: Delegate?, user: String) -> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericJsonSync"), .info)
            let dictService = ["initialmethod":"ServiciosDigipro.ServicioUsuario.ActivarUsuario", "assemblypath": "ServiciosDigipro.dll", "data": ["user": "\(user)" , "proyid": ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID]] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                do{
                    //try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonString)
                    let task = URLSession.shared.dataTask(with: mutableRequest) { (data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["response"].value
                            if let _ = jsonString?.data(using: .utf8){
                                do {
                                    ConfigurationManager.shared.webSecurity = true
                                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                        let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                        jsonString = jsonDecode
                                        ConfigurationManager.shared.webSecurity = false
                                    }
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    let mssg = responseService["servicemessage"] as? String ?? ""
                                    let success = responseService["success"] as! Bool
                                    if success{
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.noData.rawValue, userInfo: ["success": false, "message": "\(mssg)"]))
                                    }
                                }catch let error{
                                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                                    reject(error)
                                }
                            }
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(error)
                            
                        }
                    }
                    task.resume()
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(error)
                    
                }
        }
        }
    }
    
    /// METODO PARA SABER SI EL USUARIO EXISTE EN EL SISTEMA
    /// - Parameters:
    ///   - delegate: ViewController a utilizar
    ///   - user: user description Usuario a validar
    /// - Returns: description Respuesta del servicio de tipo Bool para saber si fue satsfactoria o no la respuesta del servcio
    func DGSDKUserExistV2(delegate: Delegate?, user: String) -> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericJsonSync"), .info)
            let dictService = ["initialmethod":"ServiciosDigipro.ServicioUsuario.ExisteUsuario", "assemblypath": "ServiciosDigipro.dll", "data": ["user": "\(user)" , "proyid": ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID]] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                do{
                    //try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonString)
                    let task = URLSession.shared.dataTask(with: mutableRequest) { (data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["response"].value
                            if let _ = jsonString?.data(using: .utf8){
                                do {
                                    ConfigurationManager.shared.webSecurity = true
                                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                        let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                        jsonString = jsonDecode
                                        ConfigurationManager.shared.webSecurity = false
                                    }
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    let mssg = responseService["servicemessage"] as? String ?? ""
                                    let dataResponse = jsonDict["data"] as! NSMutableDictionary
                                    let exist = dataResponse["Existe"] as! Bool
                                    let success = responseService["success"] as! Bool
                                    if success || exist {
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "\(mssg)"]))
                                    }
                                }catch let error{
                                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                                    reject(error)
                                }
                            }
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(error)
                            
                        }
                    }
                    task.resume()
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(error)
                    
                }
        }
        }
    }
    
    /// Metodo para recuperar password V2
    /// - Parameters:
    ///   - delegate: ViewController a utilizar
    ///   - user: user description String de entrada para consumir servicio
    /// - Returns: description valor de retorno Bool
    func DGSDKRetrievePassword(delegate: Delegate?, user: String) -> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericJsonSync"), .info)
            let dictService = ["initialmethod":"ServiciosDigipro.ServicioUsuario.OlvidePassword", "assemblypath": "ServiciosDigipro.dll", "data": ["user": "\(user)" , "proyid": ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID]] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                do{
                    //try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonString)
                    let task = URLSession.shared.dataTask(with: mutableRequest) { (data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["response"].value
                            if let _ = jsonString?.data(using: .utf8){
                                do {
                                    ConfigurationManager.shared.webSecurity = true
                                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                        let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                        jsonString = jsonDecode
                                        ConfigurationManager.shared.webSecurity = false
                                    }
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    let mssg = responseService["servicemessage"] as? String ?? ""
                                    let success = responseService["success"] as! Bool
                                    if success && (mssg != "Usuario desactivado" && mssg != "Usuario no válido"){
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        if mssg == "Usuario desactivado"{
                                            reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "Usuario desactivado"]))
                                        }else if mssg == "Usuario no válido"{
                                            reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "Usuario no válido"]))
                                        }else if mssg == "El usuario especificado no existe"{
                                            reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "El usuario especificado no existe"]))
                                        }
                                    }
                                    
                                }catch let error{
                                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                                    reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "Error en el servicio intente de nuevo"]))
                                }
                            }else{
                                ConfigurationManager.shared.utilities.writeLogger("Acceso denegado falta de Token.", .error)
                                reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "Acceso denegado falta de Token."]))
                            }
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(error)
                            
                        }
                    }
                    task.resume()
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(error)
                }
            }
        }
    }
    
    
    
    
    /// SERVICIO PARA RECUPERAR PASSWORD
    /// - Parameters:
    ///   - delegate: delegate ViewController a utilizar
    ///   - user: user description String de entrada para consumir servicio
    /// - Returns: description valor de retorno Bool
    func DGSDKrestorePassword(delegate: Delegate?, user: String) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericJsonSync"), .info)
            
            let dictService = ["initialmethod":"ServiciosDigipro.ServicioUsuario.OlvidePassword", "data": ["user": "\(user)" , "proyid": ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID]] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonString)
                    let task = URLSession.shared.dataTask(with: mutableRequest) { (data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            let jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if let _ = jsonString?.data(using: .utf8){
                                do {
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    let mssg = responseService["servicemessage"] as? String ?? ""
                                    let success = responseService["success"] as! Bool
                                    if success && (mssg != "Usuario desactivado" && mssg != "Usuario no válido"){
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        if mssg == "Usuario desactivado"{
                                            reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "Usuario desactivado"]))
                                        }else if mssg == "Usuario no válido"{
                                            reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "Usuario no válido"]))
                                        }
                                    }
                                    
                                }catch let error{
                                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                                    reject(error)
                                }
                            }
                            
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(error)
                            
                        }
                    }
                    task.resume()
                    
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(error)
                }
            }
        }
    }
    
    
    func DGSDKResetPassV2(delegate: Delegate?, user: String, password: String, passwordNuevo: String)  -> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericJsonSync"), .info)
            var passwordC = Array(password.utf8)
            passwordC = passwordC.sha512()
            let passwordString = passwordC.toBase64()
            let pass = Array(password.utf8)
            let passwordBase = pass.toBase64()
            
            var passwordN = Array(passwordNuevo.utf8)
            passwordN = passwordN.sha512()
            let passwordStringN = passwordN.toBase64()
            let passN = Array(passwordNuevo.utf8)
            let passwordBaseN = passN.toBase64()
            
            
            let dictService = ["initialmethod":"ServiciosDigipro.ServicioUsuario.CambiarPassword", "data": ["user": "\(user)","password":"\(passwordString)", "passwordnuevo":"\(passwordStringN)", "passwordencoded":"\(passwordBase)", "passwordnuevoencoded":"\(passwordBaseN)", "proyid": ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID]] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                do{
                    //try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonString)
                    let task = URLSession.shared.dataTask(with: mutableRequest) { (data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["response"].value
                            if let _ = jsonString?.data(using: .utf8){
                                do {
                                    ConfigurationManager.shared.webSecurity = true
                                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                        let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                        jsonString = jsonDecode
                                        ConfigurationManager.shared.webSecurity = false
                                    }
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    let mssg = responseService["servicemessage"] as? String ?? ""
                                    let serviceSuccess = responseService["servicesuccess"] as! Bool
                                    let success = responseService["success"] as! Bool
                                    if success && serviceSuccess{
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "\(mssg)"]))
                                    }
                                }catch let error{
                                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                                    reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "Error en el servicio intente de nuevo"]))
                                }
                            }else{
                                ConfigurationManager.shared.utilities.writeLogger("Acceso denegado falta de Token.", .error)
                                reject(NSError(domain: Domain.sdk.rawValue, code: ApiErrors.changePassword.rawValue, userInfo: ["success": false, "message": "Acceso denegado falta de Token."]))
                            }
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(error)
                        }
                    }
                    task.resume()
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(error)
                }
                
            }
        }
    }
    
    
    /// SERVICIO PARA RESETEAR CONTRASEÑA
    /// - Parameters:
    ///   - delegate: delegate ViewController a utilizar
    ///   - jsonservice: jsonservice json string con la informacion requerida para el servicio
    /// - Returns: description valor de retorno Bool
    func DGSDKresetContraseniaV2(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<APISuccessResponse>{
        
        return Promise<APISuccessResponse>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "soapGenericJsonSync"), .info)
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest) { (data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("apimng_log_nodata".langlocalized(), .warning)
                            return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            let jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if let _ = jsonString?.data(using: .utf8){
                                do {
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    let success = responseService["success"] as! Bool
                                    if success{
                                        self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(APIErrorResponse.ServerError)")
                                        reject(APIErrorResponse.ServerError)
                                    }
                                }catch let error{
                                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                                    reject(error)
                                }
                            }
                        }catch let error{
                            ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                            reject(error)
                            
                        }
                    }
                    task.resume()
                    
                }catch let error{
                    ConfigurationManager.shared.utilities.writeLogger("\(error)", .error)
                    reject(error)
                }
            }
        }
    }
    
    func servTimestampFAD(delegate: Delegate?, jsonService jsonservice: [String : Any], nameServ nameserv : String, dllServ dllserv: String) -> Promise<String> {
        return Promise<String>{ resolve, reject in
            DispatchQueue.global(qos: .background).async {
                let dictService = ["initialmethod":"\(nameserv)","assemblypath":"\(dllserv)", "data": jsonservice] as [String : Any]
                let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
                let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonString)
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do{
                                let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                
                                let responseService = jsonDict["response"] as! NSMutableDictionary
                                let message: String = responseService["servicemessage"] as? String ?? ""
                                
                                if let dataDict = jsonDict["data"] as? NSMutableDictionary, (dataDict["JSON"] != nil) {
                                    do{
                                        let jsonDict = try JSONSerializer.toDictionary(dataDict["JSON"] as! String)
                                        let timeStamp = jsonDict.value(forKey: "value") as? String ?? ""
                                        if timeStamp != "" {
                                            resolve(timeStamp)
                                        }else{
                                            reject(APIErrorResponse.defaultError)
                                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                        }
                                    }catch{ reject(APIErrorResponse.ServerError) }
                                }else{
                                    reject(APIErrorResponse.ServerError)
                                }
                            }catch{ reject(APIErrorResponse.ServerError) }
                        }
                    }catch{ reject(APIErrorResponse.ServerError) }
                }); task.resume()
                
            }catch{ reject(APIErrorResponse.ServerError) }
        }
        }
    }
    
    //// MARK: -
    // MARK: - SERVICIO TIMESTAMP FIRMA FAD
    /// SERVICIO TIMESTAMP FIRMA FAD ECONsubanco
    /// - Parameters:
    ///   - delegate: delegat viewcontyroller a utilizar
    ///   - jsonservice: jsonservice json string con la informacion requerida para el servicio
    /// - Returns: description valor de retorno String cadena del timestamp
    func serviceTimestampFAD(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<String>{
        return Promise<String>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                
                                let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                let responseService = jsonDict["response"] as! NSMutableDictionary
                                var message: String = ""
                                if let serviceMessage = responseService["servicemessage"] as? String{
                                    message = serviceMessage
                                }
                                if let dataDict = jsonDict["data"] as? NSMutableDictionary{
                                    if let jsonTimestamp = dataDict["Json"] as? NSMutableDictionary{
                                        let jsonResolve = JSONSerializer.toJson(jsonTimestamp)
                                        self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "")
                                        resolve(jsonResolve)
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)")
                                        reject(APIErrorResponse.ServerError)
                                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                    }
                                }else{
                                    reject(APIErrorResponse.ServerError)
                                    ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                }
                            }else{ reject(APIErrorResponse.ServerError) }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
    /// SERVICIO PARA OBTENER IMAGEN DE FIRMA CURSIVA
    /// - Parameters:
    ///   - jsonservice: json nsstring con la informacion requerida para el servicio
    /// - Returns: una imagen codificada en base64
    func serviceFirmaCursivaFAD(jsonService: NSString) -> Promise<String> {
        return Promise<String> { resolve, reject in
            do {
                let request = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService: jsonService)
                
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity {
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                        reject(APIErrorResponse.ServerError)
                        return
                    }
                    do {
                        let doc = try AEXMLDocument(xml: data)
                        if let jsonString = doc["s:Envelope"]["s:Body"]["response"].value, jsonString != "" {
                            let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString)
                           
                            if jsonDecode != ""{
                                let jsonDict = try JSONSerializer.toDictionary(jsonDecode)
                                if let dataDict = jsonDict["data"] as? NSMutableDictionary {
                                    if let base64 = dataDict["Firma"] as? String {
                                        resolve(base64)
                                    } else {
                                        reject(APIErrorResponse.ServerError)
                                    }
                                } else {
                                    reject(APIErrorResponse.ServerError)
                                }
                            } else {
                                reject(APIErrorResponse.ServerError)
                            }
                        } else {
                            reject(APIErrorResponse.ServerError)
                        }
                    } catch {
                        reject(APIErrorResponse.ServerError)
                    }
                }.resume()
            } catch {
                reject(APIErrorResponse.ServerError)
            }
        }
    }
}


//// MARK: -
// MARK: - SERVICIOS CALCULADORA CONSUBANCO
public extension APIManager{
    /// SERVICIO CONFIGURACIÓN CALCULADORA CONSUBANCO
    /// - Parameters:
    ///   - delegate: delegate ViewController a utilizar
    ///   - jsonservice: jsonservice json string con la informacion requerida para el servicio
    /// - Returns: description valor de retorno Array de FEJsonCalculadora
    func serviceConfigurationCalc(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<FEJsonCalculadora>{
        return Promise<FEJsonCalculadora>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do {
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    var dataCalculadora: FEJsonCalculadora = FEJsonCalculadora()
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary{
                                        if let jsonCalc = dataDict["Json"] as? NSMutableDictionary{
                                            self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            let data = NSKeyedArchiver.archivedData(withRootObject: jsonCalc)
                                            let userDefaults = UserDefaults.standard
                                            userDefaults.set(data, forKey:"JSONCALC")
                                            userDefaults.synchronize()
                                            dataCalculadora = FEJsonCalculadora(dictionary: jsonCalc)
                                            resolve(dataCalculadora)
                                        }else{let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                            self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(APIErrorResponse.ServerError)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath); reject(APIErrorResponse.ServerError) }
                                    }else{ reject(APIErrorResponse.ServerError) }
                                }catch let error{ print("\(String(describing: error))");reject(APIErrorResponse.ServerError) }
                            }else{ reject(APIErrorResponse.ServerError) }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
                
            }
        }
    }
    
    /// SERVICIO COTIZACIONES CALCULADORA CONSUBANCO
    /// - Parameters:
    ///   - delegate: delegate ViewController a utilizar
    ///   - jsonservice: jsonservice json string con la informacion requerida para el servicio
    /// - Returns: description valor de retorno Array de FEQuotations
    func serviceQuotesCalc(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<[FEQuotations]>{
        
        return Promise<[FEQuotations]>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do {
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    var quotesArrayDict: [[FECotizaciones]] = [[FECotizaciones]]()
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    var message: String = ""
                                    if let serviceMessage = responseService["servicemessage"] as? String{
                                        message = serviceMessage
                                    }
                                    
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary{
                                        
                                        
                                        if let cotizacionesDict = dataDict["Cotizaciones"] as? Array<Dictionary<String, Any>>{
                                            self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            var newCot = [FEQuotations]()
                                            for (_, cot) in cotizacionesDict.enumerated(){
                                                newCot.append(FEQuotations(dictionary: cot as NSDictionary))
                                                var quotesArrayData: [FECotizaciones] = [FECotizaciones]()
                                                for coti in (cot["quotations"] as? Array<Dictionary<String, Any>>)!{
                                                    let quote: FECotizaciones = FECotizaciones()
                                                    quote.cat = coti["cat"] as! Double
                                                    quote.discountAmount = coti["discountAmount"] as! Double
                                                    quote.estimatedCommision = coti["estimatedCommision"] as! Int
                                                    quote.frequencyDescription = coti["frequencyDescription"] as! String
                                                    quote.interestRate = coti["interestRate"] as! Double
                                                    quote.plazo = coti["plazo"] as! Int
                                                    quote.priceGroupId = coti["priceGroupId"] as! String
                                                    quote.requestedAmount = coti["requestedAmount"] as! Double
                                                    quote.totalAmount = coti["totalAmount"] as! Double
                                                    quotesArrayData.append(quote)
                                                }
                                                quotesArrayDict.append(quotesArrayData)
                                            }
                                            resolve(newCot)
                                        }else{
                                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                            self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            reject(APIErrorResponse.ServerError)
                                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                            
                                        }
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
    /// SERVICIO PRELLENADO SOLICITUD COTIZACIÓN CONSUBANCO
    /// - Parameters:
    ///   - delegate: delegate ViewController a utilizar
    ///   - jsonservice: jsonservice json string con la informacion requerida para el servicio
    /// - Returns: description valor de retorno Object FEFormatoData
    func serviceQuotePrefill(delegate: Delegate?, jsonService jsonservice: NSString)-> Promise<FEFormatoData>{
        return Promise<FEFormatoData>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do{
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    var message: String = ""
                                    if let serviceMessage = responseService["servicemessage"] as? String{
                                        message = serviceMessage
                                    }
                                    
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary{
                                        if let prellenado = dataDict["Prellenado"] as? NSMutableDictionary{
                                            self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            let jsonDatos = prellenado["JsonDatos"] as? NSString
                                            prellenado["JsonDatos"] = jsonDatos
                                            let newFormat = FEFormatoData(dictionary: prellenado as NSDictionary)
                                            //                                            let SANDBOX_FORMATO = newFormat
                                            //                                             _ = ConfigurationManager.shared.utilities.save(info: SANDBOX_FORMATO.JsonDatos, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(SANDBOX_FORMATO.FlujoID)/\(SANDBOX_FORMATO.PIID)/\(SANDBOX_FORMATO.Guid)_\(SANDBOX_FORMATO.ExpID)_\(SANDBOX_FORMATO.TipoDocID)-\(SANDBOX_FORMATO.FlujoID)-\(SANDBOX_FORMATO.PIID).json")
                                            //
                                            //                                            // Saving object Format
                                            //                                            let json = JSONSerializer.toJson(SANDBOX_FORMATO)
                                            //                                            _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(SANDBOX_FORMATO.FlujoID)/\(SANDBOX_FORMATO.PIID)/\(SANDBOX_FORMATO.Guid)_\(SANDBOX_FORMATO.ExpID)_\(SANDBOX_FORMATO.TipoDocID)-\(SANDBOX_FORMATO.FlujoID)-\(SANDBOX_FORMATO.PIID).bor")
                                            resolve(newFormat)
                                        }else{
                                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                            self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            reject(APIErrorResponse.ServerError)
                                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                        }
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                    
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
    /// SERVICIO PARA NOTIFICACIONES PUSH
    /// - Parameters:
    ///   - delegate: delegate viewcontroller a utilizar
    ///   - tipoOp: Tipo de Operacion
    ///     2 Visto
    ///     3 Eliminar
    ///   - idPush: ID de la Push Notification
    /// - Returns: Valor de retorno Array FEMensajesPush
    func serviceNotifications(delegate: Delegate?, tipoOp : Int? = nil , idPush : [String]? = nil) -> Promise<[FEMensajesPush]>{
        return Promise<[FEMensajesPush]>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                
                var dictService: [String : Any] = [:]
                
                if tipoOp == nil && idPush == nil{
                    dictService = ["initialmethod":"ServiciosDigipro.ServicioSms.ObtieneMensajesPush", "assemblypath": "ServiciosDigipro.dll", "data": ["user": "\(ConfigurationManager.shared.usuarioUIAppDelegate.User)", "proyid": "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)"]] as [String : Any]
                }else{
                    dictService = ["initialmethod":"ServiciosDigipro.ServicioSms.EditaMensajesPush", "assemblypath": "ServiciosDigipro.dll", "data": ["user": "\(ConfigurationManager.shared.usuarioUIAppDelegate.User)", "proyid": "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)", "operacion": "\(tipoOp ?? 0)", "pushedit": idPush ?? []]] as [String : Any]
                }
                
                let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
                let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
                
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonString)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do{
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    var message: String = ""
                                    if let serviceMessage = responseService["servicemessage"] as? String{
                                        message = serviceMessage
                                    }
                                    
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary{
                                        if let mensajes = dataDict["Mensajes"] as? NSArray
                                        {
                                            self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            var msjPush : [FEMensajesPush] = []
                                            for mensaje in mensajes
                                            {   let newMsj = FEMensajesPush(dictionary: mensaje as! NSDictionary)
                                                msjPush.append(newMsj)
                                            }
                                            resolve(msjPush)
                                        }else{
                                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                            self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "Sin mensajes", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            reject(APIErrorResponse.defaultError)
                                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                        }
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "Sin mensajes", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                    
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
    /// SERVICIO PARA INCIDENCIAS DE SOLICITUDES ECONSUBANCO
    /// - Parameters:
    ///   - delegate: delegate ViewController a utilizar
    ///   - jsonservice: jsonservice json string con la informacion requerida para el servicio
    /// - Returns: description valor de retorno Array FEIncidencias
    func serviceIncidentDetail(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<[FEIncidencias]>{
        return Promise<[FEIncidencias]>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do{
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    var message: String = ""
                                    if let serviceMessage = responseService["servicemessage"] as? String{
                                        message = serviceMessage
                                    }
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary{
                                        if let incidenciasDict = dataDict["Incidencias"] as? Array<Dictionary<String, Any>>{
                                            self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            var incidencias = [FEIncidencias]()
                                            for (_, cot) in incidenciasDict.enumerated() {
                                                incidencias.append(FEIncidencias(dictionary: cot as NSDictionary))
                                            }
                                            resolve(incidencias)
                                        }
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
    // MARK: servicio para descuento cuando seleccion con descuento y tienen deshabilitado mismo descuento
    
    /// SERVICIO DESCUENTO REAL COTIZACIÓN ECONSUBANCO
    /// - Parameters:
    ///   - delegate: delegate ViewController a utilizar
    ///   - jsonservice: jsonservice json string con la informacion requerida para el servicio
    /// - Returns: description valor de retorno Object FEDiscount
    func servicegetDiscount(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<FEDiscount>{
        return Promise<FEDiscount>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do{
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    var message: String = ""
                                    if let serviceMessage = responseService["servicemessage"] as? String{
                                        message = serviceMessage
                                    }
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary {
                                        if let descuento = dataDict["Descuento"] as? Double {
                                            self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            let discount = FEDiscount()
                                            discount.Descuento = descuento
                                            if let tasa = dataDict["Tasa"] as? Double {
                                                discount.Tasa = tasa
                                            }
                                            if let montoTotal = dataDict["MontoTotal"] as? Double {
                                                discount.MontoTotal = montoTotal
                                            }
                                            resolve(discount)
                                        }
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
}

//// MARK: -
// MARK: - SERVICIOS PROLOGISTIK
public extension APIManager{
    /// SERVICIO PARA RECUPERAR LOS VIAJES PROLOGISTIK
    /// - Parameters:
    ///   - delegate: delegate ViewController a utilizar
    ///   - jsonservice: jsonservice json string con la informacion requerida para el servicio
    /// - Returns: description valor de retorno Array FEFormatoData
    func serviceCheckTrips(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<[FEFormatoData]>{
        
        return Promise<[FEFormatoData]>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            let jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if jsonString != nil && jsonString != ""{
                                do {
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary{
                                        if let formatosDict = dataDict["Formatos"] as? Array<Dictionary<String, Any>>{
                                            self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            var newFormat = [FEFormatoData]()
                                            for (_, fe) in formatosDict.enumerated(){
                                                newFormat.append(FEFormatoData(dictionary: fe as NSDictionary))
                                            }
                                            
                                            let SANDBOX_FORMATO = newFormat
                                            var counter = 0
                                            for incidencias in SANDBOX_FORMATO{
                                                counter += 1
                                                // Saving JSON DATA
                                                _ = ConfigurationManager.shared.utilities.save(info: incidencias.JsonDatos, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(incidencias.FlujoID)/\(incidencias.PIID)/\(incidencias.Guid)_\(incidencias.ExpID)_\(incidencias.TipoDocID)-\(incidencias.FlujoID)-\(incidencias.PIID).json")
                                                
                                                //let customJson = incidencias.JsonDatos
                                                //incidencias.JsonDatos = ""
                                                
                                                // Saving object Format
                                                let json = JSONSerializer.toJson(incidencias)
                                                _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(incidencias.FlujoID)/\(incidencias.PIID)/\(incidencias.Guid)_\(incidencias.ExpID)_\(incidencias.TipoDocID)-\(incidencias.FlujoID)-\(incidencias.PIID).bor")
                                            }
                                            
                                            resolve(newFormat)
                                        }else{
                                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                            self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "No se obtuvo ningun resultado", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            reject(APIErrorResponse.ServerError)
                                        }
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "No se obtuvo ningun resultado", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
        
    }
    
    
    /// SERVICIO PARA ACEPTAR VAJES PROLOGISTIK
    /// - Parameters:
    ///   - delegate: delegate ViewController a utilizar
    ///   - jsonservice: jsonservice json string con la informacion requerida para el servicio
    /// - Returns: description valor de retorno Bool
    func serviceAcceptTrips(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<APISuccessResponse>{
        return Promise<APISuccessResponse>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                do{
                    mutableRequest = try ConfigurationManager.shared.request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            let jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if jsonString != nil && jsonString != ""{
                                do {
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    let success = responseService["success"] as! Bool
                                    let serviceSuccess = responseService["servicesuccess"] as! Bool
                                    
                                    if success && serviceSuccess{
                                        self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        resolve(APISuccessResponse.success)
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(APIErrorResponse.ServerError)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
}

// MARK: SERVICIOS PARA VERIDAS
public extension APIManager {
    // MARK: ServiciosDigipro.ServiciosVeridaas.GetValidationId
    
    func getIdVeridasDocument(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<String> {
        
        return Promise<String>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                let request = Requests()
                do{
                    mutableRequest = try request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do{
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    var message: String = ""
                                    if let serviceMessage = responseService["servicemessage"] as? String{
                                        message = serviceMessage
                                    }
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary {
                                        self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        if let idVeridas = dataDict["idVal"] as? String {
                                            let defaults = UserDefaults.standard
                                            defaults.set(idVeridas, forKey: "currentIdVeridasDocument")
                                            print(idVeridas)
                                            resolve(idVeridas)
                                        }
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
    // MARK: ServiciosDigipro.ServiciosVeridaas.GetValidationId obverse
    // Subir anverso
    func uploadObverseVeridas(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<String> {
           return Promise<String>{ resolve, reject in
            let startDate = Date()
               DispatchQueue.global(qos: .background).async {
                   let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                   let request = Requests()
                   do{
                       mutableRequest = try request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                       let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                           guard data != nil && error == nil else{
                               ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                               reject(APIErrorResponse.ServerError); return
                           }
                           do{
                               let doc = try AEXMLDocument(xml: data!)
                               var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                               if jsonString != nil && jsonString != ""{
                                   do{
                                       let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                       
                                       let responseService = jsonDict["response"] as! NSMutableDictionary
                                       var message: String = ""
                                       if let serviceMessage = responseService["servicemessage"] as? String{
                                           message = serviceMessage
                                       }
                                       if let dataDict = jsonDict["data"] as? NSMutableDictionary {
                                        self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            resolve("todoOk")
                                       }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(String(describing: message))", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                           reject(APIErrorResponse.ServerError)
                                           ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                       }
                                   }catch{ reject(APIErrorResponse.ServerError) }
                               }
                           }catch{ reject(APIErrorResponse.ServerError) }
                       }); task.resume()
                   }catch{ reject(APIErrorResponse.ServerError) }
               }
           }
       }
    // Subir reverso
    func uploadReverseVeridas(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<String> {
              return Promise<String>{ resolve, reject in
                let startDate = Date()
                  DispatchQueue.global(qos: .background).async {
                      let mutableRequest: URLRequest
                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                        _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                    }
                      let request = Requests()
                      do{
                          mutableRequest = try request.soapGenericJSONRequest(jsonService:  jsonservice)
                        let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                          let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                              guard data != nil && error == nil else{
                                  ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                                  reject(APIErrorResponse.ServerError); return
                              }
                              do{
                                  let doc = try AEXMLDocument(xml: data!)
                                  var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                    let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                    jsonString = jsonDecode
                                }
                                  if jsonString != nil && jsonString != ""{
                                      do{
                                          let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                          
                                          let responseService = jsonDict["response"] as! NSMutableDictionary
                                          var message: String = ""
                                          if let serviceMessage = responseService["servicemessage"] as? String{
                                              message = serviceMessage
                                          }
                                          if let dataDict = jsonDict["data"] as? NSMutableDictionary {
                                            self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                            resolve("todoOk")
                                          }else{
                                            let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                            self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                              reject(APIErrorResponse.ServerError)
                                              ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                          }
                                      }catch{ reject(APIErrorResponse.ServerError) }
                                  }
                              }catch{ reject(APIErrorResponse.ServerError) }
                          }); task.resume()
                      }catch{ reject(APIErrorResponse.ServerError) }
                  }
              }
          }
    
    // generar ocr y recuperar imagenes recortadas
    func generateOCRAndGetCropImageFromDocumentVeridas(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<FEOcrVeridas>{
        return Promise<FEOcrVeridas>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                let request = Requests()
                do{
                    mutableRequest = try request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do{
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    var message: String = ""
                                    if let serviceMessage = responseService["servicemessage"] as? String{
                                        message = serviceMessage
                                    }
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary {
                                        self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        let jsonString = dataDict["data"] as? String
                                        let getCropImagejsonDict = try JSONSerializer.toDictionary(jsonString ?? "")
                                        let feOcrVeridas = FEOcrVeridas(dictionary: getCropImagejsonDict)
                                        resolve(feOcrVeridas)
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
    // MARK: Servicios que se utilizan en el elemento ocr de veridas
    
    func uploadBothImagesAnverseAndReverse(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<String> {
        return Promise<String>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                let request = Requests()
                do{
                    mutableRequest = try request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do{
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    var message: String = ""
                                    if let serviceMessage = responseService["servicemessage"] as? String{
                                        message = serviceMessage
                                    }
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary {
                                        self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        let idVal = dataDict["idVal"] as? String
                                        print(dataDict)
                                        resolve(idVal ?? "0780e033cc9849b4ac3e702313d80c2b")
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
    func getImagesAndOcrData(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<FEOcrVeridas>{
        return Promise<FEOcrVeridas>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                let request = Requests()
                do{
                    mutableRequest = try request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do{
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    var message: String = ""
                                    if let serviceMessage = responseService["servicemessage"] as? String{
                                        message = serviceMessage
                                    }
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary {
                                        self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        let jsonString = dataDict["data"] as? String
                                        let getCropImagejsonDict = try JSONSerializer.toDictionary(jsonString ?? "")
                                        let feOcrVeridas = FEOcrVeridas(dictionary: getCropImagejsonDict)
                                        resolve(feOcrVeridas)
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
    func sendCorrectionOcr(delegate: Delegate?, jsonService jsonservice: NSString) -> Promise<String> {
        return Promise<String>{ resolve, reject in
            let startDate = Date()
            DispatchQueue.global(qos: .background).async {
                let mutableRequest: URLRequest
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                    _ = self.DGSDKRestoreTokenSecurityV2(delegate: delegate)
                }
                let request = Requests()
                do{
                    mutableRequest = try request.soapGenericJSONRequest(jsonService:  jsonservice)
                    let serviceName = mutableRequest.allHTTPHeaderFields?["SOAPAction"] ?? ""
                    let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                        guard data != nil && error == nil else{
                            ConfigurationManager.shared.utilities.writeLogger("\(String(describing: error))", .error)
                            reject(APIErrorResponse.ServerError); return
                        }
                        do{
                            let doc = try AEXMLDocument(xml: data!)
                            var jsonString = doc["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
                            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                                let jsonDecode = self.getReturnObject(aexmlD: doc, r: jsonString ?? "")
                                jsonString = jsonDecode
                            }
                            if jsonString != nil && jsonString != ""{
                                do{
                                    let jsonDict = try JSONSerializer.toDictionary(jsonString!)
                                    let responseService = jsonDict["response"] as! NSMutableDictionary
                                    var message: String = ""
                                    if let serviceMessage = responseService["servicemessage"] as? String{
                                        message = serviceMessage
                                    }
                                    if let dataDict = jsonDict["data"] as? NSMutableDictionary {
                                        self.logsService(log: true, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: "", error: "", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        resolve("todoOK")
                                    }else{
                                        let lineError = ConfigurationManager.shared.utilities.logMessage("Line Error")
                                        self.logsService(log: false, responseData: doc, servicio: serviceName, requestData: ConfigurationManager.shared.requestData, startDate: startDate, endDate: Date(), lineError: lineError, error: "\(message)", ConfigurationManager.shared.initialmethod, ConfigurationManager.shared.assemblypath)
                                        reject(APIErrorResponse.ServerError)
                                        ConfigurationManager.shared.utilities.writeLogger("\(String(describing: message))", .error)
                                    }
                                }catch{ reject(APIErrorResponse.ServerError) }
                            }
                        }catch{ reject(APIErrorResponse.ServerError) }
                    }); task.resume()
                }catch{ reject(APIErrorResponse.ServerError) }
            }
        }
    }
    
}

