import Foundation
import UIKit


public class NuevoFEViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, APIDelegate{
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var device: Device?
    var isInitiated = false
    let cellReuseIdentifier = "cell"
    
    var sdkAPI : APIManager<NuevoFEViewController>?
    public var dataviewDelegate: ControllerDelegate?
    private var hud: JGProgressHUD?
    var arrayPlantillaData = Array<(String, Array<FEPlantillaData>)>()
    var plantillasData = [(String,Array<FEPlantillaData>)]()
    var selectedSection = 0
    var selectedIndex = 0
    var isAutoEnable = false
    
    /*
     MARK: - API PROTOCOLS
     Protocolos del APIDelegate
     */
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendToServerFormatos() { }
    public func isVisibleHUD() { }
    public func didSendError(message: String, error: enumErrorType) {
        let rightView = UIImageView(image: UIImage(named: "warning_sign", in: Cnstnt.Path.framework, compatibleWith: nil))
        let bannerNew = NotificationBanner(title: "", subtitle: message, leftView: nil, rightView: rightView, style: .danger, colors: nil)
        bannerNew.show()
    }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    
    public func performNewPlantilla() {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.dataviewDelegate?.performNuevoFeViewController(self.arrayPlantillaData[self.selectedSection].1[self.selectedIndex], self.selectedIndex)
        }
        
    }
    // MARK: Life Cycle
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if ConfigurationManager.shared.hasNewFormat{
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if isAutoEnable{
            let modeApp = UserDefaults.standard.string(forKey: Cnstnt.BundlePrf.licenceMode)
            switch modeApp {
            case "Normal": break
            case "Kiosco": performNewPlantilla(); break
            case "SDK": break
            case "Licencia": break
            default: break
            }
        }
    }
    
    override public func viewDidLoad(){
        sdkAPI = APIManager<NuevoFEViewController>()
        self.titleLabel.text = "nvovw_lbl_title".langlocalized()
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.initAsync()
    }
    
    public func initAsync(){
        
        selectedSection = 0
        selectedIndex = 0
        
        DispatchQueue.main.async {
            self.hud = JGProgressHUD(style: .dark)
            self.hud?.show(in: self.view)
        }
        
        self.getStoredPlantillas()
        
        if self.arrayPlantillaData.count == 0{
            let banner = NotificationBanner(title: "not_templates".langlocalized(), subtitle: "not_templates_des".langlocalized(), style: .danger)
            banner.show()
            DispatchQueue.main.async {
                self.hud?.dismiss(animated: true)
            }
            isInitiated = false
            return
        }
        
        if self.arrayPlantillaData[0].1.count == 1{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                let indexPath = NSIndexPath(row: 0, section: 0) as IndexPath
                self.tableview.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
                self.tableview.delegate?.tableView!(self.tableview, didSelectRowAt: indexPath)
            })
        }
        DispatchQueue.main.async {
            self.hud?.dismiss(animated: true)
        }
        isInitiated = true
    }

    public func getStoredPlantillas(){
        if FormularioUtilities.shared.globalFlujo != 0{
            arrayPlantillaData = (self.sdkAPI?.DGSDKgetTemplates(String(FormularioUtilities.shared.globalFlujo)))!
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    // MARK: Table View
    public func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayPlantillaData.count == 0{ return 0 }
        return arrayPlantillaData[section].1.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        let object = arrayPlantillaData[indexPath.section].1[indexPath.row]
        cell?.textLabel?.text = "\(object.NombreTipoDoc.uppercased())"
        cell?.textLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        cell?.textLabel?.textColor = UIColor(named: "black", in: Cnstnt.Path.framework, compatibleWith: nil)
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSection = indexPath.section
        selectedIndex = indexPath.row
        performNewPlantilla()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 45.0; }
    
}
