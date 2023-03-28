import UIKit


public class FiveViewController: UIViewController, UIApplicationDelegate {
    
    @IBOutlet private weak var imageOne: UIImageView!
    @IBOutlet private weak var imageTwo: UIImageView!
    @IBOutlet private weak var imageThree: UIImageView!
    @IBOutlet private weak var imageFour: UIImageView!
    @IBOutlet private weak var imageFive: UIImageView!
    @IBOutlet private weak var imageSix: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var buttonNext: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var labelCamara: UILabel!
    @IBOutlet weak var labelMic: UILabel!
    @IBOutlet weak var labelLoc: UILabel!
    @IBOutlet weak var labelGal: UILabel!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var micImage: UIImageView!
    @IBOutlet weak var locImage: UIImageView!
    @IBOutlet weak var galImage: UIImageView!
    @IBOutlet weak var lineViewOne: UIView!
    @IBOutlet weak var lineViewTwo: UIView!
    @IBOutlet weak var lineViewThree: UIView!
    @IBOutlet weak var lineViewFour: UIView!
    @IBOutlet weak var lineViewFive: UIView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.hero.isEnabled = true
        
        self.imageFive.hero.id = "circleFive"
        self.imageSix.hero.id = "circleSix"
        self.titleLabel.hero.id = "circleFive"
        self.infoLabel.hero.id = "circleFive"
        self.buttonNext.hero.id = "buttonNext"
        self.backgroundImage.hero.id = "buttonNext"
        self.labelCamara.hero.id = "circleFive"
        self.labelMic.hero.id = "circleFive"
        self.labelLoc.hero.id = "circleFive"
        self.labelGal.hero.id = "circleFive"
        self.cameraImage.hero.id = "circleFive"
        self.micImage.hero.id = "circleFive"
        self.locImage.hero.id = "circleFive"
        self.galImage.hero.id = "circleFive"
        self.lineViewOne.hero.id = "buttonNext"
        self.lineViewTwo.hero.id = "buttonNext"
        self.lineViewThree.hero.id = "buttonNext"
        self.lineViewFour.hero.id = "buttonNext"
        self.lineViewFive.hero.id = "buttonNext"
        
        self.titleLabel.text = "onbfve_lbl_title".langlocalized()
        self.infoLabel.text = "onbfve_lbl_info".langlocalized()
        self.labelCamara.text = "onbfve_lbl_camera".langlocalized()
        self.labelMic.text = "onbfve_lbl_mic".langlocalized()
        self.labelLoc.text = "onbfve_lbl_loc".langlocalized()
        self.labelGal.text = "onbfve_lbl_gal".langlocalized()
        self.buttonNext.setTitle("onbfst_btn_next".langlocalized(), for: .normal)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        self.buttonNext.layer.cornerRadius = 5.0
        
        self.backgroundImage.image = UIImage (named: "permisos", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.cameraImage.image = UIImage (named: "ic_camera_tutorial", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.micImage.image = UIImage (named: "ic_microphone_tutorial", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.locImage.image = UIImage (named: "ic_location_tutorial", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.galImage.image = UIImage (named: "ic_gallery_tutorial", in: Cnstnt.Path.framework, compatibleWith: nil)
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
            imageFive.tintColor = Cnstnt.Color.green
            imageSix.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageSix.tintColor = UIColor.lightGray
        }
    }

    @IBAction func nextAction(_ sender: UIButton) {
        let destination = SixViewController.init(nibName: "CQXxUHbmIUddHPq", bundle: Cnstnt.Path.framework)
        destination.modalPresentationStyle = .fullScreen
        self.present(destination, animated: true, completion: nil)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer){
        if (sender.direction == .left){
            let destination = SixViewController.init(nibName: "CQXxUHbmIUddHPq", bundle: Cnstnt.Path.framework)
            destination.modalPresentationStyle = .fullScreen
            self.present(destination, animated: true, completion: nil)
        }
        
        if (sender.direction == .right){
            self.dismiss(animated: true, completion: nil)
            
            // show the view from the left side
        }
    }
    

}
