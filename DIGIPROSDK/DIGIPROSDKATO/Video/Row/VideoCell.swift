import Foundation
import MobileCoreServices
import AVKit
import AVFoundation
import Eureka

open class VideoCell: Cell<String>, CellType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var headersView: FEHeaderView = {
        let view = FEHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    lazy var bgHabilitado: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints  = false
        view.backgroundColor = UIColor.init(hexFromString: "E8ECEE", alpha: 0.3)
        return view
    }()
    
    lazy var activity: UIActivityIndicatorView = {
        let activityLoader = UIActivityIndicatorView(frame: .zero)
        activityLoader.translatesAutoresizingMaskIntoConstraints = false
        activityLoader.color = .black
        activityLoader.isHidden = true
        return activityLoader
    }()
    
    lazy var btnPlay: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints  = false
        btn.setImage(UIImage(named: "ic_playVid", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.addTarget(self, action: #selector(self.onTapVideo), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnMeta: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints  = false
        btn.setImage(UIImage(named: "ic_meta", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.backgroundColor = UIColor.init(hexFromString: "00B2F2")
        btn.isHidden = true
        btn.addTarget(self, action: #selector(self.metaAction(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()
    
    lazy var videoPreview: VideoView = {
        let video = VideoView()
        video.translatesAutoresizingMaskIntoConstraints  = false
        video.backgroundColor = .black
        video.isHidden = true
        video.isUserInteractionEnabled = true
        video.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapVideo)))
        return video
    }()
    
    lazy var download: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints  = false
        btn.backgroundColor = UIColor.lightGray
        btn.isHidden = true
        btn.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()
    
    lazy var downloadView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(download)
        NSLayoutConstraint.activate([
            download.heightAnchor.constraint(equalToConstant: 50),
            download.widthAnchor.constraint(equalToConstant: 50),
        ])
        return view
    }()
    
    lazy var btnCamara: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints  = false
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(self.btnCamaraAction(_:)), for: .touchUpInside)
        btn.setImage(UIImage(named: "ic_camera", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()
    lazy var camaraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnCamara)
        NSLayoutConstraint.activate([
            btnCamara.heightAnchor.constraint(equalToConstant: 50),
            btnCamara.widthAnchor.constraint(equalToConstant: 50),
        ])
        return view
    }()
    
    lazy var btnImport: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints  = false
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(self.btnImportAction(_:)), for: .touchUpInside)
        btn.setImage(UIImage(named: "ic_noteAdd", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()
    
    lazy var importView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnImport)
        NSLayoutConstraint.activate([
            btnImport.heightAnchor.constraint(equalToConstant: 50),
            btnImport.widthAnchor.constraint(equalToConstant: 50),
        ])
        return view
    }()
    
    lazy var btnClean: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints  = false
        btn.backgroundColor = .clear
        btn.setImage(UIImage(named: "ic_clean", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(self.btnCleanAction(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()
    lazy var cleanView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnClean)
        NSLayoutConstraint.activate([
            btnClean.heightAnchor.constraint(equalToConstant: 50),
            btnClean.widthAnchor.constraint(equalToConstant: 50),
        ])
        return view
    }()
    
    lazy var btnFill: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints  = false
        return btn
    }()
    lazy var secondBtnFill: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints  = false
        return btn
    }()
    
    lazy var typeDocButton: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints  = false
        btn.backgroundColor = UIColor.init(hexFromString: "00B2F2")
        btn.isHidden = true
        btn.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints  = false
        btn.addTarget(self, action: #selector(self.typeDocAction), for: .touchUpInside)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()
    lazy var lblTypeDoc: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 10, weight: .regular)
        return label
    }()
    
    lazy var elementsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 5
        stack.addArrangedSubview(downloadView)
        stack.addArrangedSubview(camaraView)
        stack.addArrangedSubview(cleanView)
        stack.addArrangedSubview(btnFill)
        stack.addArrangedSubview(importView)
        stack.addArrangedSubview(secondBtnFill)
        
        NSLayoutConstraint.activate([
            cleanView.widthAnchor.constraint(equalToConstant: 50),
            cleanView.heightAnchor.constraint(equalToConstant: 50),
            
            downloadView.widthAnchor.constraint(equalToConstant: 50),
            downloadView.heightAnchor.constraint(equalToConstant: 50),
            
            btnFill.widthAnchor.constraint(equalToConstant: 50),
            btnFill.heightAnchor.constraint(equalToConstant: 5),
            
            camaraView.widthAnchor.constraint(equalToConstant: 50),
            camaraView.heightAnchor.constraint(equalToConstant: 50),
            
            importView.widthAnchor.constraint(equalToConstant: 50),
            importView.heightAnchor.constraint(equalToConstant: 50),
            
            secondBtnFill.widthAnchor.constraint(equalToConstant: 50),
            secondBtnFill.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        return stack
    }()
    
    lazy var bodyStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 5
        stack.addArrangedSubview(headersView)
        stack.addArrangedSubview(elementsStackView)
        
        NSLayoutConstraint.activate([
            elementsStackView.heightAnchor.constraint(equalToConstant: 44),
        ])
        return stack
    }()
    
    //* Elementos para reemplazar anexo.
    lazy var btnCamReemp: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(btnCamReempAction(_:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var btnImpReemp: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var btnCancelReemp: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var reempStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(btnCamReemp)
        stack.addArrangedSubview(btnImpReemp)
        stack.addArrangedSubview(btnCancelReemp)
        return stack
    }()
    
    public var isPlayingVideo: Bool = false
    public var elemento = Elemento()
    public var atributos: Atributos_video!
    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var isServiceMessageDisplayed = 0
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    
    public var anexosDict = [ (id: "", url: ""),
                              (id: "", url: "") ]
    public var docTypeDict = [(catalogoId: 0, descripcion: ""),
                              (catalogoId: 0, description: "" )] as [Any]
    
    var sdkAPI : APIManager<VideoCell>?
    var anexo: FEAnexoData?
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    
    public var startReemp : Bool = false
    public var anexoReemp: FEAnexoData?
    var vvalorReemp = ""
    var vmeteReemp = ""
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
        (row as? VideoRow)?.presentationMode = nil
    }
    
    // Tipificación
    var vw: MetaAttributesViewController = MetaAttributesViewController()
    var docID: Int = 0
    var arrayMetadatos: [FEListMetadatosHijos] = []
    public var tipUnica: Int?
    public var listAllowed: [FEListTipoDoc] = []
    public var path = ""
    public var fedocumento: FEDocumento = FEDocumento()
    
    // MARK: - ACTIONS
    @objc func downloadAnexo(_ sender: Any) {
        setDownloadAnexo(sender)
    }

    @objc func onTapVideo() {
        if videoPreview.player == nil{
            guard let data = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(self.path)") else{ return }
            FCFileManager.createFile(atPath: "video.mp4", withContent: data as NSObject, overwrite: true)
            guard let url = FCFileManager.urlForItem(atPath: "video.mp4") else{ return }
            videoPreview.configure(videoUrl: url)
        }
        
        if isPlayingVideo {
            isPlayingVideo = false
            self.videoPreview.pause()
            self.btnPlay.setImage(UIImage(named: "ic_playVid", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
            
        } else {
            isPlayingVideo = true
            self.videoPreview.play()
            self.btnPlay.setImage(UIImage(named: "ic_stopVid", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        }
    }
    
    @IBAction func btnCleanAction(_ sender: UIButton) {
        self.headersView.lblMessage.text = ""
        self.headersView.lblMessage.isHidden = true
        self.btnClean.isHidden = true
        self.btnCamara.isHidden = false
        self.btnImport.isHidden = false
        
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
        
        isPlayingVideo = false
        videoPreview.isHidden = true
        videoPreview.pause()
        if (videoPreview.layer.sublayers?.count ?? 0) > 2{
            videoPreview.layer.sublayers?.removeLast()
        }
        
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader + 130)
        triggerRulesOnChange("removeanexo")
    }
    
    @objc func btnImportAction(_ sender: UIButton) {
        getAutho()
        openGallery()
    }
    
    @objc func btnCamaraAction(_ sender: UIButton) {
        getAutho()
        openCamera()
    }
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        
            let text: UILabel = {
                let properties = UILabel()
                properties.translatesAutoresizingMaskIntoConstraints = false
                properties.text = atributos.leyendavideo
                properties.textColor = UIColor.white
                properties.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                properties.numberOfLines = 0
                properties.textAlignment = .justified
                return properties
            }()
            
            let controller = UIImagePickerController()
            
            if !atributos.leyendavideo.isEmpty {
                controller.view.addSubview(text)
                NSLayoutConstraint.activate([
                    text.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor, constant: 12.0),
                    text.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
                    text.widthAnchor.constraint(equalTo: controller.view.widthAnchor, multiplier: 0.95),
                    text.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
                ])
            }
           
            controller.sourceType = .camera
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
            controller.allowsEditing = true
            if atributos?.modocamara == "front"{
                controller.cameraDevice = .front
            }else{
                controller.cameraDevice = .rear
            }
            (row as? VideoRow)?.cell.formCell()?.formViewController()?.show(controller, sender: nil)
        }
    }
    
    func openGallery(){
        let controller = UIImagePickerController()
        controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        controller.mediaTypes = [kUTTypeMovie as String]
        controller.delegate = self
        (row as? VideoRow)?.cell.formCell()?.formViewController()?.show(controller, sender: nil)
    }
    
    public func saveDataReep ()
    {
        self.anexoReemp = self.anexo
        self.vvalorReemp = self.elemento.validacion.valor
        self.vmeteReemp = self.elemento.validacion.valormetadato
        if self.startReemp
        {
            
        }
    }
    // Called Reemplazo Action
    @objc func btnCamReempAction(_ sender: UIButton) {
        self.saveDataReep()
        self.startReemp = true
        self.btnCamaraAction(sender)
    }
    @IBAction func btnDocReempAction(_ sender: UIButton) {
        self.saveDataReep()
        self.startReemp = true
        self.btnImportAction(sender)
    }
    // Called CancelReemplazo Action
    @IBAction func btnCancelReempAction(_ sender: UIButton) {
        self.anexo = self.anexoReemp
        self.anexosDict[0] = (id: "reemplazo", url: self.anexo?.FileName ?? "")
        self.anexoReemp = nil
        self.elemento.validacion.valor = self.vvalorReemp
        self.elemento.validacion.valormetadato = self.vmeteReemp
        self.vvalorReemp = ""
        self.vmeteReemp = ""
        _ = setMetaValues()
        
        FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.anexo?.FileName ?? "" { $0.Reemplazado = false }}
        
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(self.anexo?.FileName ?? "")"){
            setEdited(v: self.anexo?.FileName ?? "")
        }
        self.btnCamReemp.isHidden = false
        self.btnImpReemp.isHidden = false
        self.btnCancelReemp.isHidden = true
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
        
        (row as? VideoRow)?.cell.formCell()?.formViewController()?.present(alert, animated: true, completion: nil)
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
        
        let apiObject = AttachedFormManager<VideoCell>()
        apiObject.delegate = self
        
        let apiMeta = MetaFormManager<VideoCell>()
        apiMeta.delegate = self
        
        sdkAPI = APIManager<VideoCell>()
        
        addSubview(vw.view)
        vw.view.isHidden = true
        vw.view.translatesAutoresizingMaskIntoConstraints = false
        vw.delegate = apiMeta.delegate
        
        contentView.addSubview(bgHabilitado)
        contentView.addSubview(activity)
        contentView.addSubview(bodyStackView)
        contentView.addSubview(videoPreview)
        contentView.addSubview(lblTypeDoc)
        contentView.addSubview(typeDocButton)
        
        videoPreview.addSubview(btnPlay)
        videoPreview.addSubview(btnMeta)
        
        NSLayoutConstraint.activate([
            vw.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            vw.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vw.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vw.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            headersView.heightAnchor.constraint(equalToConstant: 40),
            
            bgHabilitado.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgHabilitado.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bgHabilitado.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bgHabilitado.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            bodyStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            bodyStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bodyStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            videoPreview.topAnchor.constraint(equalTo: bodyStackView.bottomAnchor, constant: 10),
            videoPreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 45),
            videoPreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -45),
            videoPreview.heightAnchor.constraint(equalToConstant: 200),
            
            btnPlay.topAnchor.constraint(equalTo: videoPreview.topAnchor),
            btnPlay.trailingAnchor.constraint(equalTo: videoPreview.trailingAnchor),
            btnPlay.heightAnchor.constraint(equalToConstant: 60),
            btnPlay.widthAnchor.constraint(equalToConstant: 60),
            
            btnMeta.bottomAnchor.constraint(equalTo: videoPreview.bottomAnchor),
            btnMeta.trailingAnchor.constraint(equalTo: videoPreview.trailingAnchor),
            btnMeta.heightAnchor.constraint(equalToConstant: 60),
            btnMeta.widthAnchor.constraint(equalToConstant: 60),
            
            activity.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activity.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    func setColorsElement(){
        btnClean.backgroundColor = UIColor(hexFromString: atributos?.colorborrar ?? "#1E88E5")
        btnCamara.backgroundColor = UIColor(hexFromString: atributos?.colortomarvideo ?? "#1E88E5")
        btnImport.backgroundColor = UIColor(hexFromString: atributos?.colortomarvideo ?? "#1E88E5")
        btnMeta.backgroundColor = UIColor(hexFromString: atributos?.colortomarvideo ?? "#1E88E5")
        typeDocButton.backgroundColor = UIColor(hexFromString: atributos?.colortomarvideo ?? "#1E88E5")
    }
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) {
        guard let _ = self.atributos, let help = atributos?.ayuda else{
            return;
        }
        toogleToolTip(help)
    }
    // MARK: SETTING
    /// SetObject for VideoRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_video
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        if atributos?.titulo ?? "" == ""{ self.headersView.setOcultarTitulo(true) }else{ self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        if atributos?.subtitulo ?? "" == ""{ self.headersView.setOcultarSubtitulo(true) }else{ self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false) }
        
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? VideoRow)?.cell.formCell()?.formViewController()?.tableView
        
        self.headersView.hiddenTit = false
        self.headersView.hiddenSubtit = false
        
        self.headersView.setTitleText(headersView.txttitulo)
        self.headersView.setSubtitleText(headersView.txtsubtitulo)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
        self.headersView.setMessage("")
        
        setInfo()
        getTipificacionPermitida()
        setColorsElement()
        
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: 120.0 + headersView.heightHeader)
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
    // MARK: - Button Action Metadata
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
    
    // Image Picker
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedVideo:URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
            do{
                picker.dismiss(animated: true)
                
                let videoData = try Data(contentsOf: selectedVideo)
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
                    self.btnCamReemp.isHidden = true
                    self.btnImpReemp.isHidden = true
                    self.btnCancelReemp.isHidden = false
                    FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.anexoReemp?.FileName { $0.Reemplazado = true }}
                    doc.DocID = self.anexoReemp?.DocID ?? 0
                    for list in self.listAllowed{
                        if list.CatalogoId == self.anexoReemp?.TipoDocID {
                            list.current -= 1
                            break
                        }
                    }
                }

                for list in self.listAllowed{
                    if tipUnica == nil{ break }
                    if list.CatalogoId != tipUnica{ continue }
                    doc.TipoDocID = tipUnica ?? 0
                    doc.TipoDoc = list.Descripcion
                    list.current = 0
                    if list.current != 0 {
                        if list.current >= list.max{
                            setMessage(String(format: "elemts_doc_maxtyp".langlocalized(), list.Descripcion, String(list.max)), .error)
                            return
                        }
                    }
                    list.current += 1
                }
                self.docID = doc.TipoDocID ?? 0
                self.fedocumento = doc
                let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(videoData as NSData, path)
                setEdited(v: path)
                
                self.videoPreview.isHidden = false
                self.btnClean.isHidden = false
                self.btnCamara.isHidden = true
                self.btnImport.isHidden = true
                
                btnClean.heightAnchor.constraint(equalToConstant: 44).isActive = true
                
                self.setVariableHeight(Height: 350)
                self.btnClean.isHidden = false
                
                if tipUnica == nil{ setPermisoTipificar(atributos?.permisotipificar ?? false) }
                if self.getMetaData(){ btnMeta.isHidden = false }else{ btnMeta.isHidden = true }
                guard let data = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(self.path)") else{ return }
                FCFileManager.createFile(atPath: "video.mp4", withContent: data as NSObject, overwrite: true)
                guard let url = FCFileManager.urlForItem(atPath: "video.mp4") else{ return }
                videoPreview.configure(videoUrl: url)
            }catch{
                picker.dismiss(animated: true)
            }
        }
        
    }
    
    public func tipUnicaDoc(){
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
        
        for list in self.listAllowed{
            if tipUnica == nil{ break }
            if list.CatalogoId != tipUnica{ continue }
            doc.TipoDocID = tipUnica ?? 0
            doc.TipoDoc = list.Descripcion
            list.current = 0
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
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        if self.startReemp {
            self.startReemp = false
            self.btnCancelReempAction(self.btnCancelReemp ?? UIButton())
        }
    }
    
}

// MARK: - OBJECTFORMDELEGATE
extension VideoCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Video"
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
            //self.row.reload()
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
            toolTip?.show(forView: self.headersView.btnInfo, withinSuperview: (row as? VideoRow)?.cell.formCell()?.formViewController()?.tableView)
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
            self.btnCamara.isHidden = true
            self.btnImport.isHidden = true
            self.videoPreview.isHidden = false
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

            self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
            row.value = nil
            self.updateIfIsValid()
            self.setVariableHeight(Height: 160)
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
        
        triggerEvent("alterminarcaptura")
        triggerRulesOnChange("addanexo")
    }
    public func setEdited(v: String, isRobot: Bool) { }
    public func setValue(v: String){
        self.path = v
        self.tipUnicaDoc()
        let tipodoc: NSMutableDictionary = NSMutableDictionary();
        tipodoc.setValue("\(String(fedocumento.TipoDocID ?? 0))", forKey: "\(fedocumento.guid)");
        self.anexosDict[1] = (id: "\(0)", url: "\(fedocumento.Nombre)")
        
        self.elemento.validacion.valor = tipodoc.toJsonString()
        self.elemento.validacion.valormetadato = tipodoc.toJsonString()

        self.anexosDict[1] = (id: "1", url: v)
        self.docTypeDict[1] = (catalogoId: self.fedocumento.TipoDocID, descripcion: self.fedocumento.TipoDoc)
        self.setVariableHeight(Height: 360)
        row.value = v
        self.headersView.lblTitle.textColor = UIColor.black
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

                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? VideoRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.validado = false
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            }else{
                self.headersView.lblMessage.text = ""
                self.headersView.lblMessage.isHidden = true
                resetValidation()
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? VideoRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.attData = ((row as? VideoRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.attData = ((row as? VideoRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
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
                self.headersView.lblMessage.text = "  \(self.row.validationErrors[0].msg)  "
                _ = self.formDelegate?.getColorsErrors(.error)
                self.headersView.lblMessage.backgroundColor = .clear
                self.headersView.lblMessage.textColor = Cnstnt.Color.red2
                self.headersView.lblMessage.isHidden = false
            }

            self.elemento.validacion.anexos = [(id: String, url: String)]()
            self.elemento.validacion.anexos = (row as? VideoRow)?.cell.anexosDict
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
        if atributos != nil, atributos?.eventos != nil {
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
extension VideoCell: AttachedFormDelegate{
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
    public func setAnexoOption(_ anexo: FEAnexoData) {
        self.anexo = anexo
        download.isHidden = false
        self.anexosDict[0] = (id: "reemplazo", url: anexo.FileName)
        triggerRulesOnChange("replaceanexo")
    }
    
    // MARK: Set - Attributes to Controller
    public func setAttributesToController(){ }
    
    // MARK: Set - Anexo
    public func setAnexo(_ anexo: FEAnexoData) {
        bgHabilitado.isHidden = true
        (row as? VideoRow)?.disabled = false
        (row as? VideoRow)?.evaluateDisabled()
        _ = setMetaValues()
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
            setEdited(v: "\(anexo.FileName)")
            self.setMessage("elemts_attch_recover".langlocalized(), .info)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(999)) {
            self.download.isHidden = true
            self.headersView.lblMessage.isHidden = true
        }
    }
    
    // MARK: Set - Preview
    public func setPreview(_ sender: Any) {  }
    
    // MARK: Set - Download Anexo
    public func setDownloadAnexo(_ sender: Any) {
        self.setMessage("hud_downloading".langlocalized(), .info)
        bgHabilitado.isHidden = false
        (row as? VideoRow)?.disabled = true
        (row as? VideoRow)?.evaluateDisabled()
        if self.anexo != nil{
            self.sdkAPI?.DGSDKformatoAnexos(delegate: self, anexo: self.anexo!, estado: FormularioUtilities.shared.currentFormato.EstadoApp)
                .then{ response in
                    self.setAnexo(response)
                }.catch{ error in
                    self.bgHabilitado.isHidden = true
                    (self.row as? VideoRow)?.disabled = false
                    (self.row as? VideoRow)?.evaluateDisabled()
                    self.setMessage("elemts_attch_error".langlocalized(), .info)
            }
        }
    }
    
}

extension VideoCell{
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

extension VideoCell: MetaFormDelegate{
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

// MARK: - APIDELEGATE
extension VideoCell : APIDelegate {
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
}
