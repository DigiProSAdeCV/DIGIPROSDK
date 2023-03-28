import UIKit

import WebKit

public class FourViewController: UIViewController, UIApplicationDelegate {
    
    @IBOutlet private weak var imageOne: UIImageView!
    @IBOutlet private weak var imageTwo: UIImageView!
    @IBOutlet private weak var imageThree: UIImageView!
    @IBOutlet private weak var imageFour: UIImageView!
    @IBOutlet private weak var imageFive: UIImageView!
    @IBOutlet private weak var imageSix: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var calcLabel: UILabel!
    @IBOutlet weak var consultaLabel: UILabel!
    @IBOutlet weak var calcImage: UIImageView!
    @IBOutlet weak var consultaImage: UIImageView!
    @IBOutlet weak var lineViewOne: UIView!
    @IBOutlet weak var lineViewTwo: UIView!
    @IBOutlet weak var lineViewThree: UIView!
    @IBOutlet weak var webView: WKWebView!
    
    var timer = Timer()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        self.imageFour.hero.id = "circleFour"
        self.imageFive.hero.id = "circleFive"
        self.titleLabel.hero.id = "circleFour"
        self.infoLabel.hero.id = "buttonNext"
        self.nextButton.hero.id = "buttonNext"
        self.imageView.hero.id = "buttonNext"
        self.webView.hero.id = "buttonNext"
        self.calcLabel.hero.id = "circleFour"
        self.consultaLabel.hero.id = "circleFour"
        self.calcImage.hero.id = "buttonNext"
        self.consultaImage.hero.id = "buttonNext"
        self.lineViewOne.hero.id = "circleFour"
        self.lineViewTwo.hero.id = "circleFour"
        self.lineViewThree.hero.id = "circleFour"
        
        self.titleLabel.text = "onbfrth_lbl_title".langlocalized()
        self.infoLabel.text = "onbfrth_lbl_info".langlocalized()
        self.calcLabel.text = "onbfrth_lbl_calc".langlocalized()
        self.consultaLabel.text = "onbfrth_lbl_consult".langlocalized()
        self.nextButton.setTitle("onbfst_btn_next".langlocalized(), for: .normal)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        self.nextButton.layer.cornerRadius = 5.0
        
        let url = Bundle.main.url(forResource: "widget_gif", withExtension: "gif")
        let data = try! Data(contentsOf: url!)
        self.webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
        self.webView.contentMode = UIView.ContentMode.scaleAspectFit
       
        self.calcImage.image = UIImage (named: "ic_calculator_tutorial", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.consultaImage.image = UIImage (named: "ic_query_tutorial", in: Cnstnt.Path.framework, compatibleWith: nil)
        if let auxImage = UIImage (named: "gray_silhouette", in: Cnstnt.Path.framework, compatibleWith: nil)
        {
            imageOne.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageOne.tintColor = Cnstnt.Color.blue
            imageTwo.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageTwo.tintColor = Cnstnt.Color.blue
            imageThree.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageThree.tintColor = Cnstnt.Color.blue
            imageFour.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageFour.tintColor = Cnstnt.Color.green
            imageFive.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageFive.tintColor = UIColor.lightGray
            imageSix.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageSix.tintColor = UIColor.lightGray
        }

        // Do any additional setup after loading the view.
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let url = Bundle.main.url(forResource: "widget_gif", withExtension: "gif")
        let data = try! Data(contentsOf: url!)
        self.webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
        webView.contentMode = UIView.ContentMode.scaleAspectFit
        self.timer = Timer.scheduledTimer(timeInterval: 32.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        // Something cool
        let url = Bundle.main.url(forResource: "widget_gif", withExtension: "gif")
        let data = try! Data(contentsOf: url!)
        self.webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
        webView.contentMode = UIView.ContentMode.scaleAspectFit
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.timer.invalidate()
    }

    @IBAction func nextAction(_ sender: UIButton) {
        let destination = FiveViewController.init(nibName: "tMnYbwvgyVUFsmi", bundle: Cnstnt.Path.framework)
        destination.modalPresentationStyle = .fullScreen
        self.present(destination, animated: true, completion: nil)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer){
        if (sender.direction == .left){
            let destination = FiveViewController.init(nibName: "tMnYbwvgyVUFsmi", bundle: Cnstnt.Path.framework)
            destination.modalPresentationStyle = .fullScreen
            self.present(destination, animated: true, completion: nil)        }
        
        if (sender.direction == .right){
            self.dismiss(animated: true, completion: nil)
            
            // show the view from the left side
        }
    }
    
    
}
