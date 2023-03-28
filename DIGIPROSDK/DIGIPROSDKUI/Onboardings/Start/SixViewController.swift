import UIKit
import LocalAuthentication


public class SixViewController: UIViewController, UIApplicationDelegate {
    
    @IBOutlet private weak var imageOne: UIImageView!
    @IBOutlet private weak var imageTwo: UIImageView!
    @IBOutlet private weak var imageThree: UIImageView!
    @IBOutlet private weak var imageFour: UIImageView!
    @IBOutlet private weak var imageFive: UIImageView!
    @IBOutlet private weak var imageSix: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var buttonNext: UIButton!
    @IBOutlet private weak var labelActivate: UILabel!
    @IBOutlet private weak var switchControl: UISwitch!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var touchLabel: UILabel!
    @IBOutlet weak var touchImage: UIImageView!
    @IBOutlet weak var lineViewOne: UIView!
    @IBOutlet weak var lineViewTwo: UIView!
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hero.isEnabled = true
        
        self.imageSix.hero.id = "circleSix"
        self.titleLabel.hero.id = "circleSix"
        self.infoLabel.hero.id = "circleSix"
        self.buttonNext.hero.id = "buttonNext"
        self.backgroundImage.hero.id = "buttonNext"
        self.touchLabel.hero.id = "circleSix"
        self.touchImage.hero.id = "circleSix"
        self.lineViewOne.hero.id = "circleSix"
        self.lineViewTwo.hero.id = "circleSix"
        self.labelActivate.hero.id = "circleSix"

        self.titleLabel.text = "onbsix_lbl_title".langlocalized()
        self.infoLabel.text = "onbsix_lbl_info".langlocalized()
        self.touchLabel.text = "onbsix_lbl_touch".langlocalized()
        self.labelActivate.text = "onbsix_lbl_activate".langlocalized()
        self.buttonNext.setTitle("onbfst_btn_next".langlocalized(), for: .normal)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        self.buttonNext.layer.cornerRadius = 5.0
        
        self.backgroundImage.image = UIImage (named: "touch_id", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.touchImage.image = UIImage (named: "ic_touch_tutorial", in: Cnstnt.Path.framework, compatibleWith: nil)
        if let auxImage = UIImage (named: "gray_silhouette", in: Cnstnt.Path.framework, compatibleWith: nil)
        {
            imageOne.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageOne.tintColor = Cnstnt.Color.blue
            imageTwo.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageTwo.tintColor = Cnstnt.Color.blue
            imageThree.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageThree.tintColor = Cnstnt.Color.blue
            imageFour.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageFour.tintColor = Cnstnt.Color.blue
            imageFive.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageFive.tintColor = Cnstnt.Color.blue
            imageSix.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageSix.tintColor = Cnstnt.Color.green
        }
        
        let touchIDPreference = plist.touchid.rawValue.dataB()
        if touchIDPreference == true{
            self.switchControl.isOn = true
            self.labelActivate.text = "onbscnd_lbl_activate".langlocalized()
        }else{
           self.switchControl.isOn = false
            self.labelActivate.text = "onbscnd_lbl_desactivate".langlocalized()
        }
        
    }

    @IBAction func nextAction(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer){
        if (sender.direction == .left){
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        if (sender.direction == .right){
            self.dismiss(animated: true, completion: nil)
            // show the view from the left side
        }
    }
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "alrt_accept".langlocalized(), style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func touchVerification(){
        let context = LAContext()
        var error: NSError?
        
        // 2
        // check if Touch ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // 3
            let reason = "onbsix_lbl_touchid".langlocalized()
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(succes, error) in
                    // 4
                    if succes {
                        DispatchQueue.main.async {
                            self.switchControl.isOn = true
                            self.labelActivate.text = "onbscnd_lbl_desactivate".langlocalized()
                            self.showAlertController("onbsix_lbl_idCorrect".langlocalized())
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.switchControl.isOn = false
                            self.labelActivate.text = "onbscnd_lbl_activate".langlocalized()
                            self.showAlertController("onbsix_lbl_idIncorrect".langlocalized())
                        }
                    }
                    })
        }
            // 5
        else {
            showAlertController("onbsix_lbl_touchUnavailable".langlocalized())
        }
    }
    
    
    @IBAction func actionFingerPrint(_ sender: UISwitch) {
        
        if self.switchControl.isOn{
            plist.touchid.rawValue.dataSSet(true)
            //self.touchVerification()
            self.showAlertController("onbsix_success".langlocalized())
            self.labelActivate.text = "onbscnd_lbl_desactivate".langlocalized()
        }else{
            plist.touchid.rawValue.dataSSet(false)
            self.showAlertController("onbsix_fail".langlocalized())
            self.labelActivate.text = "onbscnd_lbl_activate".langlocalized()
        }
        
    }
    
    

}
