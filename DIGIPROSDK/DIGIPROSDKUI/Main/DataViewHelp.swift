import Foundation


class DataViewHelp: UIViewController{
    var formato: FEFormatoData?
    var text: UITextView?
    var path: UITextView?
    var segment: UISegmentedControl?
    
    convenience init(formato feformato: FEFormatoData){
        self.init()
        self.formato = feformato
        self.layout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc public func changeHelp(_ sender: UISegmentedControl){
        text?.text = ""
        switch sender.selectedSegmentIndex{
        case 0:
            let mirror = Mirror(reflecting: formato!)
            for att in mirror.children{ setData("\(att.label ?? ""): \(att.value) \r\n") }
            break;
        case 1:
            setData(ConfigurationManager.shared.utilities.getXML(flujo: String(formato?.FlujoID ?? 0), exp: String(formato?.ExpID ?? 0), doc: String(formato?.TipoDocID ?? 0))); break;
        case 2:
            setData(ConfigurationManager.shared.utilities.getFormatoJson(formato!) ?? ""); break;
        case 3:
            setData(ConfigurationManager.shared.utilities.getAdditionals(formato!) ?? ""); break;
        default: break;
        }
        text?.setContentOffset(.zero, animated: true)
        text?.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    func layout(){
        segment = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        segment?.insertSegment(withTitle: "F", at: 0, animated: true)
        segment?.insertSegment(withTitle: "X", at: 1, animated: true)
        segment?.insertSegment(withTitle: "J", at: 2, animated: true)
        segment?.insertSegment(withTitle: "O", at: 3, animated: true)
        segment?.addTarget(self, action: #selector(changeHelp(_:)), for: .touchUpInside)
        segment?.addTarget(self, action: #selector(changeHelp(_:)), for: .valueChanged)
        self.view.addSubview(segment!)

        path = UITextView(frame: CGRect(x: 0, y: 60, width: self.view.frame.width, height: 60))
        path?.isEditable = false
        path?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        path?.textColor = .white
        path?.backgroundColor = .clear
        path?.layer.borderColor = .none
        path?.layer.borderWidth = 0.0
        path?.isUserInteractionEnabled = true
        path?.text = "\(FCFileManager.pathForDocumentsDirectory() ?? "")"
        self.view.addSubview(path!)
        
        text = UITextView(frame: CGRect(x: 0, y: 120, width: self.view.frame.width, height: (self.view.frame.height / 2) - 120))
        text?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 16.0)
        text?.isEditable = false
        self.view.addSubview(text!)
        
        segment?.selectedSegmentIndex = 0
        changeHelp(segment!)
    }
    
    func setData(_ data: String){
        text?.text.append("\(data)")
    }
}
