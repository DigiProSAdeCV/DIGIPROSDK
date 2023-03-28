import Foundation
import UIKit


public class ConsultasViewController: UIViewController, APIDelegate, UINavigationControllerDelegate{
    
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    
    @IBOutlet public var tableview: UITableView!
    @IBOutlet public var titleLabel: UILabel!
    
    let apiSDK = APIManager<ConsultasViewController>()
    let cellReuseIdentifier = "cell"
    public lazy var hud: JGProgressHUD = JGProgressHUD(style: .dark)
    public var dataviewDelegate: ControllerDelegate?
    
    var emptyTitleTableView = String(format: "cnslvw_lbl_title".langlocalized(), ConfigurationManager.shared.usuarioUIAppDelegate.User)
    var emptySubtitleTableView = "nodatavw_table_subtitle".langlocalized()
    
    public override func viewWillAppear(_ animated: Bool) {
        hud.show(in: self.view)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            self.hud.dismiss(animated: true)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "cnslvw_lbl_title".langlocalized()
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableview.delegate = self
        self.tableview.dataSource = self
        apiSDK.delegate = self
        self.navigationController?.delegate = self
        self.navigationController?.isNavigationBarHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if ConfigurationManager.shared.mainTab?.selectedIndex == 1{
            _ = apiSDK.validConsultasOffline(delegate: self)
            self.tableview.reloadData()
            if ConfigurationManager.shared.consultasUIAppDelegate.count == 1{
                self.dismiss(animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    self.dataviewDelegate?.performConsultaViewController(0)
                }
            }
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
}

extension ConsultasViewController: UITableViewDelegate, UITableViewDataSource{
    
    public func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConfigurationManager.shared.consultasUIAppDelegate.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        cell?.textLabel?.text = "\(ConfigurationManager.shared.consultasUIAppDelegate[indexPath.row].Nombre.uppercased())."
        cell?.textLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        cell?.textLabel?.textColor = UIColor(hexFromString: "#202020", alpha: 1)
        cell?.textLabel?.textColor = .label
        return cell!
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let form = ConsultasFormViewController.init(nibName: "RIqpwNzWIdapSSS", bundle: Cnstnt.Path.framework)
        form.reporte = ConfigurationManager.shared.consultasUIAppDelegate[indexPath.row]
        self.navigationController?.pushViewController(form, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 45 }
    
}

// MARK: - DZNEMPTYDATA
extension ConsultasViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    public func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = emptyTitleTableView
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    public func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = emptySubtitleTableView
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    public func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? { return nil }
    public func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? { return nil }
}
