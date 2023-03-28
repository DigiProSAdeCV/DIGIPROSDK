import Foundation
import AVFoundation
import Eureka
import UIKit

enum TipoAnexo{
    case nuevo
    case reemplazo
    case form
}

open class AudioCell: Cell<String>, CellType, APIDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // IBOUTLETS
    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var lblGrabar: UILabel!
    @IBOutlet weak var lblDuracion: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var lblPlay: UILabel!
    @IBOutlet weak var btnClean: UIButton!
    @IBOutlet weak var lblClean: UILabel!
    @IBOutlet weak var btnReemplazo: UIButton!
    @IBOutlet weak var lblReemplazo: UILabel!
    @IBOutlet weak var btnCancelReemp: UIButton!
    @IBOutlet weak var lblCancelReemp: UILabel!
    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var lblDownload: UILabel!
    @IBOutlet weak var typeDocButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var bgHabilitado: UIView!
    
    @IBOutlet weak var boxBtnReemp: UIView!
    @IBOutlet weak var boxBtnReempCancel: UIView!
    @IBOutlet weak var boxBtnPlay: UIView!
    @IBOutlet weak var boxBtnClean: UIView!
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var elemento = Elemento()
    public var atributos: Atributos_audio!
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    // Anexos
    public var feanexo: FEAnexoData?
    public var idAnexoReemp: Int = -1
    public var anexosDict = [ (id: "", url: ""),(id: "", url: "") ]
    // Anexos
    // Tipificación
    public var docTypeDict = [(catalogoId: 0, descripcion: ""), (catalogoId: 0, description: "" )] as [Any]
    public var tipUnica: Int?
    public var listAllowed: [FEListTipoDoc] = []
    public var path = ""
    // Tipificación
    public var estiloBotones: String = ""
    public lazy var reemplazarAudio: Bool = false
    // PRIVATE
    var sdkAPI : APIManager<AudioCell>?
    var vw: MetaAttributesViewController = MetaAttributesViewController()
    var docID: Int = 0
    var allAnexos: [(anexo: FEAnexoData?, tipo: TipoAnexo, docid: String, metas: String)] = []
    var currentAnexos: [FEAnexoData]? = []
    var reAnexos: [FEAnexoData]? = []
    var startReemp : Bool = false
    var player: AVAudioPlayer?
    var heightHeaderCell : CGFloat = 0.0
    var lastTimeLabel : String = ""
    var milliseconds: Int = 0
    var timeString: String = ""
    var timeTimer: Timer?

    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
        (row as? AudioRow)?.presentationMode = nil
    }
    
   
    // MARK: SETTING
    /// SetObject for AudioRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_audio
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? AudioRow)?.cell.formCell()?.formViewController()?.tableView
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
        
        self.btnCall.translatesAutoresizingMaskIntoConstraints = false
        self.btnCall.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 10).isActive = true
        self.btnCall.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.btnCall.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let anchoBtn : CGFloat = (estiloBotones != "circulofondo" && estiloBotones != "circuloborde") ? 105.0 : 40.0
        self.btnCall.widthAnchor.constraint(equalToConstant: anchoBtn).isActive = true
        self.lblGrabar.text = "Grabar"
        self.btnCall = self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: btnCall, nameIcono: "ic_micro", titulo: self.lblGrabar.text!, colorFondo: self.atributos.coloraudio, colorTxt: self.atributos.colortextoaudio)
        btnCall.backgroundColor = UIColor(hexFromString: "#1E88E5")

        self.lblGrabar.translatesAutoresizingMaskIntoConstraints = false
        self.lblGrabar.centerXAnchor.constraint(equalTo: self.btnCall.centerXAnchor).isActive = true
        self.lblGrabar.topAnchor.constraint(equalTo: self.btnCall.bottomAnchor, constant: 3).isActive = true
        self.lblGrabar.widthAnchor.constraint(equalToConstant: 90.0).isActive = true
        self.lblGrabar.textColor = UIColor.black
        self.lblGrabar.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        self.lblGrabar.isHidden = self.btnCall.titleLabel?.text == self.lblGrabar.text! ? true : false
        
        self.lblDuracion.translatesAutoresizingMaskIntoConstraints = false
        self.lblDuracion.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 10).isActive = true
        self.lblDuracion.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        self.lblDuracion.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        
        self.lblTime.translatesAutoresizingMaskIntoConstraints = false
        self.lblTime.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 10).isActive = true
        self.lblTime.leadingAnchor.constraint(equalTo: self.lblDuracion.trailingAnchor, constant: 5).isActive = true
        self.lblTime.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.topAnchor.constraint(equalTo: self.lblDuracion.bottomAnchor, constant: 5).isActive = true
        self.progressView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        self.progressView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        self.progressView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.topAnchor.constraint(equalTo: self.progressView.bottomAnchor, constant: 10).isActive = true
        self.stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        self.stackView.isHidden = true
        
        
        self.btnClean.translatesAutoresizingMaskIntoConstraints = false
        self.btnClean.widthAnchor.constraint(equalToConstant: anchoBtn).isActive = true
        self.lblClean.text = "Eliminar"
        self.btnClean = self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: btnClean, nameIcono: "ic_delete", titulo: self.lblClean.text!, colorFondo: self.atributos.colorborrar, colorTxt: self.atributos.colortextoborrar)
                
        self.lblClean.textColor = UIColor.black
        self.lblClean.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.playButton.widthAnchor.constraint(equalToConstant: anchoBtn).isActive = true
        self.lblPlay.text = "Reproducir"
        self.playButton = self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.playButton, nameIcono: "ic_play", titulo: self.lblPlay.text!, colorFondo: self.atributos.coloraudio, colorTxt: self.atributos.colortextoaudio)
        
        self.lblPlay.textColor = UIColor.black
        self.lblPlay.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        
        self.btnReemplazo.translatesAutoresizingMaskIntoConstraints = false
        self.btnReemplazo.widthAnchor.constraint(equalToConstant: anchoBtn).isActive = true
        self.lblReemplazo.text = "Sustituir"
        self.btnReemplazo = self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnReemplazo, nameIcono: "ic_sustituir", titulo: self.lblReemplazo.text!, colorFondo: self.atributos?.colorreemplazar ?? "#1E88E5", colorTxt: self.atributos.colortextoreemplazar)
        
       
        self.lblReemplazo.textColor = UIColor.black
        self.lblReemplazo.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        
        self.btnCancelReemp.translatesAutoresizingMaskIntoConstraints = false
        self.btnCancelReemp.widthAnchor.constraint(equalToConstant: anchoBtn).isActive = true
        self.lblCancelReemp.text = "Deshacer"
        self.btnCancelReemp = self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnCancelReemp, nameIcono: "ic_deshacer", titulo: self.lblCancelReemp.text!, colorFondo: self.atributos?.colorreemplazar ?? "#1E88E5", colorTxt: self.atributos.colortextoreemplazar)
        
        self.lblCancelReemp.translatesAutoresizingMaskIntoConstraints = false
        self.lblCancelReemp.textColor = UIColor.black
        self.lblCancelReemp.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        
        self.download.translatesAutoresizingMaskIntoConstraints = false
        self.download.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 10).isActive = true
        self.download.centerXAnchor.constraint(equalTo: self.lblDownload.centerXAnchor, constant: 0).isActive = true
        self.download.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.download.widthAnchor.constraint(equalToConstant: anchoBtn).isActive = true
        self.lblDownload.text = "Descargar"
        self.download = self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.download, nameIcono: "ic_descarga", titulo: self.lblDownload.text!, colorFondo: self.atributos.coloraudio, colorTxt: self.atributos.colortextoaudio)
        self.download.addTarget(self, action: #selector(downloadAnexo(_:)), for: .touchDown)
        
        self.lblDownload.translatesAutoresizingMaskIntoConstraints = false
        self.lblDownload.topAnchor.constraint(equalTo: self.download.bottomAnchor, constant: 3).isActive = true
        self.lblDownload.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        self.lblDownload.textColor = UIColor.black
        self.lblDownload.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
    
        self.typeDocButton.translatesAutoresizingMaskIntoConstraints = false
        self.typeDocButton.topAnchor.constraint(equalTo: self.lblPlay.bottomAnchor, constant: 10).isActive = true
        self.typeDocButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.typeDocButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        self.typeDocButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: 0).isActive = true
        self.typeDocButton.layer.cornerRadius = typeDocButton.frame.height / 2
        self.typeDocButton.backgroundColor = UIColor(hexFromString: atributos?.coloraudio ?? "#1E88E5")
        self.typeDocButton.setTitle("     Tipo de documento ▼     ", for: .normal)
        
        self.bgHabilitado.translatesAutoresizingMaskIntoConstraints = false
        self.bgHabilitado.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.bgHabilitado.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.bgHabilitado.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.bgHabilitado.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.progressView.transform = self.progressView.transform.scaledBy(x: 1, y: 3)
        self.progressView.layer.cornerRadius = 2.0
        self.progressView.clipsToBounds = true
        self.progressView.layer.sublayers![1].cornerRadius = 2.0
        self.progressView.subviews[1].clipsToBounds = true

        getTipificacionPermitida()
        self.setHeightFromTitles()
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
        
        let apiMeta = MetaFormManager<AudioCell>()
        apiMeta.delegate = self
        
        sdkAPI = APIManager<AudioCell>()
        vw.delegate = apiMeta.delegate

    }

    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        
        if self.headersView.isInfoToolTipVisible{
            self.headersView.toolTip!.dismiss()
            self.headersView.isInfoToolTipVisible = false
        }
    }
    
    // MARK: - APIDELEGATE
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    
    // MARK: - ACTIONS
    @IBAction func btnCallAction(_ sender: Any) {
        self.lblGrabar.isHidden = true
        self.btnCall.isHidden = true
        let controller = AudioRecorderViewController()
        controller.row = self.row
        controller.atributos = self.atributos
        let presenter = Presentr(presentationType: .fullScreen)
        self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true)
        
        DispatchQueue.main.async {
            (self.row as? AudioRow)?.presentationMode = .show(controllerProvider: ControllerProvider.callback {
                return controller
                }, onDismiss: { [weak self] vc in
                    vc.dismiss(animated: true)
                    if controller.path != ""{
                        self?.lblTime.text = controller.timeRecord
                        self?.lastTimeLabel = self?.lblTime.text ?? ""
                        self?.setPath(controller.path, controller.guid)
                    } else if self?.startReemp == true {
                        self?.startReemp = false
                        self?.btnCancelReempAction(self?.btnCancelReemp ?? UIButton())
                    }else {
                        self?.lblGrabar.isHidden = false
                        self?.btnCall.isHidden = false
                    }
            })
            
            if !(self.row as? AudioRow)!.isDisabled {
                if let presentationMode = (self.row as? AudioRow)?.presentationMode {
                    if let controller = presentationMode.makeController(){
                        presentationMode.present(controller, row: (self.row as? AudioRow)!, presentingController: self.formViewController()!)
                        (self.row as? AudioRow)?.onPresentCallback?(self.formViewController()!, controller as! SelectorViewController<SelectorRow<AudioCell>>)
                    } else {
                        presentationMode.present(nil, row: (self.row as? AudioRow)!, presentingController: self.formViewController()!)
                    }
                }
            }
        }
        controller.delegate = self
    }
    
    // Llama descargar audio
    @IBAction func downloadAnexo(_ sender: Any) { setDownloadAnexo(sender) }
    
    // Elimina anexo audio
    @IBAction func btnCleanAction(_ sender: UIButton) {
        self.stackView.isHidden = true
        self.btnCall.isHidden = false
        self.lblGrabar.isHidden = false
        
        self.progressView.isHidden = true
        self.lblDuracion.isHidden = true
        self.lblTime.isHidden = true
        
        self.typeDocButton.isHidden = true
        self.typeDocButton.setTitle("     Tipo de documento ▼     ", for: .normal)
        
        self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
        row.value = nil
        row.validate()
        self.updateIfIsValid()
        self.setVariableHeight(Height: self.heightHeaderCell)
        triggerRulesOnChange("removeanexo")
    }
    
    // Inicia - Detiene reproduccion de audio
    @IBAction func playAction(_ sender: UIButton) {
        self.playURLAction()
    }
    
    func playURLAction() {
        if let player = player {
            player.stop()
            self.player = nil
            self.updateControls()
            return
        }
        do {
            guard let data = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(row.value ?? "")") else{ return }
            player = try AVAudioPlayer(data: data)
            player?.delegate = self
            print(player!.duration)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
            Timer.scheduledTimer(timeInterval: 0.0174, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
            timeTimer = Timer.scheduledTimer(timeInterval: 0.0174, target: self, selector: #selector(updateTimeLabel(timer:)), userInfo: nil, repeats: true)
           
            progressView.setProgress(Float(player.currentTime/player.duration), animated: false)
            self.updateControls()
        } catch { }
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        updateControls()
    }
    
    func updateControls(){
        if let _ = player {
            self.btnClean.isEnabled = false
            self.lblPlay.text = "Detener"
            self.playButton = self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: playButton, nameIcono: "ic_stop", titulo: self.lblPlay.text!, colorFondo: "#D32E2E", colorTxt: self.atributos.colortextoaudio)

        } else {
            self.lblPlay.text = "Reproducir"
            self.btnClean.isEnabled = true
            self.playButton = self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: playButton, nameIcono: "ic_play", titulo: self.lblPlay.text!, colorFondo: self.atributos.coloraudio, colorTxt: self.atributos.colortextoaudio)
            timeTimer?.invalidate()
            self.milliseconds = 0
            self.lblTime.text = self.lastTimeLabel
        }
        progressView.progress = 0.0
    }
    
    
    
    // Called AudioReemplazo Action
    @IBAction func btnReemplazoAction(_ sender: UIButton) {
        self.idAnexoReemp = sender.tag
        (self.currentAnexos?.first(where: {$0.DocID == self.idAnexoReemp}) ?? FEAnexoData()).Reemplazado = true
        self.reAnexos?.append(self.currentAnexos?.first(where: {$0.DocID == self.idAnexoReemp}) ?? FEAnexoData())
        self.startReemp = true
        reemplazarAudio = true
        self.boxBtnReempCancel.isHidden = false
        self.boxBtnPlay.isHidden = false
        self.boxBtnReemp.isHidden = true
        self.btnCallAction(sender)
    }
    
    // Cancel Reemplazo Action Reemplazo Action
    @IBAction func btnCancelReempAction(_ sender: UIButton) {
        let anteriorDoc = self.reAnexos?.first(where: {$0.DocID == self.idAnexoReemp}) ?? FEAnexoData()
        if anteriorDoc.TipoDocID != self.feanexo?.TipoDocID
        {   var menos = false; var mas = false;
            for list in self.listAllowed{
                if list.CatalogoId == anteriorDoc.TipoDocID && !mas { list.current += 1 ; mas = true}
                if list.CatalogoId == self.feanexo?.TipoDocID && !menos { list.current -= 1; menos = true }
            }
        }
        anteriorDoc.Reemplazado = false
        var auxAnexos: [FEAnexoData]? = []
        self.reAnexos?.forEach({ if $0.DocID != self.idAnexoReemp { auxAnexos?.append($0)} })
        self.reAnexos = auxAnexos
        self.feanexo = anteriorDoc
        self.setAnexoOption(anteriorDoc)
        FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == anteriorDoc.FileName { $0.Reemplazado = false }}
        self.stackView.isHidden = false
        self.boxBtnPlay.isHidden = false
        self.boxBtnReempCancel.isHidden = true
        self.boxBtnReemp.isHidden = false
        self.download.isHidden = true
        self.lblDownload.isHidden = true
        self.progressView.isHidden = false
        self.lblTime.text = self.lastTimeLabel
        self.lblTime.isHidden = false
        self.lblDuracion.isHidden = false
        self.idAnexoReemp = -1
    }
    
    @objc func updateAudioProgressView(){
        if let player = player{
            progressView.setProgress(Float(player.currentTime/player.duration), animated: true)
        }
    }
    
    @objc func updateTimeLabel(timer: Timer) {
        self.milliseconds += 1
        let milli = (milliseconds % 60) + 38
        let sec = (milliseconds / 60) % 60
        let min = milliseconds / 3600
        self.lblTime.text = NSString(format: "%02d:%02d.%02d", min, sec, milli) as String
        self.timeString = NSString(format: "%02d:%02d.%02d", min, sec, milli) as String
        
    }
    // MARK: - Autorización
    
    
    // MARK: - TIPIFYCATION
    // MARK: Set Permiso Tipificar
    public func setPermisoTipificar(_ bool: Bool){
        if bool{
            self.typeDocButton.isHidden = false
        }else{
            self.typeDocButton.isHidden = true
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
    

    // MARK: Button Action Document Type
    @IBAction func typeDocAction(_ sender: UIButton) {
        let presenter = Presentr(presentationType: .bottomHalf)
        self.formDelegate?.getFormViewControllerDelegate()?.customPresentViewController(presenter, viewController: vw, animated: true, completion: nil)
        
        self.vw.view.isHidden = false
        self.vw.lblTipoDoc.text = "elemts_meta_select".langlocalized()
        self.vw.listAllowed = self.listAllowed
        self.vw.feanexo = self.feanexo ?? FEAnexoData()
        self.vw.metaDataTableView.isHidden = true
        self.vw.documentType.isHidden = false
        self.vw.documentType.reloadAllComponents()
        self.vw.documentType.selectRow(0, inComponent: 0, animated: false)
        self.vw.metaBtnGuardar.isHidden = true
    }
    
    // MARK: - Meta Datos
    // MARK:  Button Action Metadata
    @IBAction func metaAction(_ sender: UIButton) {
        self.vw.view.isHidden = false
        self.vw.lblTipoDoc.text = "elemts_meta_write".langlocalized()
        self.vw.listAllowed = self.listAllowed
        self.vw.docID = self.docID
        self.vw.feanexo = self.feanexo ?? FEAnexoData()
        self.vw.metaDataTableView.isHidden = false
        self.vw.metaDataTableView.reloadData()
        self.vw.documentType.isHidden = true
        self.vw.metaBtnGuardar.isHidden = false
    }
    // MARK: Close Meta View
    @IBAction func closeMetaAction(_ sender: Any) {
        self.vw.dismiss(animated: true, completion: nil)
    }
    // MARK: Save Meta View
    @IBAction func saveMetaAction(_ sender: Any) {
        // Saving meta attibutes to the Document Typed
        let obj = feanexo
        obj?.Metadatos = []
        var counterFe = 0
        if obj?.Metadatos.count == 0{
            counterFe += 1
        }
        if counterFe == 0{
            let tipodoc: NSMutableDictionary = NSMutableDictionary();
            let meta: NSMutableDictionary = NSMutableDictionary();
            tipodoc.setValue("\(String(obj?.TipoDocID ?? 0))", forKey: "\(obj?.Guid ?? "")");
            let metadatos: NSMutableDictionary = NSMutableDictionary();
            if obj?.Metadatos.count ?? 0 > 0{
                for metaFe in (obj?.Metadatos)!{
                    metadatos.setValue("\(metaFe.NombreCampo)", forKey: "\(metaFe.Nombre)");
                }
                meta.setValue(metadatos, forKey: "\(obj?.Guid ?? "")");
                self.anexosDict.append((id: "\(0)", url: "\(obj?.NombreOriginal ?? "")"))
            }
            self.elemento.validacion.valor = tipodoc.toJsonString()
            self.elemento.validacion.valormetadato = meta.toJsonString()
            self.setEdited(v: obj?.FileName ?? "")
        }
    }
    
    // MARK: Saving Data from Metas
    public func savingData(){
        let obj = feanexo
        let tipodoc: NSMutableDictionary = NSMutableDictionary();
        let meta: NSMutableDictionary = NSMutableDictionary();
        
        tipodoc.setValue("\(String(obj?.TipoDocID ?? 0))", forKey: "\(obj?.Guid ?? "")");
        self.anexosDict[1] = (id: "\(0)", url: "\(obj?.FileName ?? "")")
        
        self.elemento.validacion.valor = tipodoc.toJsonString()
        self.elemento.validacion.valormetadato = meta.toJsonString()
        self.setValue(v: obj?.FileName ?? "")
        self.progressView.isHidden = false
        self.boxBtnPlay.isHidden = false
        self.lblDuracion.isHidden = false
        self.lblTime.isHidden = false
    }
}

// MARK: - OBJECTFORMDELEGATE
extension AudioCell: ObjectFormDelegate{
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
        est?.Campo = "Audio"
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
            self.bgHabilitado.isHidden = true
            self.row.baseCell.isUserInteractionEnabled = true
            self.row.disabled = false
        }else{
            self.bgHabilitado.isHidden = true
            self.row.baseCell.isUserInteractionEnabled = false
            self.row.disabled = true
        }
        self.row.evaluateDisabled()
    }
    // MARK: Set - Path
    public func setPath(_ p: String, _ g: String){
        path = p
        
        let ane = FEAnexoData()
        ane.Guid = "\(g)"
        ane.Extension = "mp3"
        ane.NombreOriginal = path
        ane.FileName = path
        
        if self.startReemp {
            FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.DocID == self.idAnexoReemp { $0.Reemplazado = true }}
            ane.DocID = self.idAnexoReemp
            for list in self.listAllowed {
                let auxAnt = self.reAnexos?.first(where: {$0.DocID == self.idAnexoReemp })
                if list.CatalogoId != auxAnt?.TipoDocID { continue }
                list.current -= 1
                break
            }
        }
        for list in self.listAllowed{
            if tipUnica == nil{ break }
            if list.CatalogoId != tipUnica{ continue }
            ane.TipoDocID = tipUnica ?? 0
            list.current += 1
        }
        self.feanexo = ane

        setEdited(v: path)
        
        self.setVariableHeight(Height: self.typeDocButton.isHidden ? 200 : 250)
        self.boxBtnPlay.isHidden = false
        self.boxBtnClean.isHidden = self.idAnexoReemp != -1 ? true : false
        self.boxBtnReemp.isHidden = true
        self.boxBtnReempCancel.isHidden = self.idAnexoReemp != -1 ? false : true
        
        self.stackView.isHidden = false
        self.progressView.isHidden =  false
        self.lblDuracion.isHidden =  false
        self.lblTime.isHidden = false
        
        if tipUnica == nil{ setPermisoTipificar(atributos?.permisotipificar ?? false) }
    }
    // MARK: Set - Edited
    public func setEdited(v: String){
        if v != ""{
            self.boxBtnReemp.isHidden = self.idAnexoReemp != -1 ? false : true
            self.boxBtnReempCancel.isHidden = self.idAnexoReemp != -1 ? false : true
            self.boxBtnClean.isHidden = self.idAnexoReemp != -1 ? true : false
            self.lblGrabar.isHidden = true
            self.btnCall.isHidden = true
            if tipUnica == nil && atributos?.permisotipificar ?? false == false{
                self.setValue(v: v)
            }else{
                if tipUnica != nil{
                    self.setValue(v: v)
                }else{
                    if atributos?.permisotipificar ?? false{
                        self.setPermisoTipificar(atributos?.permisotipificar ?? false)
                        if (self.elemento.validacion.valor != "" && self.elemento.validacion.valormetadato != ""){
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
            self.setVariableHeight(Height: self.heightHeaderCell)
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
        let obj = feanexo
        let tipodoc: NSMutableDictionary = NSMutableDictionary();
        tipodoc.setValue("\(String(obj?.TipoDocID ?? 0))", forKey: "\(obj?.Guid ?? "")");
        self.anexosDict[1] = (id: "\(0)", url: "\(obj?.FileName ?? "")")
        
        self.elemento.validacion.valor = tipodoc.toJsonString()
        
        self.anexosDict[1] = (id: "1", url: v)
        self.docTypeDict[1] = (catalogoId: obj?.TipoDocID, descripcion: obj?.TipoDocID ?? 0)
        self.setVariableHeight(Height: self.typeDocButton.isHidden ? 200 : 250)
        let localPath = "\(Cnstnt.Tree.anexos)/\(v)"
        if FCFileManager.existsItem(atPath: localPath){
            self.progressView.isHidden = true
            self.boxBtnPlay.isHidden = true
            self.lblDuracion.isHidden = true
            self.lblTime.isHidden = true
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
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        if row.isValid{ // Setting row as valid
            if row.value == nil{
                self.headersView.setMessage("")
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? AudioRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.validado = false
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            }else{
                self.headersView.setMessage("")
                resetValidation()
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? AudioRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.attData = ((row as? AudioRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.attData = ((row as? AudioRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
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
            self.elemento.validacion.anexos = (row as? AudioRow)?.cell.anexosDict
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

// MARK: AudioOptions
extension AudioCell: AudioOptions {
    func didCancel() {
        if reemplazarAudio {
            DispatchQueue.main.async {
                self.btnCall.isHidden = true
                self.lblGrabar.isHidden = true
                self.stackView.isHidden = false
                self.boxBtnReemp.isHidden = false
                self.boxBtnPlay.isHidden = false
                self.boxBtnClean.isHidden = true
                self.boxBtnReempCancel.isHidden = true
                
            }
        }
    }
}

// MARK: - ATTACHEDFORMDELEGATE
extension AudioCell: AttachedFormDelegate{
    
    func setMetaValues() -> Bool{ return false }
    
    // MARK: Set - Anexo Option
    public func setAnexoOption(_ anexo: FEAnexoData){
        self.currentAnexos?.append(anexo)
        if anexo.Reemplazado{
            self.reAnexos?.append(anexo)
            return
        }
        // Detect if the attachment is in the phone
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
            setEdited(v: "\(anexo.FileName)")
//            self.download.isHidden = true
//            self.lblDownload.isHidden = true
        }else{
        // Set Download option
            self.download.isHidden = false
            self.lblDownload.isHidden = false
        }
        
        self.btnReemplazo.tag = anexo.DocID
        self.boxBtnReemp.isHidden = self.idAnexoReemp != -1 ? false : true
        self.boxBtnReempCancel.isHidden = self.idAnexoReemp != -1 ? false : true
        self.download.isHidden = anexo.DocID != 0 ? false : true
        self.lblDownload.isHidden = anexo.DocID != 0 ? false : true
        
        self.stackView.isHidden = anexo.DocID != 0 ? true : false
        self.boxBtnPlay.isHidden = anexo.DocID != 0 ? true : false
        
        self.boxBtnClean.isHidden = anexo.DocID != 0 ? true : false
        
        do {
            guard let data = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(self.row.value ?? "")") else{ return }
            self.player = try! AVAudioPlayer(data: data)
            self.player?.delegate = self
            self.lblTime.text = self.player!.duration.stringFromTimeInterval()
            self.lastTimeLabel = self.lblTime.text ?? ""
        }
        self.lblDuracion.isHidden = anexo.DocID != 0 ? true : false
        self.lblTime.isHidden = anexo.DocID != 0 ? true : false
        self.progressView.isHidden = anexo.DocID != 0 ? true : false
        
    }
    
    // MARK: Set - Local Anexo
    public func didSetLocalAnexo(_ feAnexo: FEAnexoData){ }
    
    // MARK: Set - Attributes to Controller
    public func setAttributesToController(){ }
    
    // MARK: Set - Anexo
    public func setAnexo(_ anexo: FEAnexoData) { }
    
    // MARK: Set - Preview
    public func setPreview(_ sender: Any) {  }
    
    // MARK: Set - Download Anexo
    public func setDownloadAnexo(_ sender: Any) {
        
        if !ConfigurationManager.shared.usuarioUIAppDelegate.PermisoDescargarAnexos{
            self.download.isHidden = true
            self.lblDownload.isHidden = true
            self.setMessage("El usuario no tiene permisos de descargar el anexo", .warning)
            return
        }else{
            self.download.isHidden = false
            self.lblDownload.isHidden = false
        }
        
        self.setMessage("hud_downloading".langlocalized(), .info)
        (row as? AudioRow)?.disabled = true
        (row as? AudioRow)?.evaluateDisabled()
        if self.currentAnexos?.count == 0{ return }
        for ane in self.currentAnexos!{
            self.sdkAPI?.DGSDKformatoAnexos(delegate: self, anexo: ane, estado: FormularioUtilities.shared.currentFormato.EstadoApp)
                .then{ response in
                    if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(ane.FileName)"){
                        self.setEdited(v: "\(ane.FileName)")
                        do {
                            guard let data = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(self.row.value ?? "")") else{ return }
                            self.player = try AVAudioPlayer(data: data)
                            self.player?.delegate = self
                            self.lblTime.text = self.player!.duration.stringFromTimeInterval()
                            self.lastTimeLabel = self.lblTime.text ?? ""
                            guard self.player != nil else { return }
                        }
                        
                        self.stackView.isHidden = false
                        self.download.isHidden = true
                        self.lblDownload.isHidden = true
                        self.boxBtnPlay.isHidden = false
                        self.boxBtnReemp.isHidden = false
                        self.lblTime.isHidden = false
                        self.lblDuracion.isHidden = false
                        self.progressView.isHidden = false
                        self.boxBtnClean.isHidden = true
                        
//                        ane.DocID != 0 ? true : false
                    }else{
                        self.download.isHidden = false
                        self.lblDownload.isHidden = false
                        self.setMessage("elemts_attch_server".langlocalized(), .info)
                    }
                    (self.row as? AudioRow)?.disabled = false
                    (self.row as? AudioRow)?.evaluateDisabled()
                }.catch{ error in
                    (self.row as? AudioRow)?.disabled = false
                    (self.row as? AudioRow)?.evaluateDisabled()
                    self.setMessage("elemts_attch_error".langlocalized(), .info)
                }
        }
    }
    
}

extension TimeInterval{

        func stringFromTimeInterval() -> String {

            let time = NSInteger(self)

            let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 100)
            let seconds = time % 60
            let minutes = (time / 60) % 60

            return String(format: "%0.2d:%0.2d.%0.2d",minutes,seconds,ms)

        }
    }

extension AudioCell{
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

extension AudioCell: MetaFormDelegate{
    public func didClose() {
        self.closeMetaAction(Any.self)
    }
    
    public func didSave() {
        self.saveMetaAction(Any.self)
        self.closeMetaAction(Any.self)
    }
    
    public func didUpdateData(_ tipoDoc: String, _ idDoc: Int) {
        self.typeDocButton.setTitle("     \(tipoDoc) ▼     ", for: .normal)
        self.docID = idDoc
    }
}
