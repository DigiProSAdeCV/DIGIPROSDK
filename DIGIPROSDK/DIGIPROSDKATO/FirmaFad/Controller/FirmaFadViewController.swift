import Foundation
import UIKit
import CoreLocation
import AVFoundation
import Security
import CommonCrypto

import Vision
import Eureka

enum UserTypeAttached<T>: Equatable where T: Equatable {
    case userSignature(T) // opcion video del que firma
    case witness(T) // testigo
}

enum TypeAttached {
    case photo
    case video
}


class FirmaFadViewController: UIViewController, SignatureDrawingViewControllerDelegate, TypedRowControllerType, AVCaptureFileOutputRecordingDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var newTermAndView: UIView = {
        let properties = UIView()
        properties.translatesAutoresizingMaskIntoConstraints = false
        properties.backgroundColor = UIColor.white
        properties.layer.shadowColor = UIColor.black.cgColor
        properties.layer.shadowOpacity = 0.5
        properties.layer.shadowOffset = .zero
        properties.layer.shadowRadius = 10
        properties.layer.cornerRadius = 10
        return properties
    }()
    
    let termAndConditionsText: UITextView = {
        let content = UITextView()
        content.text = ""
        content.translatesAutoresizingMaskIntoConstraints = false
        content.isEditable = false
        content.textColor = .black
        content.backgroundColor = .clear
        return content
    }()
    
    // MARK: Detección del rostro variables
    var isFaceVisible: Bool = false
    var session: AVCaptureSession?
    var flagAction = ""
    var sdkAPI = APIManager<FirmaFadViewController>()
    var isExpanded: Bool = false
    var photoData: Data?
    // MARK: End Detección del rostro variables
    /// The row that pushed or presented this controller
    public var row: RowOf<String>!
    var genericRow: FirmaFadRow! {return row as? FirmaFadRow}
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    public var atributos: Atributos_firmafad?
    public var hashObject: Atributos_firma_hash = Atributos_firma_hash()
    public var anexoTXTObject: Atributos_firma_Anexo = Atributos_firma_Anexo()
    public var hashJson: String = ""
    public var hashCrypt: String = ""
    public var formDelegate: FormularioDelegate?
    // MARK: UIViewController+
    public var signature: UIImage?
    public var cursivaSignature: UIImage?
    public var signatureLabel: String?
    public var nombreCompleto = ""
    public var resultSign: UIImageView?
    public var path = ""
    public var guid = ""
    public var newGuid = ConfigurationManager.shared.utilities.guid()
    public var pathVideo = ""
    public var pathTxt = ""
    public var isGrafo: Bool = false
    let locationManager = CLLocationManager()
    
    // Terms & Conditions
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var signPersona: UILabel!
    @IBOutlet weak var signatureTextView: UITextView!
    @IBOutlet weak var agreedBtn: UIButton!
    
    @IBOutlet weak var viewButtons: UIView!
    @IBOutlet weak var videoViewCapture: UIView!
    
    @IBOutlet weak var btnOkCheck: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnCerrar: UIButton!
    @IBOutlet weak var tycButton: UIButton!
    @IBOutlet weak var tycImageView: UIImageView!
    @IBOutlet weak var underlineImageview: UIImageView!
    
    // RodrigoPruebas - Movilidad
    var alertFace: BaseNotificationBanner?
    var captureSession = AVCaptureSession()
    var movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var activeInput: AVCaptureDeviceInput?
    var outputURL: URL?
    var videoData: Data?
    var imageData: Data?
    var testigoData: Data?
    var gps: String = ""
    var time: String = ""
    var acuerdoFirma: String = ""
    var personaFirma: String = ""
    var cleanFlag: Bool = false
    
    deinit
    {
        formDelegate = nil
        atributos = nil
        session = nil
        hashObject = Atributos_firma_hash()
        anexoTXTObject = Atributos_firma_Anexo()
        formDelegate = nil
        signature = nil
        signatureLabel = nil
        resultSign = nil
        alertFace = nil
        captureSession = AVCaptureSession()
        movieOutput = AVCaptureMovieFileOutput()
        previewLayer = nil
        activeInput = nil
        outputURL = nil
        videoData = nil
        imageData = nil
        testigoData = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sdkAPI.delegate = self
        setTermAndConditions()
        
        initComponents()
        setConstraints() // constraints signatureviewcontroller
        
        updateContraintPreviewVideo()
        validarTipoDeFirma()
        self.newTermAndView.isHidden = true
        self.termAndConditionsText.isHidden = true
        self.tycButton.layer.cornerRadius = 8.0
        self.tycImageView.image = UIImage(named: "ic_tyc_fad", in: Cnstnt.Path.framework, compatibleWith: nil)
        
    }
    
    private func initComponents() {
        self.signPersona.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 17)
        
        //#Btn Fondo/Redondo
        self.btnCerrar.backgroundColor = UIColor.red
        self.btnCerrar.layer.cornerRadius = self.btnCerrar.frame.height / 2
        self.btnCerrar.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        self.btnOkCheck.setImage(UIImage(named: "check_full", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        btnRedo.backgroundColor = UIColor.systemYellow
        btnRedo.layer.cornerRadius = btnRedo.frame.height / 2
        btnRedo.setImage(UIImage(named: "ic_redo", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        signatureViewController.delegate = self
        self.signatureViewController.view.layer.borderWidth = 1
        self.signatureViewController.view.backgroundColor = UIColor(hexFromString: "#ffffff", alpha: 0.4)
        self.signatureViewController.view.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
    }
    
    @IBAction func tycAction(_ sender: UIButton) {
        let tycController = TyCfirmaFadViewController(nibName: "TyCfirmaFadViewController", bundle: Cnstnt.Path.framework)
        tycController.tycFirma = self.signatureLabel ?? ""
        tycController.flagtyc = true
        self.present(tycController, animated: true, completion: nil)

    }
    
    
    private func updateContraintPreviewVideo() {
        
        self.videoViewCapture.removeFromSuperview()
        self.view.addSubview(videoViewCapture)
        
        
        self.videoViewCapture.removeConstraints(self.videoViewCapture.constraints)
        self.videoViewCapture.layer.cornerRadius = 8
        self.videoViewCapture.translatesAutoresizingMaskIntoConstraints = false
        
        self.videoViewCapture.topAnchor.constraint(equalTo: self.tycButton.bottomAnchor, constant: 58.0).isActive = true
        self.videoViewCapture.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.videoViewCapture.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.64).isActive = true
        self.videoViewCapture.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.97).isActive = true
        self.videoViewCapture.updateConstraints()
        self.videoViewCapture.layer.masksToBounds = true
        self.videoViewCapture.reloadInputViews()
        self.videoViewCapture.clipsToBounds = true
        self.videoViewCapture.needsUpdateConstraints()
        self.videoViewCapture.layoutIfNeeded()
        
        
        self.viewButtons.removeConstraints(self.viewButtons.constraints)
        self.viewButtons.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewButtons.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        self.viewButtons.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
        self.viewButtons.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.10).isActive = true
        self.viewButtons.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.viewButtons.backgroundColor = UIColor.clear
        self.viewButtons.reloadInputViews()
        self.viewButtons.needsUpdateConstraints()
        self.viewButtons.layoutIfNeeded()
        
        self.btnOkCheck.translatesAutoresizingMaskIntoConstraints = false
        self.btnOkCheck.leadingAnchor.constraint(equalTo: self.viewButtons.leadingAnchor, constant: 0).isActive = true
        self.btnOkCheck.heightAnchor.constraint(equalTo: self.view.heightAnchor , multiplier: 0.08).isActive = true
        self.btnOkCheck.widthAnchor.constraint(equalTo: self.view.heightAnchor , multiplier: 0.08).isActive = true
        
        self.btnRedo.translatesAutoresizingMaskIntoConstraints = false
        self.btnRedo.trailingAnchor.constraint(equalTo: self.viewButtons.trailingAnchor,constant: 0).isActive = true
        self.btnRedo.heightAnchor.constraint(equalTo: self.view.heightAnchor , multiplier: 0.08).isActive = true
        self.btnRedo.widthAnchor.constraint(equalTo: self.view.heightAnchor , multiplier: 0.08).isActive = true
        
        self.viewButtons.isHidden = true
    }
    
    // MARK: term and conditions view
    private func setTermAndConditions() {
        self.view.addSubview(newTermAndView)
        
        self.termsView.removeConstraints(self.termsView.constraints)
        self.termsView.translatesAutoresizingMaskIntoConstraints = true
        self.termsView.isHidden = true
        
        modifyConstraintTermAndConditionView(newTermAndView)
        addTextTermAndConditionTextView()
        //closeButtonUpdate()
        addIconExpand(newTermAndView)
    }
    
    private func addTextTermAndConditionTextView() {
        self.newTermAndView.addSubview(termAndConditionsText)
        self.termAndConditionsText.text = atributos?.acuerdofirma ?? ""
        NSLayoutConstraint.activate([
            termAndConditionsText.topAnchor.constraint(equalTo: self.newTermAndView.topAnchor, constant: 8),
            termAndConditionsText.leadingAnchor.constraint(equalTo: self.newTermAndView.leadingAnchor, constant: 8),
            termAndConditionsText.trailingAnchor.constraint(equalTo: self.btnCerrar.leadingAnchor, constant: 0),
            termAndConditionsText.bottomAnchor.constraint(equalTo: self.newTermAndView.bottomAnchor, constant: -8)
        ])
    }
    
    private func closeButtonUpdate() {
        if alertFace?.isDisplaying ?? false { alertFace?.dismiss() }
        //   self.btnCerrar.translatesAutoresizingMaskIntoConstraints = false
        self.newTermAndView.addSubview(self.btnCerrar)
        self.btnCerrar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.btnCerrar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.btnCerrar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            self.btnCerrar.heightAnchor.constraint(equalToConstant: 50),
            self.btnCerrar.widthAnchor.constraint(equalToConstant: 50),
        ])
        
    }
    
    private func modifyConstraintTermAndConditionView(_ vista: UIView) {
        NSLayoutConstraint.activate([
            vista.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
            vista.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.90),
            vista.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 16),
            vista.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -16),
            vista.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.20),
        ])
    }
    
    private func validarTipoDeFirma() {
        switch atributos?.tipovalidacion {
        case "ninguna": //Grafo
            isGrafo = true
            self.signatureViewController.view.isHidden = false
            self.videoViewCapture.isHidden = true
            self.view.bringSubviewToFront(signatureViewController.view)
            break
        case "video", "testigo": //video/imagen
            detectFaceActivate()
            break
        default:
            detectFaceActivate()
            break
        }
    }
    
    private func addIconExpand(_ vista: UIView) {
        let expandIcon: UIImageView = {
            let propertires = UIImageView()
            propertires.translatesAutoresizingMaskIntoConstraints = false
            propertires.image = UIImage(named: "iconfinder_expand", in: Cnstnt.Path.framework, compatibleWith: nil)
            propertires.isUserInteractionEnabled = true
            return propertires
        }()
        
        vista.addSubview(expandIcon)
        
        NSLayoutConstraint.activate([
            expandIcon.bottomAnchor.constraint(equalTo: vista.bottomAnchor, constant: -8),
            expandIcon.trailingAnchor.constraint(equalTo: vista.trailingAnchor, constant: -8),
            expandIcon.heightAnchor.constraint(equalToConstant: 20),
            expandIcon.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleExpand))
        expandIcon.addGestureRecognizer(tap)
        
    }
    
    @objc func toggleExpand() {
        if isExpanded {
            newTermAndView.heightConstraint?.constant = UIScreen.main.bounds.height * 0.20
        } else {
            newTermAndView.heightConstraint?.constant = UIScreen.main.bounds.height * 0.80
        }
        isExpanded = !isExpanded
    }
    
    // MARK: function to detection face
    private func detectFaceActivate() {
        self.isFaceVisible = false // se debe reiniciar esta bandera a false
        alertFace = StatusBarNotificationBanner(title: "Muestra tú rostro frente a la cámara.", style: .info)
        alertFace?.autoDismiss = true
        alertFace?.duration = 3.0
        alertFace?.show(bannerPosition: .bottom)

        captureSession.sessionPreset = .medium
        
        // MARK: esto es para evitar Multiple audio/video AVCaptureInputs are not currently supported
        if let inputs = self.captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
        
        if self.captureSession.outputs.count > 0{
            for output in self.captureSession.outputs {
                self.captureSession.removeOutput(output)
            }
        }
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera , for: AVMediaType.video, position: AVCaptureDevice.Position.front) else { return }
        if(captureDevice.isFocusModeSupported(.continuousAutoFocus)) {
            do{
                try captureDevice.lockForConfiguration()
                captureDevice.focusMode = .autoFocus
                captureDevice.unlockForConfiguration()
            }catch{
                
            }
             
         }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard let captureAudio = AVCaptureDevice.default(for: AVMediaType.audio) else { return }
        guard let inputAudio = try? AVCaptureDeviceInput(device: captureAudio) else { return }
        activeInput = input
        captureSession.addInput(input)
        captureSession.addInput(inputAudio)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = videoViewCapture.bounds
        previewLayer.videoGravity = .resizeAspectFill
        videoViewCapture.layer.addSublayer(previewLayer)
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func successMessageDetectFace() {
        if alertFace?.isDisplaying ?? false { alertFace?.dismiss() }
        let bannerNew = StatusBarNotificationBanner(title: "Rostro detectado, ya puede firmar.", style: .success)
        bannerNew.duration = 1.0
        bannerNew.dismissDuration = 1.0
        bannerNew.show(bannerPosition: .bottom)
        self.signatureViewController.view.isHidden = false
        self.view.bringSubviewToFront(signatureViewController.view)
    }
    
    // MARK: es para revisar o poner un limite de 15 segundos al video.
     func limitStopRecord() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(atributos?.intervalomaximo ?? 5)) {
            self.cleanAction()
        }
    }
    
    // MARK: function stop and back
    private func stopRecordAndBack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(100)) {
            self.stopSession()
            self.stopRecording()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Getting values
        let nn = (row as? FirmaFadRow)?.cell.formDelegate!.getValueFromComponent((row as? FirmaFadRow)?.cell.atributos.personafirma ?? "")
        signPersona.text = nn
        updateConstraintNameSig()
        updateContraintPreviewVideo()
    }
    
     func updateConstraintNameSig() {
        
        self.view.addSubview(signPersona)
        self.view.bringSubviewToFront(signPersona)
        
        signPersona.isHidden = false
        signPersona.textAlignment = .center
        signPersona.textColor = UIColor.black
        signPersona.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    
    @IBAction func agreedAction(_ sender: Any) {
        
        termsView.isHidden = true
        if row.value == nil{
            detectFaceActivate()
            //cleanAction()
        }
        
    }
    
    @IBAction func cerrarAction(_ sender: Any) {
        if alertFace?.isDisplaying ?? false { alertFace?.dismiss() }
        if let navController = self.navigationController {
            UILoader.remove(parent: self.view)
            navController.popViewController(animated: true)
        }
        onDismissCallback?(self)
    }
    
    @IBAction func removerAction(_ sender: Any) {
        signature = nil
        signatureViewController.reset()
    }
    
    @IBAction func borrarAction(_ sender: Any) {
        
        UILoader.show(parent: self.view)
        
        DispatchQueue.global(qos: .background).async {
            
            DispatchQueue.main.async {
                self.videoViewCapture.isHidden = false
                
                self.viewButtons.isHidden = true
//                self.view.subviews.forEach({
//                    if $0.isKind(of: UIImageView.self){
//
//                        $0.removeFromSuperview()
//                    }
//                })
                self.signature = nil
                self.signatureViewController.reset()
                self.resultSign?.image = nil
                self.resultSign?.removeFromSuperview()
                self.setConstraints() // constraints view signature
                self.hideSignatureLayoutView()
                self.stopRecording()
                self.stopSession()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                if self.isGrafo {
                    UILoader.remove(parent: self.view)
                    self.signatureViewController.view.isHidden = false
                    self.videoViewCapture.isHidden = true
                    self.view.bringSubviewToFront(self.signatureViewController.view)
                }
                else if self.setupSession() {
                    self.startSession()
                    self.startRecording()
                    self.detectFaceActivate()
                    self.viewButtons.isHidden = true
                    self.videoViewCapture.isHidden = false
                    UILoader.remove(parent: self.view)
                }
            }
        }
        
        
    }
    
    func cleanAction() {
        
        self.isFaceVisible = false
        self.cleanFlag = false
        self.viewButtons.isHidden = true
        
        self.view.subviews.forEach({
            if $0.isKind(of: UIImageView.self){
                $0.removeFromSuperview()
            }
        })
        signature = nil
        signatureViewController.reset()
        resultSign?.image = nil
        resultSign?.removeFromSuperview()
        setConstraints()
        self.stopRecording()
        self.stopSession()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            if self.setupSession(){
                self.startSession()
                self.startRecording()
            }
        }
        
    }
    
    func hideSignatureLayoutView() {
        signatureViewController.view.isHidden = true
    }
    
    func setConstraints(){
        self.view.addSubview(signatureViewController.view)
        signatureViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        signatureViewController.view.topAnchor.constraint(equalTo: self.tycButton.bottomAnchor, constant: 58.0).isActive = true
        signatureViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        signatureViewController.view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.64).isActive = true
        signatureViewController.view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.45).isActive = true
    }
    
    @IBAction func GuardarAction(_ sender: Any?) {
        self.cleanFlag = true
        if signature == nil{
            signature = signatureViewController.fullSignatureImage
        }else{
            signature = signatureViewController.fullSignatureImage
        }
        signatureViewController.reset()
        path = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
        
        if self.signature != nil {
            let _ = ConfigurationManager.shared.utilities.saveImageToFolder(signature!, path)
        } else {
            let _ = ConfigurationManager.shared.utilities.saveImageToFolder(cursivaSignature!, path)
        }
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        self.viewButtons.isHidden = false
        UILoader.show(parent: self.view)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }

    }
    
    //Instanciar esta clase y llamar este metodo para guardar firma cursiva.
    public func guardarFirmaCursiva(_ firmaCursiva: UIImage, completion: @escaping () -> ()) {
        cursivaSignature = firmaCursiva
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        //Esperamos a que locatiobManager(_ manager:) termine de ejecutarse, approx un segundo y hacemos el completion.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        if let signature = signatureViewController.fullSignatureImage {
            
            self.signature = signature.resized(toWidth: 0.3)
            signatureViewController.view.removeFromSuperview()
            
            if signature.size.width > 1600{
                let newWidth = signature.size.width / 2
                let newHeight = signature.size.height / 2
                let newImage = signature.resizeVI(size: CGSize(width: newWidth, height: newHeight))
                self.signature = newImage
            }
    
        } else if let signature = cursivaSignature {
            self.signature = signature
        }
        
        
        let _ = (row as? FirmaFadRow)?.cell.formDelegate!.getValueFromComponent((row as? FirmaFadRow)?.cell.atributos.personafirma ?? "")
        let _ = ConfigurationManager.shared.deviceToken
        // Saving Data for Generating HASH
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd H:mm:ss.SS"
        let dateInfo = formatter.string(from: date)
        self.time = dateInfo
        self.hashObject.tiempo = self.time
        self.anexoTXTObject.tiempo = self.time
        (row as? FirmaFadRow)?.cell.elemento.validacion.fecha = self.time
        
        let device = Device()
        let deviceInfo = "\(device.description), iOS \(device.systemVersion ?? "") "
        self.hashObject.deviceDesc = deviceInfo
        self.anexoTXTObject.dispositivo = deviceInfo
        (row as? FirmaFadRow)?.cell.elemento.validacion.dispositivo = deviceInfo
        
        let location = "\(locValue.latitude), \(locValue.longitude)"
        self.gps = location
        self.hashObject.gps = self.gps
        self.anexoTXTObject.localizacion = self.gps
        (row as? FirmaFadRow)?.cell.elemento.validacion.georeferencia = self.gps
        
        self.acuerdoFirma = atributos?.acuerdofirma ?? ""
        self.hashObject.acuerdofirma = self.acuerdoFirma
        self.anexoTXTObject.acuerdofirma = self.acuerdoFirma
        (row as? FirmaFadRow)?.cell.elemento.validacion.acuerdofirma = self.acuerdoFirma
        
        self.personaFirma = signPersona?.text ?? ""
        self.hashObject.personafirma = self.personaFirma
        self.anexoTXTObject.personafirma = self.personaFirma
        (row as? FirmaFadRow)?.cell.elemento.validacion.personafirma = self.personaFirma
        
        // dataFile
        self.imageData = signature?.jpegData(compressionQuality: 0.6) //signature?.pngData()
        let anexoBase64 = self.imageData?.base64EncodedData()
        let testigoBase64 = self.testigoData?.base64EncodedData()
        self.hashObject.imagebase64 = String(data: anexoBase64 ?? Data(), encoding: String.Encoding.utf8) as String? ?? ""
        self.hashObject.imagevideobase64 = String(data: testigoBase64 ?? Data(), encoding: String.Encoding.utf8) as String? ?? ""
        
        if atributos?.tipovalidacion ?? "" == "testigo" { self.hashObject.videobase64 = "" }
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        self.GuardarAction((Any).self)
        self.stopRecordAndBack()
        
        if isGrafo {
            if let navController = self.navigationController {
                UILoader.remove(parent: self.view)
                navController.popViewController(animated: true)
            }
            self.onDismissCallback?(self)
        } 
        
    }
    
    //MARK:- Setup Camera
    func setupSession() -> Bool {
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.medium
        
        // Setup Camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera , for: AVMediaType.video, position: AVCaptureDevice.Position.front) else{ return false }
        do {
            if(camera.isFocusModeSupported(.continuousAutoFocus)) {
                try camera.lockForConfiguration()
                camera.focusMode = .autoFocus
                camera.unlockForConfiguration()
             }
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch { return false }
        
        // captureSession.addOutput(photoOutput)
        
        // Setup Microphone
        guard let microphone = AVCaptureDevice.default(for: AVMediaType.audio) else{ return false }
        do {
            try microphone.lockForConfiguration()
            let micInput = try AVCaptureDeviceInput(device: microphone)
            microphone.unlockForConfiguration()
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch { return false }
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        captureSession.commitConfiguration()
        return true
    }
    
    //MARK:- Camera Session
    func startSession() {
        if !captureSession.isRunning {
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            self.captureSession.stopRunning()
        }
    }
    func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait: orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight: orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown: orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default: orientation = AVCaptureVideoOrientation.landscapeRight }
        return orientation
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func startRecording() {
        if movieOutput.isRecording == false {
            let connection = movieOutput.connection(with: AVMediaType.video)
            if (connection?.isVideoOrientationSupported)! { connection?.videoOrientation = currentVideoOrientation() }
            if (connection?.isVideoStabilizationSupported)! { connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto }
            outputURL = tempURL()
            if outputURL != nil{
                movieOutput.startRecording(to: outputURL!, recordingDelegate: self)

            }
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        var videoData: Data? = Data()
        if (error != nil) { return }
        
        do{
            let dataFile = try Data(contentsOf: outputURL!)
            videoData = dataFile
            if atributos?.tipovalidacion ?? "" != "testigo" {
                self.pathVideo = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_2_\(ConfigurationManager.shared.utilities.guid()).ane"
                (row as? FirmaFadRow)?.cell.pathVideo = self.pathVideo
            }
            if self.testigoData == nil{
                self.pathVideo = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_2_\(ConfigurationManager.shared.utilities.guid()).ane"
                (row as? FirmaFadRow)?.cell.pathVideo = self.pathVideo
            }

            
            let compressedURL =  NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
            compressVideo(inputURL: outputFileURL as URL,
                          outputURL: compressedURL) { exportSession in
                guard let session = exportSession else { return }
                            
                switch session.status {
                case .unknown: break
                case .waiting: break
                case .exporting: break
                case .completed:
                    guard let compressedData = try? Data(contentsOf: compressedURL) else { return }
                    videoData = compressedData; break
                case .failed: break
                case .cancelled: break
                @unknown default: break }
            }
            
            if self.cleanFlag {
                if atributos?.tipovalidacion ?? "" != "testigo" {
                    let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(videoData! as NSData, self.pathVideo)
                }
                if self.testigoData == nil{
                    let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(videoData! as NSData, self.pathVideo)
                }

                // dataFile
                let anexoBase64 = self.imageData?.base64EncodedData()
                self.hashObject.imagebase64 = String(data: anexoBase64 ?? Data(), encoding: String.Encoding.utf8) as String? ?? ""
                // en el caso del video
                let videoBase64 = dataFile.base64EncodedData()
                if atributos?.tipovalidacion ?? "" != "testigo" {
                    self.hashObject.videobase64 = String(data: videoBase64, encoding: String.Encoding.utf8) as String? ?? ""
                } else { self.hashObject.imagevideobase64 = "" }
                
                self.timeStampService()
                print("TXT OBJECT: \(self.anexoTXTObject)")
                if let navController = self.navigationController {
                    UILoader.remove(parent: self.view)
                    navController.popViewController(animated: true)
                }
                self.onDismissCallback?(self)
            }

        }catch{ }
        
    }
    
    func jsonToNSData(json: AnyObject) -> NSData?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
    func jsonToData(json: Any) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.sortedKeys)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
    
    func timeStampService ()
    {
        DispatchQueue.main.async {
            self.hashJson = self.hashObject.toJsonString()
            self.hashCrypt = self.hashJson.sha512()
            self.anexoTXTObject.hashCrypt = self.hashCrypt
            (self.row as? FirmaFadRow)?.cell.elemento.validacion.hashFad = self.hashCrypt
            (self.row as? FirmaFadRow)?.cell.atributos.hashCrypt = self.hashCrypt
            self.atributos?.hashCrypt = self.hashCrypt
//            self.pathTxt = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_4_\(ConfigurationManager.shared.utilities.guid()).ane"
//            let dataString = JSONSerializer.toJson(self.anexoTXTObject)
//            let dataTXT = self.jsonToData(json: dataString)
//            let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(dataTXT! as NSData, self.pathTxt)
//            (self.row as? FirmaFadRow)?.cell.pathTXT = self.pathTxt
            print("TXT OBJECT 2: \(self.anexoTXTObject)")
            if self.atributos?.obtenerhash ?? false {
                let data:[String : Any] = ["tipo" : self.atributos?.proveedor ?? "", "hash": self.hashCrypt ]
                self.sdkAPI.servTimestampFAD(delegate: self, jsonService: data, nameServ: "ServiciosDigipro.ServicioSelladoTiempo.SolicitayDescargaSellado", dllServ: "ServiciosDigipro.dll")
                    .then { response in
                        let hashGenerado = response
                        self.anexoTXTObject.timestamp = hashGenerado
                        (self.row as? FirmaFadRow)?.cell.elemento.validacion.guidtimestamp = hashGenerado
//                        self.pathTxt = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_4_\(ConfigurationManager.shared.utilities.guid()).ane"
//                        let dataTXT = self.jsonToNSData(json: self.anexoTXTObject)
//                        let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(dataTXT!, self.pathTxt)
//                        (self.row as? FirmaFadRow)?.cell.pathTXT = self.pathTxt
                        print(hashGenerado)
                    }.catch { error in
                        let e = error as NSError
                        print("Sin HASH generado")
                        print(e.localizedDescription)
                        
                    }
            }
        }
    }
    
    // MARK: SignatureDrawingViewControllerDelegate
    func signatureDrawingViewControllerIsEmptyDidChange(controller: SignatureDrawingViewController, isEmpty: Bool) {
        self.viewButtons.isHidden = false
    }
    
    // MARK: Private
    public let signatureViewController = SignatureDrawingViewController()
    
    // MARK: Transition
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            self.previewLayer?.frame = self.videoViewCapture.bounds
            self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            if self.previewLayer != nil{
                self.videoViewCapture.layer.addSublayer(self.previewLayer!)
            }
        }
    
    }
    
}

extension FirmaFadViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) { }

    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage
    {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectFaceRectanglesRequest { (req, err) in
            
            if let err = err {
                print("Failed to detect faces:", err)
                return
            }
            guard let results = req.results as? [VNFaceObservation] else {
                    return
            }
            // Face detected
            // Perform all UI updates (drawing) on the main queue, not the background queue on which this handler is being called.
            // Delay face detection for a better image quality
            if results.count == 1 && self.isFaceVisible == false{
                // pixelBuffer to Image
                self.isFaceVisible = true
                let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
                let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
                let image : UIImage = self.convert(cmage: ciimage)
                
                let path = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_3_\(ConfigurationManager.shared.utilities.guid()).ane"

                self.testigoData = image.pngData()
                if self.testigoData != nil {
                    let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(self.testigoData! as NSData, path)
                    (self.row as? FirmaFadRow)?.cell.pathImage = path
                }
                
                DispatchQueue.main.async {
                    if self.captureSession.canAddOutput(self.movieOutput) { self.captureSession.addOutput(self.movieOutput) }
                    self.successMessageDetectFace()
                    self.startRecording()
                }
                
                if self.atributos?.tipovalidacion ?? "" == "testigo" {
                    DispatchQueue.main.async {
                        self.videoViewCapture.isHidden = true
                    }
                }
            }
                
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
            } catch let reqErr {
                print("Failed to perform request:", reqErr)
            }
        }
        
    }
    
    func compressVideo(inputURL: URL,
                       outputURL: URL,
                       handler:@escaping (_ exportSession: AVAssetExportSession?) -> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset,
                                                       presetName: AVAssetExportPresetMediumQuality) else {
                                                        handler(nil)
                                                        
                                                        return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            handler(exportSession)
        }
    }
    
    func cleanVariablesAndShowLayerToSign() {
        hideElemetsToOnlyShowSign()
        self.isFaceVisible = false
        self.cleanFlag = false
        self.viewButtons.isHidden = true
        self.view.subviews.forEach({
            if $0.isKind(of: UIImageView.self){
                $0.removeFromSuperview()
            }
        })
        signature = nil
        signatureViewController.reset()
        resultSign?.image = nil
        resultSign?.removeFromSuperview()
        setConstraints()
    }
    
    open func hideElemetsToOnlyShowSign() {
        self.videoViewCapture.isHidden = true
        self.signatureViewController.view.isHidden = false
    }
    
}


extension UIView {
    
    var heightConstraint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
    
    var widthConstraint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .width && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
    
}

extension FirmaFadViewController: APIDelegate {
    
    func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
    func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
    func sendStatusCodeMessage(message: String, error: enumErrorType) {}
    func didSendError(message: String, error: enumErrorType) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(850)) {
            let bannerNew = StatusBarNotificationBanner(title: "\(message)", style: .warning)
            bannerNew.show(bannerPosition: .bottom)
        }
    }
    func didSendResponse(message: String, error: enumErrorType) {}
    func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
}

extension FirmaFadViewController {
    
    func optionAttached(_ option: UserTypeAttached<TypeAttached>) {
        switch option {
        case .userSignature(.video):
            recordVideo()
            break
        case .userSignature(.photo):
            casePhoto()
            break
        case .witness(.video):
            break
        case .witness(.photo):
            break
        }
    }
    
    func recordVideo() {
        self.cleanAction()
        //self.limitStopRecord()
        self.successMessageDetectFace()
        //stopTimer()
        self.session?.stopRunning()
    }
    
    func BugTracking() {
        if UserDefaults.standard.string(forKey: Cnstnt.BundlePrf.serial) == "QWEASDZXC"{
            addOptionVideoOrTestigo()
        }
    }
    
    func addOptionVideoOrTestigo() {
        addSwitchToview(self.view)
    }
    
    func addSwitchToview(_ rootView: UIView) {
        
        let switchFlow: UISwitch = {
            let properties = UISwitch()
            properties.translatesAutoresizingMaskIntoConstraints = false
            properties.backgroundColor = .blue
            properties.isOn = false
            properties.onTintColor = .red
            properties.addTarget(self, action: #selector(toggleSwitch), for: .valueChanged)
            return properties
        }()
        
        rootView.addSubview(switchFlow)
        constraintSwitch(switchFlow)
        toggleSwitch(switchFlow)
        
    }
    
    @objc func toggleSwitch(_ switchUI: UISwitch) {
        
        if switchUI.isOn {
            self.view.backgroundColor = .orange
        } else {
            self.view.backgroundColor = .systemPink
        }
        
    }
    
    func constraintSwitch(_ switchUI: UISwitch) {
        NSLayoutConstraint.activate([
            switchUI.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8),
            switchUI.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            switchUI.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.10),
            switchUI.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.20),
        ])
    }
    
    // MARK: test to take screen shoot in swift
    
    private func casePhoto() {
        getPhoto()
        //stopTimer()
    }
    
    open func getPhoto() {
        /*DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }*/
    }
    
    open func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
    
}

extension FirmaFadViewController: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // Flash the screen to signal that the camera took a photo.
        self.previewLayer?.opacity = 0
        UIView.animate(withDuration: 0.25) {
            self.previewLayer?.opacity = 1
        }
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
        }
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let photoData = photoData else {
            print("No photo data resource")
            return
        }
        
        // MARK: temporal paths to save photo
        
        let pathTestPhoto = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_3_\(ConfigurationManager.shared.utilities.guid()).ane"
        let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(photoData as NSData, pathTestPhoto)
        self.genericRow.cell.pathImage = pathTestPhoto
        cleanVariablesAndShowLayerToSign()
        
    }
    
    func generateHash() {
        
        // dataFile
        if let anexoBase64 = self.imageData?.base64EncodedData(){
            self.hashObject.imagebase64 = String(data: anexoBase64, encoding: String.Encoding.utf8) as String? ?? ""
            
            // en el caso de la foto
            self.hashObject.imagevideobase64 = String(data: photoData?.base64EncodedData() ?? Data(), encoding: String.Encoding.utf8) as String? ?? ""
            self.hashObject.videobase64 = ""
            
            self.hashObject.gps = self.gps
            self.anexoTXTObject.localizacion = self.gps
            self.hashObject.tiempo = self.time
            self.anexoTXTObject.tiempo = self.time
            self.hashObject.acuerdofirma = self.acuerdoFirma
            self.anexoTXTObject.acuerdofirma = self.acuerdoFirma
            self.hashObject.personafirma = self.personaFirma
            self.anexoTXTObject.personafirma = self.personaFirma
            self.anexoTXTObject.dispositivo = self.hashObject.deviceDesc
            self.genericRow.cell.elemento.validacion.georeferencia = self.gps
            self.genericRow.cell.elemento.validacion.fecha = self.time
            self.genericRow.cell.elemento.validacion.acuerdofirma = self.acuerdoFirma
            self.genericRow.cell.elemento.validacion.personafirma = self.personaFirma
            self.genericRow.cell.elemento.validacion.dispositivo = self.hashObject.deviceDesc
            
            self.hashJson = self.hashObject.toJsonString()
            self.hashCrypt = self.hashJson.sha512()
            self.genericRow.cell.elemento.validacion.hashFad = hashCrypt
            self.anexoTXTObject.hashCrypt = self.hashCrypt
            self.genericRow.cell.atributos.hashCrypt = self.hashCrypt
            self.atributos?.hashCrypt = self.hashCrypt
            //self.serviceTimestampFAD()
        }
        
    }
    
}
