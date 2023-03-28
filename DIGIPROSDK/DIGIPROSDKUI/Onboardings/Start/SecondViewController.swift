import UIKit
import UserNotifications


public class SecondViewController: UIViewController, UIApplicationDelegate, UNUserNotificationCenterDelegate  {
    
    @IBOutlet public weak var imageOne: UIImageView!
    @IBOutlet public weak var imageTwo: UIImageView!
    @IBOutlet public weak var imageThree: UIImageView!
    @IBOutlet public weak var imageFour: UIImageView!
    @IBOutlet public weak var imageFive: UIImageView!
    @IBOutlet public weak var imageSix: UIImageView!
    @IBOutlet public weak var switchControl: UISwitch!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var infoLabel: UILabel!
    @IBOutlet public weak var nextButton: UIButton!
    @IBOutlet public weak var labelActivate: UILabel!
    @IBOutlet public weak var backgroundImage: UIImageView!
    @IBOutlet public weak var iconImage: UIImageView!
    @IBOutlet public weak var notificationLabel: UILabel!
    @IBOutlet public weak var lineViewOne: UIView!
    @IBOutlet public weak var lineViewTwo: UIView!
    
    public var flag: Bool = false
    public var notification = false
    var timer = Timer()
    public static let shared: SecondViewController = SecondViewController()

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hero.isEnabled = true
       
        self.imageTwo.hero.id = "circleTwo"
        self.imageThree.hero.id = "circleThree"
        self.titleLabel.hero.id = "circleTwo"
        self.infoLabel.hero.id = "circleTwo"
        self.nextButton.hero.id = "buttonNext"
        self.switchControl.hero.id = "infoLabel"
        self.labelActivate.hero.id = "infoLabel"
        self.notificationLabel.hero.id = "circleTwo"
        self.lineViewOne.hero.id = "infoLabel"
        self.lineViewTwo.hero.id = "circleTwo"
        self.backgroundImage.hero.id = "infoLabel"
        self.iconImage.hero.id = "infoLabel"
        
        self.titleLabel.text = "onbscnd_lbl_title".langlocalized()
        self.infoLabel.text = "onbscnd_lbl_info".langlocalized()
        self.notificationLabel.text = "onbscnd_lbl_notification".langlocalized()
        self.labelActivate.text = "onbscnd_lbl_activate".langlocalized()
        self.nextButton.setTitle("onbfst_btn_next".langlocalized(), for: .normal)
        
        //self.switchControl.transform = CGAffineTransform(scaleX: -1.59, y: 1.15)
        self.nextButton.layer.cornerRadius = 5.0
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        self.iconImage.image = UIImage(named: "ic_notifications_tutorial", in: Cnstnt.Path.framework, compatibleWith: nil )
        self.backgroundImage.image = UIImage(named: "notificaciones_push", in: Cnstnt.Path.framework, compatibleWith: nil )
        if let auxImage = UIImage (named: "gray_silhouette", in: Cnstnt.Path.framework, compatibleWith: nil)
        {
            imageOne.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageOne.tintColor = Cnstnt.Color.blue
            imageTwo.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageTwo.tintColor = Cnstnt.Color.green
            imageThree.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageThree.tintColor = UIColor.lightGray
            imageFour.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageFour.tintColor = UIColor.lightGray
            imageFive.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageFive.tintColor = UIColor.lightGray
            imageSix.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageSix.tintColor = UIColor.lightGray
        }
        // Do any additional setup after loading the view.
        self.registerForPushNotifications()
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
   
    @objc func update() {
        // Something cool
        if ConfigurationManager.shared.isNotification{
            self.registerForPushNotifications()
        }
    }

    @IBAction func netAction(_ sender: UIButton) {
        self.notification = false
        ConfigurationManager.shared.isNotification = false
        self.timer.invalidate()
        let destination = ThirdViewController.init(nibName: "CWqfeJOkMTMfFCr", bundle: Cnstnt.Path.framework)
        destination.modalPresentationStyle = .fullScreen
        self.present(destination, animated: true, completion: nil)
    }
    
    
    public func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            
            if granted{
                DispatchQueue.main.async {
                    self.labelActivate.text! = "onbscnd_lbl_desactivate".langlocalized()
                    self.switchControl.isOn = true
                     self.flag = self.switchControl.isOn
                    
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }else{
                DispatchQueue.main.async {
                    self.labelActivate.text! = "onbscnd_lbl_activate".langlocalized()
                    self.switchControl.isOn = false
                     self.flag = self.switchControl.isOn
                }
            }
            // 1. Check if permission granted
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
           
        }
    }
    
    
     @objc public func registerNotification(sender: NSNotification) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            
            if granted{
                DispatchQueue.main.async {
                    self.labelActivate.text = "onbscnd_lbl_desactivate".langlocalized()
                    self.switchControl.isOn = true
                    self.flag = self.switchControl.isOn
                    
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }else{
                DispatchQueue.main.async {
                    self.labelActivate.text = "onbscnd_lbl_activate".langlocalized()
                    self.switchControl.isOn = false
                    self.flag = self.switchControl.isOn
                }
            }
            // 1. Check if permission granted
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            
        }
    }
    
    
    
    @IBAction func actionSwitch(_ sender: UISwitch) {
        if self.switchControl.isOn{
            self.labelActivate.text! = "onbscnd_lbl_desactivate".langlocalized()
            self.alertNotification(message: "onbscnd_lbl_activate_des".langlocalized())
        }else{
            self.labelActivate.text! = "onbscnd_lbl_activate".langlocalized()
            self.alertNotification(message: "onbscnd_lbl_desactivate_des".langlocalized())
        }
    }
    
    func alertNotification(message: String){
        let alertController = UIAlertController (title: "alrt_dgp".langlocalized(), message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "alrt_settings".langlocalized(), style: .default) { (_) -> Void in
            self.notification = true
            ConfigurationManager.shared.isNotification = true
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                   
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "alrt_cancel".langlocalized(), style: .cancel) { (_) -> Void in
            self.switchControl.isOn = self.flag
            if self.flag{
                self.labelActivate.text! = "onbscnd_lbl_desactivate".langlocalized()
            }else{
                self.labelActivate.text! = "onbscnd_lbl_activate".langlocalized()
            }
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer){
        if (sender.direction == .left){
            self.notification = false
            ConfigurationManager.shared.isNotification = false
            self.timer.invalidate()
            let destination = ThirdViewController.init(nibName: "CWqfeJOkMTMfFCr", bundle: Cnstnt.Path.framework)
            destination.modalPresentationStyle = .fullScreen
            self.present(destination, animated: true, completion: nil)
        }
        
        if (sender.direction == .right){
            self.notification = false
            self.timer.invalidate()
            ConfigurationManager.shared.isNotification = false
            self.dismiss(animated: true, completion: nil)
            
            // show the view from the left side
        }
    }

}
