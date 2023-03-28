import Foundation
import Eureka

public class ModalViewController: FormViewController, TypedRowControllerType, UINavigationControllerDelegate{
   
    @IBOutlet weak var btnClose: UIButton!
    /// The row that pushed or presented this controller
    public var row: RowOf<String>!
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    var delegate: NuevaPlantillaViewController?
    
    @IBAction func btnCloseAction(_ sender: Any) {
        for row in self.form.allRows{
            row.hidden = true
            row.evaluateHidden()
        }
        self.tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    public func initForm(_ form: Form, _ delegate: NuevaPlantillaViewController){
        self.form = form
        self.delegate = delegate
    }
    
    public func setVisibleRows(){
        for row in self.form.allRows{
            switch row {
            case is TextoRow:
                let cell = (row as! TextoRow).cell
                let atributos = cell?.atributos!
                let visible = atributos?.visible ?? false
                row.hidden = Condition(booleanLiteral: !visible)
                row.evaluateHidden()
                break
            case is ListaRow:
                let cell = (row as! ListaRow).cell
                let atributos = cell?.atributos!
                let visible = atributos?.visible ?? false
                row.hidden = Condition(booleanLiteral: !visible)
                row.evaluateHidden()
                break
            case is FechaRow:
                let cell = (row as! FechaRow).cell
                let atributos = cell?.atributos!
                let visible = atributos?.visible ?? false
                row.hidden = Condition(booleanLiteral: !visible)
                row.evaluateHidden()
                break
            case is WizardRow:
                let cell = (row as! WizardRow).cell
                let atributos = cell?.atributos!
                let visible = atributos?.visible ?? false
                row.hidden = Condition(booleanLiteral: !visible)
                row.evaluateHidden()
                break
            case is HeaderRow:
                let cell = (row as! HeaderRow).cell
                let atributos = cell?.atributos!
                let visible = atributos?.visible ?? false
                row.hidden = Condition(booleanLiteral: !visible)
                row.evaluateHidden()
                break
            case is EtiquetaRow:
                let cell = (row as! EtiquetaRow).cell
                let atributos = cell?.atributos!
                let visible = atributos?.visible ?? false
                row.hidden = Condition(booleanLiteral: !visible)
                row.evaluateHidden()
                break
            default: break
            }
        }
        self.tableView.reloadData()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        btnClose.backgroundColor = UIColor.red
        btnClose.layer.cornerRadius = btnClose.frame.height / 2
        btnClose.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: UIControl.State.normal)
        view.backgroundColor = UIColor.white
    }

}



