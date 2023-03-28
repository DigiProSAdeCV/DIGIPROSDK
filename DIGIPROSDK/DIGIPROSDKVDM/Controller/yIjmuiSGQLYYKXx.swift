import UIKit

class VeridiumViewController: UIViewController {
    // MARK: UIViewController+
    public var atributos: Atributos_huelladigital?
    @IBOutlet weak var btnCerrar: UIButton!
    @IBOutlet weak var vwInfo: UIView!
    
    @IBOutlet weak var lefHandImage: UIImageView!
    @IBOutlet weak var rightHandImage: UIImageView!
    
    @IBOutlet weak var left_thumb: UIImageView!
    @IBOutlet weak var left_index: UIImageView!
    @IBOutlet weak var left_middle: UIImageView!
    @IBOutlet weak var left_ring: UIImageView!
    @IBOutlet weak var left_little: UIImageView!
    
    @IBOutlet weak var right_thumb: UIImageView!
    @IBOutlet weak var right_index: UIImageView!
    @IBOutlet weak var right_middle: UIImageView!
    @IBOutlet weak var right_ring: UIImageView!
    @IBOutlet weak var right_little: UIImageView!
    
    @IBOutlet weak var oneF: UIImageView!
    @IBOutlet weak var twoF: UIImageView!
    @IBOutlet weak var threeF: UIImageView!
    @IBOutlet weak var fourF: UIImageView!
    @IBOutlet weak var fiveF: UIImageView!
    @IBOutlet weak var sixF: UIImageView!
    
    @IBOutlet weak var sevenF: UIImageView!
    @IBOutlet weak var eightF: UIImageView!
    @IBOutlet weak var nineF: UIImageView!
    @IBOutlet weak var tenF: UIImageView!
    
    @IBOutlet weak var LblResultados: UILabel!
    @IBOutlet weak var LblScore: UILabel!
    
    @IBOutlet weak var leftHandHolder: UIView!
    @IBOutlet weak var rightHandHolder: UIView!
    
    @IBOutlet weak var switchHand: UIButton!
    var isLefty = true
    var isHandLeft = false
    var isHandRight = false
    
    var is2F = false
    var is8F = false
    var is4FI = false
    var is4FD = false
    
    public var signature: UIImage?
    let guid = ConfigurationManager.shared.utilities.guid()
    public var fingersLeft = [(isEnable: false, score: 0, image: "", position: 0),
                       (isEnable: false, score: 0, image: "", position: 0),
                       (isEnable: false, score: 0, image: "", position: 0),
                       (isEnable: false, score: 0, image: "", position: 0),
                       (isEnable: false, score: 0, image: "", position: 0)]
    public var fingersRight = [(isEnable: false, score: 0, image: "", position: 0),
                        (isEnable: false, score: 0, image: "", position: 0),
                        (isEnable: false, score: 0, image: "", position: 0),
                        (isEnable: false, score: 0, image: "", position: 0),
                        (isEnable: false, score: 0, image: "", position: 0)]
    
    @IBAction func switchHandAction(_ sender: Any) {
        
        if isLefty{
            switchHand.setImage(UIImage(named: "switchtoLeft", in: Cnstnt.Path.framework, compatibleWith: nil), for: UIControl.State.normal)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.leftHandHolder.isHidden = true
                    self?.rightHandHolder.isHidden = false
                    self?.LblResultados.text = "elemts_righthand".langlocalized()
                })
            }
            isLefty = false
        }else{
            switchHand.setImage(UIImage(named: "switchtoRight", in: Cnstnt.Path.framework, compatibleWith: nil), for: UIControl.State.normal)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.leftHandHolder.isHidden = false
                    self?.rightHandHolder.isHidden = true
                    self?.LblResultados.text = "elemts_lefthand".langlocalized()
                })
            }
            isLefty = true
        }
        
    }
    
    @IBAction func cerrarAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //#Btn Fondo/Redondo
        self.btnCerrar.backgroundColor = UIColor.red
        self.btnCerrar.layer.cornerRadius = self.btnCerrar.frame.height / 2
        self.switchHand.setImage(UIImage(named: "switchtoLeft", in: Cnstnt.Path.framework, compatibleWith: nil), for: UIControl.State.normal)
        self.lefHandImage.image = UIImage(named: "left-hand", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.rightHandImage.image = UIImage(named: "right.hand", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.btnCerrar.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.LblScore.text = String(format: "elemts_finger_score".langlocalized(), atributos?.scoremin ?? "5")
        self.LblResultados.text = "elemts_lefthand".langlocalized()
        self.twoF.image = nil
        self.threeF.image = nil
        self.fourF.image = nil
        self.fiveF.image = nil
        self.sevenF.image = nil
        self.eightF.image = nil
        self.nineF.image = nil
        self.tenF.image = nil

        for finger in fingersLeft{
            switch finger.position{
            case 1:
                if finger.isEnable{
                    self.oneF.image = self.setFingerPrint(finger.score)
                    left_thumb.isHidden = true
                }
                
                break
            case 2:
                
                if finger.isEnable{
                    self.twoF.image = self.setFingerPrint(finger.score)
                    left_index.isHidden = true
                }
                
                break
            case 3:
                
                if finger.isEnable{
                    self.threeF.image = self.setFingerPrint(finger.score)
                    left_middle.isHidden = true
                }
                
                break
            case 4:
                
                if finger.isEnable{
                    self.fourF.image = self.setFingerPrint(finger.score)
                    left_ring.isHidden = true
                }
                
                break
            case 5:
                
                if finger.isEnable{
                    self.fiveF.image = self.setFingerPrint(finger.score)
                    left_little.isHidden = true
                }
                
                break
            default:
                break
            }
        }
        
        for finger in fingersRight{
            switch finger.position{
            case 6:
                
                if finger.isEnable{
                    self.sixF.image = self.setFingerPrint(finger.score)
                    right_thumb.isHidden = true
                }
                
                break
            case 7:
                
                if finger.isEnable{
                    self.sevenF.image = self.setFingerPrint(finger.score)
                    right_index.isHidden = true
                }
                
                break
            case 8:
                
                if finger.isEnable{
                    self.eightF.image = self.setFingerPrint(finger.score)
                    right_middle.isHidden = true
                }
                
                break
            case 9:
                
                if finger.isEnable{
                    self.nineF.image = self.setFingerPrint(finger.score)
                    right_ring.isHidden = true
                }
                
                break
            case 10:
                
                if finger.isEnable{
                    self.tenF.image = self.setFingerPrint(finger.score)
                    right_little.isHidden = true
                }
                
                break
            default:
                break
            }
        }
        // DETECTING
        
        var isClear = true
        
        let score: Int = Int(self.atributos?.scoremin ?? "5")!
        for fingerLeft in self.fingersLeft{
            if score >= fingerLeft.score{
                
            }else{
                isClear = false
            }
        }
        
        for fingerRight in self.fingersRight{
            if score >= fingerRight.score{
                
            }else{
                isClear = false
            }
        }
        if !isClear{
            // REDO Veridium Scan
        }
    }
    
    func setFingerPrint(_ nfiq: Int)->String{
        switch nfiq{
        case 1:
            return "green-fingreprint"
        case 2:
            return "blue-fingerprint"
        case 3:
            return "yellow-fingerprint"
        case 4:
            return "orange-fingerprint"
        case 5:
            return "red-fingerprint"
        default:
            return ""
        }
    }
    
    func setFingerPrint(_ nfiq: Int)->UIImage?{
        switch nfiq{
        case 1:
            return UIImage(named: "green-fingreprint", in: Cnstnt.Path.framework, compatibleWith: nil)!
        case 2:
            return UIImage(named: "blue-fingerprint", in: Cnstnt.Path.framework, compatibleWith: nil)!
        case 3:
            return UIImage(named: "yellow-fingerprint", in: Cnstnt.Path.framework, compatibleWith: nil)!
        case 4:
            return UIImage(named: "orange-fingerprint", in: Cnstnt.Path.framework, compatibleWith: nil)!
        case 5:
            return UIImage(named: "red-fingerprint", in: Cnstnt.Path.framework, compatibleWith: nil)!
        default:
            return nil
        }
    }
}
