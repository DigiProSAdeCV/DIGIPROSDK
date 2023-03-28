import UIKit



protocol CustomAlertViewDelegate: AnyObject {
    func okButtonTapped()
    func cancelButtonTapped()
}

class CustomAlertView: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    var delegate: CustomAlertViewDelegate?
    var namePlantilla: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
        if ConfigurationManager.shared.isConsubanco{
            if  self.namePlantilla == "Biométrico"{
                self.titleLabel.text = "ctmalrt_lbl_title".langlocalized()
                self.messageLabel.text = "ctmalrt_lbl_message".langlocalized()
                self.okButton.setTitle("ctmalrt_btn_ok".langlocalized(), for: .normal)
                self.cancelButton.setTitle("ctmalrt_btn_cancel".langlocalized(), for: .normal)
            }else{
                self.titleLabel.text = "ctmalrt_lbl_title_EC".langlocalized()
                self.messageLabel.text = "ctmalrt_lbl_message_EC".langlocalized()
                self.okButton.setTitle("ctmalrt_btn_ok_EC".langlocalized(), for: .normal)
                self.cancelButton.setTitle("ctmalrt_btn_cancel_EC".langlocalized(), for: .normal)
            }
        }else{
            self.titleLabel.text = "ctmalrt_lbl_title".langlocalized()
            self.messageLabel.text = "ctmalrt_lbl_message".langlocalized()
            self.okButton.setTitle("ctmalrt_btn_ok".langlocalized(), for: .normal)
            self.cancelButton.setTitle("ctmalrt_btn_cancel".langlocalized(), for: .normal)
        }

    }
    
    func setupView() {
        alertView.layer.cornerRadius = 12
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.alertView.alpha = 1.0
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.cancelButtonTapped()
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.okButtonTapped()
    }
}
