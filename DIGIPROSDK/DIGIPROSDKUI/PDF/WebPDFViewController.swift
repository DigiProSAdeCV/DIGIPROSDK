import UIKit
import WebKit


class WebPDFViewController: UIViewController {
    
    fileprivate var completion: (() -> ())? = nil
    fileprivate static var animationDuration = 0.3
    var pdfString: String?
    
    @IBOutlet weak var webFaq: WKWebView!
    
    deinit{
        pdfString = nil
        webFaq.navigationDelegate = nil
        webFaq.scrollView.delegate = nil
        
        WKWebView.clean()
        URLCache.shared.removeAllCachedResponses()
        NotificationCenter.default.removeObserver(self)
    }
    
    init() {
        super.init(nibName: "syCTiMgatmryFwp", bundle: Cnstnt.Path.framework)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        WKWebView.clean()
        URLCache.shared.removeAllCachedResponses()
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let data = Data(base64Encoded: pdfString!, options: .ignoreUnknownCharacters) {
            self.webFaq.load(data, mimeType: "application/pdf", characterEncodingName: "utf-8", baseURL: URL(fileURLWithPath: ""))
        }
        //#Btn Fondo/Redondo
        self.btnCerrar.backgroundColor = UIColor.red
        self.btnCerrar.layer.cornerRadius = self.btnCerrar.frame.height / 2
        self.btnCerrar.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
    }

    @IBOutlet weak var btnCerrar: UIButton!
    @IBAction func actionClose(_ sender: UIButton) {
        UIView.animate(withDuration: WebPDFViewController.animationDuration, animations: { [weak self] in
            self?.view.alpha = 0.0
        }) { [weak self] (_) in
            self?.view.removeFromSuperview()
            self?.removeFromParent()
            self?.completion?()
            
        }
    }

}

extension WebPDFViewController {
    
    static func show(in viewcontroller: UIViewController, pdfString: String?, completion: (() -> ())? = nil) {
        let alert = WebPDFViewController()
        alert.view.frame = viewcontroller.view.bounds
        alert.pdfString = pdfString!
        alert.view.alpha = 0.0
        alert.completion = completion
        viewcontroller.addChild(alert)
        alert.didMove(toParent: viewcontroller)
        viewcontroller.view.addSubview(alert.view)
        UIView.animate(withDuration: WebPDFViewController.animationDuration) {
            alert.view.alpha = 1.0
        }
    }
    
}
