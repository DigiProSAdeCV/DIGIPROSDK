import Foundation
import UIKit


public class FlujoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, APIDelegate{
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
    let cellReuseIdentifier = "cell"
    public lazy var hud: JGProgressHUD = JGProgressHUD(style: .dark)
    public var dataviewDelegate: ControllerDelegate?
    var isUpdated: Bool = false
    var sdkAPI : APIManager<FlujoViewController>?
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let image = UIImage(named: "icon-downloaddata", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.updateButton.setImage(image, for: .normal)
        hud.show(in: self.view)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.tableview.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(850)) {
            self.hud.dismiss(animated: true)
        }
    }
    
    override public func viewDidLoad(){
        super.viewDidLoad()
        sdkAPI = APIManager<FlujoViewController>()
        sdkAPI?.delegate = self
        self.tableview.reloadData()
        self.titleLabel.text = "fljvw_lbl_title".langlocalized()
    }
    @IBAction func updateAction(_ sender: UIButton) {
        self.dataviewDelegate?.updatePlantillas()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View
    public func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return ConfigurationManager.shared.flujosOrdered.count }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? =
            tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellReuseIdentifier)
        }
        cell?.subviews.forEach({
            if $0.isKind(of: UIButton.self){ $0.removeFromSuperview() }
        })
        
        let obj = ConfigurationManager.shared.flujosOrdered[indexPath.row]
        cell?.textLabel?.text = "\(obj.NombreFlujo)"
        cell?.textLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        cell?.textLabel?.textColor = UIColor(named: "black", in: Cnstnt.Path.framework, compatibleWith: nil)
        
        if obj.CounterFormats > 0{
            let btn = UIButton()
            btn.layer.cornerRadius = 15
            btn.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 10.0)
            btn.setTitle(String(obj.CounterFormats), for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = .red
            btn.translatesAutoresizingMaskIntoConstraints = false
            cell?.addSubview(btn)
            btn.topAnchor.constraint(equalTo: cell!.topAnchor, constant: 7).isActive = true
            btn.trailingAnchor.constraint(equalTo: cell!.trailingAnchor, constant: -5).isActive = true
            btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Selection
        self.dismiss(animated: true, completion: nil)
        FormularioUtilities.shared.globalProceso = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.dataviewDelegate?.performFlowSelection(indexPath.row)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 45.0; }
    
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
    public func sendStatusCodeMessage(message: String, error: enumErrorType) {}
    public func didSendError(message: String, error: enumErrorType) {}
    public func didSendResponse(message: String, error: enumErrorType) {}
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
    
}
