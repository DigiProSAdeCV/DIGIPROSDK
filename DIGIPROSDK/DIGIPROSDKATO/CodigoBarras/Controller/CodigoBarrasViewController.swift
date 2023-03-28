import Foundation
import NotificationCenter
import AVFoundation

import Eureka

class CodigoBarrasViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, TypedRowControllerType{
    
    public var row: RowOf<String>!
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    
    // Images, Inputs, Refreshers
    @IBOutlet weak var imageView :UIImageView!
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var imgCodeBorde: UIImageView!

    
    var session = AVCaptureSession()
    var reset: Bool = false
    var flag: String = ""
    
    var atributos: Atributos_codigobarras?
    var atributosQR: Atributos_codigoqr?
    var flagCode: Bool = false
    var textValidation : String = ""
    
    fileprivate var timer:Timer!
    
    deinit{
        atributos = nil
        atributosQR = nil
    }
    
    @IBOutlet weak var btnCerrar: UIButton!
    @IBAction func cerrarAction(_ sender: Any) {
        self.flagCode = true
        session.stopRunning()
        reset = true
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        onDismissCallback?(self)
    }
    
    @IBAction func reiniciarAction(_ sender: Any) {
        self.flagCode = false
        if session.isRunning{
            session.stopRunning()
        }
        imageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        initOCR()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initOCR()
        if flag == "codigoBarra"{
            self.lblTitulo.text = "Captura de código de barras"
        }else{
            self.lblTitulo.text = "Captura de código de QR"
        }
        
        self.lblTitulo.font = UIFont(name: ConfigurationManager.shared.fontLatoBlod, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        self.btnCerrar.backgroundColor = UIColor.red
        self.btnCerrar.layer.cornerRadius = self.btnCerrar.frame.height / 2
        self.btnCerrar.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        self.imgCodeBorde.tintColor = .white
        if #available(iOS 13.0, *) {
            self.imgCodeBorde.image = UIImage(named: "camera_b", in:  Cnstnt.Path.framework, with: nil)
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        UIView.setAnimationsEnabled(true)
        forcelandscapeRight()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(forcelandscapeRight), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if reset{
            reset = false
            reiniciarAction(Any.self)
        }
    }
    
    
    
 
     
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return .landscapeRight
//    }

        
    override var shouldAutorotate: Bool {
        return true
    }
    
    @objc func forcelandscapeRight() {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    func initOCR(){
        self.startLiveVideo()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) { }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let scannedValue = readableObject.stringValue else {
                return
        }
        
        self.textValidation = scannedValue
        if self.session.isRunning{
            self.session.stopRunning()
            self.flagCode = true
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
            onDismissCallback?(self)
            reset = true
        }

    }
    
    private func startLiveVideo() {
        
        do
        {
            session = AVCaptureSession()
            guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
            
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            let metaDataOutput = AVCaptureMetadataOutput()
            
            // Add device input
            if session.canAddInput(deviceInput) && session.canAddOutput(metaDataOutput)
            {
                session.addInput(deviceInput)
                session.addOutput(metaDataOutput)
                
                metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metaDataOutput.metadataObjectTypes = [.qr, .code128, .code39, .code39Mod43, .code93, .ean13, .ean8, .interleaved2of5, .itf14, .pdf417, .upce ]
                
            }
        }
        catch let e{ print(e) }
       
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        imageLayer.videoGravity = .resizeAspectFill
        imageLayer.connection?.videoOrientation = .portrait
        imageView.layer.addSublayer(imageLayer)
        self.flagCode = true
        session.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
