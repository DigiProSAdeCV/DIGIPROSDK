import Foundation
import Eureka
public class DebugFormViewController: UIViewController{
    
    var elements: [BaseRow] = [BaseRow]()
    var filteredOrders: [BaseRow] = [BaseRow]()
    var listOrders: [BaseRow] = [BaseRow]()
    let cellReuseIdentifier = "cell"
    public var delegate: NuevaPlantillaViewController?
    public var forms = [Form]()
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 100
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { self.retriveAllData() }
    }
    
    func retriveAllData(){
        for page in forms{
            for element in page.allRows{
                elements.append(element)
            }
        }
        filteredOrders = elements
        listOrders = elements
        tableview.reloadData()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension DebugFormViewController: UITableViewDelegate, UITableViewDataSource {
       
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOrders.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellReuseIdentifier)
        let obj = filteredOrders[indexPath.row]
        cell.textLabel?.text = "\(obj.tag ?? "") \(obj)"
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = self.delegate?.getTitleByRow(obj)
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let actionAlert = UIAlertController(title: "Adicionales", message: "Utiliza las siguientes opciones", preferredStyle: UIAlertController.Style.actionSheet)
        let attributes = UIAlertAction(title: "Atributos", style: .default) { (action: UIAlertAction) in
            let obj = self.filteredOrders[indexPath.row]
            let detail = DebugDetailViewController(nibName: "DebugDetailViewController", bundle: Cnstnt.Path.framework)
            self.present(detail, animated: true, completion: nil)
            detail.txtView.text = ""
            let row = obj
            switch row{
            case is TextoRow:
                let base = row as? TextoRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is TextoAreaRow:
                let base = row as? TextoAreaRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is NumeroRow:
                let base = row as? NumeroRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is MonedaRow:
                let base = row as? MonedaRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is FechaRow:
                let base = row as? FechaRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is WizardRow:
                let base = row as? WizardRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is BotonRow:
                let base = row as? BotonRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is LogoRow:
                let base = row as? LogoRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is LogicoRow:
                let base = row as? LogicoRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is EtiquetaRow:
                let base = row as? EtiquetaRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is RangoFechasRow:
                let base = row as? RangoFechasRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is SliderNewRow:
                let base = row as? SliderNewRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is ListaRow:
                let base = row as? ListaRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is ComboDinamicoRow:
                let base = row as? ComboDinamicoRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is ListaTemporalRow:
                let base = row as? ListaTemporalRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is HeaderTabRow: break;
            case is HeaderRow: break;
            case is TablaRow:
                let base = row as? TablaRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is MarcadoDocumentoRow:
                let base = row as? MarcadoDocumentoRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is CodigoBarrasRow:
                let base = row as? CodigoBarrasRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is CodigoQRRow:
                let base = row as? CodigoQRRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is EscanerNFCRow:
                let base = row as? EscanerNFCRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is CalculadoraRow:
                let base = row as? CalculadoraRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is AudioRow:
                let base = row as? AudioRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is FirmaRow:
                let base = row as? FirmaRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is FirmaFadRow:
                let base = row as? FirmaFadRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
            case is MapaRow:
                let base = row as? MapaRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is DocumentoRow:
                let base = row as? DocumentoRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is ImagenRow:
                let base = row as? ImagenRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is DocFormRow:
                let base = row as? DocFormRow
                detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is VideoRow:
                let base = row as? VideoRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            case is VeridiumRow:
                let base = row as? VeridiumRow; detail.txtView.text = base?.cell.atributos?.toJsonString(.None, prettyPrinted: true)
                break;
            default: break;
            }
        }
        let rules = UIAlertAction(title: "Reglas", style: .default) { (action: UIAlertAction) in
            let obj = self.filteredOrders[indexPath.row]
            let detail = DebugDetailViewController(nibName: "DebugDetailViewController", bundle: Cnstnt.Path.framework)
            self.present(detail, animated: true, completion: nil)
            detail.txtView.text = ""
            let row = obj
            switch row{
            case is TextoRow:
                let base = row as? TextoRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is TextoAreaRow:
                let base = row as? TextoAreaRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is NumeroRow:
                let base = row as? NumeroRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is MonedaRow:
                let base = row as? MonedaRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is FechaRow:
                let base = row as? FechaRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is WizardRow:
                let base = row as? WizardRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is BotonRow:
                let base = row as? BotonRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is LogoRow:
                let base = row as? LogoRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is LogicoRow:
                let base = row as? LogicoRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is EtiquetaRow:
                let base = row as? EtiquetaRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is RangoFechasRow:
                let base = row as? RangoFechasRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is SliderNewRow:
                let base = row as? SliderNewRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is ListaRow:
                let base = row as? ListaRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is ComboDinamicoRow:
                let base = row as? ComboDinamicoRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is ListaTemporalRow:
                let base = row as? ListaTemporalRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is HeaderTabRow: break;
            case is HeaderRow: break;
            case is TablaRow:
                let base = row as? TablaRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is MarcadoDocumentoRow:
                let base = row as? MarcadoDocumentoRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is CodigoBarrasRow:
                let base = row as? CodigoBarrasRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is CodigoQRRow:
                let base = row as? CodigoQRRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is EscanerNFCRow:
                let base = row as? EscanerNFCRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is CalculadoraRow:
                let base = row as? CalculadoraRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is AudioRow:
                let base = row as? AudioRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is FirmaRow:
                let base = row as? FirmaRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is FirmaFadRow:
                let base = row as? FirmaFadRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is MapaRow:
                let base = row as? MapaRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is DocumentoRow:
                let base = row as? DocumentoRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is ImagenRow:
                let base = row as? ImagenRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is DocFormRow:
                let base = row as? DocFormRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0 { for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is VideoRow:
                let base = row as? VideoRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            case is VeridiumRow:
                let base = row as? VeridiumRow;
                if base?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (base?.cell.rulesOnChange)!{ detail.txtView.text.append(rule.xmlSpaces) } }
                if base?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (base?.cell.rulesOnProperties)!{ detail.txtView.text.append(rule.xml.xmlSpaces) } }
                break;
            default: break;
            }
        }
        let math = UIAlertAction(title: "Operaciones Matemáticas", style: .default) { (action: UIAlertAction) in
            
        }
        actionAlert.addAction(attributes)
        actionAlert.addAction(rules)
        actionAlert.addAction(math)
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        actionAlert.addAction(cancel)
        self.present(actionAlert, animated: true, completion: nil)
        
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
}

// MARK: - Search Bar Delegate
extension DebugFormViewController: UISearchBarDelegate{
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filteredOrders = searchBar.text!.isEmpty ? listOrders : listOrders.filter { (item: BaseRow) -> Bool in
            return item.tag?.range(of: searchBar.text!, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        self.tableview.reloadData()
    }
}

public class DebugDetailViewController: UIViewController{
    
    @IBOutlet weak var txtView: UITextView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
