import UIKit
import Foundation

import CommonCrypto
import Eureka

open class FirmaFadCell: Cell<String>, CellType, APIDelegate {

    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet public weak var bgHabilitado: UIView!
    @IBOutlet public weak var download: UIButton!
    @IBOutlet public weak var activity: UIActivityIndicatorView!
    @IBOutlet public weak var imgPreview: UIImageView!
    @IBOutlet public weak var imageCert: UIImageView!
    @IBOutlet weak var btnVideoTestigo: UIButton!
    @IBOutlet weak var btnTxt: UIButton!
    @IBOutlet weak var btnClean: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnCursiva: UIButton!
    
    @IBOutlet weak var btnMeta: UIButton!
    @IBOutlet weak var typeDocButton: UIButton!
    @IBOutlet weak var lblTypeDoc: UILabel!
    @IBOutlet weak var dataTxt: UITextView!
    @IBOutlet weak var btnPlay: UIButton!
    
    
    //Reemplazo
    @IBOutlet weak var reempStack: UIStackView!
    @IBOutlet weak var btnReemp: UIButton!
    @IBOutlet weak var btnCancelReemp: UIButton!

    public var atributos: Atributos_firmafad!
    public var elemento = Elemento()
    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var isServiceMessageDisplayed = 0
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var isPlayingVideo: Bool = false
    public var pathTXT: String = ""
    public var pathVideo: String = ""
    public var pathImage: String = ""
    public var  isCertified: Bool = true

    var sdkAPI : APIManager<FirmaFadCell>?
    var anexo: FEAnexoData?
    var anexoVideoTestigo: FEAnexoData?
    var anexoReempVideoTestigo: FEAnexoData?
    var anexoTXT: FEAnexoData?
    var anexoReempTXT: FEAnexoData?
    var auxVisibleViewAnimation = false
    var gps: String = ""
    var arrayAnexos: [FEAnexoData] = [FEAnexoData]()
    
    public var startReemp : Bool = false
    public var anexoReemp: FEAnexoData?
    var vvalorReemp = ""
    var vmeteReemp = ""
    var listAllowedReemp: [FEListTipoDoc] = []

    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var cert: Bool = false
    
    public var anexosDict = [ (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: ""),
                              (id: "", url: "") ]
    public var docTypeDict = [(catalogoId: 0, descripcion: ""),
                              (catalogoId: 0, description: "" )] as [Any]
        
    let guid = ConfigurationManager.shared.utilities.guid()
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        isInfoToolTipVisible = false
        toolTip = nil
        est = nil
        (row as? FirmaFadRow)?.presentationMode = nil
    }
    
    // Tipificación
    var vw: MetaAttributesViewController = MetaAttributesViewController()
    var docID: Int = 0
    var arrayMetadatos: [FEListMetadatosHijos] = []
    public var tipUnica: Int?
    public var listAllowed: [FEListTipoDoc] = []
    public var path = ""
    public var fedocumento: FEDocumento = FEDocumento()
    
    // MARK: - APIDELEGATE
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    
    // MARK: - ACTIONS
    @IBAction func downloadAnexo(_ sender: Any) {
        setDownloadAnexo(sender)
    }
    
    @IBAction func btnCleanAction(_ sender: UIButton) {
        self.imageCert.isHidden = true
        self.headersView.lblMessage.text = ""
        self.headersView.lblMessage.isHidden = true
        self.btnClean.isHidden = true
        self.btnTxt.isHidden = true
        self.btnVideoTestigo.isHidden = true
        self.imgPreview.image = nil
        self.imgPreview.isHidden = true
        
        
        if self.atributos?.tipovalidacion == "cursiva" {
            self.btnCursiva.isHidden = false
        } else {
            self.btnCall.isHidden = false
        }
        
        
        self.typeDocButton.isHidden = true
        self.lblTypeDoc.isHidden = true
        self.btnMeta.isHidden = true
        
        self.anexosDict[1] = (id: "", url: "")
        self.elemento.validacion.valor = ""
        self.elemento.validacion.valormetadato = ""
        
        self.typeDocButton.setTitle("Tipo de documento", for: .normal)
        self.lblTypeDoc.text = ""
        self.docID = 0
        
        self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
        row.value = nil
        row.validate()
        self.updateIfIsValid()
        
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader)
        triggerRulesOnProperties("alborrar")
        triggerRulesOnChange("removeanexo")
    }
    
    @IBAction func btnVideoTestigoAction(_ sender: Any) {
        if self.atributos?.tipovalidacion == "testigo"
        {
            let localPath = "\(Cnstnt.Tree.anexos)/\(self.pathImage)"
            if FCFileManager.existsItem(atPath: localPath){
                let file = ConfigurationManager.shared.utilities.read(asData: localPath)
                let preview = PreviewImagenViewMain.create(dataImage: file)
                preview.modalPresentationStyle = .overFullScreen
                self.formViewController()?.present(preview, animated: true)
            }
        } else if self.atributos?.tipovalidacion == "video"
        {
            let localPath = "\(Cnstnt.Tree.anexos)/\(self.pathVideo)"
            if FCFileManager.existsItem(atPath: localPath){
                let auxPreview = PreviewVideoFADViewController()
                auxPreview.pathPreview = self.pathVideo
                auxPreview.customInit()
                let presenter = Presentr(presentationType: .popup)
                self.formViewController()?.customPresentViewController(presenter, viewController: auxPreview, animated: true)
            }
        }
        
    }
    
    @IBAction func btnTxtAction(_ sender: Any) {
        
        let myStringFromData = "\(self.elemento._idelemento): {\nPersona que firma: \(self.elemento.validacion.personafirma)\nFecha y Hora: \(self.elemento.validacion.fecha)\nLocalización: \(self.elemento.validacion.georeferencia)\nDispositivo: \(self.elemento.validacion.dispositivo)\nAcuerdo firma: \(self.elemento.validacion.acuerdofirma)\nhashCrypt: \(self.elemento.validacion.hashFad)\nGuidtimestamp: \(self.elemento.validacion.guidtimestamp)\n}"
        let preview = PreviewTxtFADViewController()
        preview.preview = myStringFromData
        preview.customInit()
        let presenter = Presentr(presentationType: .popup)
        self.formViewController()?.customPresentViewController(presenter, viewController: preview, animated: true, completion: nil)
    }
    
    @IBAction func btnCallAction(_ sender: Any) {
        let tycController = TyCfirmaFadViewController(nibName: "TyCfirmaFadViewController", bundle: Cnstnt.Path.framework)
        self.obtainTerminos(acuerdofirma: self.atributos.acuerdofirma)
        tycController.tycFirma = self.atributos.acuerdofirma
        tycController.configure (onFinishedAction: { [unowned self] result in
            switch result {
            case .success( _):
                let controller = FirmaFadViewController(nibName: "jdHSbEmnEarRIBF", bundle: Cnstnt.Path.framework)
                controller.atributos = self.atributos
                self.obtainTerminos(acuerdofirma: self.atributos.acuerdofirma)
                controller.signatureLabel = self.atributos.acuerdofirma
                controller.row = self.row
                controller.guid = self.guid
                (row as? FirmaFadRow)?.presentationMode = .show(controllerProvider: ControllerProvider.callback {
                    return controller
                    }, onDismiss: { [weak self] vc in
                        vc.dismiss(animated: true)
                        if controller.signature != nil{
                            self?.setPath(controller.path, controller.guid)
                            self?.startReemp = false
                            self?.btnReemp.isHidden = true
                            self?.btnCancelReemp.isHidden = false
                        } else if self?.startReemp == true
                        {
                            self?.startReemp = false
                            self?.btnCancelReempAction(self?.btnCancelReemp ?? UIButton())

                        }
                    })

                if !(row as? FirmaFadRow)!.isDisabled {

                    if let presentationMode = (row as? FirmaFadRow)?.presentationMode {
                        if let controller = presentationMode.makeController(){
                            presentationMode.present(controller, row: (row as? FirmaFadRow)!, presentingController: self.formViewController()!)
                            (row as? FirmaFadRow)?.onPresentCallback?(self.formViewController()!, controller as! SelectorViewController<SelectorRow<FirmaFadCell>>)
                        } else {
                            presentationMode.present(nil, row: (row as? FirmaFadRow)!, presentingController: self.formViewController()!)
                        }
                    }
                }
                break
            case .failure(let error):
                print("ERROR: \(error)")
             break
            }
        })
        let presenter = Presentr(presentationType: .fullScreen)
        self.formViewController()?.customPresentViewController(presenter, viewController: tycController, animated: true, completion: nil)
        

    }
    
    
    @IBAction func btnCursivaAction(_ sender: UIButton, isReemp: Bool = false) {
        //Obtener el nombre del elemento:
        let nombre = self.formDelegate?.getValueFromComponent(self.atributos.personafirma) ?? ""
        let textoRow = self.formDelegate?.getElementByIdInCurrentForm(self.atributos.personafirma)
        
        var titulo = ""
        if let row = textoRow as? TextoRow {
            titulo = row.cell.headersView.txttitulo
        }
        if !nombre.isEmpty {
            let tycController = TyCfirmaFadViewController(nibName: "TyCfirmaFadViewController", bundle: Cnstnt.Path.framework)
            self.obtainTerminos(acuerdofirma: self.atributos.acuerdofirma)
            tycController.tycFirma = self.atributos.acuerdofirma
            tycController.configure (onFinishedAction: { [unowned self] result in
                switch result {
                case .success( _):
                    self.getFirmaCursiva(nombre) { [weak self] image in
                        
                        guard let self = self else {return}
                        
                        if let image = image {
                            let controller = FirmaFadViewController(nibName: "jdHSbEmnEarRIBF", bundle: Cnstnt.Path.framework)
                            controller.atributos = self.atributos
                            self.obtainTerminos(acuerdofirma: self.atributos.acuerdofirma)
                            controller.signatureLabel = self.atributos.acuerdofirma
                            controller.row = self.row
                            controller.guid = self.guid
                            
                            controller.guardarFirmaCursiva(image) {
                                
                                self.setPath(controller.path, controller.guid, isCursiva: true)
                                
                                DispatchQueue.main.async {
                                    self.imgPreview.image = image
                                    self.imgPreview.isHidden = false
                                    self.setVariableHeight(Height: 280)
                                    self.hideButtons(hide: true)
                                    
                                    if isReemp {
                                        self.btnClean.isHidden = false
                                      
                                    }
                                    //self.imageCert.isHidden = false
                              
                                    //Remplazo:
                                    self.startReemp = false
                                    self.btnReemp.isHidden = true
                                    self.btnCancelReemp.isHidden = false
                                }
                            }
                        } else {
                            //Una alerta talvez? Consultarlo con project managers
                            print("Imagen es nil.")
                        }
                    }
                    break
                case .failure(let error):
                    print("ERROR: \(error)")
                 break
                }
            })
            let presenter = Presentr(presentationType: .fullScreen)
            self.formViewController()?.customPresentViewController(presenter, viewController: tycController, animated: true, completion: nil)
        } else {
            //print("Nombre de firmante esta vacio.")
            let alert = UIAlertController(title: "Sin asignación", message: "Porfavor ingrese el nombre del firmante en el campo: \(titulo)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .destructive) { _ in
                alert.dismiss(animated: true)
            })
            let presenter = Presentr(presentationType: .popup)
            self.formViewController()?.customPresentViewController(presenter, viewController: alert, animated: true, completion: nil)
            
            ConfigurationManager.shared.utilities.writeLogger("Nombre de firmante esta vacio.\r\n", .error)
        }
    }
    
    fileprivate func hideButtons(hide: Bool) {
        self.btnCall.isHidden = hide
        self.btnCursiva.isHidden = hide
    }
    
    
    // Called Reemplazo Action
    @IBAction func btnReempAction(_ sender: UIButton) {
        self.anexoReemp = self.anexo
        self.anexoReempVideoTestigo = self.anexoVideoTestigo
        self.anexoReempTXT = self.anexoTXT
        self.vvalorReemp = self.elemento.validacion.valor
        self.vmeteReemp = self.elemento.validacion.valormetadato
        self.listAllowedReemp = listAllowed
        self.startReemp = true
        
        if self.atributos?.tipovalidacion == "cursiva" {
            self.btnCursivaAction(sender, isReemp: true)
        } else {
            self.btnCallAction(sender)
        }
    }
    // Called CancelReemplazo Action
    @IBAction func btnCancelReempAction(_ sender: UIButton) {
        self.anexo = self.anexoReemp
        self.anexoVideoTestigo = self.anexoReempVideoTestigo
        self.anexoTXT = self.anexoReempTXT
        self.anexosDict[1] = (id: "reemplazo", url: self.anexo?.FileName ?? "")
        self.anexosDict[2] = (id: "reemplazo", url: self.anexoVideoTestigo?.FileName ?? "")
        self.pathImage = self.anexoVideoTestigo?.FileName ?? ""
        self.pathVideo = self.anexoVideoTestigo?.FileName ?? ""
        self.anexoReemp = nil
        self.anexoReempVideoTestigo = nil
        self.anexoReempTXT = nil
        self.elemento.validacion.valor = self.vvalorReemp
        self.elemento.validacion.valormetadato = self.vmeteReemp
        listAllowed = self.listAllowedReemp
        self.vvalorReemp = ""
        self.vmeteReemp = ""
        self.listAllowedReemp =  []
        _ = setMetaValues()
        
        FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.anexo?.FileName ?? "" { $0.Reemplazado = false }}
        
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(self.anexo?.FileName ?? "")"){
            setEdited(v: self.anexo?.FileName ?? "")
        }
        self.btnReemp.isHidden = false
        self.btnCancelReemp.isHidden = true
    }

    // MARK: Get - Values in terms and conditions
    func obtainTerminos (acuerdofirma : String)
    {
        if acuerdofirma.contains("{{") {
            var terminos : String = acuerdofirma
            acuerdofirma.split(separator: "{").forEach{
                (aux) in
                if String(aux).contains("}}")
                {   String(aux).split(separator: "}").forEach{
                    (idElem) in
                        if String(idElem).contains("formElec_element")
                        {   let textoId = self.formDelegate?.valueElementRow(String(idElem)) ?? ""
                            terminos = terminos.replacingOccurrences(of: "{{\(idElem)}}", with: textoId )
                        }
                    }
                }
            }
            self.atributos.acuerdofirma = terminos
        }
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
        
        // MARK: icono certificado de la firma
        imageCert.isHidden = true
        imageCert.image = UIImage(named: "certificated_icon", in: Cnstnt.Path.framework, compatibleWith: nil)
        imageCert.sizeToFit()
        imageCert.isUserInteractionEnabled = false
        
        let apiObject = AttachedFormManager<FirmaFadCell>()
        apiObject.delegate = self
        
        let apiMeta = MetaFormManager<FirmaFadCell>()
        apiMeta.delegate = self
        
        sdkAPI = APIManager<FirmaFadCell>()
        
        download.addTarget(self, action: #selector(downloadAnexo(_:)), for: .touchDown)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(setPreview(_:)))
        imgPreview.isUserInteractionEnabled = true
        imgPreview.addGestureRecognizer(tapRecognizer)
        
        //#Btn Fondo/Redondo
        
       
        btnCall.layer.cornerRadius = btnCall.frame.height / 2
        btnCall.setImage(UIImage(named: "firma", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btnCall.tintColor = .white
        
        btnCursiva.layer.cornerRadius = btnCall.frame.height / 2
        btnCursiva.setImage(UIImage(named: "firmaCursiva", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btnCursiva.tintColor = .white
        
        btnClean.layer.cornerRadius = btnClean.frame.height / 2
        btnClean.setImage(UIImage(named: "ic_deshacer", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btnClean.tintColor = .white
        
        
        btnVideoTestigo.layer.cornerRadius = btnVideoTestigo.frame.height / 2
        btnVideoTestigo.setImage(UIImage(named: "ic_camera", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        
        btnTxt.layer.cornerRadius = btnTxt.frame.height / 2
        btnTxt.setImage(UIImage(named: "ic_txtFAD", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        download.backgroundColor = UIColor.lightGray
        download.layer.cornerRadius = download.frame.height / 2
        download.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)

        btnMeta.layer.cornerRadius = btnMeta.frame.height / 2
        btnMeta.setImage(UIImage(named: "ic_meta", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        
        typeDocButton.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        typeDocButton.tintColor = .white
        
        btnPlay.backgroundColor =
            ConfigurationManager.shared.isConsubanco ? Cnstnt.Color.pushEConsubanco : UIColor(hexFromString: "#1E88E5")
        btnPlay.layer.cornerRadius = btnPlay.frame.height / 2
        btnPlay.setImage(UIImage(named: "animation", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btnPlay.addTarget(self, action: #selector(onTapVideo(_:)), for: .touchDown)
        btnPlay.isHidden = true
        
        // Reemplazo
        
        btnCancelReemp.layer.cornerRadius = btnCancelReemp.frame.height / 2
        btnCancelReemp.setImage(UIImage(named: "ic_deshacer", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btnCancelReemp.isHidden = true
        
        
        btnReemp.layer.cornerRadius = btnReemp.frame.height / 2
        btnReemp.setImage(UIImage(named: "ic_sustituir", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        self.reempStack.layer.cornerRadius = self.reempStack.frame.height / 2
        
        self.reempStack.isHidden = true

        self.addSubview(vw.view)
        vw.view.isHidden = true
        vw.view.translatesAutoresizingMaskIntoConstraints = false
        
        vw.view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        vw.view.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        vw.view.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        vw.view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        vw.delegate = apiMeta.delegate
        
    }
    func setColorsElement(){
        btnCall.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        btnCursiva.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        btnClean.backgroundColor = UIColor(hexFromString: atributos?.colorborrar ?? "#1E88E5")
        btnVideoTestigo.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        btnTxt.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        btnMeta.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        typeDocButton.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        btnCancelReemp.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        btnReemp.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
    }

    //MARK: SERVICIO FIRMA CURSIVA
    fileprivate func getFirmaCursiva(_ nombre: String, completion: @escaping (UIImage?) -> () ) {
        
        let dictService = ["initialmethod":"ServiciosDigipro.ServicioFirmaCursiva.ObtenFirmaCursiva",
                           "assemblypath": "ServiciosDigipro.dll",
                           "data": ["name": "\(nombre)", "fontName": "", "size": 0, "showlog": true]
                          ] as [String : Any]
        
        ConfigurationManager.shared.assemblypath = "ServiciosDigipro.dll"
        ConfigurationManager.shared.initialmethod = "ServiciosDigipro.ServicioFirmaCursiva.ObtenFirmaCursiva"
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictService, options: .sortedKeys)
            guard let jsonService = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) else {
                print("\(#function) - No se pudo codificar json string")
                completion(nil)
                return
            }
            
            self.sdkAPI?.serviceFirmaCursivaFAD(jsonService: jsonService)
                .then { base64 in
                    
                    
                    guard let data = Data(base64Encoded: base64, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
                        completion(nil)
                        return
                    }
                    
                    if let image = UIImage(data: data) {
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
                .catch { error in
                    print("\(#function) \(error.localizedDescription)")
                    completion(nil)
                }
            
            
        } catch {
            print("\(#function) - No se pudo codificar json: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) {
        guard let _ = self.atributos, let help = atributos?.ayuda else{
            return;
        }
        toogleToolTip(help)
    }
    // MARK: Set - Preview
    @objc public func setPreview(_ sender: Any) {
        let localPath = "\(Cnstnt.Tree.anexos)/\(self.anexosDict[1].url)"
        if FCFileManager.existsItem(atPath: localPath){
            let file = ConfigurationManager.shared.utilities.read(asData: localPath)
            let preview = PreviewImagenViewMain.create(dataImage: file)
            preview.modalPresentationStyle = .overFullScreen
            self.formViewController()?.present(preview, animated: true)
        }
    }
    
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_firmafad
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        
        if self.atributos?.tipovalidacion == "ninguna" {
            self.btnVideoTestigo.isHidden = true
          
            self.btnCursiva.isHidden = true

        } else if self.atributos?.tipovalidacion == "testigo" {
            self.btnVideoTestigo.setImage(UIImage(named: "ic_testigo", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
            self.btnCursiva.isHidden = true
          
        } else if self.atributos?.tipovalidacion == "cursiva" {
            self.btnCall.isHidden = true
   
            
            self.btnCursiva.isHidden = false
        
        } else {
          
            self.btnCursiva.isHidden = true
        
        }
        
        initRules()
        setAttributesToController()
        if atributos?.titulo ?? "" == ""{ self.headersView.setOcultarTitulo(true) }else{ self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        if atributos?.subtitulo ?? "" == ""{ self.headersView.setOcultarSubtitulo(true) }else{ self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false) }
        
        
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? FirmaFadRow)?.cell.formCell()?.formViewController()?.tableView
        self.headersView.hiddenTit = false
        self.headersView.hiddenSubtit = false
        
        self.headersView.setTitleText(headersView.txttitulo)
        self.headersView.setSubtitleText(headersView.txtsubtitulo)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
        self.headersView.setMessage("")
        
        getTipificacionPermitida()
        btnPlay.isHidden = self.atributos.mostraranimacion ? false : true
        self.elemento.validacion.tipodoc = "\(self.atributos.tipodoc)"
        setColorsElement()
        
        self.headersView.translatesAutoresizingMaskIntoConstraints = false
        self.headersView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        self.headersView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.headersView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        if headersView.lblTitle.text?.count ?? 0 > 50 {
            headersView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }else if headersView.lblTitle.text?.count ?? 0 > 50{
            headersView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        }else {
            headersView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        
        self.reempStack.translatesAutoresizingMaskIntoConstraints = false
        self.reempStack.centerXAnchor.constraint(equalTo: btnClean.centerXAnchor, constant: 0).isActive = true
        self.reempStack.centerYAnchor.constraint(equalTo: btnClean.centerYAnchor, constant: 0).isActive = true
        
        //Labels
//        self.lblFirma.translatesAutoresizingMaskIntoConstraints = false
//        self.lblFirma.topAnchor.constraint(equalTo: btnCall.bottomAnchor, constant: -1).isActive = true
//        self.lblFirma.widthAnchor.constraint(equalTo: btnCall.widthAnchor).isActive = true
//        self.lblFirma.centerXAnchor.constraint(equalTo: btnCall.centerXAnchor).isActive = true
//        self.lblFirma.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
//        self.lblFirmaCursiva.translatesAutoresizingMaskIntoConstraints = false
//        self.lblFirmaCursiva.topAnchor.constraint(equalTo: btnCursiva.bottomAnchor, constant: -1).isActive = true
//        self.lblFirmaCursiva.widthAnchor.constraint(equalTo: btnCursiva.widthAnchor).isActive = true
//        self.lblFirmaCursiva.centerXAnchor.constraint(equalTo: btnCursiva.centerXAnchor).isActive = true
        
//        self.btnClean.translatesAutoresizingMaskIntoConstraints = false
//        btnClean.centerXAnchor.constraint(equalTo: activity.centerXAnchor).isActive = true
//        btnClean.centerYAnchor.constraint(equalTo: activity.centerYAnchor).isActive = true
        
        self.btnCall.translatesAutoresizingMaskIntoConstraints = false
        self.btnCall.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 10).isActive = true
        
        self.imgPreview.translatesAutoresizingMaskIntoConstraints = false
        self.imgPreview.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 10).isActive = true
        self.imgPreview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 55).isActive = true
        self.imgPreview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -55).isActive = true
        
        self.imageCert.translatesAutoresizingMaskIntoConstraints = false
        self.imageCert.centerXAnchor.constraint(equalTo: btnMeta.centerXAnchor).isActive = true
        self.imageCert.centerYAnchor.constraint(equalTo: btnMeta.centerYAnchor).isActive = true
        //self.imageCert.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 50).isActive = true
        
        self.btnVideoTestigo.translatesAutoresizingMaskIntoConstraints = false
        self.btnVideoTestigo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        self.btnVideoTestigo.topAnchor.constraint(equalTo: self.imgPreview.bottomAnchor, constant: 5).isActive = true
        
//        self.btnTxt.translatesAutoresizingMaskIntoConstraints = false
//        self.btnTxt.leadingAnchor.constraint(equalTo: btnVideoTestigo.trailingAnchor, constant: -6).isActive = true
        //self.btnTxt.centerXAnchor.constraint(equalTo: self.btnVideoTestigo.centerXAnchor).isActive = true
        //self.btnTxt.centerYAnchor.constraint(equalTo: btnVideoTestigo.centerYAnchor).isActive = true
        
        //self.btnTxt.topAnchor.constraint(equalTo: self.btnVideoTestigo.bottomAnchor, constant: 5).isActive = true
//        self.btnTxt.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 75).isActive = true
        
//        self.lblVideoTestigo.translatesAutoresizingMaskIntoConstraints = false
//        self.lblVideoTestigo.topAnchor.constraint(equalTo: self.btnVideoTestigo.bottomAnchor, constant: 5).isActive = true
//        self.lblVideoTestigo.heightAnchor.constraint(equalToConstant: 10).isActive = true
//        self.lblVideoTestigo.centerXAnchor.constraint(equalTo: self.btnVideoTestigo.centerXAnchor).isActive = true
//        self.lblVideoTestigo.widthAnchor.constraint(equalTo: self.btnVideoTestigo.widthAnchor).isActive = true
        
//        self.lblJson.translatesAutoresizingMaskIntoConstraints = false
//        self.lblJson.topAnchor.constraint(equalTo: self.btnTxt.bottomAnchor, constant: 5).isActive = true
//        self.lblJson.heightAnchor.constraint(equalToConstant: 10).isActive = true
//        self.lblJson.centerXAnchor.constraint(equalTo: self.btnTxt.centerXAnchor).isActive = true
//        self.lblJson.widthAnchor.constraint(equalTo: self.btnTxt.widthAnchor).isActive = true
        
        
        self.btnClean.translatesAutoresizingMaskIntoConstraints = false
        self.btnClean.topAnchor.constraint(equalTo: self.btnVideoTestigo.bottomAnchor, constant: 5).isActive = true
        
//        self.lblEliminar.translatesAutoresizingMaskIntoConstraints = false
//        self.lblEliminar.topAnchor.constraint(equalTo: self.btnClean.bottomAnchor, constant: 5).isActive = true
//        self.lblEliminar.heightAnchor.constraint(equalToConstant: 10).isActive = true
//        self.lblEliminar.centerXAnchor.constraint(equalTo: self.btnClean.centerXAnchor).isActive = true
//        self.lblEliminar.widthAnchor.constraint(equalTo: self.btnClean.widthAnchor).isActive = true
        
        self.download.translatesAutoresizingMaskIntoConstraints = false
        self.download.centerXAnchor.constraint(equalTo: self.btnClean.centerXAnchor).isActive = true
        self.download.centerYAnchor.constraint(equalTo: self.btnClean.centerYAnchor).isActive = true
        
        self.reempStack.translatesAutoresizingMaskIntoConstraints = false
        self.reempStack.widthAnchor.constraint(equalTo: self.btnClean.widthAnchor).isActive = true
        self.reempStack.heightAnchor.constraint(equalTo: self.btnClean.heightAnchor).isActive = true
        self.reempStack.layer.cornerRadius = self.reempStack.frame.height / 2
        
        
        self.typeDocButton.translatesAutoresizingMaskIntoConstraints = false
        self.typeDocButton.topAnchor.constraint(equalTo: self.imgPreview.bottomAnchor, constant: 35).isActive = true
        self.typeDocButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        self.typeDocButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        self.typeDocButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader)
    }
    
    // MARK: Set - Ayuda
    @objc func onTapVideo(_ sender: Any) {
        guard let localPath = Cnstnt.Path.framework?.path(forResource: "iOs Firma de Documentos", ofType: "mp4") else {
            debugPrint("video firma not found")
            return
        }
        let auxPreview = PreviewVideoFADViewController()
        auxPreview.pathPreview = localPath
        auxPreview.isAnimation = true
        auxPreview.titleAnimation = "firmfad_animation".langlocalized()
        auxPreview.customInit()
        auxPreview.onTapVideo()
        let presenter = Presentr(presentationType: .popup)
        self.formViewController()?.customPresentViewController(presenter, viewController: auxPreview, animated: true)
    }
    
    override open func update() {
        super.update()
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        if isInfoToolTipVisible{
            toolTip!.dismiss()
            isInfoToolTipVisible = false
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
            self.elemento.validacion.tipodoc = "\(self.atributos.tipodoc)"
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
        
        tipodoc.setValue("\(String(fedocumento.TipoDocID ?? 0))", forKey: "\(fedocumento.guid)");
        self.anexosDict[1] = (id: "\(0)", url: "\(fedocumento.Nombre)")
        
        self.elemento.validacion.valor = tipodoc.toJsonString()
        self.elemento.validacion.valormetadato = meta.toJsonString()
        self.setEdited(v: fedocumento.Nombre)
        
        //if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
    }
    // MARK: - Set Permiso Tipificar
    public func setPermisoTipificar(_ bool: Bool){
        if bool{
            self.typeDocButton.isHidden = false
            //self.btnMeta.isHidden = false
            self.lblTypeDoc.isHidden = false
        }else{
            self.typeDocButton.isHidden = true
            self.btnMeta.isHidden = true
            self.lblTypeDoc.isHidden = true
        }
    }
    // MARK: - Get All Tipyfication options
    public func getTipificacionPermitida(){
        // Getting tipificacion única
        let tipificacionUnica = Int(atributos?.tipodoc ?? "0" )
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
    
    // MARK: - Execute animation
    public func executeAnimation(){
        self.onTapVideo(Any.self)
    }
    
    // MARK: - Save data FAD
    public func saveValuesFAD(){
        let nombreFirma = self.formDelegate?.getValueFromComponent(self.atributos.personafirma) ?? ""
        self.obtainTerminos(acuerdofirma: self.atributos.acuerdofirma)
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd H:mm:ss.SS"
        let dateInfo = formatter.string(from: date)
        
        let device = Device()
        let deviceInfo = "\(device.description), iOS \(device.systemVersion ?? "")"
        let gps = self.formDelegate? .obtainerLocation() ?? ""
        
        self.atributos.nombrefirmante = nombreFirma
        self.atributos.fecha = dateInfo
        self.atributos.georeferencia = gps
        self.atributos.dispositivo = deviceInfo
        self.atributos.acuerdofirma = self.atributos.acuerdofirma
        
        self.elemento.validacion.personafirma = nombreFirma
        self.elemento.validacion.fecha = dateInfo
        self.elemento.validacion.georeferencia = gps
        self.elemento.validacion.dispositivo = deviceInfo
        self.elemento.validacion.acuerdofirma = self.atributos.acuerdofirma
    }
}

// MARK: - ATTACHEDFORMDELEGATE
extension FirmaFadCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "FirmaFad"
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
            self.row.reload()
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
            toolTip?.show(forView: self.headersView.btnInfo, withinSuperview: (row as? FirmaFadRow)?.cell.formCell()?.formViewController()?.tableView)
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
    // MARK: Set - Path
    public func setPath(_ p: String, _ g: String, isCursiva: Bool = false){
        path = p
        let doc = FEDocumento()
        doc.guid = "\(g)"
        doc.isKindImage = true
        doc.Ext = "png"
        doc.ImageString = ""
        doc.Nombre = path
        doc.Path = path
        doc.URL = "\(Cnstnt.Tree.anexos)/\(path)"
        doc.TipoDoc = ""
        doc.TipoDocID = 0

        for list in self.listAllowed {
            if tipUnica == nil{ break }
            if list.CatalogoId != tipUnica{ continue }
            doc.TipoDocID = tipUnica ?? 0
            doc.TipoDoc = list.Descripcion
            list.current = 0 // temporal test
            if list.current != 0 {
                if list.current >= list.max{
                    setMessage(String(format: "elemts_doc_maxtyp".langlocalized(), list.Descripcion, String(list.max)), .error)
                    //return
                }
            }
            list.current += 1
        }
        if self.startReemp {
            FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.anexoReemp?.FileName { $0.Reemplazado = true }}
            doc.DocID = self.anexoReemp?.DocID ?? 0
        }
        self.docID = doc.TipoDocID ?? 0
        self.fedocumento = doc
        let localPath =  "\(Cnstnt.Tree.anexos)/\(path)"
        if FCFileManager.existsItem(atPath: localPath){
            let file = ConfigurationManager.shared.utilities.read(asData: localPath)
            self.imgPreview.image = UIImage(data: file ?? Data())
            self.imgPreview.isHidden = false
        }
        
        setEdited(v: path)
        self.setVariableHeight(Height: 300)
        self.btnClean.isHidden = false
        if atributos?.tipovalidacion != "ninguna" {
            self.btnVideoTestigo.isHidden = false
        }
        
        
        if isCursiva {
            self.btnVideoTestigo.isHidden = true
            self.btnMeta.isHidden = true
            self.btnTxt.isHidden = true
        } else {
            self.btnTxt.isHidden = false
        }
        
        self.hideButtons(hide: true)
        
        if tipUnica == nil{ setPermisoTipificar(atributos?.permisotipificar ?? false) }
        //if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
    }
    // MARK: Set - Edited
    public func setEdited(v: String){
        if v != ""{
            self.btnClean.isHidden = false
            self.hideButtons(hide: true)
            if tipUnica == nil && atributos?.permisotipificar ?? false == false{
                if v.contains("_1_"){
                    self.setValue(v: v)
                }
            }else{
                if tipUnica != nil{
                    if v.contains("_1_"){
                        self.setValue(v: v)
                    }
                }else{
                    if atributos?.permisotipificar ?? false{
                        if (self.elemento.validacion.valor != "" && self.elemento.validacion.valormetadato != ""){
                            self.setPermisoTipificar(atributos?.permisotipificar ?? false)
                            if v.contains("_1_"){
                                self.setValue(v: v)
                            }
                        }
                    }
                }
            }
            if row.value != nil || row.value != ""{ triggerRulesOnChange("notempty") }
        }else{
            self.anexosDict[1] = (id: "", url: "")
            self.docTypeDict[1] = (catalogoId: 0, descripcion: "")
            
            self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
            row.value = nil
            self.updateIfIsValid()
            self.setVariableHeight(Height: 100)
            if row.value == nil || row.value == ""{ triggerRulesOnChange("empty") }
        }
        
        // MARK: - Setting estadisticas
        setEstadistica()
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = v.replaceLineBreakEstadistic()
        est!.KeyStroke += 1
        elemento.estadisticas = est!
        let fechaValorFinal = Date.getTicks()
        self.setEstadisticaV2()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = v.replaceLineBreakEstadistic()
        self.estV2!.Cambios += 1
        elemento.estadisticas2 = estV2!
        
        triggerRulesOnChange("addanexo")
        triggerEvent("alterminarcaptura")
    }
    public func setEdited(v: String, isRobot: Bool) { }
    public func setValue(v: String){
        
        if isCertified && (self.atributos?.tipovalidacion == "testigo" || self.atributos?.tipovalidacion == "video") {
            self.imageCert.isHidden = false
        }
        
        let tipodoc: NSMutableDictionary = NSMutableDictionary();
        tipodoc.setValue("\(String(fedocumento.TipoDocID ?? 0))", forKey: "\(fedocumento.guid)");
        if anexosDict[1].id == "reemplazo"{}else{
            self.anexosDict[1] = (id: "\(0)", url: "\(fedocumento.Nombre)")
        }
        if !self.pathImage.isEmpty || !self.pathVideo.isEmpty{
            if anexosDict[2].id == "reemplazo"{}else{
                if self.pathVideo.isEmpty{
                   self.anexosDict[2] = (id: "1", url: self.pathImage)
                }else{
                    self.anexosDict[2] = (id: "1", url: self.pathVideo)
                }
            }

            self.anexosDict[3] = (id: "2", url: self.pathTXT)
            self.elemento.validacion.valor = tipodoc.toJsonString()
            self.elemento.validacion.valormetadato = tipodoc.toJsonString()
            self.elemento.validacion.tipodoc = "\(self.atributos.tipodoc)"
        }else{
            self.elemento.validacion.valor = tipodoc.toJsonString()
            self.elemento.validacion.valormetadato = tipodoc.toJsonString()
            self.elemento.validacion.tipodoc = "\(self.atributos.tipodoc)"
        }

        if anexosDict[1].id == "reemplazo"{}else{
            self.anexosDict[1] = (id: "1", url: v)
            self.docTypeDict[1] = (catalogoId: self.fedocumento.TipoDocID, descripcion: self.fedocumento.TipoDoc)
        }

        self.setVariableHeight(Height: 380)
        let localPath = "\(Cnstnt.Tree.anexos)/\(v)"
        let localPathOCR = "\(Cnstnt.Tree.anexos)/\(v)"
        if FCFileManager.existsItem(atPath: localPath){
            let file = ConfigurationManager.shared.utilities.read(asData: localPathOCR)
            self.imgPreview.image = UIImage(data: file!)
            self.imgPreview.isHidden = false
        }
        if localPathOCR.contains("Anverso") || localPathOCR.contains("Reverso"){
            if FCFileManager.existsItem(atPath: localPath){
                let file = ConfigurationManager.shared.utilities.read(asData: localPath)
                self.imgPreview.image = UIImage(data: file!)
                self.imgPreview.isHidden = false
            }
        }
        self.headersView.lblTitle.textColor = UIColor.black
        row.value = v
        
        self.updateIfIsValid()
    }
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
                self.headersView.lblMessage.text = ""
                self.headersView.lblMessage.isHidden = true
//                self.viewValidation.backgroundColor = Cnstnt.Color.gray

                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? FirmaFadRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.validado = false
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            }else{
                self.headersView.lblMessage.text = ""
                self.headersView.lblMessage.isHidden = true
//                self.viewValidation.backgroundColor = UIColor.green

                resetValidation()
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? FirmaFadRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.attData = ((row as? FirmaFadRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.attData = ((row as? FirmaFadRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                }else{
                    self.elemento.validacion.validado = false
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                  
                }
            }
        }else{
            // Throw the first error printed in the label
            if (self.row.validationErrors.count) > 0{
                self.headersView.lblMessage.text = "  \(self.row.validationErrors[0].msg)  "
                let colors = self.formDelegate?.getColorsErrors(.error)
                self.headersView.lblMessage.backgroundColor = .clear
                self.headersView.lblMessage.textColor = Cnstnt.Color.red2
                self.headersView.lblMessage.isHidden = false
            }

            self.elemento.validacion.anexos = [(id: String, url: String)]()
            self.elemento.validacion.anexos = (row as? FirmaFadRow)?.cell.anexosDict
            self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
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
        if rulesOnChange.count > 0{
            if row.value == nil || row.value == ""{ triggerRulesOnChange("empty") }
            if row.value != nil || row.value != ""{ triggerRulesOnChange("notempty") }
        }
        if rulesOnProperties.count > 0{
            if self.atributos?.habilitado ?? false{ triggerRulesOnProperties("enabled") }else{ triggerRulesOnProperties("notenabled") }
            if self.atributos?.visible ?? false{
                triggerRulesOnProperties("visible")
                triggerRulesOnProperties("visiblecontenido")
            }else{
                triggerRulesOnProperties("notvisible")
                triggerRulesOnProperties("notvisiblecontenido")
            }
        }
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
    public func setMathematics(_ bool: Bool, _ id: String) {}
    
}

// MARK: - ATTACHEDFORMDELEGATE
extension FirmaFadCell: AttachedFormDelegate{
    public func setAnexoOption(_ anexo: FEAnexoData) {
        
    }
    
    func setMetaValues() -> Bool{
        let vvalor = self.elemento.validacion.valor.data(using: .utf8)
        let vmeta = self.elemento.validacion.valormetadato.data(using: .utf8)
        do {
            let tipodoc = (try JSONSerialization.jsonObject(with: vvalor!, options: []) as? [String: Any])!
            let metadoc = (try JSONSerialization.jsonObject(with: vmeta!, options: []) as? [String: Any])!
            for tipo in tipodoc{
                guard let ane = self.anexo else{ return false }
                if ane.Guid == FormularioUtilities.shared.currentFormato.Guid{
                    let fedoc = FEDocumento()
                    fedoc.guid = "\(tipo.key)"
                    fedoc.isKindImage = true
                    let fileExtension = ane.FileName.fileExtension().lowercased()
                    fedoc.Ext = fileExtension
                    fedoc.ImageString = ""
                    fedoc.Nombre = ane.FileName.cleanAnexosDocPath()
                    fedoc.Path = ane.FileName.cleanAnexosDocPath()
                    fedoc.URL = ane.FileName
                    fedoc.TipoDocID = Int(tipo.value as? String ?? "0") ?? 0
                    if ane.TipoDocID == 0{
                        ane.TipoDocID = Int(tipo.value as? String ?? "0") ?? 0
                    }
                    for docType in listAllowed{
                        if ane.TipoDocID == docType.CatalogoId{
                            fedoc.TipoDoc = docType.Descripcion
                        }
                    }
                    self.docID = fedoc.TipoDocID ?? 0
                    for meta in metadoc{
                        for mm in meta.value as? [String: Any] ?? [:]{
                            let m = FEListMetadatosHijos()
                            m.Nombre = mm.key
                            m.NombreCampo = mm.value as? String ?? ""
                            fedoc.Metadatos.append(m)
                        }
                    }
                    self.typeDocButton.setTitle("\(fedoc.TipoDoc)", for: .normal)
                    self.lblTypeDoc.text = "\(fedoc.TipoDoc)"
                    self.fedocumento = fedoc
                    //if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
                }
            }
            return true

        } catch { return false }
    }
    // MARK: Set - Local Anexo
    public func didSetLocalAnexo(_ feAnexo: [FEAnexoData]){
        _ = setMetaValues()
        for ane in feAnexo{
            if ane.FileName.contains("_1_"){
                self.anexo = ane
                if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(ane.FileName)"){
                    setEdited(v: "\(ane.FileName)")
                }else{
                    self.setMessage("elemts_attch_server".langlocalized(), .info)
                }
            }else if ane.FileName.contains("_2_"){
                self.btnVideoTestigo.isHidden = false
                self.anexosDict[2] = (id: "2", url: ane.FileName)
                self.pathVideo = ane.FileName
            }else if ane.FileName.contains("_3_"){
                self.btnVideoTestigo.isHidden = false
                self.pathImage = ane.FileName
                self.anexosDict[2] = (id: "2", url: ane.FileName)
            }else if ane.FileName.contains("_4_"){
                self.btnTxt.isHidden = false
                self.pathTXT = ane.FileName
                self.anexosDict[2] = (id: "3", url: ane.FileName)
            }
            
        }


    }
    public func didSetLocalAnexo(_ feAnexo: FEAnexoData){

        _ = setMetaValues()
        if feAnexo.FileName.contains("_1_"){
            self.anexo = feAnexo
            if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(feAnexo.FileName)"){
                setEdited(v: "\(feAnexo.FileName)")
            }else{
                self.setMessage("elemts_attch_server".langlocalized(), .info)
            }
        }

    }
    
    // MARK: Set - Anexo Option
    public func setAnexoOption(_ anexo: [FEAnexoData]){
        
        self.download.isHidden = false
        self.btnCall.isHidden = true
   
        self.btnCursiva.isHidden = true

        self.arrayAnexos = anexo
        self.imgPreview.image = UIImage(named: "download-attachment", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.imgPreview.isHidden = false
        self.setVariableHeight(Height: 380)
        for a in anexo{
            if a.FileName.contains("_1_"){
                self.anexo = a
                self.anexosDict[1] = (id: "reemplazo", url: a.FileName)
                triggerRulesOnChange("replaceanexo")
            }else if a.FileName.contains("_2_"){
                self.anexoVideoTestigo = a
                self.anexosDict[0] = (id: "reemplazo", url: a.FileName)
                triggerRulesOnChange("replaceanexo")
                self.pathVideo = a.FileName
            }else if a.FileName.contains("_3_"){
                self.anexoVideoTestigo = a
                self.anexosDict[0] = (id: "reemplazo", url: a.FileName)
                triggerRulesOnChange("replaceanexo")
                self.pathImage = a.FileName
            }else if a.FileName.contains("_4_"){
                self.anexoTXT = a
                self.anexosDict[2] = (id: "reemplazo", url: a.FileName)
                triggerRulesOnChange("replaceanexo")
                self.pathTXT = a.FileName
            }else{}
        }


        
    }
    
    // MARK: Set - Attributes to Controller
    public func setAttributesToController(){ }
    
    // MARK: Set - Anexo
    public func setAnexo(_ anexo: FEAnexoData) {
        bgHabilitado.isHidden = true
        (row as? FirmaFadRow)?.disabled = false
        (row as? FirmaFadRow)?.evaluateDisabled()
        _ = setMetaValues()
        
        if anexo.FileName.contains("_2_"){
           self.pathVideo = anexo.FileName
        }else if anexo.FileName.contains("_3_"){
            self.pathImage = anexo.FileName
        }else if anexo.FileName.contains("_4_"){
           self.pathTXT = anexo.FileName
        }
        
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
            setEdited(v: "\(anexo.FileName)")
            self.setMessage("elemts_attch_recover".langlocalized(), .info)
        }
        self.reempStack.isHidden = self.anexo?.DocID != 0 ? false : true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(999)) {
            self.download.isHidden = true
            self.headersView.lblMessage.isHidden = true
            
            if self.atributos?.tipovalidacion != "cursiva" {
                self.btnVideoTestigo.isHidden = false
                self.btnTxt.isHidden = false
            }
          
            //self.imgPreview.gestureRecognizers?.forEach(self.imgPreview.removeGestureRecognizer)
        }
    }
    
    // MARK: Set - Download Anexo
    public func setDownloadAnexo(_ sender: Any) {
        self.setMessage("hud_downloading".langlocalized(), .info)
        bgHabilitado.isHidden = false
        (row as? FirmaFadRow)?.disabled = true
        (row as? FirmaFadRow)?.evaluateDisabled()
    
        for ane in self.arrayAnexos{
            self.sdkAPI?.DGSDKformatoAnexos(delegate: self, anexo: ane, estado: FormularioUtilities.shared.currentFormato.EstadoApp)
                .then{ response in
                    self.anexo?.Descargado = true
//                    self.btnTxt.isHidden = true
//                    self.btnVideoTestigo.isHidden = true
                    self.setAnexo(response)
                }.catch{ error in
                    self.bgHabilitado.isHidden = true
                    (self.row as? FirmaFadRow)?.disabled = false
                    (self.row as? FirmaFadRow)?.evaluateDisabled()
                    self.setMessage("elemts_attch_error".langlocalized(), .info)
            }
        }
        if self.anexo != nil{

        }
    }
   
}


extension FirmaFadCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{
        return self.headersView.lblMessage.text ?? ""
    }
    public func getRowEnabled()->Bool{
        return true//self.row.baseCell.isUserInteractionEnabled
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

extension FirmaFadCell: MetaFormDelegate{
    public func didClose() {
        self.closeMetaAction(Any.self)
    }
    
    public func didSave() {
        self.saveMetaAction(Any.self)
        self.closeMetaAction(Any.self)
    }
    
    public func didUpdateData(_ tipoDoc: String, _ idDoc: Int) {
        self.typeDocButton.setTitle("\(tipoDoc)", for: .normal)
        self.lblTypeDoc.text = "\(tipoDoc)"
        self.docID = idDoc
    }
    
}
