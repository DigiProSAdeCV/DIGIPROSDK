import Foundation
import AVFoundation
import MobileCoreServices
import UIKit
import Eureka
#if canImport(WeScan)
import WeScan
#endif

class Historico: EVObject {
    public var DocPId: Int = 0
    public var DocID: Int = 0
    public var ExpID: Int = 0
    public var TipoDocID: Int = 0
    public var Descripcion: String = ""
    public var Error: Int = 0
    public var PermisoID: Int = 0
    public var Extension: String = ""
    public var Fecha_Creacion: String = ""
}

protocol HistorialCellProtocol: AnyObject{
    func displayImagePreview(tag:Int)
}

class HistorialCell: UITableViewCell{
    weak var delegate: HistorialCellProtocol?
    lazy var titleBtn: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    lazy var watchBtn: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.setImage(UIImage(named: "eye-solid", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(onDisplayImage(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        contentView.addSubview(titleBtn)
        contentView.addSubview(watchBtn)
        NSLayoutConstraint.activate([
            titleBtn.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleBtn.trailingAnchor.constraint(equalTo: watchBtn.leadingAnchor, constant: -10),
            titleBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            watchBtn.heightAnchor.constraint(equalToConstant: 35),
            watchBtn.widthAnchor.constraint(equalToConstant: 35),
            watchBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            watchBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func onLoadData(historico: Historico?, delegate: HistorialCellProtocol?){
        titleBtn.text = historico?.Descripcion
        self.delegate = delegate
    }
    
    @objc func onDisplayImage(_ sender: UIButton){
        delegate?.displayImagePreview(tag: self.tag)
    }
}

open class ImagenCell: Cell<String>, CellType, APIDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  UIDocumentPickerDelegate {

    lazy var headersView: HeaderView = {
        let hv = HeaderView(frame: .zero)
        hv.translatesAutoresizingMaskIntoConstraints = false
        return hv
    }()
    lazy var btnActions: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.backgroundColor = UIColor.init(hexString: "#00B2F2")
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(btnActionsAction(_:)), for: .touchUpInside)
        return btn
    }()
    lazy var lblTitleBtn: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.text = "Agregar"
        lbl.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var imgPreview: UIImageView = {
        let img = UIImageView(frame: .zero)
        img.backgroundColor = .clear
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.isHidden = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setPreview(_:)))
        img.isUserInteractionEnabled = true
        img.addGestureRecognizer(tapGestureRecognizer)
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    lazy var stackOptions: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.spacing = 10
        stack.axis = .horizontal
        stack.isHidden = true
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(stackHistoric)
        stack.addArrangedSubview(stackModificar)
        stack.addArrangedSubview(stackFiltros)
        stack.addArrangedSubview(stackReemp)
        stack.addArrangedSubview(stackClean)
        return stack
    }()
    lazy var stackHistoric: UIStackView = {
        let stack = UIStackView(frame: .zero)
       // stack.isHidden = (formDelegate?.getFormatoDataObject().DocID == 0 || formDelegate?.getFormatoDataObject().DocID == nil) ? true : false
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(watchHistoric)
        stack.addArrangedSubview(lblWatchHistoric)
        return stack
    }()
    lazy var stackFiltros: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(btnFiltros)
        stack.addArrangedSubview(lblFiltros)
        return stack
    }()
    lazy var stackModificar: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(btnModificar)
        stack.addArrangedSubview(lblModificar)
        return stack
    }()
    lazy var stackReemp: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(btnReempAndCancel)
        stack.addArrangedSubview(lblReempAndCancel)
        stack.isHidden = true
        return stack
    }()
    lazy var stackClean: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(btnClean)
        stack.addArrangedSubview(lblClean)
        return stack
    }()
    
   
    lazy var watchHistoric: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.init(hexString: "#16ABF1")
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(self.watchHistoricActions(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            btn.heightAnchor.constraint(equalToConstant: 40)
        ])
        return btn
    }()
    lazy var lblWatchHistoric: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        lbl.text = "Historial"
        return lbl
    }()
    lazy var btnModificar: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.init(hexString: "#16ABF1")
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(btnModificarAction(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            btn.heightAnchor.constraint(equalToConstant: 40)
        ])
        return btn
    }()
    lazy var lblModificar: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        lbl.text = "Modificar"
        return lbl
    }()
    lazy var btnFiltros: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.init(hexString: "#16ABF1")
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(btnfiltrosAction(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            btn.heightAnchor.constraint(equalToConstant: 40)
        ])
        return btn
    }()
    lazy var lblFiltros: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Filtros"
        lbl.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        return lbl
    }()
    lazy var btnClean:UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.init(hexString: "#16ABF1")
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(btnCleanAction(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            btn.heightAnchor.constraint(equalToConstant: 40)
        ])
        return btn
    }()
    lazy var lblClean: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Eliminar"
        lbl.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        return lbl
    }()
    lazy var btnReempAndCancel: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.init(hexString: "#16ABF1")
        btn.addTarget(self, action: #selector(btnReempAndCancelAction(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            btn.heightAnchor.constraint(equalToConstant: 40)
        ])
        return btn
    }()
    lazy var lblReempAndCancel: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Sustituir"
        lbl.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        return lbl
    }()
    
    lazy var btnMeta: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(metaAction(_:)), for: .touchUpInside)
        btn.backgroundColor = UIColor.init(hexString: "#16ABF1")
        btn.layer.cornerRadius = 20
        btn.setImage(UIImage(named: "ic_meta", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.isHidden = true
        return btn
    }()
    lazy var typeDocButton: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(typeDocAction(_:)), for: .touchUpInside)
        btn.backgroundColor = UIColor.init(hexString: "#16ABF1")
        btn.setTitle("Seleccione...      ", for: .normal)
        btn.isHidden = true
        btn.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.tintColor = .white
        return btn
    }()
    lazy var lblTypeDoc: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Tipo de documento: "
        lbl.isHidden = true
        lbl.font = UIFont.init(name: "Lato-Regular", size: 16)
        return lbl
    }()
    lazy var bgHabilitado: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(hexString: "#E8ECEE")
        return view
    }()
    
    lazy var previewline: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var historialTable: UITableView = {
        let view = UITableView.init(frame: .zero, style: UITableView.Style.grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.isScrollEnabled = false
        view.register(HistorialCell.self, forCellReuseIdentifier: "HistorialCell")
        view.delegate = self
        view.dataSource = self
        view.isHidden = true
        return view
    }()
    var messageHistorialList = ""
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var elemento = Elemento()
    public var atributos: Atributos_imagen!
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    // Anexos
    public var anexo: FEAnexoData?
    public var anexosDict = [ (id: "", url: ""), (id: "", url: "") ]
    public var docTypeDict = [(catalogoId: 0, descripcion: ""),(catalogoId: 0, description: "" )] as [Any]
    public var isServiceMessageDisplayed = 0
    public var estiloBotones: String = ""
    
    // Tipificación
    public var tipUnica: Int?
    public var listAllowed: [FEListTipoDoc] = []
    public var path = ""
    public var pathOCR: String = ""
    public var fedocumento: FEDocumento = FEDocumento()
    public var fedocReemp : FEDocumento = FEDocumento()
    public var anexoReemp: FEAnexoData?
    public var startReemp : Bool = false
    // Tipificación
    
    // PRIVATE
    #if canImport(WeScan)
    var scannerViewController: ImageScannerController!
    #endif
    var sdkAPI : APIManager<ImagenCell>?
    let guid = ConfigurationManager.shared.utilities.guid()
    var vw: MetaAttributesViewController = MetaAttributesViewController()
    var docID: Int = 0
    var arrayMetadatos: [FEListMetadatosHijos] = []
    var heightHeaderCell : CGFloat = 0.0
    var imgOriginal : UIImage?
    var historicList: [Historico]?{
        didSet{
            DispatchQueue.main.async { [weak self] in
                self?.historialTable.reloadData()
            }
        }
    }
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
        (row as? ImagenRow)?.presentationMode = nil
    }
    
    override open func update() {
        super.update()
    }
    
    // MARK: - INIT
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        
        contentView.addSubview(headersView)
        contentView.addSubview(btnActions)
        contentView.addSubview(lblTitleBtn)
        contentView.addSubview(imgPreview)
        contentView.addSubview(stackOptions)
        contentView.addSubview(btnMeta)
        contentView.addSubview(typeDocButton)
        contentView.addSubview(lblTypeDoc)
        contentView.addSubview(bgHabilitado)
        contentView.addSubview(previewline)
        contentView.addSubview(historialTable)
        
        let apiMeta = MetaFormManager<ImagenCell>()
        apiMeta.delegate = self
        
        sdkAPI = APIManager<ImagenCell>()
        contentView.addSubview(vw.view)
        vw.view.isHidden = true
        vw.view.translatesAutoresizingMaskIntoConstraints = false
        
        vw.view.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        vw.view.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        vw.view.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        vw.view.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        vw.delegate = apiMeta.delegate
        
        let anchor = 40.0
        NSLayoutConstraint.activate([
        
            headersView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            headersView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            headersView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            btnActions.topAnchor.constraint(equalTo: headersView.bottomAnchor, constant: 10),
            btnActions.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            btnActions.heightAnchor.constraint(equalToConstant: 40.0),
            btnActions.widthAnchor.constraint(equalToConstant: anchor),
            lblTitleBtn.centerXAnchor.constraint(equalTo: btnActions.centerXAnchor),
            lblTitleBtn.topAnchor.constraint(equalTo: btnActions.bottomAnchor, constant: 3),
            
            imgPreview.topAnchor.constraint(equalTo: headersView.bottomAnchor, constant: 5),
            imgPreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 75),
            imgPreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -75),
            imgPreview.heightAnchor.constraint(equalToConstant: 250.0),
            
            btnMeta.topAnchor.constraint(equalTo: imgPreview.bottomAnchor, constant: 5),
            btnMeta.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            btnMeta.widthAnchor.constraint(equalToConstant: 40.0),
            btnMeta.heightAnchor.constraint(equalToConstant: 40.0),
            
            stackOptions.topAnchor.constraint(equalTo: imgPreview.bottomAnchor, constant: 5),
            stackOptions.centerXAnchor.constraint(equalTo: imgPreview.centerXAnchor),
            watchHistoric.widthAnchor.constraint(equalToConstant: anchor),
            btnModificar.widthAnchor.constraint(equalToConstant: anchor),
            btnFiltros.widthAnchor.constraint(equalToConstant: anchor),
            btnClean.widthAnchor.constraint(equalToConstant: anchor),
            btnReempAndCancel.widthAnchor.constraint(equalToConstant: anchor),
            
            lblTypeDoc.topAnchor.constraint(equalTo: stackOptions.bottomAnchor, constant: 5),
            lblTypeDoc.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            typeDocButton.topAnchor.constraint(equalTo: stackOptions.bottomAnchor, constant: 5),
            typeDocButton.leadingAnchor.constraint(equalTo: lblTypeDoc.trailingAnchor, constant: 5),
            typeDocButton.heightAnchor.constraint(equalToConstant: 40.0),
            
            historialTable.topAnchor.constraint(equalTo: stackOptions.bottomAnchor, constant: 10),
            historialTable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            historialTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            historialTable.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            previewline.heightAnchor.constraint(equalToConstant: 0.5),
            previewline.leadingAnchor.constraint(equalTo: historialTable.leadingAnchor, constant: -5),
            previewline.trailingAnchor.constraint(equalTo: historialTable.trailingAnchor, constant: 5),
            previewline.bottomAnchor.constraint(equalTo: historialTable.topAnchor, constant: -5),
            
            bgHabilitado.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgHabilitado.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bgHabilitado.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bgHabilitado.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
           
        ])
        lblTitleBtn.isHidden = btnActions.titleLabel?.text == lblTitleBtn.text! ? true : false
        lblFiltros.isHidden = btnFiltros.titleLabel?.text == lblFiltros.text! ? true : false
        lblClean.isHidden = btnClean.titleLabel?.text == lblClean.text! ? true : false
        lblReempAndCancel.isHidden = btnReempAndCancel.titleLabel?.text == lblReempAndCancel.text! ? true : false
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        
        if self.headersView.isInfoToolTipVisible{
            self.headersView.toolTip!.dismiss()
            self.headersView.isInfoToolTipVisible = false
        }
    }
    
    // MARK: SETTING
    /// SetObject for ImagenRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_imagen
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? ImagenRow)?.cell.formCell()?.formViewController()?.tableView
        self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false)
        self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
    
        self.stackFiltros.isHidden = self.atributos.normalizacion == "Manual" ? false : true
        self.lblClean.textColor = UIColor(hexFromString: atributos?.colortextoborrar ?? "#FFFFFF")
        self.lblReempAndCancel.textColor = UIColor(hexFromString: atributos?.colortextoreemplazar ?? "#FFFFFF")
        self.lblModificar.textColor = UIColor(hexFromString: atributos?.colortextotomarfoto ?? "#FFFFFF")
        self.lblWatchHistoric.textColor = UIColor(hexFromString: atributos?.colortextotomarfoto ?? "#FFFFFF")
        self.lblTitleBtn.textColor = UIColor(hexFromString: atributos?.colortextotomarfoto ?? "#FFFFFF")
        
        btnMeta.backgroundColor = UIColor(hexFromString: atributos?.colortomarfoto ?? "#1E88E5")
        
        typeDocButton.backgroundColor = UIColor(hexFromString: atributos?.colortomarfoto ?? "#1E88E5")
        self.lblFiltros.textColor = UIColor(hexFromString: atributos?.colortextotomarfoto ?? "#FFFFFF")
        
        self.btnActions = (self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnActions, nameIcono: "ic_agregar", titulo: self.lblTitleBtn.text!, colorFondo: atributos?.colortomarfoto ?? "#1E88E5", colorTxt: atributos?.colortextotomarfoto ?? "#FFFFFF"))!
       
        self.btnModificar = (self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnModificar, nameIcono: "ic_modificar", titulo: self.lblModificar.text!, colorFondo: atributos?.colortomarfoto ?? "#1E88E5", colorTxt: atributos?.colortextotomarfoto ?? "#FFFFFF"))!
       
        self.btnFiltros = (self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnFiltros, nameIcono: "ic_filtros", titulo: self.lblFiltros.text!, colorFondo: atributos?.colortomarfoto ?? "#1E88E5", colorTxt: atributos?.colortextotomarfoto ?? "#FFFFFF"))!
        
        self.btnClean = (self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnClean, nameIcono: "ic_delete", titulo: self.lblClean.text!, colorFondo: atributos?.colorborrar ?? "#1E88E5", colorTxt: atributos?.colortextoborrar ?? "#FFFFFF"))!
       
        self.btnReempAndCancel = (self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnReempAndCancel, nameIcono: "ic_sustituir", titulo: self.lblReempAndCancel.text!, colorFondo: atributos?.colorreemplazar ?? "#1E88E5", colorTxt: atributos?.colortextoreemplazar ?? "#FFFFFF"))!
    
        
        self.watchHistoric = (self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.watchHistoric, nameIcono: "ic_toggle", titulo: self.lblWatchHistoric.text!, colorFondo: atributos?.colortomarfoto ?? "#1E88E5", colorTxt: atributos?.colortextotomarfoto ?? "#FFFFFF"))!
        btnActions.layer.cornerRadius = 20
        watchHistoric.layer.cornerRadius = 20
        btnReempAndCancel.layer.cornerRadius = 20
        btnClean.layer.cornerRadius = 20
        btnFiltros.layer.cornerRadius = 20
        btnModificar.layer.cornerRadius = 20
        self.getTipificacionPermitida()
        self.setHeightFromTitles()
    }
    
    
    // MARK: - PROTOCOLS APIDELEGATE
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    

    // MARK: - ACTIONS
    
    /// Consume attachment history service
    @objc func watchHistoricActions(_ sender: UIButton) {
        let format = formDelegate?.getFormatoDataObject()
        let data: [String: Any] = ["proyid": "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)", "docid":"\(format?.DocID ?? 0)", "docidanexo":"\(anexo?.DocID ?? 0)"]
        
        sdkAPI?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioFEExtern.HistoricoAnexo", assemblypath: "ServiciosDigipro.dll", data: data).then({ response in
            do {
                let dictionary = try JSONSerializer.toDictionary(response)
                guard let response = dictionary["response"] as? NSMutableDictionary else {
                    self.historicList = []
                    DispatchQueue.main.async {
                        self.messageHistorialList = "Sin resultados"
                        self.historialTable.isHidden = false
                        self.previewline.isHidden = false
                        self.setVariableHeight(Height: 320 + self.heightHeaderCell + 35)
                    }
                    return
                }

                if response["success"] as? Int != 1 { // Responde 1
                    self.historicList = []
                    DispatchQueue.main.async {
                        self.messageHistorialList = "Sin resultados"
                        self.historialTable.isHidden = false
                        self.previewline.isHidden = false
                        self.setVariableHeight(Height: 320 + self.heightHeaderCell + 35)
                    }
                }
                
                guard let data = dictionary["data"] as? NSMutableDictionary, let historic = data["Historico"] as? Array<NSDictionary> else {
                    let servicemessage = response["servicemessage"] as? String ?? ""
                    self.messageHistorialList = servicemessage
                    self.historicList = []
                    DispatchQueue.main.async {
                        self.historialTable.isHidden = false
                        self.previewline.isHidden = false
                        self.setVariableHeight(Height: 320 + self.heightHeaderCell + 35)
                    }
                    return
                }
                var historicArray = [Historico]()
                for dictionaryElement in historic{
                    let historic = Historico(dictionary: dictionaryElement)
                    if historic.Extension.lowercased() == ".png" || historic.Extension.lowercased() == ".jpeg" || historic.Extension.lowercased() == ".jpg" {
                        historicArray.append(historic)
                    }
                }
                
                self.historicList = historicArray
                DispatchQueue.main.async {
                    self.messageHistorialList = "Anexos remplazados"
                    self.historialTable.isHidden = false
                    self.previewline.isHidden = false
                    self.setVariableHeight(Height: 320 + self.heightHeaderCell + (CGFloat(self.historicList?.count ?? 0) * 35))
                }
                
            } catch {
                self.historicList = []
                DispatchQueue.main.async {
                    self.messageHistorialList = "Sin resultados"
                    self.historialTable.isHidden = false
                    self.previewline.isHidden = false
                    self.setVariableHeight(Height: 320 + self.heightHeaderCell + 35)
                }
            }

        }).catch({ error in
            print(error.localizedDescription)
            self.historicList = []
            DispatchQueue.main.async {
                self.messageHistorialList = "Sin resultados"
                self.historialTable.isHidden = false
                self.previewline.isHidden = false
                self.setVariableHeight(Height: 320 + self.heightHeaderCell + (CGFloat(self.historicList?.count ?? 0) * 35))
            }
        })
    }
    
    // Lanza acciones de imagen
    @objc func btnActionsAction(_ sender: UIButton) {
        var alert = UIAlertController()
        alert = UIAlertController(title: "Agregar", message: "", preferredStyle: .actionSheet)
        
        let alertCamera = UIAlertAction(title: "Por cámara", style: .default , handler:{ [self] (UIAlertAction)in
            self.btnCamaraAction()
        })
        alert.addAction(alertCamera)

        let alertLibrary = UIAlertAction(title: "Por biblioteca", style: .default , handler:{ [self] (UIAlertAction)in
            self.openGallery()
        })
        alert.addAction(alertLibrary)
        
        let alertDocuments = UIAlertAction(title: "Por almacenamiento", style: .default , handler:{ (UIAlertAction)in
            self.openFiles()
        })
        alert.addAction(alertDocuments)
        
        let alertCancel = UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            self.anexoReemp = nil
            self.fedocReemp = FEDocumento()
            self.startReemp = false
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
    
    // Lanza opciones para modificar imagen
    @objc func btnModificarAction(_ sender: UIButton) {
    let controller = FiltrosModificarViewController(nibName: "FiltroModifImagen", bundle: Cnstnt.Path.framework)
    controller.atributos = self.atributos
    controller.row = self.row
    controller.tipo = "Modificar"
    controller.preview = self.imgPreview.image
    controller.formDelegate = self.formDelegate
    controller.configure (onFinishedAction: { [unowned self] result in
        switch result {
        case .success( _):
            let previewImage = controller.imgAnexo.image
            if self.pathOCR.contains("Anverso") || self.pathOCR.contains("Reverso") || self.pathOCR.contains("Veridas") {
                let _ = ConfigurationManager.shared.utilities.saveImageToFolder(previewImage!, self.pathOCR)
            }else{
                let _ = ConfigurationManager.shared.utilities.saveImageToFolder(previewImage!, path)
            }
            self.imgPreview.image = previewImage
            break
        case .failure(let error):
            print("ERROR BACK MODIFICAR IMAGEN: \(error)")
            break
        }
    })
    
    let presenter = Presentr(presentationType: .fullScreen)
    self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
}
    
    // Lanza opciones de Filtros a aplicar en la imagen
    @objc func btnfiltrosAction(_ sender: UIButton) {
        let controller = FiltrosModificarViewController(nibName: "FiltroModifImagen", bundle: Cnstnt.Path.framework)
        controller.atributos = self.atributos
        controller.row = self.row
        controller.tipo = "Filtros"
        controller.preview = self.imgPreview.image
        if self.imgOriginal != nil { controller.imgOriginal = self.imgOriginal }
        controller.formDelegate = self.formDelegate
        controller.configure (onFinishedAction: { [unowned self] result in
            switch result {
            case .success( _):
                if self.imgOriginal == nil { self.imgOriginal = controller.preview }
                let previewImage = controller.imgAnexo.image
                self.imgPreview.image = previewImage
                if self.pathOCR.contains("Anverso") || self.pathOCR.contains("Reverso") || self.pathOCR.contains("Veridas") {
                    let _ = ConfigurationManager.shared.utilities.saveImageToFolder(previewImage!, self.pathOCR)
                }else{
                    let _ = ConfigurationManager.shared.utilities.saveImageToFolder(previewImage!, path)
                }
                break
            case .failure(let error):
                print("ERROR BACK Filtros IMAGEN: \(error)")
             break
            }
        })
        
        let presenter = Presentr(presentationType: .fullScreen)
        self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
    }
    
    // Elimina imagen (anexo)
    @objc func btnCleanAction(_ sender: UIButton) {
        self.setVariableHeight(Height: self.heightHeaderCell)
        self.btnActions.isHidden = false
        self.lblTitleBtn.isHidden = self.btnActions.titleLabel?.text == self.lblTitleBtn.text! ? true : false
        self.headersView.setMessage("")
        self.stackOptions.isHidden = true
        
        self.imgPreview.image = nil
        self.imgPreview.isHidden = true
        
        self.typeDocButton.isHidden = true
        self.lblTypeDoc.isHidden = true
        self.btnMeta.isHidden = true
        
        self.anexosDict[1] = (id: "", url: "")
        self.elemento.validacion.valor = ""
        self.elemento.validacion.valormetadato = ""
        
        self.typeDocButton.setTitle(" Seleccione...      ", for: .normal)
        self.lblTypeDoc.text = " Tipo de documento: "
        self.docID = 0
        
        self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
        row.value = nil
        row.validate()
        self.updateIfIsValid()
        triggerRulesOnChange("removeanexo")
    }
    
    // Reemplaza anexo
    @objc func btnReempAndCancelAction(_ sender: UIButton) {
        if self.lblReempAndCancel.text == "Sustituir"{
            self.fedocReemp = self.fedocumento
            self.anexoReemp = self.anexo
            self.startReemp = true
            self.btnActionsAction(sender)
        }else if self.lblReempAndCancel.text == "Deshacer"{
            FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.fedocReemp.Nombre { $0.Reemplazado = false }}
            if self.fedocReemp.TipoDocID != self.fedocumento.TipoDocID
            {   var menos = false; var mas = false;
                for list in self.listAllowed{
                    if list.CatalogoId == self.fedocReemp.TipoDocID && !mas { list.current += 1 ; mas = true}
                    if list.CatalogoId == self.fedocumento.TipoDocID && !menos { list.current -= 1; menos = true }
                }
            }
            self.anexoReemp?.Reemplazado = false
            self.fedocumento = self.fedocReemp
            self.anexo = self.anexoReemp
            self.anexoReemp = nil
            self.fedocReemp = FEDocumento()
            self.startReemp = false
            self.btnModificar.isEnabled = false
            self.btnFiltros.isEnabled = false
            self.lblReempAndCancel.text = "Sustituir"
            self.btnReempAndCancel = (self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnReempAndCancel, nameIcono: "ic_sustituir", titulo: self.lblReempAndCancel.text!, colorFondo: atributos?.colorreemplazar ?? "#1E88E5", colorTxt: atributos?.colortextoreemplazar ?? "#FFFFFF"))!
            self.setEdited(v: fedocumento.Nombre)
        }
    }
    
    // MARK: Button Action Document Type
    @objc func typeDocAction(_ sender: UIButton) {
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
    
    // MARK: - METADATOS
    // MARK: Button Action Metadata
    @objc func metaAction(_ sender: UIButton) {
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
    
    // Función carama
    func btnCamaraAction() {
        getAutho()
        if atributos.tipocamara == "Normal" {
            openCamera()
        } else if atributos.tipocamara == "GeniusScan" {
            self.formDelegate?.setStatusBarNotificationBanner("Genius Scan está inhabilitado por el momento", .warning, .top)
            //openGeniusScan()
        } else if atributos.tipocamara == "Scanbot" {
            openScanner()
        } else {
            openCamera()
        }
    }
    
    // Función archivo
    func openFiles(){
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeGIF),String(kUTTypeJPEG), String(kUTTypeJPEG), String(kUTTypePNG)], in: .import)
        importMenu.delegate = self
        importMenu.allowsMultipleSelection = false
        importMenu.modalPresentationStyle = .popover
        let presenter = Presentr(presentationType: .popup)
        self.formViewController()?.customPresentViewController(presenter, viewController: importMenu, animated: true, completion: nil)
    }
    
    
    // MARK: Set - Preview
    @objc public func setPreview(_ sender: Any) {
        if "\(self.anexosDict[1].url)" == "" && !self.imgPreview.isHidden {
            self.setDownloadAnexo(Any.self)
        } else {
            let localPath = "\(Cnstnt.Tree.anexos)/\(self.anexosDict[1].url)"
            if FCFileManager.existsItem(atPath: localPath){
                let file = ConfigurationManager.shared.utilities.read(asData: localPath)
                let preview = PreviewImagenViewMain.create(dataImage: file)
                preview.modalPresentationStyle = .overFullScreen
                self.formViewController()?.present(preview, animated: true)
            }
        }
    }
    
    // MARK: Set - Download Anexo
    @objc public func setDownloadAnexo(_ sender: Any) {
        self.setMessage("hud_downloading".langlocalized(), .info)
        bgHabilitado.isHidden = false
        (row as? ImagenRow)?.disabled = true
        (row as? ImagenRow)?.evaluateDisabled()
        if self.anexo != nil{
            self.sdkAPI?.DGSDKformatoAnexos(delegate: self, anexo: self.anexo!, estado: FormularioUtilities.shared.currentFormato.EstadoApp)
                .then{ response in
                    self.setAnexo(response)
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.setPreview(_:)))
                    self.imgPreview.isUserInteractionEnabled = false
                    self.imgPreview.addGestureRecognizer(tapGestureRecognizer)
                    self.btnModificar.isEnabled = false
                    self.btnFiltros.isEnabled = false
                    self.stackClean.isHidden = true
                    self.stackReemp.isHidden = false
                }.catch{ error in
                    self.bgHabilitado.isHidden = true
                    (self.row as? ImagenRow)?.disabled = false
                    (self.row as? ImagenRow)?.evaluateDisabled()
                    self.setMessage("elemts_attch_error".langlocalized(), .info)
            }
        }
    }
    
    // MARK: - PHOTO OPTIONS
    func openCamera() {
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
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.modalPresentationStyle = .fullScreen
            pickerController.delegate = self
            pickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            pickerController.allowsEditing = false
            self.formDelegate?.getFormViewControllerDelegate()?.present(pickerController, animated: true, completion: nil)
        }
    }
    
    func openScanner() {
        #if canImport(WeScan)
        scannerViewController = ImageScannerController()
        scannerViewController.modalPresentationStyle = .fullScreen
        scannerViewController.imageScannerDelegate = self
        self.formDelegate?.getFormViewControllerDelegate()?.present(scannerViewController, animated: true)
        #endif
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
        
        self.formDelegate?.getFormViewControllerDelegate()?.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - TIPIFYCATION
    // MARK: Set Permiso Tipificar
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
    
    // MARK: Get All Tipyfication options
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
    
    // MARK: Saving Data from Metas
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
    
    
    // MARK: - Take a photo
    // ImagePicker
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var image : UIImage!

        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage { image = img }
        else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage { image = img }
        
        if self.atributos.normalizacion == "Grey" { //Escala de grises
            if let imgBN = image.tonal {
                image = imgBN
            }
        } else if self.atributos.normalizacion == "B/W" { //Blanco y negro
            if let imgGrises = image.noir {
                image = imgGrises
            }
        }
        
        // Detecting if Image Width and Height is greater than 1600
        let portraitImage = image.upOrientationImage()
        var previewImage = UIImage()
        
        //Saving image
        let resizeImage = portraitImage?.resized(withPercentage: 0.3)
        let jpgConversion = resizeImage?.jpegData(compressionQuality: 0.6)
        let jpgImage = UIImage(data: jpgConversion!)
        previewImage = jpgImage!
        
        path = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
        let doc = FEDocumento()
        
        doc.guid = "\(guid)"
        doc.isKindImage = true
        doc.Ext = "jpg"
        doc.ImageString = ""
        doc.Nombre = path
        doc.Path = path
        doc.URL = "\(Cnstnt.Tree.anexos)/\(path)"
        doc.TipoDoc = ""
        doc.TipoDocID = 0
        
        if self.startReemp {
            FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.fedocumento.Nombre { $0.Reemplazado = true }}
            if self.anexoReemp != nil{
                self.anexoReemp?.Reemplazado = true
                doc.DocID = self.anexoReemp?.DocID ?? -1
            }
            for list in self.listAllowed {
                if list.CatalogoId != self.fedocumento.TipoDocID { continue }
                list.current -= 1
                break
            }
            
            self.btnModificar.isEnabled = true
            self.btnFiltros.isEnabled = true
            self.lblReempAndCancel.text = "Deshacer"
            self.btnReempAndCancel = (self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnReempAndCancel, nameIcono: "ic_deshacer", titulo: self.lblReempAndCancel.text!, colorFondo: atributos?.colorreemplazar ?? "#1E88E5", colorTxt: atributos?.colortextoreemplazar ?? "#FFFFFF"))!
        }
        for list in self.listAllowed{
            if tipUnica == nil{ break }
            if list.CatalogoId != tipUnica{ continue }
            doc.TipoDocID = tipUnica ?? 0
            anexo?.TipoDocID = tipUnica ?? 0
            doc.TipoDoc = list.Descripcion
            list.current = 1
        }
        self.docID = doc.TipoDocID ?? 0
        self.fedocumento = doc
        let _ = ConfigurationManager.shared.utilities.saveImageToFolder(jpgImage!, path)
        setEdited(v: path)
        
        self.imgPreview.image = previewImage
        self.imgPreview.isHidden = false
        self.btnActions.isHidden = true
        self.lblTitleBtn.isHidden = true
        self.setVariableHeight(Height: (280 + self.heightHeaderCell))
        
        if tipUnica == nil{ setPermisoTipificar(atributos?.permisotipificar ?? false) }
        if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImagenCell: UITableViewDelegate, UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historicList?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HistorialCell", for: indexPath) as? HistorialCell{
            cell.tag = indexPath.row
            cell.onLoadData(historico: historicList?[indexPath.row], delegate: self)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = messageHistorialList == "Sin resultados" ? .systemFont(ofSize: 14, weight: .regular) : .systemFont(ofSize: 15, weight: .semibold)
        label.text = messageHistorialList
        label.numberOfLines = 0
        label.textColor =  messageHistorialList == "Sin resultados" ? .red : .black
        
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onCancelList(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "baseline_clear_black_48pt", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
       
        view.addSubview(label)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 50),
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 60),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
            
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    @objc func onCancelList(_ sender: UIButton){
        historialTable.isHidden = true
        previewline.isHidden = true
        setVariableHeight(Height: 350 + (CGFloat(historicList?.count ?? 0) * 20))
    }
    
}

extension ImagenCell: HistorialCellProtocol{
    func displayImagePreview(tag: Int) {
        let anexo = FEAnexoData()
        anexo.DocID = historicList?[tag].DocID ?? 0
        anexo.FileName = historicList?[tag].Descripcion ?? ""
        anexo.Publicado = true
        anexo.Extension = historicList?[tag].Extension ?? ""
        self.sdkAPI?.DGSDKverAnexo(anexo: anexo, formato: FEFormatoData()).then({ response in
            let data = Data(base64Encoded: response, options: .ignoreUnknownCharacters)
            DispatchQueue.main.async {
                let preview = PreviewImagenViewMain.create(dataImage: data)
                preview.modalPresentationStyle = .overFullScreen
                self.formViewController()?.present(preview, animated: true)
            }
        }).catch({ error in
             print(error.localizedDescription)
        })
    }
}
#if canImport(WeScan)
extension ImagenCell: ImageScannerControllerDelegate {
    public func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithObject results: WeScanImageObject) {
        scanner.dismiss(animated: true, completion: nil)
    }
    
    public func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        // scanner.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(
            title: "alrt_warning".langlocalized(),
            message: "intenta nuevamente",
            preferredStyle: UIAlertController.Style.alert
        )
        let actionAccept = UIAlertAction(title: "Aceptar".langlocalized(), style: .default) { (action) in
            scanner.dismiss(animated: false) {
                self.openScanner()
            }
        }
        alert.addAction(actionAccept)
        #if canImport(WeScan)
        scannerViewController.present(alert, animated: true, completion: nil)
        #endif
    }
    
    public func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        scanner.dismiss(animated: true, completion: nil)
        var previewImage = UIImage()
        
        //Saving image
        let resizeImage = results.scannedImage.resized(withPercentage: 0.3)
        let jpgConversion = resizeImage?.jpegData(compressionQuality: 0.6)
        let jpgImage = UIImage(data: jpgConversion!)
        previewImage = jpgImage!
        path = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
        let doc = FEDocumento()
        
        doc.guid = "\(guid)"
        doc.isKindImage = true
        doc.Ext = "jpg"
        doc.ImageString = ""
        doc.Nombre = path
        doc.Path = path
        doc.URL = "\(Cnstnt.Tree.anexos)/\(path)"
        doc.TipoDoc = ""
        doc.TipoDocID = 0
        
        if self.startReemp {
            FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.fedocumento.Nombre { $0.Reemplazado = true }}
            if self.anexoReemp != nil{
                self.anexoReemp?.Reemplazado = true
                doc.DocID = self.anexoReemp?.DocID ?? -1
            }
            for list in self.listAllowed {
                if list.CatalogoId != self.fedocumento.TipoDocID { continue }
                list.current -= 1
                break
            }
            
            self.btnModificar.isEnabled = true
            self.btnFiltros.isEnabled = true
            self.lblReempAndCancel.text = "Deshacer"
            self.btnReempAndCancel = (self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnReempAndCancel, nameIcono: "ic_deshacer", titulo: self.lblReempAndCancel.text!, colorFondo: atributos?.colorreemplazar ?? "#1E88E5", colorTxt: atributos?.colortextoreemplazar ?? "#FFFFFF"))!
        }
        for list in self.listAllowed{
            if tipUnica == nil{ break }
            if list.CatalogoId != tipUnica{ continue }
            doc.TipoDocID = tipUnica ?? 0
            anexo?.TipoDocID = tipUnica ?? 0
            doc.TipoDoc = list.Descripcion
            list.current = 1
        }
        self.docID = doc.TipoDocID ?? 0
        self.fedocumento = doc
        let _ = ConfigurationManager.shared.utilities.saveImageToFolder(jpgImage!, path)
        setEdited(v: path)
        
        self.imgPreview.image = previewImage
        self.imgPreview.isHidden = false
        self.btnActions.isHidden = true
        self.lblTitleBtn.isHidden = true
        self.setVariableHeight(Height: (280 + self.heightHeaderCell))
        
        if tipUnica == nil{ setPermisoTipificar(atributos?.permisotipificar ?? false) }
        if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
    }
    
    public func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
    }
    
}
#endif

// MARK: - OBJECTFORMDELEGATE
extension ImagenCell: ObjectFormDelegate{
    
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
        self.heightHeaderCell = 90 + CGFloat(heightHeader)
        self.setVariableHeight(Height: self.heightHeaderCell)
    }
    
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Imagen"
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
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) {
        DispatchQueue.main.async {
            self.height = {return h}
            self.layoutIfNeeded()
            self.row.reload()
            self.formDelegate?.reloadTableViewFormViewController()
        }
    }
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){ }
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil{
            self.elemento.validacion.needsValidation = atributos?.requerido ?? false
            if atributos?.requerido ?? false {
                var rules = RuleSet<String>()
                rules.add(rule: ReglaRequerido())
                self.row.add(ruleSet: rules)
            }
            self.headersView.setRequerido(atributos?.requerido ?? false)
        }
    }
    // MARK: Set - MinMax
    public func setMinMax(){ }
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){ }
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

            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            row.value = nil
            self.updateIfIsValid()
            self.setVariableHeight(Height: self.heightHeaderCell)
            if row.value == nil || row.value == ""{ triggerRulesOnChange("empty") }
        }
        
        // MARK: - Setting estadisticas
        setEstadistica()
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = v.replaceLineBreakEstadistic()
        est!.KeyStroke += 1
        let fechaValorFinal = Date.getTicks()
        self.setEstadisticaV2()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = v.replaceLineBreakEstadistic()
        self.estV2!.Cambios += 1
        elemento.estadisticas2 = estV2!
        
        elemento.estadisticas = est!
        
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
        self.setVariableHeight(Height: (280 + self.heightHeaderCell))
        let localPath = "\(Cnstnt.Tree.anexos)/\(v)"
        if FCFileManager.existsItem(atPath: localPath){
            let file = ConfigurationManager.shared.utilities.read(asData: localPath)
            let resizeImage = UIImage(data: file!)//?.resized(withPercentage: 0.3)
            let jpgConversion = resizeImage?.jpegData(compressionQuality: 0.8)
            let jpgImage = UIImage(data: jpgConversion!)
            self.imgPreview.image = jpgImage
            self.imgPreview.isHidden = false
            self.btnModificar.isHidden = false
        }
        if plist.idportal.rawValue.dataI() >= 39{
            let localPathOCR = "\(Cnstnt.Tree.anexos)/\(v)"
            if localPathOCR.contains("Anverso") || localPathOCR.contains("Reverso") || localPathOCR.contains("Veridas") {
                if FCFileManager.existsItem(atPath: localPath){
                    self.pathOCR = localPathOCR
                    let file = ConfigurationManager.shared.utilities.read(asData: localPath)
                    let resizeImage = UIImage(data: file!)//?.resized(withPercentage: 0.3)
                    let jpgConversion = resizeImage?.jpegData(compressionQuality: 0.8)
                    let jpgImage = UIImage(data: jpgConversion!)
                    self.imgPreview.image = jpgImage
                    self.imgPreview.isHidden = false
                }
            }
        }
        self.stackOptions.isHidden = false
        self.headersView.lblTitle.textColor = UIColor.black
        row.value = v
        detailTextLabel?.isHidden = true
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
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        if row.isValid{ // Setting row as valid
            if row.value == nil{
                self.headersView.setMessage("")
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? ImagenRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.validado = false
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            }else{
                self.headersView.setMessage("")
                resetValidation()
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? ImagenRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.attData = ((row as? ImagenRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.attData = ((row as? ImagenRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
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
                self.headersView.setMessage("  \(self.row.validationErrors[0].msg)  ")
            }

            self.elemento.validacion.anexos = [(id: String, url: String)]()
            self.elemento.validacion.anexos = (row as? ImagenRow)?.cell.anexosDict
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
extension ImagenCell: AttachedFormDelegate{
    public func setAttributesToController() { }
    
    func setMetaValues() -> Bool{
        if self.anexo?.DocID != 0 {
            self.btnModificar.isEnabled = false
            self.btnFiltros.isEnabled = false
            self.stackClean.isHidden = true
            self.stackReemp.isHidden = false
        }
        if self.elemento.validacion.valor == "" {
            guard let ane = self.anexo else{ return false }
            if ane.Guid == FormularioUtilities.shared.currentFormato.Guid{
                let fedoc = FEDocumento()
                fedoc.guid = self.anexo?.GuidAnexo ?? ""
                fedoc.isKindImage = true
                let fileExtension = ane.FileName.fileExtension().lowercased()
                fedoc.Ext = fileExtension
                fedoc.ImageString = ""
                fedoc.Nombre = ane.FileName.cleanAnexosDocPath()
                fedoc.Path = ane.FileName.cleanAnexosDocPath()
                fedoc.URL = ane.FileName
                fedoc.TipoDocID = self.anexo?.TipoDocID ?? 0
                for docType in listAllowed{
                    if ane.TipoDocID == docType.CatalogoId{
                        fedoc.TipoDoc = docType.Descripcion
                    }
                }
                self.docID = fedoc.TipoDocID ?? 0
                if self.elemento.validacion.valormetadato != "" {
                    let vmeta = self.elemento.validacion.valormetadato.data(using: .utf8)
                    do {
                        let metadoc = (try JSONSerialization.jsonObject(with: vmeta!, options: []) as? [String: Any])!
                    
                        for meta in metadoc{
                            for mm in meta.value as? [String: Any] ?? [:]{
                                let m = FEListMetadatosHijos()
                                m.Nombre = mm.key
                                m.NombreCampo = mm.value as? String ?? ""
                                fedoc.Metadatos.append(m)
                            }
                        }
                    } catch {}
                }
                self.typeDocButton.setTitle("\(fedoc.TipoDoc)", for: .normal)
                self.lblTypeDoc.text = "\(fedoc.TipoDoc)"
                self.fedocumento = fedoc
                if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
                return true
            }
        }
                
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
        if self.anexo?.DocID != 0 {
            self.btnActions.isHidden = true
            self.lblTitleBtn.isHidden = true
        }
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
        self.btnActions.isHidden = true
        self.lblTitleBtn.isHidden = true
        self.setVariableHeight(Height: (280 + self.heightHeaderCell))
        self.anexosDict[0] = (id: "reemplazo", url: anexo.FileName)
        triggerRulesOnChange("replaceanexo")
    }
    
    // MARK: Set - Anexo
    public func setAnexo(_ anexo: FEAnexoData) {
        bgHabilitado.isHidden = true
        (row as? ImagenRow)?.disabled = false
        (row as? ImagenRow)?.evaluateDisabled()
        _ = setMetaValues()
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
            setEdited(v: "\(anexo.FileName)")
            self.setMessage("elemts_attch_recover".langlocalized(), .info)
        }
    }
    
}

extension ImagenCell{
    
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

extension ImagenCell: MetaFormDelegate{
    public func didClose() {
       // self.closeMetaAction(Any.self)
    }
    
    public func didSave() {
       // self.saveMetaAction(Any.self)
       // self.closeMetaAction(Any.self)
    }
    
    public func didUpdateData(_ tipoDoc: String, _ idDoc: Int) {
        self.typeDocButton.setTitle("\(tipoDoc)", for: .normal)
        self.lblTypeDoc.text = "\(tipoDoc)"
        self.docID = idDoc
    }
    
}
