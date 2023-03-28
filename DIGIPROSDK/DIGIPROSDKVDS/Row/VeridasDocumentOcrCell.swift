//
//  VeridasDocumentOcrCell.swift
//  DIGIPROSDKATO
//
//  Created by Carlos Mendez Flores on 24/11/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Eureka
#if canImport(VDDocumentCapture)
import VDDocumentCapture
#endif

open class VeridasDocumentOcrCell: Cell<String>, CellType{
    
    var sdkAPI : APIManager<VeridasDocumentOcrCell>?
    
    @IBOutlet weak var ocrButtonOutlet: UIButton!
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var lblMoreInfo: UILabel!
    @IBOutlet weak var lblRequired: UILabel!
    @IBOutlet weak var viewValidation: UIView!
    @IBOutlet weak var bgHabilitado: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var btnInfo: UIButton!
    
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var sects: [(id:String, attributes:Atributos_OCR, elements:[String])] = [(id:String, attributes:Atributos_OCR, elements:[String])]()
    
    // PRIVATE
    public var elemento = Elemento()
    public var atributos: Atributos_OCR?
    public var atributosOCR: OcrIneObject = OcrIneObject()
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    
    // SIMPLE VARIABLES
    public var genericRow: VeridasDocumentOcrRow! {return row as? VeridasDocumentOcrRow}
    public var isSectionHeader: Bool = false
    public var isTab: Bool = false
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func setup() {
        super.setup()
        selectionStyle = .none
    }
    
    override open func update() {
        super.update()
    }
    
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_OCR
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        if atributos?.titulo ?? "" == ""{ setOcultarTitulo(true) }else{ setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        setHeightFromTitles()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        setAlignment(atributos?.alineadotexto ?? "")
        setDecoration(atributos?.decoraciontexto ?? "")
        setTextStyle(atributos?.estilotexto ?? "")
        setInfo()
        
        let titOCR = self.atributos?.textoocr ?? "OCR"
        self.ocrButtonOutlet = self.formDelegate?.configButton(tipo: "", btnStyle: self.ocrButtonOutlet, nameIcono: "", titulo: "  \(titOCR)  ", colorFondo: atributos?.colorbotonocr ?? "#1E88E5", colorTxt: self.atributos?.colorbotonocrtexto ?? "#ffffff")
        let titRedoOCR = self.atributos?.textocorreccion ?? "OCR"
        self.editButtonOutlet = self.formDelegate?.configButton(tipo: "", btnStyle: self.editButtonOutlet, nameIcono: "", titulo: "  \(titRedoOCR)  ", colorFondo: atributos?.colorbotonocr ?? "#1E88E5", colorTxt: self.atributos?.colorbotonocrtexto ?? "#ffffff")
        self.editButtonOutlet.isHidden = true
        
    }
    
    
    @IBAction func OcrCall(_ sender: UIButton) {
        callOcrFlowVeridas()
    }
    
    @IBAction func CorrectionOcr(_ sender: UIButton) {
        self.editButtonOutlet.isHidden = true
        let elemData = self.formDelegate!.getElementService(self.atributos?.prefijo ?? "", true)
        var correctedInfoOcer: [FECorrectedOCR] = []
        for elem in elemData {
            let correctItem = FECorrectedOCR()
            correctItem.name = elem.value as? String ?? "#"
            correctItem.confirmedText = elem.key
            correctedInfoOcer.append(correctItem)
        }
        
        for elemA in elemData{
            for elemB in FormularioUtilities.shared.elementsInPlantilla{
                if elemB.id == elemA.key {
                    for value in correctedInfoOcer {
                        if value.name == elemB.element?.validacion.idunico.replacingOccurrences(of: "ocrpre_", with: "")  {
                            value.confirmedText = elemB.element?.validacion.valor ?? ""
                        }
                    }
                }
            }
        }
        
        confirmOcr(correctInfo: correctedInfoOcer)
    }
    
    func confirmOcr(correctInfo: [FECorrectedOCR]) {
        self.sdkAPI = APIManager<VeridasDocumentOcrCell>()
        self.sdkAPI?.delegate = self
        let defaults = UserDefaults.standard
        let dictService = ["initialmethod":"ServiciosDigipro.ServicioVeridas.ConfirmOCR", "assemblypath": "ServiciosDigipro.dll", "data": ["id": defaults.string(forKey: "idVeridas") ?? "", "correctedOCR":  correctInfo.toJsonString()]] as [String : Any]
        ConfigurationManager.shared.assemblypath = "ServiciosDigipro.dll"
        ConfigurationManager.shared.initialmethod = "ServiciosDigipro.ServicioVeridas.ConfirmOCR"
        let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        self.sdkAPI?.sendCorrectionOcr(delegate: self, jsonService: jsonString)
            .then{response in
                print(response)
            }
            .catch{error in
                let rightView = UIImageView(image: UIImage(named: "warning_sign", in: Cnstnt.Path.framework, compatibleWith: nil))
                let bannerNew = NotificationBanner(title: "", subtitle: error.localizedDescription, leftView: nil, rightView: rightView, style: .danger, colors: nil)
                bannerNew.show()
            }
    }
    
    private func bannerWillAppear(withText text: String) {
        let banner = NotificationBanner(title: text, subtitle: nil, leftView: nil, rightView: nil, style: .info, colors: nil, texts: nil)
        banner.show()
    }
    
    // Boton prueba de vida, atributos?.formasvalidacion == "selfie"
    // Validar documentos con prueba de vida == "video"
    // Confirmar con veridas atributos?.formasvalidacion == "confirm"
    // Cancelar proceso atributos?.formasvalidacion == "cancel"
    // Validar datos PEP-AML
    // atributos?.formasvalidacion == "pepaml"
    
    public func callOcrFlowVeridas() {
        if atributos?.formasvalidacion == "documentos" {
            let controller = VeridasViewController()
            controller.delegateVeridas = self
            let presenter = Presentr(presentationType: .fullScreen)
            self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
            
        } else if atributos?.formasvalidacion == "selfie"{
            if VeridasValidation.token == ""{
                bannerWillAppear(withText: "No se ha iniciado el proceso de validación de documentos, favor de iniciarlo.")
            } else {
                let controller = VeridasSelfieViewController(token: VeridasValidation.token)
                controller.delegateSelfieVeridas = self
                let presenter = Presentr(presentationType: .fullScreen)
                self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
            }
        } else if atributos?.formasvalidacion == "video" {
            if VeridasValidation.token == "" {
                bannerWillAppear(withText: "No se ha iniciado el proceso de validación de documentos, favor de iniciarlo.")
            } else {
                let controller = VeridasVideoViewController(token: VeridasValidation.token, docType: VeridasValidation.docType)
                controller.delegateVideoVeridas = self
                let presenter = Presentr(presentationType: .fullScreen)
                self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
            }
        } else if atributos?.formasvalidacion == "confirm" {
            if VeridasValidation.token == ""{
                bannerWillAppear(withText: "No se ha iniciado el proceso de validación de documentos, favor de iniciarlo.")
            } else {
                let controller = VeridasConfirmViewController(token: VeridasValidation.token)
                controller.delegateConfirmVeridas = self
                let presenter = Presentr(presentationType: .fullScreen)
                self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
            }
        } else if atributos?.formasvalidacion == "cancel" {
            if VeridasValidation.token == ""{
                bannerWillAppear(withText: "No se ha iniciado el proceso de validación de documentos, favor de iniciarlo.")
            } else {
                let controller = VeridasCancelViewController(token: VeridasValidation.token)
                controller.delegateCancelVeridas = self
                let presenter = Presentr(presentationType: .fullScreen)
                self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
            }
        }  else if atributos?.formasvalidacion == "pepaml" {
            bannerWillAppear(withText: "Módulo en contrucción")
        } else {
            bannerWillAppear(withText: "Módulo en contrucción")
        }
    }
}

extension VeridasDocumentOcrCell: BackVeridasActionDelegate {
    public func processFinished(incomeData: FEOcrVeridas, pathReverse: String, pathObverse: String, _ token: String, _ doctype: String) {
        print("Token recibido \(token)")
        print("Tipo de documento recibido \(doctype)")
        VeridasValidation.token = token
        VeridasValidation.docType = doctype
        self.atributosOCR = OcrIneObject()
        self.editButtonOutlet.isHidden = true
        //self.editButtonOutlet.setTitle("Corregir Ocr", for: .normal)

        let elemData = atributos?.mappingocr as! [String:Any]
        
        for elemA in elemData {
            let values = incomeData.value(forKey: elemA.key)
            _ = self.formDelegate?.resolveValor(elemA.value as? String ?? "", "asignacion", values as? String ?? "", "")
        }
        
        let tokenStr = atributos?.tokenshared ?? ""
        _ = self.formDelegate?.resolveValor(tokenStr, "asignacion", token, "")
                
        for score in atributos?.mappingscore as! [String : Any] {
            let values = incomeData.value(forKey: score.key)
            _ = self.formDelegate?.resolveValor(score.value as? String ?? "", "asignacion", values as? String ?? "", "")
        }
        
        let imagenAnversa = atributos?.imagenanverso ?? ""
        _ = self.formDelegate?.resolveValor(imagenAnversa, "asignacion", pathObverse, "")
        
        let imagenReversa = atributos?.imagenreverso ?? ""
        _ = self.formDelegate?.resolveValor(imagenReversa, "asignacion", pathReverse, "")
    }
    
    
    public func vdOutOfTime(_ message: String, seconds: Int32) {
        formDelegate?.setStatusBarNotificationBanner(message, .warning, .bottom)
    }
    
    public func failureToken(_ message: String) {
        formDelegate?.setStatusBarNotificationBanner(message, .danger, .bottom)
    }
    
    public func failureUploadDocuments(_ message: String) {
        formDelegate?.setStatusBarNotificationBanner(message, .danger, .bottom)
    }
    
    public func failureGetValidation(_ message: String) {
        formDelegate?.setStatusBarNotificationBanner(message, .danger, .bottom)
    }
    
    public func successfulProcess(title: String) {
        formDelegate?.setStatusBarNotificationBanner(title, .success, .bottom)
    }
}

extension VeridasDocumentOcrCell: BackVeridasSelfieActionDelegate {
    
    public func processSelfieFinished(incomeData: FEOcrVeridas, pathCroppedSelfie: String, pathVideoSelfie: String) {
        self.atributosOCR = OcrIneObject()
        self.editButtonOutlet.isHidden = true // No conocemos esta funcionalidad, mientras lo dejamos oculto
        
        let imagenSelfie = atributos?.imagenselfie ?? ""
        _ = self.formDelegate?.resolveValor(imagenSelfie, "asignacion", pathCroppedSelfie, "")
        
        let videoSelfie = atributos?.videoselfie ?? ""
        _ = self.formDelegate?.resolveValor(videoSelfie, "asignacion", pathVideoSelfie, "")
        
        for score in atributos?.mappingscore as! [String : Any] {
            let values = incomeData.value(forKey: score.key)
            _ = self.formDelegate?.resolveValor(score.value as? String ?? "", "asignacion", values as? String ?? "", "")
        }
    }
    
    public func failureUploadSelfie(_ message: String) {
        formDelegate?.setStatusBarNotificationBanner(message, .danger, .bottom)
    }
    
    public func failureSelfieGetValidation(_ message: String) {
        formDelegate?.setStatusBarNotificationBanner(message, .danger, .bottom)
    }
    
    public func successfulSelfieProcess(title: String) {
        formDelegate?.setStatusBarNotificationBanner(title, .success, .bottom)
    }
    
    public func failureUpdateChallenge(_ message: String) {
        formDelegate?.setStatusBarNotificationBanner(message, .danger, .bottom)
    }
}

// MARK: BackVideoVeridasActionDelegate
extension VeridasDocumentOcrCell: BackVideoVeridasActionDelegate {
    func successfulProcess(dataOCR incomeData: FEOcrVeridas, path videoPath: String, withToken token: String, message text: String) {
        
        for elemA in atributos?.mappingocr as! [String:Any] {
            let values = incomeData.value(forKey: elemA.key)
            _ = self.formDelegate?.resolveValor(elemA.value as? String ?? "", "asignacion", values as? String ?? "", "")
        }
        
        for score in atributos?.mappingscore as! [String : Any] {
            let values = incomeData.value(forKey: score.key)
            _ = self.formDelegate?.resolveValor(score.value as? String ?? "", "asignacion", values as? String ?? "", "")
        }
        
        let tokenStr = atributos?.tokenshared ?? ""
        _ = self.formDelegate?.resolveValor(tokenStr, "asignacion", token, "")
        
        let video = atributos?.videodocumentosselfie ?? ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = self.formDelegate?.resolveValor(video, "asignacion", videoPath, "")
        }
        
        formDelegate?.setStatusBarNotificationBanner(text, .success, .bottom)
    }
    
    func failureUploadVideo(message text: String) {
        formDelegate?.setStatusBarNotificationBanner(text, .danger, .bottom)
    }
    
    func failureGetValidation(message text: String) {
        formDelegate?.setStatusBarNotificationBanner(text, .danger, .bottom)
    }
}

// MARK: BackConfirmVeridasActionDelegate
extension VeridasDocumentOcrCell: BackVeridasConfirmActionDelegate {
    public func processConfirmFinished(_ text: String){
        formDelegate?.setStatusBarNotificationBanner(text, .success, .bottom)
    }
    
    public func failureConfirmation(_ text: String){
        formDelegate?.setStatusBarNotificationBanner(text, .danger, .bottom)
    }
}

// MARK: BackCancelVeridasActionDelegate
extension VeridasDocumentOcrCell: BackVeridasCancelActionDelegate {
    public func failureCancel(_ message: String) {
        formDelegate?.setStatusBarNotificationBanner(message, .danger, .bottom)
    }
    
    public func processCancelFinished(_ text: String){
        formDelegate?.setStatusBarNotificationBanner(text, .success, .bottom)
    }
}

// MARK: implementation veridas ocr document
extension VeridasDocumentOcrCell: VDDocumentCaptureProtocol {
    public func vdDocumentCaptured(_ imageData: Data!, with captureType: VDCaptureType, andDocument document: [VDDocument]!) {
        print(document.description)
    }
    
    public func vdDocumentAllFinished(_ processFinished: Bool) {
        print(processFinished)
    }
    
    public func vdTimeWithoutPhotoTaken(_ seconds: Int32, with capture: VDCaptureType) {
        print(seconds)
    }
}

extension VeridasDocumentOcrCell: ObjectFormDelegate {
    
    
    public func setHeightFromTitles() {
        
    }
    
    public func setEdited(v: String, isRobot: Bool) {
        
    }
    
    
    public func setEstadistica() {
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "OCR"
        est?.NombrePagina = (self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
        est?.OrdenCampo = atributos?.ordencampo ?? 0
        est?.PaginaID = Int(atributos?.elementopadre.replaceFormElec() ?? "0") ?? 0
        est?.FechaEntrada = ConfigurationManager.shared.utilities.getFormatDate()
        est?.Latitud = ConfigurationManager.shared.latitud
        est?.Longitud = ConfigurationManager.shared.longitud
        est?.Usuario = ConfigurationManager.shared.usuarioUIAppDelegate.User
        est?.Dispositivo = UIDevice().model
        est?.NombrePlantilla = (self.formDelegate?.getPlantillaTitle() ?? "").replaceLineBreak()
        est?.Sesion = ConfigurationManager.shared.guid
        est?.PlantillaID = 0
        est?.CampoID = Int(elemento._idelemento.replaceFormElec()) ?? 0
    }
    public func setEstadisticaV2(){
        if self.estV2 != nil { return }
        self.estV2 = FEEstadistica2()
        if self.atributos != nil{
            self.estV2?.IdElemento = elemento._idelemento
            self.estV2?.Titulo = atributos?.titulo ?? ""
            self.estV2?.Pagina = (self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
            self.estV2?.IdPagina = self.formDelegate?.getPageID(atributos?.elementopadre ?? "") ?? ""
        }
    }
    
    public func setTextStyle(_ style: String) {
        
    }
    
    public func setDecoration(_ decor: String) {
        
    }
    
    public func setAlignment(_ align: String) {
        
    }
    
    public func setVariableHeight(Height h: CGFloat) {
        DispatchQueue.main.async {
            self.height = {return h}
            self.layoutIfNeeded()
            self.genericRow.reload()
            self.formDelegate?.reloadTableViewFormViewController()
        }
    }
    
    public func setTitleText(_ text: String) {
        self.lblTitle.text = text
    }
    
    public func setSubtitleText(_ text: String) {
        self.lblSubtitle.text = text
    }
    
    public func setPlaceholder(_ text: String) {
        
    }
    
    public func setInfo() {
        if atributos?.ayuda != nil, !(atributos?.ayuda.isEmpty)!, atributos?.ayuda != ""{
            self.btnInfo.isHidden = false
        }
    }
    
    public func setAyuda(_ sender: Any) {
        
    }
    
    public func toogleToolTip(_ help: String) {
        
    }
    
    public func setMessage(_ string: String, _ state: enumErrorType) {
        
    }
    
    public func initRules() {
        
    }
    
    public func setMinMax() {
        
    }
    
    public func setExpresionRegular() {
        
    }
    
    public func setOcultarTitulo(_ bool: Bool) {
        self.atributos?.ocultartitulo = bool
        if bool{
            self.lblTitle.isHidden = true
            self.setTitleText("")
        }else{
            self.lblTitle.isHidden = false
            if atributos != nil{
                setTitleText(atributos?.titulo ?? "")
            }
        }
        self.layoutIfNeeded()
    }
    
    public func setOcultarSubtitulo(_ bool: Bool) {
        self.atributos?.ocultarsubtitulo = "\(bool)"
        if bool{
            self.lblSubtitle.isHidden = true
            self.setSubtitleText("")
        }else{
            self.lblSubtitle.isHidden = false
            if atributos != nil{
                setSubtitleText(atributos?.subtitulo ?? "")
            }
        }
        self.layoutIfNeeded()
    }
    
    public func setHabilitado(_ bool: Bool) {
        self.elemento.validacion.habilitado = bool
        self.atributos?.habilitado = bool
        if bool{
            self.bgHabilitado.isHidden = true;
            self.row.baseCell.isUserInteractionEnabled = true
            self.row.disabled = false
        }else{
            self.bgHabilitado.isHidden = false;
            self.row.baseCell.isUserInteractionEnabled = false
            self.row.disabled = true
        }
        self.row.evaluateDisabled()
    }
    
    public func setEdited(v: String) {
        if v != ""{
            self.lblMoreInfo.text = v
            self.lblMoreInfo.isHidden = false
            row.value = v
        }else{
            self.lblMoreInfo.text = ""
            self.lblMoreInfo.isHidden = true
            row.value = nil
        }
        
        // MARK: - Setting estadisticas
        setEstadistica()
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = v.replaceLineBreakEstadistic()
        est!.KeyStroke += 1
        elemento.estadisticas = est!
        
        self.setEstadisticaV2()
        let fechaValorFinal = Date.getTicks()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = v.replaceLineBreakEstadistic()
        self.estV2!.Cambios += 1
        elemento.estadisticas2 = estV2!
    }
    
    public func setVisible(_ bool: Bool) {
        self.elemento.validacion.visible = bool
        if self.atributos != nil{
            self.atributos?.visible = bool
            if bool {
                self.row.hidden = false
            }else{
                self.row.hidden = true
            }
        }
        self.row.evaluateHidden()
    }
    
    public func setRequerido(_ bool: Bool) {
        
    }
    
    public func resetValidation() {
        
    }
    
    public func updateIfIsValid(isDefault: Bool) {
        
    }
    
    public func triggerEvent(_ action: String) {
        
    }
    
    public func setRulesOnProperties() {
        
    }
    
    public func setRulesOnChange() {
        
    }
    
    public func triggerRulesOnProperties(_ action: String) {
        
    }
    
    public func triggerRulesOnChange(_ action: String?) {
        
    }
    
    public func setMathematics(_ bool: Bool, _ id: String) {
        
    }
    
}

extension VeridasDocumentOcrCell {
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{ return "" }
    public func getRowEnabled()->Bool{ return self.row.baseCell.isUserInteractionEnabled }
    public func getRequired()->Bool{ return false }
    public func getTitleLabel()->String{ return "" }
    public func getSubtitleLabel()->String{ return "" }
}

extension VeridasDocumentOcrCell: APIDelegate {
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
    
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
    
    public func sendStatusCodeMessage(message: String, error: enumErrorType) {}
    
    public func didSendError(message: String, error: enumErrorType) {}
    
    public func didSendResponse(message: String, error: enumErrorType) {}
    
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
}
