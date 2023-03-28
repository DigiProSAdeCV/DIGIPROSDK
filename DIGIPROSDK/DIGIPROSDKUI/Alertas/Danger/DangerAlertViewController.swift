import UIKit


public class DangerAlertViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var imageAlert: UIImageView!
    @IBOutlet weak var titleAlertLabel: UILabel!
    @IBOutlet weak var descriptionAlertLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    fileprivate var completion: (() -> ())? = nil
    fileprivate static var animationDuration = 0.4
    
    init() {
        super.init(nibName: "ozUXrCYgLVenYix", bundle: Cnstnt.Path.framework)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.layer.cornerRadius = 10.0
        self.closeButton.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
    }

    @IBAction func closeAction(_ sender: UIButton) {
        UIView.animate(withDuration: DangerAlertViewController.animationDuration, animations: { [weak self] in
            self?.view.alpha = 0.0
        }) { [weak self] (_) in
            self?.view.removeFromSuperview()
            self?.removeFromParent()
            self?.completion?()
            
        }
    }
}


extension DangerAlertViewController {
    
    public func show(in viewcontroller: UIViewController, title: String?, description: String?, textButton: String?, imageAlert: UIImage?, colorBanner: UIColor?, colorButton: UIColor?, colorText: UIColor?, completion: (() -> ())? = nil) {
        let alert = DangerAlertViewController()
        alert.view.frame = viewcontroller.view.bounds
        alert.titleAlertLabel.text = title
        alert.titleAlertLabel.textColor = colorText
        alert.descriptionAlertLabel.text = description
        alert.colorView.backgroundColor = colorBanner
        alert.closeButton.backgroundColor = colorButton
        alert.closeButton.setTitle(textButton, for: .normal)
        alert.closeButton.setTitleColor(colorText, for: .normal)
        alert.imageAlert.image = imageAlert
        alert.view.alpha = 0.0
        alert.completion = completion
        viewcontroller.addChild(alert)
        alert.didMove(toParent: viewcontroller)
        viewcontroller.view.addSubview(alert.view)
        UIView.animate(withDuration: DangerAlertViewController.animationDuration) {
            alert.view.alpha = 1.0
        }
    }
    
    
    
    
}
