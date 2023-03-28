import Foundation
import Eureka

public class MarcadoDocumentoViewController: FormViewController, TypedRowControllerType, UINavigationControllerDelegate, UISearchBarDelegate {
    /// The row that pushed or presented this controller
    public var row: RowOf<String>!
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    // MARK: Global Var
    var isSelectedItem = false
    public weak var atributos: Atributos_marcadodocumentos?
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnCerrar: UIButton!
    
    // MARK: - Destructor
    deinit {
        atributos = nil
    }
    
    @IBAction public func cerrarAction(_ sender: Any) {
        let listaSeleccion = form.first as! SelectableSection<ListCheckRow<String>>
        if listaSeleccion.selectedRow()?.tag != nil || listaSeleccion.selectedRow() != nil{
            isSelectedItem = true
        }
        if form.allRows.isEmpty { isSelectedItem = true }
        
        if isSelectedItem || !isSelectedItem {
            if let navController = self.navigationController {
                if ((navController.topViewController as? MarcadoDocumentoViewController) != nil){
                    navController.popViewController(animated: true)
                }
            }
           onDismissCallback?(self)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        lblTitle.text = atributos?.titulo ?? ""
        
        searchBar.delegate = self
        // Quita el contorno negro de la search bar
        self.searchBar.backgroundImage = UIImage()
        btnCerrar.backgroundColor = UIColor.red
        btnCerrar.layer.cornerRadius = btnCerrar.frame.height / 2
        btnCerrar.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: UIControl.State.normal)
        
        lblTitle.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        btnCerrar.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 15.0)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isSelectedItem = false
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // We need to reload table view for cell layout issue the border of the cell is not rendering
        self.tableView.reloadData()
    }
    
    public func initForm(_ form: Form){
        self.form = form
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        form[indexPath].updateCell()
        form[indexPath].baseCell.textLabel?.numberOfLines = 0
        form[indexPath].baseCell.textLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        return form[indexPath].baseCell
    }
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        for row in self.form.allRows {
            if searchBar.text == ""{ row.hidden = false; row.evaluateHidden(); continue }
            let res = row.title?.range(of: searchBar.text!, options: .caseInsensitive, range: nil, locale: nil)
            if res == nil{ row.hidden = true; row.evaluateHidden() }
        }
        self.tableView.reloadData()
    }
}
