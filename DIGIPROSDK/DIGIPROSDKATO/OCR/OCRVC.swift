import Foundation
import AVFoundation

import Vision
import VisionKit
import Eureka
#if canImport(MLKit)
import MLKit
#endif
#if canImport(WeScan)
import WeScan
#endif
public class OCRVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, TypedRowControllerType, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    public var row: RowOf<String>!
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    public var serviceId = -1
    public var formDelegate: FormularioDelegate?
    // Services
    // 1 INE/IFE
    // 2 AGUA
    // 3 CFE
    // 4 PAsaporte
    // 5 VISA
    
    // Images, Inputs, Refreshers
    @IBOutlet weak var imageView :UIImageView!
    @IBOutlet weak var frontImage: UIImageView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnChanger: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    
    var isDetectedAnverso: Bool = false
    var isDetectedReverso: Bool = false
    #if canImport(WeScan)
    public var imageINEAnversoObject = WeScanImageObject()
    public var imageINEReversoObject = WeScanImageObject()
    #endif
    var session = AVCaptureSession()
    
    fileprivate var timer:Timer!
    var atributos: Atributos_servicio?
    
    // Utilities and Objects
    let ocrUtility = OCRIneWordBreak()
    let ocrCfeUtility = OCRCfeWordBreak()
    let ocrPasaporteUtility = OCRPasaporteWordBreak()
    public var objectOCRINE: OcrIneObject?
    public var objectOCRPasaporte: OcrPasaporteObject?
    public var objectOCRCfe: OcrCfeObject?
    public var objectOCRVisa: OcrVisaObject?
    
    public var isFromRule: Bool = false
    public var component: String = ""
    
    var isImageDetected = false
    var isReverso = false
    var isLiveCamera = true
    public var validAnchors = [String]()
    public var tableContent = [String]()
    
    // MARK: - Actions
    @IBAction func cerrarAction(_ sender: Any) {
        self.stopActivity()
        
        self.isLiveCamera = false
        self.isReverso = false
        
        if isFromRule{
            self.dismiss(animated: true, completion: nil)
            switch serviceId{
            case 1: self.formDelegate?.setOCRDetails(serviceId, objectOCRINE!, component); break;
            case 4: self.formDelegate?.setOCRDetails(serviceId, objectOCRPasaporte!, component); break;
            default: break;
            }
        }
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        onDismissCallback?(self)
    }
    
    @IBAction func guardarAction(_ sender: Any) {
        self.stopActivity()
        
        self.isLiveCamera = false
        self.isReverso = false
        
        if isFromRule{
            self.dismiss(animated: true, completion: nil)
            switch serviceId{
            case 1: self.formDelegate?.setOCRDetails(serviceId, objectOCRINE!, component); break;
            case 4: self.formDelegate?.setOCRDetails(serviceId, objectOCRPasaporte!, component); break;
            default: break;
            }
        }
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        
        onDismissCallback?(self)
    }
    
    @IBAction func reiniciarAction(_ sender: Any) {
        self.stopActivity()
        
        self.isLiveCamera = false
        self.isReverso = false
        
        frontImage.tag = 0
        backImage.tag = 0
        
        resetting(serviceId)
        settingAnchors(serviceId)
        
        self.isDetectedAnverso = false
        self.isDetectedReverso = false
        #if canImport(WeScan)
        self.imageINEAnversoObject.imageView = nil
        self.imageINEReversoObject.imageView = nil
        #endif
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.isLiveCamera = true
            self.startLiveVideo()
            self.setTimer()
        }
        
    }
    
    func reloadImageCamera(){
        self.stopActivity()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.isLiveCamera = true
            self.startLiveVideo()
            self.setTimer()
        }
    }
    
    @IBAction func btnChangerAction(_ sender: Any) {
        if isReverso{
            frontImage.alpha = CGFloat(1)
            backImage.alpha = CGFloat(0.5)
            isReverso = false
        }else{
            frontImage.alpha = CGFloat(0.5)
            backImage.alpha = CGFloat(1)
            isReverso = true
        }
    }
    
    // INIT - ViewController
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, service nibServiceOrNil: Int?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.serviceId = nibServiceOrNil ?? -1
    }
    
    // MARK: - INIT SERVICE
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Setting service
        //if FirebaseApp.app() == nil{ FirebaseApp.configure() }

        frontImage.alpha = CGFloat(1)
        backImage.alpha = CGFloat(0.5)
        frontImage.tag = 0
        backImage.tag = 0
        
        

        
        session = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.initOCR()
        }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
       
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        detectServiceOCR(serviceId)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
        //#Btn Fondo/Redondo
        btnClose.backgroundColor = UIColor.red
        btnClose.layer.cornerRadius = btnClose.frame.height / 2
        btnClose.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btnRedo.layer.cornerRadius = btnRedo.frame.height / 2
        btnRedo.setImage(UIImage(named: "ic_redo", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btnChanger.setImage(UIImage(named: "ic_changer", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        frontImage.alpha = CGFloat(1)
        backImage.alpha = CGFloat(0.5)
    }
    
    func detectServiceOCR(_ service: Int){
        
        // 1 INE/IFE
        // 2 AGUA
        // 3 CFE
        // 4 Pasaporte
        // 5 VISA
        settingAnchors(service)
        switch service{
        case 1:
            frontImage.image = UIImage(named: "Ine-Anverso-Modificado", in: Cnstnt.Path.framework, compatibleWith: nil)
            backImage.image = UIImage(named: "Ine-Reverso-Modificado", in: Cnstnt.Path.framework, compatibleWith: nil)
            break;
        case 4:
            backImage.isHidden = true
            frontImage.image = UIImage(named: "ic_passport", in: Cnstnt.Path.framework, compatibleWith: nil)
            backImage.image = nil
            break;
        default: break;
        }
    }
    
    func initOCR(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            startLiveVideo()
            setTimer()
        }
    }
    
    func setTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(settingResults), userInfo: nil, repeats: true)
    }
    
    func stopActivity(_ isTimerDisabled: Bool = true){
        if self.session.isRunning{ self.session.stopRunning() }
        if timer != nil, isTimerDisabled { self.timer.invalidate() }
        self.imageView.layer.sublayers = nil
    }
    
    private func startLiveVideo() {
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = CGRect(x: 0, y: 0, width: self.imageView.frame.size.width, height: self.imageView.frame.size.height)
        imageLayer.videoGravity = .resizeAspectFill
        imageView.layer.addSublayer(imageLayer)
        session.startRunning()
    }
    
    // MARK: - ANIMATIONS
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.7, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    #if canImport(MLKit)
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        var arrElementsString = [String]()
        
            let visionImage = VisionImage(buffer: sampleBuffer)
            let orientation = UIUtilities.imageOrientation( fromDevicePosition: .back )
            visionImage.orientation = orientation
        let textRecognizer = TextRecognizer.textRecognizer()

        
        
        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let results = result else { return }
            print(results.text)
            arrElementsString.append(results.text)
            // 1 INE/IFE
            // 2 AGUA
            // 3 CFE
            // 4 Pasaporte
            // 5 VISA
                
            switch self.serviceId {
            case 1:
                // INSTITUTO NACIONAL
                if !(self.objectOCRINE?.detectednombre)!{ self.ocrUtility.containsNombre(arrElementsString, self) }
                if !(self.objectOCRINE?.detecteddomicilio)!{ self.ocrUtility.containsDireccion(arrElementsString, self) }
                if !(self.objectOCRINE?.detectedclaveelector)!{ self.ocrUtility.containsClaveElector(arrElementsString, self) }
                if !(self.objectOCRINE?.detectedcurp)!{ self.ocrUtility.containsCurp(arrElementsString, self) }
                if !(self.objectOCRINE?.detectedseccion)!{ self.ocrUtility.containsSeccion(arrElementsString, self) }
                if !(self.objectOCRINE?.detectedestado)!{ self.ocrUtility.containsEstado(arrElementsString, self) }
                if !(self.objectOCRINE?.detectedvigencia)!{ self.ocrUtility.containsVigencia(arrElementsString, self) }
                if !(self.objectOCRINE?.detectedemision)!{ self.ocrUtility.containsEmision(arrElementsString, self) }
                if !(self.objectOCRINE?.detectedfolio)!{ self.ocrUtility.containsFolio(arrElementsString, self) }
                if !(self.objectOCRINE?.detectedmunicipio)!{ self.ocrUtility.containsMunicipio(arrElementsString, self) }
                if !(self.objectOCRINE?.detectedfecha)!{ self.ocrUtility.containsFecha(arrElementsString, self) }
                // INSTITUTO FEDERAL
                if !(self.objectOCRINE?.detectedsexo)!{ self.ocrUtility.containsSexo(arrElementsString, self) }
                if !(self.objectOCRINE?.detectedlocalidad)!{ self.ocrUtility.containsLocalidad(arrElementsString, self) }
                
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
                let context:CIContext = CIContext.init(options: nil)
                let finalImage = CIImage(cvPixelBuffer: pixelBuffer)
                let cgImage:CGImage = context.createCGImage(finalImage, from: finalImage.extent)!
                let img:UIImage = UIImage.init(cgImage: cgImage)
                let imgNew = img.rotateImage(radians: Float(Double.pi/2))
                let newFinalImage = CIImage(image: imgNew!)
                _ = finalImage.extent.size
                
                #if canImport(WeScan)
                self.imageINEAnversoObject.imageView = self.frontImage
                #endif
                if (self.objectOCRINE?.detectednombre)!{
                    if !self.isDetectedAnverso{
                        #if canImport(WeScan)
                        VisionRectangleDetector.rectangle(forImage: newFinalImage!) { (rectangle) in
                            if rectangle != nil{
                                var quad = rectangle!.toCartesian(withHeight: imgNew!.size.height)
                                quad.reorganize()
                                DispatchQueue.main.async {
                                    self.isDetectedAnverso = true
                                    self.stopActivity()
                                    let _ = ImageScannerController(self.imageINEAnversoObject, imgNew, quad, self)
                                }
                            }
                        }
                        #endif
                    }
                }
                
                if self.isReverso {
                    if !(self.objectOCRINE?.detectedcic)!{ self.ocrUtility.containsCic(arrElementsString, self) }
                    if !(self.objectOCRINE?.detectedocr)!{ self.ocrUtility.containsOcr(arrElementsString, self) }
                    if (self.objectOCRINE?.detectedcic)!{
                        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
                        let context:CIContext = CIContext.init(options: nil)
                        let finalImage = CIImage(cvPixelBuffer: pixelBuffer)
                        let cgImage:CGImage = context.createCGImage(finalImage, from: finalImage.extent)!
                        let img:UIImage = UIImage.init(cgImage: cgImage)
                        let imgNew = img.rotateImage(radians: Float(Double.pi/2))
                        let newFinalImage = CIImage(image: imgNew!)
                        _ = finalImage.extent.size
                        #if canImport(WeScan)
                        self.imageINEReversoObject.imageView = self.backImage
                        #endif
                        if !self.isDetectedReverso{
                            #if canImport(WeScan)
                            VisionRectangleDetector.rectangle(forImage: newFinalImage!) { (rectangle) in
                                if rectangle != nil{
                                    var quad = rectangle!.toCartesian(withHeight: imgNew!.size.height)
                                    quad.reorganize()
                                    DispatchQueue.main.async {
                                        self.isDetectedReverso = true
                                        self.stopActivity()
                                        let _ = ImageScannerController(self.imageINEAnversoObject, imgNew, quad, self)
                                    }
                                }
                            }
                            #endif
                        }
                    }
                }
                break
            case 2:
                
                break
            case 3:
                // CFE
                if !(self.objectOCRCfe?.detectednombre)!{ self.ocrCfeUtility.containsNombreDomicilio(arrElementsString, self) }
                break
            case 4:
                // Pasaporte
                /*detectedtipo
                detectedclavedelpais
                detectedpasaportenumero
                detectedapellidos
                detectednombres
                detectednacionalidad
                detectedobservaciones
                detectedfechanacimiento
                detectedcurp
                detectedsexo
                detectedlugarnacimiento
                detectedfechaexpedicion
                detectedfechacaducidad
                detectedautoridad*/
                
                self.ocrPasaporteUtility.containsCode(arrElementsString, self)

                guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
                let context:CIContext = CIContext.init(options: nil)
                let finalImage = CIImage(cvPixelBuffer: pixelBuffer)
                let cgImage:CGImage = context.createCGImage(finalImage, from: finalImage.extent)!
                let img:UIImage = UIImage.init(cgImage: cgImage)
                let imgNew = img.rotateImage(radians: Float(Double.pi/2))
                let newFinalImage = CIImage(image: imgNew!)
                _ = finalImage.extent.size
                #if canImport(WeScan)
                self.imageINEAnversoObject.imageView = self.frontImage
                #endif
                if (self.objectOCRPasaporte?.detectednombres)!{
                    #if canImport(WeScan)
                    VisionRectangleDetector.rectangle(forImage: newFinalImage!) { (rectangle) in
                        if rectangle != nil{
                            var quad = rectangle!.toCartesian(withHeight: imgNew!.size.height)
                            quad.reorganize()
                            DispatchQueue.main.async {
                                self.isDetectedAnverso = true
                                let _ = ImageScannerController(self.imageINEAnversoObject, imgNew, quad, self)
                            }
                        }
                    }
                    #endif
                }
                
                break
            case 5:
                // VISA
                break
            default:
                break
            }
        }
    }
    #endif
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        reloadImageCamera()
    }
}
#if canImport(WeScan)
extension OCRVC: ImageScannerControllerDelegate {
    
    public func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) { scanner.dismiss(animated: true, completion: nil) }
    
    public func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        scanner.dismiss(animated: true, completion: nil)
        
        switch serviceId{
        case 1:
            if isImageDetected{ self.stopActivity(false); return; }
            
            if self.isDetectedAnverso && !self.isDetectedReverso{ self.imageINEAnversoObject.imageView?.image = results.scannedImage; self.frontImage.tag = 1
                let path = "\(ConfigurationManager.shared.guid)_Anverso_1_\(ConfigurationManager.shared.utilities.guid()).jpg"
                               _ = ConfigurationManager.shared.utilities.saveImageToFolder(results.scannedImage, path)
                               self.objectOCRINE?.ineanverso = path
            }
            
            if self.isDetectedAnverso && self.isDetectedReverso{
                if self.frontImage.tag == 1{ self.imageINEReversoObject.imageView?.image = results.scannedImage
                   let path = "\(ConfigurationManager.shared.guid)_Reverso_1_\(ConfigurationManager.shared.utilities.guid()).jpg"
                    _ = ConfigurationManager.shared.utilities.saveImageToFolder(results.scannedImage, path)
                    self.objectOCRINE?.inereverso = path
                }
                if self.backImage.tag == 1{ self.imageINEAnversoObject.imageView?.image = results.scannedImage
                   
                }
                self.isReverso = false; self.isImageDetected = true
            }
            
            if !self.isDetectedAnverso && self.isDetectedReverso{ self.imageINEReversoObject.imageView?.image = results.scannedImage; self.isReverso = false; self.backImage.tag = 1; }
            
            self.isLiveCamera = true; self.startLiveVideo(); self.setTimer();
            break;
            
        case 4:
            if isImageDetected{ return; }
            
            if self.isDetectedAnverso && !self.isDetectedReverso{ self.imageINEAnversoObject.imageView?.image = results.scannedImage; self.frontImage.tag = 1
                let path = "\(ConfigurationManager.shared.guid)_Anverso_1_\(ConfigurationManager.shared.utilities.guid()).jpg"
                               _ = ConfigurationManager.shared.utilities.saveImageToFolder(results.scannedImage, path)
                               //self.objectOCRINE?.ineanverso = path
                self.isImageDetected = true
            }
            break;
            
        default: break;
        }
        
    }
    
    public func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithObject results: WeScanImageObject) {
        scanner.dismiss(animated: true, completion: nil)
        
        if self.isDetectedAnverso && !self.isDetectedReverso{
            self.imageINEAnversoObject = results
            self.imageINEAnversoObject.imageView?.image = self.imageINEAnversoObject.results?.scannedImage
            self.isLiveCamera = true
            self.startLiveVideo()
            self.setTimer()
        }
        
        if self.isDetectedAnverso && self.isDetectedReverso{
            self.imageINEReversoObject = results
            self.imageINEReversoObject.imageView?.image = self.imageINEReversoObject.results?.scannedImage
            self.isReverso = false
        }
        
    }
    
    public func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
    }
    
}
#endif
