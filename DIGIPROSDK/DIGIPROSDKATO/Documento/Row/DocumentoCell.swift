import Foundation
import AVFoundation
import MobileCoreServices
import Eureka
import PDFKit
import UIKit
import SafariServices

class DocumentDetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgDetailDoc: UIImageView!
    @IBOutlet weak var lblNameFile: UILabel!
    @IBOutlet weak var btnImportReemp: UIButton!
    @IBOutlet weak var btnCamaraReemp: UIButton!
    @IBOutlet weak var btnCancelReemp: UIButton!
    @IBOutlet weak var imgValidate: UIImageView!
    @IBOutlet weak var btnMeta: UIButton!
    @IBOutlet weak var btnPreviewAne: UIButton!
    @IBOutlet weak var btnClean: UIButton!
    @IBOutlet weak var lblTypeDoc: UILabel!
    @IBOutlet weak var btnTypeDoc: UIButton!
    @IBOutlet weak var tblMetaData: UIStackView!
    @IBOutlet weak var lblNumAne: UILabel!
    @IBOutlet weak var widthCell: NSLayoutConstraint!
    @IBOutlet weak var heightMetaData: NSLayoutConstraint!
    //@IBOutlet weak var tapLabel: UILabel!
    
    static let identifier = "DocCell"
    override func awakeFromNib() {
        super.awakeFromNib();
        
        self.contentView.backgroundColor = .white
        self.imgValidate.isHidden = true
        self.imgValidate.layer.cornerRadius = self.imgValidate.frame.height / 2
        
        self.btnMeta.layer.cornerRadius = 7.0
        self.btnMeta.backgroundColor = UIColor(hexFromString: "#008EC1")
        self.btnMeta.setImage(UIImage(named: "ic_editarMeta", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        self.btnMeta.setTitle(" Editar", for: .normal)
        
        self.btnPreviewAne.layer.cornerRadius = self.btnPreviewAne.frame.height / 2
        self.btnPreviewAne.backgroundColor = UIColor(hexFromString: "#1E88E5")
        self.btnPreviewAne.setImage(UIImage(named: "ic_eye", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        self.btnClean.layer.cornerRadius = 7.0//self.btnClean.frame.height / 2
        self.btnClean.backgroundColor = UIColor(hexFromString: "#008EC1")
        self.btnClean.setImage(UIImage(named: "ic_cleanMeta", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        self.btnClean.setTitle("Eliminar", for: .normal)
        
        self.btnImportReemp.layer.cornerRadius = 7.0//self.btnImportReemp.frame.height / 2
        self.btnImportReemp.backgroundColor = UIColor(hexFromString: "#1E88E5")
        self.btnImportReemp.setImage(UIImage(named: "ic_mergeDoc", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        self.btnImportReemp.setTitle("Sustituir", for: .normal)
        
        self.btnCamaraReemp.layer.cornerRadius = self.btnCamaraReemp.frame.height / 2
        self.btnCamaraReemp.backgroundColor = UIColor.brown//(hexFromString: "#1E88E5")
        self.btnCamaraReemp.setImage(UIImage(named: "ic_photo", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        self.btnCancelReemp.layer.cornerRadius = 7.0//self.btnCancelReemp.frame.height / 2
        self.btnCancelReemp.backgroundColor = UIColor(hexFromString: "#008EC1")
        self.btnCancelReemp.setImage(UIImage(named: "ic_undoDoc", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        self.btnCancelReemp.setTitle("Deshacer", for: .normal)
        
        self.lblTypeDoc.text = " Tipo de documento: "
        //self.tapLabel.layer.cornerRadius = 8.0
        
        self.btnTypeDoc.backgroundColor = UIColor.clear
        self.btnTypeDoc.setTitle(" Seleccione...      ", for: .normal)
        self.btnTypeDoc.setImage(UIImage(named: "ic_arrowDown", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
//        watchHistory.backgroundColor = UIColor.clear
//        watchHistory.layer.cornerRadius = 7.0
//        watchHistory.setTitle("Historial", for: .normal)
//        watchHistory.setTitleColor(UIColor.black, for: UIControl.State.normal)
        //watchHistory.setImage(UIImage(named: "ic_mergeDoc", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - 1.0, width: UIScreen.main.bounds.width, height: 1.0)
        border.backgroundColor = UIColor.black.cgColor
        self.btnTypeDoc.layer.addSublayer(border)
        
        self.tblMetaData.isHidden = true
    }
    
}

open class DocumentoCell: Cell<String>, CellType, APIDelegate, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // IBOUTLETS
    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var btnActions: UIButton!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var vwEffectMetaTbl: UIVisualEffectView!
    @IBOutlet weak var metaBtnCancel: UIButton!
    @IBOutlet weak var metaBtnGuardar: UIButton!
    @IBOutlet weak var lblTipoDoc: UILabel!
    @IBOutlet weak var documentType: UIPickerView!
    @IBOutlet weak var metaDataTableView: UITableView!
    @IBOutlet weak var metaBtnRedo: UIButton!
    @IBOutlet weak var bgHabilitado: UIView!
    
    // MetaAttributes TableView
    @IBOutlet weak var heightCollectionMeta: NSLayoutConstraint!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var elemento = Elemento()
    public var atributos: Atributos_documento!
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var isMarcado: String = ""
    public var metaDatosDictionary = [String:String]()
    // Anexos
    public var fedocumentos: [FEDocumento] = [FEDocumento]()
    public var anexosDict: [(id: String, url: String)] = []
    public var tipodoc: String = "" // aux en nueva plantilla saveAnexos, es = elemento.validación.valor
    public var arrayAnexosReemp = [(key: Int, value: FEDocumento)]()
    // Tipificación
    public var listAllowed: [FEListTipoDoc] = []
    public var tipUnica: Int?
    public var flagEdit: Bool = false
    public var estiloBotones: String = ""
    
    // PRIVATE
    var sdkAPI : APIManager<DocumentoCell>?
    var btnPreview = UIButton() // Global - elem inhabilitado
    var tamSinAnexos: CGFloat = 0.0
    var tamConAnexos: CGFloat = 0.0
    var tamMaxMeta: CGFloat = 0.0
    var porDescargar = false
    
    // metadatos
    var arrayMetadatos: [FEListMetadatosHijos] = []
    var metadatosFEDocumentos: [Int : [FEListMetadatosHijos]] = [:]
    var metaDIC: NSMutableDictionary = NSMutableDictionary();
    var metaReq: NSMutableDictionary = NSMutableDictionary();
    var docID: Int = 0 // aux para saber idTipificación en consulta de metadatos
    var listaInMeta = false
    var dataListaInMeta : Array<FEItemCatalogo> = [FEItemCatalogo]()
    var clearMeta = false
    var flagRem: Bool = false
    
    // anexos
    var maxTipUnica: String = "0"
    var anexosRecup:  [FEAnexoData]? //OK
    var idAnexoReemp: Int = -1
    var startReemp : Bool = false
    var okUnico = false
    let flowLayout = ZoomAndSnapFlowLayout()
    
    var indexClic : Int = -1 // bnd para saber quien abrio los metadatos
    var indexPathTableView: IndexPath? // bnd de index en lista tipificación
    var indextableview: Int = 0 // bnd index campo en View Metadatos
    
    var extensionsDictionary: Dictionary<String, String> = ["BMP": String(kUTTypeBMP), "doc":"com.microsoft.word.doc", "docx": "org.openxmlformats.wordprocessingml.document", "GIF": String(kUTTypeGIF), "JPEG": String(kUTTypeJPEG), "JPG": String(kUTTypeJPEG), "mp3": String(kUTTypeMP3), "mp4": String(kUTTypeMPEG4), "PDF": String(kUTTypePDF), "PNG": String(kUTTypePNG), "xml": String(kUTTypeXML), "ppt": "public.presentation", "pptx": "org.openxmlformats.presentationml.presentation", "TIF": String(kUTTypeTIFF), "TIFF": String(kUTTypeTIFF), "wma": "com.microsoft.advanced-systems-format", "xls": "com.microsoft.excel.xls", "xlsm": "org.openxmlformats.spreadsheetml.sheet.macroenabled", "xlsx": "org.openxmlformats.spreadsheetml.sheet", "msg":"", "webm":"", "WSQ":""]
    
    let extensionsDocs: [String] = [String(kUTTypePNG), String(kUTTypeJPEG), String(kUTTypePDF), String(kUTTypeBMP), String(kUTTypeGIF), String(kUTTypeMP3), String(kUTTypeMPEG4), String(kUTTypeTIFF), String(kUTTypeWebArchive), String(kUTTypeXML), String("org.openxmlformats.wordprocessingml.document"), String("com.microsoft.word.doc"), String("org.openxmlformats.spreadsheetml.sheet"), String("com.microsoft.excel.xls"), String("org.openxmlformats.presentationml.presentation"), String("public.presentation"), String("com.microsoft.advanced-systems-format"), String(kUTTypePlainText), String(kUTTypeQuickTimeMovie), String("org.openxmlformats.spreadsheetml.sheet.macroenabled"), String("org.oasis-open.opendocument")]
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
        (row as? DocumentoRow)?.presentationMode = nil
    }
    
    // MARK: SETTING
    /// SetObject for DocumentoRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_documento
        
        self.elemento.validacion.idunico = atributos?.idunico ?? ""
        initRules()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        if atributos?.maximodocumentos == 0 { atributos?.maximodocumentos = 99 }
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? DocumentoRow)?.cell.formCell()?.formViewController()?.tableView
        self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false)
        self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
        
        self.headersView.translatesAutoresizingMaskIntoConstraints = false
        self.headersView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        self.headersView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.headersView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        
        self.headersView.setNeedsLayout()
        self.headersView.layoutIfNeeded()
        
        self.btnActions.translatesAutoresizingMaskIntoConstraints = false
        self.btnActions.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -15).isActive = true
        self.btnActions.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.btnActions.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        self.btnActions = self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnActions, nameIcono: "", titulo: "Agregar documento", colorFondo: atributos?.colortomarfoto ?? "#008EC1", colorTxt: atributos?.colortextotomarfoto ?? "#FFFFFF")
        self.btnActions.setImage(UIImage(named: "ic_noteAdd", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        self.detailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.detailCollectionView.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 10).isActive = true
        self.detailCollectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 50).isActive = true
        self.detailCollectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -50).isActive = true
        self.detailCollectionView.bottomAnchor.constraint(equalTo: self.btnActions.topAnchor, constant: -5).isActive = true
        self.detailCollectionView.delegate = self
        self.detailCollectionView.dataSource = self
        
        self.imagePreview.translatesAutoresizingMaskIntoConstraints = false
        self.imagePreview.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 5).isActive = true
        self.imagePreview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 75).isActive = true
        self.imagePreview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -75).isActive = true
        self.imagePreview.heightAnchor.constraint(equalToConstant: 250.0).isActive = true
        
        self.vwEffectMetaTbl.translatesAutoresizingMaskIntoConstraints = false
        self.vwEffectMetaTbl.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.vwEffectMetaTbl.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.vwEffectMetaTbl.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.vwEffectMetaTbl.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.bgHabilitado.translatesAutoresizingMaskIntoConstraints = false
        self.bgHabilitado.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.bgHabilitado.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.bgHabilitado.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.bgHabilitado.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.setHeightFromTitles()
        
        self.getTipificacionPermitida()
        self.lblTipoDoc.text = "rules_select".langlocalized()
        self.initTipificacion()
        
    }
    
    override open func update() {
        super.update()
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
        
        sdkAPI = APIManager<DocumentoCell>()
        
        let nib = UINib(nibName: "vDndloQPRpDwkSO", bundle: Cnstnt.Path.framework)
        self.detailCollectionView.register(nib, forCellWithReuseIdentifier: DocumentDetailCollectionViewCell.identifier)
        
        self.detailCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let layout = self.detailCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: contentView.frame.size.width - 205, height: contentView.frame.size.height - 205)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.detailCollectionView.setCollectionViewLayout(layout, animated: true)
        
        detailCollectionView.backgroundColor = UIColor.clear
        detailCollectionView.layer.borderWidth = 0.5
        detailCollectionView.layer.borderColor = UIColor.black.cgColor
        detailCollectionView.layer.cornerRadius = 5.0
        detailCollectionView.isHidden = true
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        
        if self.headersView.isInfoToolTipVisible{
            self.headersView.toolTip!.dismiss()
            self.headersView.isInfoToolTipVisible = false
        }
    }
    
    // MARK: - PROTOCOLS APIDELEGATE
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
    public func sendStatusCodeMessage(message: String, error: enumErrorType) {}
    public func didSendError(message: String, error: enumErrorType) {}
    public func didSendResponse(message: String, error: enumErrorType) {}
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
    func presentrShouldDismiss() -> Bool { return true }
    
    // MARK: - ACTIONS
    // Lanza acciones documento
    @IBAction func btnActionsAction(_ sender: UIButton) {
        var alert = UIAlertController()
        alert = UIAlertController(title: "Agregar", message: "", preferredStyle: .actionSheet)
        let alertCamera = UIAlertAction(title: "\(atributos?.textobotontomarfoto ?? "Por cámara")", style: .default , handler:{ [self] (UIAlertAction)in
            self.btnCamaraAction()
        })
        
        let extensionesPermitidas = self.atributos.extensionespermitidas.components(separatedBy: ",").map { $0.lowercased() }
        let shouldShowCamera = extensionesPermitidas.contains { ext in
            return ext == "jpg" || ext == "png" || ext == "jpeg"
        }
        
        if shouldShowCamera && self.atributos!.permisocamara {
            alert.addAction(alertCamera)
        }
        
        let alertLibrary = UIAlertAction(title: "Por biblioteca", style: .default , handler:{ (UIAlertAction)in
            self.openLibrary()
        })
        alert.addAction(alertLibrary)
        
        let alertDocuments = UIAlertAction(title: "Por almacenamiento", style: .default , handler:{ (UIAlertAction)in
            self.openFiles()
        })
        alert.addAction(alertDocuments)

        let alertEmptyDoc = UIAlertAction(title: "Documento vacio", style: .default, handler:{ [self] (UIAlertAction)in
            self.sinImgAction()
        })
        alert.addAction(alertEmptyDoc)
        
        let alertCancel = UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            print("Cancel Action")
        })
        alert.addAction(alertCancel)

        alertCamera.isEnabled = atributos.permisocamara
        alertDocuments.isEnabled = atributos.permisoimportar
        alertLibrary.isEnabled = atributos.permisoimportar

        self.formDelegate?.getFormViewControllerDelegate()?.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    //MARK: Extensiones permitidas
    func getExtensions(ext: String) -> [String]{
        let array = ext.components(separatedBy: ",")
        var arrayExtDoc: [String] = []
        if ext == "" { // ext -> BMP, DOCX PDF
            return self.extensionsDocs
        }else if ext == "*"{
            return arrayExtDoc
        } else{
            for key in array{
                if self.extensionsDictionary[key] != nil{
                    arrayExtDoc.append(self.extensionsDictionary[key]!)
                }
            }
            return arrayExtDoc
        }
    }
    
    // Función Foto/Imagen anexo
    func btnCamaraAction() {
        getAutho()
        if (atributos?.maximodocumentos ?? 0 == 0 && atributos?.minimodocumentos ?? 0 == 0) || self.startReemp {
            openCamera()
        }else if self.fedocumentos.count >= atributos?.maximodocumentos ?? 0 {
            setMessage(String(format: "elemts_doc_max".langlocalized(), String(self.atributos?.maximodocumentos ?? 99)), .error)
            return
        }else{
            openCamera()
        }
    }
    func openCamera() {
        /*
         Hay dos opciones de atributos?.tipocamara.
          1. El tipo de camara a abrir sea GeniusScan -> Abre el controlador GeniusEscanerViewController
          2. El tipo de camara sea diferente a GeniusScan -> Abre UIImagePickerController
         */
        
        if atributos?.tipocamara == "GeniusScan" {
            self.formDelegate?.setStatusBarNotificationBanner("La camara de Genius Scan está inhabilitado por el momento", .warning, .top)
//            let escaner: GeniusEscanerViewController = GeniusEscanerViewController()
//            escaner.delegate = self
//            self.formDelegate?.getFormViewControllerDelegate()?.present(escaner, animated: true, completion: nil)
        } else {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let pickerController = UIImagePickerController()
                pickerController.modalPresentationStyle = .fullScreen
                pickerController.delegate = self
                pickerController.sourceType = UIImagePickerController.SourceType.camera
                pickerController.allowsEditing = false
                if atributos?.modocamara == "front"{
                    pickerController.cameraDevice = .front
                }else{
                    pickerController.cameraDevice = .rear
                }
                self.formDelegate?.getFormViewControllerDelegate()?.present(pickerController, animated: true, completion: nil)
            }
        }
    }
    
    // Función biblioteca
    func openLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.modalPresentationStyle = .fullScreen
            pickerController.delegate = self
            pickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            pickerController.allowsEditing = false
            self.formDelegate?.getFormViewControllerDelegate()?.present(pickerController, animated: true, completion: nil)
        }
    }
    
    // Función archivos
    func openFiles(){
        let importMenu = UIDocumentPickerViewController(documentTypes: self.getExtensions(ext: self.atributos.extensionespermitidas), in: .import)
        importMenu.delegate = self
        importMenu.allowsMultipleSelection = true
        importMenu.modalPresentationStyle = .popover
        let presenter = Presentr(presentationType: .popup)

        if (self.atributos?.maximodocumentos ?? 0 == 0 && self.atributos?.minimodocumentos ?? 0 == 0) || self.startReemp {
            self.formViewController()?.customPresentViewController(presenter, viewController: importMenu, animated: true, completion: nil)
        }else if self.fedocumentos.count >= self.atributos?.maximodocumentos ?? 0   {
            self.setMessage(String(format: "elemts_doc_max".langlocalized(), String(self.atributos?.maximodocumentos ?? 99)), .error)
            return
        }else{
            self.formViewController()?.customPresentViewController(presenter, viewController: importMenu, animated: true, completion: nil)
        }
    }
    
    // Función Sin Imagen - anexo
    func sinImgAction() {
        if (self.fedocumentos.count < self.atributos?.maximodocumentos ?? 99) {
            let guid = ConfigurationManager.shared.utilities.guid()
            let image = UIImage(named: "ic_anexoDefault", in: Cnstnt.Path.framework, compatibleWith: nil)
            let p = "\(guid).ane"
            let doc = FEDocumento()
            doc.guid = "\(guid)"
            doc.isKindImage = self.atributos.extensionespermitidas == "PDF" ? false : true
            doc.Ext = self.atributos.extensionespermitidas == "PDF" ? "pdf" : "png"
            
            doc.ImageString = ""
            doc.Nombre = p
            doc.Path = p
            doc.URL = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
            doc.TipoDoc = ""
            doc.TipoDocID = 0
            
            for list in self.listAllowed{
                if self.tipUnica == nil{ break }
                if list.CatalogoId != tipUnica{ continue }
                doc.TipoDocID = tipUnica ?? 0
                doc.TipoDoc = list.Descripcion
                list.current += 1
            }
            doc.TipoDocID = tipUnica ?? 0
            self.fedocumentos.append(doc)
            // Guardamos el id y ruta del anexo en el array global
            self.anexosDict.append((id: "\(self.fedocumentos.count - 1)", url: doc.URL))
            
            if self.atributos.extensionespermitidas == "PDF" {
                if let image = image {
                    let document = PDFDocument()
                    let pdfPage = PDFPage(image: image)
                    document.insert(pdfPage!, at: 0)
                    let _ = ConfigurationManager.shared.utilities.savePDFToFolder(document, doc.URL)
                }
            } else {
                let _ = ConfigurationManager.shared.utilities.saveImageToFolder(image!, doc.URL)
            }
            if self.isMarcado != ""
            {   _ = self.formDelegate?.resolveValor(self.isMarcado, "asignacion", "\(String(describing: doc.TipoDocID))|\(doc.TipoDoc)" , nil)  }
            self.detailCollectionView.isHidden = false
            self.detailCollectionView.reloadData()
            setEdited(v: doc.URL)
            savingData()
        }else{
            setMessage(String(format: "elemts_doc_max".langlocalized(), String(self.atributos?.maximodocumentos ?? 99)), .error)
        }
    }
    
    //MARK: Lanza Preview Anexo
    @IBAction func togglePreviewAction(_ sender: UIButton) {
        // Validamos que sea un anexo existente y que tenga datos (!= nil)
        if let data = ConfigurationManager.shared.utilities.getDataFromFile("\(Cnstnt.Tree.anexos)/\(self.fedocumentos[sender.tag].URL)")
        {   // Valida si es pdf o diferente para mostrarlo
            if self.fedocumentos[sender.tag].Ext.lowercased().replacingOccurrences(of: ".", with: "") == "pdf" {
                self.setPreviewPDF(fileData: data, fileName: fedocumentos[sender.tag].Nombre)
            } else if self.fedocumentos[sender.tag].Ext.lowercased().replacingOccurrences(of: ".", with: "") == "png" || self.fedocumentos[sender.tag].Ext.lowercased().replacingOccurrences(of: ".", with: "") == "jpg" || self.fedocumentos[sender.tag].Ext.lowercased().replacingOccurrences(of: ".", with: "") == "jpeg" {
                self.setPreview(data)
            }
            
        }
    }
    
    // Función de tap para preview
    @objc func previewTapImg(_ sender: UITapGestureRecognizer) {
        let auxImg : UIImageView = sender.view as? UIImageView ?? UIImageView()
        let aux: UIButton = UIButton()
        aux.tag = auxImg.tag
        self.togglePreviewAction(aux)
    }
    
    // Función preview imagen
    public func setPreview(_ sender: Any) {
        let dataAne = sender as? Data
        if dataAne == nil { return }
        let preview = PreviewImagenViewMain.create(dataImage: dataAne)
        preview.modalPresentationStyle = .overFullScreen
        self.formViewController()?.present(preview, animated: true)
    }
    
    // Función preview PDF
    func setPreviewPDF(fileData: Data, fileName: String) {
        let fileStream:String = fileData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        let preview = WebPDFViewControllerMain.create(pdfString: fileStream, nameOfFile: fileName)
        preview.modalPresentationStyle = .overFullScreen
        self.formViewController()?.present(preview, animated: true)
    }
    
    // Lanza acción Borrar anexo
    @IBAction func deleteAction(_ sender: UIButton) {
        if self.fedocumentos.isEmpty{
            self.arrayAnexosReemp = []
            self.detailCollectionView.reloadData()
            self.metaDataTableView.reloadData()
        }else{
            let actualDoc = self.fedocumentos[sender.tag]
            for list in self.listAllowed{
                if list.CatalogoId != actualDoc.TipoDocID{ continue }
                list.current -= 1
                break
            }
            self.fedocumentos.remove(at: sender.tag)
            self.metadatosFEDocumentos[sender.tag] = []
            self.metaReq.allKeys.forEach({ keyFE in
                let id = String((keyFE as! String).split(separator: "|").last ?? "")
                if Int(id) ?? -1 == sender.tag {
                    self.metaReq.removeObject(forKey: keyFE)
                }
            })
                
            if !self.anexosDict.isEmpty { self.anexosDict.remove(at: sender.tag) }
            FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == actualDoc.Nombre { $0.Borrado = true }}
            
            if self.isMarcado != ""
            {
                var exist = false
                for list in self.fedocumentos{
                    if list.TipoDocID == actualDoc.TipoDocID
                    { exist = true }
                }
                if !exist
                {   _ = self.formDelegate?.resolveValor(self.isMarcado, "asignacion", "\(actualDoc.TipoDocID ?? 0)OFF", nil)   }
            }
            self.indexClic = -1
            self.tamMaxMeta = 0.0
            self.detailCollectionView.reloadData()
            self.metaDataTableView.reloadData()
            if self.fedocumentos.count == 0{
                self.tamConAnexos = 0
                self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
                row.value = nil
                row.validate()
                if self.atributos?.minimodocumentos ?? 0 > 0 {
                    setMessage(String(format: "elemts_doc_min".langlocalized(), String(self.atributos?.minimodocumentos ?? 0)), .error)
                }
                self.setVariableHeight(Height: tamSinAnexos)
                self.detailCollectionView.isHidden = true
                (row as? DocumentoRow)?.baseCell.formViewController()?.tableView.reloadData()
                
            }
        }
        triggerRulesOnChange("removeanexo")
        triggerRulesOnChange("typifyattach")
    }
    
    // Lanza Download Anexo
    @objc public func setDownloadAnexo(_ sender: Any) {
        // Se muestra mensaje de descarga
        self.setMessage("hud_downloading".langlocalized(), .info)
        activity.startAnimating()
        activity.isHidden = false
        // Se crea un auxiliar de array de anexos en caso de tener que descargarlos
        var arrayAnexos: [FEAnexoData] = [FEAnexoData]()
        // Validamos y recorremos el array de anexos
        if self.anexosRecup != nil {
            var isFist = true
            var totAne = 0
            for ane in self.anexosRecup!{
                // Validamos si es un anexo local (creado y guardado desde el móvil)
                if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(ane.FileName)"){
                    totAne += 1
                    activity.stopAnimating()
                    activity.isHidden = true
                    // Si no es un anexo reemplazado se muestra
                    if !ane.Reemplazado && isFist {
                        // Validamos que sea un anexo local y que tenga datos (!= nil)
                        if let data = ConfigurationManager.shared.utilities.getDataFromFile("\(Cnstnt.Tree.anexos)/\(ane.FileName)") {
                            if ane.Extension == ".pdf" || ane.Extension == "pdf" || ane.Extension == ".PDF" || ane.Extension == "PDF"{
                                self.setPreviewPDF(fileData: data, fileName: ane.FileName)
                                isFist = false
                            }else{
                                self.setPreview(data)
                                isFist = false
                            }
                            
                            
                        }
                    } // #REVISAR SI SE ABRE EL PREVIEW EN CASO DE MUCHOS ANEXOS EN AND Y WEB
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { self.setMessage("", .info) }
                }else{
                    // Se descarga el anexo
                    self.sdkAPI?.DGSDKformatoAnexos(delegate: self, anexo: ane, estado: FormularioUtilities.shared.currentFormato.EstadoApp)
                        .then{ response in
                            totAne += 1
                            // Se prende la propiedad de descargado y se guarda en el aux array anexos
                            let auxAnexoDescargado : FEAnexoData = response
                            auxAnexoDescargado.Descargado = true
                            arrayAnexos.append(auxAnexoDescargado)
                            // Si no es un anexo reemplazado se muestra
                            if !ane.Reemplazado && isFist{
                                // Validamos que sea un anexo local y que tenga datos (!= nil)
                                if let data = ConfigurationManager.shared.utilities.getDataFromFile("\(Cnstnt.Tree.anexos)/\(ane.FileName)")
                                {
                                    if ane.Extension == ".pdf" || ane.Extension == "pdf" || ane.Extension == ".PDF" || ane.Extension == "PDF"{
                                        self.setPreviewPDF(fileData: data, fileName: ane.FileName)
                                        isFist = false
                                    }else{
                                        self.setPreview(data)
                                        isFist = false
                                    }
                                }
                            }
                            if totAne == self.anexosRecup?.count{
                                self.anexosRecup = arrayAnexos
                                self.porDescargar = false
                                self.detailCollectionView.reloadData()
                                self.activity.stopAnimating()
                                self.activity.isHidden = true
                                self.setMessage("", .info)
                            }
                        }.catch{ error in
                            totAne += 1
                            if totAne == self.anexosRecup?.count{
                                self.activity.stopAnimating()
                                self.activity.isHidden = true
                            }
                            self.setMessage("elemts_attch_error".langlocalized(), .info)
                        }
                }
            }
        }
    }
    
    //MARK: Reemplazo Anexo
    // Called Reemplazo Action
    @IBAction func btnReempAction(_ sender: UIButton) {
        self.idAnexoReemp = sender.tag
        arrayAnexosReemp.append((key: sender.tag, value: self.fedocumentos[sender.tag]))
        self.startReemp = true
        
        let alert = UIAlertController(title: "Sustituir", message: "", preferredStyle: .actionSheet)
        let alertCamera = UIAlertAction(title: "Por \(atributos?.textobotontomarfoto ?? "Por cámara")", style: .default , handler:{ [self] (UIAlertAction)in
            self.btnCamaraAction()
        })
        
        let extensionesPermitidas = self.atributos.extensionespermitidas.components(separatedBy: ",").map { $0.lowercased() }
        let shouldShowCamera = extensionesPermitidas.contains { ext in
            return ext == "jpg" || ext == "png" || ext == "jpeg"
        }
        
        if shouldShowCamera && self.atributos!.permisocamara {
            alert.addAction(alertCamera)
        }

        let alertLibrary = UIAlertAction(title: "Por biblioteca", style: .default , handler:{ (UIAlertAction) in
            self.openLibrary()
        })
        alert.addAction(alertLibrary)

        let alertDocuments = UIAlertAction(title: "Por Archivos", style: .default , handler:{ (UIAlertAction)in
            self.openFiles()
        })
        alert.addAction(alertDocuments)

        let alertEmptyDoc = UIAlertAction(title: "Documento vacio", style: .default, handler:{ [self] (UIAlertAction)in
            self.sinImgAction()
        })
        alert.addAction(alertEmptyDoc)
        
        let alertCancel = UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            print("Cancel Action")
        })
        alert.addAction(alertCancel)

        alertCamera.isEnabled = atributos.permisocamara
        alertDocuments.isEnabled = atributos.permisoimportar
        alertLibrary.isEnabled = atributos.permisoimportar
        
        self.formDelegate?.getFormViewControllerDelegate()?.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    // Called CancelReemplazo Action
    @IBAction func btnCancelReempAction(_ sender: UIButton) {
        // Eliminamos el id y ruta nueva del anexoReemplazo en el array global
        var auxAnexosDict = [(id: String, url: String)]()
        self.anexosDict.forEach({
            if $0 != (id: "\(sender.tag)", url: self.fedocumentos[sender.tag].URL) { auxAnexosDict.append($0) } })
        self.anexosDict = auxAnexosDict
        let anteriorDoc = self.arrayAnexosReemp.first(where: {$0.key == sender.tag})?.value ?? FEDocumento()
        self.fedocumentos[sender.tag] = anteriorDoc
        var auxArrayReemp = [(key: Int, value: FEDocumento)]()
        self.arrayAnexosReemp.forEach({ if $0 != (key: sender.tag, value: anteriorDoc) { auxArrayReemp.append($0) } })
        self.arrayAnexosReemp = auxArrayReemp
        FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == anteriorDoc.Nombre { $0.Reemplazado = false }}
        self.detailCollectionView.reloadData()
        self.metaDataTableView.reloadData()
    }
    
    // MARK: - AUTHORIZATION
    func getAutho(){
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .notDetermined: requestCameraPermission(); break;
        case .authorized: break;
        case .restricted, .denied: alertCameraAccessNeeded();
        @unknown default: break;
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
        })
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "alrt_warning".langlocalized(),
            message: "alrt_camerause".langlocalized(),
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "alrt_cancel".langlocalized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "alrt_allow".langlocalized(), style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        (row as? DocumentoRow)?.cell.formCell()?.formViewController()?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - INIT TIPYFICATION
    public func initTipificacion(){
        let nibMD = UINib(nibName: "KHFSnImyzOBlprQ", bundle: Cnstnt.Path.framework)
        self.metaDataTableView.register(nibMD, forCellReuseIdentifier: MetaDataTableViewCell.identifier)
        self.metaDataTableView.layer.cornerRadius = 6.0
        self.metaDataTableView.layer.borderWidth = 1.0
        self.metaDataTableView.dataSource = self
        self.metaDataTableView.delegate = self
        
        self.metaBtnCancel.backgroundColor = UIColor.red
        self.metaBtnCancel.layer.cornerRadius = metaBtnCancel.frame.height / 2
        self.metaBtnCancel.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        self.metaBtnGuardar.setImage(UIImage(named: "check_full", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)

        /*self.metaBtnRedo.layer.cornerRadius = metaBtnRedo.frame.height / 2
        self.metaBtnRedo.backgroundColor = UIColor.systemYellow
        self.metaBtnRedo.layer.cornerRadius = metaBtnRedo.frame.height / 2
        self.metaBtnRedo.setImage( UIImage(named: "ic_redo", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)*/
        
        self.documentType.isHidden = true
        self.documentType.dataSource = self
        self.documentType.delegate = self
        self.documentType.layer.cornerRadius = 10
    }
    
    public func getTipificacionPermitida(){
        let tipificacionUnica = atributos?.tipificacionunica
        if tipificacionUnica != nil && tipificacionUnica?["enabled"] != nil {
            if tipificacionUnica?["enabled"] as! String == "true" {
                if let idTypeDoc = tipificacionUnica?["idtype"] as? String {
                    self.tipUnica = Int(idTypeDoc) ?? nil
                    let tipificacionPermitida = atributos.tipificacionpermitida
                    let dictTip: [Dictionary<String, Any>] = tipificacionPermitida as! [Dictionary<String, Any>]
                    
                    // If typUnic is not null we need to set all catalogs to false only true the typ unique
                    if self.tipUnica != nil{
                        for idDoc in ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc{
                            if self.tipUnica == idDoc.CatalogoId{
                                okUnico = true
                                for (keys, values) in dictTip[0]{
                                    let valueTipoDoc = values as! NSDictionary
                                    if "tipodoc_\(self.tipUnica ?? 0)" == keys{
                                        idDoc.min = Int((valueTipoDoc["min"] as? String) ?? "0") ?? 0
                                        idDoc.max = Int((valueTipoDoc["max"] as? String) ?? "0") ?? 0
                                    }
                                }
                                idDoc.Activo = true
                            }else { idDoc.Activo = false }
                        }
                    }
                }
            }else{
                let dictTip: [Dictionary<String, Any>] = atributos.tipificacionpermitida as! [Dictionary<String, Any>]
                
                for idDoc in ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc {
                // If typ is not null we need to set all catalogs to false only true the typ unique
                    for (keys, values) in dictTip[0] {
                        let valueTipoDoc = values as! NSDictionary
                        if "tipodoc_\(idDoc.CatalogoId)" == keys{
                            idDoc.min = Int((valueTipoDoc["min"] as? String) ?? "0") ?? 0
                            idDoc.max = Int((valueTipoDoc["max"] as? String) ?? "0") ?? 0
                            if valueTipoDoc["enabled"] as? String == "true"{
                                idDoc.Activo = true
                            }
                        }
                    }
                }
            }
        }
        
        self.listAllowed = []
        for list in ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc{
            if self.listAllowed.isEmpty && list.Activo {
                self.listAllowed.append(list)
            } else if self.listAllowed.contains(where: { $0.CatalogoId != list.CatalogoId}) && list.Activo {
                self.listAllowed.append(list)
            }
        }
    }
    
    // MARK: Button Action Document Type
    @IBAction func typeDocAction(_ sender: UIButton) {
        self.indexClic = sender.tag
        self.listaInMeta = false
        self.documentType.reloadComponent(0)
        self.documentType.selectRow(0, inComponent: 0, animated: false)
        self.vwEffectMetaTbl.isHidden = false
        self.documentType.isHidden = false
        self.flagEdit = false
        self.metaDataTableView.isHidden = true
        
        self.metaBtnGuardar.isHidden = true
        //self.metaBtnRedo.isHidden = true
        self.lblTipoDoc.text = "Selecciona un tipo de documento"
        self.lblTipoDoc.isHidden = false
    }
    
    //MARK: - Piker: Typification's Controllers
    public func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.listaInMeta {
            return self.dataListaInMeta.count + 1
        } else{
            if ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc.count == 0 { return 0 } else { return listAllowed.count + 1 }
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font =  UIFont(name: ConfigurationManager.shared.fontApp, size: 16.0)
            pickerLabel?.textAlignment = .center
        }
        if row == 0{ pickerLabel?.text = "rules_select".langlocalized() }else{
            if self.listaInMeta {
                pickerLabel?.text = self.dataListaInMeta[row - 1].Descripcion
            } else{
                pickerLabel?.text = listAllowed[row - 1].Descripcion
            }
        }
        return pickerLabel!
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0{ return "rules_select".langlocalized() }else{
            if self.listaInMeta {
                return self.dataListaInMeta[row - 1].Descripcion
            } else{
                return listAllowed[row - 1].Descripcion
            }
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0{ return }
        self.documentType.isHidden = true
        
        if self.listaInMeta {
            let cell = metaDataTableView.cellForRow(at: IndexPath(row: self.indextableview, section: 0)) as! MetaDataTableViewCell
            cell.textFieldMD.text = "\(self.dataListaInMeta[row - 1].CatalogoId)|_Desc|\(self.dataListaInMeta[row - 1].Descripcion)"
            cell.listMD.setTitle("\(self.dataListaInMeta[row - 1].Descripcion)", for: .normal)
            self.documentType.isHidden = true
            self.flagEdit = true
            self.metaDataTableView.isHidden = false
            self.metaBtnGuardar.isHidden = false
            //self.metaBtnRedo.isHidden = false
            self.listaInMeta = false
        } else{
            let desc = listAllowed[row - 1].Descripcion
            let id = listAllowed[row - 1].CatalogoId
        
            for list in self.listAllowed{
                if list.CatalogoId != id { continue }
                self.fedocumentos[self.indexClic].TipoDocID = id
                self.fedocumentos[self.indexClic].TipoDoc = desc
                list.current += 1
                break
            }
        
            self.headersView.lblMessage.isHidden = true
            self.headersView.lblSubtitle.isHidden = false
            self.vwEffectMetaTbl.isHidden = true
            self.tamMaxMeta = 0.0
            if self.fedocumentos[self.indexClic].TipoDocID != 0 {
                self.docID = self.fedocumentos[self.indexClic].TipoDocID ?? 0
                if self.getMetaData(){
                    // Saving meta empty attibutes to the Document Typed
                    var metaDatosFED : [FEListMetadatosHijos] = []
                    for (_, meta) in self.arrayMetadatos.enumerated() {
                        let auxMeta : FEListMetadatosHijos = FEListMetadatosHijos()
                        auxMeta.Accion = meta.Accion
                        auxMeta.EsEditable = meta.EsEditable
                        auxMeta.Expresion_Regular = meta.Expresion_Regular
                        auxMeta.FolioAut = meta.FolioAut
                        auxMeta.Longitud_Maxima = meta.Longitud_Maxima
                        auxMeta.Longitud_Minima = meta.Longitud_Minima
                        auxMeta.Mascara = meta.Mascara
                        auxMeta.MetadatoId = meta.MetadatoId
                        auxMeta.Nombre = meta.Nombre
                        auxMeta.Obligatorio = meta.Obligatorio
                        auxMeta.TipoDato = meta.TipoDato
                        auxMeta.TipoDatoId = meta.TipoDatoId
                        auxMeta.TipoDoc = meta.TipoDoc
                        auxMeta.NombreCampo = ""
                        metaDatosFED.append(auxMeta)
                    }
                    self.metadatosFEDocumentos[self.indexClic] = metaDatosFED
                } else{
                    self.metadatosFEDocumentos[self.indexClic] = []
                    self.fedocumentos[self.indexClic].Metadatos = []
                }
                self.savingData()
            }
            self.detailCollectionView.reloadData()
            triggerRulesOnChange("typifyattach")
        }
    }
    
    // MARK: - METADATA
    // MARK: Button Action Metadata
    @IBAction func metaAction(_ sender: UIButton) {
        self.indexClic = sender.tag
        if self.fedocumentos[self.indexClic].TipoDocID == 0
        {
            self.formDelegate?.setNotificationBanner("", "Es necesario seleccionar un tipo de documento para mapear los metadatos.", .danger , .bottom)
        } else {
            self.docID = self.fedocumentos[self.indexClic].TipoDocID ?? 0
            if self.getMetaData(){
                self.documentType.isHidden = true
                self.vwEffectMetaTbl.isHidden = false
                self.lblTipoDoc.text = "Metadatos"
                self.metaBtnGuardar.isHidden = false
                self.flagEdit = true
                self.metaDataTableView.isHidden = false
                self.metaDataTableView.reloadData()
            } else
            {
                self.formDelegate?.setNotificationBanner("", "No existen metadatos asociados a este tipo de documento.", .danger , .bottom)
            }
        }
    }
    
    // MARK: Close Meta View
    @IBAction func closeMetaAction(_ sender: Any) {
        self.listaInMeta = false
        self.vwEffectMetaTbl.isHidden = true
        self.cleanMetaAction(self)
    }
    
    // MARK: Clean Meta View
    @IBAction func cleanMetaAction(_ sender: Any) {
        self.clearMeta = true
        self.metaDataTableView.reloadData()
    }
    
    // MARK: Save Meta View
    @IBAction func saveMetaAction(_ sender: Any) {
        self.listaInMeta = false
        var error = false
        // Saving meta attibutes to the Document Typed
        var metaDatosFED : [FEListMetadatosHijos] = []
        let obj = self.fedocumentos[self.indexClic]
        for (_, meta) in self.arrayMetadatos.enumerated() {
            let auxMeta : FEListMetadatosHijos = FEListMetadatosHijos()
            
            auxMeta.Accion = meta.Accion
            auxMeta.EsEditable = meta.EsEditable
            auxMeta.Expresion_Regular = meta.Expresion_Regular
            auxMeta.FolioAut = meta.FolioAut
            auxMeta.Longitud_Maxima = meta.Longitud_Maxima
            auxMeta.Longitud_Minima = meta.Longitud_Minima
            auxMeta.Mascara = meta.Mascara
            auxMeta.MetadatoId = meta.MetadatoId
            auxMeta.Nombre = meta.Nombre
            auxMeta.Obligatorio = meta.Obligatorio
            auxMeta.TipoDato = meta.TipoDato
            auxMeta.TipoDatoId = meta.TipoDatoId
            auxMeta.TipoDoc = meta.TipoDoc
            
            if auxMeta.TipoDato.contains("bit"){
                for (key, value) in metaDatosDictionary{
                    if auxMeta.Nombre == key.replacingOccurrences(of: " *", with: "") {
                        auxMeta.NombreCampo = value
                    }
                }
            } else {
                for (key, value) in metaDatosDictionary{
                    if auxMeta.Nombre == key.replacingOccurrences(of: " *", with: "") {
                        auxMeta.NombreCampo = value
                    }
                }
            }

            if let idTipoDoc = self.metaReq.value(forKey: "\(auxMeta.Nombre)|\(self.indexClic)") {
                if obj.TipoDocID == idTipoDoc as? Int && auxMeta.NombreCampo == "" {
                    error = true
                    self.formDelegate?.setNotificationBanner("", "Verifique los campos obligatorios", .danger , .top)
                    break
                }
            }
            if !error {
                metaDatosFED.append(auxMeta)
            }else {
                break
            }
        }
        self.metadatosFEDocumentos[self.indexClic] = metaDatosFED
        self.fedocumentos[self.indexClic].Metadatos = metaDatosFED
        if !error {
            self.metaDatosDictionary = [String:String]()
            self.vwEffectMetaTbl.isHidden = true
            self.savingData()
            self.detailCollectionView.reloadData()
            self.cleanMetaAction(self)
            var valid = true
            self.metaReq.allKeys.forEach({ keyFE in
                let id = String((keyFE as! String).split(separator: "|").last ?? "")
                let obj = self.fedocumentos[Int(id) ?? -1]
                if obj.Metadatos.count == 0 {
                    valid = false
                }
            })
            if valid {
                DispatchQueue.main.async {
                    self.setOcultarSubtitulo(self.atributos?.ocultarsubtitulo ?? false)
                    self.headersView.lblMessage.text = ""
                    self.headersView.lblMessage.isHidden = true
//                    self.headersView.viewValidation.backgroundColor = Cnstnt.Color.gray
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: Get Metas
    func getMetaData()->Bool{
        self.arrayMetadatos = []
        let metas = ConfigurationManager.shared.plantillaDataUIAppDelegate.ListMetadatosHijos
        if metas.count == 0{ return false }
        for meta in metas{ if self.docID == meta.TipoDoc{ self.arrayMetadatos.append(meta) } }
        if self.arrayMetadatos.count == 0{ return false }
        return true
    }
    
    //MARK: - TABLEVIEW METADATOS
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.indextableview = textField.tag
        self.metaDataTableView.selectRow(at: IndexPath(row: textField.tag, section: 0), animated: true, scrollPosition: .middle)
        //maxLogMeta - minLogMeta
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let cell = metaDataTableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as! MetaDataTableViewCell
        if cell.minLongMeta != 0{
            if (textField.text?.count)! < (cell.minLongMeta){
                print("No cumple el minimo")
            }
        }
        metaDatosDictionary[cell.lblNameMD.text ?? ""] = cell.textFieldMD.text ?? ""
    }
    
    @objc open func textFieldDidChange(_ textField: UITextField) {
        guard let _ = textField.text else { return }
        let cell = metaDataTableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as! MetaDataTableViewCell
        if cell.maxLongMeta != 0{
            if (textField.text?.count)! > (cell.maxLongMeta){
                textField.text = textField.text!.substring(to: cell.maxLongMeta )
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayMetadatos.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = metaDataTableView.dequeueReusableCell(withIdentifier: "MDCELL", for: indexPath) as! MetaDataTableViewCell
        if self.clearMeta {
            cell.lblNameMD.text = ""
            cell.textFieldMD.text = ""
            cell.textFieldMD.placeholder = ""
            cell.textFieldMD.textColor = .black
            cell.listMD.setTitle(" Seleccione...      ", for: .normal)
            cell.listMD.setImage(UIImage(named: "ic_arrowDown", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
            cell.boolMD.setImage(UIImage(named: "ic_uncheck", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
            cell.maxLongMeta = 0
            cell.minLongMeta = 0
            self.clearMeta = (indexPath.row + 1) == self.arrayMetadatos.count ? false : true
            return cell
        }
        let obj = self.arrayMetadatos.isEmpty ? FEListMetadatosHijos() : self.arrayMetadatos[indexPath.row]
        let a = self.metaDatosDictionary[obj.Nombre]
        cell.textFieldMD.text = a != nil ? a : ""
        
        cell.lblRequeridoMD.isHidden = !obj.Obligatorio
        cell.textFieldMD.tag = indexPath.row
        cell.textFieldMD.delegate = self
        cell.textFieldMD.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if self.docID == obj.TipoDoc{
            var objMeta = FEListMetadatosHijos()
            if !self.fedocumentos.isEmpty && self.indexClic != -1 {
                objMeta = self.fedocumentos[self.indexClic].Metadatos.first(where: {$0.Nombre == obj.Nombre}) ?? objMeta
            }
            if objMeta.NombreCampo != "" { cell.textFieldMD.text = objMeta.NombreCampo }
            cell.lblNameMD.text = obj.Nombre
            cell.textFieldMD.placeholder = obj.Mascara
            cell.textFieldMD.keyboardType = .emailAddress
            cell.textFieldMD.textColor = .black
            if obj.TipoDato.contains("datetime") || obj.TipoDato.contains("DD/MM/AAAA") || obj.TipoDato.contains("AAAA/MM/DD") || obj.TipoDato.contains("DD-MM-AAAA") || obj.TipoDato.contains("AAAA-MM-DD") {
                cell.textFieldMD.addTarget(self, action: #selector(showDatePicker(_:)), for: .editingDidBegin)
                cell.textFieldMD.isEnabled = obj.EsEditable
                cell.boolMD.isHidden = true
                cell.listMD.isHidden = true
                return cell
            }else if obj.TipoDato.contains("Catalogo"){
                cell.textFieldMD.placeholder = ""
                cell.textFieldMD.textColor = .white
                cell.boolMD.isHidden = true
                cell.listMD.isHidden = false
                cell.listMD.tag = indexPath.row
                cell.listMD.addTarget(self, action: #selector(showListAction(_:)), for: .touchUpInside)
                if objMeta.NombreCampo != "" {
                    if objMeta.NombreCampo.split(separator: "|").count == 3 {
                        let _Desc = String(objMeta.NombreCampo.split(separator: "|").last ?? "")
                        cell.listMD.setTitle(_Desc, for: .normal)
                    }
                }
                cell.listMD.isEnabled = obj.EsEditable
                return cell
            }else if obj.TipoDato.contains("Money"){
                cell.textFieldMD.keyboardType = .numberPad
                cell.boolMD.isHidden = true
                cell.listMD.isHidden = true
                cell.textFieldMD.isEnabled = obj.EsEditable
                cell.maxLongMeta = obj.Longitud_Maxima
                cell.minLongMeta = obj.Longitud_Minima
                return cell
            }else if obj.TipoDato.contains("Int") || obj.TipoDato.contains("bigint") || obj.TipoDato.contains("Tinyint"){
                cell.textFieldMD.keyboardType = .numberPad
                cell.boolMD.isHidden = true
                cell.listMD.isHidden = true
                cell.textFieldMD.isEnabled = obj.EsEditable
                cell.maxLongMeta = obj.Longitud_Maxima
                cell.minLongMeta = obj.Longitud_Minima
                return cell
            }else if obj.TipoDato.contains("bit"){
                cell.textFieldMD.placeholder = ""
                cell.textFieldMD.textColor = .white
                cell.textFieldMD.isEnabled = false
                cell.listMD.isHidden = true
                cell.boolMD.isHidden = false
                cell.boolMD.setTitle("false", for: []);
                cell.boolMD.tag = indexPath.row
                cell.boolMD.addTarget(self, action: #selector(checkAction), for: .touchUpInside)
                if objMeta.NombreCampo != "" && objMeta.NombreCampo == "true"{
                    cell.boolMD.setTitle("true", for: []);
                    cell.boolMD.setImage(UIImage(named: "ic_check_c", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
                }
                cell.boolMD.isEnabled = obj.EsEditable
                return cell
            }else{
                cell.boolMD.isHidden = true
                cell.listMD.isHidden = true
                cell.textFieldMD.isEnabled = obj.EsEditable
                cell.maxLongMeta = obj.Longitud_Maxima
                cell.minLongMeta = obj.Longitud_Minima
                return cell
            }
            
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = metaDataTableView.dequeueReusableCell(withIdentifier: "MDCELL", for: indexPath) as! MetaDataTableViewCell
        cell.textFieldMD.becomeFirstResponder()
        print(indexPath.row)
        self.indexPathTableView = indexPath
    }
    
    @objc func showDatePicker(_ sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        sender.text = formatDate(tag: sender.tag, date: Date())
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        sender.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(_ sender:UIDatePicker) {
        let cell = metaDataTableView.cellForRow(at:IndexPath(row: self.indextableview, section: 0)) as! MetaDataTableViewCell
        let date = formatDate(tag: nil, date: sender.date)
        cell.textFieldMD.text = date
    }
    
    
    private func formatDate(tag: Int?, date: Date) -> String {
        
        let index: Int
        if let tag = tag {
            index = tag
        } else {
            index = self.indextableview
        }
        
        let obj = self.arrayMetadatos[index]
        var formatt = obj.TipoDato.replacingOccurrences(of: " ", with: "")
        formatt = formatt.replacingOccurrences(of: "DD", with: "dd")
        formatt = formatt.replacingOccurrences(of: "AAAA", with: "yyyy")
        let dateFormatter = DateFormatter()
        if formatt == "datetime" {
            dateFormatter.dateStyle = DateFormatter.Style.medium
        } else {
            formatt = formatt.replacingOccurrences(of: "datetime", with: "")
            dateFormatter.dateFormat = formatt
        }
        
        return dateFormatter.string(from: date)
    }
    
    // muestra la lista
    @objc func showListAction(_ sender: UIButton) {
        
        let obj = self.arrayMetadatos[sender.tag]
        let catalogos = ConfigurationManager.shared.utilities.getCatalogoInLibrary(obj.Accion.replacingOccurrences(of: "Web_BuscaCatalogo ", with: ""))
        if catalogos?.Catalogo.count ?? 0 > 0{
            for catalogo in catalogos!.Catalogo {
                self.dataListaInMeta.append(catalogo)
            }
            self.listaInMeta = true
            self.indextableview = sender.tag
            self.documentType.reloadComponent(0)
            self.documentType.selectRow(0, inComponent: 0, animated: false)
            self.vwEffectMetaTbl.isHidden = false
            self.documentType.isHidden = false
            self.flagEdit = false
            self.metaDataTableView.isHidden = true
            self.metaBtnGuardar.isHidden = true
            //self.metaBtnRedo.isHidden = true
        }
    }

    
    // MARK: - COLLECTIONVIEW ANEXOS
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.fedocumentos.count > 0 { self.headersView.lblTitle.textColor = UIColor.black }
        return self.fedocumentos.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentDetailCollectionViewCell.identifier, for: indexPath) as! DocumentDetailCollectionViewCell
        //cell.tapLabel.layer.cornerRadius = 8.0
        cell.widthCell.constant = (self.detailCollectionView.frame.width - 15)
        let obj = self.fedocumentos[indexPath.row]
        
        if (ConfigurationManager.shared.utilities.getDataFromFile("\(Cnstnt.Tree.anexos)/\(self.fedocumentos[indexPath.row].URL)") != nil) || self.porDescargar {
            if obj.Nombre.contains("formElec_element"){
                let index = obj.Nombre.index(obj.Nombre.endIndex, offsetBy: -23)
                let mySubstring = obj.Nombre.suffix(from: index)
                cell.lblNameFile.text = "\(mySubstring)".replacingOccurrences(of: ".ane", with: "\(obj.Ext)")
            }else{
                cell.lblNameFile.text = "\(obj.Nombre)".replacingOccurrences(of: ".ane", with: "\(obj.Ext)")
            }
            cell.btnPreviewAne.isHidden = false
            cell.imgDetailDoc.tag = indexPath.row
            cell.imgDetailDoc.isUserInteractionEnabled = true
            if let dataImg = ConfigurationManager.shared.utilities.getDataFromFile("\(Cnstnt.Tree.anexos)/\(self.fedocumentos[indexPath.row].URL)"){
                if let image = UIImage(data: dataImg){
                    cell.imgDetailDoc.image = image
                    //cell.tapLabel.isHidden = true
                }else{
                    cell.imgDetailDoc.image = UIImage(named: "ic_doc", in: Cnstnt.Path.framework, compatibleWith: nil)
                    //cell.tapLabel.isHidden = true
                }
                let tapgesture = UITapGestureRecognizer(target: self, action: #selector(previewTapImg(_:)))
                tapgesture.numberOfTapsRequired = 1
                cell.imgDetailDoc.addGestureRecognizer(tapgesture)
                if self.fedocumentos[indexPath.row].Ext.lowercased() == ".pdf" || self.fedocumentos[indexPath.row].Ext.lowercased() == "pdf" {
                    //cell.tapLabel.isHidden = true
                    let fileData = ConfigurationManager.shared.utilities.getDataFromFile("\(Cnstnt.Tree.anexos)/\(self.fedocumentos[indexPath.row].URL)")
                    let fileStream:String = fileData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0)) ?? String()
                    if let data = Data(base64Encoded: fileStream, options: .ignoreUnknownCharacters) {
                        let thumbnailSize = CGSize(width: 500, height: 500)
                        cell.imgDetailDoc.image = generatePdfThumbnail(of: thumbnailSize, for: URL(string: fileStream)!, data: data, atPage: 0)
                    }
                } else if self.fedocumentos[indexPath.row].Ext.lowercased().replacingOccurrences(of: ".", with: "") != "png" && self.fedocumentos[indexPath.row].Ext.lowercased().replacingOccurrences(of: ".", with: "") != "jpg" && self.fedocumentos[indexPath.row].Ext.lowercased().replacingOccurrences(of: ".", with: "") != "jpeg" {
                    cell.btnPreviewAne.isHidden = true
                    cell.imgDetailDoc.isUserInteractionEnabled = false
                }
            } else if self.porDescargar {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setDownloadAnexo(_:)))
                cell.imgDetailDoc.addGestureRecognizer(tapGestureRecognizer)
                cell.imgDetailDoc.image = UIImage(named: "download-attachment", in: Cnstnt.Path.framework, compatibleWith: nil)
            }
            
            self.printButton(bnt: cell.btnTypeDoc, act: 7, indx: indexPath.row)
            cell.imgValidate.isHidden = true
            var auxTypeDoc = "\(obj.TipoDoc)"
            if (!self.fedocumentos.isEmpty) && (listAllowed.count == 1) && self.okUnico && auxTypeDoc == "" {
                auxTypeDoc = (listAllowed.first ?? FEListTipoDoc()).value(forKey: "Descripcion") as! String
                cell.btnTypeDoc.isHidden = true
                cell.lblTypeDoc.text = " Tipo de documento: \(auxTypeDoc) "
            } else if auxTypeDoc != "" {
                cell.lblTypeDoc.text = " Tipo de documento: "
                auxTypeDoc = "\(obj.TipoDoc)      "
                cell.btnTypeDoc.setTitle(auxTypeDoc, for: .normal)
                //SI ESTA SELECCIONADO ALGUNA TIPIFICACIÓN Y ESTA TIENE METADATOS SE MUESTRA LA TABLA DE METADATOS
                let auxTem = self.docID
                self.docID = obj.TipoDocID ?? 0
                if self.getMetaData(){
                    let auxViews = cell.tblMetaData.arrangedSubviews
                    auxViews.forEach{ viewBtn in
                        cell.tblMetaData.removeArrangedSubview(viewBtn)
                        viewBtn.removeFromSuperview()
                    }
                    cell.tblMetaData.tag = indexPath.row
                    cell.imgValidate.isHidden = false
                    cell.imgValidate.backgroundColor = UIColor.white
                    cell.imgValidate.image = UIImage(named: "check_full", in: Cnstnt.Path.framework, compatibleWith: nil)
                    if obj.Metadatos.count != 0 {
                        for index in 0...(obj.Metadatos.count - 1) {
                            var tit = obj.Metadatos[index].Nombre
                            if obj.Metadatos[index].Obligatorio { tit += " *" }
                            let value = obj.Metadatos[index].NombreCampo
                            self.printTblMeta(stack: cell.tblMetaData, title: tit, value: value)
                        }
                    } else {
                        self.arrayMetadatos.forEach{ obj in
                            var tit = "\(obj.Nombre)"
                            if obj.Obligatorio {
                                tit += " *"
                                self.metaReq.setValue(self.docID, forKey: "\(obj.Nombre)|\(indexPath.row)")
                                cell.imgValidate.backgroundColor = UIColor.red
                                cell.imgValidate.image = UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil)
                            }
                            self.printTblMeta(stack: cell.tblMetaData, title: tit, value: obj.TipoDato.contains("bit") ? "false" : "")
                        }
                    }
                    
                    cell.heightMetaData.constant = CGFloat(self.arrayMetadatos.count * 25)
                    cell.tblMetaData.isHidden = false
                    
                    let tamActual = (row as? DocumentoRow)?.cell.contentView.frame.size.height ?? 0
                    let nvoTam = self.tamSinAnexos + 360.0 + cell.heightMetaData.constant
                    if tamActual < nvoTam {
                        self.tamConAnexos = nvoTam
                        //self.detailCollectionView.heightAnchor.constraint(equalToConstant: (320.0 + cell.heightMetaData.constant)).isActive = true
                        self.setVariableHeight(Height: nvoTam)
                    }
                } else {
                    cell.imgValidate.isHidden = false
                    cell.imgValidate.backgroundColor = UIColor.white
                    cell.imgValidate.image = UIImage(named: "check_full", in: Cnstnt.Path.framework, compatibleWith: nil)
                    cell.heightMetaData.constant = 0.0
                    cell.tblMetaData.isHidden = true
                }
                self.docID = auxTem
            } else {
                cell.heightMetaData.constant = 0.0
                cell.tblMetaData.isHidden = true
            }
            self.tamMaxMeta = cell.heightMetaData.constant > self.tamMaxMeta ? cell.heightMetaData.constant : self.tamMaxMeta
            let tamActual = (row as? DocumentoRow)?.cell.contentView.frame.size.height ?? 0
            let tamAprop = self.tamSinAnexos + 360.0 + self.tamMaxMeta
            if tamActual > tamAprop {
                if (indexPath.row + 1) == self.fedocumentos.count {
                    self.detailCollectionView.heightAnchor.constraint(equalToConstant: (320.0 + cell.heightMetaData.constant)).isActive = true
                    self.tamConAnexos = tamAprop
                    self.setVariableHeight(Height: tamAprop)
                }
            }
            
            self.setPermisoTipificar(self.atributos?.permisotipificar ?? false, cell.btnTypeDoc , cell.btnMeta, cell.lblTypeDoc)
            
            self.printButton(bnt: cell.btnMeta, act: 1, indx: indexPath.row)
            self.printButton(bnt: cell.btnPreviewAne, act: 2, indx: indexPath.row)
            self.printButton(bnt: cell.btnClean, act: 3, indx: indexPath.row)
            self.flagRem = false
            if self.anexosRecup != nil && (obj.DocID != 0) && (self.anexosRecup?[indexPath.row].DocID != 0) //isPublicado
            {
                
                cell.btnClean.isHidden = true
                //cell.btnTypeDoc.isEnabled = false
                //cell.btnMeta.isEnabled = false
                //self.printButton(bnt: cell.btnCamaraReemp, act: 4, indx: indexPath.row)
                self.printButton(bnt: cell.btnCancelReemp, act: 5, indx: indexPath.row)
                self.printButton(bnt: cell.btnImportReemp, act: 6, indx: indexPath.row)
                if self.arrayAnexosReemp.contains(where: {$0.key == indexPath.row})
                {
                    cell.btnCancelReemp.isHidden = false
                    cell.btnImportReemp.isHidden = true
                } else
                {
                    cell.btnCancelReemp.isHidden = true
                    cell.btnImportReemp.isHidden = self.btnActions.isHidden
                }
            } else
            {
                cell.btnClean.isHidden = false
                cell.btnCamaraReemp.isHidden = true
                cell.btnCancelReemp.isHidden = true
                cell.btnImportReemp.isHidden = true
            }
        }
        
        cell.lblNumAne.text = "\(indexPath.row + 1) de \(self.fedocumentos.count)"
        //if flagEdit{cell.btnMeta.isHidden = false}else{cell.btnMeta.isHidden = true}
        //cell.btnMeta.isHidden = true
        cell.btnPreviewAne.isHidden = true
        
        return cell
    }
    // Función genera PDF
    func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, data documentData: Data, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(data: documentData)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func printButton (bnt btnAction : UIButton, act action: Int, indx index: Int )
    {
        //btnAction.backgroundColor = UIColor(hexFromString: self.atributos?.color ?? "#1E88E5")
        btnAction.tag = index
        switch action {
            case 1:
                btnAction.addTarget(self, action: #selector(metaAction(_:)), for: .touchUpInside)
                break;
            case 2:
                if self.porDescargar{
                    btnAction.addTarget(self, action: #selector(setDownloadAnexo(_:)), for: .touchUpInside)
                } else {
                    btnAction.addTarget(self, action: #selector(togglePreviewAction(_:)), for: .touchUpInside)
                }
                break;
            case 3:
                btnAction.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
                break;
            case 5:
                btnAction.addTarget(self, action: #selector(btnCancelReempAction(_:)), for: .touchUpInside)
                break;
            case 6:
                btnAction.addTarget(self, action: #selector(btnReempAction(_:)), for: .touchUpInside)
                break;
            case 7:
                btnAction.setTitle(" Seleccione...      ", for: .normal)
                btnAction.addTarget(self, action: #selector(typeDocAction(_:)), for: .touchUpInside)
                break;
            default:
                break;
        }
    }
    
    func printTblMeta (stack stackGral : UIStackView, title ttlMeta: String, value valMeta: String)
    {
        //Stack Fila
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 3.0
        stackView.isUserInteractionEnabled = false
        
        //Label title meta
        let titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor(hexFromString: "#52A7A7A7")
        titleLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        titleLabel.textColor = UIColor.darkGray
        titleLabel.setText(ttlMeta, withColorPart: "*", color: .red)
        titleLabel.font = UIFont(name: "Helvetica-bold", size: 11.0)
        titleLabel.textAlignment = .left
        stackView.addArrangedSubview(titleLabel)
        
        switch valMeta {
            case "true",  "false":
                let grayView = UIView()
                grayView.backgroundColor = UIColor.systemGray
                grayView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
                let btnCheck: UIButton = UIButton(frame: CGRect(x: 5, y: 1, width: 19, height: 19))
                btnCheck.setTitleColor(UIColor.white, for: [])
                btnCheck.setTitle(valMeta, for: .normal)
                if NSString(string:valMeta).boolValue {
                    btnCheck.setImage(UIImage(named: "ic_check_c", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
                } else {
                    btnCheck.setImage(UIImage(named: "ic_uncheck", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
                }
                grayView.addSubview(btnCheck)
                stackView.addArrangedSubview(grayView)
                break;
            default:
                //Label value meta
                let valueLabel = UILabel()
                valueLabel.backgroundColor = UIColor(hexFromString: "#52A7A7A7")
                valueLabel.textColor = UIColor.darkGray
                valueLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
                valueLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
                var valueMeta = valMeta
                if valMeta.split(separator: "|").count == 3 {
                    valueMeta = String(valMeta.split(separator: "|").last ?? "")
                }
                valueLabel.text  = valueMeta 
                valueLabel.textAlignment = .left
                stackView.addArrangedSubview(valueLabel)
                break;
        }
        stackGral.addArrangedSubview(stackView)
    }
    
    @objc func checkAction(sender: UIButton) {
        if sender.titleLabel?.text == "false" {
            sender.setTitle("true", for: [])
            sender.setImage(UIImage(named: "ic_check_c", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        } else if sender.titleLabel?.text == "true" {
            sender.setTitle("false", for: [])
            sender.setImage(UIImage(named: "ic_uncheck", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        }
    }
    
    public func setPermisoTipificar(_ bool: Bool, _ btnTypeDoc: UIButton, _ btnMeta: UIButton, _ lblTypeDoc: UILabel){
        if bool{
            btnTypeDoc.isHidden = self.isMarcado != "" ? true : false
            btnMeta.isHidden = false
            lblTypeDoc.isHidden = false
        }else{
            btnTypeDoc.isHidden = true
            lblTypeDoc.isHidden = true
            if  self.tipUnica != nil{
                btnMeta.isHidden = false
            }else{
                 btnMeta.isHidden = true
            }
        }
    }
    
    // MARK: - ADD ANEXOS
    // Document Picker
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if !urls.isEmpty{
            for ext in urls{
                
                if (self.fedocumentos.count < self.atributos?.maximodocumentos ?? 99) || self.startReemp{
                    let fileExtension = String(describing: ext).fileExtension()
                    let doc = FEDocumento()
                    switch ConfigurationManager.shared.utilities.detectExtension(ext: fileExtension) {
                    case 1:
                        let imageURL = ext
                        
                        let guid = ConfigurationManager.shared.utilities.guid()
                        let image = try? UIImage(withContentsOfUrl: imageURL)
                        let p = "\(guid).ane"
                        
                        doc.guid = "\(guid)"
                        doc.isKindImage = true
                        doc.Ext = fileExtension.lowercased()
                        doc.ImageString = ""
                        doc.Nombre = p
                        doc.Path = p
                        doc.URL = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
                        doc.TipoDoc = ""
                        doc.TipoDocID = 0
                        
                        if self.startReemp {
                            FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.fedocumentos[self.idAnexoReemp].Nombre { $0.Reemplazado = true }}
                            if self.anexosRecup != nil{
                                for (_, data) in (self.anexosRecup ?? [FEAnexoData]() ).enumerated(){
                                    if data.FileName == self.fedocumentos[self.idAnexoReemp].Nombre {
                                        data.Reemplazado = true
                                        doc.DocID = data.DocID
                                    }
                                }
                                doc.TipoDocID = self.fedocumentos[self.idAnexoReemp].TipoDocID
                                doc.TipoDoc = self.fedocumentos[self.idAnexoReemp].TipoDoc
                                doc.Metadatos = self.fedocumentos[self.idAnexoReemp].Metadatos
                            }
                            self.fedocumentos[self.idAnexoReemp] = doc
                            // Guardamos el id con "r" y ruta del nuevo anexo en el array global
                            self.anexosDict.append((id: "\(self.idAnexoReemp)", url: doc.URL))
                        } else {
                            for list in self.listAllowed{
                                if tipUnica == nil{ break }
                                if list.CatalogoId != tipUnica{ continue }
                                doc.TipoDocID = tipUnica ?? 0
                                doc.TipoDoc = list.Descripcion
                                list.current += 1
                            }
                            doc.TipoDocID = tipUnica ?? 0
                            self.fedocumentos.append(doc)
                            // Guardamos el id y ruta del anexo en el array global
                            self.anexosDict.append((id: "\(self.fedocumentos.count - 1)", url: doc.URL))
                        }
                        let _ = ConfigurationManager.shared.utilities.saveImageToFolder(image!, doc.URL)
                        if self.isMarcado != ""
                        {   _ = self.formDelegate?.resolveValor(self.isMarcado, "asignacion", "\(String(describing: doc.TipoDocID))|\(doc.TipoDoc)" , nil)  }
                        break;
                    default:
                        let guid = ConfigurationManager.shared.utilities.guid()
                        let docData = try? Data(contentsOf: ext)
                        let p = "\(guid).ane"
                        doc.guid = "\(guid)"
                        doc.isKindImage = true
                        doc.Ext = fileExtension.lowercased()
                        doc.ImageString = "ic_doc"
                        doc.Nombre = p
                        doc.Path = p
                        doc.URL = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
                        doc.TipoDoc = ""
                        doc.TipoDocID = 0
                        
                        if self.startReemp {
                            FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.fedocumentos[self.idAnexoReemp].Nombre { $0.Reemplazado = true }}
                            if self.anexosRecup != nil{
                                for (_, data) in (self.anexosRecup ?? [FEAnexoData]() ).enumerated(){
                                    if data.FileName == self.fedocumentos[self.idAnexoReemp].Nombre {
                                        data.Reemplazado = true
                                        doc.DocID = data.DocID
                                    }
                                }
                                doc.TipoDocID = self.fedocumentos[self.idAnexoReemp].TipoDocID
                                doc.TipoDoc = self.fedocumentos[self.idAnexoReemp].TipoDoc
                                doc.Metadatos = self.fedocumentos[self.idAnexoReemp].Metadatos
                            }
                            self.fedocumentos[self.idAnexoReemp] = doc
                            // Guardamos el id con "r" y ruta del nuevo anexo en el array global
                            self.anexosDict.append((id: "\(self.idAnexoReemp)", url: doc.URL))
                        } else {
                            if tipUnica != nil{
                                for list in self.listAllowed{
                                    if list.CatalogoId != tipUnica{ continue }
                                    doc.TipoDocID = tipUnica ?? 0
                                    doc.TipoDoc = list.Descripcion
                                    list.current += 1
                                }
                            }
                            self.fedocumentos.append(doc)
                            // Guardamos el id y ruta del anexo en el array global
                            self.anexosDict.append((id: "\(self.fedocumentos.count - 1)", url: doc.URL))
                        }
                        let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(docData! as NSData, doc.URL)
                        if self.isMarcado != ""
                        {   _ = self.formDelegate?.resolveValor(self.isMarcado, "asignacion", "\(String(describing: doc.TipoDocID))|\(doc.TipoDoc)" , nil)  }
                        break;
                    }
                    setEdited(v: doc.URL)
                    self.detailCollectionView.isHidden = false
                    self.detailCollectionView.reloadData()
                    savingData()
                }else{
                    setMessage(String(format: "elemts_doc_max".langlocalized(), String(self.atributos?.maximodocumentos ?? 99)), .error)
                }
            }
        }
    }
    
    public func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        let presenter = Presentr(presentationType: .popup)
        self.formViewController()?.customPresentViewController(presenter, viewController: documentPicker, animated: true, completion: nil)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if self.startReemp {
            var auxArrayReemp = [(key: Int, value: FEDocumento)]()
            self.arrayAnexosReemp.forEach({
                if $0 != (key: self.idAnexoReemp, value: self.arrayAnexosReemp[self.idAnexoReemp].value) { auxArrayReemp.append($0) }
            })
            self.arrayAnexosReemp = auxArrayReemp
            self.startReemp = false
            self.idAnexoReemp = -1
        }
    }
    
    // Image Picker
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var image : UIImage!
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage { image = img }
        else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage { image = img }
        
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL, !self.atributos.extensionespermitidas.isEmpty {
            let extensionesPermitidas = self.atributos.extensionespermitidas.components(separatedBy: ",").map { $0.lowercased() }
            let fileType = url.pathExtension
            if !extensionesPermitidas.contains(fileType) {
                let extensionAlertController = UIAlertController(title: "Extension no permitida", message: "Extensiones permitidas son: \(extensionesPermitidas.joined(separator: ", "))", preferredStyle: .alert)
                extensionAlertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
                    extensionAlertController.dismiss(animated: true, completion: nil)
                }))
                (row as? DocumentoRow)?.cell.formCell()?.formViewController()?.present(extensionAlertController, animated: true, completion: nil)
                return
            }
        }
        
        // Detecting if Image Width and Height is greater than 1600
        let portraitImage = image.upOrientationImage()
        let resizeImage = portraitImage?.resized(withPercentage: 0.3)
        let jpgConversion = resizeImage?.jpegData(compressionQuality: 0.6)
        let jpgImage = UIImage(data: jpgConversion!)!
        
        if (self.fedocumentos.count < self.atributos?.maximodocumentos ?? 99) || self.startReemp {
            
            let guid = ConfigurationManager.shared.utilities.guid()
            let p = "\(guid).ane"
            let doc = FEDocumento()
            doc.guid = "\(guid)"
            doc.isKindImage = true
            doc.Ext = "png"
            doc.ImageString = ""
            doc.Nombre = p
            doc.Path = p
            doc.URL = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_1_\(guid).ane"
            doc.TipoDoc = ""
            doc.TipoDocID = 0
            
            if self.startReemp {
                FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.fedocumentos[self.idAnexoReemp].Nombre { $0.Reemplazado = true }}
                if self.anexosRecup != nil{
                    for (_, data) in (self.anexosRecup ?? [FEAnexoData]() ).enumerated(){
                        if data.FileName == self.fedocumentos[self.idAnexoReemp].Nombre {
                            data.Reemplazado = true
                            doc.DocID = data.DocID
                        }
                    }
                    doc.TipoDoc = self.fedocumentos[self.idAnexoReemp].TipoDoc
                    doc.TipoDocID = self.fedocumentos[self.idAnexoReemp].TipoDocID
                    doc.Metadatos = self.fedocumentos[self.idAnexoReemp].Metadatos
                }
                self.fedocumentos[self.idAnexoReemp] = doc
                // Guardamos el id y ruta del nuevo anexo en el array global
                self.anexosDict.append((id: "\(self.idAnexoReemp)", url: doc.URL))
            } else {
                if self.tipUnica != nil{
                    for list in self.listAllowed{
                        if list.CatalogoId != self.tipUnica{ continue }
                        doc.TipoDocID = self.tipUnica ?? 0
                        doc.TipoDoc = list.Descripcion
                        list.current += 1
                    }
                }
                self.fedocumentos.append(doc)
                // Guardamos el id y ruta del anexo en el array global
                self.anexosDict.append((id: "\(self.fedocumentos.count - 1)", url: doc.URL))
            }
            let _ = ConfigurationManager.shared.utilities.saveImageToFolder(jpgImage, doc.URL)
            if self.isMarcado != ""
            {   _ = self.formDelegate?.resolveValor(self.isMarcado, "asignacion", "\(String(describing: doc.TipoDocID))|\(doc.TipoDoc)" , nil)  }
            self.detailCollectionView.isHidden = false
            self.detailCollectionView.reloadData()
            self.setEdited(v: doc.URL)
            if !self.startReemp {   self.triggerRulesOnChange("addanexo") }
            self.savingData()
            
        }else{
            setMessage(String(format: "elemts_doc_max".langlocalized(), String(self.atributos?.maximodocumentos ?? 99)), .error)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        if self.startReemp {
            var auxArrayReemp = [(key: Int, value: FEDocumento)]()
            self.arrayAnexosReemp.forEach({
                if $0 != (key: self.idAnexoReemp, value: self.arrayAnexosReemp[self.idAnexoReemp].value) { auxArrayReemp.append($0) }
            })
            self.arrayAnexosReemp = auxArrayReemp
            self.startReemp = false
            self.idAnexoReemp = -1
        }
    }
}


// MARK: - OBJECTFORMDELEGATE
extension DocumentoCell: ObjectFormDelegate{
    
    public func toogleToolTip(_ help: String) { }
    public func setTextStyle(_ style: String){ }
    public func setDecoration(_ decor: String){ }
    public func setAlignment(_ align: String){ }
    public func setTitleText(_ text:String){ }
    public func setSubtitleText(_ text:String){ }
    public func setInfo(){ }
    public func setOcultarTitulo(_ bool: Bool){ }
    public func setOcultarSubtitulo(_ bool: Bool){ }
    public func setRequerido(_ bool: Bool){}
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){
        self.headersView.setMessage(string)
    }
    // MARK: Set - Height From Titles
    public func setHeightFromTitles(){
        var heightHeader : CGFloat = 0.0
        let ttl = self.headersView.lblTitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        let sttl = self.headersView.lblSubtitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        let msgerr = self.headersView.lblMessage.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        self.headersView.lblTitle.numberOfLines = ttl
        self.headersView.lblSubtitle.numberOfLines = sttl
        self.headersView.lblMessage.numberOfLines = msgerr
        
        var httl: CGFloat = 0
        var hsttl: CGFloat = 0
        let hmsg: CGFloat = (CGFloat(msgerr) * self.headersView.lblMessage.font.lineHeight) //1 estatico para error
        if !self.headersView.hiddenTit {
            httl = (CGFloat(ttl) * self.headersView.lblTitle.font.lineHeight)
        }
        if !self.headersView.hiddenSubtit {
            hsttl = (CGFloat(sttl) * self.headersView.lblSubtitle.font.lineHeight)
        }
        //Total de labels
        heightHeader = httl + hsttl + hmsg
        
        // Validación por si no hay titulo ni subtitulos a mostrar
        if (heightHeader - 25) < 0 {
            if !self.getRequired() && self.headersView.txthelp != "" {
                heightHeader = 40
            } else if !self.getRequired() || self.headersView.txthelp != "" {
                heightHeader = 25
            }
        }
        if self.headersView.frame.height < 6.0 {
            self.headersView.heightAnchor.constraint(equalToConstant: heightHeader).isActive = true
        }
        
        // Se actualiza el tamaño de la celda, agregando el alto del header
        self.tamSinAnexos = 50 + CGFloat(heightHeader)
        self.setVariableHeight(Height: self.tamSinAnexos)
    }
    
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Documento"
        est?.NombrePagina = atributos?.elementopadre ?? ""
        est?.OrdenCampo = atributos?.ordencampo ?? 0
        est?.PaginaID = Int(atributos?.elementopadre.replaceFormElec() ?? "0") ?? 0
        est?.FechaEntrada = ConfigurationManager.shared.utilities.getFormatDate()
        est?.Latitud = ConfigurationManager.shared.latitud
        est?.Longitud = ConfigurationManager.shared.longitud
        est?.Usuario = ConfigurationManager.shared.usuarioUIAppDelegate.User
        est?.Dispositivo = UIDevice().model
        est?.NombrePlantilla = ""
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
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) {
        DispatchQueue.main.async {
            self.height = {return h}
            self.layoutIfNeeded()
            self.row.reload()
            self.formDelegate?.reloadTableViewFormViewController()
        }
    }
    
    // MARK: Set - Habilitado
    public func setHabilitado(_ bool: Bool){
        self.elemento.validacion.habilitado = bool
        self.atributos?.habilitado = bool
        if bool{
            self.bgHabilitado.isHidden = true;
            self.btnPreview.isHidden = true;
        }else{
            self.bgHabilitado.isHidden = false;
            if self.anexosRecup != nil{
                self.btnPreview.isHidden = false;
            }
        }
    }
    
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil{
            var rules = RuleSet<String>()
            rules.add(rule: ReglaRequerido())
            self.row.add(ruleSet: rules)
            self.headersView.setRequerido(atributos?.requerido ?? false)
        }
    }
    // MARK: Set - MinMax
    public func setMinMax(){ }
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){ }
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){ }
    
    // MARK: Set - Prmiso Camara
    public func setPermisoCamara(_ bool: Bool){
        if self.atributos != nil{
            if bool{
                print("Activa permiso de camara")
            }else{
                print("Activa permiso de camara")
            }
        }
    }
    // MARK: Set - Permiso Importar
    public func setPermisoImportar(_ bool: Bool){
        if self.atributos != nil{
            if bool{
                print("Activa permiso de importar")
            }else{
                print("Activa permiso de importar")
            }
        }
    }
    // MARK: Set - Permiso Sin Imagen
    public func setPermisoSinImagen(_ bool: Bool){
        if self.atributos != nil{
            if bool{
                print("Activa permiso de sinImagen")
            }else{
                print("Activa permiso de sinImagen")
            }
        }
    }
    
    // MARK: Set - Edited
    public func setEdited(v: String){
        if v != ""{
            row.value = v
            let hh = (row as? DocumentoRow)?.cell.contentView.frame.size.height ?? 0
            self.tamConAnexos = self.tamConAnexos == 0.0 ? self.tamSinAnexos + 360.0 : self.tamConAnexos
            if (self.tamConAnexos != 0 && hh < self.tamConAnexos) || hh < self.tamSinAnexos + 360.0 {
                self.setVariableHeight(Height: tamConAnexos)
            }
            if v.contains("true"){
                if self.anexosRecup != nil{
                    self.saveDataFEDocumento(isEdited: true)
                    self.detailCollectionView.isHidden = false
                    self.detailCollectionView.reloadData()
                    self.updateIfIsValid()
                }
            }
        }else{
            row.value = nil
            self.anexosDict = [(id: "", url: "")]
            self.updateIfIsValid()
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
        
        triggerEvent("alcambiar")
        triggerRulesOnChange("addanexo")
    }
    
    public func setEdited(v: String, isRobot: Bool) { }
    // MARK: Set - Validation
    public func resetValidation(){
        if atributos != nil{
            self.elemento.validacion.needsValidation = atributos?.requerido ?? false
        }
    }
    // MARK: Set - Validation Metadatos
    public func validationMeta() -> Bool {
        var valid = true
        self.metaReq.allKeys.forEach({ keyFE in
            let id = String((keyFE as! String).split(separator: "|").last ?? "")
            let obj = self.fedocumentos[Int(id) ?? -1]
            if obj.Metadatos.count == 0 {
                valid = false
            }
        })
        
        if !valid {
            DispatchQueue.main.async {
                self.headersView.setMessage("Verifique el elemento, tiene metadatos obligatorios faltantes")
            }
            self.elemento.validacion.needsValidation = true
            self.elemento.validacion.validado = false
        }
        
        return valid
    }
    
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        if row.isValid || isDefault { // Setting row as valid
            if row.value == nil{
                if validationMeta() {
                    DispatchQueue.main.async {
                        self.headersView.setMessage("")
                        self.layoutIfNeeded()
                    }
                    self.elemento.validacion.anexos = [(id: String, url: String)]()
                    self.elemento.validacion.anexos = (row as? DocumentoRow)?.cell.anexosDict
                    ConfigurationManager.shared.extensionDoc = self.fedocumentos
                    self.elemento.validacion.validado = false
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                }
            }else{
                resetValidation()
                if validationMeta() {
                    DispatchQueue.main.async {
                        self.headersView.setMessage("")
                        self.layoutIfNeeded()
                    }
                    self.elemento.validacion.anexos = [(id: String, url: String)]()
                    self.elemento.validacion.anexos = (row as? DocumentoRow)?.cell.anexosDict
                    ConfigurationManager.shared.extensionDoc = self.fedocumentos
                    if row.isValid && row.value != "" {
                        self.elemento.validacion.validado = true
                        self.elemento.validacion.valor = self.tipodoc
                        self.elemento.validacion.valormetadato  = self.metaDIC.toJsonString()
                    }else{
                        self.elemento.validacion.validado = false
                        self.elemento.validacion.valor = ""
                        self.elemento.validacion.valormetadato = ""
                    }
                }
            }
        }else{
            // Throw the first error printed in the label
            DispatchQueue.main.async {
                if (self.row.validationErrors.count) > 0{
                    self.headersView.setMessage("  \(self.row.validationErrors[0].msg)  ")
                
                }
            }
            self.setVisible(self.atributos?.visible ?? false)
            if self.tipUnica != nil{
                /*if self.indexCollectionView < Int(self.maxTipUnica)! - 1 {
                    self.lblMessage.text = String(format: "elemts_doc_maxtyp_allow".langlocalized(), self.maxTipUnica)
                }*/
            }
            
            self.elemento.validacion.anexos = [(id: String, url: String)]()
            self.elemento.validacion.anexos = (row as? DocumentoRow)?.cell.anexosDict
            ConfigurationManager.shared.extensionDoc = self.fedocumentos
            self.elemento.validacion.needsValidation = true
            self.elemento.validacion.validado = false
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato = ""
        }
    }
    
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){}
    // MARK: Events
    public func triggerEvent(_ action: String) {}
    
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

// MARK: - ATTACHEDFORMDELEGATE
extension DocumentoCell: AttachedFormDelegate{
    public func didSetLocalAnexo(_ feAnexo: FEAnexoData) {}
    
    // MARK: Set - Local Anexo
    public func didSetLocalAnexoDoc(_ feAnexo: [FEAnexoData]){
        // Se guarda el array de anexos en la variable global (en caso de ser anexos descargados se actualiza con las nuevas url-path)
        self.anexosRecup = feAnexo
        //if self.anexo != nil{ self.btnPreview.isHidden = false; } //#REVISAR SI SE DEBE HACER VISIBLE O SOLO CUANDO ESTA INHABILITADO
        self.activity.stopAnimating()
        // Guardamos la información de los anexos en otros formatos de variables globales
        self.saveDataFEDocumento()
        self.savingData()
        self.detailCollectionView.isHidden = false
        self.detailCollectionView.reloadData()
        if !self.fedocumentos.isEmpty && listAllowed.count == 1 && self.okUnico { /*cell.lblTypeDoc.text = (listAllowed.first ?? FEListTipoDoc()).value(forKey: "Descripcion") as? String*/} // #REVISAR SI SE QUEDA O SE BORRA EN LA TIPIFICACIÓN UNICA
        self.setMessage("", .info)
        self.updateIfIsValid()
    }
    
    func saveDataFEDocumento (isEdited : Bool = false)
    {
        // Se limpia array de match id del anexo- ruta path
        if !isEdited { self.anexosDict = [] }
        // Se limpia el array global de anexos en formato: FEDocumento y se recorre el array de anexos
        self.fedocumentos = [FEDocumento]()
        for (index, data) in self.anexosRecup!.enumerated(){
            // Si no es reemplazado, creo un objeto FEDocumento con los datos del anexo
            if !data.Reemplazado {
                let documentAnexo: FEDocumento = FEDocumento()
                documentAnexo.guid = data.GuidAnexo
                if data.Extension.isEmpty{
                    let fileExtension = data.FileName.fileExtension().lowercased()
                    documentAnexo.Ext = fileExtension
                }else{
                    documentAnexo.Ext = data.Extension
                }
                documentAnexo.Path = data.FileName
                documentAnexo.Nombre = data.FileName.cleanAnexosDocPath()
                documentAnexo.URL = data.FileName
                for docType in listAllowed{
                    if data.TipoDocID == docType.CatalogoId{
                        documentAnexo.TipoDoc = docType.Descripcion
                    }
                }
                documentAnexo.isKindImage = true
                documentAnexo.TipoDocID = data.TipoDocID
                switch ConfigurationManager.shared.utilities.detectExtension(ext: data.Extension) {
                case 1:
                    documentAnexo.ImageString = ""
                    break;
                default:
                    documentAnexo.ImageString = "ic_doc"
                    break;
                }
                documentAnexo.DocID = data.DocID
                // Guardamos el obj aux FEDocumento en el array global
                self.fedocumentos.append(documentAnexo)
                // Guardamos el id y ruta del anexo en el array global
                self.anexosDict.append((id: "\(index)", url: data.FileName))
                if !isEdited {
                    if FCFileManager.existsItem(atPath: data.FileName){
                        setEdited(v: "\(data.FileName)")
                    }else{
                        self.setMessage("elemts_attch_server".langlocalized(), .info)
                    }
                }
            }
        }
        
        do{
            let auxValuesMeta = try JSONSerializer.toDictionary(self.elemento.validacion.valormetadato )
            for ( _, fedocMeta) in auxValuesMeta.enumerated() { // Metadatos recuperados
                let valuesMeta = fedocMeta.value as? NSDictionary ?? NSDictionary()
                if valuesMeta.count > 0{
                    var metaDatosFED : [FEListMetadatosHijos] = []
                    for (index, fedocto) in self.fedocumentos.enumerated() { // fedocumentos recuperados
                        if (fedocMeta.key as! String) == "\(fedocto.guid)" { // se compara si existen metadatos del fedocumento
                            self.docID = fedocto.TipoDocID ?? 0
                            if self.getMetaData(){
                                self.arrayMetadatos.forEach ({ meta in
                                    let auxMeta : FEListMetadatosHijos = FEListMetadatosHijos()
                                    auxMeta.Accion = meta.Accion
                                    auxMeta.EsEditable = meta.EsEditable
                                    auxMeta.Expresion_Regular = meta.Expresion_Regular
                                    auxMeta.FolioAut = meta.FolioAut
                                    auxMeta.Longitud_Maxima = meta.Longitud_Maxima
                                    auxMeta.Longitud_Minima = meta.Longitud_Minima
                                    auxMeta.Mascara = meta.Mascara
                                    auxMeta.MetadatoId = meta.MetadatoId
                                    auxMeta.Nombre = meta.Nombre
                                    auxMeta.Obligatorio = meta.Obligatorio
                                    auxMeta.TipoDato = meta.TipoDato
                                    auxMeta.TipoDatoId = meta.TipoDatoId
                                    auxMeta.TipoDoc = meta.TipoDoc
                                    if ((fedocMeta.value as! NSDictionary).value(forKey: "\(auxMeta.Nombre)_Desc") != nil) {
                                        let valDesc : String = "\(valuesMeta.value(forKey: "\(auxMeta.Nombre)_Desc") ?? "")"
                                        auxMeta.NombreCampo = "\(valuesMeta.value(forKey: auxMeta.Nombre) ?? "")|_Desc|\(valDesc)"
                                    } else {
                                        auxMeta.NombreCampo = "\(valuesMeta.value(forKey: auxMeta.Nombre) ?? "")"
                                    }
                                    metaDatosFED.append(auxMeta)
                                })
                                self.metadatosFEDocumentos[index] = metaDatosFED
                                self.fedocumentos[index].Metadatos = metaDatosFED
                            }
                        }
                    }
                }
            }
        }catch{
        }
    }
    
    // MARK: Save anexo
    public func savingData(){
        
        // Array de match: tipo de documento con guid
        let tipodoc: NSMutableDictionary = NSMutableDictionary();
        // Array de match: diccionario de metadatos con guid
        let meta: NSMutableDictionary = [:]
        // Se recorre el array global de anexos con formato: FEDocumento
        for (indexAux, fedoc) in self.fedocumentos.enumerated(){
            // Array de metadatos del anexo
            let metadata: NSMutableDictionary = NSMutableDictionary()
            // De forma numerada se obtienen los datos del anexo y se llenan los array de información
            tipodoc.setValue("\(String(fedoc.TipoDocID ?? 0))", forKey: "\(fedoc.guid)");
            // Se recorre el array de metadatos del anexo (en caso de tener)
            self.metadatosFEDocumentos[indexAux]?.forEach({ metaFe in
                metadata.setValue("\(metaFe.NombreCampo)", forKey: "\(metaFe.Nombre)");
                if "\(metaFe.NombreCampo)" != "" {
                    if "\(metaFe.NombreCampo)".split(separator: "|").count == 3 {
                        metadata.setValue(String(metaFe.NombreCampo.split(separator: "|").first ?? ""), forKey: "\(metaFe.Nombre)");
                        let _Desc = String(metaFe.NombreCampo.split(separator: "|").last ?? "")
                        metadata.setValue(_Desc, forKey: "\(metaFe.Nombre)_Desc");
                    }
                }
            })
            meta.setValue(metadata, forKey: "\(fedoc.guid)")
        }
        
        self.elemento.validacion.valor = tipodoc.toJsonString()
        self.elemento.validacion.valormetadato = meta.toJsonString()
        self.tipodoc = tipodoc.toJsonString()
        self.metaDIC = meta
        self.elemento.validacion.anexos = self.anexosDict
        self.setEdited(v: "Tipo de documento respaldado")
        self.startReemp = false
        self.idAnexoReemp = -1
    }
    
    // MARK: Set - Anexo Option
    public func setAnexoOption(_ anexo: FEAnexoData){}
    // anexo publicado para descargar y recuperar
    public func setAnexoOptionDoc(_ anexo: [FEAnexoData]){
        // Se guarda el array de anexos en la variable global (en caso de ser anexos descargados se actualiza con las nuevas url-path)
        self.anexosRecup = anexo
        anexosDict = []
        // Guardamos la información de los anexos en otros formatos de variables globales
        self.saveDataFEDocumento(isEdited: true)
        self.savingData()
        self.porDescargar = true
        self.detailCollectionView.isHidden = false
        self.detailCollectionView.reloadData()
        self.updateIfIsValid()
        for (_, data) in anexo.enumerated(){
            if data.Reemplazado
            {
                self.anexosDict.append((id: "reemplazo", url: data.FileName))
                triggerRulesOnChange("replaceanexo")
            }
        }
    }
    
    
    // MARK: Set - Attributes to Controller
    public func setAttributesToController(){ }
    
    // MARK: Set - Anexo
    public func setAnexo(_ anexo: FEAnexoData) {}
    
    
    
}

extension DocumentoCell{
    // MARK: Get's for every IBOUTLET in side the component
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

//extension DocumentoCell : GeniusEscanerViewControllerDelegate {
//    public func escanerResult(image: UIImage) {
//        if (self.fedocumentos.count < self.atributos?.maximodocumentos ?? 99) || self.startReemp {
//
//            let pdfDocument = PDFDocument()
//            let pdfPage = PDFPage(image: image)
//            pdfDocument.insert(pdfPage!, at: 0)
//
//
//            let guid = ConfigurationManager.shared.utilities.guid()
//            let p = "\(guid).ane"
//            let doc = FEDocumento()
//            doc.guid = "\(guid)"
//            doc.isKindImage = true
//            doc.Ext = "pdf"
//            doc.ImageString = ""
//            doc.Nombre = p
//            doc.Path = p
//            doc.URL = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_1_\(guid).ane"
//            doc.TipoDoc = ""
//            doc.TipoDocID = 0
//
//            if self.startReemp {
//                FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.fedocumentos[self.idAnexoReemp].Nombre { $0.Reemplazado = true }}
//                if self.anexosRecup != nil{
//                    for (_, data) in (self.anexosRecup ?? [FEAnexoData]() ).enumerated(){
//                        if data.FileName == self.fedocumentos[self.idAnexoReemp].Nombre {
//                            data.Reemplazado = true
//                            doc.DocID = data.DocID
//                        }
//                    }
//                    doc.TipoDoc = self.fedocumentos[self.idAnexoReemp].TipoDoc
//                    doc.TipoDocID = self.fedocumentos[self.idAnexoReemp].TipoDocID
//                    doc.Metadatos = self.fedocumentos[self.idAnexoReemp].Metadatos
//                }
//                self.fedocumentos[self.idAnexoReemp] = doc
//                // Guardamos el id y ruta del nuevo anexo en el array global
//                self.anexosDict.append((id: "\(self.idAnexoReemp)", url: doc.URL))
//            } else {
//                if self.tipUnica != nil{
//                    for list in self.listAllowed{
//                        if list.CatalogoId != self.tipUnica{ continue }
//                        doc.TipoDocID = self.tipUnica ?? 0
//                        doc.TipoDoc = list.Descripcion
//                        list.current += 1
//                    }
//                }
//                self.fedocumentos.append(doc)
//                // Guardamos el id y ruta del anexo en el array global
//                self.anexosDict.append((id: "\(self.fedocumentos.count - 1)", url: doc.URL))
//            }
//            let _ = ConfigurationManager.shared.utilities.savePDFToFolder(pdfDocument, doc.URL)
//            if self.isMarcado != ""
//            {   _ = self.formDelegate?.resolveValor(self.isMarcado, "asignacion", "\(String(describing: doc.TipoDocID))|\(doc.TipoDoc)" , nil)  }
//            self.detailCollectionView.isHidden = false
//            self.detailCollectionView.reloadData()
//            self.setEdited(v: doc.URL)
//            if !self.startReemp {   self.triggerRulesOnChange("addanexo") }
//            self.savingData()
//        }
//
//    }
//
//    public func errorEscaner(mensaje: String, error: Error?) {
//        let alert = UIAlertController(title: "Error Escaneo", message: mensaje, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
//            alert.dismiss(animated: true, completion: nil)
//        }))
//
//        let presenter = Presentr(presentationType: .popup)
//        self.formViewController()?.customPresentViewController(presenter, viewController: alert, animated: true, completion: nil)
//    }
//}
