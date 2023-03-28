import Foundation

import CommonCrypto
import Eureka

open class FirmaCell: Cell<String>, CellType, APIDelegate {
    
    // MARK: - IBOUTLETS AND VARS
    @IBOutlet public weak var lblRequired: UILabel!
    @IBOutlet public weak var viewValidation: UIView!
    @IBOutlet public weak var bgHabilitado: UIView!
    @IBOutlet public weak var lblMessage: UILabel!
    @IBOutlet public weak var lblTitle: UILabel!
    @IBOutlet public weak var lblSubtitle: UILabel!
    @IBOutlet public weak var btnInfo: UIButton!
    @IBOutlet public weak var download: UIButton!
    @IBOutlet public weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var imgPreview: UIImageView!
    
    @IBOutlet weak var btnClean: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnPreview: UIButton!
    
    @IBOutlet weak var btnMeta: UIButton!
    @IBOutlet weak var typeDocButton: UIButton!
    @IBOutlet weak var lblTypeDoc: UILabel!
    
    public var atributos: Atributos_firma!
    public var elemento = Elemento()
    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var isServiceMessageDisplayed = 0
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var isPlayingVideo: Bool = false

    var sdkAPI : APIManager<FirmaCell>?
    var anexo: FEAnexoData?
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    
    public var anexosDict = [ (id: "", url: ""),
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
        (row as? FirmaRow)?.presentationMode = nil
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
        self.lblMessage.text = ""
        self.lblMessage.isHidden = true
        self.btnClean.isHidden = true
        self.btnPreview.isHidden = true
        self.imgPreview.image = nil
        self.imgPreview.isHidden = true
        self.btnCall.isHidden = false
        
        self.typeDocButton.isHidden = true
        self.lblTypeDoc.isHidden = true
        self.btnMeta.isHidden = true
        
        self.anexosDict[1] = (id: "", url: "")
        self.elemento.validacion.valor = ""
        self.elemento.validacion.valormetadato = ""
        
        self.typeDocButton.setTitle("Tipo de documento", for: .normal)
        self.lblTypeDoc.text = ""
        self.docID = 0
        
        for list in self.listAllowed{ if list.current != 0{ list.current = 0 } }
        
        self.lblTitle.textColor =  self.lblRequired.isHidden ?  UIColor.black : UIColor.red
        row.value = nil
        row.validate()
        self.updateIfIsValid()
        
        self.setVariableHeight(Height: 110)
        triggerRulesOnProperties("alborrar")
        triggerRulesOnChange("removeanexo")
    }
    
    @IBAction func btnCallAction(_ sender: Any) {
        
        let controller = FirmaViewController(nibName: "lDPqDIgEpijhPZI", bundle: Cnstnt.Path.framework)
        controller.signatureLabel = self.atributos.acuerdofirma
        controller.row = self.row
        controller.atributos = atributos
        (row as? FirmaRow)?.presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return controller
            }, onDismiss: { [weak self] vc in
                vc.dismiss(animated: true)
                if controller.signature != nil{
                    self?.setPath(controller.path, controller.guid)
                }
            })
        
        if !(row as? FirmaRow)!.isDisabled {
           
            if let presentationMode = (row as? FirmaRow)?.presentationMode {
                if let controller = presentationMode.makeController(){
                    presentationMode.present(controller, row: (row as? FirmaRow)!, presentingController: self.formViewController()!)
                    (row as? FirmaRow)?.onPresentCallback?(self.formViewController()!, controller as! SelectorViewController<SelectorRow<FirmaCell>>)
                } else {
                    presentationMode.present(nil, row: (row as? FirmaRow)!, presentingController: self.formViewController()!)
                }
            }
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
        
        let apiObject = AttachedFormManager<FirmaCell>()
        apiObject.delegate = self
        
        let apiMeta = MetaFormManager<FirmaCell>()
        apiMeta.delegate = self
        
        sdkAPI = APIManager<FirmaCell>()
        
        btnInfo.layer.cornerRadius = 13
        btnInfo.layer.borderColor = UIColor.gray.cgColor
        btnInfo.layer.borderWidth = 1
        btnInfo.addTarget(self, action: #selector(setAyuda(_:)), for: .touchDown)
        btnInfo.isHidden = true
        
        download.addTarget(self, action: #selector(downloadAnexo(_:)), for: .touchDown)
        
        
        //#Btn Fondo/Redondo
        btnCall.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        btnCall.layer.cornerRadius = btnCall.frame.height / 2
        btnCall.setImage(UIImage(named: "ic_sign", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        btnClean.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        btnClean.layer.cornerRadius = btnClean.frame.height / 2
        btnClean.setImage(UIImage(named: "ic_clean", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        download.backgroundColor = UIColor.lightGray
        download.layer.cornerRadius = download.frame.height / 2
        download.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        btnPreview.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        btnPreview.layer.cornerRadius = btnClean.frame.height / 2
        btnPreview.setImage(UIImage(named: "ic_eye", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        btnPreview.addTarget(self, action: #selector(setPreview(_:)), for: .touchUpInside)
        
        lblRequired.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 30.0)
        lblMessage.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        lblTitle.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        lblSubtitle.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        btnInfo.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 15.0)
        
        btnMeta.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        btnMeta.layer.cornerRadius = btnMeta.frame.height / 2
        btnMeta.setImage(UIImage(named: "ic_meta", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        typeDocButton.backgroundColor = UIColor(hexFromString: atributos?.colorfirma ?? "#1E88E5")
        typeDocButton.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        typeDocButton.tintColor = .white
        
        self.addSubview(vw.view)
        vw.view.isHidden = true
        vw.view.translatesAutoresizingMaskIntoConstraints = false
        
        vw.view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        vw.view.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        vw.view.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        vw.view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        vw.delegate = apiMeta.delegate
    }
    // MARK: Set - Download Anexo
    @objc public func setDownloadAnexo(_ sender: Any) {
        self.setMessage("hud_downloading".langlocalized(), .info)
        bgHabilitado.isHidden = false
        (row as? FirmaRow)?.disabled = true
        (row as? FirmaRow)?.evaluateDisabled()
        if self.anexo != nil{
            self.sdkAPI?.DGSDKformatoAnexos(delegate: self, anexo: self.anexo!, estado: FormularioUtilities.shared.currentFormato.EstadoApp)
                .then{ response in
                    self.setAnexo(response)
                }.catch{ error in
                    self.bgHabilitado.isHidden = true
                    (self.row as? FirmaRow)?.disabled = false
                    (self.row as? FirmaRow)?.evaluateDisabled()
                    self.setMessage("elemts_attch_error".langlocalized(), .info)
            }
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
        atributos = obj.atributos as? Atributos_firma
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        
        initRules()
        setAttributesToController()
        if atributos?.titulo ?? "" == ""{ setOcultarTitulo(true) }else{ setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        if atributos?.subtitulo ?? "" == ""{ setOcultarSubtitulo(true) }else{ setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false) }
        setHeightFromTitles()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        setAlignment(atributos?.alineadotexto ?? "")
        setDecoration(atributos?.decoraciontexto ?? "")
        setTextStyle(atributos?.estilotexto ?? "")
        setInfo()
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
        
        if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
    }
    // MARK: - Set Permiso Tipificar
    public func setPermisoTipificar(_ bool: Bool){
        if bool{
            self.typeDocButton.isHidden = false
            self.btnMeta.isHidden = false
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

// MARK: - ATTACHEDFORMDELEGATE
extension FirmaCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Firma"
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
        self.atributos?.estilotexto = style
        self.lblTitle.font = self.lblTitle.font.setStyle(style)
        self.lblSubtitle.font = self.lblSubtitle.font.setStyle(style)
    }
    // MARK: Set - Decoration
    public func setDecoration(_ decor: String){
        self.atributos?.decoraciontexto = decor
        self.lblTitle.attributedText = self.lblTitle.text?.setDecoration(decor)
        self.lblSubtitle.attributedText = self.lblSubtitle.text?.setDecoration(decor)
    }
    // MARK: Set - Alignment
    public func setAlignment(_ align: String){
        self.atributos?.alineadotexto = align
        self.lblTitle.textAlignment = self.lblTitle.setAlignment(align)
        self.lblSubtitle.textAlignment = self.lblSubtitle.setAlignment(align)
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
        self.lblTitle.text = text
    }
    // MARK: Set - Subtitle Text
    public func setSubtitleText(_ text:String){
        self.lblSubtitle.text = text
    }
    // MARK: Set - Height From Titles
    public func setHeightFromTitles(){
        let ttl = lblTitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        let sttl = lblSubtitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        lblTitle.numberOfLines = ttl
        lblSubtitle.numberOfLines = sttl
        var httl: CGFloat = 0
        var hsttl: CGFloat = 0
        if atributos != nil{
            if atributos?.ocultartitulo ?? false{ if ttl == 0{ httl = -self.lblTitle.font.lineHeight } }else{ httl = (CGFloat(ttl) * self.lblTitle.font.lineHeight) - self.lblTitle.font.lineHeight }
            if atributos?.ocultarsubtitulo ?? false{ if sttl == 0{ hsttl = -self.lblSubtitle.font.lineHeight } }else{ hsttl = (CGFloat(sttl) * self.lblSubtitle.font.lineHeight) - self.lblSubtitle.font.lineHeight }
        }
        let h: CGFloat = httl + hsttl
        let hh = (row as? FirmaRow)?.cell.contentView.frame.size.height ?? 0 + h
        setVariableHeight(Height: hh)
    }
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){ }
    // MARK: Set - Info
    public func setInfo(){
        if atributos?.ayuda != nil, !(atributos?.ayuda.isEmpty)!, atributos?.ayuda != ""{
            self.btnInfo.isHidden = false
        }
    }
    
    public func toogleToolTip(_ help: String){
        if isInfoToolTipVisible{
            toolTip?.dismiss()
            isInfoToolTipVisible = false
        }else{
            toolTip = EasyTipView(text: help, preferences: EasyTipView.globalPreferences)
            toolTip?.show(forView: self.btnInfo, withinSuperview: (row as? FirmaRow)?.cell.formCell()?.formViewController()?.tableView)
            isInfoToolTipVisible = true
        }
    }
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){
        // message, valid, alert, error
        if string == ""{ self.lblMessage.text = ""; self.lblMessage.isHidden = true; return; }
        DispatchQueue.main.async {
            self.lblMessage.text = "  \(string)  "
            let colors = self.formDelegate?.getColorsErrors(state)
            self.lblMessage.backgroundColor = colors![0]
            self.lblMessage.textColor = colors![1]
            self.lblMessage.isHidden = false
            self.layoutIfNeeded()
        }
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
    // MARK: Set - OcultarSubtitulo
    public func setOcultarSubtitulo(_ bool: Bool){
        self.atributos?.ocultarsubtitulo = bool
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
    public func setPath(_ p: String, _ g: String){
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
        
        for list in self.listAllowed{
            if tipUnica == nil{ break }
            if list.CatalogoId != tipUnica{ continue }
            doc.TipoDocID = tipUnica ?? 0
            doc.TipoDoc = list.Descripcion
            list.current = 0 // temporal test
            if list.current != 0{
                if list.current >= list.max{
                    setMessage(String(format: "elemts_doc_maxtyp".langlocalized(), list.Descripcion, String(list.max)), .error)
                    return
                }
            }
            list.current += 1
        }
        self.docID = doc.TipoDocID ?? 0
        self.fedocumento = doc
        let localPath = "\(Cnstnt.Tree.anexos)/\(path)"
        if FCFileManager.existsItem(atPath: localPath){
            let file = ConfigurationManager.shared.utilities.read(asData: localPath)
            self.imgPreview.image = UIImage(data: file!)
            self.imgPreview.isHidden = false
        }
        
        setEdited(v: path)
        self.setVariableHeight(Height: 250)
        self.btnClean.isHidden = false
        self.btnPreview.isHidden = false
        self.btnCall.isHidden = true
        
        if tipUnica == nil{ setPermisoTipificar(atributos?.permisotipificar ?? false) }
        if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
    }
    // MARK: Set - Edited
    public func setEdited(v: String){
        if v != ""{
            self.btnClean.isHidden = false
            self.btnPreview.isHidden = false
            self.btnCall.isHidden = true
            if tipUnica == nil && atributos?.permisotipificar ?? false == false{
                self.setValue(v: v)
            }else{
                if tipUnica != nil{
                    self.setValue(v: v)
                }else{
                    if atributos?.permisotipificar ?? false{
                        if (self.elemento.validacion.valor != "" && self.elemento.validacion.valormetadato != ""){
                            self.setPermisoTipificar(atributos?.permisotipificar ?? false)
                            self.setValue(v: v)
                        }
                    }
                }
            }
            if row.value != nil || row.value != ""{ triggerRulesOnChange("notempty") }
        }else{
            self.anexosDict[1] = (id: "", url: "")
            self.docTypeDict[1] = (catalogoId: 0, descripcion: "")
            
            self.lblTitle.textColor =  self.lblRequired.isHidden ?  UIColor.black : UIColor.red
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
        let tipodoc: NSMutableDictionary = NSMutableDictionary();
        tipodoc.setValue("\(String(fedocumento.TipoDocID ?? 0))", forKey: "\(fedocumento.guid)");
        self.anexosDict[1] = (id: "\(0)", url: "\(fedocumento.Nombre)")
        
        self.elemento.validacion.valor = tipodoc.toJsonString()
        
        self.anexosDict[1] = (id: "1", url: v)
        self.docTypeDict[1] = (catalogoId: self.fedocumento.TipoDocID, descripcion: self.fedocumento.TipoDoc)
        self.setVariableHeight(Height: 250)
        let localPath = "\(Cnstnt.Tree.anexos)/\(v)"
        let localPathOCR = "\(Cnstnt.Tree.anexos)/\(v)"
        if FCFileManager.existsItem(atPath: localPathOCR){
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
        
        self.lblTitle.textColor = UIColor.black
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
            self.lblRequired.isHidden = false
            self.lblTitle.textColor = UIColor.red
        }else{
            self.lblRequired.isHidden = true
            self.lblTitle.textColor = UIColor.black
        }
        self.layoutIfNeeded()
        self.row.add(ruleSet: rules)
    }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        self.lblMessage.isHidden = true
        if row.isValid{
            // Setting row as valid
            if row.value == nil{
                self.lblMessage.text = ""
                self.lblMessage.isHidden = true
                self.viewValidation.backgroundColor = Cnstnt.Color.gray

                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? FirmaRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.validado = false
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            }else{
                self.lblMessage.text = ""
                self.lblMessage.isHidden = true
                self.viewValidation.backgroundColor = UIColor.green

                resetValidation()
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? FirmaRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.attData = ((row as? FirmaRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.attData = ((row as? FirmaRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                }else{
                    self.elemento.validacion.validado = false
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                  
                }
                self.elemento.validacion.docid = "0"
                self.elemento.validacion.tipodoc = "\(self.atributos?.tipodoc ?? 0)"
            }
        }else{
            // Throw the first error printed in the label
            if (self.row.validationErrors.count) > 0{
                self.lblMessage.text = "  \(self.row.validationErrors[0].msg)  "
                let colors = self.formDelegate?.getColorsErrors(.error)
                self.lblMessage.backgroundColor = colors![0]
                self.lblMessage.textColor = colors![1]
                self.lblMessage.isHidden = false
            }

            self.elemento.validacion.anexos = [(id: String, url: String)]()
            self.elemento.validacion.anexos = (row as? FirmaRow)?.cell.anexosDict
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
        if rulesOnProperties.count == 0{
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
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){ }
}


// MARK: - ATTACHEDFORMDELEGATE
extension FirmaCell: AttachedFormDelegate{
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
                    fedoc.Ext = "png"
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
                    if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
                }
            }
            return true

        } catch { return false }
    }
    // MARK: Set - Local Anexo
    public func didSetLocalAnexo(_ feAnexo: FEAnexoData){
        self.anexo = feAnexo
        _ = setMetaValues()
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(feAnexo.FileName)"){
            setEdited(v: "\(feAnexo.FileName)")
        }else{
            self.setMessage("elemts_attch_server".langlocalized(), .info)
        }
    }
    
    // MARK: Set - Anexo Option
    public func setAnexoOption(_ anexo: FEAnexoData){
        self.anexo = anexo
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setDownloadAnexo(_:)))
        imgPreview.isUserInteractionEnabled = true
        imgPreview.addGestureRecognizer(tapGestureRecognizer)
        
        self.imgPreview.image = UIImage(named: "download-attachment", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.imgPreview.isHidden = false
        self.setVariableHeight(Height: 250)
        self.anexosDict[0] = (id: "reemplazo", url: anexo.FileName)
        triggerRulesOnChange("replaceanexo")
    }
    
    // MARK: Set - Attributes to Controller
    public func setAttributesToController(){ }
    
    // MARK: Set - Anexo
    public func setAnexo(_ anexo: FEAnexoData) {
        bgHabilitado.isHidden = true
        (row as? FirmaRow)?.disabled = false
        (row as? FirmaRow)?.evaluateDisabled()
        _ = setMetaValues()
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
            setEdited(v: "\(anexo.FileName)")
            self.setMessage("elemts_attch_recover".langlocalized(), .info)
        }
    }
    
    
    
}

extension FirmaCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{
        return self.lblMessage.text ?? ""
    }
    public func getRowEnabled()->Bool{
        return self.row.baseCell.isUserInteractionEnabled
    }
    public func getRequired()->Bool{
        return self.lblRequired.isHidden
    }
    public func getTitleLabel()->String{
        return self.lblTitle.text ?? ""
    }
    public func getSubtitleLabel()->String{
        return self.lblSubtitle.text ?? ""
    }
}

extension FirmaCell: MetaFormDelegate{
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
