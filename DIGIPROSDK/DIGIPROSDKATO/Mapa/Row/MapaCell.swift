import Foundation
import MapKit
import CoreLocation
import UIKit
import Eureka

open class MapaCell: Cell<String>, CellType, APIDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOUTLETS AND VARS
    
    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var bgHabilitado: UIView!
    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imgPreview: UIImageView!
    @IBOutlet weak var lblUbicacion: UILabel!
    @IBOutlet var imageMapView: UIView?
    
    //@IBOutlet weak var btnBuscar: UIButton!
    @IBOutlet weak var btnPosición: UIButton!
    @IBOutlet weak var btnClean: UIButton!
    @IBOutlet weak var btnMeta: UIButton!
    @IBOutlet weak var typeDocButton: UIButton!
    @IBOutlet weak var lblTypeDoc: UILabel!
    
    public var elemento = Elemento()
    public var isMapa = false
    public var atributos: Atributos_mapa!
    public var atributosGeo: Atributos_georeferencia!
    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var isServiceMessageDisplayed = 0
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var annotationView: MKPinAnnotationView = MKPinAnnotationView()
    
    public var latitud: String = ""
    public var longitud: String = ""
    public var ruleCoord: Bool = false
    public var anexosDict = [ (id: "", url: ""),
                              (id: "", url: "") ]
    public var docTypeDict = [(catalogoId: 0, descripcion: ""),
                              (catalogoId: 0, description: "" )] as [Any]
    
    var sdkAPI : APIManager<MapaCell>?
    var anexo: FEAnexoData?
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    
    let guid = ConfigurationManager.shared.utilities.guid()
    let locationManager = CLLocationManager()
    //let marker = GMSMarker()
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        isInfoToolTipVisible = false
        toolTip = nil
        est = nil
        (row as? MapaRow)?.presentationMode = nil
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
        //btnBuscar.isUserInteractionEnabled = true
        btnPosición.isUserInteractionEnabled = true
        activity.stopAnimating()
        self.headersView.lblMessage.text = ""
        self.lblUbicacion.text = ""
        self.headersView.lblMessage.isHidden = true
        self.btnClean.isHidden = true
        self.imgPreview.image = nil
        self.imgPreview.isHidden = true
        
        self.typeDocButton.isHidden = true
        self.lblTypeDoc.isHidden = true
        self.btnMeta.isHidden = true
        
        self.anexosDict[1] = (id: "", url: "")
        self.elemento.validacion.valor = ""
        self.elemento.validacion.valormetadato = ""
        
        self.typeDocButton.setTitle("Tipo de documento", for: .normal)
        self.lblTypeDoc.text = ""
        self.docID = 0
        
        self.btnPosición.isHidden = false
        self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
        row.value = nil
        row.validate()
        self.updateIfIsValid()
        if (row as? MapaRow)?.cell.frame.height ?? 0 > 100{
            hideMapViewController()
        }
        
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader)
    }
    
    @IBAction func btnBuscarAction(_ sender: UIButton) {
        // googleTop
        setVariableHeight(Height: 400)
        for constraint in (row as? MapaRow)!.cell.contentView.constraints {
            if constraint.identifier == "googleTop" {
                constraint.constant = 50
            }
        }
        getAutho()
    }
        
    @IBAction func btnPosicionAction(_ sender: UIButton) {
        self.ruleCoord = false
        btnCallPosicionAction()
    }
    
    public func btnCallPosicionAction() {
        if self.atributos != nil {
            self.presentSearchViewController()
        } else {
            activity.startAnimating()
            getAutho()
        }
    }
    
    // Hide View Controller
    func hideMapViewController(){
        // googleTop
        setVariableHeight(Height: 100)
        for constraint in (row as? MapaRow)!.cell.contentView.constraints {
            if constraint.identifier == "googleTop" {
                constraint.constant = -250
            }
        }
    }
    // MARK: - Authorization
    
    func getAutho(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()

            mapView.isHidden = false
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
                        if !ruleCoord
                        {   if (self.atributosGeo != nil && self.atributosGeo.pedirmapa) || self.atributos != nil
                            {
                                self.imageMapView = mapView
                            }
                        }
        }
        
        activity.stopAnimating()
        
    }
    
    private func presentSearchViewController() {
        let mapController: MapaSearchViewController = MapaSearchViewController()
        mapController.delegate = self
        
        (row as? MapaRow)?.presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return mapController
        }, onDismiss: { /*[weak self]*/ vc in
            vc.dismiss(animated: true)
        })
        
        if !((row as? MapaRow)?.isDisabled ?? true) {
            if let presentationMode = (row as? MapaRow)?.presentationMode {
                if let controller = presentationMode.makeController(){
                        presentationMode.present(controller, row: (row as? MapaRow)!, presentingController: self.formViewController()!)
                        (row as? MapaRow)!.onPresentCallback?(self.formViewController()!, controller as! SelectorViewController<SelectorRow<MapaCell>>)
                    } else {
                    presentationMode.present(nil, row: (row as? MapaRow)!, presentingController: self.formViewController()!)
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
        
        let apiObject = AttachedFormManager<MapaCell>()
        apiObject.delegate = self
        
        let apiMeta = MetaFormManager<MapaCell>()
        apiMeta.delegate = self
        
        sdkAPI = APIManager<MapaCell>()
        
        
        download.addTarget(self, action: #selector(downloadAnexo(_:)), for: .touchDown)
        
        if !ruleCoord
        {   if (self.atributosGeo != nil && self.atributosGeo.pedirmapa) || self.atributos != nil
        {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(setPreview(_:)))
            imgPreview?.isUserInteractionEnabled = true
            imgPreview?.addGestureRecognizer(tapRecognizer)
        }
        }
        
        //#Btn Fondo/Redondo
        btnPosición.backgroundColor = UIColor(hexFromString: "#1E88E5")
        btnPosición.layer.cornerRadius = btnPosición.frame.height / 2
        btnPosición.setImage(UIImage(named: "ic_marker", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
//        btnBuscar.backgroundColor = UIColor(hexFromString: "#1E88E5")
//        btnBuscar.layer.cornerRadius = btnBuscar.frame.height / 2
//        btnBuscar.setImage(UIImage(named: "ic_search", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        btnClean.backgroundColor = UIColor(hexFromString: "#1E88E5")
        btnClean.layer.cornerRadius = btnClean.frame.height / 2
        btnClean.setImage(UIImage(named: "ic_clean", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        download.backgroundColor = UIColor.lightGray
        download.layer.cornerRadius = download.frame.height / 2
        download.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        btnMeta.backgroundColor = UIColor(hexFromString: "#1E88E5")
        btnMeta.layer.cornerRadius = btnMeta.frame.height / 2
        btnMeta.setImage(UIImage(named: "ic_meta", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        typeDocButton.backgroundColor = UIColor(hexFromString: "#1E88E5")
        typeDocButton.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        typeDocButton.tintColor = .white
        
        //self.addSubview(vw.view)
        self.contentView.addSubview(vw.view)
        
        vw.view.isHidden = true
        vw.view.translatesAutoresizingMaskIntoConstraints = false
        
        vw.view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        vw.view.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        vw.view.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        vw.view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        vw.delegate = apiMeta.delegate
        
    }
    
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) {
        guard let _ = self.atributos, let help = atributos?.ayuda else{
            guard let _ = self.atributosGeo, let help = atributosGeo?.ayuda else{ return }
            toogleToolTip(help); return;
        }
        toogleToolTip(help)
    }
    
    // MARK: Set - Download Anexo
    @objc public func setDownloadAnexo(_ sender: Any) {
        self.setMessage("hud_downloading".langlocalized(), .info)
        bgHabilitado.isHidden = false
        (row as? MapaRow)?.disabled = true
        (row as? MapaRow)?.evaluateDisabled()
        if self.anexo != nil{
            self.sdkAPI?.DGSDKformatoAnexos(delegate: self, anexo: self.anexo!, estado: FormularioUtilities.shared.currentFormato.EstadoApp)
                .then{ response in
                    self.setAnexo(response)
                }.catch{ error in
                    self.bgHabilitado.isHidden = true
                    (self.row as? MapaRow)?.disabled = false
                    (self.row as? MapaRow)?.evaluateDisabled()
                    self.setMessage("elemts_attch_error".langlocalized(), .info)
                }
        }
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
    
    // MARK: SETTING
    /// SetObject for MapaRow(Geolocalizacion),
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObjectGeolocalizacion(obj: Elemento){
        elemento = obj
        atributosGeo = obj.atributos as? Atributos_georeferencia
        
        self.locationManager.delegate = self
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        
        initRules()
        if atributosGeo?.titulo ?? "" == ""{ self.headersView.setOcultarTitulo(true) }else{ self.headersView.setOcultarTitulo(atributosGeo?.ocultartitulo ?? false) }
        if atributosGeo?.subtitulo ?? "" == ""{ self.headersView.setOcultarSubtitulo(true) }else{ self.headersView.setOcultarSubtitulo(atributosGeo?.ocultarsubtitulo ?? false) }
        
        setVisible(atributosGeo?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributosGeo?.habilitado ?? false) }
        
        self.headersView.txttitulo = atributosGeo?.titulo ?? ""
        self.headersView.txtsubtitulo = atributosGeo?.subtitulo ?? ""
        self.headersView.txthelp = atributosGeo?.ayuda ?? ""
        
        self.headersView.hiddenTit = false
        self.headersView.hiddenSubtit = false
        
        self.headersView.setTitleText(headersView.txttitulo)
        self.headersView.setSubtitleText(headersView.txtsubtitulo)
        self.headersView.setAlignment(atributosGeo?.alineadotexto ?? "")
        self.headersView.setDecoration(atributosGeo?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributosGeo?.estilotexto ?? "")
        self.headersView.setMessage("")

        if anexo != nil{
            if anexo?.Error == 100{
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
        
        if headersView.lblTitle.text?.count ?? 0 > 120 {
            headersView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        }else if headersView.lblTitle.text?.count ?? 0 > 50{
            headersView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }else {
            headersView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        self.btnPosición.translatesAutoresizingMaskIntoConstraints = false
        self.btnPosición.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 5).isActive = true
        
        self.btnClean.translatesAutoresizingMaskIntoConstraints = false
        self.btnClean.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 5).isActive = true
        
        self.lblUbicacion.translatesAutoresizingMaskIntoConstraints = false
        self.lblUbicacion.topAnchor.constraint(equalTo: self.btnClean.bottomAnchor, constant: 10).isActive = true
        self.lblUbicacion.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 75).isActive = true
        self.lblUbicacion.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -75).isActive = true
        
        self.imgPreview.translatesAutoresizingMaskIntoConstraints = false
        self.imgPreview.layer.cornerRadius = 10
        self.imgPreview.topAnchor.constraint(equalTo: self.lblUbicacion.bottomAnchor, constant: -150).isActive = true
        self.imgPreview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 40).isActive = true
        self.imgPreview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -40).isActive = true
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader)
    }
    
    /// SetObject for MapaRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObjectMapa(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_mapa
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        
        initRules()
        if atributos?.titulo ?? "" == ""{ self.headersView.setOcultarTitulo(true) }else{ self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        if atributos?.subtitulo ?? "" == ""{ self.headersView.setOcultarSubtitulo(true) }else{ self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false) }

        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(true) }else{ setHabilitado(true) }
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? MapaRow)?.cell.formCell()?.formViewController()?.tableView
        self.headersView.hiddenTit = false
        self.headersView.hiddenSubtit = false
        
        self.headersView.setTitleText(headersView.txttitulo)
        self.headersView.setSubtitleText(headersView.txtsubtitulo)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
        self.headersView.setMessage("")
        setInfo()
//        getTipificacionPermitida()
        
        if anexo != nil{
            if anexo?.Error == 100{
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
        
        if headersView.lblTitle.text?.count ?? 0 > 50 {
            headersView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }else if headersView.lblTitle.text?.count ?? 0 > 50{
            headersView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        }else {
            headersView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        self.btnPosición.translatesAutoresizingMaskIntoConstraints = false
        self.btnPosición.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 5).isActive = true
        
        self.btnClean.translatesAutoresizingMaskIntoConstraints = false
        self.btnClean.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 5).isActive = true
        
        self.lblUbicacion.translatesAutoresizingMaskIntoConstraints = false
        self.lblUbicacion.topAnchor.constraint(equalTo: self.btnClean.bottomAnchor, constant: 10).isActive = true
        self.lblUbicacion.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 75).isActive = true
        self.lblUbicacion.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -75).isActive = true
        
        self.imgPreview.translatesAutoresizingMaskIntoConstraints = false
        self.imgPreview.layer.cornerRadius = 10
        self.imgPreview.topAnchor.constraint(equalTo: self.lblUbicacion.bottomAnchor, constant: -150).isActive = true
        self.imgPreview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 40).isActive = true
        self.imgPreview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -40).isActive = true
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader)
        
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
    
    
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let pin = mapView.view(for: annotation) as? MKPinAnnotationView ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.pinTintColor = UIColor.red
            self.annotationView = pin
            return pin
        } else if annotation is MKPointAnnotation {
            // handle other annotations
            let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.pinTintColor = UIColor.blue
            return pin
        }
        return nil
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
    
    //MARK: STATIC MAP API
    private func setStaticMap(with pin: CLLocationCoordinate2D) {
        ///https://maps.googleapis.com/maps/api/staticmap?parameters
        let googleStaticMapURL: String = "https://maps.googleapis.com/maps/api/staticmap?"
        let url: URLComponents? = URLComponents(string: googleStaticMapURL)
        
        if var googleMapURL = url {
            let center = "\(pin.latitude),\(pin.longitude)"
            let size = "\(640)x\(640)"
            
            googleMapURL.queryItems = [
                //Requeridos:
                ///Center puede ser ("latitud,longitud") separado por una coma o un lugar eg: Berkeley, CA
                URLQueryItem(name: "center", value: center),
                URLQueryItem(name: "zoom", value: "15"), //15 es nivel de calle
                URLQueryItem(name: "size", value: size),
                URLQueryItem(name: "format", value: "JPEG")
            ]
            
            let marker = "color:red|label:Ubicacion|\(pin.latitude),\(pin.longitude)"
            googleMapURL.queryItems?.append(URLQueryItem(name: "markers", value: marker))
            
            //Guardar llave en algun lugar mas seguro, ConfigurationManager?
            googleMapURL.queryItems?.append(URLQueryItem(name: "key", value: "AIzaSyBWvN1C3CsbTeEoyc5t7ADU3oaLXwh4fek"))
            
            if let mapURL = googleMapURL.url {
                let request: URLRequest = URLRequest(url: mapURL)
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data, let _ = response as? HTTPURLResponse, error == nil else {
                        print("Error: \(error?.localizedDescription ?? "")")
                        return
                    }
                    
//                    guard(200...299) ~= response.statusCode else {
//                        print("statusCode: \(response.statusCode)")
//                        return
//                    }
                    
                    if let image: UIImage = UIImage(data: data) {
                        //Para guardar imagen en Georeferencia:
                        self.path = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_1_\(self.guid).ane"
                        let _ = ConfigurationManager.shared.utilities.saveImageToFolder(image, self.path)
                        DispatchQueue.main.async {
                            self.setVariableHeight(Height: 400)
                            self.imgPreview.isHidden = false
                            self.imgPreview.image = image
                            self.setEdited(v: self.path)
                            self.row.validate()
                            self.updateIfIsValid()
                        }
                    }
                    
                }.resume()
            }
        }
    }
    
    // Location
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return  }
        
        let strLatitude = "\(locValue.latitude)"
        let endLatitude = strLatitude.index(strLatitude.startIndex, offsetBy: 7)
        let rangeLatitude = strLatitude.startIndex ..< endLatitude
        
        let strLongitude = "\(locValue.longitude)"
        let endLongitude = strLongitude.index(strLongitude.startIndex, offsetBy: 7)
        let rangeLongitude = strLongitude.startIndex ..< endLongitude
        
        self.latitud = "\(strLatitude[rangeLatitude])"
        self.longitud = "\(strLongitude[rangeLongitude])"
        
        self.elemento.validacion.valor = "\(self.latitud),\(self.longitud)"
        self.elemento.validacion.valormetadato = "\(self.latitud),\(self.longitud)"
        
        locationManager.stopUpdatingLocation()
        
        if self.atributosGeo != nil {
            self.path = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_1_\(self.guid).ane"
            let doc = FEDocumento()
            doc.guid = "\(self.guid)"
            doc.isKindImage = true
            doc.Ext = "jpg"
            doc.ImageString = ""
            doc.Nombre = self.path
            doc.Path = self.path
            doc.URL = "\(Cnstnt.Tree.anexos)/\(self.path)"
            
            self.setStaticMap(with: locValue)
            
            // MARK: tipo de documento hijo firma recupera id 14
            if self.atributosGeo.tipodoc == 11 && self.atributosGeo.metadato == "Geolocalizacion" {
                doc.TipoDoc = ""
                doc.TipoDocID = Int(self.atributosGeo.tipodoc)
                self.elemento.validacion.tipodoc = ""
                self.elemento.validacion.docid = ""
            } else {
                doc.TipoDoc = ""
                doc.TipoDocID = 0
            }
            
            for list in self.listAllowed{
                if self.tipUnica == nil{ break }
                if list.CatalogoId != self.tipUnica{ continue }
                doc.TipoDocID = self.tipUnica ?? 0
                doc.TipoDoc = list.Descripcion
                if list.current != 0{
                    if list.current >= list.max{
                        self.setMessage(String(format: "elemts_doc_maxtyp".langlocalized(), list.Descripcion, String(list.max)), .error)
                        return
                    }
                }
                list.current += 1
            }
            
            self.docID = doc.TipoDocID ?? 0
            self.fedocumento = doc
            self.setEdited(v: self.path)
            
            if !self.ruleCoord
            {   if (self.atributosGeo != nil && self.atributosGeo.pedirmapa) || self.atributos != nil
            {
                self.btnClean.isHidden = false
                self.btnPosición.isHidden = true
                self.btnPosición.isUserInteractionEnabled = true
            }
            }
            
            if self.tipUnica == nil{
                if self.atributos != nil{
                    self.setPermisoTipificar(self.atributos?.permisotipificar ?? false)
                }else if self.atributosGeo != nil{
                    self.setPermisoTipificar(self.atributosGeo?.permisotipificar ?? false)
                }
            }
            if self.getMetaData(){ self.btnMeta.isHidden = false }else{ self.btnMeta.isHidden = true }
            self.activity.stopAnimating()
        } else if self.atributos != nil {
            self.setStaticMap(with: locValue)
            self.btnClean.isHidden = false
        }
    }
}

// MARK: - ATTACHEDFORMDELEGATE
extension MapaCell: ObjectFormDelegate{
    
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        if atributos != nil{
            est?.Campo = "Mapa"
            est?.NombrePagina = (self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
            est?.OrdenCampo = atributos?.ordencampo ?? 0
            est?.PaginaID = Int(atributos?.elementopadre.replaceFormElec() ?? "0") ?? 0
        }else if atributosGeo != nil{
            est?.Campo = "Geolocalizacion"
            est?.NombrePagina = (self.formDelegate?.getPageTitle(atributosGeo?.elementopadre ?? "") ?? "").replaceLineBreak()
            est?.OrdenCampo = atributosGeo?.ordencampo ?? 0
            est?.PaginaID = Int(atributosGeo?.elementopadre.replaceFormElec() ?? "0") ?? 0
        }
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
        }else if atributosGeo != nil{
            self.estV2?.IdElemento = elemento._idelemento
            self.estV2?.Titulo = atributosGeo?.titulo ?? ""
            self.estV2?.Pagina = (self.formDelegate?.getPageTitle(atributosGeo?.elementopadre ?? "") ?? "").replaceLineBreak()
            self.estV2?.IdPagina = self.formDelegate?.getPageID(atributos?.elementopadre ?? "") ?? ""
        }
        self.estV2?.ValorFinal = elemento.validacion.valormetadato
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
        if atributosGeo?.ayuda != nil, !(atributosGeo?.ayuda.isEmpty)!, atributosGeo?.ayuda != ""{
            self.headersView.btnInfo.isHidden = false
        }
    }
    
    public func toogleToolTip(_ help: String){
        if isInfoToolTipVisible{
            toolTip?.dismiss()
            isInfoToolTipVisible = false
        }else{
            toolTip = EasyTipView(text: help, preferences: EasyTipView.globalPreferences)
            toolTip?.show(forView: self.headersView.btnInfo, withinSuperview: (row as? MapaRow)?.cell.formCell()?.formViewController()?.tableView)
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
        if atributos != nil{ setRequerido(atributos?.requerido ?? false)
        }else if atributosGeo != nil{ setRequerido(atributosGeo?.requerido ?? false) }
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
        if atributos != nil{
            self.atributos?.habilitado = bool
        }else if atributosGeo != nil{
            self.atributosGeo?.habilitado = bool
        }
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
            //self.btnBuscar.isHidden = true
            self.btnPosición.isHidden = true
            if tipUnica == nil && atributos?.permisotipificar ?? false == false{
                self.setValue(v: v)
            }else{
                if tipUnica != nil{
                    self.setValue(v: v)
                }else{
                    if atributos != nil{
                        if atributos?.permisotipificar ?? false{
                            if (self.elemento.validacion.valor != "" && self.elemento.validacion.valormetadato != ""){
                                self.setPermisoTipificar(atributos?.permisotipificar ?? false)
                                self.setValue(v: v)
                            }
                        }
                    }else if atributosGeo != nil{
                        if atributosGeo?.permisotipificar ?? false{
                            if (self.elemento.validacion.valor != "" && self.elemento.validacion.valormetadato != ""){
                                self.setPermisoTipificar(atributosGeo?.permisotipificar ?? false)
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
        
        triggerRulesOnChange(nil)
        triggerEvent("alterminarcaptura")
    }
    public func setEdited(v: String, isRobot: Bool) { }
    public func setValue(v: String){
        let tipodoc: NSMutableDictionary = NSMutableDictionary();
        tipodoc.setValue("\(String(fedocumento.TipoDocID ?? 0))", forKey: "\(fedocumento.guid)");
        self.anexosDict[1] = (id: "\(0)", url: "\(fedocumento.Nombre)")
        
        let latitudString = v.components(separatedBy: ",").first ?? ""
        let longitudString = v.components(separatedBy: ",").last ?? ""
        
        if let latitud = Double(latitudString), let longitud = Double(longitudString) {
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
            self.lblUbicacion.text = "\(latitudString),\(longitudString)" 
            self.setStaticMap(with: location)
        }
        
        self.elemento.validacion.valor = tipodoc.toJsonString()
        
        self.anexosDict[1] = (id: "1", url: v)
        self.docTypeDict[1] = (catalogoId: self.fedocumento.TipoDocID, descripcion: self.fedocumento.TipoDoc)
        
        if !ruleCoord
        {   if (self.atributosGeo != nil && self.atributosGeo.pedirmapa) || self.atributos != nil
            {
                let localPath = "\(Cnstnt.Tree.anexos)/\(self.anexosDict[1].url)"
                if FCFileManager.existsItem(atPath: localPath){
                    let file = ConfigurationManager.shared.utilities.read(asData: localPath)
                    self.imgPreview.image = UIImage(data: file!)
                    self.imgPreview.isHidden = false
                }
                self.setVariableHeight(Height: 380)
            }
        }
        self.headersView.lblTitle.textColor = UIColor.black
        row.value = v
        self.updateIfIsValid()
        self.lblUbicacion.text = "\(self.latitud),\(self.longitud)"
        self.lblUbicacion.isHidden = false
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
        if self.atributosGeo != nil{
            self.atributosGeo?.visible = bool
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
        if atributosGeo != nil{
            self.elemento.validacion.needsValidation = atributosGeo?.requerido ?? false
        }
    }
    // MARK: Set - Requerido
    public func setRequerido(_ bool: Bool){
        self.elemento.validacion.needsValidation = bool
        if atributos != nil{
            self.atributos?.requerido = bool
        }else if atributosGeo != nil{
            self.atributosGeo?.requerido = bool
        }
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
                self.elemento.validacion.anexos = (row as? MapaRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.validado = false
                if !ConfigurationManager.shared.isConsubanco {
                    self.elemento.validacion.valor = "\(self.latitud),\(self.longitud)"
                    self.elemento.validacion.valormetadato = "\(self.latitud),\(self.longitud)"
                } else {
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                }
            }else{
                self.headersView.lblMessage.text = ""
                self.headersView.lblMessage.isHidden = true
//                self.viewValidation.backgroundColor = UIColor.green
                
                resetValidation()
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? MapaRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.attData = ((row as? MapaRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.attData = ((row as? MapaRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                }else{
                    self.elemento.validacion.validado = false
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                }
                self.elemento.validacion.docid = "0"
                if self.atributos != nil{
                    if ConfigurationManager.shared.isConsubanco{self.elemento.validacion.tipodoc = "0"}else{
                        self.elemento.validacion.tipodoc = "\(self.atributos?.tipodoc ?? 0)"
                    }
                    
                }else if self.atributosGeo != nil{
                    if ConfigurationManager.shared.isConsubanco{self.elemento.validacion.tipodoc = "0"}else{
                        self.elemento.validacion.tipodoc = "\(self.atributosGeo?.tipodoc ?? 0)"
                    }
                    if self.atributosGeo?.tipodoc == 11 {
                        if ConfigurationManager.shared.isConsubanco{self.elemento.validacion.tipodoc = "0"}else{
                            self.elemento.validacion.tipodoc = "\(self.atributosGeo?.tipodoc ?? 0)"
                        }
                    }
                }
                self.elemento.validacion.valor = "\(self.latitud),\(self.longitud)"
                self.elemento.validacion.valormetadato = "\(self.latitud),\(self.longitud)"
            }
        }else{
            // Throw the first error printed in the label
            if (self.row.validationErrors.count) > 0{
                self.headersView.lblMessage.text = "  \(self.row.validationErrors[0].msg)  "
                _ = self.formDelegate?.getColorsErrors(.error)
                self.headersView.lblMessage.backgroundColor = .clear
                self.headersView.lblMessage.textColor = Cnstnt.Color.red2
                self.headersView.lblMessage.isHidden = false
            }
            
            self.elemento.validacion.anexos = [(id: String, url: String)]()
            self.elemento.validacion.anexos = (row as? MapaRow)?.cell.anexosDict
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
        
        if atributosGeo != nil, atributosGeo?.eventos != nil {
            for evento in (atributosGeo?.eventos.expresion)!{
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
            if row.value == nil || row.value == ""{ self.triggerRulesOnChange("empty") }
            if row.value != nil || row.value != ""{ self.triggerRulesOnChange("notempty") }
        }
        if rulesOnProperties.count == 0{
            if self.atributos != nil
            {
                if self.atributos?.habilitado ?? false{ triggerRulesOnProperties("enabled") }else{ triggerRulesOnProperties("notenabled") }
                if self.atributos?.visible ?? false{
                    triggerRulesOnProperties("visible")
                    triggerRulesOnProperties("visiblecontenido")
                }else{
                    triggerRulesOnProperties("notvisible")
                    triggerRulesOnProperties("notvisiblecontenido")
                }
            } else if self.atributosGeo != nil
            {
                if self.atributosGeo?.habilitado ?? false{ triggerRulesOnProperties("enabled") }else{ triggerRulesOnProperties("notenabled") }
                if self.atributosGeo?.visible ?? false{
                    triggerRulesOnProperties("visible")
                    triggerRulesOnProperties("visiblecontenido")
                }else{
                    triggerRulesOnProperties("notvisible")
                    triggerRulesOnProperties("notvisiblecontenido")
                }
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
    public func setRulesOnChange() {
        self.triggerRulesOnChange(nil)
    }
    
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
extension MapaCell: AttachedFormDelegate{
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
        self.setVariableHeight(Height: 380)
        self.anexosDict[0] = (id: "reemplazo", url: anexo.FileName)
        triggerRulesOnChange("replaceanexo")
    }
    
    // MARK: Set - Attributes to Controller
    public func setAttributesToController(){ }
    
    // MARK: Set - Anexo
    public func setAnexo(_ anexo: FEAnexoData) {
        bgHabilitado.isHidden = true
        (row as? MapaRow)?.disabled = false
        (row as? MapaRow)?.evaluateDisabled()
        _ = setMetaValues()
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
            setEdited(v: "\(anexo.FileName)")
            self.setMessage("elemts_attch_recover".langlocalized(), .info)
        }
    }
    
}

extension MapaCell{
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

extension MapaCell: MetaFormDelegate{
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

extension MapaCell: MapaSearchViewControllerDelegate {
    public func didDismiss(location: CLLocationCoordinate2D?) {
        if let location = location {
            //Asignar latitud, longitud a feDocumento:
            self.latitud = String(location.latitude)
            self.longitud = String(location.longitude)

            self.elemento.validacion.valor = "\(self.latitud),\(self.longitud)"
            self.elemento.validacion.valormetadato = "\(self.latitud),\(self.longitud)"
            
            self.lblUbicacion.text = "\(self.latitud),\(self.longitud)"
            
            self.mapView.isHidden = true
            
            self.setStaticMap(with: location)
            self.btnPosición.isHidden = true
            self.btnClean.isHidden = false
        } else {
            //No hay localizacion
        }
    }
}

