import Eureka
import AVFoundation
//#if canImport(VeridiumCore)
//import VeridiumCore
//import Veridium4FBiometrics
//#endif

open class VeridiumCell: Cell<String>, CellType, APIDelegate {
    // MARK: - IBOUTLETS AND VARS
    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var lblMoreInfo: UILabel!
    @IBOutlet weak var bgHabilitado: UIView!
    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var btnClean: UIButton!
    @IBOutlet weak var btnPreview: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    
    public var genericRow: VeridiumRow! {return row as? VeridiumRow}
    public var elemento = Elemento()
    public var atributos: Atributos_huelladigital!
    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var isServiceMessageDisplayed = 0
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil

    #if canImport(VeridiumCore)
    var exportConfig : VeridiumFourFCaptureConfig = VeridiumFourFCaptureConfig()
    #endif
    var sdkAPI : APIManager<VeridiumCell>?
    var anexo: [FEAnexoData]?
    var totalHuellas: Int = 0
    var totalPromedio = 0
    
    // Tipificación
    var vw: MetaAttributesViewController = MetaAttributesViewController()
    var docID: Int = 0
    var arrayMetadatos: [FEListMetadatosHijos] = []
    public var tipUnica: Int?
    public var listAllowed: [FEListTipoDoc] = []
    public var path = ""
    public var fedocumento: FEDocumento = FEDocumento()
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    
    // Anexos Dictionary
    // 1 - 10 are anexos Only
    // 11 - 20 are repleacement
    public var anexosDict = [ (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: "")]
    var fingersLeft = [(isEnable: false, score: 0, image: "", position: 0),
                       (isEnable: false, score: 0, image: "", position: 0),
                       (isEnable: false, score: 0, image: "", position: 0),
                       (isEnable: false, score: 0, image: "", position: 0),
                       (isEnable: false, score: 0, image: "", position: 0)]
    var fingersRight = [(isEnable: false, score: 0, image: "", position: 0),
                        (isEnable: false, score: 0, image: "", position: 0),
                        (isEnable: false, score: 0, image: "", position: 0),
                        (isEnable: false, score: 0, image: "", position: 0),
                        (isEnable: false, score: 0, image: "", position: 0)]
    var is2F = false
    var is8F = false
    var is4FI = false
    var is4FD = false
    var isHandLeft = false
    var isHandRight = false
    
    // MARK: - APIDELEGATE
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    
    // MARK: - ACTIONS
    @IBAction func downloadAnexo(_ sender: Any) {
        setDownloadAnexo(sender)
    }
    @IBAction func btnCleanAction(_ sender: UIButton) {
        self.headersView.lblMessage.text = ""
        self.headersView.lblMessage.isHidden = true
        self.lblMoreInfo.text = ""
        self.lblMoreInfo.isHidden = true
        self.btnClean.isHidden = true
        self.btnPreview.isHidden = true
        self.btnCall.isHidden = false
        
        self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
        row.value = nil
        row.validate()
        self.updateIfIsValid()
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader + 10)
        triggerRulesOnChange("removeanexo")
    }
    @IBAction func btnPreviewAction(_ sender: UIButton) {
        setPreview(sender)
    }
    @IBAction func btnRedoAction(_ sender: UIButton) {
        launchVeridium()
    }
    
    // MARK: - INIT
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        
        let apiObject = AttachedFormManager<VeridiumCell>()
        apiObject.delegate = self
        sdkAPI = APIManager<VeridiumCell>()
        
        self.btnPreview.layer.cornerRadius = self.btnPreview.frame.width / 2

        
        download.addTarget(self, action: #selector(downloadAnexo(_:)), for: .touchDown)
        
        //#Btn Fondo/Redondo
        
        btnClean.layer.cornerRadius = btnClean.frame.height / 2
        btnClean.setImage(UIImage(named: "ic_clean", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        
        btnRedo.layer.cornerRadius = btnRedo.frame.height / 2
        btnRedo.setImage(UIImage(named: "ic_redo", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        
        btnPreview.layer.cornerRadius = btnPreview.frame.height / 2
        btnPreview.setImage(UIImage(named: "ic_score", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        
        btnCall.layer.cornerRadius = btnCall.frame.height / 2
        btnCall.setImage(UIImage(named: "ic_fingerprint", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        
        download.layer.cornerRadius = download.frame.height / 2
        download.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
    }
    func setColorsElement(){
        btnClean.backgroundColor = UIColor(hexFromString: atributos?.colortextobotoneliminar ?? "#1E88E5")
        btnRedo.backgroundColor = UIColor(hexFromString: atributos?.colorbotonescanear ?? "#1E88E5")
        btnPreview.backgroundColor = UIColor(hexFromString: atributos?.colorbotonescanear ?? "#1E88E5")
        btnCall.backgroundColor = UIColor(hexFromString: atributos?.colorbotonescanear ?? "#1E88E5")
        download.backgroundColor = UIColor(hexFromString: atributos?.colorbotonescanear ?? "#1E88E5")
    }
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) {
        guard let _ = self.atributos, let help = atributos?.ayuda else{
            return;
        }
        toogleToolTip(help)
    }
    // MARK: SETTING
    /// SetObject for VeridiumRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_huelladigital
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        
        if(ConfigurationManager.shared.veridiumLicense) {
            self.headersView.lblMessage.text = ""
            self.headersView.lblMessage.isHidden = true
            self.btnCall.isEnabled = true
        }else{
            self.headersView.lblMessage.text = "  \("elemts_finger_sdk".langlocalized())  "
            let colors = self.formDelegate?.getColorsErrors(.success)
            self.headersView.lblMessage.backgroundColor = colors![1]
            self.headersView.lblMessage.textColor = UIColor.white
            self.headersView.lblMessage.isHidden = false
            self.btnCall.isEnabled = false
        }
        
        initRules()
        setFingersVeridium()
        if atributos?.titulo ?? "" == ""{ self.headersView.setOcultarTitulo(true) }else{ self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        if atributos?.subtitulo ?? "" == ""{ self.headersView.setOcultarSubtitulo(true) }else{ self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false) }
        
        
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? VeridiumRow)?.cell.formCell()?.formViewController()?.tableView
        
        self.headersView.setTitleText(headersView.txttitulo)
        self.headersView.setSubtitleText(headersView.txtsubtitulo)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
        
        setInfo()
        getTipificacionPermitida()
        setColorsElement()
        
        if anexo != nil{
            if anexo?[0].Error == 100{
                self.setMessage("elemts_attch_replace".langlocalized(), .warning)
            }else{
                self.setMessage("elemts_attch_noreplace".langlocalized(), .error)
                self.bringSubviewToFront(download)
                setHabilitado(false)
            }
        }
        
        self.headersView.translatesAutoresizingMaskIntoConstraints = false
        self.headersView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        self.headersView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.headersView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        
        self.headersView.setNeedsLayout()
        self.headersView.layoutIfNeeded()
        
        self.btnCall.translatesAutoresizingMaskIntoConstraints = false
        self.btnCall.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 10).isActive = true
        
        self.lblMoreInfo.translatesAutoresizingMaskIntoConstraints = false
        self.lblMoreInfo.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 3).isActive = true
        self.lblMoreInfo.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 55).isActive = true
        self.lblMoreInfo.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -55).isActive = true
        
        btnClean.translatesAutoresizingMaskIntoConstraints = false
        self.btnClean.topAnchor.constraint(equalTo: self.lblMoreInfo.bottomAnchor, constant: 10).isActive = true
        self.btnClean.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -145).isActive = true
        
        btnPreview.translatesAutoresizingMaskIntoConstraints = false
        self.btnPreview.topAnchor.constraint(equalTo: self.lblMoreInfo.bottomAnchor, constant: 10).isActive = true
        self.btnPreview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -200).isActive = true
        
        btnRedo.translatesAutoresizingMaskIntoConstraints = false
        self.btnRedo.topAnchor.constraint(equalTo: self.lblMoreInfo.bottomAnchor, constant: 10).isActive = true
        self.btnRedo.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -260).isActive = true
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader)
    }

    func setFingersVeridium(){
        let huellasacapturar = atributos?.huellasacapturar.split{$0 == ","}.map(String.init)
        guard huellasacapturar != nil else{
            headersView.lblMessage.text = "elemts_finger_config".langlocalized()
            return
        }
        /*
        1 - Pulgar Derecho
        2 - Indice Derecho
        3 - Medio Derecho
        4 - Anular Derecho
        5 - Meñique Derecho
        6 - Pulgar Izquierdo
        7 - Indice Izquierdo
        8 - Medio Izquierdo
        9 - Anular Izquierdo
        10 - Meñique Izquierdo
        11 - Palma Derecho
        12 - Palma Izquierdo
        13 - Pulgares */
    }
    
    override open func update() {
        super.update()
    }
    
    @IBAction func btnCallAction(_ sender: Any) {
        let dd = Device()
        if !dd.isPad || AVCaptureDevice.default(for: .video)?.hasFlash ?? false {
            launchVeridium()
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                self.headersView.lblMessage.text = "elemts_finger_ipad".langlocalized()
                self.headersView.lblMessage.isHidden = false
                self.layoutIfNeeded()
            })
        }
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        
        if isInfoToolTipVisible{
            toolTip!.dismiss()
            isInfoToolTipVisible = false
        }
    }
    
    func launchVeridium(){
        self.settingFingers()
    }
    
    func settingFingers(){
        let huellasacapturar = atributos?.huellasacapturar.split{$0 == ","}.map(String.init)
        guard let huellas = huellasacapturar else{
            return
        }
        if huellas.count > 0{
            for finger in huellas{
                switch finger{
                case "1":
                    fingersLeft[0].isEnable = true
                    break
                case "2":
                    fingersLeft[1].isEnable = true
                    break
                case "3":
                    fingersLeft[2].isEnable = true
                    break
                case "4":
                    fingersLeft[3].isEnable = true
                    break
                case "5":
                    fingersLeft[4].isEnable = true
                    break
                case "6":
                    fingersRight[0].isEnable = true
                    break
                case "7":
                    fingersRight[1].isEnable = true
                    break
                case "8":
                    fingersRight[2].isEnable = true
                    break
                case "9":
                    fingersRight[3].isEnable = true
                    break
                case "10":
                    fingersRight[4].isEnable = true
                    break
                case "11":
                    fingersRight[0].isEnable = true
                    fingersRight[1].isEnable = true
                    fingersRight[2].isEnable = true
                    fingersRight[3].isEnable = true
                    fingersRight[4].isEnable = true
                    break
                case "12":
                    fingersLeft[0].isEnable = true
                    fingersLeft[1].isEnable = true
                    fingersLeft[2].isEnable = true
                    fingersLeft[3].isEnable = true
                    fingersLeft[4].isEnable = true
                    break
                case "13":
                    fingersRight[0].isEnable = true
                    fingersRight[1].isEnable = false
                    fingersRight[2].isEnable = false
                    fingersRight[3].isEnable = false
                    fingersRight[4].isEnable = false
                    fingersLeft[0].isEnable = true
                    fingersLeft[1].isEnable = false
                    fingersLeft[2].isEnable = false
                    fingersLeft[3].isEnable = false
                    fingersLeft[4].isEnable = false
                default:
                    break
                }
            }
            // Setting Menu Options
            if fingersRight[0].isEnable && fingersLeft[0].isEnable{ self.is2F = true }
            if fingersRight[1].isEnable, fingersRight[2].isEnable, fingersRight[3].isEnable, fingersRight[4].isEnable{ self.is4FD = true }
            if fingersLeft[1].isEnable, fingersLeft[2].isEnable, fingersLeft[3].isEnable, fingersLeft[4].isEnable{ self.is4FI = true }
            if fingersRight[0].isEnable, fingersRight[1].isEnable, fingersRight[2].isEnable, fingersRight[3].isEnable, fingersRight[4].isEnable, fingersLeft[0].isEnable, fingersLeft[1].isEnable, fingersLeft[2].isEnable, fingersLeft[3].isEnable, fingersLeft[4].isEnable{ self.is4FD = false; self.is4FI = false; self.is8F = true; }
            #if canImport(VeridiumCore)
            self.setFingerHand(VeridiumFourFHandChoice.forceLeftHandEnroll, 0)
            
            #endif
        }
    }
    #if canImport(VeridiumCore)
    func setFingerHand(_ hand: VeridiumFourFHandChoice, _ index: Int){
        exportConfig = VeridiumFourFCaptureConfig()
        exportConfig.setHand(.bothHands)
        exportConfig.exportFormat = .FORMAT_JSON
        exportConfig.wsq_compression_ratio = Float(0.6)
        exportConfig.calculate_nfiq = true
        exportConfig.targetIndexFinger = true
        exportConfig.targetLittleFinger = false
        
        exportConfig.pack_audit_image = false
        exportConfig.pack_png = false;
        exportConfig.pack_wsq = true;
        exportConfig.pack_bmp = false;
        exportConfig.pack_raw = false;
        
        exportConfig.show_instruction_screen = true
        exportConfig.canSwitch = false
        exportConfig.do_debug = false
        exportConfig.do_export = true;
        isHandLeft = true
        isHandRight = true
        startVeridium()
    }
    
    func startVeridium() {
        
        VeridiumBiometricsFourFService.exportTemplate(exportConfig, onSuccess: { [self] (biometricVector) in
            
            let bio = String(data: biometricVector, encoding: .utf8)
            let fingerResult = HuellaDigitalRespuesta(json: bio)
            
            if fingerResult.Fingerprints.count > 0 {
                for fingerPrint in fingerResult.Fingerprints {
                    let wsq = fingerPrint.FingerImpressionImage.BinaryBase64ObjectWSQ
                    
                    if self.isHandLeft && self.isHandRight{
                        switch fingerPrint.FingerPositionCode{
                        
                        case 2:
                            
                            if self.fingersLeft[1].isEnable {
                                self.fingersLeft[1].image = self.setFingerPrint(fingerPrint.NFIQ)
                                self.fingersLeft[1].score = fingerPrint.NFIQ
                                self.fingersLeft[1].position = fingerPrint.FingerPositionCode
                                
                                let urlFile = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_\(7)_\(ConfigurationManager.shared.utilities.guid()).ane"
                                self.saveWQS(urlFile, 7, wsq)
                            }
                            
                            break
                        case 3:
                            
                            if self.fingersLeft[2].isEnable{
                                self.fingersLeft[2].image = self.setFingerPrint(fingerPrint.NFIQ)
                                self.fingersLeft[2].score = fingerPrint.NFIQ
                                self.fingersLeft[2].position = fingerPrint.FingerPositionCode
                                
                                let urlFile = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_\(8)_\(ConfigurationManager.shared.utilities.guid()).ane"
                                self.saveWQS(urlFile, 8, wsq)
                            }
                            
                            break
                        case 4:
                            
                            if self.fingersLeft[3].isEnable{
                                self.fingersLeft[3].image = self.setFingerPrint(fingerPrint.NFIQ)
                                self.fingersLeft[3].score = fingerPrint.NFIQ
                                self.fingersLeft[3].position = fingerPrint.FingerPositionCode
                                
                                let urlFile = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_\(9)_\(ConfigurationManager.shared.utilities.guid()).ane"
                                self.saveWQS(urlFile, 9, wsq)
                            }
                            
                            break
                        case 5:
                            
                            if self.fingersLeft[4].isEnable{
                                self.fingersLeft[4].image = self.setFingerPrint(fingerPrint.NFIQ)
                                self.fingersLeft[4].score = fingerPrint.NFIQ
                                self.fingersLeft[4].position = fingerPrint.FingerPositionCode
                                
                                let urlFile = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_\(10)_\(ConfigurationManager.shared.utilities.guid()).ane"
                                self.saveWQS(urlFile, 10, wsq)
                            }
                            
                            break
                        case 7:
                            
                            if self.fingersRight[1].isEnable{
                                self.fingersRight[1].image = self.setFingerPrint(fingerPrint.NFIQ)
                                self.fingersRight[1].score = fingerPrint.NFIQ
                                self.fingersRight[1].position = fingerPrint.FingerPositionCode
                                
                                let urlFile = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_\(2)_\(ConfigurationManager.shared.utilities.guid()).ane"
                                self.saveWQS(urlFile, 2, wsq)
                            }
                            
                            break
                        case 8:
                            
                            if self.fingersRight[2].isEnable{
                                self.fingersRight[2].image = self.setFingerPrint(fingerPrint.NFIQ)
                                self.fingersRight[2].score = fingerPrint.NFIQ
                                self.fingersRight[2].position = fingerPrint.FingerPositionCode
                                
                                let urlFile = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_\(3)_\(ConfigurationManager.shared.utilities.guid()).ane"
                                self.saveWQS(urlFile, 3, wsq)
                            }
                            
                            break
                        case 9:
                            
                            if self.fingersRight[3].isEnable{
                                self.fingersRight[3].image = self.setFingerPrint(fingerPrint.NFIQ)
                                self.fingersRight[3].score = fingerPrint.NFIQ
                                self.fingersRight[3].position = fingerPrint.FingerPositionCode
                                
                                let urlFile = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_\(4)_\(ConfigurationManager.shared.utilities.guid()).ane"
                                self.saveWQS(urlFile, 4, wsq)
                            }
                            
                            break
                        case 10:
                            
                            if self.fingersRight[4].isEnable{
                                self.fingersRight[4].image = self.setFingerPrint(fingerPrint.NFIQ)
                                self.fingersRight[4].score = fingerPrint.NFIQ
                                self.fingersRight[4].position = fingerPrint.FingerPositionCode
                                
                                let urlFile = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_\(5)_\(ConfigurationManager.shared.utilities.guid()).ane"
                                self.saveWQS(urlFile, 5, wsq)
                            }
                            
                            break
                        
                        default:
                            break
                        }
                    }
                    
                }
            }
            var isClear = true
            
            let score: Int = Int(self.atributos?.scoremin ?? "5")!
            for fingerLeft in self.fingersLeft{
                if score >= fingerLeft.score{
                    
                }else{
                    isClear = false
                }
            }
            
            for fingerRight in self.fingersRight{
                if score >= fingerRight.score{
                    
                }else{
                    isClear = false
                }
            }
            var totalScore: Float = 0.0
            var totalFingerPrints: Float = 0.0
            self.elemento.validacion.scorehuellas = ""
            if self.fingersLeft[0].isEnable{
                totalScore += Float(self.fingersLeft[0].score); totalFingerPrints += 1.0
                self.elemento.validacion.scorehuellas += "\(self.fingersLeft[0].position)-\(self.fingersLeft[0].score),"
            }
            if self.fingersLeft[1].isEnable{
                totalScore += Float(self.fingersLeft[1].score); totalFingerPrints += 1.0
                self.elemento.validacion.scorehuellas += "\(self.fingersLeft[1].position)-\(self.fingersLeft[1].score),"
            }
            if self.fingersLeft[2].isEnable{
                totalScore += Float(self.fingersLeft[2].score); totalFingerPrints += 1.0
                self.elemento.validacion.scorehuellas += "\(self.fingersLeft[2].position)-\(self.fingersLeft[2].score),"
            }
            if self.fingersLeft[3].isEnable{
                totalScore += Float(self.fingersLeft[3].score); totalFingerPrints += 1.0
                self.elemento.validacion.scorehuellas += "\(self.fingersLeft[3].position)-\(self.fingersLeft[3].score),"
            }
            if self.fingersLeft[4].isEnable{
                totalScore += Float(self.fingersLeft[4].score); totalFingerPrints += 1.0
                self.elemento.validacion.scorehuellas += "\(self.fingersLeft[4].position)-\(self.fingersLeft[4].score),"
            }
            
            if self.fingersRight[0].isEnable{
                totalScore += Float(self.fingersRight[0].score); totalFingerPrints += 1.0
                self.elemento.validacion.scorehuellas += "\(self.fingersRight[0].position)-\(self.fingersRight[0].score),"
            }
            if self.fingersRight[1].isEnable{
                totalScore += Float(self.fingersRight[1].score); totalFingerPrints += 1.0
                self.elemento.validacion.scorehuellas += "\(self.fingersRight[1].position)-\(self.fingersRight[1].score),"
            }
            if self.fingersRight[2].isEnable{
                totalScore += Float(self.fingersRight[2].score); totalFingerPrints += 1.0
                self.elemento.validacion.scorehuellas += "\(self.fingersRight[2].position)-\(self.fingersRight[2].score),"
            }
            if self.fingersRight[3].isEnable{
                totalScore += Float(self.fingersRight[3].score); totalFingerPrints += 1.0
                self.elemento.validacion.scorehuellas += "\(self.fingersRight[3].position)-\(self.fingersRight[3].score),"
            }
            if self.fingersRight[4].isEnable{
                totalScore += Float(self.fingersRight[4].score); totalFingerPrints += 1.0
                self.elemento.validacion.scorehuellas += "\(self.fingersRight[4].position)-\(self.fingersRight[4].score),"
            }
            self.elemento.validacion.scorehuellas.removeLast()

            if !isClear{
                self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
                self.row.value = nil
                self.row.validate()
                self.updateIfIsValid()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: { [self] in
                    self.headersView.lblMessage.text = String(format: "elemts_finger_score".langlocalized(), String(self.atributos!.scoremin))
                    self.headersView.lblMessage.isHidden = false
                    self.lblMoreInfo.text = String(format: "elemts_finger_prom".langlocalized(), String(Int(Double(totalScore/totalFingerPrints).rounded())), String(Int(totalFingerPrints)))
                    self.lblMoreInfo.isHidden = false
                    self.btnCall.isHidden = false
                    setVariableHeight(Height: 165)
                    self.layoutIfNeeded()
                })
            }else{
                self.headersView.lblMessage.text = ""
                self.headersView.lblMessage.isHidden = true
                self.lblMoreInfo.text = String(format: "elemts_finger_prom".langlocalized(), String(Int(Double(totalScore/totalFingerPrints).rounded())), String(Int(totalFingerPrints)))
                self.lblMoreInfo.isHidden = false
                self.btnClean.isHidden = false
                self.btnPreview.isHidden = false
                self.btnCall.isHidden = true
                setVariableHeight(Height: 165)
                self.setEdited(v: String(format: "elemts_finger_prom".langlocalized(), String(Int(Double(totalScore/totalFingerPrints).rounded())), String(Int(totalFingerPrints))))
                self.row.validate()
                self.updateIfIsValid()

                // Setting metas
                self.elemento.validacion.docid = "0"
                self.elemento.validacion.isreemplazohuella = "no"
                self.elemento.validacion.tipodoc = "\(self.atributos?.tipodoc ?? 0)"
                self.elemento.validacion.cantidadhuellas = "\(Int(totalFingerPrints))"
                self.elemento.validacion.scorepromedio = "\(Int(Double(totalScore/totalFingerPrints).rounded()))"
            }
            
        }, onFail: { }, onCancel: { }) { (error) in }
        
    }
    #endif

    
    func saveWQS(_ urlFile: String, _ fingerPosition: Int, _ data: String){
        self.anexosDict[fingerPosition] = (id: String(fingerPosition), url: urlFile)
        let _ = ConfigurationManager.shared.utilities.saveWSQToFolder(data, urlFile)
    }
    
    func setFingerPrint(_ nfiq: Int)->String{
        switch nfiq{
        case 1:
            return "green-fingreprint"
        case 2:
            return "blue-fingerprint"
        case 3:
            return "yellow-fingerprint"
        case 4:
            return "orange-fingerprint"
        case 5:
            return "red-fingerprint"
        default:
            return ""
        }
    }
    
    func setFingerPrint(_ nfiq: Int)->UIImage? {
        switch nfiq {
        case 1:
            return UIImage(named: "green-fingreprint", in: Cnstnt.Path.framework, compatibleWith: nil)!
        case 2:
            return UIImage(named: "blue-fingerprint", in: Cnstnt.Path.framework, compatibleWith: nil)!
        case 3:
            return UIImage(named: "yellow-fingerprint", in: Cnstnt.Path.framework, compatibleWith: nil)!
        case 4:
            return UIImage(named: "orange-fingerprint", in: Cnstnt.Path.framework, compatibleWith: nil)!
        case 5:
            return UIImage(named: "red-fingerprint", in: Cnstnt.Path.framework, compatibleWith: nil)!
        default:
            return nil
        }
    }
    
    
    // MARK: - TIPIFYCATION
    // MARK: - Button Action Document Type
    @IBAction func typeDocAction(_ sender: UIButton) {
        self.vw.view.isHidden = false
        self.vw.lblTipoDoc.text = "elemts_meta_select".langlocalized()
        self.vw.listAllowed = self.listAllowed
        self.vw.fedocumento = self.fedocumento
        self.vw.arrayMetadatos = self.arrayMetadatos
        self.vw.metaDataTableView.isHidden = true
        self.vw.documentType.isHidden = false
        self.vw.documentType.reloadAllComponents()
        self.vw.documentType.selectRow(0, inComponent: 0, animated: false)
        self.vw.metaBtnGuardar.isHidden = true
    }
    // MARK: - Button Action Metadata
    @IBAction func metaAction(_ sender: UIButton) {
        self.vw.view.isHidden = false
        self.vw.lblTipoDoc.text = "elemts_meta_write".langlocalized()
        self.vw.listAllowed = self.listAllowed
        self.vw.docID = self.docID
        self.vw.fedocumento = self.fedocumento
        self.vw.arrayMetadatos = self.arrayMetadatos
        self.vw.metaDataTableView.isHidden = false
        self.vw.metaDataTableView.reloadData()
        self.vw.documentType.isHidden = true
        self.vw.metaBtnGuardar.isHidden = false
    }
    // MARK: - Close Meta View
    @IBAction func closeMetaAction(_ sender: Any) {
        self.vw.view.isHidden = true
    }
    // MARK: - Save Meta View
    @IBAction func saveMetaAction(_ sender: Any) {
        // Saving meta attibutes to the Document Typed
        let obj = fedocumento
        obj.Metadatos = []
        for (index, meta) in self.arrayMetadatos.enumerated(){
            let indexPath = IndexPath(row: index, section: 0)
            let cell = self.vw.metaDataTableView.cellForRow(at: indexPath) as! MetaDataTableViewCell
            let m = meta
            m.NombreCampo = cell.textFieldMD.text ?? ""
            obj.Metadatos.append(m)
        }
        var counterFe = 0
        if fedocumento.Metadatos.count == 0{
            counterFe += 1
        }
        if counterFe == 0{
            let tipodoc: NSMutableDictionary = NSMutableDictionary();
            let meta: NSMutableDictionary = NSMutableDictionary();

            tipodoc.setValue("\(String(fedocumento.TipoDocID ?? 0))", forKey: "\(fedocumento.guid)");
            let metadatos: NSMutableDictionary = NSMutableDictionary();
            for metaFe in fedocumento.Metadatos{
                metadatos.setValue("\(metaFe.NombreCampo)", forKey: "\(metaFe.Nombre)");
            }
            meta.setValue(metadatos, forKey: "\(fedocumento.guid)");
            self.anexosDict.append((id: "\(0)", url: "\(fedocumento.Nombre)"))

            self.elemento.validacion.valor = tipodoc.toJsonString()
            self.elemento.validacion.valormetadato = meta.toJsonString()
            self.setEdited(v: fedocumento.URL)
        }
    }
    // MARK: Get Metas
    func getMetaData()->Bool{
        self.arrayMetadatos = []
        let metas = ConfigurationManager.shared.plantillaDataUIAppDelegate.ListMetadatosHijos
        if metas.count == 0{ return false }
        for meta in metas{
            if self.fedocumento.TipoDocID == meta.TipoDoc{
                self.arrayMetadatos.append(meta)
            }
        }
        if self.arrayMetadatos.count == 0{ return false }
        self.vw.metaDataTableView.reloadData()
        return true
    }
    // MARK: - Saving Data from Metas
    public func savingData(){
        let tipodoc: NSMutableDictionary = NSMutableDictionary();
        let meta: NSMutableDictionary = NSMutableDictionary();
        
        tipodoc.setValue("\(String(atributos?.tipodoc ?? 0))", forKey: "\(fedocumento.guid)");
        self.elemento.validacion.valor = tipodoc.toJsonString()
        self.elemento.validacion.valormetadato = meta.toJsonString()
//        self.setEdited(v: fedocumento.Nombre)
//        if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
    }
    // MARK: - Set Permiso Tipificar
    public func setPermisoTipificar(_ bool: Bool){
//        if bool{
//            self.typeDocButton.isHidden = false
//            self.btnMeta.isHidden = false
//            self.lblTypeDoc.isHidden = false
//        }else{
//            self.typeDocButton.isHidden = true
//            self.btnMeta.isHidden = true
//            self.lblTypeDoc.isHidden = true
//        }
    }
    // MARK: - Get All Tipyfication options
    public func getTipificacionPermitida(){
        // Getting tipificacion única
        let tipificacionUnica = atributos?.tipodoc
        if tipificacionUnica != 0{
            self.tipUnica = tipificacionUnica
            for idDoc in ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc{
                if self.tipUnica == idDoc.CatalogoId{
                    idDoc.min = 0
                    idDoc.max = 1
                    idDoc.Activo = true
                }else{ idDoc.Activo = false }
            }
        }else{
            for idDoc in ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc{
                idDoc.min = 0
                idDoc.max = 1
                idDoc.Activo = true
            }
        }
        for list in ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc{
            if list.Activo{
                listAllowed.append(list)
            }
        }
    }
}

// MARK: - OBJECTFORMDELEGATE
extension VeridiumCell: ObjectFormDelegate{
    
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Huella Digital"
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
            self.estV2?.IdPagina = atributos?.elementopadre.replaceFormElec() ?? ""
        }
    }
    // MARK: Set - TextStyle
    public func setTextStyle(_ style: String){
    }
    // MARK: Set - Decoration
    public func setDecoration(_ decor: String){
    }
    // MARK: Set - Alignment
    public func setAlignment(_ align: String){
    }
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) {
        DispatchQueue.main.async {
            self.height = {return h}
            self.layoutIfNeeded()
            self.genericRow.reload()
            self.formDelegate?.reloadTableViewFormViewController()
        }
    }
    // MARK: Set - Title Text
    public func setTitleText(_ text:String){
    }
    // MARK: Set - Subtitle Text
    public func setSubtitleText(_ text:String){
    }
    // MARK: Set - Height From Titles
    public func setHeightFromTitles(){
    }
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){ }
    // MARK: Set - Info
    public func setInfo(){
        if atributos?.ayuda != nil, !(atributos?.ayuda.isEmpty)!, atributos?.ayuda != ""{
            self.headersView.btnInfo.isHidden = false
        }
    }
    
    public func toogleToolTip(_ help: String){
        if isInfoToolTipVisible{
            toolTip?.dismiss()
            isInfoToolTipVisible = false
        }else{
            toolTip = EasyTipView(text: help, preferences: EasyTipView.globalPreferences)
            toolTip?.show(forView: self.headersView.btnInfo, withinSuperview: self.genericRow.cell.formCell()?.formViewController()?.tableView)
            isInfoToolTipVisible = true
        }
    }
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){
        // message, valid, alert, error
    }
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil{ setRequerido(atributos?.requerido ?? false) }
    }
    // MARK: Set - MinMax
    public func setMinMax(){ }
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){ }
    
    // MARK: Set - OcultarTitulo
    public func setOcultarTitulo(_ bool: Bool){
    }
    // MARK: Set - OcultarSubtitulo
    public func setOcultarSubtitulo(_ bool: Bool){
    }
    // MARK: Set - Habilitado
    public func setHabilitado(_ bool: Bool){
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
    // MARK: Set - Edited
    public func setEdited(v: String){
        if v != ""{
            self.btnClean.isHidden = false
            self.btnPreview.isHidden = false
            self.lblMoreInfo.text = v
            self.lblMoreInfo.isHidden = false
            //self.anexosDict[1] = (id: "1", url: v)
            self.headersView.lblTitle.textColor = UIColor.black
            row.value = v
            self.updateIfIsValid()
        }else{
            self.lblMoreInfo.text = ""
            self.lblMoreInfo.isHidden = true
            for (index, _) in anexosDict.enumerated(){
                anexosDict[index] = (id: "", url: "")
            }
            self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
            row.value = nil
            self.updateIfIsValid()
        }
        
        // MARK: - Setting estadisticas
        setEstadistica()
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = v.replaceLineBreakEstadistic()
        est!.KeyStroke += 1
        elemento.estadisticas = est!
        let FechaValorFinal = Date.getTicks()
        self.setEstadisticaV2()
        self.estV2!.FechaValorFinal = FechaValorFinal
        self.estV2!.ValorFinal = v.replaceLineBreakEstadistic()
        self.estV2!.Cambios += 1
        elemento.estadisticas2 = estV2!
        
        triggerRulesOnChange("addanexo")
        triggerEvent("alterminarcaptura")
    }
    public func setEdited(v: String, isRobot: Bool) { }
    // MARK: Set - Visible
    public func setVisible(_ bool: Bool){
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
    // MARK: Set - Validation
    public func resetValidation(){
        if atributos != nil{
            self.elemento.validacion.needsValidation = atributos?.requerido ?? false
        }
    }
    // MARK: Set - Requerido
    public func setRequerido(_ bool: Bool){
        self.elemento.validacion.needsValidation = bool
        self.atributos?.requerido = bool
        var rules = RuleSet<String>()
        if bool{
            rules.add(rule: ReglaRequerido())
            self.headersView.lblRequired.isHidden = false
            self.headersView.lblTitle.textColor = UIColor.red
        }else{
            self.headersView.lblRequired.isHidden = true
            self.headersView.lblTitle.textColor = UIColor.black
        }
        self.layoutIfNeeded()
        self.row.add(ruleSet: rules)
    }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        self.headersView.lblMessage.isHidden = true
        if row.isValid{
            // Setting row as valid
            if row.value == nil{
                DispatchQueue.main.async {
                    self.setOcultarSubtitulo(self.atributos?.ocultarsubtitulo ?? false)
                    self.headersView.lblMessage.text = ""
                    self.headersView.lblMessage.isHidden = true
//                    self.viewValidation.backgroundColor = Cnstnt.Color.gray
                    self.layoutIfNeeded()
                }
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = genericRow.cell.anexosDict
                self.elemento.validacion.validado = false
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            }else{
                DispatchQueue.main.async {
                    self.setOcultarSubtitulo(self.atributos?.ocultarsubtitulo ?? false)
                    self.headersView.lblMessage.text = ""
                    self.headersView.lblMessage.isHidden = true
//                    self.viewValidation.backgroundColor = UIColor.green
                    self.layoutIfNeeded()
                }
                resetValidation()
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = genericRow.cell.anexosDict
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.valor = row.value?.replaceLineBreak() ?? ""
                    self.elemento.validacion.valormetadato  = row.value?.replaceLineBreak() ?? ""
                }else{
                    self.elemento.validacion.validado = false
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                }
            }
        }else{
            // Throw the first error printed in the label
            DispatchQueue.main.async {
//                self.viewValidation.backgroundColor = UIColor.red
                if (self.row.validationErrors.count) > 0{
                    self.headersView.lblMessage.text = "  \(self.row.validationErrors[0].msg)  "
                    let colors = self.formDelegate?.getColorsErrors(.error)
                    self.headersView.lblMessage.backgroundColor = .clear
                    self.headersView.lblMessage.textColor = Cnstnt.Color.red2
                }
                self.headersView.lblMessage.isHidden = false
                self.layoutIfNeeded()
            }
            self.elemento.validacion.anexos = [(id: String, url: String)]()
            self.elemento.validacion.anexos = genericRow.cell.anexosDict
            self.elemento.validacion.needsValidation = true
            self.elemento.validacion.validado = false
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato = ""
        }
    }
    // MARK: Events
    public func triggerEvent(_ action: String) {
        // alentrar
        // alcambiar
        if atributos != nil, atributos?.eventos != nil{
            for evento in (atributos?.eventos.expresion)!{
                if evento._tipoexpression == action{
                    DispatchQueue.main.async {
                        self.formDelegate?.addEventAction(evento)
                    }
                }
            }
        }
    }
    // MARK: Excecution for RulesOnProperties
    public func setRulesOnProperties(){
        if rulesOnProperties.count == 0{ return }
        if self.atributos?.habilitado ?? false{ triggerRulesOnProperties("enabled") }else{ triggerRulesOnProperties("notenabled") }
        if self.atributos?.visible ?? false{
            triggerRulesOnProperties("visible")
            triggerRulesOnProperties("visiblecontenido")
        }else{
            triggerRulesOnProperties("notvisible")
            triggerRulesOnProperties("notvisiblecontenido")
        }
    }
    // MARK: Rules on properties
    public func triggerRulesOnProperties(_ action: String){
        if rulesOnProperties.count == 0{ return }
        for rule in rulesOnProperties{
            if rule.vrb == action{
                _ = self.formDelegate?.obtainRules(rString: rule.xml.name, eString: self.genericRow.tag, vString: rule.vrb, forced: false, override: false)
            }
        }
    }
    
    // MARK: Excecution for RulesOnChange
    public func setRulesOnChange(){ }
    
    // MARK: Rules on change
    public func triggerRulesOnChange(_ action: String?){
        if rulesOnChange.count == 0{ return }
        for rule in rulesOnChange{
            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: self.genericRow.tag, vString: action, forced: false, override: false)
        }
    }
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){ }
}

// MARK: - ATTACHEDFORMDELEGATE
extension VeridiumCell: AttachedFormDelegate{
    
    // MARK: Set - Local Anexo
    public func didSetLocalAnexo(_ feAnexo: FEAnexoData){
        self.anexo?.append(feAnexo)
        let filename = feAnexo.FileName.split{$0 == "_"}.map(String.init)
        let nameId = Int(filename[(filename.count - 2)])
        let localpath = "\(Cnstnt.Tree.anexos)/\(feAnexo.FileName)"
        if FCFileManager.existsItem(atPath: localpath){
            
            // Setting details
            switch nameId{
            case 1:
                self.fingersLeft[0].isEnable = true
                self.fingersLeft[0].image = self.setFingerPrint(0)
                self.fingersLeft[0].score = 0
                self.fingersLeft[0].position = 1
                break
            case 2:
                self.fingersLeft[1].isEnable = true
                self.fingersLeft[1].image = self.setFingerPrint(0)
                self.fingersLeft[1].score = 0
                self.fingersLeft[1].position = 2
                break
            case 3:
                self.fingersLeft[2].isEnable = true
                self.fingersLeft[2].image = self.setFingerPrint(0)
                self.fingersLeft[2].score = 0
                self.fingersLeft[2].position = 3
                break
            case 4:
                self.fingersLeft[3].isEnable = true
                self.fingersLeft[3].image = self.setFingerPrint(0)
                self.fingersLeft[3].score = 0
                self.fingersLeft[3].position = 4
                break
            case 5:
                self.fingersLeft[4].isEnable = true
                self.fingersLeft[4].image = self.setFingerPrint(0)
                self.fingersLeft[4].score = 0
                self.fingersLeft[4].position = 5
                break
            case 6:
                self.fingersRight[0].isEnable = true
                self.fingersRight[0].image = self.setFingerPrint(0)
                self.fingersRight[0].score = 0
                self.fingersRight[0].position = 6
                break
            case 7:
                self.fingersRight[1].isEnable = true
                self.fingersRight[1].image = self.setFingerPrint(0)
                self.fingersRight[1].score = 0
                self.fingersRight[1].position = 7
                break
            case 8:
                self.fingersRight[2].isEnable = true
                self.fingersRight[2].image = self.setFingerPrint(0)
                self.fingersRight[2].score = 0
                self.fingersRight[2].position = 8
                break
            case 9:
                self.fingersRight[3].isEnable = true
                self.fingersRight[3].image = self.setFingerPrint(0)
                self.fingersRight[3].score = 0
                self.fingersRight[3].position = 9
                break
            case 10:
                self.fingersRight[4].isEnable = true
                self.fingersRight[4].image = self.setFingerPrint(0)
                self.fingersRight[4].score = 0
                self.fingersRight[4].position = 10
                break
            default:
                break
            }
            
            totalHuellas += 1
            self.anexosDict[nameId!] = (id: "\(nameId!)", url: feAnexo.FileName)
            setEdited(v: String(format: "elemts_finger_token", totalHuellas))
            self.btnPreview.isHidden = false
            self.btnCall.isHidden = true
            
        }else{
            self.setMessage("elemts_attch_error".langlocalized(), .info)
            download.isHidden = false
        }
    }
    
    // MARK: Set - Anexo Option
    public func setAnexoOption(_ anexo: FEAnexoData){
        let filename = anexo.FileName.split{$0 == "_"}.map(String.init)
        var nameId = Int(filename[(filename.count - 2)])
        nameId = nameId! + 10
        self.anexo?.append(anexo)
        self.anexosDict[nameId!] = (id: "reemplazo", url: anexo.FileName)
        download.isHidden = false
        totalHuellas += 1
        setEdited(v: String(format: "elemts_finger_token", totalHuellas))
        triggerRulesOnChange("replaceanexo")
    }
    
    // MARK: Set - Attributes to Controller
    public func setAttributesToController(){ }
    
    // MARK: Set - Anexo
    public func setAnexo(_ anexo: FEAnexoData) {
        DispatchQueue.main.async {
            self.activity.stopAnimating()
            self.activity.isHidden = true
            self.bgHabilitado.isHidden = true
            self.download.isHidden = true
            self.genericRow.value = anexo.FileName
            self.anexosDict[1] = (id: "1", url: anexo.FileName)
            self.updateIfIsValid()
            self.layoutIfNeeded()
            
            self.genericRow.disabled = false
            self.genericRow.evaluateDisabled()
            self.setMessage("elemts_attch_recover".langlocalized(), .info)
        }
    }
    
    // MARK: Set - Preview
    public func setPreview(_ sender: Any) {
        if row.value != nil{
            let preview = VeridiumViewController(nibName: "XnWdkpfeKuOrYMm", bundle: Cnstnt.Path.framework)
            preview.fingersLeft = self.fingersLeft
            preview.fingersRight = self.fingersRight
            preview.atributos = self.atributos
            preview.modalPresentationStyle = .fullScreen
            let presenter = Presentr(presentationType: .fullScreen)
            self.formViewController()?.customPresentViewController(presenter, viewController: preview, animated: true, completion: nil)
        }
    }
    
    // MARK: Set - Download Anexo
    public func setDownloadAnexo(_ sender: Any) {
        self.formDelegate?.setStatusBarNotificationBanner("hud_downloading".langlocalized(), .info, .bottom)
        activity.startAnimating()
        activity.isHidden = false
        bgHabilitado.isHidden = false
        genericRow.disabled = true
        genericRow.evaluateDisabled()
        
        if anexo != nil{
            for ane in anexo!{
                
                self.sdkAPI?.DGSDKformatoAnexos(delegate: self, anexo: ane, estado: FormularioUtilities.shared.currentFormato.EstadoApp)
                    .then{ response in
                        self.setAnexo(response)
                    }.catch{ error in
                        self.setMessage("elemts_attch_error".langlocalized(), .info)
                }
                
            }
        }
        
    }
    
}

extension VeridiumCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{
        return self.headersView.lblMessage.text ?? ""
    }
    public func getRowEnabled()->Bool{
        return self.row.baseCell.isUserInteractionEnabled
    }
    public func getRequired()->Bool{
        return self.headersView.lblRequired.isHidden
    }
    public func getTitleLabel()->String{
        return self.headersView.lblTitle.text ?? ""
    }
    public func getSubtitleLabel()->String{
        return self.headersView.lblSubtitle.text ?? ""
    }
}
