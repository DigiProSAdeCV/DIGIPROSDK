import Foundation
import UIKit
import CoreLocation

import Eureka

class FirmaViewController: UIViewController, SignatureDrawingViewControllerDelegate, TypedRowControllerType, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var isExpanded: Bool = false
    
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
    
    
    /// The row that pushed or presented this controller
    public var row: RowOf<String>!
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    public var atributos: Atributos_firma?
    public var hashObject: Atributos_firma_hash = Atributos_firma_hash()
    public var hashJson: String = ""
    public var hashCrypt: String = ""
    // MARK: UIViewController+
    
    public var signature: UIImage?
    public var signatureLabel: String?
    public var nombreCompleto = ""
    public var path = ""
    public var guid = ConfigurationManager.shared.utilities.guid()
    var genericRow: FirmaRow! {return row as? FirmaRow}
    let locationManager = CLLocationManager()
    
    // Terms & Conditions
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var signPersona: UILabel!
    @IBOutlet weak var signatureTextView: UITextView!
    @IBOutlet weak var agreedBtn: UIButton!
    
    @IBOutlet weak var viewButtons: UIView!
    
    @IBOutlet weak var btnOkCheck: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnCerrar: UIButton!
    @IBOutlet weak var btnPreview: UIButton!
    
    private var willClean: Bool = false
        
    deinit{
        atributos = nil
        signature = nil
        signatureLabel = nil
    }
    
    @IBAction func agreedAction(_ sender: Any) {
        
        termsView.isHidden = true
        if row.value == nil{
            cleanAction()
        }
        
    }
    
    @IBAction func cerrarAction(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        onDismissCallback?(self)
    }
    
    @IBAction func removerAction(_ sender: Any) {
        signature = nil
        signatureViewController.reset()
    }
    
    @IBAction func borrarAction(_ sender: Any) {
        willClean = true
        self.view.subviews.forEach({
            if $0.isKind(of: UIImageView.self){
                $0.removeFromSuperview()
            }
        })
        signature = nil
        signatureViewController.reset()
        // setConstraints()
        
        //does it need to configure them again?
        //updateConstraintsButton()
        configureTermAndView()
        setConstraintsSignatureView()
    }
    
    
    @IBAction func previewAction(_ sender: UIButton) {
        
    }
    
    func cleanAction() {
        self.view.subviews.forEach({
            if $0.isKind(of: UIImageView.self){
                $0.removeFromSuperview()
            }
        })
        signature = nil
        signatureViewController.reset()
        //setConstraints()
        //updateConstraintsButton()
        configureTermAndView()
        setConstraintsSignatureView()
    }
    
    func setConstraints(){
        self.view.addSubview(signatureViewController.view)
        self.view.bringSubviewToFront(signatureViewController.view)
        signatureViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        signatureViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        //signatureViewController.view.topAnchor.constraint(equalTo: btnCerrar.bottomAnchor, constant: 5.0).isActive = true
        signatureViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        signatureViewController.view.bottomAnchor.constraint(equalTo: viewButtons.topAnchor, constant: -5.0).isActive = true
        
    }
    
    @IBAction func GuardarAction(_ sender: Any?) {
        if signature != nil {
            signatureViewController.reset()
            path = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
            let _ = ConfigurationManager.shared.utilities.saveImageToFolder(signature!, path)
            
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
            onDismissCallback?(self)
        }
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        showButtons()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        signature = signatureViewController.fullSignatureImage
        
        _ =  UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)!
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:sss"
        let dateInfo = formatter.string(from: date)
        self.genericRow.cell.elemento.validacion.fecha = dateInfo
        let device = Device()
        let deviceInfo = "\(device.description) \(device.name ?? "") \(device.systemVersion ?? "") | \(dateInfo)"
        
        self.genericRow.cell.elemento.validacion.fecha = dateInfo
        self.genericRow.cell.elemento.validacion.acuerdofirma = atributos?.acuerdofirma ?? ""
        self.genericRow.cell.elemento.validacion.personafirma = signPersona.text ?? ""
        self.genericRow.cell.elemento.validacion.dispositivo = deviceInfo
        
        _ = genericRow.cell.formDelegate!.getValueFromComponent(genericRow.cell.atributos.personafirma)
        
        _ = ConfigurationManager.shared.deviceToken

        let location = "\(locValue.latitude), \(locValue.longitude)"
        self.genericRow.cell.elemento.validacion.georeferencia = location

        _ = signature?.size.width ?? 0.0 - 10.0
        
        _ = signatureViewController.view.frame.size.height

        signatureViewController.view.removeFromSuperview()
        
        if let signature = self.signature {
            //if signature.size.width > 1600 {
                //Add elements to signature:
            let textoInformacion: String = "\(dateInfo) \n \(location) \n \(device.description)"
            
            let imagenConTexto = self.textToImage(drawText: textoInformacion, inImage: signature, atPoint: CGPoint(x: 20, y: signature.size.height - 50))
                
                let newWidth = imagenConTexto.size.width
                let newHeight = imagenConTexto.size.height
                let newImage = imagenConTexto.resizeVI(size: CGSize(width: newWidth, height: newHeight))
                self.signature = newImage
            //}
        } else {
            self.signature = nil
        }
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        self.GuardarAction((Any).self)
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Getting values
        let nn = genericRow.cell.formDelegate!.getValueFromComponent(genericRow.cell.atributos.personafirma)
        signPersona.text = nn
        setConstraintsSignatureView()
        updateConstraintNameSig()
        updateConstraintsButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.termsView.layer.cornerRadius = 50
        self.agreedBtn.backgroundColor = Cnstnt.Color.green
        self.agreedBtn.setTitleColor(.white, for: .normal)
        self.agreedBtn.setTitle("Acepto", for: .normal)
        self.agreedBtn.layer.cornerRadius = self.agreedBtn.frame.height/2
        
        self.lblTerms.text = "Términos y Condiciones"
        self.lblTerms.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 20)
        
        self.signPersona.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 17)
        self.signatureTextView.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 16)
        
        //#Btn Fondo/Redondo
        self.btnCerrar.backgroundColor = UIColor.red
        //self.btnCerrar.layer.cornerRadius = self.btnCerrar.frame.height / 2
        self.btnCerrar.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        self.btnOkCheck.setImage(UIImage(named: "check_full", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        btnRedo.backgroundColor = UIColor.systemYellow
        //btnRedo.layer.cornerRadius = btnRedo.frame.height / 2
        btnRedo.setImage(UIImage(named: "ic_redo", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        signatureViewController.delegate = self
        self.signatureViewController.view.layer.borderWidth = 1
        self.signatureViewController.view.backgroundColor = UIColor(hexFromString: "#cccccc", alpha: 0.4)
        self.signatureViewController.view.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            if self.signatureLabel != nil && self.signatureLabel != ""{
                self.signatureTextView.text = self.signatureLabel
                self.signatureTextView.isHidden = false
            }else{
                self.signatureTextView.text = ""
                self.signatureTextView.isHidden = true
            }
        }
        
        locationManager.delegate = self
   
        updateConstraintsButton()
        configureTermAndView()
        setConstraintsSignatureView()
        
    }
    
    func updateConstraintNameSig() {
        
        self.view.addSubview(signPersona)
        self.view.bringSubviewToFront(signPersona)
        
        signPersona.removeConstraints(signPersona.constraints)
        signPersona.isHidden = false
        signPersona.textAlignment = .center
        signPersona.textColor = UIColor.black
        signPersona.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            signPersona.topAnchor.constraint(equalTo: signatureViewController.view.bottomAnchor, constant: 8),
            signPersona.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            signPersona.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.080),
            signPersona.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.50)
        ])
        
    }
    
    func configureTermAndView() {
        
        self.termsView.removeConstraints(self.termsView.constraints)
        self.termsView.translatesAutoresizingMaskIntoConstraints = true
        self.termsView.isHidden = true
        
        modifyConstraintTermAndConditionView(newTermAndView)
        addTextTermAndConditionTextView()
        //closeButtonUpdate()
        addIconExpand(newTermAndView)
        
    }
    
   
    private func addTextTermAndConditionTextView() {
        
        self.termsView.removeConstraints(self.termsView.constraints)
        self.termsView.translatesAutoresizingMaskIntoConstraints = true
        self.termsView.isHidden = true
        
           self.newTermAndView.addSubview(termAndConditionsText)
           self.termAndConditionsText.text = atributos?.acuerdofirma ?? ""
           
           NSLayoutConstraint.activate([
               termAndConditionsText.topAnchor.constraint(equalTo: self.newTermAndView.topAnchor, constant: 8),
               termAndConditionsText.leadingAnchor.constraint(equalTo: self.newTermAndView.leadingAnchor, constant: 8),
               termAndConditionsText.trailingAnchor.constraint(equalTo: self.newTermAndView.trailingAnchor, constant: 0),
               termAndConditionsText.bottomAnchor.constraint(equalTo: self.newTermAndView.bottomAnchor, constant: -8)
           ])
       }
    
//    private func closeButtonUpdate() {
//        self.viewButtons.addSubview(self.btnCerrar)
//        self.btnCerrar.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            self.btnCerrar.topAnchor.constraint(equalTo: self.viewButtons.topAnchor, constant: 8),
//            self.btnCerrar.trailingAnchor.constraint(equalTo: self.viewButtons.trailingAnchor, constant: -24),
//            self.btnCerrar.heightAnchor.constraint(equalToConstant: 50),
//            self.btnCerrar.widthAnchor.constraint(equalToConstant: 50),
//        ])
//
//    }
    
    private func modifyConstraintTermAndConditionView(_ vista: UIView) {
        self.view.addSubview(vista)
        NSLayoutConstraint.activate([
            vista.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
            vista.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.90),
            vista.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 16),
            vista.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -16),
            vista.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.20),
        ])
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
    
    func updateConstraintsButton() {
        
        self.btnOkCheck.removeConstraints(self.btnOkCheck.constraints)
        self.btnRedo.removeConstraints(self.btnRedo.constraints)
        self.btnCerrar.removeConstraints(self.btnCerrar.constraints)
        
        self.viewButtons.removeConstraints(self.viewButtons.constraints)
        self.viewButtons.translatesAutoresizingMaskIntoConstraints = false
        self.viewButtons.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80).isActive = true
        self.viewButtons.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
        self.viewButtons.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.10).isActive = true
        self.viewButtons.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        self.viewButtons.backgroundColor = UIColor.clear
        self.viewButtons.reloadInputViews()
        self.viewButtons.needsUpdateConstraints()
        self.viewButtons.layoutIfNeeded()
        
        hideButtons()
        
        self.btnOkCheck.translatesAutoresizingMaskIntoConstraints = false
        self.btnOkCheck.trailingAnchor.constraint(equalTo: self.viewButtons.trailingAnchor,constant: -1).isActive = true
        self.btnOkCheck.heightAnchor.constraint(equalTo: self.view.heightAnchor , multiplier: 0.08).isActive = true
        self.btnOkCheck.widthAnchor.constraint(equalTo: self.view.heightAnchor , multiplier: 0.08).isActive = true
        
        self.btnCerrar.translatesAutoresizingMaskIntoConstraints = false
        self.btnCerrar.leadingAnchor.constraint(equalTo: self.viewButtons.leadingAnchor, constant: 1).isActive = true
        self.btnCerrar.heightAnchor.constraint(equalTo: self.view.heightAnchor , multiplier: 0.08).isActive = true
        self.btnCerrar.widthAnchor.constraint(equalTo: self.view.heightAnchor , multiplier: 0.08).isActive = true
        
        self.btnRedo.translatesAutoresizingMaskIntoConstraints = false
        self.btnRedo.leadingAnchor.constraint(equalTo: self.btnCerrar.trailingAnchor, constant: 12).isActive = true
        self.btnRedo.heightAnchor.constraint(equalTo: self.view.heightAnchor , multiplier: 0.08).isActive = true
        self.btnRedo.widthAnchor.constraint(equalTo: self.view.heightAnchor , multiplier: 0.08).isActive = true
        
        
        self.btnCerrar.layer.cornerRadius = self.btnCerrar.frame.height / 2
        self.btnRedo.layer.cornerRadius = self.btnRedo.frame.height / 2
        
        self.viewButtons.layoutIfNeeded()
    }
    
    func setConstraintsSignatureView(){
           self.view.addSubview(signatureViewController.view)
           self.view.bringSubviewToFront(signatureViewController.view)
           signatureViewController.view.translatesAutoresizingMaskIntoConstraints = false
           signatureViewController.view.topAnchor.constraint(equalTo: newTermAndView.bottomAnchor, constant: 16.0).isActive = true
           signatureViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
           signatureViewController.view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.60).isActive = true
           signatureViewController.view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.45).isActive = true
       }
    
    func mergeSignAndEntitlements(_ inImage: UIImage) -> UIImage{
        
        let size = CGSize(width: signatureViewController.view.frame.width, height: signatureViewController.view.frame.height + 250)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        inImage.draw(at: CGPoint.zero)
        let rectangle = CGRect(x: 0, y: signatureViewController.view.frame.height, width: signatureViewController.view.frame.width, height: 250)
        context!.setFillColor(UIColor.white.cgColor)
        context!.addRect(rectangle)
        context!.drawPath(using: .fill)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.black
        let textFont =  UIFont(name: ConfigurationManager.shared.fontApp, size: 12)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    private func hideButtons() {
        self.btnOkCheck.isHidden = true
        self.btnRedo.isHidden = true
    }
    
    private func showButtons() {
        self.btnOkCheck.isHidden = false
        self.btnRedo.isHidden = false
    }
    
    // MARK: SignatureDrawingViewControllerDelegate
    func signatureDrawingViewControllerIsEmptyDidChange(controller: SignatureDrawingViewController, isEmpty: Bool) {
        if willClean {
            hideButtons()
            willClean = false
        } else {
            showButtons()
        }
    }
    
    // MARK: Private
    private let signatureViewController = SignatureDrawingViewController()
    
    // MARK: Transition
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
}
