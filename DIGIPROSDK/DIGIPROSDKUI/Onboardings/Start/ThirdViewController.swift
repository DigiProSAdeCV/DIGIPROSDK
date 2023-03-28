import UIKit

import WebKit

public class ThirdViewController: UIViewController, UIApplicationDelegate{
    
    @IBOutlet private weak var imageOne: UIImageView!
    @IBOutlet private weak var imageTwo: UIImageView!
    @IBOutlet private weak var imageThree: UIImageView!
    @IBOutlet private weak var imageFour: UIImageView!
    @IBOutlet private weak var imageFive: UIImageView!
    @IBOutlet private weak var imageSix: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    var timer = Timer()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hero.isEnabled = true
        self.imageThree.hero.id = "circleThree"
        self.imageFour.hero.id = "circleFour"
        self.titleLabel.hero.id = "circleThree"
        self.infoLabel.hero.id = "buttonNext"
        self.nextButton.hero.id = "buttonNext"
        self.webView.hero.id = "buttonNext"
        
        self.titleLabel.text = "onbthrd_lbl_title".langlocalized()
        self.infoLabel.text = "onbthrd_lbl_info".langlocalized()
        self.nextButton.setTitle("onbfst_btn_next".langlocalized(), for: .normal)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        self.nextButton.layer.cornerRadius = 5.0
        
        if let auxImage = UIImage (named: "gray_silhouette", in: Cnstnt.Path.framework, compatibleWith: nil)
        {
            imageOne.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageOne.tintColor = Cnstnt.Color.blue
            imageTwo.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageTwo.tintColor = Cnstnt.Color.blue
            imageThree.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageThree.tintColor = Cnstnt.Color.green
            imageFour.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageFour.tintColor = UIColor.lightGray
            imageFive.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageFive.tintColor = UIColor.lightGray
            imageSix.image = auxImage.withRenderingMode(.alwaysTemplate)
            imageSix.tintColor = UIColor.lightGray
        }
        let url = Bundle.main.url(forResource: "shortcuts_gif", withExtension: "gif")
        let data = try! Data(contentsOf: url!)
        self.webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
        self.webView.contentMode = UIView.ContentMode.scaleAspectFit
        // Do any additional setup after loading the view.
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let url = Bundle.main.url(forResource: "shortcuts_gif", withExtension: "gif")
        let data = try! Data(contentsOf: url!)
        self.webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
        self.webView.contentMode = UIView.ContentMode.scaleAspectFit
        self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        // Something cool
        let url = Bundle.main.url(forResource: "shortcuts_gif", withExtension: "gif")
        let data = try! Data(contentsOf: url!)
        self.webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
        self.webView.contentMode = UIView.ContentMode.scaleAspectFit
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.timer.invalidate()
    }

    @IBAction func nextAction(_ sender: Any) {
        let destination = FourViewController.init(nibName: "aPivzVuUzeqtRXL", bundle: Cnstnt.Path.framework)
        destination.modalPresentationStyle = .fullScreen
        self.present(destination, animated: true, completion: nil)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer){
        if (sender.direction == .left){
            let destination = FourViewController.init(nibName: "aPivzVuUzeqtRXL", bundle: Cnstnt.Path.framework)
            destination.modalPresentationStyle = .fullScreen
            self.present(destination, animated: true, completion: nil)
        }
        
        if (sender.direction == .right){
            self.dismiss(animated: true, completion: nil)
            
            // show the view from the left side
        }
    }
    
}
