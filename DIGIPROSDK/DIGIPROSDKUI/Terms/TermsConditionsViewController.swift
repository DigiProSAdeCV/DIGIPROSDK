import Foundation

import CoreLocation

public protocol TermsConditionsViewControllerDelegate {
    func didTapAccept()
}

public class TermsConditionsViewController: UIViewController
{
    var select : Int = 0
    public let locationManager = CLLocationManager()
    fileprivate var completion: (() -> ())? = nil
    fileprivate static var animationDuration = 0.3
    public var delegate: TermsConditionsViewControllerDelegate!
    @IBOutlet var lblTitleView: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var btnCheckTerms: DLRadioButton!
    @IBOutlet weak var btnCerrar: UIButton!
    @IBAction func actionClose(_ sender: UIButton)
    {
        //validar
        if self.btnCheckTerms.isSelected && UserDefaults.standard.bool(forKey: "termsCond")
        {
            self.completion?()
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        } else
        {
            self.completion?()
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            self.delegate.didTapAccept()
            //self.checkLocationPermission()
        }
    }
    
    @objc @IBAction public func selectedButton(radioButton : DLRadioButton) {
        if radioButton.isSelected && self.select == 0
        {   self.select = 1
            //self.checkLocationPermission()
             self.btnCerrar.isEnabled = true
        } else
        {
            self.select = 0
            radioButton.isSelected = false
            UserDefaults.standard.set("NO", forKey: "termsCond")
            self.btnCerrar.isEnabled = false
        }
    }
    
    public init() {
        super.init(nibName: "UoSoZWMUbiqrjRp", bundle: Cnstnt.Path.framework)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification)
    {   self.checkLocationPermission()  }
    @objc func applicationDidEnterBackground(notification: NSNotification)
    {   self.checkLocationPermission()  }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.modelName.contains("iPad")
        {
            self.viewDidAppear(true)
        }
    }
        
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.lblTitleView.text = "trms_lbl_titleView".langlocalized()
        btnCheckTerms.isMultipleSelectionEnabled = false
        btnCheckTerms.setTitle("trms_lbl_title".langlocalized(), for: []);
        btnCheckTerms.iconColor = UIColor.black;
        btnCheckTerms.indicatorColor = UIColor.black
        btnCheckTerms.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left;
        btnCheckTerms.addTarget(self, action: #selector(self.selectedButton), for: UIControl.Event.touchUpInside);
        self.lblTerms.text = ""
        let currentLanguage = NSLocale.current.identifier
        if currentLanguage.contains("es"){
            self.lblTerms.text = self.readTerms("TermsCondit")
        }else if currentLanguage.contains("en"){
            self.lblTerms.text = self.readTerms("TermsCondit-en")
        }else{
            self.lblTerms.text = self.readTerms("TermsCondit")
        }
        self.lblTerms.textAlignment = self.lblTerms.setAlignment("justify")
        self.btnCerrar.isEnabled = false
        self.btnCerrar.setTitle("alrt_continue".langlocalized(), for: [])
    }
    
    public func readTerms(_ file: String) -> String
    {
       var string = ""
        if let filepath = Cnstnt.Path.framework?.path(forResource: file, ofType: "txt") {
            do {
                string = try String(contentsOfFile: filepath)
                return string
            } catch {
                return "apimng_log_nofile".langlocalized()
            }
        } else {
            return "apimng_log_nofile".langlocalized()
        }
    }
}


extension TermsConditionsViewController {
    
    /// Check if the user has actually the location permission
    public func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .restricted, .denied:
                self.openSettingApp(message: "nvapla_permissions_loc".langlocalized()); break;
            case .authorizedAlways, .authorizedWhenInUse:
                if !UserDefaults.standard.bool(forKey: "termsCond"){
                    UserDefaults.standard.set("YES", forKey: "termsCond")
                }
                self.btnCerrar.isEnabled = true
                break;
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.checkLocationPermission()
                }
            @unknown default: break
            }
        }else {
            self.locationManager.delegate = self as? CLLocationManagerDelegate
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    /// Pop up to alert the user to enable the location permission
    ///
    /// - Parameter message: The message to show in the alert
    public func openSettingApp(message: String) {
        var alertController = UIAlertController()
        alertController = UIAlertController (title: nil, message:message , preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: NSLocalizedString("Ajustes", comment: ""), style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString)else{ return }
            if UIApplication.shared.canOpenURL(settingsUrl) { UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil) }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "alrt_cancel".langlocalized(), style: .default, handler: { action in
            self.checkLocationPermission()
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
