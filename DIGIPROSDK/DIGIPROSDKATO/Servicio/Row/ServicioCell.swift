import Foundation

import Eureka

public class ServicioCell: Cell<String>, CellType, APIDelegate {
    
    var sdkAPI : APIManager<ServicioCell>?
    var actionDelegate: FormViewController?
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    
    // PRIVATE
    public var elemento: Elemento?
    public var atributos: Atributos_servicio?
        
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        (row as? ServicioRow)?.presentationMode = nil
    }
    
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    
    public func didSetCompareFaces(_ compareFaces: CompareFacesResult, _ mensaje: String){
        DispatchQueue.main.async {
            let parametrosSalida = self.atributos?.parametrossalida
            let formulaResult = CompareFacesResponse(json: parametrosSalida)
            if formulaResult.score != ""{
                self.settingFormula(formulaResult.score, compareFaces.RespuestaServicio)
            }
            var message = mensaje
            if message == ""{
                message = "not_service".langlocalized()
            }
            if formulaResult.mensaje != ""{
                var mensajeMod = formulaResult.mensaje.replacingOccurrences(of: "Score: ", with: "")
                mensajeMod = mensajeMod.replacingOccurrences(of: "score: ", with: "")
                mensajeMod = mensajeMod.replacingOccurrences(of: "Score:", with: "")
                mensajeMod = mensajeMod.replacingOccurrences(of: "score:", with: "")
                self.settingFormula(formulaResult.mensaje, mensajeMod)
            }
            if formulaResult.accioncorrecta != ""{
                self.settingFormula(formulaResult.accioncorrecta, message)
            }
            
            self.formDelegate?.setStatusBarNotificationBanner("not_service".langlocalized(), .success, .bottom)
        }
    }
    
    public func didSetCompareFacesError(_ compareFaces: CompareFacesResult?, _ mensaje: String){
        DispatchQueue.main.async {
            let parametrosSalida = self.atributos?.parametrossalida
            let formulaResult = CompareFacesResponse(json: parametrosSalida)
            var message = mensaje
            if message == ""{
                message = "not_service_error".langlocalized()
            }
            if formulaResult.accioncorrecta != ""{
                self.settingFormula(formulaResult.accioncorrecta, message)
            }
            self.formDelegate?.setStatusBarNotificationBanner("not_service_error".langlocalized(), .success, .bottom)
        }
    }
    
    public func didSetServicioFolio(_ folio: FolioAutomaticoResult, _ mensaje: String){
        DispatchQueue.main.async {
            let parametrosSalida = self.atributos?.parametrossalida
            let formulaResult = FolioResponse(json: parametrosSalida)
            
            if formulaResult.folio != ""{
                if folio.RespuestaServicio != ""{
                    self.settingFormula(formulaResult.folio, folio.RespuestaServicio)
                }else if folio.Item1 != ""{
                    self.settingFormula(formulaResult.folio, folio.Item1)
                }
                
            }
            var message = mensaje
            if message == ""{
                message = "not_service".langlocalized()
            }
            if formulaResult.mensaje != ""{
                self.settingFormula(formulaResult.mensaje, message)
            }
            if formulaResult.accioncorrecta != ""{
                self.settingFormula(formulaResult.accioncorrecta, message)
            }
            self.formDelegate?.setStatusBarNotificationBanner("not_service".langlocalized(), .success, .bottom)
        }
    }

    public func didSetServicioSepomex(_ dict: NSDictionary, _ mensaje: String){
        DispatchQueue.main.async {
            let parametrosSalida = self.atributos?.parametrossalida
            let sepomexResult = SepomexResponse(json: parametrosSalida)

            let del = (dict["Item1"] as? String ?? "")
            if del != ""{
                self.settingFormula(sepomexResult.delegacion, del)
            }
            let col = (dict["Item2"] as? String ?? "")
            if col != ""{
                self.settingFormula(sepomexResult.estado, col)
            }
            let est = (dict["Item3"] as? String ?? "")
            if est != ""{
                self.settingFormula(sepomexResult.colonias, est)
            }

            var message = mensaje
            if message == ""{
                message = "not_service".langlocalized()
            }
            if sepomexResult.mensaje != ""{
                self.settingFormula(sepomexResult.mensaje, message)
            }
            if sepomexResult.accioncorrecta != ""{
                self.settingFormula(sepomexResult.accioncorrecta, message)
            }
            self.formDelegate?.setStatusBarNotificationBanner("not_service".langlocalized(), .success, .bottom)
        }
    }

    public func didSetServicioFolioError(_ folio: FolioAutomaticoResult?, _ mensaje: String){
        DispatchQueue.main.async {
            let parametrosSalida = self.atributos?.parametrossalida
            let formulaResult = FolioResponse(json: parametrosSalida)
            var message = mensaje
            if message == ""{
                message = "not_service_error".langlocalized()
            }
            if formulaResult.accioncorrecta != ""{
                self.settingFormula(formulaResult.accioncorrecta, message)
            }
            self.formDelegate?.setStatusBarNotificationBanner("not_service_error".langlocalized(), .danger, .bottom)
        }
        
    }
    
    public func didSetServicioSepomexError(_ dict: NSDictionary?, _ mensaje: String){
        DispatchQueue.main.async {
            let parametrosSalida = self.atributos?.parametrossalida
            let formulaResult = SepomexResponse(json: parametrosSalida)
            var message = mensaje
            if message == ""{
                message = "not_service_error".langlocalized()
            }
            if formulaResult.accioncorrecta != ""{
                self.settingFormula(formulaResult.accioncorrecta, message)
            }
            self.formDelegate?.setStatusBarNotificationBanner("\(mensaje)", .danger, .bottom)
        }
        
    }
    
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_servicio
        actionDelegate = self.formDelegate?.getFormViewControllerDelegate()
    }
    
    public func setInstanceCompareFaces(_ compareFaces: CompareFacesJson){
        
        self.formDelegate?.setStatusBarNotificationBanner("not_service_init".langlocalized(), .success, .bottom)
        let result = self.formDelegate?.getImagesFromElement(compareFaces)
        if result == nil{
            self.formDelegate?.setStatusBarNotificationBanner("not_service_config".langlocalized(), .danger, .bottom)
        }else{
            sdkAPI?.compareFacesPromise(delegate: self, compareFaces: result!)
                .then{ _ in
                }.catch{ _ in }
        }
        
    }
    
    public func setInstanceOcrIne(_ object: OcrIneObject){
        let controller = OCRVC(nibName: "WkvQfEJcVZMMkqD", bundle: Cnstnt.Path.framework, service: 1)
        controller.atributos = self.atributos
        controller.row = self.row
        controller.objectOCRINE = object
        (row as? ServicioRow)?.presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return controller
            }, onDismiss: { [weak self] vc in
                vc.dismiss(animated: true)
                self?.evaluateFormulaOcrIne(controller.objectOCRINE!)
        })
        (row as? ServicioRow)?.didSelect()
    }
    
    public func setInstanceOcrCfe(_ object: OcrCfeObject){
        let controller = OCRVC(nibName: "WkvQfEJcVZMMkqD", bundle: Cnstnt.Path.framework, service: 3)
        controller.atributos = self.atributos
        controller.row = self.row
        controller.objectOCRCfe = object
        (row as? ServicioRow)?.presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return controller
            }, onDismiss: { [weak self] vc in
                vc.dismiss(animated: true)
                self?.evaluateFormulaOcrCfe(controller.objectOCRCfe!)
        })
        (row as? ServicioRow)?.didSelect()
    }
    
    public func setInstanceOcrPasaporte(_ object: OcrPasaporteObject){
        let controller = OCRVC(nibName: "WkvQfEJcVZMMkqD", bundle: Cnstnt.Path.framework, service: 4)
        controller.atributos = self.atributos
        controller.row = self.row
        controller.objectOCRPasaporte = object
        (row as? ServicioRow)?.presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return controller
            }, onDismiss: { [weak self] vc in
                vc.dismiss(animated: true)
                self?.evaluateFormulaOcrPasaporte(controller.objectOCRPasaporte!)
        })
        (row as? ServicioRow)?.didSelect()
    }
    
    public func setSOAPFolio(_ service: String, _ parametrosEntrada: String){
        
        self.formDelegate?.setStatusBarNotificationBanner("not_service_init".langlocalized(), .success, .bottom)
        
        let atributos: [String: Any]
        if let data = parametrosEntrada.data(using: .utf8) {
            do {
                atributos = (try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
                let folio = FolioAutomaticoResult()
                folio.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
                folio.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
                folio.ExpId = ConfigurationManager.shared.plantillaDataUIAppDelegate.ExpID
                folio.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
                folio.Proveedor = atributos["proveedor"] as! String
                folio.Provedor = atributos["proveedor"] as! String
                
                folio.GrupoId = ConfigurationManager.shared.usuarioUIAppDelegate.GrupoAdminID
                if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
//                    self.sdkAPI?.DGSDKRestoreTokenSecurity(delegate: self)
//                        .then({ response in
//                        debugPrint("REGENERA TOKEN: \(response)")
//                        self.sdkAPI?.soapFolioPromise(delegate: self, folio: folio)
//                            .then{ _ in
//                            }.catch{ _ in }
//                    }).catch({ error in
//                        debugPrint("ERROR AL REGENERAR TOKEN")
//                        self.sdkAPI?.soapFolioPromise(delegate: self, folio: folio)
//                            .then{ _ in
//                            }.catch{ _ in }
//                    })
                }else{
                    self.sdkAPI?.soapFolioPromise(delegate: self, folio: folio)
                    .then{ _ in
                    }.catch{ _ in }
                }
            } catch { }
        }
        
    }
    
    
    public func setSepomex(_ sepomex: SepomexJson){
        
        self.formDelegate?.setStatusBarNotificationBanner("not_service_init".langlocalized(), .success, .bottom)
        let result =  self.formDelegate?.getColoniasElement(sepomex)
        
        if result == nil{
            self.formDelegate?.setStatusBarNotificationBanner("not_service_config".langlocalized(), .danger, .bottom)
        }else{
            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
//                self.sdkAPI?.DGSDKRestoreTokenSecurity(delegate: self)
//                    .then({ response in
//                    debugPrint("REGENERA TOKEN: \(response)")
//                    self.sdkAPI?.sepomexPromise(delegate: self, sepomex: result!)
//                        .then{ _ in }.catch{ _ in }
//                }).catch({ error in
//                    debugPrint("ERROR AL REGENERAR TOKEN")
//                    self.sdkAPI?.sepomexPromise(delegate: self, sepomex: result!)
//                        .then{ _ in }.catch{ _ in }
//                })
            }else{
                self.sdkAPI?.sepomexPromise(delegate: self, sepomex: result!)
                    .then{ _ in }.catch{ _ in }
            }
        }
        
        
        
    }
    
    public func evaluateFormulaOcrPasaporte(_ obj: OcrPasaporteObject){
        let parametrosSalida = atributos?.parametrossalida
        let atributosSalida = OcrPasaporteFormulas(json: parametrosSalida)
        if atributosSalida.accioncorrecta != ""{ settingFormula(atributosSalida.accioncorrecta, "not_data_valid".langlocalized()) }
        if atributosSalida.accionincorrecta != ""{ settingFormula(atributosSalida.accionincorrecta, "not_data_invalid".langlocalized()) }
    }
    
    public func evaluateFormulaOcrCfe(_ obj: OcrCfeObject){
        let parametrosSalida = atributos?.parametrossalida
        let atributosSalida = OcrCfeFormulas(json: parametrosSalida)
        if atributosSalida.nombre != "" && obj.nombre != ""{ settingFormula(atributosSalida.nombre, obj.nombre) }
        if atributosSalida.calle != "" && obj.calle != ""{ settingFormula(atributosSalida.calle, obj.calle) }
        if atributosSalida.ciudad != "" && obj.ciudad != ""{ settingFormula(atributosSalida.ciudad, obj.ciudad) }
        if atributosSalida.delegacion != "" && obj.delegacion != ""{ settingFormula(atributosSalida.delegacion, obj.delegacion) }
        if atributosSalida.mensaje != ""{ settingFormula(atributosSalida.mensaje, "") }
        if atributosSalida.accioncorrecta != ""{ settingFormula(atributosSalida.accioncorrecta, "not_data_valid".langlocalized()) }
        if atributosSalida.accionincorrecta != ""{ settingFormula(atributosSalida.accionincorrecta, "not_data_invalid".langlocalized()) }
    }
    
    public func evaluateFormulaOcrIne(_ obj: OcrIneObject){
        let parametrosSalida = atributos?.parametrossalida
        let atributosSalida = OcrIneFormulas(json: parametrosSalida)
        if atributosSalida.nombre != "" && obj.nombre != ""{ settingFormula(atributosSalida.nombre, obj.nombre) }
        if atributosSalida.apellidopaterno != "" && obj.aPaterno != ""{ settingFormula(atributosSalida.apellidopaterno, obj.aPaterno) }
        if atributosSalida.apellidomaterno != "" && obj.aMaterno != ""{ settingFormula(atributosSalida.apellidomaterno, obj.aMaterno) }
        if atributosSalida.curp != "" && obj.curp != ""{
            settingFormula(atributosSalida.curp, obj.curp)
            if atributosSalida.rfc != ""{
                let rfc = obj.curp.regexMatches(regex: "^[A-Z]{1}[AEIOU]{1}[A-Z]{2}[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])[A-Z]{2}[0-9]{1}|[A-Z]{1}[AEIOU]{1}[A-Z]{2}[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])")
                if rfc.count > 0{ settingFormula(atributosSalida.rfc, rfc[0]) }
            }
        }
        if atributosSalida.fechanacimiento != "" && obj.fecha != ""{ settingFormula(atributosSalida.fechanacimiento, obj.fecha) }
        if atributosSalida.fecha != "" && obj.fecha != ""{ settingFormula(atributosSalida.fecha, obj.fecha) }
        if atributosSalida.calle != "" && obj.calle != ""{ settingFormula(atributosSalida.calle, obj.calle) }
        if atributosSalida.colonia != "" && obj.colonia != ""{ settingFormula(atributosSalida.colonia, obj.colonia) }
        if atributosSalida.delegacion != "" && obj.delegacion != ""{ settingFormula(atributosSalida.delegacion, obj.delegacion) }
        if atributosSalida.cp != "" && obj.cP != ""{ settingFormula(atributosSalida.cp, obj.cP) }
        if atributosSalida.seccion != "" && obj.seccion != ""{ settingFormula(atributosSalida.seccion, obj.seccion) }
        if atributosSalida.claveelector != "" && obj.claveElector != ""{ settingFormula(atributosSalida.claveelector, obj.claveElector) }
        if atributosSalida.vigencia != "" && obj.vigencia != ""{ settingFormula(atributosSalida.vigencia, obj.vigencia) }
        if atributosSalida.estado != "" && obj.estado != ""{ settingFormula(atributosSalida.estado, obj.estado) }
        if atributosSalida.cic != "" && obj.cic != ""{ settingFormula(atributosSalida.cic, obj.cic) }
        if atributosSalida.numeroocr != "" && obj.ocr != ""{ settingFormula(atributosSalida.numeroocr, obj.ocr) }
        if atributosSalida.mensaje != ""{ settingFormula(atributosSalida.mensaje, "") }
        if atributosSalida.accioncorrecta != ""{ settingFormula(atributosSalida.accioncorrecta, "not_data_valid".langlocalized()) }
        if atributosSalida.accionincorrecta != ""{ settingFormula(atributosSalida.accionincorrecta, "not_data_invalid".langlocalized()) }
        if atributosSalida.ciudad != "" && obj.ciudad != ""{ settingFormula(atributosSalida.ciudad, obj.ciudad) }
        if atributosSalida.reposicion != "" && obj.emision != ""{
            let emision = obj.emision.regexMatches(regex: "([0-9]{2})")
            if emision.count > 0{ settingFormula(atributosSalida.reposicion, emision[0]) }
        }
    }
    
    func settingFormula(_ str: String, _ ocrStr: String){
        
        var formula: [NSDictionary]?
        if let dataFromString = str.data(using: .utf8, allowLossyConversion: false) {
            do{
                formula = try JSONSerialization.jsonObject(with: dataFromString, options: []) as? [NSDictionary]
                if formula?.count == 0{ return }
                if formula?.count == 1{
                    let f1:NSDictionary = [ "value": ".", "type": "point" ]
                    let f2:NSDictionary = [ "value": "mensaje", "type": "propiedadvariable" ]
                    formula?.append(f1)
                    formula?.append(f2)
                }
                let f1:NSDictionary = [ "value": "=", "type": "equal" ]
                let f2:NSDictionary = [ "value": "\(ocrStr)", "type": "character" ]
                formula?.append(f1)
                formula?.append(f2)
                if let theJSONData = try? JSONSerialization.data(withJSONObject: formula!, options: []) {
                    let theJSONText = String(data: theJSONData, encoding: .ascii)
                    _ = self.formDelegate?.recursiveTokenFormula(theJSONText, nil, "asignacion", false)
                }
            }catch{ formula = [NSDictionary]() }
        }else{ formula = [NSDictionary]() }
    }
    
    func gettingDictionary(_ str: String) -> (NSDictionary, NSDictionary){
        let equal:NSDictionary = [
            "value": "=",
            "type": "equal"
        ]
        let value:NSDictionary = [
            "value": "\(str)",
            "type": "character"
        ]
        return (equal, value)
    }
    
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        sdkAPI = APIManager<ServicioCell>()
        sdkAPI?.delegate = self
        height = {return 1}
    }
    
    @objc public func setAyuda(_ sender: Any) { }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
    
    override open func update() {
        super.update()
    }
    
}

extension ServicioCell: ObjectFormDelegate{
    public func setEstadistica() { }
    public func setEstadisticaV2(){ }
    
    public func setTextStyle(_ style: String) { }
    
    public func setDecoration(_ decor: String) { }
    
    public func setAlignment(_ align: String) { }
    
    public func setVariableHeight(Height h: CGFloat) { }
    
    public func setTitleText(_ text: String) { }
    
    public func setSubtitleText(_ text: String) { }
    
    public func setPlaceholder(_ text: String) { }
    
    public func setInfo() { }
    
    public func setHeightFromTitles() { }
    
    public func toogleToolTip(_ help: String) { }
    
    public func setMessage(_ string: String, _ state: enumErrorType) { }
    
    public func initRules() { }
    
    public func setMinMax() { }
    
    public func setExpresionRegular() { }
    
    public func setOcultarTitulo(_ bool: Bool) { }
    
    public func setOcultarSubtitulo(_ bool: Bool) { }
    
    public func setHabilitado(_ bool: Bool) { }
    
    public func setEdited(v: String) { }
    
    public func setEdited(v: String, isRobot: Bool) { }
    
    public func setVisible(_ bool: Bool) { }
    
    public func setRequerido(_ bool: Bool) { }
    
    public func resetValidation() { }
    
    public func updateIfIsValid(isDefault: Bool = false) { }
    
    public func triggerEvent(_ action: String) { }
    
    public func setMathematics(_ bool: Bool, _ id: String) { }
    
    // MARK: Excecution for RulesOnProperties
    public func setRulesOnProperties(){
        triggerRulesOnProperties("")
    }
    // MARK: Rules on properties
    public func triggerRulesOnProperties(_ action: String){
        if rulesOnProperties.count == 0{ return }
        for rule in rulesOnProperties{
            if rule.vrb == action{
                _ = self.formDelegate?.obtainRules(rString: rule.xml.name, eString: row.tag, vString: rule.vrb, forced: false, override: false)
            }
        }
    }
    
    // MARK: Excecution for RulesOnChange
    public func setRulesOnChange(){ }
    
    // MARK: Rules on change
    public func triggerRulesOnChange(_ action: String?){
        if rulesOnChange.count == 0{ return }
        for rule in rulesOnChange{
            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: action, forced: false, override: false)
        }
    }
}

extension ServicioCell: AttachedFormDelegate{
    public func didSetLocalAnexo(_ feAnexo: FEAnexoData) { }
    
    public func setAnexoOption(_ anexo: FEAnexoData) { }
    
    public func setAttributesToController() { }
    
    public func setPreview(_ sender: Any) { }
    
    public func setDownloadAnexo(_ sender: Any) { }
    
    public func setAnexo(_ anexo: FEAnexoData) { }
}
