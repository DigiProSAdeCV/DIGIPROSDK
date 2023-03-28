import Foundation
import UIKit
import CoreLocation
import Eureka

// Enum Para el contenido estático
private enum StateContent {
    case closed
    case open
}

extension StateContent {
    var opposite: StateContent {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

public protocol NuevaPlantillaViewControllerDelegate { func reloadContEstatico () }
public typealias BackFromSuccessBiometricLocal = (_ infoToReturn :NSString) ->()

public class NuevaPlantillaViewController: FormViewController, FormularioDelegate, UIGestureRecognizerDelegate, NuevaPlantillaViewControllerDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, UISearchBarDelegate
{
    public var elemtVDDocument: AEXMLElement?
    public var completionBlockLocalBiometric: BackFromSuccessBiometricLocal?
    let staticVC = EstaticosViewController(nibName: "RDurXfJXfDzresY", bundle: Cnstnt.Path.framework)
    public var completionHandler: ((_ childVC: NuevaPlantillaViewController, _ status: [String : Any]?, _ error: NSError?) -> Void)?
    private let popupOffset: CGFloat = 440
    
    public var formActions : FormManager<NuevaPlantillaViewController>?
    public var sdkAPI : APIManager<NuevaPlantillaViewController>?
    public var navigation: FormViewController?
    public var elementsForValidate = [String]()
    public var ElementosArray:NSMutableDictionary = NSMutableDictionary()
    public var valuesArray: Array<String>?
    public var filtrosArray: Array<String>?
    public var imageCollector = [(id: String, value: String, desc: String)]()
    @IBOutlet weak var fotterViewController: UIView!
    
    public var flujo = 0
    public var proceso = 0
    public var index: Int = 0
    public var allIndex = 1
    public var formCounter = 0
    public var currentPage = -1
    public var tapped = false
    public var pageSelected = 0
    public var isGrantedPremissions = false
    public var isBorradorSNSalir = false
    
    public var arrayPlantillaData = FEPlantillaData()
    public var xmlParsed = Elemento()
    public var xmlAEXML = AEXMLDocument()
    public var formatoData = FEFormatoData()
    public var dadFormat = FEFormatoData()
    public var formato = FEConsultaFormato()
    var feOpenPlantilla: [FEOpenPlantilla] = []
    //MARK: Estadisticas
    public var currentEstadisticas = [FEEstadistica]()
    public var currentEstadisticas2 = [FEEstadistica2]()
    public var reporteEstadisticas = FEReporteEstadistico()
    
    public var historialEstadistico = [FEHistoria]()
    public var historiaOBJ = FEHistoria() ///Se usa para servicios/componentes
    
    public var arrayOrder: [String] = [String]()
    public var validAnchors: [String] = [String]()
    public let atributos: OcrIneObject = OcrIneObject()
    public var fechaInicial: UInt64 = 0
    
    public var macros: [Macro] = []
    
    public var elemNetPay: String = ""
    
    public var isAnexoAdded = false
    public var isAutoEnable = false
    public var plantillamapear = ""
    
    public var currentAnexos = [FEAnexoData]()
    public var anexosLocales = [(elementoid:String, anexo:FEAnexoData)]()
    public var anexosRemotos = [(elementoid:String, anexo:FEAnexoData)]()
    public var currentHijos = [Elemento]()
    public var sectionsDictionary = [String: Form]()
    
    public var forms = [Form]()
    public var footerForm = Form()
    public var footerViewController: FooterViewController? = nil
    public var isFooterDetected: Bool = false
    public var viewControllerR: RequestSuccessController? = nil
    public var folioEconsubanco = ""
    public var compareFaceFlag = false
    public var plaCot = FEPlantillaData()
    public var formatoCot = FEFormatoData()
    public var formatoFlag: Bool = false
    public var flagCalculadora: Bool = false
    public var openPlantilla = FEOpenPlantilla()
    
    public var atributosPlantilla: Atributos_plantilla?
    var saveTimer: Timer?
    var flagSave: Bool?
    var flagAlert: Bool = false
    var flagLocation: Bool = false
    var flagEventos: Bool = false
    var timer = Timer()
    var segmentSelected = 0
    let device = Device()
    var hud: JGProgressHUD = JGProgressHUD(style: .dark)
    lazy var banner: StatusBarNotificationBanner = StatusBarNotificationBanner(title: "", style: .info)
    var plantillaAction = ""
    // MARK: - Only for Q/A
    public var QAElements: [(String, Bool)] = []
    var templateDelegate: TemplateDelegate?
    var negoPermisos : Int = 0
    public let locationManager = CLLocationManager()
    public var wrdNavigation: WizardRow?
    public var valueRuleCoor : String = ""
    var rulesOnProperties : [Int] = []
    var auxMarcadoDoct : [String] = []
    public var combosPend : [String: String] = [:]
    public var flagCot: Bool = false
    public var flagBio: Bool = false
    
    public var arrayArchivesOn: [String] = [String]()
    internal var netPayInfoViewController: NetPayInfoViewController?
    
    //Mostrar la status bar
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    lazy var pagesScrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        v.isScrollEnabled = true
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        return v
    }()
    
    public lazy var warningView : UIImageView = {
        let imgVw = UIImageView(image: UIImage(named: "warning_alert", in:  Cnstnt.Path.framework, compatibleWith: nil))
        return imgVw
    }()
    
    public lazy var dangerView : UIImageView = {
        let imgVw = UIImageView(image: UIImage(named: "warning_sign", in: Cnstnt.Path.framework, compatibleWith: nil))
        return imgVw
    }()
    
    public var dictValues = Dictionary<String, (docid:String, valor:String, valormetadato:String, tipodoc:String, metadatostipodoc:String, nameFirm:String, dateFirm:String, georefFirm:String, deviceFirm:String)>()
    
    @IBOutlet weak var titlePlantilla: UILabel!
    @IBOutlet weak var subtitlePlantilla: UILabel!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var viewVisual: UIVisualEffectView!
    @IBOutlet weak public var btnTopView: UIButton!
    
    // IPAD versión IBOutlet
    @IBOutlet weak var btnFormatos: UIBarButtonItem?
    @IBOutlet weak var btnMenu: UIBarButtonItem?
    
    public var popover: UINavigationController? = nil
    public var isTblVwAnimating: Bool = false
    public var isDisableTopVw: Bool = false
    
    public var colorDeseado: UIColor = .clear
    
    @IBOutlet weak public var btnBack: UIButton? {
        didSet {
            self.btnBack?.backgroundColor = colorDeseado
        }
    }
    @IBOutlet weak var btnGuardar: UIButton?
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var switchAutoSave: UISwitch!
    @IBOutlet weak var labelAutoSave: UILabel!
    
    // Navigation
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var leftNavigation: UIButton!
    @IBOutlet weak var rightNavigation: UIButton!
    
    @IBAction func actionFormatos(_ sender: Any) {
        // Popping DataViewController
    }
    
    // MARK: - DELEGATES
    public func didSendToServerFormatos() { }
    public func isVisibleHUD() { }
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    
    // MARK: ACTIONS
    @IBAction func backAction(_ sender: UIButton) {
        ConfigurationManager.shared.utilities.log(.canceled, "Se ha cancelado el formato")
        self.cancelarAction((Any).self)
    }
    
    
    
    func closeViewController(status: Int = 400) {
        ConfigurationManager.shared.utilities.log(.canceled, "Se ha cancelado el formato")
        ConfigurationManager.shared.utilities.log(.log, "Removiendo el video dummy en el caso de que exista")
        if FCFileManager.existsItem(atPath: "video.mp4"){
            FCFileManager.removeItem(atPath: "video.mp4")
        }
        var s: [String : Any]?
        var e: NSError?
        
        if templateDelegate != nil{
            switch status{
            case 200:
                ConfigurationManager.shared.utilities.log(.log, "Saliendo del formato con códido 200")
                if self.formatoData.TareaSiguiente.NombreTarea == ""{
                    // Console log Status
                    s = ["success": true, "codigo": 200, "tarea": "originación", "accion": "\(self.plantillaAction)"]
                    //                    self.templateDelegate?.didFormatViewFinish(error: nil, success: s)
                    //                    self.templateDelegate?.onFinishFormat_Publicar?(guid: self.formatoData.Guid, error: nil, success: s)
                }else{
                    s = ["success": true, "codigo": 200, "tarea": "\(self.formatoData.TareaSiguiente.NombreTarea)", "accion": "\(self.plantillaAction)"]
                    //                    self.templateDelegate?.didFormatViewFinish(error: nil, success: s)
                    //                    self.templateDelegate?.onFinishFormat_Publicar?(guid: self.formatoData.Guid, error: nil, success: s)
                }
                break;
            case 300:
                ConfigurationManager.shared.utilities.log(.log, "Saliendo del formato con código 300")
                s = ["success": true, "codigo": 300, "tarea": "Formato Borrador", "accion": "Borrador"]
                //                self.templateDelegate?.didFormatViewFinish(error: nil, success: s)
                //                self.templateDelegate?.onFinishFormat_Borrador?(guid: self.formatoData.Guid, error: nil, success: s)
                break;
            case 400:
                ConfigurationManager.shared.utilities.log(.log, "Saliendo del formato con código 400")
                e = NSError(domain: Domain.sdk.rawValue, code: ApiErrors.noFormat.rawValue, userInfo: ["success": false, "message": "RESULT_CANCELED"])
                //                self.templateDelegate?.didFormatViewFinish(error: e, success: nil)
                //                self.templateDelegate?.onFinishFormat_Cancelado?(error: e)
                break;
            default: break;
            }
        }
        self.dismiss(s: s, e: e)
    }
    
    func runCompletion(){
        resettingSettings()
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    /// Cancel Custom Alert for "cancel button navigation"
    func cancelCustomAlert(){
        let customAlert = CustomAlertView(nibName: "vGwdIGDXntKOQIC", bundle: Cnstnt.Path.framework)
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        customAlert.namePlantilla = atributosPlantilla?.titulo ?? ""
        self.present(customAlert, animated: true, completion: nil)
    }
    
    /// Cancel  Default Alert for "cancel button navigation"
    func cancelAlert(){
        let alert = UIAlertController(title: atributosPlantilla?.textosalirtitulo ?? "", message: atributosPlantilla?.textosalirmensaje ?? "alrt_saving".langlocalized(), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "alrt_accept".langlocalized(), style: .default, handler: { action in
                                        switch action.style{
                                        case .default:
                                            self.switchAutoSave.isOn = false
                                            self.flagSave = false
                                            self.formatoData.EstadoApp = 1
                                            self.formatoData.Editado = true
                                            self.setValuesToObject(accion: actionForm.publicado)
                                            // Setting Local displaying options
                                            FormularioUtilities.shared.globalFlujo = self.formatoData.FlujoID
                                            FormularioUtilities.shared.globalProceso = 0
                                            break
                                        case .cancel: break
                                        case .destructive: break
                                        @unknown default: break
                                        }}))
        alert.addAction(UIAlertAction(title: "alrt_cancel".langlocalized(), style: .destructive, handler: { action in
                                        switch action.style{
                                        case .default: break
                                        case .cancel, .destructive:
                                            self.feOpenPlantilla.removeAll()
                                            ConfigurationManager.shared.openPlantilla.removeAll()
                                            if self.switchAutoSave.isOn {
                                                self.deleteFormatFromLocal(formato: self.formatoData)
                                            }
                                            self.closeViewController(status: 400)
                                            break
                                        @unknown default: break
                                        }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Cancel Action in top navigation
    /// - Parameter sender: button sender
    @IBAction func cancelarAction(_ sender: Any) {
        ConfigurationManager.shared.utilities.log(.log, "PermisoSalirConCambios \(ConfigurationManager.shared.usuarioUIAppDelegate.PermisoSalirConCambios)")
        if ConfigurationManager.shared.usuarioUIAppDelegate.PermisoSalirConCambios{
            self.flagAlert = true
            if ConfigurationManager.shared.isConsubanco{
                self.cancelCustomAlert()
            }else{
                self.cancelAlert()
            }
        }else{
            if ConfigurationManager.shared.isConsubanco{
                if  self.atributosPlantilla?.titulo == "Biométrico" || self.atributosPlantilla?.titulo == "Captación"{ self.flagAlert = false }else{ self.flagAlert = true }
                self.cancelCustomAlert()
            }else{
                self.flagAlert = false
                self.cancelAlert()
            }
        }
    }
    
    @IBAction func salvarAction(_ sender: Any) {
        
        
        if self.negoPermisos == 1{
            self.negoPermisos = 2
            self.checkLocationPermission()
        }else{
            self.formatoData.TipoReemplazo = 1
            self.formatoData.Accion = 0
            self.plantillaAction = "publicacion"
            self.validationForms()
        }
        
    }
    
    // DELEGATE
    public func getColorsErrors(_ type: enumErrorType) -> [UIColor] {
        switch type {
        case .error: return [UIColor(hexFromString: self.atributosPlantilla?.colorfondoerrorelemento ?? "#D93829", alpha: 1.0), UIColor(hexFromString: self.atributosPlantilla?.colortextoerrorelemento ?? "#FFFFFF", alpha: 1.0)]
        case .info: return [UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertainfo ?? "#3C3CCC", alpha: 1.0), UIColor(hexFromString: self.atributosPlantilla?.colortextoalertainfo ?? "#FFFFFF", alpha: 1.0)]
        case .success: return [UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertaexito ?? "#68B848", alpha: 1.0), UIColor(hexFromString: self.atributosPlantilla?.colortextoalertaexito ?? "#FFFFFF", alpha: 1.0)]
        case .warning: return [UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertaadvertencia ?? "#FFD500", alpha: 1.0), UIColor(hexFromString: self.atributosPlantilla?.colortextoalertaadvertencia ?? "#FFFFFF", alpha: 1.0)]
        default: return [UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertainfo ?? "#3C3CCC", alpha: 1.0), UIColor(hexFromString: self.atributosPlantilla?.colortextoalertainfo ?? "#FFFFFF", alpha: 1.0)]
        }
    }
    
    public func getCurrentPage() -> Int{
        return self.segmentSelected
    }
    
    public func getValueFromTitleComponent(_ id: String) -> String{
        
        for form in self.forms{
            
            for rows in form.allRows{
                let row = rows as? TextoRow
                if row?.cell.getTitleLabel() == id{ return row?.value ?? "" }else{ continue; }
            }
            
        }
        
        return ""
    }
    
    public func getValueFromComponent(_ id: String) -> String
    {
        var valor : String = ""
        self.forms.forEach { form in
            let rows = form.rowBy(tag: "\(id)")
            if (rows != nil){
                if let row = rows as? TextoRow, (row.value ?? "") != ""
                {   valor = row.value ?? "" }
            }
        }
        return valor
    }
    
    public func getAllRowsFromCurrentForm() -> [BaseRow]{
        return forms[currentPage].allRows
    }
    public func reloadTableViewFormViewController() {
        self.tableView.reloadData()
        self.tableView.layoutSubviews()
        self.tableView.layoutIfNeeded()
        self.tableView.setNeedsLayout()
    }
    
    public func getFormatoDataObject() -> FEFormatoData {
        return self.formatoData
    }
    
    // MARK: - Wizard Tabla
    public func wizardActionTabla(id: String, validar: Bool, tipo: String, atributos: Atributos_wizard) {
        switch tipo  {
        case "borrador":
            //self.saveWorksheetTable(atributos: atributos)
            self.setTransitOptions(option: tipo)
            self.saveWorksheet()
            break
        default:
            break
        }
    }
    
    
    // MARK: - Wizard Plantilla
    public func  wizardAction(id: String, validar: Bool, tipo: String, atributos: Atributos_wizard) -> Bool {
        self.view.endEditing(true)
        
        self.plantillaAction = tipo
        switch tipo {
        case "regresar":
            self.isBorradorSNSalir = false
            if id == ""{ return false }
            var button: UIButton?
            for (index, pagina) in FormularioUtilities.shared.paginasVisibles.enumerated(){
                if pagina.idelemento == id{
                    pagina.visible = true;
                    pagina.habilitado = true;
                    self.pagesScrollView.subviews.forEach({
                        if $0.isKind(of: UIButton.self){
                            if $0.tag == index{
                                button = $0 as? UIButton
                            }
                        }
                    })
                }
            }
            self.reloadPages()
            self.segmentSelected(button)
            return true
        case "avanzar":
            self.isBorradorSNSalir = false
            if validar{
                let isValid = validateSingleForm(currentPage)
                if isValid{
                    if id == ""{ return false }
                    var button: UIButton?
                    for (index, pagina) in FormularioUtilities.shared.paginasVisibles.enumerated(){
                        if pagina.idelemento == id {
                            pagina.visible = true;
                            pagina.habilitado = true;
                            self.pagesScrollView.subviews.forEach({
                                if $0.isKind(of: UIButton.self){
                                    if $0.tag == index{ button = $0 as? UIButton }
                                }
                            })
                        }
                    }
                    self.reloadPages()
                    self.segmentSelected(button)
                    self.triggerPlantillaEvents(event: "validate")
                    return true
                }else{
                    let path = self.elementsForValidate.first
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                        let indexPath: IndexPath? = self.form.rowBy(tag: "\(path ?? "")")?.indexPath
                        if indexPath != nil{
                            self.tableView.scrollToRow(at: indexPath ?? IndexPath(row: 0, section: 0), at: .top, animated: true)
                            self.tableView.selectRow(at: indexPath ?? IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
                        }
                        self.setStatusBarNotificationBanner("not_check_fields".langlocalized(), .danger, .bottom)
                    }
                    return false
                }
            }else{
                if id == ""{ return false }
                var button: UIButton?
                for (index, pagina) in FormularioUtilities.shared.paginasVisibles.enumerated(){
                    if pagina.idelemento == id {
                        pagina.visible = true;
                        pagina.habilitado = true;
                        self.pagesScrollView.subviews.forEach({
                            if $0.isKind(of: UIButton.self){
                                if $0.tag == index{ button = $0 as? UIButton }
                            }
                        })
                    }
                }
                self.reloadPages()
                self.segmentSelected(button)
                self.triggerPlantillaEvents(event: "validate")
                return true
            }
            
        case "nada": self.closeViewController(status: 400); return true;
        case "publicacion", "metadatos", "remplazametadatosehijos", "borrador", "finalizar":
            // Detects if needs validation
            self.isBorradorSNSalir = false
            if validar{
                let isValid = self.wizardValidation(elementValidation: atributos.elementoavalidar)
                if isValid{
                    // Detect type of transit
                    self.setTransitOptions(option: tipo)
                    // Detect if Task exist or setting next task
                    self.wizardTransit(atributos: atributos)
                    return true
                }else{
                    self.detectErrorsForm()
                    return false
                }
            }else{
                // Detect type of transit
                self.setTransitOptions(option: tipo)
                // Detect if Task exist or setting next task
                self.wizardTransit(atributos: atributos)
                return true
            }
            
        case "borradorSinSalir":
            self.isBorradorSNSalir = true
            self.banner.dismiss()
            self.flagSave = true
            self.saveWorksheet()
            break
        case "modoboton":
            self.isBorradorSNSalir = false
            if FormularioUtilities.shared.rulesAfterWizard.isEmpty{
                if atributos.plantillaabrir != ""{
                    
                    if FormularioUtilities.shared.prefilleddata != nil{
                        self.setPrefilledDataToNewForm(atributos.plantillaabrir)
                    }else{
                        self.setValuesToNewForm(atributos.plantillaabrir, atributos)
                    }
                    
                }else{
                    self.setStatusBarNotificationBanner("not_noprefill".langlocalized(), .danger, .bottom)
                }
                return true
            }else{
                let rows = self.form.allRows
                for row in rows{
                    switch row{
                    case is BotonRow:
                        let e = (row as? BotonRow)
                        let url = e!.cell.atributos?.urllink ?? ""
                        var tipoDoc:Int?
                        var expId: Int?
                        var flujoId: Int?
                        var piid: Int?
                        var guid: String?
                        for idDoc in ConfigurationManager.shared.openPlantilla{
                            if url.contains("\(idDoc.ExoID)"){
                                tipoDoc = idDoc.TipoDocID
                                expId = idDoc.ExoID
                                flujoId = idDoc.FlujoID
                                piid = idDoc.PIID
                                guid = idDoc.Guid
                            }
                        }
                        self.openForm(tipoDoc: tipoDoc!, expId: expId!, flujoId: flujoId!, piid: piid!, guid: guid!)
                        
                        break
                    default:
                        break
                    }
                }
                return false
            }
            
        default: return true
        }
        return false
    }
    
    public func setTransitOptions(option: String){
        switch option{
        case "publicacion": // Publicación (normal)
            self.formatoData.TipoReemplazo = 1
            self.formatoData.Accion = 0
            self.formatoData.EstadoApp = 2
            self.formatoData.Editado = true
            self.formatoData.NombreEstado = "datavw_card_lblstatus".langlocalized()
            break;
        case "metadatos": // Metadatos (sin reemplazar y sólo publicados)
            self.formatoData.TipoReemplazo = 0
            self.formatoData.Accion = 0
            self.formatoData.EstadoApp = 2
            self.formatoData.Editado = true
            self.formatoData.NombreEstado = "datavw_card_lblstatus".langlocalized()
            break;
        case "borrador": // Borrador (sin reemplazar y sin metadatos)
            self.formatoData.TipoReemplazo = 1
            self.formatoData.Accion = 0
            self.formatoData.EstadoApp = 2
            self.formatoData.Editado = true
            self.formatoData.NombreEstado = "datavw_card_lblstatus".langlocalized()
            break;
        case "borradorSinSalir": // Borrador sin salir (sin reemplazar y sin metadatos)
            self.formatoData.TipoReemplazo = 1
            self.formatoData.Accion = 0
            self.formatoData.EstadoApp = 1
            self.formatoData.Editado = true
            self.formatoData.NombreEstado = "datavw_card_lblstatus".langlocalized()
            break;
        case "nada": // Salir (no guardar)
            
            break;
        case "modoboton": // No hacer nada (uso para prellenado)
            
            break;
        case "remplazametadatosehijos": // Reemplazo metadatos e hijos (el padre permanece)
            self.formatoData.TipoReemplazo = 2
            self.formatoData.Accion = 0
            self.formatoData.EstadoApp = 2
            self.formatoData.Editado = true
            self.formatoData.NombreEstado = "datavw_card_lblstatus".langlocalized()
            break;
        default:
            self.formatoData.TipoReemplazo = 1
            self.formatoData.Accion = 0
            self.formatoData.EstadoApp = 2
            self.formatoData.Editado = true
            self.formatoData.NombreEstado = "datavw_card_lblstatus".langlocalized()
            break;
        }
    }
    
    public func wizardValidation(elementValidation: String)->Bool{
        
        var isValid: Bool = false
        // Se validará la misma página
        if elementValidation == "formElec_element0"{
            isValid = validateAllForms()
            return isValid
        }
        let element = getElementById(elementValidation)
        switch element {
        case is PaginaRow:
            for (index, page) in FormularioUtilities.shared.paginasVisibles.enumerated(){
                if page.idelemento == elementValidation{
                    isValid = validateSingleForm(index)
                    if isValid{
                        page.validado = true
                    }
                }
            }
            break;
        default:
            isValid = validateSingleForm(currentPage)
            FormularioUtilities.shared.paginasVisibles[currentPage].validado = true
            break;
        }
        
        return isValid
    }
    
    public func wizardTransit(atributos: Atributos_wizard){
        if atributos.tareafinalizar != ""{
            let transito = atributos.tareafinalizar.split{$0 == "_"}.map(String.init)
            for evento in ConfigurationManager.shared.plantillaDataUIAppDelegate.EventosTareas{
                if evento.PIID == Int(transito[0]) && evento.TareaID == Int(transito[1]){
                    
                    if self.presentedViewController != nil{
                        let isModal = self.presentedViewController as? ModalViewController
                        if isModal != nil{ isModal?.dismiss(animated: true, completion: nil) }
                    }
                    self.saveFormWizard(finalizar: true, evento: evento, flujo: evento.FlujoID, proceso: evento.ProcesoID, opendatend: !atributos.cerraralfinalizar, atributos: atributos)
                    
                }
            }
        }else{
            self.nextTask(atributos: atributos)
        }
        
    }
    
    public func detectErrorsForm(){
        let path = self.elementsForValidate.first
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            // We are getting the index of the required element
            for (index, ff) in self.forms.enumerated(){
                let indexPath: IndexPath? = ff.rowBy(tag: "\(path ?? "")")?.indexPath
                if indexPath == nil{ continue }
                self.pagesScrollView.subviews.forEach({
                    if $0.isKind(of: UIButton.self){
                        if $0.tag == index{
                            if self.currentPage != index{
                                self.segmentSelected($0 as? UIButton)
                            }
                        }
                    }
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    if self.tableView.indexPathExists(indexPath: indexPath ?? IndexPath(row: 0, section: 0)) {
                        self.tableView.scrollToRow(at: indexPath ?? IndexPath(row: 0, section: 0), at: .top, animated: true)
                        self.tableView.selectRow(at: indexPath ?? IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
                        
                    }
                })
            }
            self.setStatusBarNotificationBanner("not_check_fields".langlocalized(), .danger, .bottom)
        }
    }
    public func didSendResponseStatus(title: String, subtitle: String, porcentage: Float){
    }
    
    /// Funcion para publicación directa de formato electrónico
    func sendToServer() {
        DispatchQueue.main.async {
            self.showLoading()
            
            // Setting process
            // 1 SyncFormats
            // 2 SendFormats
            // 3 DownloadFormats
            ConfigurationManager.shared.utilities.isConnectedToNetwork()
                .then { response in
                    // SendFormats
                    self.sdkAPI?.DGSDKsendFormatos(delegate: self)
                        .then({ response in
                            // DownloadFormats
                            let view: RequestSuccessView?
                            view = RequestSuccessView()
                            view?.backgroundColor = .white
                            let controller = RequestSuccessController(UI: view!)
                            controller.delegate = self
                            controller.modalTransitionStyle = .coverVertical
                            controller.modalPresentationStyle = .overFullScreen
                            controller.folioEconsubanco = self.folioEconsubanco
                            if  self.atributosPlantilla?.titulo == "Biométrico" || self.atributosPlantilla?.titulo == "Captación"{
                                controller.titlePage = "\(self.atributosPlantilla?.titulo ?? "")"
                            }
                            self.present(controller, animated: true, completion: nil)
                            self.hud.dismiss(animated: true)
                            
                        }).catch({ error in
                            self.hud.dismiss(animated: true)
                            
                        })
                    
                }.catch { error in
                    self.hud.dismiss(animated: true)
                    
                }
            
        }
    }
    func saveBiobetricOffline(){
        if  self.atributosPlantilla?.titulo == "Biométrico" || self.atributosPlantilla?.titulo == "Captación"{
            self.flagBio = true
            let words = self.formatoData.Resumen.replacingOccurrences(of: "||", with: " ")
            let separatedWords = words.components(separatedBy: " ")
            var folio = ""
            if separatedWords.count >= 3 {
                folio = separatedWords[2]
                for f in separatedWords{
                    if f.contains("PP"){
                        folio = separatedWords[2]
                    }
                }
                //folio = separatedWords[2]
            }
            
            let view: SaveRequestScreenView?
            view = SaveRequestScreenView()
            view?.backgroundColor = .white
            let controller = SaveRequestScreenController(UI: view!, folio: folio)
            //controller.delegate = self
            
            controller.completionBlock = {(dataReturned) -> ()in
                
                if dataReturned == "goFirstTab" {
                    self.closeViewController(status: 200)
                } else {
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                    self.sdkAPI = nil; self.formActions = nil; self.elemtVDDocument = nil; self.navigation = nil; self.valuesArray = nil; self.filtrosArray = nil; self.xmlParsed = Elemento(); self.xmlAEXML = AEXMLDocument(); self.arrayPlantillaData = FEPlantillaData(); self.formatoData = FEFormatoData(); self.currentAnexos = [FEAnexoData](); self.atributosPlantilla = nil; self.templateDelegate = nil
                    guard let cb = self.completionBlockLocalBiometric else { return }
                    cb("successBiometric")
                }
            }
            
            controller.titlePage = "\(self.atributosPlantilla?.titulo ?? "")"
            controller.modalTransitionStyle = .coverVertical
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true, completion: nil)
            self.hud.dismiss(animated: true)
        }
    }
    /// Funcion para publicacion directa o guardar formato en servidor para EEconsubanco
    func sendToServerEC() {
        DispatchQueue.main.async {
            self.showLoading()
            // Setting process
            // 1 SyncFormats
            // 2 SendFormats
            // 3 DownloadFormats
            if InternetConnectionManager.isConnectedToNetwork(){
                ConfigurationManager.shared.utilities.isConnectedToNetwork()
                    
                    .then { response in
                        // SendFormats
                        self.sdkAPI?.DGSDKsendFormatosEC(delegate: self, formatoData: self.formatoData)
                            .then({ response in
                                // DownloadFormats
                                
                                if self.flagCot{
                                    let words = self.formatoData.Resumen.replacingOccurrences(of: "||", with: " ")
                                    let separatedWords = words.components(separatedBy: " ")
                                    var folio = ""
                                    if separatedWords.count >= 3 {
                                        folio = separatedWords[2]
                                        for f in separatedWords{
                                            if f.contains("PP"){
                                                folio = separatedWords[2]
                                            }
                                        }
                                        //folio = separatedWords[2]
                                    }
                                    let view: SaveRequestScreenView?
                                    view = SaveRequestScreenView()
                                    view?.backgroundColor = .white
                                    let controller = SaveRequestScreenController(UI: view!, folio: folio)
                                    controller.delegate = self
                                    controller.modalTransitionStyle = .coverVertical
                                    controller.modalPresentationStyle = .overFullScreen
                                    self.present(controller, animated: true, completion: nil)
                                    self.hud.dismiss(animated: true)
                                }else{
                                    let view: RequestSuccessView?
                                    view = RequestSuccessView()
                                    view?.backgroundColor = .white
                                    let controller = RequestSuccessController(UI: view!)
                                    controller.delegate = self
                                    controller.modalTransitionStyle = .coverVertical
                                    controller.modalPresentationStyle = .overFullScreen
                                    controller.folioEconsubanco = self.folioEconsubanco
                                    if  self.atributosPlantilla?.titulo == "Biométrico" || self.atributosPlantilla?.titulo == "Captación"{
                                        controller.titlePage = "\(self.atributosPlantilla?.titulo ?? "")"
                                    }
                                    self.present(controller, animated: true, completion: nil)
                                    self.hud.dismiss(animated: true)
                                }
                                
                            }).catch({ error in
                                self.hud.dismiss(animated: true)
                                if !InternetConnectionManager.isConnectedToNetwork(){
                                    self.saveBiobetricOffline()
                                }
                            })
                    }.catch { error in
                        self.hud.dismiss(animated: true)
                        self.saveBiobetricOffline()
                    }
            }else{
                self.hud.dismiss(animated: true)
                self.saveBiobetricOffline()
            }
        }
    }
    
    public func nextTask(atributos: Atributos_wizard? = nil){
        self.getTareaSiguientePromise()
            .then{ response in
                if atributos?.usuarioasignar != ""{ self.formatoData.TareaSiguiente.UsuarioAsignar = atributos?.usuarioasignar ?? "" }
                FormularioUtilities.shared.globalFlujo = self.formatoData.TareaSiguiente.FlujoID
                FormularioUtilities.shared.globalProceso = self.formatoData.TareaSiguiente.ProcesoID
                self.setValuesToObject(false, atributos, accion: actionForm.publicado)
            }
            .catch{ error in
                self.setStatusBarNotificationBanner("not_transit_error".langlocalized(), .danger, .bottom)
            }
    }
    
    public func saveFormWizard(finalizar: Bool?, evento: FEEventosFlujo? = nil, flujo: Int? = 0, proceso: Int? = 0, opendatend: Bool? = false, atributos: Atributos_wizard? = nil){
        self.flagSave = false
        if finalizar!{
            self.formatoData.TareaSiguiente = evento!
            if atributos?.usuarioasignar != ""{ self.formatoData.TareaSiguiente.UsuarioAsignar = atributos?.usuarioasignar ?? "" }
            FormularioUtilities.shared.globalFlujo = flujo!
            FormularioUtilities.shared.globalProceso = proceso!
            self.setValuesToObject(opendatend!, atributos, accion: actionForm.publicado)
        }else{
            self.formatoData.TareaSiguiente = evento!
            if atributos?.usuarioasignar != ""{ self.formatoData.TareaSiguiente.UsuarioAsignar = atributos?.usuarioasignar ?? "" }
            FormularioUtilities.shared.globalFlujo = flujo!
            FormularioUtilities.shared.globalProceso = proceso!
            self.setValuesToObject(accion: actionForm.publicado)
        }
    }
    
    @objc public func saveWorksheet(){
        self.setValuesToObject(accion: actionForm.publicado)
        // Setting Local displaying options
        FormularioUtilities.shared.globalFlujo = self.formatoData.FlujoID
        FormularioUtilities.shared.globalProceso = 0
    }
    
    @objc public func saveWorksheetTable(atributos: Atributos_wizard? = nil){
        //self.setValuesToObject(false, atributos)
        self.setValuesToObjectTabla(false, atributos)
        // Setting Local displaying options
        FormularioUtilities.shared.globalFlujo = self.formatoData.FlujoID
        FormularioUtilities.shared.globalProceso = 0
    }
    
    public func wizardValidate(isvalid: Bool) -> Bool{
        
        if isvalid{
            self.formatoData.EstadoApp = 2
            self.formatoData.Editado = true
            self.formatoData.NombreEstado = "datavw_card_lblstatus".langlocalized()
            self.getTareaSiguientePromise()
                .then{ response in
                    FormularioUtilities.shared.globalFlujo = self.formatoData.TareaSiguiente.FlujoID
                    FormularioUtilities.shared.globalProceso = self.formatoData.TareaSiguiente.ProcesoID
                    DispatchQueue.main.async { self.setValuesToObject(accion: actionForm.publicado) }
                }
                .catch{ error in
                    self.setStatusBarNotificationBanner("not_transit_error".langlocalized(), .danger, .bottom)
                }
            return true
        }else{
            // Detect if the error is in the same page, otherwise we need to go back to another form
            self.detectErrorsForm()
            return false
        }
    }
    
    public func deleteFormatFromLocal(formato: FEFormatoData){
        self.sdkAPI?.DGSDKformatoDelete(delegate: self, formato: formato)
            .then({ response in
                let leftView = UIImageView(image: UIImage(named: "info_alert", in: Cnstnt.Path.framework, compatibleWith: nil))
                let bannerNew = NotificationBanner(title: "", subtitle: "not_delete_format".langlocalized(), leftView: leftView, rightView: nil, style: .success, colors: nil)
                bannerNew.show()
            }).catch({ _ in })
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) { self.checkLocationPermission() }
    @objc func applicationDidEnterBackground(notification: NSNotification) { }
    
    /// Hud Loader whit timer for a better experience in the init Form
    @objc func initHudView(){
        ConfigurationManager.shared.utilities.writeLogger("Function initHudView", .format)
        
        showLoading()
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(initCheckLocation), userInfo: nil, repeats: false)
    }
    
    /// Check if the user has the permission for the user location if no there is no a way to load the format
    @objc func initCheckLocation(){
        ConfigurationManager.shared.utilities.writeLogger("Function initCheckLocation", .format)
        
        timer.invalidate()
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.checkLocationPermission()
    }
    
    public convenience init(_ template: TemplateDelegate, _ plantilla: FEPlantillaData, _ index: Int, _ isEdited: Bool) {
        self.init(nibName: "iBDcDDDRiUOwvhx", bundle: Cnstnt.Path.framework)
        
        templateDelegate = template
        
        ConfigurationManager.shared.isInEditionMode = isEdited
        ConfigurationManager.shared.utilities.initLogFormat()
        ConfigurationManager.shared.utilities.writeLogger("Iniciando el formato", .format)
        FormularioUtilities.shared.currentFormato = FEFormatoData()
        FormularioUtilities.shared.currentFormato.FlujoID = plantilla.FlujoID
        FormularioUtilities.shared.currentFormato.TipoDocID = plantilla.TipoDocID
        FormularioUtilities.shared.currentFormato.ExpID = plantilla.ExpID
        
        self.formatoData = FormularioUtilities.shared.currentFormato
        
        self.index = index
        self.flujo = plantilla.FlujoID
        self.proceso = 0
        self.arrayPlantillaData = plantilla
        
        ConfigurationManager.shared.utilities.writeLogger("Iniciando el formato", .format)
        ConfigurationManager.shared.utilities.writeLogger("Flujo: \(plantilla.FlujoID), TipoDocID: \(plantilla.TipoDocID), ExpID: \(plantilla.ExpID)", .format)
    }
    
    public convenience init(_ template: TemplateDelegate, _ formato: FEFormatoData, _ index: Int, _ isEdited: Bool) {
        self.init(nibName: "iBDcDDDRiUOwvhx", bundle: Cnstnt.Path.framework)
        
        templateDelegate = template
        
        ConfigurationManager.shared.isInEditionMode = isEdited
        ConfigurationManager.shared.utilities.initLogFormat()
        ConfigurationManager.shared.utilities.writeLogger("Iniciando el formato", .format)
        FormularioUtilities.shared.currentFormato = formato
        
        self.formatoData = formato
        
        for ane in formato.Anexos{
            self.currentAnexos.append(ane)
        }
        
        self.index = index
        self.flujo = formato.FlujoID
        self.proceso = formato.ProcesoID
        ConfigurationManager.shared.utilities.writeLogger("Flujo: \(formato.FlujoID), ProcesoID: \(formato.ProcesoID), ExpID: \(formato.ExpID)", .format)
    }
    
    // MARK: - Handle Gestures
    @objc func openElementDetails() {
        let debug = DebugFormViewController(nibName: "DebugFormViewController", bundle: Cnstnt.Path.framework)
        debug.forms = self.forms
        debug.delegate = self
        self.present(debug, animated: true, completion: nil)
    }
    
    @objc func openSettings() {
        let actionAlert = UIAlertController(title: "Settings", message: "Utiliza las siguientes opciones", preferredStyle: UIAlertController.Style.actionSheet)
        let enableAllPages = UIAlertAction(title: "Enable All Pages", style: .default) { (action: UIAlertAction) in
            // Enable All Pages
            for pagina in FormularioUtilities.shared.paginasVisibles{ pagina.habilitado = true; }
            self.reloadPages()
        }
        let visibleAllPages = UIAlertAction(title: "Visible All Pages", style: .default) { (action: UIAlertAction) in
            // Visible All Pages
            for pagina in FormularioUtilities.shared.paginasVisibles{ pagina.visible = true; pagina.vertab = true; }
            self.reloadPages()
        }
        let enableAllElements = UIAlertAction(title: "Enable All Elements", style: .default) { (action: UIAlertAction) in
            // Enable All Elements
            for row in self.forms[self.currentPage].allRows{
                row.disabled = false
                row.baseCell.isUserInteractionEnabled = true
                row.evaluateDisabled()
            }
        }
        let visibleAllElements = UIAlertAction(title: "Visible All Elements", style: .default) { (action: UIAlertAction) in
            // Visible All Elements
            for row in self.forms[self.currentPage].allRows{
                row.hidden = false
                row.evaluateHidden()
            }
        }
        let goto = UIAlertAction(title: "Go to Page", style: .default) { (action: UIAlertAction) in
            self.enableAllPagesToGo()
        }
        let logFormat = UIAlertAction(title: "Format Log", style: .default) { (action: UIAlertAction) in
            // Visible All Elements
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray).firstObject as? String ?? ""
            if paths != "" {
                let str = ConfigurationManager.shared.utilities.readLogger("format.txt")
                let data = str.data(using: .utf8)
                var completeUrl = URL(fileURLWithPath: paths)
                completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/format")
                completeUrl.appendPathExtension("txt")
                do {
                    try data?.write(to: completeUrl, options: .atomic)
                    if FileManager.default.fileExists(atPath: completeUrl.path), let pdf = FileManager.default.contents(atPath: completeUrl.path) {
                        DispatchQueue.main.async {
                            let activityViewController = UIActivityViewController(activityItems: [pdf], applicationActivities: nil)
                            self.present(activityViewController, animated: true, completion: {
                                do {
                                    try FileManager.default.removeItem(at: completeUrl)
                                }catch { }
                            })
                        }
                    }
                }catch{ }
            }
        }
        
        let shareXML = UIAlertAction(title: "Share XML", style: .default) { (action: UIAlertAction) in
            // Sharing XML
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray).firstObject as? String ?? ""
            if paths != "" {
                let data = self.xmlAEXML.xmlCompact.data(using: .utf8)
                var completeUrl = URL(fileURLWithPath: paths)
                completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/xml")
                completeUrl.appendPathExtension("txt")
                do {
                    try data?.write(to: completeUrl, options: .atomic)
                    if FileManager.default.fileExists(atPath: completeUrl.path), let pdf = FileManager.default.contents(atPath: completeUrl.path) {
                        DispatchQueue.main.async {
                            let activityViewController = UIActivityViewController(activityItems: [pdf], applicationActivities: nil)
                            self.present(activityViewController, animated: true, completion: {
                                do {
                                    try FileManager.default.removeItem(at: completeUrl)
                                }catch { }
                            })
                        }
                    }
                }catch{ }
            }
        }
        let sharePlantilla = UIAlertAction(title: "Share Plantilla Data", style: .default) { (action: UIAlertAction) in
            // Sharing Plantilla
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray).firstObject as? String ?? ""
            if paths != "" {
                let data = ConfigurationManager.shared.plantillaDataUIAppDelegate.toJsonString().data(using: .utf8)
                var completeUrl = URL(fileURLWithPath: paths)
                completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/data")
                completeUrl.appendPathExtension("txt")
                do {
                    try data?.write(to: completeUrl, options: .atomic)
                    if FileManager.default.fileExists(atPath: completeUrl.path), let pdf = FileManager.default.contents(atPath: completeUrl.path) {
                        DispatchQueue.main.async {
                            let activityViewController = UIActivityViewController(activityItems: [pdf], applicationActivities: nil)
                            self.present(activityViewController, animated: true, completion: {
                                do {
                                    try FileManager.default.removeItem(at: completeUrl)
                                }catch { }
                            })
                        }
                    }
                }catch{ }
            }
        }
        let shareJsonDatos = UIAlertAction(title: "Share Json Data", style: .default) { (action: UIAlertAction) in
            // Sharing XML
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray).firstObject as? String ?? ""
            if paths != "" {
                self.ElementosArray = NSMutableDictionary()
                var theJsonText = String()
                self.setMetaAttributes(self.xmlParsed, false)
                self.loopElements(self.xmlParsed)
                if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: self.ElementosArray, options: .sortedKeys){
                    theJsonText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
                    theJsonText = theJsonText.replacingOccurrences(of: "\\\\\\\"", with: "\\\"")
                }
                let data = theJsonText.data(using: .utf8)
                var completeUrl = URL(fileURLWithPath: paths)
                completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/json")
                completeUrl.appendPathExtension("txt")
                do {
                    try data?.write(to: completeUrl, options: .atomic)
                    if FileManager.default.fileExists(atPath: completeUrl.path), let pdf = FileManager.default.contents(atPath: completeUrl.path) {
                        DispatchQueue.main.async {
                            let activityViewController = UIActivityViewController(activityItems: [pdf], applicationActivities: nil)
                            self.present(activityViewController, animated: true, completion: {
                                do {
                                    try FileManager.default.removeItem(at: completeUrl)
                                }catch { }
                            })
                        }
                    }
                }catch{ }
            }
        }
        actionAlert.addAction(enableAllPages)
        actionAlert.addAction(visibleAllPages)
        actionAlert.addAction(enableAllElements)
        actionAlert.addAction(visibleAllElements)
        actionAlert.addAction(goto)
        actionAlert.addAction(logFormat)
        actionAlert.addAction(shareXML)
        actionAlert.addAction(sharePlantilla)
        actionAlert.addAction(shareJsonDatos)
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        actionAlert.addAction(cancel)
        self.present(actionAlert, animated: true, completion: nil)
    }
    
    func enableAllPagesToGo(){
        let actionAlert = UIAlertController(title: "Settings", message: "Utiliza las siguientes opciones", preferredStyle: UIAlertController.Style.actionSheet)
        for (index, pagina) in FormularioUtilities.shared.paginasVisibles.enumerated(){
            let pageEnabled = UIAlertAction(title: "\(pagina.titulo)", style: .default) { (action: UIAlertAction) in
                self.segmentSelected = index
                self.timer = Timer.scheduledTimer(timeInterval: 0.50, target: self, selector: #selector(self.initSetFormPromise), userInfo: nil, repeats: false)
            }
            actionAlert.addAction(pageEnabled)
        }
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        actionAlert.addAction(cancel)
        self.present(actionAlert, animated: true, completion: nil)
    }
    /// Init the timer for load the configuration
    // MARK: - viewDidLoad
    override public func viewDidLoad() {
        super.viewDidLoad()
        let fechaInicio = Date.getTicks()
        self.fechaInicial = fechaInicio
        let defaults = UserDefaults.standard
        let serial = defaults.string(forKey: Cnstnt.BundlePrf.serial)
        if serial == "QWEASDZXC"{
            let gestLeft = UISwipeGestureRecognizer(target: self, action: #selector(openElementDetails))
            gestLeft.direction = .left
            gestLeft.numberOfTouchesRequired = 3
            self.tableView.addGestureRecognizer(gestLeft)
            
            let gestRight = UISwipeGestureRecognizer(target: self, action: #selector(openSettings))
            gestRight.direction = .right
            gestRight.numberOfTouchesRequired = 3
            self.tableView.addGestureRecognizer(gestRight)
            
            let executeMacroGesture = UILongPressGestureRecognizer(target: self, action: #selector(executeMacros))
            executeMacroGesture.minimumPressDuration = 2.0
            self.btnGuardar?.addGestureRecognizer(executeMacroGesture)
        }
        FCFileManager.removeItem(atPath: "video.mp4")
        
        self.switchAutoSave.isOn = false
        self.labelAutoSave.text = "nvapla_autosaved_off".langlocalized()
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(initHudView), userInfo: nil, repeats: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func dismiss(s: [String : Any]?, e: NSError?){
        // Dismiss ViewController
        self.dismiss(animated: true) {
            self.resettingSettings()
            self.completionHandler?(self, s, e)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func rotated() {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    deinit{
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.timer.invalidate()
        self.saveTimer?.invalidate()
        self.sdkAPI?.delegate = nil
        self.form.delegate = nil
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // MARK: - viewDidAppear
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // heightViewEffect
        // tableTopView
        self.viewControllerR?.delegate = self
        self.switchAutoSave.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    }
    // MARK: - viewWillAppear
    public override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(true) }
    // MARK: - viewWillDisappear
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.flagLocation = false
        self.saveTimer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    // MARK: - didReceiveMemoryWarning
    override public func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    // MARK - switch Auto-Save Action
    @IBAction func autoSaveAction(_ sender: UISwitch) {
        if self.switchAutoSave.isOn{
            self.labelAutoSave.text = "nvapla_autosaved_on".langlocalized()
            self.saveTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.saveWorksheet), userInfo: nil, repeats: true)
        }else{
            self.labelAutoSave.text = "nvapla_autosaved_off".langlocalized()
            self.saveTimer?.invalidate()
        }
    }
    
    
    /// This is the first function to set the configuration for the form
    func defaultSettings(){
        ConfigurationManager.shared.utilities.writeLogger("Default Settings", .format)
        
        ConfigurationManager.shared.utilities.resetFolderTree("Digipro/Collector")
        self.navigationController?.isNavigationBarHidden = true
        self.tableView.separatorStyle = .none
        self.tableView.alwaysBounceVertical = false
        
        // Segment Control - Pages
        let screenSize: CGRect = UIScreen.main.bounds
        var widthView = screenSize.width
        if (UIDevice.current.model.contains("iPad")) { widthView = widthView < self.view.frame.size.width ? self.view.frame.size.width : widthView }
        
        // Variables initiialization
        ConfigurationManager.shared.garbageCollector = [(id: String, value: String, desc: String)]()
        FormularioUtilities.shared.elementsInPlantilla = [(id: String, type: String, kind: Any?, element: Elemento?)]()
        FormularioUtilities.shared.atributosPaginas = [Atributos_pagina]()
        FormularioUtilities.shared.paginasVisibles = [Atributos_pagina]()
        
        // Delegates
        formActions = FormManager<NuevaPlantillaViewController>()
        formActions?.delegate = self
        
        sdkAPI = APIManager<NuevaPlantillaViewController>()
        sdkAPI?.delegate = self
        
        // Obtain Guid for the format
        if FormularioUtilities.shared.currentFormato.Guid == "" || FormularioUtilities.shared.currentFormato.Guid == "0"{
            ConfigurationManager.shared.guid = ConfigurationManager.shared.utilities.guid()
            formatoData.Guid = ConfigurationManager.shared.guid
        }else{
            ConfigurationManager.shared.guid = FormularioUtilities.shared.currentFormato.Guid
            formatoData.Guid = ConfigurationManager.shared.guid
        }
        
        // Obtain Json for saved formato
        dictValues = Dictionary<String, (docid:String, valor:String, valormetadato:String, tipodoc:String, metadatostipodoc:String, nameFirm:String, dateFirm:String, georefFirm:String, deviceFirm:String)>()
        self.getValuesJson(FormularioUtilities.shared.currentFormato.JsonDatos)
        
        // Enable location services for getting Lat and Lon for the format
        if CLLocationManager.locationServicesEnabled() { self.locationManager.startUpdatingLocation() }
        
        // Init Form Generation
        self.initForm()
    }
        
    public func initForm(){
        self.flagEventos = true
        ConfigurationManager.shared.utilities.writeLogger("Function InitForm", .format)
        ConfigurationManager.shared.utilities.writeLogger("Plantilla seleccionada: \(FormularioUtilities.shared.currentFormato.FlujoID) \(FormularioUtilities.shared.currentFormato.ExpID) \(FormularioUtilities.shared.currentFormato.TipoDocID)", .format)
        let pla = FEOpenPlantilla()
        pla.FlujoID = FormularioUtilities.shared.currentFormato.FlujoID
        pla.ExoID = FormularioUtilities.shared.currentFormato.ExpID
        pla.TipoDocID = FormularioUtilities.shared.currentFormato.TipoDocID
        pla.Guid = FormularioUtilities.shared.currentFormato.Guid
        pla.PIID = FormularioUtilities.shared.currentFormato.PIID
        ConfigurationManager.shared.openPlantilla.append(pla)
        self.openPlantilla = pla
        
        self.feOpenPlantilla.append(pla) // 1
        
        xmlParsed = (self.sdkAPI?.getXML(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))) ?? Elemento()
        
        xmlAEXML = (self.sdkAPI?.getPLANTILLA(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))) ?? AEXMLDocument()
        
        ConfigurationManager.shared.utilities.writeLogger("Obteniendo xml de la plantilla", .format)
        
        if(xmlParsed._tipoelemento == "plantilla") {
            atributosPlantilla = xmlParsed.atributos as? Atributos_plantilla
            if atributosPlantilla == nil{
                let atributos = Atributos_plantilla(xmlString: xmlAEXML.root.children[0].xmlCompact)
                let macros = xmlAEXML.root.children[0]["macros"]
                self.parseMacros(macros)
                //Obtenerlo de los atributos parece no funcionar pero podemos hacer esto:
                //xmlAEXML.root.children[0]["macro"]
                
                //                <macros><fcbafafbdadbedbcaea><name>Macro Prueba iOS</name><steps><fbdbfdbbcbbbcdabeadcaa><name>Primer Ejecucion</name><enabled>true</enabled><actions><enabled>true</enabled><action>fillt</action><who>formElec_element181</who><what>Prueba</what></actions></fbdbfdbbcbbbcdabeadcaa></steps></fcbafafbdadbedbcaea></macros>
                xmlParsed.atributos = atributos
                atributosPlantilla = atributos
                if self.atributosPlantilla?.tiempoautoguardado ?? 0 <= 0{
                    self.switchAutoSave.isHidden = true
                    self.labelAutoSave.isHidden = true
                }else{
                    self.banner.dismiss()
                    self.flagSave = true
                    let seconds: Double = Double(atributosPlantilla?.tiempoautoguardado ?? 2) * Double(60.0)
                    self.saveTimer = Timer.scheduledTimer(timeInterval: TimeInterval(seconds), target: self, selector: #selector(self.saveWorksheet), userInfo: nil, repeats: true)
                }
            }
            
            if atributosPlantilla?.titulo ?? "" == ""{ titlePlantilla.isHidden = true }
            titlePlantilla.text = atributosPlantilla?.titulo.uppercased() ?? ""
            if atributosPlantilla?.subtitulo ?? "" == ""{ subtitlePlantilla.isHidden = true }
            subtitlePlantilla.text = atributosPlantilla?.subtitulo.uppercased() ?? ""
            if atributosPlantilla?.ocultartitulo ?? false{titlePlantilla.isHidden = true }else{titlePlantilla.isHidden = false }
            if atributosPlantilla?.ocultarsubtitulo ?? false{subtitlePlantilla.isHidden = true }else{subtitlePlantilla.isHidden = false }
            if self.atributosPlantilla?.verguardar ?? true == false && self.atributosPlantilla?.versalir ?? true == false && self.atributosPlantilla?.ocultartitulo ?? true && self.atributosPlantilla?.ocultarsubtitulo ?? true{
                isDisableTopVw = true
            }
            
            let ttl = titlePlantilla.frame.height
            let sttl = subtitlePlantilla.frame.height
            var httl: Double = 0
            var hsttl: Double = 0
            if self.atributosPlantilla != nil{
                if self.atributosPlantilla?.ocultartitulo ?? false || self.atributosPlantilla?.titulo == ""{ httl = -19.5 }else{ httl = Double(ttl) }
                if self.atributosPlantilla?.ocultarsubtitulo ?? false || self.atributosPlantilla?.subtitulo == ""{ hsttl = -19.5 }else{ hsttl = Double(sttl) }
            }
            let h: Double = httl + hsttl
            let hh = (80) + CGFloat(h)
            
            if isDisableTopVw{
                for constraint in self.viewVisual.constraints { if constraint.identifier == "heightTopView" { constraint.constant = 0 } }
                UIView.animate(withDuration: 0.55) { self.view.layoutIfNeeded(); }
            }else{
                for constraint in self.viewVisual.constraints { if constraint.identifier == "heightTopView" { constraint.constant = hh } }
                UIView.animate(withDuration: 0.55) { self.view.layoutIfNeeded(); }
            }
            
            configureColors()
            configureButtons()
            configurePermissions()
            
        }
        
        ConfigurationManager.shared.utilities.writeLogger("Promise SettingAllElementsInForm", .format)
        self.settingAllElementsInForms()
            .then {response in
                ConfigurationManager.shared.utilities.writeLogger("Promise success", .format)
                self.settingPagesView()
                return
            }.catch {error in
                ConfigurationManager.shared.utilities.writeLogger("Promise error: \(error)", .format)
                self.setNotificationBanner("alrt_warning".langlocalized(), "not_form_noelements".langlocalized(), .warning, .top)
                self.hud.dismiss(animated: true)
            }
    }
    
    func configureFooter(){
        
        if isFooterDetected{
            if footerViewController == nil{
                for constraint in self.view.constraints {
                    if constraint.identifier == "tblbottom" {
                        constraint.constant = -70
                    }
                }
                footerViewController = FooterViewController(nibName: "iBDcDDDRiUOaljr", bundle: Cnstnt.Path.framework)
                addChild(footerViewController!)
                self.view.addSubview(footerViewController!.view)
                footerViewController!.view.translatesAutoresizingMaskIntoConstraints = false
                footerViewController!.view.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
                footerViewController!.view.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
                footerViewController!.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
                footerViewController!.view.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 0).isActive = true
                footerViewController!.didMove(toParent: self)
                footerViewController!.form = footerForm
            }
            for row in footerViewController!.form.allRows{
                switch row {
                case is WizardRow: (row as! WizardRow).cell.refreshNavigation(); break;
                default: break;
                }
            }
            footerViewController!.tableView.reloadData()
        }else{
            for constraint in self.view.constraints {
                if constraint.identifier == "tblbottom" {
                    constraint.constant = 0
                }
            }
        }
        DispatchQueue.main.async {
            self.stopLoading()
        }
    }
    
    // MARK: - Permissions in Plantilla, User and Code
    func configurePermissions(){
        // Wee need to detect if is Consubanco or the Generic App
        if ConfigurationManager.shared.isConsubanco{
            // Consubanco
            // Hack only for Consubanco
            btnBack?.isHidden = false
            btnGuardar?.isHidden = true
        }else{
            btnGuardar?.isHidden = !(self.atributosPlantilla?.verguardar ?? true)
            btnBack?.isHidden = !(self.atributosPlantilla?.versalir ?? true)
        }
        plantillamapear = atributosPlantilla?.plantillamapearprellenado ?? ""
    }
    
    func settingPagesView(){
        ConfigurationManager.shared.utilities.writeLogger("Function SettingPagesView", .format)
        var firstVisibility: UIButton? = nil
        
        self.view.addSubview(pagesScrollView)
        pagesScrollView.backgroundColor = .clear
        pagesScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        pagesScrollView.topAnchor.constraint(equalTo: viewVisual.bottomAnchor, constant: 0.0).isActive = true
        pagesScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        pagesScrollView.removeConstraint(bottomConstraint)
        pagesScrollView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 0.0).isActive = true
        
        var leading = pagesScrollView.leadingAnchor
        var totalWidth: CGFloat = 0.0
        ConfigurationManager.shared.utilities.writeLogger("Pages:", .format)
        for (index, pagina) in FormularioUtilities.shared.paginasVisibles.enumerated(){
            ConfigurationManager.shared.utilities.writeLogger("\(pagina.titulo)", .format)
            let label = BotonPagina()
            
            let mayBeEstilo: EstiloBoton? = EstiloBoton(rawValue: atributosPlantilla?.estilotabs ?? "fondo")
            
            let color: UIColor = UIColor(hexFromString: atributosPlantilla?.colortabnormal ?? "#ffffff")
            let colorTexto: UIColor = UIColor(hexFromString: atributosPlantilla?.colortabtextonormal ?? "#ffffff")
            
            if let estilo = mayBeEstilo {
                label.configurar(estilo: estilo, titulo: pagina.titulo, color: color, colorTexto: colorTexto)
            } else {
                label.configurar(estilo: .conRelleno, titulo: pagina.titulo, color: color, colorTexto: colorTexto)
            }
            
            label.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.addTarget(self, action: #selector(segmentSelected(_:)), for: .touchUpInside)
            label.tag = index
            
            pagesScrollView.addSubview(label)
            label.leadingAnchor.constraint(equalTo: leading, constant: 1).isActive = true
            label.topAnchor.constraint(equalTo: pagesScrollView.topAnchor, constant: 0).isActive = true
            label.heightAnchor.constraint(equalToConstant: 40).isActive = true
            if pagina.habilitado{
                if pagina.visible, pagina.vertab{
                    label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width + 20).isActive = true
                    leading = label.trailingAnchor
                    label.isHidden = false
                    label.isUserInteractionEnabled = true
                    //let normal = UIColor(hexFromString: (self.atributosPlantilla?.colortabnormal ?? "#3d9970")!)
                    //label.backgroundColor = normal
                    totalWidth += label.intrinsicContentSize.width + 20.0
                    if firstVisibility == nil{
                        firstVisibility = label
                    }
                }else if pagina.visible, !pagina.vertab{
                    label.widthAnchor.constraint(equalToConstant: 0).isActive = true
                    leading = label.trailingAnchor
                    label.isHidden = true
                    if firstVisibility == nil{
                        firstVisibility = label
                    }
                }else if !pagina.visible{
                    label.widthAnchor.constraint(equalToConstant: 0).isActive = true
                    leading = label.trailingAnchor
                    label.isHidden = true
                }
            }else{
                label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width + 20).isActive = true
                leading = label.trailingAnchor
                label.isHidden = false
                label.isUserInteractionEnabled = false
                //let normal = UIColor(hexFromString: (self.atributosPlantilla?.colortabinhabilitado ?? "#cccccc")!)
                //label.backgroundColor = normal
                totalWidth += label.intrinsicContentSize.width + 20.0
            }
        }
        pagesScrollView.contentSize = CGSize(width: totalWidth, height: 40)
        if totalWidth == 0.0{
            pagesScrollView.removeConstraint(bottomConstraint)
            pagesScrollView.bottomAnchor.constraint(equalTo: viewVisual.bottomAnchor, constant: 0.0).isActive = true
        }
        if firstVisibility != nil{ self.segmentSelected(firstVisibility!) }
        
    }
    
    func reloadPages(){
        var totalWidth: CGFloat = 0.0
        
        let normal = UIColor(hexFromString: (self.atributosPlantilla?.colortabnormal ?? "#3d9970")!)
        let activo = UIColor(hexFromString: (self.atributosPlantilla?.colortabactivo ?? "#3c8dbc")!)
        let inhabilitado = UIColor(hexFromString: (self.atributosPlantilla?.colortabinhabilitado ?? "#cccccc")!)
        
        let textoNormal = UIColor(hexFromString: self.atributosPlantilla?.colortabtextonormal ?? "#3d9970")
        let textoActivo = UIColor(hexFromString: self.atributosPlantilla?.colortabtextoactivo ?? "#3c8dbc")
        let textoInhabilitado = UIColor(hexFromString: self.atributosPlantilla?.colortabtextoinhabilitado ?? "#3d9970")
        
        self.pagesScrollView.subviews.forEach({
            if $0.isKind(of: BotonPagina.self){
                let pagina = FormularioUtilities.shared.paginasVisibles[$0.tag]
                if pagina.habilitado{
                    if pagina.visible, pagina.vertab {
                        for c in $0.constraints { if c.firstAttribute == .width { c.constant = $0.intrinsicContentSize.width + 20 } }
                        $0.isHidden = false
                        $0.isUserInteractionEnabled = true
                        //$0.backgroundColor = normal
                        if let boton = $0 as? BotonPagina {
                            boton.aplicarColor(normal, colorTexto: textoNormal, estilo: boton.estilo)
                        }
                        
                        totalWidth += $0.intrinsicContentSize.width + 20.0
                    }else if pagina.visible, !pagina.vertab{
                        for c in $0.constraints { if c.firstAttribute == .width { c.constant = 0 } }
                        $0.isHidden = true
                    }else if !pagina.visible{
                        for c in $0.constraints { if c.firstAttribute == .width { c.constant = 0 } }
                        $0.isHidden = true
                    }
                }else{
                    for c in $0.constraints { if c.firstAttribute == .width { c.constant = $0.intrinsicContentSize.width + 20 } }
                    $0.isHidden = false
                    $0.isUserInteractionEnabled = false
                    if let boton = $0 as? BotonPagina {
                        boton.aplicarColor(inhabilitado, colorTexto: textoInhabilitado, estilo: boton.estilo)
                    }
                    //$0.backgroundColor = inhabilitado
                    totalWidth += $0.intrinsicContentSize.width + 20.0
                }
                if $0.tag == self.currentPage{
                    //$0.backgroundColor = activo
                    if let boton = $0 as? BotonPagina {
                        boton.aplicarColor(activo, colorTexto: textoActivo, estilo: boton.estilo)
                    }
                    $0.isUserInteractionEnabled = false
                }
            }
        })
        pagesScrollView.layoutIfNeeded()
        pagesScrollView.layoutSubviews()
        pagesScrollView.contentSize = CGSize(width: totalWidth, height: 40)
        if totalWidth == 0.0{
            pagesScrollView.removeConstraint(bottomConstraint)
            pagesScrollView.bottomAnchor.constraint(equalTo: viewVisual.bottomAnchor, constant: 0.0).isActive = true
        }
    }
    
    @objc func segmentSelected(_ sender: UIButton?) {
        ConfigurationManager.shared.utilities.writeLogger("Function SegmentSelected", .format)
        ConfigurationManager.shared.utilities.writeLogger("Page selected: \(sender?.tag ?? 0)", .format)
        // Need to detect if proceed to change or invalidate
        if sender?.tag ?? -1 == -1{ return }
        let normal = UIColor(hexFromString: (self.atributosPlantilla?.colortabnormal ?? "#3d9970")!)
        let activo = UIColor(hexFromString: (self.atributosPlantilla?.colortabactivo ?? "#3c8dbc")!)
        let inhabilitado = UIColor(hexFromString: (self.atributosPlantilla?.colortabinhabilitado ?? "#cccccc")!)
        
        let textoNormal = UIColor(hexFromString: self.atributosPlantilla?.colortabtextonormal ?? "#3d9970")
        let textoActivo = UIColor(hexFromString: self.atributosPlantilla?.colortabtextoactivo ?? "#3c8dbc")
        let textoInhabilitado = UIColor(hexFromString: self.atributosPlantilla?.colortabtextoinhabilitado ?? "#3d9970")
        
        self.pagesScrollView.subviews.forEach({
            if $0.isKind(of: UIButton.self){
                let pagina = FormularioUtilities.shared.paginasVisibles[$0.tag]
                if pagina.habilitado{
                    if pagina.visible, pagina.vertab{
                        $0.isUserInteractionEnabled = true
                        $0.isHidden = false
                        if let boton = $0 as? BotonPagina {
                            boton.aplicarColor(normal, colorTexto: textoNormal, estilo: boton.estilo)
                        }
                    }else if pagina.visible, !pagina.vertab{ $0.isHidden = true
                    }else if !pagina.visible{ $0.isHidden = true }
                }else{
                    $0.isUserInteractionEnabled = false
                    $0.isHidden = false
                    if let boton = $0 as? BotonPagina {
                        boton.aplicarColor(inhabilitado, colorTexto: textoInhabilitado, estilo: boton.estilo)
                    }
                }
            }
        })
        
        sender?.isUserInteractionEnabled = false
        
        if let boton = sender as? BotonPagina {
            boton.aplicarColor(activo, colorTexto: textoActivo, estilo: boton.estilo)
        }
        
        self.segmentSelected = sender?.tag ?? 0
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(initHudPerPage), userInfo: nil, repeats: false)
    }
    
    @objc func initHudPerPage(){
        ConfigurationManager.shared.utilities.writeLogger("Function InitHudPerPage", .format)
        showLoading()
        timer.invalidate() //4.5
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(initSetFormPromise), userInfo: nil, repeats: false)
    }
    
    @objc func initSetFormPromise() {
        timer.invalidate()
        ConfigurationManager.shared.utilities.writeLogger("Promise setFormPromise", .format)
        setFormPromise(index: self.segmentSelected, override: false)
            .then { response in
                ConfigurationManager.shared.utilities.writeLogger("Promise success", .format)
                self.setFormulasAndRules(index: self.segmentSelected, override: false)
                    .then({ response in
                        self.setCoordinates()
                        DispatchQueue.global(qos: .background).async {
                            self.reloadContentCombos(self.segmentSelected)
                        }
                        self.reloadElementsByAction(self.segmentSelected)
                    }).catch({ error in
                        self.hud.dismiss(animated: true)
                        self.setNotificationBanner("alrt_warning".langlocalized(), "not_form_norules".langlocalized(), .warning, .top)
                    })
            }.catch { error in
                ConfigurationManager.shared.utilities.writeLogger("Promise error: \(error)", .format)
                self.hud.dismiss(animated: true)
                self.setNotificationBanner("alrt_warning".langlocalized(), "not_form_noelements".langlocalized(), .warning, .top)
            }
        stopLoading()
        
    }
    
    public func reloadContentCombos(_ index: Int){
        DispatchQueue.main.async {
            self.hud = JGProgressHUD(style: .dark)
            self.hud.show(in: self.view)
        }
        ConfigurationManager.shared.utilities.writeLogger("Set parameters to Combo Dinamico", .format)
        if self.forms.count == 0 {
            DispatchQueue.main.async {
                self.hud.dismiss(animated: true)
            }
            return
        }
        for rows in self.forms[index].allRows{
            if let row = rows as? ComboDinamicoRow {
                ConfigurationManager.shared.utilities.writeLogger("Combo dinámico: \(row.tag ?? "")", .format)
                DispatchQueue.main.async {
                    row.cell.settingValuesSync()
                        .then { response in
                            if row.cell.elemento.validacion.valor != ""{
                                row.cell.valueOpen = true
                                if row.cell.atributos?.tipolista == "combo"
                                {
                                    let valuesArray : Array<String> = row.cell.elemento.validacion.valormetadatoinicial.split{$0 == ","}.map(String.init)
                                    var showedValues = ""
                                    for item in row.cell.listItemsCombo {
                                        let val = String(item.split(separator: "|").first ?? "")
                                        let id = String(item.split(separator: "|").last ?? "")
                                        for val in valuesArray{
                                            if id.lowercased() == val.lowercased() ||
                                                val.lowercased() == val.lowercased() ||
                                                id.lowercased() == row.cell.elemento.validacion.valormetadatoinicial.lowercased(){
                                                showedValues = val
                                            }
                                        }
                                    }
                                    row.cell.setEdited(v: showedValues != "" ? showedValues : row.cell.elemento.validacion.valormetadatoinicial)
                                }else {
                                    row.cell.setEdited(v: row.cell.elemento.validacion.valormetadatoinicial)
                                }
                            }
                            self.hud.dismiss(animated: true)
                        }.catch { error in
                            self.hud.dismiss(animated: true)
                        }
                }
            }else if let row = rows as? TablaRow{
                for rw in row.cell.viewController!.form.allRows{
                    if let cm = rw as? ComboDinamicoRow {
                        ConfigurationManager.shared.utilities.writeLogger("Combo dinámico: \(cm.tag ?? "")", .format)
                        DispatchQueue.main.async {
                            cm.cell.settingValuesSync()
                                .then { response in
                                    if cm.cell.elemento.validacion.valor != ""{
                                        cm.cell.valueOpen = true
                                        cm.cell.setEdited(v: row.cell.elemento.validacion.valormetadatoinicial)
                                    }
                                    self.hud.dismiss(animated: true)
                                }.catch { error in
                                    self.hud.dismiss(animated: true)
                                }
                        }
                    }
                }
            }
        }
    }
    
    public func reloadElementsByAction(_ index: Int){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.configureFooter()
            //self.stopLoading()
        }
    }
    
    public func reloadContEstatico ()
    {   // Init View For Static Content
        if self.getStaticElements().isEmpty{ self.tableViewHeight.constant = 0 }else{
            self.layout()
            self.popupView.addGestureRecognizer(self.panRecognizer)
            self.tableViewHeight.constant = 41
        }
    }
    
    public func setCoordinates(){
        if atributosPlantilla?.pedircoordenadasalcargar ?? false{
            // Cargar las coordenadas en el formato
            if atributosPlantilla?.usarcoordenadas != ""{
                let element = getElementANY(atributosPlantilla?.usarcoordenadas ?? "")
                if(element.element != nil){
                    switch element.type{
                    case "georeferencia":
                        let botonrow: MapaRow = element.kind as! MapaRow
                        botonrow.cell.ruleCoord = true
                        botonrow.cell.btnCallPosicionAction()
                        break
                    default: break
                    }
                }
            }
            self.locationManager.startUpdatingLocation()
            let auxCoord = "\(self.locationManager.location?.coordinate.latitude ?? 0.0),\(self.locationManager.location?.coordinate.longitude ?? 0.0)"
            self.locationManager.stopUpdatingLocation()
            self.valueRuleCoor = auxCoord
        }
    }
    
    // MARK: - Creation of Elements
    func printPagina() -> Form{ return Form() }
    
    func getElementById(_ id: String) -> BaseRow?{
        if self.xmlParsed.elementos == nil{ return nil }
        if self.xmlParsed.elementos?.elemento.count == 0{ return nil }
        for page in (self.xmlParsed.elementos?.elemento)!{
            if page.elementos == nil{ continue }
            if page.elementos?.elemento.count == 0{ continue }
            for elem in (page.elementos?.elemento)!{
                if elem._idelemento == id{
                    let row = self.form.rowBy(tag: "\(id)")
                    return row
                }
            }
        }
        return nil
    }
    
    public func getRowByIdInAllForms(_ id: String) -> (element: TipoElemento, row: BaseRow?){
        for ff in self.forms{
            let row = ff.rowBy(tag: "\(id)")
            if row != nil { return (element: TipoElemento.other, row: nil) }
        }
        return (element: TipoElemento.other, row: nil)
    }
    
    public func getElementByIdInAllForms(_ id: String) -> BaseRow?{
        for ff in self.forms{
            let row = ff.rowBy(tag: "\(id)")
            if row != nil { return row }
        }
        return nil
    }
    
    public func getSectionByIdInCurrentForm(_ id: String) -> Section?{
        return self.form.sectionBy(tag: "\(id)")
    }
    
    public func getElementByIdInCurrentForm(_ id: String) -> BaseRow?{
        return self.form.rowBy(tag: "\(id)")
    }
    
    public func getElementByIdsInAllForms(_ ids: [String]) -> [BaseRow?]{
        var array: [BaseRow?] = []
        for id in ids{
            for ff in self.forms{
                let row = ff.rowBy(tag: "\(id)")
                if row != nil { array.append(row) }
            }
        }
        return array
    }
    
    public func getElementByIdsInCurrentForm(_ ids: [String]) -> [BaseRow?]{
        var array: [BaseRow?] = []
        for id in ids{ array.append(self.form.rowBy(tag: "\(id)")) }
        return array
    }
    
    func validateComponentForm(_ index: Int?, _ element: [BaseRow]?) -> Bool{
        elementsForValidate = [String]()
        validationRowsForm(nil, element)
        if elementsForValidate.count > 0{ return false }else{ return true }
    }
    
    func validateSingleForm(_ index: Int) -> Bool{
        elementsForValidate = [String]()
        validationRowsForm(index, nil)
        if elementsForValidate.count > 0{ return false }else{ return true }
    }
    
    func validateAllForms() -> Bool{
        elementsForValidate = [String]()
        for (index, form) in forms.enumerated(){
            if form.allSections.first?.tag == nil{
                if FormularioUtilities.shared.paginasVisibles[index].visible{
                    validationRowsForm(index, nil)
                }
            }
        }
        if elementsForValidate.count > 0{ return false }else{ return true }
    }
    
    func validationForms(){
        elementsForValidate = [String]()
        for (index, form) in forms.enumerated(){
            if form.allSections.first?.tag == nil{
                if FormularioUtilities.shared.paginasVisibles[index].visible{
                    validationRowsForm(index, nil)
                }
            }
        }
        
        if elementsForValidate.count > 0{
            detectErrorsForm()
        }else{
            //1 Guardado
            //2 Validado
            //0 Del servidor
            self.formatoData.EstadoApp = 2
            self.formatoData.Editado = true
            self.formatoData.NombreEstado = "datavw_card_lblstatus".langlocalized()
            
            self.getTareaSiguientePromise()
                .then{ response in
                    FormularioUtilities.shared.globalFlujo = self.formatoData.TareaSiguiente.FlujoID
                    FormularioUtilities.shared.globalProceso = self.formatoData.TareaSiguiente.ProcesoID
                    self.setValuesToObject(accion: actionForm.publicado)
                }
        }
        
    }
    
    func getTareaSiguientePromise() -> Promise<Bool>{
        
        return Promise<Bool>{ resolve, reject in
            // Transitar Tarea
            var tareaSiguiente: FEEventosFlujo?
            for evento in ConfigurationManager.shared.plantillaDataUIAppDelegate.EventosTareas{
                if evento.TareaID == 1 && evento.EstadoIniId == FormularioUtilities.shared.currentFormato.EstadoID {
                    tareaSiguiente = evento
                }
            }
            if tareaSiguiente != nil{ self.formatoData.TareaSiguiente = tareaSiguiente!; }
            resolve(true)
        }
        
    }
    
    func ressetSettingsNew() -> Promise<Bool>{
        return Promise<Bool>{ resolve, reject in
            allIndex = 1
            formCounter = 0
            currentPage = -1
            pageSelected = 0
            
            plantillamapear = ""
            
            flagAlert = false
            flagLocation = false
            flagEventos = true
            
            self.titlePlantilla.text = ""
            self.subtitlePlantilla.text = ""
            self.pagesScrollView.subviews.forEach({ $0.removeFromSuperview() })
            
            currentPage = -1
            //            formatoData = FEFormatoData()
            isAnexoAdded = false
            isAutoEnable = false
            for ff in self.forms{
                ff.removeAll()
            }
            self.form.removeAll()
            ConfigurationManager.shared.licenciaUIAppDelegate = nil
            FormularioUtilities.shared.currentPlantilla = FEPlantillaData()
            FormularioUtilities.shared.currentAnexos = [FEAnexoData]()
            FormularioUtilities.shared.atributosPaginas = [Atributos_pagina]()
            FormularioUtilities.shared.paginasVisibles = [Atributos_pagina]()
            FormularioUtilities.shared.paginasSegmented = [(pag: Int, position: Int)]()
            FormularioUtilities.shared.rulesAfterWizard = []
            FormularioUtilities.shared.elementsInPlantilla = [(id: String, type: String, kind: Any?, element: Elemento?)]()
            
            elementsForValidate = [String]()
            currentAnexos = [FEAnexoData]()
            anexosLocales = [(elementoid:String, anexo:FEAnexoData)]()
            anexosRemotos = [(elementoid:String, anexo:FEAnexoData)]()
            currentHijos = [Elemento]()
            sectionsDictionary = [String: Form]()
            plaCot = FEPlantillaData()
            formatoCot = FEFormatoData()
            arrayPlantillaData = FEPlantillaData()
            
            formatoData = FEFormatoData()
            formato = FEConsultaFormato()
            currentEstadisticas = [FEEstadistica]()
            historialEstadistico = [FEHistoria]()
            reporteEstadisticas = FEReporteEstadistico()
            arrayOrder = [String]()
            validAnchors = [String]()
            imageCollector = [(id: String, value: String, desc: String)]()
            auxMarcadoDoct = []
            combosPend = [:]
            plaCot = FEPlantillaData()
            formatoCot = FEFormatoData()
            elemNetPay = ""
            self.tableView.reloadData()
            
            resolve(true)
        }
    }
    
    func resettingSettings() -> Promise<Bool>{
        
        return Promise<Bool>{ resolve, reject in
            
            allIndex = 1
            formCounter = 0
            currentPage = -1
            pageSelected = 0
            
            plantillamapear = ""
            
            flagAlert = false
            flagLocation = false
            flagEventos = true
            
            self.titlePlantilla.text = ""
            self.subtitlePlantilla.text = ""
            self.pagesScrollView.subviews.forEach({ $0.removeFromSuperview() })
            
            currentPage = -1
            //            formatoData = FEFormatoData()
            isAnexoAdded = false
            isAutoEnable = false
            //            currentAnexos = [FEAnexoData]()
            //            anexosLocales = [(elementoid:String, anexo:FEAnexoData)]()
            //            anexosRemotos = [(elementoid:String, anexo:FEAnexoData)]()
            //            currentHijos = [Elemento]()
            //            sectionsDictionary = [String: Form]()
            for ff in self.forms{
                ff.removeAll()
            }
            self.form.removeAll()
            
            ConfigurationManager.shared.guid = ConfigurationManager.shared.utilities.guid()
            
            ConfigurationManager.shared.elementosArray = NSMutableDictionary()
            ConfigurationManager.shared.licenciaUIAppDelegate = nil
            ConfigurationManager.shared.openPlantilla = []
            ConfigurationManager.shared.extensionDoc = []
            
            // FormularioUtilities.shared.currentFormato = FEFormatoData()
            FormularioUtilities.shared.currentPlantilla = FEPlantillaData()
            FormularioUtilities.shared.currentAnexos = [FEAnexoData]()
            FormularioUtilities.shared.atributosPaginas = [Atributos_pagina]()
            FormularioUtilities.shared.paginasVisibles = [Atributos_pagina]()
            FormularioUtilities.shared.paginasSegmented = [(pag: Int, position: Int)]()
            FormularioUtilities.shared.rules = nil
            FormularioUtilities.shared.services = nil
            FormularioUtilities.shared.components = nil
            FormularioUtilities.shared.mathematics = nil
            //FormularioUtilities.shared.prefilleddata = nil
            FormularioUtilities.shared.rulesAfterWizard = []
            FormularioUtilities.shared.elementsInPlantilla = [(id: String, type: String, kind: Any?, element: Elemento?)]()
            
            self.tableView.reloadData()
            
            elemtVDDocument = nil
            completionBlockLocalBiometric = nil
            
            formActions = nil
            sdkAPI = nil
            navigation = nil
            elementsForValidate = [String]()
            ElementosArray = NSMutableDictionary()
            valuesArray = nil
            filtrosArray = nil
            imageCollector = [(id: String, value: String, desc: String)]()
            
            arrayPlantillaData = FEPlantillaData()
            xmlParsed = Elemento()
            xmlAEXML = AEXMLDocument()
            formatoData = FEFormatoData()
            formato = FEConsultaFormato()
            feOpenPlantilla = []
            currentEstadisticas = [FEEstadistica]()
            historialEstadistico = [FEHistoria]()
            reporteEstadisticas = FEReporteEstadistico()
            arrayOrder = [String]()
            validAnchors = [String]()
            elemNetPay = ""
            
            currentAnexos = [FEAnexoData]()
            anexosLocales = [(elementoid:String, anexo:FEAnexoData)]()
            anexosRemotos = [(elementoid:String, anexo:FEAnexoData)]()
            currentHijos = [Elemento]()
            sectionsDictionary = [String: Form]()
            
            footerViewController = nil
            viewControllerR = nil
            plaCot = FEPlantillaData()
            formatoCot = FEFormatoData()
            //            openPlantilla = FEOpenPlantilla()
            
            atributosPlantilla = nil
            saveTimer = nil
            
            templateDelegate = nil
            negoPermisos = 0
            
            wrdNavigation = nil
            
            rulesOnProperties = []
            auxMarcadoDoct = []
            combosPend = [:]
            resolve(true)
            
        }
        
        
    }
    
    func getJSonDatosValues() -> String{
        var theJsonText = ""
        
        self.getJsonDatosValuesLoop(xmlParsed)
        
        if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: ElementosArray, options: .sortedKeys){ theJsonText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)! }
        return theJsonText
    }
    // MARK: - Looping All Elements Document - METAAttributes
    func getJsonDatosValuesLoop(_ elem: Elemento){
        
        if elem.elementos == nil{ return }
        if elem.elementos?.elemento == nil, elem.elementos?.elemento.count == 0 { return }
        for element in elem.elementos!.elemento{
            // Looping
            if element.elementos?.elemento.count ?? 0 > 0 {
                if element._tipoelemento != "tabla" {
                    loopElements(element)
                }
            }else{
                if element._tipoelemento != "tabla" || element._tipoelemento != "plantilla" {
                    self.detectValue(elem: element, isPrellenado: false)
                }
            }
        }
        
    }
    
    func setValuesToNewForm(){
        
        // Resetting Settings
        resettingSettings().then { response in
            
            self.ElementosArray = NSMutableDictionary()
            var theJsonText = String()
            
            if self.xmlParsed.elementos?.elemento.count ?? 0 > 0{
                for pagina in (self.xmlParsed.elementos?.elemento)!{
                    if pagina._tipoelemento == "pagina"{
                        if pagina.elementos?.elemento.count == 0{ continue }
                        for elem in (pagina.elementos?.elemento)!{
                            self.detectValue(elem: elem, isPrellenado: true)
                        }
                    }
                }
            }
            
            if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: self.ElementosArray, options: .sortedKeys){
                theJsonText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
            }
            
            
            let file = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/\(self.plantillamapear).pla")
            let plantilla = FEPlantillaData(json: file)
            FormularioUtilities.shared.currentFormato = FEFormatoData()
            FormularioUtilities.shared.currentFormato.JsonDatos = theJsonText
            self.index = 0
            self.flujo = plantilla.FlujoID
            self.proceso = 0
            self.arrayPlantillaData = plantilla
            
            self.getValuesJson()
            
            self.showLoading()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.initForm()
            }
        }
        
    }
    
    func setValuesToNewForm(_ plantilla: String, _ atributosWizard: Atributos_wizard){
        
        // Resetting Settings
        resettingSettings().then { response in
            
            var theJsonText = String()
            let newElementosArray: NSMutableDictionary = NSMutableDictionary()
            let mapValues = atributosWizard.prefilleddata["mapeo"] as? [String: String]
            
            if mapValues != nil
            {
                if self.ElementosArray.count > 0{
                    for elem in self.ElementosArray{
                        for mapObj in mapValues!{
                            if mapObj.key == elem.key as? String {
                                newElementosArray.setValue(elem.value, forKey: "\(mapObj.value)")
                            }
                        }
                    }
                }
                
                if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: newElementosArray, options: .sortedKeys){
                    theJsonText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
                }
                self.getValuesJson(theJsonText)
            }
            
            let files = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/", deep: true)
            
            var readFile = ""
            for file in files!{ if (file as! String).contains("/\(plantilla).pla"){ readFile = file as! String; break; } }
            let contentFile = ConfigurationManager.shared.utilities.read(asString: readFile)
            let plantilla = FEPlantillaData(json: contentFile)
            FormularioUtilities.shared.currentFormato = FEFormatoData()
            FormularioUtilities.shared.currentFormato.JsonDatos = theJsonText
            
            FormularioUtilities.shared.currentFormato.FlujoID = plantilla.FlujoID
            FormularioUtilities.shared.currentFormato.ExpID = plantilla.ExpID
            FormularioUtilities.shared.currentFormato.TipoDocID = plantilla.TipoDocID
            
            self.index = 0
            self.flujo = plantilla.FlujoID
            self.proceso = 0
            self.arrayPlantillaData = plantilla
            
            
            self.showLoading()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.initForm()
            }
        }
    }
    
    // MARK: - Looping All Elements Document - METAAttributes
    func loopElements(_ elem: Elemento){
        
        if elem.elementos == nil{ return }
        if elem.elementos?.elemento == nil, elem.elementos?.elemento.count == 0 { return }
        for element in elem.elementos!.elemento{
            // Looping
            if element.elementos?.elemento.count ?? 0 > 0 {
                if element._tipoelemento == "tabla" {
                    self.setMetaAttributes(element, false)
                }else{
                    loopElements(element)
                }
            }else{
                if element.estadisticas != nil{
                    self.currentEstadisticas.append(element.estadisticas!)
                    
                }
                if element.estadisticas2 != nil{
                    self.currentEstadisticas2.append(element.estadisticas2!)
                }
                if element._tipoelemento == "tabla" || element._tipoelemento == "plantilla" {
                    self.setMetaAttributes(element, false)
                }else{
                    self.detectValue(elem: element, isPrellenado: false)
                }
            }
        }
        
    }
    
    // MARK: - Saving Format
    func setValuesToObjectTabla(_ openAtEnd: Bool = false, _ atributosWizard: Atributos_wizard? = nil){
        
        self.saveTimer?.invalidate()
        showLoading()
        
        // Init FEFormatoData
        self.currentEstadisticas = [FEEstadistica]()
        self.reporteEstadisticas = FEReporteEstadistico()
        
        
        self.ElementosArray = NSMutableDictionary()
        var theJsonText = String()
        var objectResumen: [(id: String, valor: String, orden: Int)] = [(id: String, valor: String, orden: Int)]()
        var resumen: [(id: Int, valor: String)] = []
        
        if(xmlParsed._tipoelemento == "plantilla"){
            self.setMetaAttributes(xmlParsed, false)
        }
        
        if plist.idportal.rawValue.dataI() >= 40{
            // New Resumen
            if objectResumen.count == 0{
                objectResumen = self.newResumen(xmlAEXML.root, objectResumen) ?? [(id: String, valor: String, orden: Int)]()
            }
        }else if plist.idportal.rawValue.dataI() <= 39{
            // Old Resumen
            objectResumen = (self.sdkAPI?.loopResumen(xmlAEXML.root, objectResumen))!
        }else{}
        
        self.setMetaAttributes(xmlParsed, false)
        self.loopElements(xmlParsed)
        
        // Add ids pdfmapping On
        if arrayArchivesOn.count > 0{
            let archivosIDsOn: NSMutableDictionary = NSMutableDictionary(); archivosIDsOn.setValue(arrayArchivesOn, forKey: "k")
            self.ElementosArray.setValue(archivosIDsOn, forKey: "mappingfiles")
        }
        
        if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: ElementosArray, options: .sortedKeys){
            theJsonText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
            theJsonText = theJsonText.replacingOccurrences(of: "\\\\\\\"", with: "\\\"")
        }
        let customJson = theJsonText
        
        if objectResumen.count > 0{
            
            do{
                let dict = try JSONSerializer.toDictionary(customJson)
                
                for equal in objectResumen{
                    var isAlreadySet = false
                    for dato in dict{
                        if isAlreadySet{ continue }
                        let dictValor = dato.value as! NSMutableDictionary
                        let valor = dictValor.value(forKey: "valor") as? String ?? ""
                        
                        if dato.key as! String == equal.id{
                            // We need to detect the real value only Text and not number only if ther is no way
                            let isList = getElementANY(equal.id)
                            let list = isList.kind as? ListaRow
                            if list != nil{
                                resumen.append((id: Int(equal.orden), valor: list?.cell.getTxtInput() ?? ""))
                                isAlreadySet = true
                                continue
                            }else{
                                resumen.append((id: Int(equal.orden), valor: valor))
                                isAlreadySet = true
                                continue
                            }
                        }else{
                            // Detecting values in Table element
                            if valor == ""{ continue }
                            if !valor.contains("{"){ continue }
                            do{
                                let arrayDictionary = try JSONSerializer.toArray(valor)
                                for keyArray in arrayDictionary{
                                    let dictArray = keyArray as! NSMutableDictionary
                                    
                                    for dict in dictArray{
                                        if dict.key as! String == equal.id{
                                            let dictValor = dict.value as! NSMutableDictionary
                                            let vv = dictValor.value(forKey: "valor") as? String ?? ""
                                            resumen.append((id: Int(equal.orden), valor: vv))
                                            isAlreadySet = true
                                        }
                                    }
                                }
                                continue
                            }catch{ }
                        }
                    }
                }
            }catch{ }
        }
        
        resumen.sort(by: { $0.id < $1.id })
        formatoData.Resumen = ""
        for r in resumen{
            if r.valor != ""{
                formatoData.Resumen += "\(r.valor)||"
            }
        }
        let fechaTermino = Date.getTicks()
        self.reporteEstadisticas.FechaComienzo = self.fechaInicial
        self.reporteEstadisticas.FechaTermino = fechaTermino
        self.reporteEstadisticas.Plataforma = "iOS"
        self.reporteEstadisticas.VersiónPlantilla = self.xmlParsed._version
        self.reporteEstadisticas.FechaPlantilla = self.xmlParsed._fechaguardadoplantilla
        self.reporteEstadisticas.Resultado = ""
        self.reporteEstadisticas.DocId = 0
        self.reporteEstadisticas.Usuario = ""
        self.reporteEstadisticas.Estadisticas = self.currentEstadisticas2
        self.reporteEstadisticas.Historia = self.historialEstadistico
        
        if FormularioUtilities.shared.currentFormato.DocID != 0{
            formatoData.DocID = FormularioUtilities.shared.currentFormato.DocID
            formatoData.ExpID = FormularioUtilities.shared.currentFormato.ExpID
            formatoData.NombreExpediente = FormularioUtilities.shared.currentFormato.NombreExpediente
            formatoData.TipoDocID = FormularioUtilities.shared.currentFormato.TipoDocID
            formatoData.NombreTipoDoc = FormularioUtilities.shared.currentFormato.NombreTipoDoc
            formatoData.FlujoID = FormularioUtilities.shared.currentFormato.FlujoID
            formatoData.InstanciaId = FormularioUtilities.shared.currentFormato.InstanciaId
            formatoData.PIID = FormularioUtilities.shared.currentFormato.PIID
        }else{
            formatoData.DocID = 0
            formatoData.ExpID = ConfigurationManager.shared.plantillaDataUIAppDelegate.ExpID
            formatoData.NombreExpediente = ConfigurationManager.shared.plantillaDataUIAppDelegate.NombreExpediente
            formatoData.TipoDocID = ConfigurationManager.shared.plantillaDataUIAppDelegate.TipoDocID
            formatoData.NombreTipoDoc = ConfigurationManager.shared.plantillaDataUIAppDelegate.NombreTipoDoc
            formatoData.FlujoID = flujo
        }
        formatoData.Guid = ConfigurationManager.shared.guid
        formatoData.Anexos = currentAnexos
        formatoData.ProcesoID = proceso
        formatoData.JsonDatos = ""
        if self.atributosPlantilla?.permisoestadisticas ?? true{
            formatoData.Estadisticas = currentEstadisticas
            formatoData.Reporte = self.reporteEstadisticas
        }else{
            formatoData.Estadisticas = [FEEstadistica]()
        }
        
        self.sdkAPI?.salvarPlantillaDataAndJson(formato: formatoData, json: theJsonText)
        
        ConfigurationManager.shared.hasNewFormat = true
        
        if atributosWizard?.plantillaabrir ?? "" != ""{
            
            if FormularioUtilities.shared.prefilleddata != nil{
                self.setPrefilledDataToNewForm(atributosWizard!.plantillaabrir)
            }else{
                self.setValuesToNewForm(atributosWizard!.plantillaabrir, atributosWizard!)
            }
            
        }else{
            if flagLocation{
                NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
                self.negoPermisos = 0
                self.checkLocationPermission()
            }
            self.hud.dismiss(animated: true)
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    enum actionForm: Int{
        case cancelar = 400
        case borrador = 300
        case publicado = 200
        case autoguardado = 100
    }
    
    func setValuesToObject(_ openAtEnd: Bool = false, _ atributosWizard: Atributos_wizard? = nil, accion action: actionForm){
        
        self.saveTimer?.invalidate()
        
        if !(self.flagSave ?? false){
            showLoading()
        }
        
        self.currentEstadisticas = [FEEstadistica]()
        self.reporteEstadisticas = FEReporteEstadistico()
        self.ElementosArray = NSMutableDictionary()
        var theJsonText = String()
        var objectResumen: [(id: String, valor: String, orden: Int)] = [(id: String, valor: String, orden: Int)]()
        var resumen: [(id: Int, valor: String)] = []
        var resumenV2TMP: FEResumenDos = FEResumenDos()
        
        if plist.idportal.rawValue.dataI() >= 43 { //New ResumenV2
            // New Resumen
            resumenV2TMP = self.newResumen2(xmlAEXML.root) ?? FEResumenDos()
            if objectResumen.count == 0{
                objectResumen = self.newResumen(xmlAEXML.root, objectResumen) ?? [(id: String, valor: String, orden: Int)]()
            }
        } else if plist.idportal.rawValue.dataI() >= 43 { // ResumenV1
            if objectResumen.count == 0{
                objectResumen = self.newResumen(xmlAEXML.root, objectResumen) ?? [(id: String, valor: String, orden: Int)]()
            }
        } else if plist.idportal.rawValue.dataI() <= 39{ // Old Resumen
            objectResumen = (self.sdkAPI?.loopResumen(xmlAEXML.root, objectResumen))!
        } else {}
        
        //Asigna los valores a self.ElementosArray:
        self.setMetaAttributes(xmlParsed, false)
        
        self.loopElements(xmlParsed)
        
        if arrayArchivesOn.count > 0 {
            let archivosIDsOn: NSMutableDictionary = NSMutableDictionary(); archivosIDsOn.setValue(arrayArchivesOn, forKey: "k")
            self.ElementosArray.setValue(archivosIDsOn, forKey: "mappingfiles")
        }
        
        if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: ElementosArray, options: .sortedKeys) {
            theJsonText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
            theJsonText = theJsonText.replacingOccurrences(of: "\\\\\\\"", with: "\\\"")
        }
        
        let dict = try! JSONSerializer.toDictionary(theJsonText)
        if !resumenV2TMP.texto.isEmpty || !resumenV2TMP.imagen.isEmpty || !resumenV2TMP.tabla.isEmpty {
            
            let resumenV2ToReturn: FEResumenDos = FEResumenDos()
            //Parseo de texto:
            for texto in resumenV2TMP.texto {
                for datoIngresado in dict {
                    if let diccionario = datoIngresado.value as? NSMutableDictionary {
                        let valor = diccionario.value(forKey: "valor") as? String ?? ""
                        //El nombre del elemento xml ejemplo: formElec_element5 vienen en el campo de valor
                        //Verificamos la llave del diccionario con el valor de nuestro resumen y remplazamos.
                        //OJO: No remplazamos el orden, lo reasignamos:
                        if datoIngresado.key as! String == texto.valor {
                            let textotmp = FETextoResumen()
                            textotmp.valor = valor
                            textotmp.orden = texto.orden
                            resumenV2ToReturn.texto.append(textotmp)
                        }
                    }
                }
            }
            //Parseo de imagen:
            for imagenv2 in resumenV2TMP.imagen {
                for datoIngresado in dict {
                    if let _ = datoIngresado.value as? NSMutableDictionary {
                        //Misma logica que texto:
                        if datoIngresado.key as! String == imagenv2.valor {
                            //Sabemos que es una imagen, podemos forzar el parseo:
                            //getElementANY ocupa el nombre del elemento XML ejemplo: formElec_element12
                            let row = getElementANY(imagenv2.valor)
                            if let imagenRow = row.kind as? ImagenRow {
                                
                                guard imagenRow.value != nil else { break }
                                
                                let exists =  FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(imagenRow.value ?? "")")
                                
                                let imagenTMP = FEImagenResumen()
                                
                                if exists {
                                    let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(imagenRow.value ?? "")")
                                    let anexoBase64 = fileData?.base64EncodedString(options: [])
                                    
                                    imagenTMP.orden = imagenv2.orden
                                    imagenTMP.valor = anexoBase64 ?? ""
                                    
                                    resumenV2ToReturn.imagen.append(imagenTMP)
                                } else if formatoData.Editado {
                                    //Logica de remplazo:
                                    for img in formatoData.ResumenV2.imagen { //Aqui ya estan las imagenes guardadas:
                                        //En formatoV2ToReturn solo tendremos las nuevas, entonces agregar las que faltan
                                        for imagen in resumenV2ToReturn.imagen {
                                            if img.orden != imagen.orden { //Si no es el mismo orden, no existe
                                                resumenV2ToReturn.imagen.append(img)
                                            }
                                        }
                                    }
                                }
                            } else if let documentoRow = row.kind as? DocumentoRow {
                                guard documentoRow.value != nil else { break }
                                guard documentoRow.cell.anexosDict.count > 0 else { break }
                                
                                //Todos los anexos y verificar cuales son de tipo imagen: jpg, png, jpeg
                                for anexo in documentoRow.cell.anexosDict {
                                    let exists = FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.url)")
                                    let imagenTMP = FEImagenResumen()
                                    
                                    for documento in documentoRow.cell.fedocumentos {
                                        let extDoc = documento.Ext.replacingOccurrences(of: ".", with: "").lowercased()
                                        if documento.URL == anexo.url && ( extDoc == "png" || extDoc == "jpg" || extDoc == "jpeg") {
                                            if exists { //Agregamos a imagen:
                                                let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(anexo.url)")
                                                let anexoBase64 = fileData?.base64EncodedString(options: [])
                                                
                                                imagenTMP.orden = imagenv2.orden
                                                imagenTMP.valor = anexoBase64 ?? ""
                                                
                                                resumenV2ToReturn.imagen.append(imagenTMP)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //Parseo de tabla:
            for table in resumenV2TMP.tabla {
                let tabla = FETablaResumen()
                var orden:Int = 0
                for datoIngresado in dict {
                    if datoIngresado.key as! String == table.valor {
                        if let diccionario = datoIngresado.value as? NSMutableDictionary {
                            let json = diccionario.value(forKey: "valor") as? String ?? ""
                            if let dictTabla = try? JSONSerializer.toArray(json) {
                                for registro in dictTabla {
                                    //Registro = Fila
                                    tabla.orden = String(orden)
                                    let fila = FETablaFilas()
                                    if let rg = registro as? NSDictionary {
                                        for rgg in rg {
                                            let valorTMP = FETablaValores()
                                            if let rggDict = rgg.value as? NSDictionary {
                                                //Tenemos el valor.
                                                if let valor = rggDict.value(forKey: "valor") as? String {
                                                    valorTMP.valor = valor
                                                    //rgg.key = formElec_element73
                                                    let elemento = getElementANY(rgg.key as! String)
                                                    valorTMP.columna = self.getTitleByRow(elemento.kind as! BaseRow)
                                                    
                                                    //El orden ya viene en resumenV2TMP, extraerlo:
                                                    for tabla in resumenV2TMP.tabla {
                                                        for fila in tabla.filas {
                                                            for valores in fila.valores {
                                                                if valores.columna == rgg.key as! String {
                                                                    valorTMP.orden = valores.orden
                                                                    break
                                                                }
                                                            }
                                                        }
                                                    }
                                                    if valorTMP.orden != "" {
                                                        fila.valores.append(valorTMP)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    tabla.filas.append(fila)
                                }
                            }
                        }
                    }
                    orden = orden + 1
                }
                //Si no hay filas, no agregamos nada a la tabla:
                if tabla.filas.count > 0 {
                    resumenV2ToReturn.tabla.append(tabla)
                }
            }
            
            formatoData.ResumenV2 = resumenV2ToReturn
        }
        
        //Logica de Resumen V1
        if objectResumen.count > 0 {
            for equal in objectResumen {
                var isAlreadySet = false
                for dato in dict {
                    if isAlreadySet{ continue }
                    let dictValor = dato.value as! NSMutableDictionary
                    let valor = dictValor.value(forKey: "valor") as? String ?? ""
                    
                    if dato.key as! String == equal.id {
                        // We need to detect the real value only Text and not number only if ther is no way
                        let row = getElementANY(equal.id)
                        let list = row.kind as? ListaRow
                        let title = self.getTitleByRow(row.kind as! BaseRow)
                        if list != nil {
                            resumen.append((id: Int(equal.orden), valor: "\(title): \(list?.cell.getTxtInput() ?? "")"))
                            isAlreadySet = true
                            continue
                        } else {
                            resumen.append((id: Int(equal.orden), valor: "\(title): \(valor)"))
                            isAlreadySet = true
                            continue
                        }
                    }else{
                        // Detecting values in Table element
                        if valor == "" { continue }
                        if !valor.contains("{") { continue }
                        do{
                            let arrayDictionary = try JSONSerializer.toArray(valor)
                            for keyArray in arrayDictionary {
                                let dictArray = keyArray as! NSMutableDictionary
                                
                                for dict in dictArray{
                                    if dict.key as! String == equal.id {
                                        let dictValor = dict.value as! NSMutableDictionary
                                        let vv = dictValor.value(forKey: "valor") as? String ?? ""
                                        resumen.append((id: Int(equal.orden), valor: vv))
                                        isAlreadySet = true
                                    }
                                }
                            }
                            continue
                        }catch{ }
                    }
                }
            }
            
            //Write to object:
            resumen.sort(by: { $0.id < $1.id })
            formatoData.Resumen = ""
            for r in resumen{
                if r.valor != ""{
                    formatoData.Resumen += "\(r.valor)||"
                }
            }
        }
        // using current date and time as an example
        let fechaTermino = Date.getTicks()
        self.reporteEstadisticas.FechaComienzo = self.fechaInicial
        self.reporteEstadisticas.FechaTermino = fechaTermino
        self.reporteEstadisticas.Plataforma = "iOS"
        self.reporteEstadisticas.VersiónPlantilla = self.xmlParsed._version
        self.reporteEstadisticas.FechaPlantilla = self.xmlParsed._fechaguardadoplantilla
        self.reporteEstadisticas.Resultado = ""
        self.reporteEstadisticas.DocId = 0
        self.reporteEstadisticas.Usuario = ""
        self.reporteEstadisticas.Estadisticas = self.currentEstadisticas2
        self.reporteEstadisticas.Historia = self.historialEstadistico
        
        if FormularioUtilities.shared.currentFormato.DocID != 0{
            formatoData.DocID = FormularioUtilities.shared.currentFormato.DocID
            formatoData.ExpID = FormularioUtilities.shared.currentFormato.ExpID
            formatoData.NombreExpediente = FormularioUtilities.shared.currentFormato.NombreExpediente
            formatoData.TipoDocID = FormularioUtilities.shared.currentFormato.TipoDocID
            formatoData.NombreTipoDoc = FormularioUtilities.shared.currentFormato.NombreTipoDoc
            formatoData.FlujoID = FormularioUtilities.shared.currentFormato.FlujoID
            formatoData.InstanciaId = FormularioUtilities.shared.currentFormato.InstanciaId
            formatoData.PIID = FormularioUtilities.shared.currentFormato.PIID
        }else{
            formatoData.DocID = 0
            formatoData.ExpID = ConfigurationManager.shared.plantillaDataUIAppDelegate.ExpID
            formatoData.NombreExpediente = ConfigurationManager.shared.plantillaDataUIAppDelegate.NombreExpediente
            formatoData.TipoDocID = ConfigurationManager.shared.plantillaDataUIAppDelegate.TipoDocID
            formatoData.NombreTipoDoc = ConfigurationManager.shared.plantillaDataUIAppDelegate.NombreTipoDoc
            formatoData.FlujoID = flujo
        }
        formatoData.Guid = ConfigurationManager.shared.guid
        formatoData.Anexos = currentAnexos
        formatoData.ProcesoID = proceso
        formatoData.JsonDatos = ""
        if self.atributosPlantilla?.permisoestadisticas ?? true{
            formatoData.Estadisticas = currentEstadisticas
            formatoData.Reporte = self.reporteEstadisticas
        }else{
            formatoData.Estadisticas = [FEEstadistica]()
            formatoData.Reporte = FEReporteEstadistico()
        }
        self.sdkAPI?.salvarPlantillaDataAndJson(formato: formatoData, json: theJsonText)
        
        ConfigurationManager.shared.hasNewFormat = true
        if atributosWizard?.plantillaabrir ?? "" != ""{
            // Prellenado
            // AfterFinish is only used with prefill
            // self.triggerRulesOnChange("afterfinish")
            if FormularioUtilities.shared.prefilleddata != nil{
                // Lógica para regresar a un formato de cotización desde un biometrico EConsubanco
                if ConfigurationManager.shared.isConsubanco{
                    self.formatoFlag = true
                    //self.plaCot = arrayPlantillaData
                    plaCot.TipoDocID = self.openPlantilla.TipoDocID
                    plaCot.ExpID = self.openPlantilla.ExoID
                    plaCot.FlujoID = self.openPlantilla.FlujoID
                    
                    let folders = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/", deep: true)
                    
                    for files in folders!{
                        let fileString = files as! String
                        if fileString.contains(".bor"){
                            let gettingXml = ConfigurationManager.shared.utilities.read(asString: fileString)
                            let formato = FEFormatoData(json: gettingXml)
                            if formatoData.Guid == formato.Guid{
                                let fileJson = fileString.replacingOccurrences(of: ".bor", with: ".json")
                                let contentJson = ConfigurationManager.shared.utilities.read(asString: fileJson)
                                formatoData.JsonDatos = contentJson!
                            }
                        }
                    }
                    self.formatoCot = formatoData
                }
                self.setPrefilledDataNew(atributosWizard!.plantillaabrir)
                
                
            }else{
                self.setValuesToNewForm(atributosWizard!.plantillaabrir, atributosWizard!)
            }
        }else{
            // Home
            if flagLocation{
                NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
                self.negoPermisos = 0
                self.checkLocationPermission()
            }
            
            if ConfigurationManager.shared.isConsubanco && self.flagCalculadora{
                hud.dismiss(animated: true)
                if !self.flagAlert{
                    self.sendToServerEC()
                }
            }else if atributosWizard?.publicarautomatico ?? false{
                hud.dismiss(animated: true)
                if !self.flagAlert{
                    self.sendToServer()
                }
            }else{
                
                // Loop plantillas actuales
                // Plantilla actual in FEOpenPlantilla
                // true == removePlantilla indice
                
                // Mensaje de alerta
                // Actualmente tienes plantillas abiertas, ¿Quieres seguir con alguna?
                // Alert sheet plantillas
                
                self.hud.dismiss(animated: true)
                if action.rawValue != 100{
                    if !self.isBorradorSNSalir{
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1200)) {
                            self.closeViewController(status: action.rawValue)
                        }
                    }
                }
            }
        }
        
    }
    
    // MARK: - New Resume
    /// Method to retrive information from format
    /// - Parameters:
    ///   - root: xml format
    ///   - object: object with data
    func newResumen(_ root: AEXMLElement, _ object: [(id: String, valor: String, orden: Int)]) -> [(id: String, valor: String, orden: Int)]?{
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "newResumen"), .info)
        var objectResumen: [(id: String, valor: String, orden: Int)] = [(id: String, valor: String, orden: Int)]()
        if root["atributos"].error != nil{ return nil }
        if root["atributos"]["resumen"].error != nil{ return nil }
        for (index, elementos) in (root["atributos"]["resumen"].children.enumerated()){
            objectResumen.append((id: elementos.name, valor: "", orden: index))
        }
        return objectResumen
    }
    
    func newResumen2(_ root: AEXMLElement) -> FEResumenDos? {
        ConfigurationManager.shared.utilities.writeLogger(String(format: "apimng_log_init".langlocalized(), "newResumen"), .info)
        let resumen: FEResumenDos = FEResumenDos()
        if root["atributos"].error != nil && root["atributos"]["resumen"].error != nil{ return nil }
        for (_, elemento) in root["atributos"]["resumen2"].children.enumerated() {
            if elemento.name == "texto" {
                for (_, childElement) in elemento.children.enumerated() {
                    let texto: FETextoResumen = FETextoResumen()
                    texto.valor = childElement.name
                    texto.orden = childElement.value ?? ""
                    resumen.texto.append(texto)
                }
            } else if elemento.name == "imagen" {
                for (_, childElement) in elemento.children.enumerated() {
                    let imagen: FEImagenResumen = FEImagenResumen()
                    imagen.valor = childElement.name
                    imagen.orden = childElement.value ?? ""
                    resumen.imagen.append(imagen)
                }
            } else if elemento.name == "tabla" {
                for table in elemento.children {
                    let tabla: FETablaResumen = FETablaResumen()
                    tabla.valor = table.name
                    tabla.orden = table.value ?? ""
                    let filas: FETablaFilas = FETablaFilas()
                    for (_,children) in table.children.enumerated() {
                        let valores = FETablaValores()
                        valores.valor = ""
                        valores.orden = children.value ?? ""
                        valores.columna = children.name
                        filas.valores.append(valores)
                    }
                    tabla.filas.append(filas)
                    resumen.tabla.append(tabla)
                }
            } else {
                print("No children elements")
                break
            }
        }
        return resumen
    }
    
    
    public func initNavigation(){
        wrdNavigation = nil
        for rows in forms[currentPage].allRows{
            switch rows{
            case is WizardRow: wrdNavigation = (rows as? WizardRow)
            default: break;
            }
        }
        if wrdNavigation != nil{
            self.navigationView.isHidden = false
            wrdNavigation?.cell.setVariableHeight(Height: 0)
            self.settingNavigationButtons(atributos: (wrdNavigation?.cell.atributos)!)
            for constraint in self.view.constraints {
                if constraint.identifier == "tableHeight" {
                    constraint.constant = 0
                }
            }
        }else{
            self.navigationView.isHidden = true
            for constraint in self.view.constraints {
                if constraint.identifier == "tableHeight" {
                    constraint.constant = 40
                }
            }
        }
    }
    public func settingNavigationButtons(atributos: Atributos_wizard){
        
        self.leftNavigation.layer.cornerRadius = 5.0
        self.rightNavigation.layer.cornerRadius = 5.0
        
        self.leftNavigation.tag = 1
        self.rightNavigation.tag = 2
        
        self.leftNavigation.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        self.rightNavigation.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        
        self.leftNavigation.setTitle(atributos.textoregresar, for: .normal)
        self.rightNavigation.setTitle(atributos.textoavanzar, for: .normal)
        
        self.leftNavigation.backgroundColor = UIColor(hexFromString: atributos.colorfondoregresar)
        self.leftNavigation.setTitleColor(UIColor(hexFromString: atributos.colortextoregresar), for: .normal)
        
        self.rightNavigation.backgroundColor = UIColor(hexFromString: atributos.colorfondoavanzar)
        self.rightNavigation.setTitleColor(UIColor(hexFromString: atributos.colortextoavanzar), for: .normal)
        
        self.leftNavigation.addTarget(self, action: #selector(setNavigationAction(_:)), for: .touchDown)
        self.rightNavigation.addTarget(self, action: #selector(setNavigationAction(_:)), for: .touchDown)
        
    }
    @objc func setNavigationAction(_ sender: UIButton){
        if sender.tag == 1{
            if wrdNavigation?.cell.atributos?.paginaregresar ?? "" != ""{
                wrdNavigation?.cell.regresarBtnAction(sender)
            }
        }else if sender.tag == 2{
            if wrdNavigation?.cell.atributos?.paginaavanzar ?? "" != ""{
                wrdNavigation?.cell.avanzarBtnAction(sender)
            }else if wrdNavigation?.cell.atributos?.tareafinalizar ?? "" != ""{
                wrdNavigation?.cell.finalizarBtnAction(sender)
            }
        }
    }
    
    // MARK: Static Content ViewController
    private var bottomConstraint = NSLayoutConstraint()
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        return view
    }()
    private lazy var closedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "nvapla_static".langlocalized()
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = Cnstnt.Color.blue
        label.textAlignment = .center
        return label
    }()
    private lazy var openTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "nvapla_static".langlocalized()
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.heavy)
        label.textColor = .black
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
        return label
    }()
    private lazy var viewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.alpha = 1
        
        return view
    }()
    private var currentState: StateContent = .closed
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    private func layout() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 480).isActive = true
        
        closedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(closedTitleLabel)
        closedTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        closedTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        closedTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 10).isActive = true
        
        openTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(openTitleLabel)
        openTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        openTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        openTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20).isActive = true
        
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewContainer)
        viewContainer.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        viewContainer.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        viewContainer.bottomAnchor.constraint(equalTo: popupView.bottomAnchor).isActive = true
        viewContainer.heightAnchor.constraint(equalToConstant: 425).isActive = true
    }
    
    // MARK: - Animation Static ViewController
    private func animateTransitionIfNeeded(to state: StateContent, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = 20
                self.overlayView.alpha = 0.5
                self.closedTitleLabel.transform = CGAffineTransform(scaleX: 1.6, y: 1.6).concatenating(CGAffineTransform(translationX: 0, y: 15))
                self.openTitleLabel.transform = .identity
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
                self.popupView.layer.cornerRadius = 0
                self.overlayView.alpha = 0
                self.closedTitleLabel.transform = .identity
                self.openTitleLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
            }
            self.view.layoutIfNeeded()
        })
        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            @unknown default:
                fatalError()
            }
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
            }
            self.runningAnimators.removeAll()
        }
        
        let inTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
            switch state {
            case .open:
                self.openTitleLabel.alpha = 1
            case .closed:
                self.closedTitleLabel.alpha = 1
            }
        })
        inTitleAnimator.scrubsLinearly = false
        let outTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: {
            switch state {
            case .open:
                self.closedTitleLabel.alpha = 0
            case .closed:
                self.openTitleLabel.alpha = 0
            }
        })
        outTitleAnimator.scrubsLinearly = false
        transitionAnimator.startAnimation()
        inTitleAnimator.startAnimation()
        outTitleAnimator.startAnimation()
        
        runningAnimators.append(transitionAnimator)
        runningAnimators.append(inTitleAnimator)
        runningAnimators.append(outTitleAnimator)
    }
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
            runningAnimators.forEach { $0.pauseAnimation() }
            animationProgress = runningAnimators.map { $0.fractionComplete }
            staticVC.estaticos = getStaticElements()
            staticVC.controller = self
            self.addChild(staticVC)
            staticVC.view.frame = self.view.bounds
            self.viewContainer.addSubview(staticVC.view)
            staticVC.didMove(toParent: self)
            staticVC.tblView.reloadData()
        case .changed:
            let translation = recognizer.translation(in: popupView)
            var fraction = -translation.y / popupOffset
            if currentState == .open { fraction *= -1 }
            if runningAnimators[0].isReversed { fraction *= -1 }
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
        case .ended:
            let yVelocity = recognizer.velocity(in: popupView).y
            let shouldClose = yVelocity > 0
            if yVelocity == 0 {
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
            }
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            }
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        default:
            ()
        }
    }
    
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        refreshConstraintsOrLayout()
    }
    
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool { return true }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { return .none }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        locationManager.stopUpdatingLocation()
        ConfigurationManager.shared.longitud = "\(locValue.longitude)"
        ConfigurationManager.shared.latitud = "\(locValue.latitude)"
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizer.State.began
    }
}

// MARK: - Init Form
extension NuevaPlantillaViewController: APIDelegate{
    
    func loopSearchFormula(_ root: AEXMLElement, _ id: String, _ tipo: String) -> String?
    {
        if root["elementos"].all?.count == 0 { return nil }
        if root["elementos"].error != nil{ return nil }
        if root["elementos"]["elemento"].all?.count == 0 { return nil}
        if root["elementos"]["elemento"].error != nil{ return nil }
        for paginas in (xmlAEXML.root["elementos"]["elemento"].all)!
        {
            for elementos in (paginas["elementos"]["elemento"].all)!
            {
                if elementos["elementos"]["elemento"].all?.count == 0
                {
                    return loopSearchFormula(elementos, id, tipo)
                }else
                {
                    if id == elementos.attributes["idelemento"] && tipo == elementos.attributes["tipoelemento"]
                    {   //let evento = Eventos(xmlString: elementos["atributos"]["eventos"].xml)
                        return elementos["atributos"]["eventos"].xml
                    }
                }
            }
        }
        return nil
    }
    
    
    public func openForm(tipoDoc: Int, expId: Int, flujoId: Int, piid: Int, guid: String) {
        
        resettingSettings().then { response in
            let files = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)", deep: true)
            
            var readFile = ""
            for file in files!{ if (file as! String).contains(".bor"){ readFile = file as! String; break; } }
            if readFile == ""{ return }
            
            let contentFile = ConfigurationManager.shared.utilities.read(asString: readFile)
            let plantilla = FEPlantillaData(json: contentFile)
            FormularioUtilities.shared.currentFormato = FEFormatoData()
            
            FormularioUtilities.shared.currentFormato.FlujoID = flujoId
            FormularioUtilities.shared.currentFormato.ExpID = expId
            FormularioUtilities.shared.currentFormato.TipoDocID = tipoDoc
            FormularioUtilities.shared.currentFormato.Guid = guid
            
            self.index = 0
            self.flujo = flujoId
            self.proceso = 0
            self.arrayPlantillaData = plantilla
            
            self.showLoading()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.initForm()
            }
        }
    }
    
    // MARK: Debug for auditory
    func getAllInfoAbout(_ elem: Elemento){
        if elem._idelemento == "plantilla"{
            let isValid = getInfoAboutElement(elem._tipoelemento)
            QAElements.append((elem._tipoelemento, isValid))
        }
        if elem.elementos == nil{ return }
        if elem.elementos?.elemento == nil, elem.elementos?.elemento.count == 0 { return }
        for element in elem.elementos!.elemento{
            // Looping
            if element.elementos?.elemento.count ?? 0 > 0 {
                let isValid = getInfoAboutElement(element._tipoelemento)
                QAElements.append((element._tipoelemento, isValid))
                getAllInfoAbout(element)
            }else{
                let isValid = getInfoAboutElement(element._tipoelemento)
                QAElements.append((element._tipoelemento, isValid))
            }
        }
        
    }
    
    func getInfoAboutElement(_ element: String) -> Bool{
        let ios = ["plantilla","pagina","audio","boton","calculadorafinanciera","codigobarras","comboboxtemporal","documento","marcadodocumentos","deslizante","espacio","fecha","firma", "firfafad", "georeferencia","hora","huelladigital","imagen","leyenda","lista","logico","logo","mapa","metodo","moneda","numero","password","pdfocr","rangofechas","seccion","servicio","tabla","tabber","texto","textarea","rostrovivo","video","wizard","videollamada"]
        if ios.contains(element){ return true }else{ return false }
    }
    
    func settingAllElementsInForms()->Promise<Bool>{
        return Promise<Bool>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger("Function SettingAllElementsInForms", .format)
            var isInit = false
            if xmlParsed.elementos?.elemento.count == 0 || xmlParsed.elementos?.elemento == nil  { reject(APIErrorResponse.ParseError); closeViewController(status: 400); return; }
            ConfigurationManager.shared.utilities.writeLogger("Paginas: \(xmlParsed.elementos?.elemento.count ?? 0)", .format)
            for element in (xmlParsed.elementos?.elemento)!{
                let pagina = printPagina()
                if isInit == false{
                    ConfigurationManager.shared.utilities.writeLogger("Plantilla: \(xmlParsed._idelemento)", .format)
                    let plantillarow = PlantillaRow("\(xmlParsed._idelemento)") { row in row.validationOptions = .validatesOnChange }
                    plantillarow.cell.formDelegate = self
                    FormularioUtilities.shared.elementsInPlantilla.append((id: xmlParsed._idelemento, type: "plantilla", kind: plantillarow, element: plantillarow.cell.elemento))
                    pagina +++ plantillarow
                }
                // Setting Pagina Row
                if element._tipoelemento == "footer" && self.atributosPlantilla?.verpieplantilla ?? false{
                    ConfigurationManager.shared.utilities.writeLogger("Footer: \(element._idelemento)", .format)
                    let footer = printPagina()
                    let attr = element.atributos as? Atributos_pagina
                    attr?.idelemento = element._idelemento
                    footerForm = footer
                    if element.elementos == nil{ continue }
                    if element.elementos?.elemento.count == 0{ continue }
                    isFooterDetected = true
                    printElemento(hijos: (element.elementos?.elemento)!, formulario: footer, atributosGlobales: attr, isFooter: true)
                }else if element._tipoelemento == "pagina"{
                    ConfigurationManager.shared.utilities.writeLogger("Pagina: \(element._idelemento)", .format)
                    let paginarow = PaginaRow("\(element._idelemento)") { row in row.validationOptions = .validatesOnChange }
                    paginarow.cell.formDelegate = self
                    let attr = element.atributos as? Atributos_pagina
                    attr?.idelemento = element._idelemento
                    FormularioUtilities.shared.paginasVisibles.append(attr ?? Atributos_pagina())
                    FormularioUtilities.shared.atributosPaginas.append(attr ?? Atributos_pagina())
                    FormularioUtilities.shared.elementsInPlantilla.append((id: element._idelemento, type: "pagina", kind: paginarow, element: paginarow.cell.elemento))
                    pagina +++ paginarow
                    
                    forms.append(pagina)
                    if element.elementos == nil{ continue }
                    if element.elementos?.elemento.count == 0{ continue }
                    printElemento(hijos: (element.elementos?.elemento)!, formulario: pagina, atributosGlobales: attr)
                    isInit = true
                }else{
                    isInit = false
                }
            }
            for additionalForm in sectionsDictionary{ forms.append(additionalForm.value) }
            
            resolve(true)
        }
    }
    
    func settingJsonValuesAllElementsInForms() -> Promise<Bool>{
        
        return Promise<Bool>{ resolve, reject in
            if xmlParsed.elementos?.elemento == nil{
                reject(APIErrorResponse.ParseError)
            }else{
                setValueElemento()
                resolve(true)
            }
        }
        
    }
    
    func setFormPromise(index: Int, override: Bool)->Promise<Bool>{
        return Promise<Bool>{ resolve, reject in
            ConfigurationManager.shared.utilities.writeLogger("Function SetFormPromise", .format)
            currentPage = index
            
            if override{
                self.form = forms[index]
            }else{
                self.form = forms[index]
                if FormularioUtilities.shared.atributosPaginas[index].visible{
                    FormularioUtilities.shared.atributosPaginas[index].visible = true
                }else{
                    FormularioUtilities.shared.atributosPaginas[index].visible = false
                }
                if self.forms[index].allSections.count == 0{
                    self.alert(message: "not_form_noelements".langlocalized())
                }
            }
            self.tableView.reloadData()
            
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            
            ConfigurationManager.shared.utilities.writeLogger("Set Visibility in Labels", .format)
            for rows in self.forms[index].allRows {
                if let row = rows as? EtiquetaRow {
                    ConfigurationManager.shared.utilities.writeLogger("Leyenda: \(row.tag ?? "")", .format)
                    row.cell.setEncoded()
                }
            }
            
            ConfigurationManager.shared.utilities.writeLogger("Set Visibility in Sections", .format)
            for rows in self.forms[index].allRows {
                if let row = rows as? HeaderRow, !(row.tag?.contains("-f"))! {
                    ConfigurationManager.shared.utilities.writeLogger("Section: \(row.tag ?? "")", .format)
                    self.setVisibleEnableElementsFromSection(row.tag ?? "", row.cell?.atributos ?? Atributos_seccion(), true, false)
                }
            }
            
            ConfigurationManager.shared.utilities.writeLogger("Set Visibility in Tabs", .format)
            for rows in self.forms[index].allRows {
                if let rowTab = rows as? HeaderTabRow, !(rowTab.tag?.contains("-f"))! {
                    ConfigurationManager.shared.utilities.writeLogger("Tab: \(rowTab.tag ?? "")", .format)
                    rowTab.cell.selectOption(0)
                }
            }
            
            if self.flagEventos{
                #warning("Cargado de FormularioUtilities")
                //TODO: Si se ocupa tambien: Operacioens Matematicas
                //MARK: Inicializacion de FormularioUtilities
                // Setting Formulas, Services and Components before content
                ConfigurationManager.shared.utilities.writeLogger("Getting Rules", .format)
                FormularioUtilities.shared.rules = self.sdkAPI?.getRULES(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))
                FormularioUtilities.shared.services = self.sdkAPI?.getSERVICES(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))
                FormularioUtilities.shared.components = self.sdkAPI?.getCOMPONENTS(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))
                ConfigurationManager.shared.utilities.writeLogger("Setting Rules", .format)
                _ = self.settingRules()
                // Execute setRulesOnProperties
                self.rulesOnProperties.append(index)
                self.executeRulesOnProperties(indexPage: index)
                ConfigurationManager.shared.utilities.writeLogger("Promise SettingJsonValues", .format)
                self.settingJsonValuesAllElementsInForms()
                    .then({ response in
                        ConfigurationManager.shared.utilities.writeLogger("Promise success", .format)
                        resolve(true)
                    }).catch({ error in
                        ConfigurationManager.shared.utilities.writeLogger("Promise error: \(error)", .format)
                        resolve(true)
                    })
            }else{
                // Execute setRulesOnProperties
                if !self.rulesOnProperties.contains(index)
                {   // Execute setRulesOnProperties
                    self.rulesOnProperties.append(index)
                    self.executeRulesOnProperties(indexPage: index)
                    resolve(true)
                } else
                {
                    resolve(true)
                }
            }
        }
    }
    
    // MARK: - Formula, Events, Rules and More
    func setFormulasAndRules(index: Int, override: Bool)->Promise<Bool>{
        
        return Promise<Bool>{ resolve, reject in
            
            // If currentPage '0' Fire Events in Plantilla
            if self.currentPage == 0{
                if self.flagEventos{
                    self.fireFirstEventPlantilla()
                }
                self.setEventos(index, override: false)
            }else{ self.setEventos(index, override: false) }
            
//            FormularioUtilities.shared.services = self.sdkAPI?.getSERVICES(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))
//            FormularioUtilities.shared.components = self.sdkAPI?.getCOMPONENTS(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))
            FormularioUtilities.shared.mathematics = self.sdkAPI?.getMATHEMATICS(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))
            FormularioUtilities.shared.prefilleddata = self.sdkAPI?.getPREFILLEDDATA(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))
            FormularioUtilities.shared.pdfmapping = self.sdkAPI?.getPDFMAPPING(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))
            //            FormularioUtilities.shared.macros = self.sdkAPI?.getMACROS(flujo: String(FormularioUtilities.shared.currentFormato.FlujoID), exp: String(FormularioUtilities.shared.currentFormato.ExpID), doc: String(FormularioUtilities.shared.currentFormato.TipoDocID ))
            self.setMathematicsToElements()
            
            //            //Parsear macros a estructura:
            //            if let macros = FormularioUtilities.shared.macros {
            //                self.parseMacros(macros)
            //            }
            
            if self.flagEventos{
                self.triggerPlantillaEvents(event: "deviceinuse")
                self.triggerPlantillaEvents(event: "document")
                self.triggerPlantillaEvents(event: "permissions")
                self.triggerPlantillaEvents(event: "loaded")
                self.flagEventos = false
            }
            triggerPageEvents(index)
            resolve(true)
        }
    }
    
    public func triggerPlantillaEvents(event: String){
        let elem = getElementANY("formElec_element0")
        switch elem.kind {
        case is PlantillaRow:
            let row = elem.kind as? PlantillaRow
            row?.cell.triggerRulesOnProperties(event)
            break
        default: break
        }
    }
    
    public func triggerPageEvents(_ i: Int){
        
        if FormularioUtilities.shared.paginasVisibles.count == 0{ return }
        let elem = getElementANY(FormularioUtilities.shared.paginasVisibles[i].idelemento)
        switch elem.kind {
        case is PaginaRow:
            let row = elem.kind as? PaginaRow
            row?.cell.triggerRulesOnChange("showpage")
            break
        default: break
        }
    }
    
    func resetSettings(){
        ConfigurationManager.shared.guid = ConfigurationManager.shared.utilities.guid()
        allIndex = 1
        formCounter = 0
        currentPage = -1
        pageSelected = 0
        
        plantillamapear = ""
        
        flagAlert = false
        flagLocation = false
        flagEventos = true
        
        self.titlePlantilla.text = ""
        self.subtitlePlantilla.text = ""
        self.pagesScrollView.subviews.forEach({ $0.removeFromSuperview() })
        
        dictValues = Dictionary<String, (docid:String, valor:String, valormetadato:String, tipodoc:String, metadatostipodoc:String,nameFirm:String, dateFirm:String, georefFirm:String, deviceFirm:String)>()
        currentPage = -1
        formatoData = FEFormatoData()
        isAnexoAdded = false
        isAutoEnable = false
        currentAnexos = [FEAnexoData]()
        anexosLocales = [(elementoid:String, anexo:FEAnexoData)]()
        anexosRemotos = [(elementoid:String, anexo:FEAnexoData)]()
        currentHijos = [Elemento]()
        sectionsDictionary = [String: Form]()
        self.forms = []
        self.form = Form()
        
        FormularioUtilities.shared.elementsInPlantilla = [(id: String, type: String, kind: Any?, element: Elemento?)]()
        FormularioUtilities.shared.atributosPaginas = [Atributos_pagina]()
        FormularioUtilities.shared.paginasVisibles = [Atributos_pagina]()
        self.tableView.reloadData()
    }
    
    public func setPrefilledDataNew(_ id: String, json: String = "", elements: NSMutableDictionary? = nil){
        resetSettings()
        //ressetSettingsNew().then { response in
        let elementsMut: NSMutableDictionary = elements ?? [:]
        let prefilledDocument = FormularioUtilities.shared.prefilleddata?.root["\(id)"]
        
        self.setMetaAttributes(self.xmlParsed, false)
        self.loopElements(self.xmlParsed)
        
        if prefilledDocument?.children.count == 0{
            self.hud.dismiss(animated: true)
            let bannerNew = NotificationBanner(title: "", subtitle: "not_noprefill".langlocalized(), leftView: nil, rightView: self.dangerView, style: .danger, colors: nil)
            bannerNew.show()
        }
        
        for elem in self.ElementosArray{
            
            elementsMut.setValue(elem.value, forKey: "\(elem.key)")
            
        }
        for e in ConfigurationManager.shared.elementosArray{
            elementsMut.setValue(e.value, forKey: "\(e.key)")
        }
        
        let newElementosArray: NSMutableDictionary = NSMutableDictionary()
        var pla: String?
        
        var theJsonText = String()
        
        pla = prefilledDocument?["idplantilla"].value ?? ""
        
        //            guard let prefil = prefilledDocument?["mapeo"].children else{
        //                return
        //            }
        for mapeo in (prefilledDocument?["mapeo"].children) ?? [AEXMLElement](){
            if mapeo["mapeoHijos"].error != nil { continue }
            if mapeo["mapeoHijos"].children.count == 0{ continue }
            for childs in mapeo["mapeoHijos"].children{
                for elem in elementsMut{
                    if childs["idelem"].value ?? "" == elem.key as? String {
                        newElementosArray.setValue(elem.value, forKey: "\(childs["destination"].value ?? "")")
                    }
                }
            }
        }
        
        if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: newElementosArray, options: .sortedKeys){
            theJsonText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
        }
        self.getValuesJson(theJsonText)
        
        let files = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/", deep: true)
        
        var readFile = ""
        for file in files!{ if (file as! String).contains("/\(pla ?? "").pla"){ readFile = file as! String; break; } }
        if readFile == ""{ return }
        let contentFile = ConfigurationManager.shared.utilities.read(asString: readFile)
        let plantilla = FEPlantillaData(json: contentFile)
        FormularioUtilities.shared.currentFormato = FEFormatoData()
        FormularioUtilities.shared.currentFormato.JsonDatos = theJsonText
        
        FormularioUtilities.shared.currentFormato.FlujoID = plantilla.FlujoID
        FormularioUtilities.shared.currentFormato.ExpID = plantilla.ExpID
        FormularioUtilities.shared.currentFormato.TipoDocID = plantilla.TipoDocID
        
        // Variables initiialization
        ConfigurationManager.shared.garbageCollector = [(id: String, value: String, desc: String)]()
        FormularioUtilities.shared.elementsInPlantilla = [(id: String, type: String, kind: Any?, element: Elemento?)]()
        
        // Obtain Guid for the format
        if FormularioUtilities.shared.currentFormato.Guid == "" || FormularioUtilities.shared.currentFormato.Guid == "0"{
            ConfigurationManager.shared.guid = ConfigurationManager.shared.utilities.guid()
            self.formatoData.Guid = ConfigurationManager.shared.guid
        }else{
            ConfigurationManager.shared.guid = FormularioUtilities.shared.currentFormato.Guid
            self.formatoData.Guid = ConfigurationManager.shared.guid
        }
        
        self.index = 0
        self.flujo = plantilla.FlujoID
        if plantilla.NombreExpediente == "Crédito Nómina"{
            plantilla.NombreExpediente = "Nómina"
            plantilla.NombreTipoDoc = "Nómina"
        }
        self.proceso = 0
        self.arrayPlantillaData = plantilla
        
        showLoading()
        
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.initForm()
        }
        //}
        
    }
    
    public func setPrefilledDataToNewForm(_ id: String, json: String = "", elements: NSMutableDictionary? = nil){
        // Resetting Settings
        resettingSettings().then { response in
            let elementsMut: NSMutableDictionary = elements ?? [:]
            let prefilledDocument = FormularioUtilities.shared.prefilleddata?.root["\(id)"]
            
            self.setMetaAttributes(self.xmlParsed, false)
            self.loopElements(self.xmlParsed)
            
            if prefilledDocument?.children.count == 0{
                self.hud.dismiss(animated: true)
                let bannerNew = NotificationBanner(title: "", subtitle: "not_noprefill".langlocalized(), leftView: nil, rightView: self.dangerView, style: .danger, colors: nil)
                bannerNew.show()
            }
            
            for elem in self.ElementosArray{
                
                elementsMut.setValue(elem.value, forKey: "\(elem.key)")
                
            }
            for e in ConfigurationManager.shared.elementosArray{
                elementsMut.setValue(e.value, forKey: "\(e.key)")
            }
            
            let newElementosArray: NSMutableDictionary = NSMutableDictionary()
            var pla: String?
            
            var theJsonText = String()
            
            pla = prefilledDocument?["idplantilla"].value ?? ""
            
            //            guard let prefil = prefilledDocument?["mapeo"].children else{
            //                return
            //            }
            for mapeo in (prefilledDocument?["mapeo"].children) ?? [AEXMLElement](){
                if mapeo["mapeoHijos"].error != nil { continue }
                if mapeo["mapeoHijos"].children.count == 0{ continue }
                for childs in mapeo["mapeoHijos"].children{
                    for elem in elementsMut{
                        if childs["idelem"].value ?? "" == elem.key as? String {
                            newElementosArray.setValue(elem.value, forKey: "\(childs["destination"].value ?? "")")
                        }
                    }
                }
            }
            
            if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: newElementosArray, options: .sortedKeys){
                theJsonText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
            }
            self.getValuesJson(theJsonText)
            
            let files = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.plantillas)/", deep: true)
            
            var readFile = ""
            for file in files!{ if (file as! String).contains("/\(pla ?? "").pla"){ readFile = file as! String; break; } }
            if readFile == ""{ return }
            let contentFile = ConfigurationManager.shared.utilities.read(asString: readFile)
            let plantilla = FEPlantillaData(json: contentFile)
            FormularioUtilities.shared.currentFormato = FEFormatoData()
            FormularioUtilities.shared.currentFormato.JsonDatos = theJsonText
            
            FormularioUtilities.shared.currentFormato.FlujoID = plantilla.FlujoID
            FormularioUtilities.shared.currentFormato.ExpID = plantilla.ExpID
            FormularioUtilities.shared.currentFormato.TipoDocID = plantilla.TipoDocID
            
            // Variables initiialization
            ConfigurationManager.shared.garbageCollector = [(id: String, value: String, desc: String)]()
            FormularioUtilities.shared.elementsInPlantilla = [(id: String, type: String, kind: Any?, element: Elemento?)]()
            
            // Obtain Guid for the format
            if FormularioUtilities.shared.currentFormato.Guid == "" || FormularioUtilities.shared.currentFormato.Guid == "0"{
                ConfigurationManager.shared.guid = ConfigurationManager.shared.utilities.guid()
                self.formatoData.Guid = ConfigurationManager.shared.guid
            }else{
                ConfigurationManager.shared.guid = FormularioUtilities.shared.currentFormato.Guid
                self.formatoData.Guid = ConfigurationManager.shared.guid
            }
            
            self.index = 0
            self.flujo = plantilla.FlujoID
            if plantilla.NombreExpediente == "Crédito Nómina"{
                plantilla.NombreExpediente = "Nómina"
                plantilla.NombreTipoDoc = "Nómina"
            }
            self.proceso = 0
            self.arrayPlantillaData = plantilla
            
            self.showLoading()
            
            self.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.initForm()
            }
        }
    }
    
    /// Funcion para Abrir formato anterior
    /// - Parameters:
    ///   - pla: pla description valor de entrada datos de la plantilla a abrir FEPlantillaData
    ///   - formato: formato description valor de entrada datos de un formato FEFormatoData
    func openPlantillaCot(pla: FEPlantillaData, formato: FEFormatoData){
        resettingSettings().then { response in
            
            FormularioUtilities.shared.currentFormato = formato
            FormularioUtilities.shared.currentFormato.JsonDatos = formato.JsonDatos
            self.dictValues = Dictionary<String, (docid:String, valor:String, valormetadato:String, tipodoc:String, metadatostipodoc:String, nameFirm:String, dateFirm:String, georefFirm:String, deviceFirm:String)>()
            self.getValuesJson(FormularioUtilities.shared.currentFormato.JsonDatos)
            FormularioUtilities.shared.currentFormato.FlujoID = pla.FlujoID
            FormularioUtilities.shared.currentFormato.ExpID = pla.ExpID
            FormularioUtilities.shared.currentFormato.TipoDocID = pla.TipoDocID
            
            // Variables initiialization
            ConfigurationManager.shared.garbageCollector = [(id: String, value: String, desc: String)]()
            FormularioUtilities.shared.elementsInPlantilla = [(id: String, type: String, kind: Any?, element: Elemento?)]()
            FormularioUtilities.shared.atributosPaginas = [Atributos_pagina]()
            FormularioUtilities.shared.paginasVisibles = [Atributos_pagina]()
            
            // Obtain Guid for the format
            if FormularioUtilities.shared.currentFormato.Guid == "" || FormularioUtilities.shared.currentFormato.Guid == "0"{
                ConfigurationManager.shared.guid = ConfigurationManager.shared.utilities.guid()
                self.formatoData.Guid = ConfigurationManager.shared.guid
            }else{
                ConfigurationManager.shared.guid = FormularioUtilities.shared.currentFormato.Guid
                self.formatoData.Guid = ConfigurationManager.shared.guid
            }
            
            self.index = 0
            self.flujo = pla.FlujoID
            self.proceso = 0
            self.arrayPlantillaData = pla
            
            self.showLoading()
            
            self.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.initForm()
            }
        }
    }
    
    func setMathematicsToElements(){
        
        if FormularioUtilities.shared.mathematics == nil{ return }
        if FormularioUtilities.shared.mathematics?.root == nil{ return }
        if FormularioUtilities.shared.mathematics?.root.children.count == 0{ return }
        for math in (FormularioUtilities.shared.mathematics?.root.children)!{
            
            if math["enabled"].value! == "true"{
                if math["identifiers"].children.count == 0{ continue }
                
                let f = math["formula"].value ?? ""
                let s = f.split{$0 == "="}.map(String.init)
                
                for identifier in math["identifiers"].children{
                    if identifier["identif"].value != nil, identifier["identif"].value == s[0]{ continue }
                    if identifier["idelem"].value != nil{
                        let elem = getElementANY(identifier["idelem"].value!)
                        switch elem.kind{
                        case is NumeroRow:
                            let row = elem.kind as? NumeroRow
                            row?.cell.setMathematics(true, math.name)
                            break;
                        case is TextoRow:
                            let row = elem.kind as? TextoRow
                            row?.cell.setMathematics(true, math.name)
                            break;
                        case is MonedaRow:
                            let row = elem.kind as? MonedaRow
                            row?.cell.setMathematics(true, math.name)
                            break
                        case is TextoAreaRow:
                            let row = elem.kind as? TextoAreaRow
                            row?.cell.setMathematics(true, math.name)
                            break
                        case is SliderNewRow:
                            let row = elem.kind as? SliderNewRow
                            row?.cell.setMathematics(true, math.name)
                            break
                        default: break;
                        }
                    }
                    
                }
            }
            
        }
        
    }
    
    func setEventos(_ cIndex: Int, override: Bool){
        if xmlParsed.elementos?.elemento == nil { return }
        if xmlParsed.elementos?.elemento.count == 0 { return }
        for (index, element) in (xmlParsed.elementos?.elemento.enumerated())!{
            if element._tipoelemento == "pagina" && cIndex == index{
                guard let attr = element.atributos as? Atributos_pagina else{ return }
                for evento in attr.eventos.expresion { addEventAction(evento)}
            }
        }
    }
    
}

// MARK: - EVENTOS HANDLER
extension NuevaPlantillaViewController{
    
    func fireFirstEventPlantilla()
    {
        if atributosPlantilla?.eventos == nil{ return }
        if atributosPlantilla?.eventos.expresion.count == 0 { return }
        for evento in (atributosPlantilla?.eventos.expresion)! {
            addEventAction(evento)
        }
    }
    
    public func addEventAction(_ evento: Expresion)
    {
        
        switch evento._tipoexpression
        {
        case "almostrarpagina", "alcambiar", "alentrar", "alterminarcaptura", "aldarclick", "alcargar":
            if evento.expresion?.count ?? 0 == 0 { return }
            for eventito in (evento.expresion)!{
                let tipo = eventito._categoria
                switch tipo{
                case "asignacion":
                    _ = recursiveTokenFormula(eventito.atributos?.formula, nil, tipo, false)
                    break
                case "condicion":
                    recursiveCondicionFormula((eventito.atributos)!, eventito.atributos!.condicion)
                    break
                default: break;
                }
            }
            break
        default: break
        }
        if let auxDatNav = UserDefaults.standard.indexPath(forKey: "NavegaciónDatos")
        {   UserDefaults.standard.removeObject(forKey: "NavegaciónDatos")
            if !form[auxDatNav].baseCell.isFocused
            {   form[auxDatNav].baseCell.cellBecomeFirstResponder() }
        }
    }
    
    public func recursiveCondicionFormula(_ atributos: Atributos_Expresion, _ condiciones: Array<Expresion>) {
        if condiciones.count == 0{ return }
        for condicion in condiciones {
            if condicion.expresion?.count ?? 0 == 0{ return }
            for expresionCondicion in condicion.expresion!{
                // Resolving formula
                if expresionCondicion.atributos?.formula == ""{ continue }
                let res = recursiveTokenFormula(expresionCondicion.atributos?.formula, nil, "afirmacion", false)
                switch res{
                case .typeString(let string):
                    if string == "" { return }
                    if string == "true" || string.lowercased() == "si" || string.lowercased() == "1" {
                        if atributos.coincidencia.count == 0{ return }
                        for coincidencia in atributos.coincidencia {
                            // Printing Coincidencia
                            if coincidencia.expresion == nil, coincidencia.atributos != nil {
                                let _ = recursiveTokenFormula(coincidencia.atributos?.formula, nil, "asignacion", false)
                            }else{
                                if coincidencia.expresion?.count ?? 0 == 0{ return }
                                for expresionCoincidencia in coincidencia.expresion!{
                                    if expresionCoincidencia.atributos?.formula != nil, expresionCoincidencia.atributos?.formula != "" {
                                        let _ = recursiveTokenFormula(expresionCoincidencia.atributos?.formula, nil, "asignacion", false)
                                    }else if expresionCoincidencia.atributos?.condicion.count ?? 0 > 0  {
                                        recursiveCondicionFormula(expresionCoincidencia.atributos!, expresionCoincidencia.atributos!.condicion)
                                    }
                                }
                            }
                            
                        }
                    } else {
                        // Printing Alternativa
                        if atributos.alternativa.count == 0{ return }
                        for alternativa in atributos.alternativa {
                            if alternativa.expresion == nil, alternativa.atributos != nil {
                                let _ = recursiveTokenFormula(alternativa.atributos?.formula, nil, "asignacion", false);
                            }else{
                                if alternativa.expresion?.count == 0{ return }
                                for expresionAlternativa in alternativa.expresion!{
                                    if expresionAlternativa.atributos?.formula != nil, expresionAlternativa.atributos?.formula != "" {
                                        let _ = recursiveTokenFormula(expresionAlternativa.atributos?.formula, nil, "asignacion", false);
                                    }else{
                                        if expresionAlternativa.atributos?.condicion.count ?? 0 > 0{
                                            recursiveCondicionFormula(expresionAlternativa.atributos!, expresionAlternativa.atributos!.condicion)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    break
                case .typeInt( _): break
                case .typeArray( _): break
                case .typeDictionary( _): break
                case .typeNil( _): break
                }
            }
        }
        
    }
    
    func detectTrue(_ str: String)->Bool{
        if str == "true" || str.lowercased() == "si" || str.lowercased() == "1"{ return true }else{ return false }
    }
    
    public func recursiveTokenFormula(_ formul: String? = nil,_ dict: [Formula]? = nil, _ typefrml: String, _ encoded: Bool) -> ReturnFormulaType {
        
        var formula: [Formula]?
        if encoded{ formula = dict }else{ if formul != nil && formul != ""{ formula = [Formula](json: formul) } }
        // Formula
        var logics = [(value: String, index: Int)]()
        var equals = [Int]()
        var rightformul = [Formula]()
        var leftformul = [Formula]()
        if formula == nil || formula?.count == 0{ return ReturnFormulaType.typeNil("not_form_norules".langlocalized()) }
        for (index, token) in formula!.enumerated(){
            if token.value == "&&" || token.value == "||" || token.value == "Y tambien" || token.value == "O tambien"{
                logics.append((value: token.value, index: index))
            }else if token.value == "="{ equals.append(index) }
        }
        
        if logics.count > 0{
            
            var resultsAll: [Bool] = [Bool]()
            var resultsAny: [Bool] = [Bool]()
            for (index, logic) in logics.enumerated(){
                // Creating logic to logics
                // Left formula and Right formula
                let logicLeftFormula = Array(formula![..<logic.index])
                var logicRightFormula: Array<Formula>?
                if logics.indices.contains(index + 1){
                    logicRightFormula = Array(formula![(logic.index + 1)..<logics[index + 1].index])
                    let rr1 = recursiveTokenFormula(nil, logicLeftFormula, "afirmacion", true)
                    let rr2 = recursiveTokenFormula(nil, logicRightFormula, "afirmacion", true)
                    
                    switch rr1{
                    case .typeString(let string):
                        if detectTrue(string){
                            if logic.value == "Y tambien"{ resultsAll.append(true) }else if logic.value == "O tambien"{ resultsAny.append(true) }
                        }else{
                            if logic.value == "Y tambien"{ resultsAll.append(false) }else if logic.value == "O tambien"{ resultsAny.append(false) }
                        }
                    case .typeInt(let int):
                        if int == 1 { if logic.value == "Y tambien"{ resultsAll.append(true) }else if logic.value == "O tambien"{ resultsAny.append(true) }
                        }else{
                            if logic.value == "Y tambien"{ resultsAll.append(false) }else if logic.value == "O tambien"{ resultsAny.append(false) }
                        }
                    case .typeArray( _): break
                    case .typeDictionary( _): break
                    default: break
                    }
                    switch rr2{
                    case .typeString(let string):
                        if detectTrue(string){
                            if logic.value == "Y tambien"{ resultsAll.append(true) }else if logic.value == "O tambien"{ resultsAny.append(true) }
                        }else{
                            if logic.value == "Y tambien"{ resultsAll.append(false) }else if logic.value == "O tambien"{ resultsAny.append(false) }
                        }
                    case .typeInt(let int):
                        if int == 1 {
                            if logic.value == "Y tambien"{ resultsAll.append(true) }else if logic.value == "O tambien"{ resultsAny.append(true) }
                        }else{
                            if logic.value == "Y tambien"{ resultsAll.append(false) }else if logic.value == "O tambien"{ resultsAny.append(false) }
                        }
                    case .typeArray( _): break
                    case .typeDictionary( _): break
                    default: break
                    }
                }else{
                    let rr1 = recursiveTokenFormula(nil, logicLeftFormula, "afirmacion", true)
                    
                    switch rr1{
                    case .typeString(let string):
                        if detectTrue(string){
                            if logic.value == "Y tambien"{ resultsAll.append(true) }else if logic.value == "O tambien"{ resultsAny.append(true) }
                        }else{
                            if logic.value == "Y tambien"{ resultsAll.append(false) }else if logic.value == "O tambien"{ resultsAny.append(false) }
                        }
                    case .typeInt(let int):
                        if int == 1 {
                            if logic.value == "Y tambien"{ resultsAll.append(true) }else if logic.value == "O tambien"{ resultsAny.append(true) }
                        }else{
                            if logic.value == "Y tambien"{ resultsAll.append(false) }else if logic.value == "O tambien"{ resultsAny.append(false) }
                        }
                    case .typeArray( _): break
                    case .typeDictionary( _): break
                    default: break
                    }
                }
            }
            
            // Resolving Formulas
            if resultsAll.count > 0 {
                for result in resultsAll{ if !result{ return ReturnFormulaType.typeNil(nil) } }
                return ReturnFormulaType.typeString("si")
            }else if resultsAny.count > 0{
                for result in resultsAny{ if result{ return ReturnFormulaType.typeString("si") } }
                return ReturnFormulaType.typeNil(nil)
            }
            return ReturnFormulaType.typeString("no")
            
        }else if equals.count > 0{
            for equal in equals{
                if typefrml == "afirmacion"{
                    // Afirmacion
                    if formula == nil || formula?.count == 0{ return ReturnFormulaType.typeNil("not_form_norules".langlocalized()) }
                    for (index, token) in (formula!.enumerated()){ if index < equal{ leftformul.append(token) } }
                    
                    rightformul = Array(formula![(equal + 1)...])
                    for token in formula!{
                        if leftformul.count >= 2{
                            if token.type == "elementovariable"{
                                let rr1 = recursiveTokenFormula(nil, rightformul, "afirmacion", true)
                                if leftformul.indices.contains(2){
                                    let res = resolveAsignOrCompare(leftformul[2].value, "afirmacion", rr1, token, formula!, equals[0])
                                    return ReturnFormulaType.typeString(res)
                                }
                            }
                        }else{
                            let res = FormularioUtilities.shared.variables(formula!)
                            return ReturnFormulaType.typeString(res)
                        }
                    }
                }else{
                    // Asignacion
                    if formula == nil || formula?.count == 0{ return ReturnFormulaType.typeNil("not_form_norules".langlocalized()) }
                    for (index, token) in (formula!.enumerated()){ if index < equal{ leftformul.append(token) } }
                    
                    rightformul = Array(formula![(equal + 1)...])
                    if rightformul.count == 0{ return ReturnFormulaType.typeNil("not_form_nomorerules".langlocalized()) }
                    var resultString = ""
                    repeat {
                        if rightformul[0].type == "unit"{
                            let value = rightformul[0].value.cleanFormulaString()
                            if resultString == ""{ resultString = "\(value)"
                            }else{ resultString = "\(resultString)\(value)" }
                            rightformul = Array(rightformul[1...])
                            continue
                        }
                        if rightformul[0].type == "character"{
                            let value = rightformul[0].value.cleanFormulaStringWithoutSpaces()
                            if resultString == ""{ resultString = "\(value)"
                            }else{ resultString = "\(resultString)\(value)" }
                            rightformul = Array(rightformul[1...])
                            continue
                        }
                        if rightformul[0].type == "operator"{
                            rightformul = Array(rightformul[1...])
                            continue
                        }
                        if rightformul[0].type == "quotation"{
                            let value = rightformul[0].value.cleanFormulaString()
                            if resultString == ""{ resultString = "\(value)"
                            }else{ resultString = "\(resultString)\(value)" }
                            rightformul = Array(rightformul[1...])
                            continue
                        }
                        if rightformul[0].type == "environment"{
                            let current = Array(rightformul[..<1])
                            rightformul = rightformul.filter { !current.contains($0) }
                            let op = FormularioUtilities.shared.variables(current)
                            if op == ""{ continue }
                            if resultString == ""{ resultString = "\(op)" }else{ resultString = "\(resultString) \(op)" }
                            continue
                        }
                        if rightformul[0].type == "elementovariable"{
                            let minformul = Array(rightformul[0...2])
                            rightformul = Array(rightformul[3...])
                            let str = recursiveTokenFormula(nil, minformul, "asignacion", true)
                            switch str{
                            case .typeString(let string):
                                if resultString == ""{ resultString = "\(string)" }else{ resultString = "\(resultString) \(string)" }; break
                            case .typeInt(let int):
                                if resultString == ""{ resultString = "\(int)" }else{ resultString = "\(resultString) \(int)" }; break
                            case .typeArray( _): break
                            case .typeDictionary( _): break
                            default: break
                            }
                        }
                    } while rightformul.count > 0;
                    if leftformul.indices.contains(0){
                        if leftformul[0].type == "elementovariable"{
                            let res = resolveAsignOrCompare(leftformul[2].value, "asignacion", ReturnFormulaType.typeString(resultString), leftformul[0], formula!, equals[0])
                            return ReturnFormulaType.typeString(res)
                        }
                    }
                }
            }
        }else{
            if formula == nil || formula?.count == 0{ return ReturnFormulaType.typeNil("not_form_norules".langlocalized()) }
            if formula?.count ?? 0 >= 3{
                let counterOperator = 1
                if formula![counterOperator].type == "operator"{
                    var value1: String?
                    var value2: String?
                    if formula![counterOperator - 1].type == "environment"{
                        value1 = FormularioUtilities.shared.variables([formula![counterOperator - 1]])
                    }else{
                        value1 = formula![counterOperator - 1].value
                    }
                    if formula![counterOperator + 1].type == "environment"{
                        value2 = FormularioUtilities.shared.variables([formula![counterOperator + 1]])
                    }else{
                        value2 = formula![counterOperator + 1].value
                    }
                    let res = FormularioUtilities.shared.operaciones(value1 ?? "", value2 ?? "", formula![counterOperator].value)
                    return ReturnFormulaType.typeString(res)
                }
            }
            let token = formula![0];
            if (token.type == "elementovariable") {
                let res = resolveFormulaByType(formula!, false)
                return res
            }
            else if (token.type == "environment") {
                if formula!.count > 0{
                    let res = FormularioUtilities.shared.variables(formula!)
                    return ReturnFormulaType.typeString(res)
                }
            }
            else if (token.value != "") {
                return ReturnFormulaType.typeString(token.value)
            }
        }
        return ReturnFormulaType.typeNil("not_form_nomorerules".langlocalized())
    }
    
    func resolveValue(_ formul: [Formula], _ token: Formula) -> ReturnFormulaType{
        if !formul.indices.contains(2){ return ReturnFormulaType.typeNil(nil) }
        switch(formul[2].value){
        case "alerta":
            break
        case "click":
            let element = getElementANY(token.id)
            if(element.element != nil){
                switch element.type{
                case "boton":
                    let botonrow: BotonRow = element.kind as! BotonRow
                    botonrow.cell.botonAction(nil)
                    break
                default:
                    break
                }
            }
            break
        case "coordenadas":
            // MARK: - BEGIN DIGIPROSDKATO
            let element = getElementANY(token.id)
            if(element.element != nil){
                switch element.type{
                case "georeferencia":
                    let botonrow: MapaRow = element.kind as! MapaRow
                    botonrow.cell.btnCallPosicionAction()
                    break
                default:
                    break
                }
            }
            break
        case "ejecuta":
            self.ejecutaServicioMetodo(formul, token)
            break
        case "error":
            break
        case "habilitado":
            break
        case "huellas":
            break
        case "mensaje":
            break
        case "mostrar":
            let element = getElementANY(token.id)
            if(element.element != nil){
                switch element.type{
                case "pagina":
                    
                    break
                default:
                    break
                }
            }
            break
        case "requerido":
            break
        case "seleccionado":
            break
        case "valor":
            let element = getElementANY(token.id)
            if(element.element != nil){
                switch element.type{
                case "texto":
                    let textorow: TextoRow = element.kind as! TextoRow
                    return ReturnFormulaType.typeString(textorow.value ?? "")
                case "textarea":
                    let textorow: TextoAreaRow = element.kind as! TextoAreaRow
                    return ReturnFormulaType.typeString(textorow.value ?? "")
                case "fecha":
                    let fecharow: FechaRow = element.kind as! FechaRow
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    formatter.locale = Locale(identifier: "es_MX")
                    if fecharow.value == nil{
                        return ReturnFormulaType.typeString("")
                    }
                    return ReturnFormulaType.typeString(formatter.string(from: fecharow.value!))
                default:
                    break
                }
            }
            break
        case "visible":
            break
        default:
            break
        }
        
        return ReturnFormulaType.typeNil(nil)
    }
    
    func resolveFormulaByType(_ formul: [Formula], _ onlyresolve: Bool) -> ReturnFormulaType {
        for token in formul {
            if token.type == "character" || token.type == "point" || token.type == "unit" || token.type == "operator" || token.type == "equal"{
                
            }
            if token.type == "elementovariable"{
                if formul.count > 3{
                    let res = resolveValue(formul, token)
                    return res
                }else if(formul.count == 3){
                    // Obtencion
                    let res = resolveValue(formul, token)
                    return res
                }else{
                    // Obtencion
                    let res = resolveValue(formul, token)
                    return res
                }
                
            }else if token.type == "propiedadvariable"{
                // token["value"] = ""
            }else if token.type == "quotation"{
                // token["value"] = ""
            }else if token.type == "environment"{
                let res = FormularioUtilities.shared.variables(formul)
                return ReturnFormulaType.typeString(res)
            }else{
                
            }
        }
        return ReturnFormulaType.typeNil(nil)
    }
    
    public func getElementANY(_ id: String) -> (id: String, type: String, kind: Any?, element: Elemento?){
        ConfigurationManager.shared.utilities.log(.log, "Getting info of element: \(id)")
        for formulario in forms{
            for rows in formulario.allRows{
                if rows.tag! == id{
                    
                    switch rows{
                    case is PlantillaRow: return (rows.tag ?? "", "plantilla", rows, (rows as? PlantillaRow)?.cell.elemento)
                    case is PaginaRow: return (rows.tag ?? "", "pagina", rows, (rows as? PaginaRow)?.cell.elemento)
                    case is HeaderRow: return (rows.tag ?? "", "seccion", rows, (rows as? HeaderRow)?.cell.elemento)
                    case is HeaderTabRow: return (rows.tag ?? "", "tabber", rows, (rows as? HeaderTabRow)?.cell.elemento)
                    case is TextoRow:
                        if (rows as? TextoRow)?.cell.atributos != nil{ return (rows.tag ?? "", "texto", rows, (rows as? TextoRow)?.cell.elemento) }
                        if (rows as? TextoRow)?.cell.atributosPassword != nil{ return (rows.tag ?? "", "password", rows, (rows as? TextoRow)?.cell.elemento) }
                        break;
                    case is TextoAreaRow: return (rows.tag ?? "", "textarea", rows, (rows as? TextoAreaRow)?.cell.elemento)
                    case is BotonRow: return (rows.tag ?? "", "boton", rows, (rows as? BotonRow)?.cell.elemento)
                    case is FechaRow:
                        if (rows as? FechaRow)?.cell.atributos != nil{ return (rows.tag ?? "", "fecha", rows, (rows as? FechaRow)?.cell.elemento) }
                        if (rows as? FechaRow)?.cell.atributosHora != nil{ return (rows.tag ?? "", "hora", rows, (rows as? FechaRow)?.cell.elemento) }
                        break;
                    case is EtiquetaRow: return (rows.tag ?? "", "leyenda", rows, (rows as? EtiquetaRow)?.cell.elemento)
                    case is ListaRow: return (rows.tag ?? "", "lista", rows, (rows as? ListaRow)?.cell.elemento)
                    case is MarcadoDocumentoRow:
                        if plist.idportal.rawValue.dataI() >= 41 {
                            return (rows.tag ?? "", "marcadodocumentos", rows, (rows as? MarcadoDocumentoRow)?.cell.elemento)
                        } else { break; }
                    case is ListaTemporalRow: return (rows.tag ?? "", "comboboxtemporal", rows, (rows as? ListaTemporalRow)?.cell.elemento)
                    case is ComboDinamicoRow:
                        if plist.idportal.rawValue.dataI() >= 40 {
                            return (rows.tag ?? "", "combodinamico", rows, (rows as? ComboDinamicoRow)?.cell.elemento)
                        } else { break; }
                    case is LogicoRow: return (rows.tag ?? "", "logico", rows, (rows as? LogicoRow)?.cell.elemento)
                    case is SliderNewRow: return (rows.tag ?? "", "deslizante", rows, (rows as? SliderNewRow)?.cell.elemento)
                    case is LogoRow: return (rows.tag ?? "", "logo", rows, (rows as? LogoRow)?.cell.elemento)
                    case is MonedaRow: return (rows.tag ?? "", "moneda", rows, (rows as? MonedaRow)?.cell.elemento)
                    case is NumeroRow: return (rows.tag ?? "", "numero", rows, (rows as? NumeroRow)?.cell.elemento)
                    case is RangoFechasRow: return (rows.tag ?? "", "rangofechas", rows, (rows as? RangoFechasRow)?.cell.elemento)
                    case is WizardRow: return (rows.tag ?? "", "wizard", rows, (rows as? WizardRow)?.cell.elemento)
                    case is CodigoBarrasRow: return (rows.tag ?? "", "codigobarras", rows, (rows as? CodigoBarrasRow)?.cell.elemento)
                    case is CodigoQRRow:
                        if plist.idportal.rawValue.dataI() >= 39 {
                            return (rows.tag ?? "", "codigoqr", rows, (rows as? CodigoQRRow)?.cell.elemento)
                        } else { break; }
                    case is EscanerNFCRow:
                        if plist.idportal.rawValue.dataI() >= 39 {
                            return (rows.tag ?? "", "nfc", rows, (rows as? EscanerNFCRow)?.cell.elemento)
                        } else { break; }
                    case is TablaRow: return (rows.tag ?? "", "tabla", rows, (rows as? TablaRow)?.cell.elemento)
                    case is AudioRow: return (rows.tag ?? "", "audio", rows, (rows as? AudioRow)?.cell.elemento)
                    case is FirmaRow: return (rows.tag ?? "", "firma", rows, (rows as? FirmaRow)?.cell.elemento)
                    case is FirmaFadRow:
                        if plist.idportal.rawValue.dataI() >= 39{
                            return (rows.tag ?? "", "firmafad", rows, (rows as? FirmaFadRow)?.cell.elemento)
                        }
                    case is MapaRow:
                        if (rows as? MapaRow)?.cell.atributos != nil{ return (rows.tag ?? "", "mapa", rows, (rows as? MapaRow)?.cell.elemento) }
                        if (rows as? MapaRow)?.cell.atributosGeo != nil{ return (rows.tag ?? "", "georeferencia", rows, (rows as? MapaRow)?.cell.elemento) }
                        break;
                    case is ImagenRow: return (rows.tag ?? "", "imagen", rows, (rows as? ImagenRow)?.cell.elemento)
                    case is DocFormRow: return (rows.tag ?? "", "pdfocr", rows, (rows as? DocFormRow)?.cell.elemento)
                    case is VideoRow: return (rows.tag ?? "", "video", rows, (rows as? VideoRow)?.cell.elemento)
                    case is ServicioRow: return (rows.tag ?? "", "servicio", rows, (rows as? ServicioRow)?.cell.elemento)
                    case is MetodoRow: return (rows.tag ?? "", "metodo", rows, (rows as? MetodoRow)?.cell.elemento)
                    case is CalculadoraRow:
                        if plist.idportal.rawValue.dataI() >= 39{
                            return (rows.tag ?? "", "calculadorafinanciera", rows, (rows as? CalculadoraRow)?.cell.elemento)
                        }
                    case is DocumentoRow: return (rows.tag ?? "", "documento", rows, (rows as? DocumentoRow)?.cell.elemento)
                    case is VeridiumRow: return (rows.tag ?? "", "huelladigital", rows, (rows as? VeridiumRow)?.cell.elemento)
                    case is VeridasDocumentOcrRow: return (rows.tag ?? "", "ocr", rows, (rows as? VeridasDocumentOcrRow)?.cell.elemento)
                        case is JUMIODocumentOcrRow: return (rows.tag ?? "", "jumio", rows, (rows as? JUMIODocumentOcrRow)?.cell.elemento)
                    default: break;
                    }
                }
            }
        }
        return ("", "", nil, nil)
    }
    
    
    public func getElementService(_ prefijo: String, _ isSalida: Bool) -> [String : Any] {
        
        var valuesData : [String:Any] = [:]
        
        for formulario in forms{
            for rows in formulario.allRows{
                switch rows{
                case is VeridiumRow: break;
                case is AudioRow: break;
                case is FirmaRow: break;
                case is FirmaFadRow:
                    if plist.idportal.rawValue.dataI() >= 39{
                        
                        let base = rows as? FirmaFadRow
                        if (rows as? FirmaFadRow)?.cell.atributos != nil
                        {if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                        {
                            if isSalida
                            {
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[rows.tag ?? ""] = nameValue
                            }else{
                                valuesData["hash"] = base?.cell.atributos.hashCrypt ?? ""
                            }
                        }
                        }
                        
                        break;
                    }
                    break;
                case is MapaRow: break;
                case is ImagenRow:
                    let base = rows as? ImagenRow
                    if (rows as? ImagenRow)?.cell.atributos != nil
                    {if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        }else{
                            
                            let exist = FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(base?.cell.path ?? "0")")
                            if exist && base?.cell.path != ""{
                                let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(base?.cell.path ?? "")")
                                let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[nameValue] = anexoBase64
                            }else{
                                if base?.cell.anexo != nil{
                                    //We're going to download the attachment
                                    let isDownloaded = self.sdkAPI?.DGSDKdownloadAttachmentSync(delegate: self, anexo: (base?.cell.anexo)!) ?? false
                                    if isDownloaded{
                                        base?.cell.setAnexo((base?.cell.anexo)!)
                                        let exist = FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(base?.cell.anexo?.FileName ?? "")")
                                        if exist && base?.cell.anexo?.FileName != ""{
                                            let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(base?.cell.anexo?.FileName ?? "")")
                                            let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                            valuesData[nameValue] = anexoBase64
                                        }
                                    }
                                }
                            }
                            if prefijo.contains("rostro") || prefijo.contains("Rostro"){
                                valuesData["proveedor"] = "FacePlusPlus"
                            }
                        }
                    }
                    }
                    break;
                case is VideoRow: break;
                case is ServicioRow: break;
                case is MetodoRow: break;
                case is CalculadoraRow: break;
                case is DocumentoRow: break;
                case is CodigoBarrasRow:
                    let base = rows as? CodigoBarrasRow
                    if (rows as? CodigoBarrasRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        } else
                        {
                            let _ = (rows.tag ?? "", "codigobarras", rows, (rows as? CodigoBarrasRow)?.cell.elemento)
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[nameValue] = (rows as? CodigoBarrasRow)?.cell.elemento.validacion.valormetadato ?? ""
                        }
                    }
                    }
                    break;
                case is CodigoQRRow:
                    if plist.idportal.rawValue.dataI() >= 39 {
                        let base = rows as? CodigoQRRow
                        if (rows as? CodigoQRRow)?.cell.atributos != nil
                        {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                        {
                            if isSalida
                            {
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[rows.tag ?? ""] = nameValue
                            } else
                            {
                                let _ = (rows.tag ?? "", "codigoqr", rows, (rows as? CodigoQRRow)?.cell.elemento)
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[nameValue] = (rows as? CodigoQRRow)?.cell.elemento.validacion.valormetadato ?? ""
                            }
                        }
                        }
                    }
                    break;
                case is EscanerNFCRow:
                    if plist.idportal.rawValue.dataI() >= 39 {
                        let base = rows as? EscanerNFCRow
                        if (rows as? EscanerNFCRow)?.cell.atributos != nil
                        {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                        {
                            if isSalida
                            {
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[rows.tag ?? ""] = nameValue
                            } else
                            {
                                let _ = (rows.tag ?? "", "nfc", rows, (rows as? EscanerNFCRow)?.cell.elemento)
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[nameValue] = (rows as? EscanerNFCRow)?.cell.elemento.validacion.valor ?? ""
                            }
                        }
                        }
                    }
                    break;
                case is TablaRow:
                    let base = rows as? TablaRow
                    if (rows as? TablaRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {   if isSalida
                    {
                        let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                        valuesData[rows.tag ?? ""] = "istable-\(nameValue)"
                    }
                    }
                    }
                case is VeridasDocumentOcrRow:
                    break
                case is JUMIODocumentOcrRow: break;
                case is PlantillaRow: break;
                case is PaginaRow: break;
                case is HeaderRow: break;
                case is HeaderTabRow: break;
                case is BotonRow: break;
                case is LogoRow: break;
                case is WizardRow: break;
                case is EtiquetaRow: break;
                case is MarcadoDocumentoRow:break;
                case is TextoRow:
                    let base = rows as? TextoRow
                    if (rows as? TextoRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        } else
                        {
                            let _ = (rows.tag ?? "", "texto", rows, (rows as? TextoRow)?.cell.elemento)
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[nameValue] = (rows as? TextoRow)?.cell.elemento.validacion.valormetadato ?? ""
                        }
                    }
                    }
                    if (rows as? TextoRow)?.cell.atributosPassword != nil
                    {   if base?.cell.atributosPassword?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        } else
                        {
                            let _ = (rows.tag ?? "", "texto", rows, (rows as? TextoRow)?.cell.elemento)
                            let nameValue = base?.cell.atributosPassword?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[nameValue] = (rows as? TextoRow)?.cell.elemento.validacion.valormetadato ?? ""
                        }
                    }
                    }
                    break;
                case is TextoAreaRow:
                    let base = rows as? TextoAreaRow
                    if (rows as? TextoAreaRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        } else
                        {
                            let _ = (rows.tag ?? "", "textarea", rows, (rows as? TextoAreaRow)?.cell.elemento)
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[nameValue] = (rows as? TextoAreaRow)?.cell.elemento.validacion.valormetadato ?? ""
                        }
                    }
                    }
                    break;
                case is LogicoRow:
                    let base = rows as? LogicoRow
                    if (rows as? LogicoRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        } else
                        {
                            let _ = (rows.tag ?? "", "logico", rows, (rows as? LogicoRow)?.cell.elemento)
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[nameValue] = (rows as? LogicoRow)?.cell.elemento.validacion.valormetadato ?? ""
                        }
                    }
                    }
                    break;
                case is FechaRow:
                    let base = rows as? FechaRow
                    if (rows as? FechaRow)?.cell.atributos != nil
                    {
                        if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                        {
                            if isSalida
                            {
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[rows.tag ?? ""] = nameValue
                            } else
                            {
                                let _ = (rows.tag ?? "", "fecha", rows, (rows as? FechaRow)?.cell.elemento)
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[nameValue] = (rows as? FechaRow)?.cell.elemento.validacion.valormetadato ?? ""
                            }
                        }
                    }
                    if (rows as? FechaRow)?.cell.atributosHora != nil
                    {
                        if base?.cell.atributosHora?.idunico.contains(prefijo) ?? false
                        {
                            if isSalida
                            {
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[rows.tag ?? ""] = nameValue
                            } else
                            {
                                let _ = (rows.tag ?? "", "hora", rows, (rows as? FechaRow)?.cell.elemento)
                                let nameValue = base?.cell.atributosHora?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[nameValue] = (rows as? FechaRow)?.cell.elemento.validacion.valormetadato ?? ""
                            }
                        }
                    }
                    break;
                    
                case is ListaRow:
                    let base = rows as? ListaRow
                    if (rows as? ListaRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        } else
                        {
                            let _ = (rows.tag ?? "", "lista", rows, (rows as? ListaRow)?.cell.elemento)
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[nameValue] = (rows as? ListaRow)?.cell.elemento.validacion.valormetadato ?? ""
                        }
                    }
                    }
                    break;
                case is ListaTemporalRow:
                    let base = rows as? ListaTemporalRow
                    if (rows as? ListaTemporalRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                        {   if isSalida
                            {
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[rows.tag ?? ""] = nameValue
                            } else
                            {
                                let _ = (rows.tag ?? "", "comboboxtemporal", rows, (rows as? ListaTemporalRow)?.cell.elemento)
                                let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                valuesData[nameValue] = (rows as? ListaTemporalRow)?.cell.elemento.validacion.valormetadato ?? ""
                            }
                        }
                    }
                    break;
                case is ComboDinamicoRow:
                    if plist.idportal.rawValue.dataI() >= 40 {
                        let base = rows as? ComboDinamicoRow
                        if (rows as? ComboDinamicoRow)?.cell.atributos != nil
                        {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                            {   if isSalida
                                {
                                    let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                    valuesData[rows.tag ?? ""] = nameValue
                                } else
                                {
                                    let _ = (rows.tag ?? "", "combodinamico", rows, (rows as? ComboDinamicoRow)?.cell.elemento)
                                    let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                                    valuesData[nameValue] = (rows as? ComboDinamicoRow)?.cell.elemento.validacion.valormetadato ?? ""
                                }
                            }
                        }
                    }
                    break;
                case is SliderNewRow:
                    let base = rows as? SliderNewRow
                    if (rows as? SliderNewRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        } else
                        {
                            let _ = (rows.tag ?? "", "deslizante", rows, (rows as? SliderNewRow)?.cell.elemento)
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[nameValue] = (rows as? SliderNewRow)?.cell.elemento.validacion.valormetadato ?? ""
                        }
                    }
                    }
                    break;
                case is MonedaRow:
                    let base = rows as? MonedaRow
                    if (rows as? MonedaRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        } else
                        {
                            let _ = (rows.tag ?? "", "moneda", rows, (rows as? MonedaRow)?.cell.elemento)
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[nameValue] = (rows as? MonedaRow)?.cell.elemento.validacion.valormetadato ?? ""
                        }
                    }
                    }
                    break;
                case is NumeroRow:
                    let base = rows as? NumeroRow
                    if (rows as? NumeroRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        } else
                        {
                            let _ = (rows.tag ?? "", "numero", rows, (rows as? NumeroRow)?.cell.elemento)
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[nameValue] = (rows as? NumeroRow)?.cell.elemento.validacion.valormetadato ?? ""
                        }
                    }
                    }
                    break;
                case is RangoFechasRow:
                    let base = rows as? RangoFechasRow
                    if (rows as? RangoFechasRow)?.cell.atributos != nil
                    {   if base?.cell.atributos?.idunico.contains(prefijo) ?? false
                    {
                        if isSalida
                        {
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[rows.tag ?? ""] = nameValue
                        } else
                        {
                            let _ = (rows.tag ?? "", "rangofechas", rows, (rows as? RangoFechasRow)?.cell.elemento)
                            let nameValue = base?.cell.atributos?.idunico.replacingOccurrences(of: prefijo, with: "") ?? ""
                            valuesData[nameValue] = (rows as? RangoFechasRow)?.cell.elemento.validacion.valormetadato ?? ""
                        }
                    }
                    }
                    break;
                default: break;
                }
            }
        }
        valuesData["proyid"] = "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)"
        valuesData["appid"] = "\(ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID)"
        valuesData["expid"] = "\(FormularioUtilities.shared.currentFormato.ExpID)"
        valuesData["grupoid"] = "\(ConfigurationManager.shared.usuarioUIAppDelegate.GrupoAdminID)"
        valuesData["user"] = "\(ConfigurationManager.shared.usuarioUIAppDelegate.User)"
        valuesData["userid"] = ""
        //valuesData["docid"] = "\(FormularioUtilities.shared.currentFormato.DocID)"
        valuesData["guidf"] = "\(FormularioUtilities.shared.currentFormato.Guid)"
        valuesData["piid"] = "\(FormularioUtilities.shared.currentFormato.PIID)"
        valuesData["esweb"] = "false"
        var newValue: String = ""
        for (key, value) in valuesData{
            if key == "number"{
                newValue = value as! String
                newValue = newValue.replacingOccurrences(of: "MX", with: "")
            }
            
        }
        valuesData.updateValue(newValue, forKey: "number")
        return valuesData
    }
    
    func resolveAsignOrCompare(_ type: String, _ mode: String, _ rr: ReturnFormulaType, _ elem: Formula, _ formul: [Formula], _ equals: Int) -> String{
        // Detect Element by ID
        let element = getElementANY(elem.id)
        
        if(element.element != nil){
            
            switch (type) {
            case "valor":
                // Call Utility to resolve Valor
                let valor = resolveValor(type, mode, rr, elem, formul, equals)
                return valor
            case "habilitado":
                // Call Utility to resolve Habilitado
                let habilitado = resolveHabilitado(type, mode, rr, elem, formul, equals)
                return habilitado
            case "visible":
                // Call Utility to resolve Visible
                let visible = resolveVisible(type, mode, rr, elem, formul, equals)
                return visible
            case "requerido":
                // Call Utility to resolve Requerido
                let requerido = resolveRequerido(type, mode, rr, elem, formul, equals)
                return requerido
            case "seleccionado":
                // Call Utility to resolve Requerido
                let seleccionado = resolveSeleccionado(type, mode, rr, elem, formul, equals)
                return seleccionado
            case "ejecuta":
                if (mode == "asignacion"){
                    self.ejecutaServicioMetodo(formul, elem)
                }else if (mode == "afirmacion") {
                    
                }
                break
            case "mensaje":
                let mensaje = resolveMensaje(type, mode, rr, elem, formul, equals, .info)
                return mensaje
            case "error":
                let mensaje = resolveMensaje(type, mode, rr, elem, formul, equals, .error)
                return mensaje
            case "alerta":
                let mensaje = resolveMensaje(type, mode, rr, elem, formul, equals, .warning)
                return mensaje
            case "agregarRegistro", "agregarRegistroYCerrar", "eliminarRegistro", "limpiarCampos":
                let permissions = resolveTablePermissions(type, mode, rr, elem, formul, equals)
                return permissions
            default:
                break;
            }
            
        }
        return ""
    }
    
}


// GENERIC FUNCTIONS
// MARK: - GENERIC FUNCTIONS
extension NuevaPlantillaViewController{
    
    public func getColoniasElement(_ sepomex: SepomexJson) -> SepoMexResult? {
        let sepomexNew = SepoMexResult()
        var sepomexDict: [[String: Any]]
        if let data =  sepomex.cp.data(using: .utf8){
            do {
                sepomexDict = (try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]])!
                let idcp = sepomexDict[0]["id"] as! String
                let valueCP = self.form.rowBy(tag: idcp) as! TextoRow
                sepomexNew.CodigoPostal = valueCP.value ?? ""
            } catch { return nil }
        }
        return sepomexNew
    }
    
    public func getLeyendaText(leyenda: String) -> String{
        var textoLeyenda = leyenda
        for formulario in forms{
            for rows in formulario.allRows{
                switch rows{
                case is TextoRow:
                    let base = rows as? TextoRow
                    if (rows as? TextoRow)?.cell.atributos != nil{
                        if textoLeyenda.contains("|||\(base?.cell.atributos?.idunico ?? "")|||"){
                            textoLeyenda = textoLeyenda.replacingOccurrences(of: "|||\(base?.cell.atributos?.idunico ?? "")|||", with: "\((rows as? TextoRow)?.cell.elemento.validacion.valor ?? "")")
                        }
                    }
                    //textoLeyenda = textoLeyenda
                    break
                case is TextoAreaRow:
                    let base = rows as? TextoAreaRow
                    if (rows as? TextoAreaRow)?.cell.atributos != nil{
                        if textoLeyenda.contains("|||\(base?.cell.atributos?.idunico ?? "")|||"){
                            textoLeyenda = textoLeyenda.replacingOccurrences(of: "|||\(base?.cell.atributos?.idunico ?? "")|||", with: "\((rows as? TextoAreaRow)?.cell.elemento.validacion.valor ?? "")")
                        }
                    }
                    break
                case is LogicoRow:
                    break
                case is FechaRow:

                    break
                case is ListaRow:
                    break
                case is ListaTemporalRow:
                    break
                case is ComboDinamicoRow:
                    break
                case is SliderNewRow:
                    let base = rows as? SliderNewRow
                    if (rows as? SliderNewRow)?.cell.atributos != nil{
                        if textoLeyenda.contains("|||\(base?.cell.atributos?.idunico ?? "")|||"){
                            textoLeyenda = textoLeyenda.replacingOccurrences(of: "|||\(base?.cell.atributos?.idunico ?? "")|||", with: "\((rows as? SliderNewRow)?.cell.elemento.validacion.valor ?? "")")
                        }
                    }
                    break
                case is MonedaRow:
                    let base = rows as? MonedaRow
                    if (rows as? MonedaRow)?.cell.atributos != nil{
                        if textoLeyenda.contains("|||\(base?.cell.atributos?.idunico ?? "")|||"){
                            textoLeyenda = textoLeyenda.replacingOccurrences(of: "|||\(base?.cell.atributos?.idunico ?? "")|||", with: "\((rows as? MonedaRow)?.cell.elemento.validacion.valor ?? "")")
                        }
                    }
                    break
                case is NumeroRow:
                    let base = rows as? NumeroRow
                    if (rows as? NumeroRow)?.cell.atributos != nil{
                        if textoLeyenda.contains("|||\(base?.cell.atributos?.idunico ?? "")|||"){
                            textoLeyenda = textoLeyenda.replacingOccurrences(of: "|||\(base?.cell.atributos?.idunico ?? "")|||", with: "\((rows as? NumeroRow)?.cell.elemento.validacion.valor ?? "")")
                        }
                    }
                    break
                case is RangoFechasRow:
                    let base = rows as? RangoFechasRow
                    if (rows as? RangoFechasRow)?.cell.atributos != nil{
                        if textoLeyenda.contains("|||\(base?.cell.atributos?.idunico ?? "")|||"){
                            textoLeyenda = textoLeyenda.replacingOccurrences(of: "|||\(base?.cell.atributos?.idunico ?? "")|||", with: "\((rows as? RangoFechasRow)?.cell.elemento.validacion.valor ?? "")")
                        }
                    }
                    break
                default:
                    break
                }
            }
        }
        return textoLeyenda
    }
    
    
    public func getImagesFromElement(_ compareFaces: CompareFacesJson) -> CompareFacesResult?{
        
        let compareFacesResult = CompareFacesResult()
        compareFacesResult.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
        compareFacesResult.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
        compareFacesResult.User = ConfigurationManager.shared.usuarioUIAppDelegate.User
        compareFacesResult.Provedor = compareFaces.proveedor
        
        var imageDict1: [[String: Any]]
        if let data =  compareFaces.imagen1.data(using: .utf8) {
            do {
                imageDict1 = (try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]])!
                let idImage1 = imageDict1[0]["id"] as! String
                let valueImage = (getElementById("\(idImage1)") as? ImagenRow)?.value
                if valueImage == nil{ return nil }
                
                if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(valueImage!)"){
                    let file = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(valueImage!)")
                    let anexoBase64 = file?.base64EncodedData()
                    let stringBase64 = String(data: anexoBase64!, encoding: String.Encoding.utf8) as String?
                    compareFacesResult.Rostro1 = stringBase64!
                }
            } catch { return nil }
        }
        
        var imageDict2: [[String: Any]]
        if let data =  compareFaces.imagen2.data(using: .utf8) {
            do {
                imageDict2 = (try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]])!
                let idImage2 = imageDict2[0]["id"] as? String ?? ""
                
                if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(idImage2)"){
                    let file = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(idImage2)")
                    let anexoBase64 = file?.base64EncodedData()
                    let stringBase64 = String(data: anexoBase64!, encoding: String.Encoding.utf8) as String?
                    compareFacesResult.Rostro2 = stringBase64!
                }
                
            } catch { return nil }
        }
        return compareFacesResult
    }
    
    // Rediseño de botones en elementos de acuerdo a propiedades en plantilla
    public func configButton(tipo : String, btnStyle : UIButton, nameIcono : String, titulo : String, colorFondo : String, colorTxt : String ) -> UIButton {
        var tittle: String = ""
        var tintColor: String = ""
        var backGround: String = ""
        let corner: Int = (tipo.contains("rectangulo") || tipo == "") ? 4 : 2
        
        switch tipo {
        case "circulofondo", "ovaloexternofondo", "rectanguloexternofondo":
            tintColor = colorTxt
            backGround = colorFondo
        case "circuloborde", "ovaloexternoborde", "rectanguloexternoborde":
            tintColor = colorTxt
            backGround = "#FFFFFF"
            btnStyle.layer.borderColor = UIColor(hexFromString: colorFondo).cgColor
            btnStyle.layer.borderWidth = 2.0
        case "ovalointernoborde","rectangulointernoborde":
            tittle = titulo
            tintColor = colorTxt
            backGround = "#FFFFFF"
            btnStyle.layer.borderColor = UIColor(hexFromString: colorFondo).cgColor
            btnStyle.layer.borderWidth = 2.0
        case "ovalointernofondo", "rectangulointernofondo":
            tittle = titulo
            tintColor = colorTxt
            backGround = colorFondo
        default:
            tittle = titulo
            tintColor = colorTxt
            backGround = colorFondo
        }
        
        let origImage = UIImage(named: nameIcono, in: Cnstnt.Path.framework, compatibleWith: nil)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        btnStyle.setTitle(tittle, for: .normal)
        btnStyle.setTitleColor(UIColor(hexFromString: tintColor), for: .normal)
        btnStyle.setImage(tintedImage, for: .normal)
        btnStyle.layer.cornerRadius = btnStyle.frame.height / CGFloat(corner)
        btnStyle.backgroundColor = UIColor(hexFromString: backGround)
        btnStyle.tintColor = UIColor(hexFromString: tintColor)
        btnStyle.layer.shadowOpacity = 1.0
        btnStyle.layer.shadowColor = UIColor.black.cgColor
        btnStyle.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        return btnStyle
    }
}

// SERVICIOS
// MARK: - SERVICIOS
extension NuevaPlantillaViewController{
    
    public func ejecutaServicioMetodo(_ elemento: [Formula], _ token: Formula) {
        let element = getElementANY(token.id)
        if(element.element != nil){
            switch element.type{
            case "servicio":
                guard let serviciorow: ServicioRow = element.kind as? ServicioRow else{
                    return
                }
                if let isServicio = serviciorow.cell.atributos?.tiposervicio {
                    ejecutaServicio(isServicio, serviciorow)
                }
                break
            case "metodo":
                guard let metodorow: MetodoRow = element.kind as? MetodoRow else{
                    return
                }
                if let isMetodo = metodorow.cell.atributos?.tipometodo {
                    ejecutaMetodo(isMetodo, metodorow)
                }
                break
            default:  break
            }
        }
    }
    
    public func ejecutaServicio(_ servicio: String, _ elementAny: Any)
    {
        guard let element: ServicioRow = elementAny as? ServicioRow else{
            return
        }
        let servicio = element.cell.atributos?.tiposervicio
        let entrada = element.cell.atributos?.parametrosentrada
        switch (servicio) {
        case "comparefaces":
            if entrada != ""{
                let atributos = CompareFacesJson(json: entrada)
                element.cell.setInstanceCompareFaces(atributos)
            }
            break
        case "ocrine":
            if entrada != ""{
                let atributos = OcrIneObject(json: entrada)
                element.cell.setInstanceOcrIne(atributos)
            }
            break
        case "ocrcfe":
            if entrada != ""{
                let atributos = OcrCfeObject(json: entrada)
                element.cell.setInstanceOcrCfe(atributos)
            }
            break;
        case "ocrpasaporte":
            if entrada != ""{
                let atributos = OcrPasaporteObject(json: entrada)
                element.cell.setInstanceOcrPasaporte(atributos)
            }
            break;
        case "folioautomatico":
            if entrada != ""{
                element.cell.setSOAPFolio("folioautomatico", entrada ?? "")
            }
            break
        case "sepomex":
            if entrada != ""{
                let atributos = SepomexJson(json: entrada)
                element.cell.setSepomex(atributos)
            }
            break
        default: break
        }
    }
    
    public func ejecutaMetodo(_ servicio: String, _ elementAny: Any)
    {
        guard let element: MetodoRow = elementAny as? MetodoRow else{
            return
        }
        let _ = element.cell.atributos?.tipometodo
        let entrada = element.cell.atributos?.parametrosentrada
        
        switch (servicio) {
        case "separarfecha":
            if entrada != nil {
                let atributos = FechaResult(json: entrada)
                element.cell.setFecha(atributos)
            }
            break;
        default:
            break
        }
    }
    
    public func detectValidation(elem: Elemento, route: String)->[String]?{
        if elem.elementos != nil {
            if elem.elementos?.elemento.count == 0{ return nil }
            var arrayObject = [String]()
            for e in (elem.elementos?.elemento)!{
                let rlt = detectValidation(elem: e, route: "\(route)|\(e._idelemento)")
                if rlt == nil{ continue }
                for r in rlt!{ arrayObject.append(r) }
            }
            return arrayObject
        }else{
            if elem.validacion.visible{
                if elem.validacion.needsValidation && elem.validacion.validado == false { return ["\(elem._idelemento)"] }
            }
        }
        return nil
    }
    
    public func setTablaDataAttributes(valor l: String, metadato m:String, idunico i:String, titulo t: String) -> NSMutableDictionary{
        let prod: NSMutableDictionary = NSMutableDictionary(); prod.setValue(l, forKey: "valor"); prod.setValue(m, forKey: "valormetadato"); prod.setValue(i, forKey: "idunico"); prod.setValue(t, forKey: "titulo");
        return prod
    }
    
    public func setDataAttributes(valor l:String, metadato m:String, habilitado h:Bool, visible v:Bool) -> NSMutableDictionary{
        let prod: NSMutableDictionary = NSMutableDictionary(); prod.setValue(l, forKey: "valor"); prod.setValue(m, forKey: "valormetadato");
        return prod
    }
    
    public func setComboboxTempAttributes(valor l:String, metadato m:String, idunico i:String, catalogoDestino cd:String) -> NSMutableDictionary{
        let prod: NSMutableDictionary = NSMutableDictionary(); prod.setValue(l, forKey: "valor"); prod.setValue(m, forKey: "valormetadato"); prod.setValue(cd, forKey: "catalogodestino"); prod.setValue(i, forKey: "idunico");
        return prod
    }
    
    public func setDataDocAttributes(valor l:String, metadato m:String, habilitado h:Bool, visible v:Bool) -> NSMutableDictionary{
        let prod: NSMutableDictionary = NSMutableDictionary(); prod.setValue(l, forKey: "tipodoc"); prod.setValue(m, forKey: "metadatostipodoc");prod.setValue(l, forKey: "valor"); prod.setValue(l, forKey: "valormetadato");
        return prod
    }
    public func setDataDateRangeAttributes(valor l:String, metadato m:String, metadatoF mf:String, metadatoI mi:String, metadatoR mr:String, visible v:Bool) -> NSMutableDictionary{
        let prod: NSMutableDictionary = NSMutableDictionary(); prod.setValue(mf, forKey: "valormetadatofinal"); prod.setValue(mi, forKey: "valormetadatoinicial");prod.setValue(l, forKey: "valor"); prod.setValue(m, forKey: "valormetadato");prod.setValue(mr, forKey: "valormetadatorango");
        return prod
    }
    public func setDataFirmaFadAttributes(valor l:String, metadato m:String, hash h:String, guidtimestamp g:String, catalogoID c: String, descripcion d: String, georeferencia ge: String, fecha f: String, personafirma pf: String, acuerdofirma af: String, dispositivo dv: String) -> NSMutableDictionary{
        let prod: NSMutableDictionary = NSMutableDictionary(); prod.setValue(h, forKey: "hash"); prod.setValue(g, forKey: "guidtimestamp");prod.setValue(l, forKey: "valor"); prod.setValue(m, forKey: "valormetadato"); prod.setValue("\(c)", forKey: "tipodoc"); prod.setValue(d, forKey: "Descripcion"); prod.setValue(ge, forKey: "georeferencia"); prod.setValue(f, forKey: "fecha"); prod.setValue(pf, forKey: "nombrefirmante"); prod.setValue(af, forKey: "acuerdofirma"); prod.setValue(dv, forKey: "dispositivo");
        return prod
    }
    
    public func setDataAttachmentAttributes(tipoDoc t:String, docId d:String) -> NSMutableDictionary{
        let prod: NSMutableDictionary = NSMutableDictionary(); prod.setValue(t, forKey: "tipodoc"); prod.setValue(d, forKey: "docid");
        return prod
    }
    
    public func setDataAttachmentValorAttributes(valor l:String, metadato m:String, tipoDoc t:String, docId d:String) -> NSMutableDictionary{
        let prod: NSMutableDictionary = NSMutableDictionary(); prod.setValue(l, forKey: "valor"); prod.setValue(m, forKey: "valormetadato"); prod.setValue(t, forKey: "tipodoc"); prod.setValue(d, forKey: "docid");
        return prod
    }
    
    public func setDataFingerAttachmentAttributes(tipodoc c: String, docid d: String, cantidad t: String, score s: String, scorehuellas sh: String, reemplazo r: String,  valor l:String, metadato m:String, visible v:Bool, habilitado h:Bool) -> NSMutableDictionary{
        let prod: NSMutableDictionary = NSMutableDictionary(); prod.setValue(c, forKey: "tipodoc"); prod.setValue(d, forKey: "docid"); prod.setValue(t, forKey: "cantidadhuellas"); prod.setValue(s, forKey: "scorepromedio"); prod.setValue(sh, forKey: "scorehuellas"); prod.setValue(r, forKey: "isreemplazohuella");
        return prod
    }
    
    func detectValue(elem: Elemento, isPrellenado: Bool){
        if !isPrellenado{
            
            // Detecting if has attachments
            if elem.validacion.anexos != nil, elem.validacion.anexos?.count ?? 0 > 0{
                for elemAnexo in elem.validacion.anexos!{
                    if elemAnexo.id != "", elemAnexo.id == "reemplazo"{
                        elem.validacion.validado = true
                        elem.validacion.valor = elemAnexo.url
                        if self.currentAnexos.count > 0{
                            for anx in self.currentAnexos{
                                if anx.ElementoId == elem._idelemento{
                                    anx.Editado = false; self.currentAnexos.append(anx);
                                }
                            }
                        }
                    }
                    
                    if elemAnexo.id != "", elemAnexo.id != "reemplazo" {
                        var founded: Bool = false
                        for (_,anx) in self.currentAnexos.enumerated() {
                            if anx.FileName == elemAnexo.url{
                                founded = true
                            }
                        }
                        if founded{ continue }
                        let anexo = FEAnexoData()
                        anexo.Guid = ConfigurationManager.shared.guid
                        anexo.FileName = elemAnexo.url
                        anexo.ElementoId = elem._idelemento
                        let row = self.getElementByIdInAllForms("\(elem._idelemento)")
                        switch elem._tipoelemento{
                        case "huelladigital":
                            anexo.Extension = ".WSQ";
                            break;
                        case "audio":
                            let audioCell = (row as? AudioRow)?.cell
                            if audioCell != nil  && audioCell?.idAnexoReemp != -1 {
                                anexo.isReemplazo = audioCell?.idAnexoReemp == audioCell?.feanexo?.DocID ? true : false
                                if anexo.isReemplazo { anexo.DocID = audioCell!.idAnexoReemp}
                            }
                            anexo.Extension = ".MP3";
                            break;
                        case "video":
                            anexo.Extension = ".MP4";
                            break;
                        case "georeferencia":
                            anexo.Extension = ".PNG"
                            break;
                        case "firmafad":
                            let fadCell = (row as? FirmaFadRow)?.cell
                            if fadCell != nil  && (fadCell?.anexoReemp != nil) {
                                anexo.isReemplazo = (fadCell?.anexoReemp?.DocID ?? 0) == fadCell?.fedocumento.DocID ? true : false
                                if anexo.isReemplazo { anexo.DocID = fadCell?.fedocumento.DocID ?? 0 }
                            }
                            anexo.Extension = ".PNG";
                            break;
                        case "documento":
                            let docCell = (row as? DocumentoRow)?.cell
                            if docCell != nil  && (docCell?.arrayAnexosReemp.count)! > 0{
                                anexo.isReemplazo = ((docCell?.arrayAnexosReemp.contains(where: {$0.key == Int(elemAnexo.id)})) != nil)
                                if anexo.isReemplazo
                                {
                                    anexo.DocID = docCell?.fedocumentos[Int(elemAnexo.id) ?? -1].DocID ?? 0
                                    anexo.Extension = ".\(docCell?.fedocumentos[Int(elemAnexo.id) ?? -1 ].Ext ?? "")".uppercased()
                                }
                            }
                            let tipoDocID = NSMutableDictionary(json: docCell?.tipodoc ?? "")
                            tipoDocID.allKeys.forEach({ keytip in
                                if anexo.FileName.contains((keytip as! String)) {
                                    anexo.TipoDocID = Int (tipoDocID.value(forKey: keytip as! String) as! String) ?? 0
                                    anexo.GuidAnexo = (keytip as! String)
                                }
                            })
                            if docCell != nil {
                                for (_, an) in docCell!.fedocumentos.enumerated(){
                                    if an.URL == anexo.FileName{
                                        anexo.Extension = ".\(an.Ext)".uppercased()
                                    }
                                }
                            }
                            break;
                        case "imagen":
                            let imagenCell = (row as? ImagenRow)?.cell
                            if imagenCell != nil  && imagenCell?.anexoReemp != nil {
                                anexo.isReemplazo = (imagenCell?.anexoReemp?.DocID ?? 0) == imagenCell?.fedocumento.DocID ? true : false
                                if anexo.isReemplazo { anexo.DocID = imagenCell?.anexoReemp?.DocID ?? 0 }
                            }
                            anexo.Extension = ".PNG";
                            break;
                            //Aqui es donde se da extesiones a los Anexos que se tienen mapeados por medio de los elementos tipo cell
                        case "pdfocr":
                            let imagenCell = (row as? DocFormRow)?.cell
                            if imagenCell != nil  && imagenCell?.anexoReemp != nil {
                                anexo.isReemplazo = (imagenCell?.anexoReemp?.DocID ?? 0) == imagenCell?.fedocumento.DocID ? true : false
                                if anexo.isReemplazo { anexo.DocID = imagenCell?.anexoReemp?.DocID ?? 0 }
                            }
                            anexo.Extension = ".PDF";
                        default:
                            anexo.Extension = ".PNG"; break;
                        }
                        anexo.Editado = true
                        anexo.ExpID = self.formatoData.ExpID
                        self.currentAnexos.append(anexo)
                        
                    }
                }
                self.setMetaAttributes(elem, isPrellenado)
                return
            }
            self.setMetaAttributes(elem, isPrellenado); return;
        }else{
            self.setMetaAttributes(elem, isPrellenado); return;
        }
    }
    
    public func setTipoDoc(_ e: Elemento) -> Int  {
        let tipoElemento = TipoElemento(rawValue: "\(e._tipoelemento)") ?? TipoElemento.other
        switch tipoElemento {
        case .eventos, .plantilla, .pagina, .seccion: return 0;
        case .boton, .codigobarras, .codigoqr, .comboboxtemporal, .deslizante, .espacio, .fecha, .hora, .leyenda, .lista, .logico, .logo, .moneda, .nfc, .numero, .password, .rangofechas, .semaforotiempo, .tabber, .tabla, .texto, .textarea, .wizard, .marcadodocumentos: return 0;
        case .combodinamico: return 0;
        case .metodo, .servicio: return 0;
        case .audio, .voz: return (e.atributos as? Atributos_audio)?.tipodoc ?? 0;
        case .calculadora: return 0;
        case .firma: return (e.atributos as? Atributos_firma)?.tipodoc ?? 0;
        case .firmafad: return Int((e.atributos as? Atributos_firmafad)?.tipodoc ?? "0") ?? 0;
        case .georeferencia: return Int( (e.atributos as? Atributos_georeferencia)?.tipodoc ?? 0) ;
        case .imagen: return (e.atributos as? Atributos_imagen)?.tipodoc ?? 0;
        case .mapa: return (e.atributos as? Atributos_mapa)?.tipodoc ?? 0;
        case .video: return (e.atributos as? Atributos_video)?.tipodoc ?? 0;
        case .videollamada: return 0;
        case .huelladigital: return (e.atributos as? Atributos_huelladigital)?.tipodoc ?? 0;
        case .rostrovivo, .capturafacial: return (e.atributos as? Atributos_rostrovivo)?.tipodoc ?? 0;
        case .documento: return (e.atributos as? Atributos_documento)?.tipodoc ?? 0;
        case .veridasdocumentcapture, .veridasvideoselfie, .veridasphotoselfie: return 0  ;
        case .ocr: return 0 ;
        case .jumio: return 0;
        case .other: return 0;
        @unknown default:
            return 0
        }
    }
    
    public func setMetaAttributes(_ e: Elemento, _ isPrellenado: Bool){
        let tipoElemento = TipoElemento(rawValue: "\(e._tipoelemento)") ?? TipoElemento.other
        
        switch tipoElemento {
        
        case .eventos: break;
        case .plantilla:
            // We need to detect if the values are not empty
            if valueRuleCoor != ""{
                self.ElementosArray.setValue(setDataAttributes(valor: "\(valueRuleCoor)", metadato: "\(valueRuleCoor)", habilitado: true, visible: true), forKey: "\(e._idelemento)")
            }
            break;
        case .pagina, .seccion: break;
        case .boton: break;
        case .comboboxtemporal:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setComboboxTempAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: "", catalogoDestino: e.validacion.catalogoDestino), forKey: "\(e._idelemento)")
                }
            }
            break;
        case .nfc: break;
        case .codigoqr:
            if plist.idportal.rawValue.dataI() >= 39 {
                if !isPrellenado{
                    if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                        self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                    }
                }
            }
            break;
        case .codigobarras, .deslizante:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }
            break;
        case .espacio: break;
        case .fecha:
            let atr = e.atributos as! Atributos_fecha
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }else{
                for field in atr.elementoprellenadoexterno{
                    let exElement = field.replacingOccurrences(of: "\(self.plantillamapear)_", with: "")
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(exElement)")
                }
            }
            break;
        case .hora:
            let atr = e.atributos as! Atributos_hora
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }else{
                for field in atr.elementoprellenadoexterno{
                    let exElement = field.replacingOccurrences(of: "\(self.plantillamapear)_", with: "")
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(exElement)")
                }
            }
            break;
        case .leyenda: break;
        case .lista:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                    
                }
            }
            break;
        case .logico:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                    
                }
            }
            break;
        case .marcadodocumentos:
            if plist.idportal.rawValue.dataI() >= 41 {
                if !isPrellenado{
                    if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                        self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                    }
                }
            }
            break;
        case .combodinamico:
            if plist.idportal.rawValue.dataI() >= 40 {
                if !isPrellenado{
                    if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                        self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                    }
                }
            }
            break;
        case .logo: break;
        case .moneda:
            let atr = e.atributos as! Atributos_moneda
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }else{
                for field in atr.elementoprellenadoexterno{
                    let exElement = field.replacingOccurrences(of: "\(self.plantillamapear)_", with: "")
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(exElement)")
                }
            }
            break;
        case .numero:
            let atr = e.atributos as! Atributos_numero
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }else{
                for field in atr.elementoprellenadoexterno{
                    let exElement = field.replacingOccurrences(of: "\(self.plantillamapear)_", with: "")
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(exElement)")
                }
            }
            break;
        case .password:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }
            break;
        case .rangofechas:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadatorango != ""{
                    //self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                    self.ElementosArray.setValue(setDataDateRangeAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, metadatoF: e.validacion.valormetadatofinal, metadatoI: e.validacion.valormetadatoinicial, metadatoR: e.validacion.valormetadatorango, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }
            break;
        case .semaforotiempo, .tabber: break;
        case .tabla:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valor, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }
            break;
        case .texto:
            let atr = e.atributos as! Atributos_texto
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }else{
                for field in atr.elementoprellenadoexterno{
                    let exElement = field.replacingOccurrences(of: "\(self.plantillamapear)_", with: "")
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(exElement)")
                }
            }
            break;
        case .textarea:
            let atr = e.atributos as! Atributos_textarea
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }else{
                for field in atr.elementoprellenadoexterno{
                    let exElement = field.replacingOccurrences(of: "\(self.plantillamapear)_", with: "")
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(exElement)")
                }
            }
            break;
        case .imagen:
            if !isPrellenado{
                self.ElementosArray.setValue(setDataAttachmentAttributes(tipoDoc: e.validacion.tipodoc, docId: e.validacion.docid), forKey: "\(e._idelemento)")
            }
            break;
        case .pdfocr:
            if !isPrellenado {
                self.ElementosArray.setValue(setDataAttachmentAttributes(tipoDoc: e.validacion.tipodoc, docId: e.validacion.docid), forKey: "\(e._idelemento)")
            }
            break;
        case .georeferencia, .mapa:
            if !isPrellenado{
                self.ElementosArray.setValue(setDataAttachmentValorAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, tipoDoc: e.validacion.tipodoc, docId: e.validacion.docid), forKey: "\(e._idelemento)")
            }
            break
        case .wizard, .metodo, .servicio: break;
        case .video, .videollamada, .audio, .voz:
            if !isPrellenado{
                self.ElementosArray.setValue(setDataAttachmentAttributes(tipoDoc: e.validacion.tipodoc, docId: e.validacion.docid), forKey: "\(e._idelemento)")
            }
            break
        case .calculadora:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }
            break;
        case .huelladigital:
            if !isPrellenado{
                if e.validacion.valor != ""{
                    self.ElementosArray.setValue(setDataFingerAttachmentAttributes(tipodoc: e.validacion.tipodoc, docid: e.validacion.docid, cantidad: e.validacion.cantidadhuellas, score: e.validacion.scorepromedio, scorehuellas: e.validacion.scorehuellas, reemplazo: e.validacion.isreemplazohuella, valor: "", metadato: "", visible: e.validacion.visible, habilitado: e.validacion.habilitado), forKey: "\(e._idelemento)")
                }
            }
            break;
        case .rostrovivo, .capturafacial:
            if !isPrellenado{
                self.ElementosArray.setValue(setDataAttachmentAttributes(tipoDoc: e.validacion.tipodoc, docId: e.validacion.docid), forKey: "\(e._idelemento)")
            }
            break;
        case .firma:
            if !isPrellenado{
                self.ElementosArray.setValue(setDataAttachmentAttributes(tipoDoc: e.validacion.tipodoc, docId: e.validacion.docid), forKey: "\(e._idelemento)")
            }
            break
        case .firmafad:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != "" && e.validacion.attData != nil{
                    self.ElementosArray.setValue(setDataFirmaFadAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, hash: e.validacion.hashFad, guidtimestamp: e.validacion.guidtimestamp, catalogoID: e.validacion.tipodoc, descripcion: e.validacion.attData?[1].descripcion ?? "", georeferencia: e.validacion.georeferencia, fecha: e.validacion.fecha, personafirma: e.validacion.personafirma, acuerdofirma: e.validacion.acuerdofirma, dispositivo: e.validacion.dispositivo), forKey: "\(e._idelemento)")
                } else {
                    if e.validacion.dispositivo != ""
                    {
                        self.ElementosArray.setValue(setDataFirmaFadAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, hash: e.validacion.hashFad, guidtimestamp: e.validacion.guidtimestamp, catalogoID: "0", descripcion: "", georeferencia: e.validacion.georeferencia, fecha: e.validacion.fecha, personafirma: e.validacion.personafirma, acuerdofirma: e.validacion.acuerdofirma, dispositivo: e.validacion.dispositivo), forKey: "\(e._idelemento)")
                    }
                }
            }
            break;
        case .documento:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataDocAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }
            break;
        case .veridasdocumentcapture, .veridasvideoselfie, .veridasphotoselfie: break ;
        case .ocr:
            if !isPrellenado{
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataDocAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }
            break;
        case .jumio:
            if !isPrellenado {
                if e.validacion.valor != "" && e.validacion.valormetadato != ""{
                    self.ElementosArray.setValue(setDataDocAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, habilitado: e.validacion.habilitado, visible: e.validacion.visible), forKey: "\(e._idelemento)")
                }
            }
            break;
        case .other: break;
        }
    }
}

extension NuevaPlantillaViewController: RequestSuccessControllerDelegate{
    public func didTapSave() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            if !(self.flagSave ?? false){
                self.hud.dismiss(animated: true)
                if self.formatoFlag{
                    self.openPlantillaCot(pla: self.plaCot, formato: self.formatoCot)
                }else{
                    self.closeViewController(status: 200)
                }
                
            }else{
                self.setStatusBarNotificationBanner("hud_save".langlocalized(),  .info, .bottom)
            }
            self.sdkAPI = nil; self.formActions = nil; self.elemtVDDocument = nil; self.navigation = nil; self.valuesArray = nil; self.filtrosArray = nil; self.xmlParsed = Elemento(); self.xmlAEXML = AEXMLDocument(); self.arrayPlantillaData = FEPlantillaData(); self.formatoData = FEFormatoData(); self.currentAnexos = [FEAnexoData](); self.atributosPlantilla = nil; self.templateDelegate = nil
        }
        
    }
}

extension NuevaPlantillaViewController: SaveRequestScreenControllerDelegate{
    public func didTapAccept() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            if self.flagBio{
                self.formatoData.EstadoApp = 1
                self.formatoData.Editado = true
                self.setValuesToObject(accion: actionForm.borrador)
                FormularioUtilities.shared.globalFlujo = self.formatoData.FlujoID
                FormularioUtilities.shared.globalProceso = 0
                self.hud.dismiss(animated: true)
            }
            if !(self.flagSave ?? false){
                self.hud.dismiss(animated: true)
                self.closeViewController(status: 200)
            }else{
                self.setStatusBarNotificationBanner("hud_save".langlocalized(),  .info, .bottom)
            }
            self.sdkAPI = nil; self.formActions = nil; self.elemtVDDocument = nil; self.navigation = nil; self.valuesArray = nil; self.filtrosArray = nil; self.xmlParsed = Elemento(); self.xmlAEXML = AEXMLDocument(); self.arrayPlantillaData = FEPlantillaData(); self.formatoData = FEFormatoData(); self.currentAnexos = [FEAnexoData](); self.atributosPlantilla = nil; self.templateDelegate = nil
        }
    }
    
}

//MARK: Macros
extension NuevaPlantillaViewController {
    enum Action: String {
        case escribirTexto = "fillt"
        #warning("Estan al reves fecha y hora desde web.")
        case escribirFecha = "fillh"
        case escribirHora = "fillf"
        case clickBoton = "clickb"
        case clickWizard = "clickw"
        case marcarCheck = "check"
        case escribirNumero = "filln"
        case agregarImagen = "upimg"
        case agregarArchivo = "upfile"
    }
    
    public struct Macro {
        var name: String
        var steps: [MacroStep]
        
        struct MacroStep {
            var enabled: Bool
            var action: Action
            var who: String
            var what: String
        }
    }
    //Obtiene lo que llega en atributos de la plantilla: <macros> y los parsea a la estructura:
    //Llamamos a este metodo despues de obtener los atributos de la plantilla:
    fileprivate func parseMacros(_ macros: AEXMLElement) {
        var plantillaMacros: [Macro] = []
        for macro in macros.children {
            let macroName = macro["name"].value
    
            let allSteps = macro.allDescendants { element in
                return element.name == "steps"
            }
            var macroSteps: [Macro.MacroStep] = []
            for stp in allSteps {
                let enabled = stp["enabled"].value == "true" ? true : false
                let action = Action(rawValue: stp["action"].value ?? "fillt") ?? Action.escribirTexto
                let who = stp["who"].value ?? ""
                let what = stp["what"].value ?? ""
                let step = Macro.MacroStep(enabled: enabled, action: action, who: who, what: what)
                macroSteps.append(step)
            }
            plantillaMacros.append(Macro(name: macroName ?? "", steps: macroSteps))
        }
        self.macros = plantillaMacros
    }
    
    //DispatchAsync? Semaphores?
    @objc private func executeMacros() {
        if self.macros.count > 0 {
            for macro in self.macros {
                for step in macro.steps {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if step.enabled {
                            self.performMacroAction(id: step.who, action: step.action, valor: step.what)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func performMacroAction(id elementoID: String, action: Action, valor: String ) {
        let element = getElementById(elementoID)
        switch action {
        case .escribirTexto:
            if let row = element as? TextoRow {
                row.cell.setEdited(v: valor)
                row.cell.updateIfIsValid()
            } else if let row = element as? TextoAreaRow {
                row.cell.setEdited(v: valor)
                row.cell.updateIfIsValid()
            }
        case .escribirFecha:
            if let row = element as? FechaRow {
                let formato = row.cell.formato
                row.cell.setEditedFecha(v: valor, format: formato)
                row.cell.updateIfIsValid()
            }
        case .escribirHora:
            
            if let row = element as? FechaRow {
                row.cell.setEditedHora(v: valor)
                row.cell.updateIfIsValid()
            }
        case .clickBoton:
            if let row = element as? BotonRow {
                row.cell.botonAction(UIButton())
            }
        case .clickWizard:
            if let row = element as? WizardRow {
                switch valor {
                case "finish":
                    row.cell.finalizarBtnAction(UIButton())
                    break
                case "forward":
                    row.cell.avanzarBtnAction(UIButton())
                    break
                case "backward":
                    row.cell.regresarBtnAction(UIButton())
                    break
                default:
                    break
                }
            }
        case .marcarCheck:
            if let row = element as? LogicoRow {
                row.cell.valueChanged()
                row.cell.updateIfIsValid()
            }
            break
        case .escribirNumero:
            if let row = element as? NumeroRow {
                row.cell.setEdited(v: valor)
                row.cell.updateIfIsValid()
            }
        case .agregarImagen:
            //TODO:
            print(valor)
            break
        case .agregarArchivo:
            //TODO:
            print(valor)
            break
        }
    }
}

extension UITableView {
    func indexPathExists(indexPath:IndexPath) -> Bool {
        if indexPath.section >= self.numberOfSections {
            return false
        }
        if indexPath.row >= self.numberOfRows(inSection: indexPath.section) {
            return false
        }
        return true
    }
}
