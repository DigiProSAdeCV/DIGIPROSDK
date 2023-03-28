import Foundation
import Eureka

public protocol TablaPlantillaViewControllerDelegate {
    func didTapCancel()
    func didTapSave()->Bool
    func didTapSaveCancel()->Bool
    func didTapUpdate() -> Bool
    
    func settingMessages(_ mssg: String, _ type: String, _ style: BannerStyle)
}

public class TablaPlantillaViewController: FormViewController{
    
    @IBOutlet weak var btnCerrar: UIButton!
    @IBOutlet weak var btnAgregar: UIButton!
    @IBOutlet weak var btnLimpiar: UIButton!
    @IBOutlet weak var btnActualizar: UIButton!
    @IBOutlet weak var btnAgregarYcerrar: UIButton!

    public var row: TablaCell?
    var hijos: Form?
    var titleSection = ""
    var isEdited = false
    var isPreview = false
    var isVisualized = false
    let hud = JGProgressHUD(style: .dark)
    var attr: Atributos_tabla?
    var dataIdValue: NSMutableDictionary = NSMutableDictionary();
    
    public var clearAdd = false
    public var elementsForValidate = [String]()
    public var delegate: TablaPlantillaViewControllerDelegate?
    
    deinit{
        row = nil
        hijos = nil
        attr = nil
        delegate = nil
    }
    
    @IBAction func closeBtnAction(_ sender: Any?) {
        delegate?.didTapCancel() }
    
    @IBAction func limpiarAction(_ sender: Any) {
        for row in self.form.allRows{
            row.baseValue = nil
            switch row{
                // DIGIPROSDKSO
            case is ListaRow:
                let listarow: ListaRow = row as! ListaRow
                listarow.cell.atributos?.habilitado = true
                if listarow.value == nil && listarow.cell.txtInput.text == "" { break }
                let tl = listarow.cell.atributos?.tipolista
                if tl != "combo" {
                    listarow.cell.txtInput.text = "--Seleccione--"
                    listarow.cell.gralButton.selectedButtons().forEach{$0.isSelected = false}
                    listarow.cell.setEdited(v: "sinSelección", isRobot: false)
                }
                if tl == "combo" {
                    listarow.cell.seleccionarValor(desc: "", id: "", isRobot: true)
                }
                
                break;
            case is TextoRow:
                let cell = (row as? TextoRow)?.cell
                if ((cell?.atributos) != nil) {cell?.atributos?.habilitado = true }
                if cell == nil || cell?.txtInput.text == "" { break }
                cell?.setEdited(v: "")
                break;
            case is TextoAreaRow:
                let cell = (row as? TextoAreaRow)?.cell
                if ((cell?.atributos) != nil) {cell?.atributos?.habilitado = true }
                if cell == nil  { break }
                cell?.setEdited(v: "")
                break;
            case is NumeroRow:
                let cell = (row as? NumeroRow)?.cell
                if ((cell?.atributos) != nil) {cell?.atributos?.habilitado = true }
                if cell == nil  { break }
                cell?.setEdited(v: "")
                break;
            case is MonedaRow:
                let cell = (row as? MonedaRow)?.cell
                if ((cell?.atributos) != nil) {cell?.atributos?.habilitado = true }
                if cell == nil { break }
                cell?.setEdited(v: "")
                break;
            case is FechaRow:
                let cell = (row as? FechaRow)?.cell
                if ((cell?.atributos) != nil) {cell?.atributos?.habilitado = true }
                if cell == nil { break }
                cell?.setEdited(v: "")
                break;
            case is LogicoRow:
                let cell = (row as? LogicoRow)?.cell
                if ((cell?.atributos) != nil) {cell?.atributos?.habilitado = true }
                cell?.setEdited(v: "")
                break;
            case is RangoFechasRow:
                let cell = (row as? RangoFechasRow)?.cell
                if ((cell?.atributos) != nil) {cell?.atributos?.habilitado = true }
                if cell == nil { break }
                cell?.txtInput.text = ""
                cell?.setEdited(v: "")
                break;
            case is SliderNewRow:
                let cell = (row as? SliderNewRow)?.cell
                if ((cell?.atributos) != nil) {cell?.atributos?.habilitado = true }
                if cell == nil { break }
                cell?.setEdited(v: "")
                break;
            case is ListaTemporalRow:
                let cell = (row as? ListaTemporalRow)?.cell
                if ((cell?.atributos) != nil) {cell?.atributos?.habilitado = true }
                cell?.flagEmpty = true
                if cell == nil { break }
                cell?.setEdited(v: "")
                break;
            case is ComboDinamicoRow:
                let cell = (row as? ComboDinamicoRow)?.cell
                if ((cell?.atributos) != nil) {cell?.atributos?.habilitado = true }
                if cell == nil { break }
                cell?.setEdited(v: "")
                break;
            case is CodigoBarrasRow:
                let cell = (row as? CodigoBarrasRow)?.cell
                if cell == nil || cell?.row.value == nil { break }
                cell?.setEdited(v: "")
                break;
            case is EscanerNFCRow:
                let cell = (row as? EscanerNFCRow)?.cell
                if cell == nil || cell?.row.value == nil { break }
                cell?.setEdited(v: "")
                break;
            default: break;
            }
        }
    }
    
    func validate()->Bool{
        if self.tableView == nil{ return true }
        elementsForValidate = [String]()
        dataIdValue = NSMutableDictionary()
        let isValid = validateSingleForm()
        if elementsForValidate.count > 0{
            let row = self.form.rowBy(tag: "\(elementsForValidate.first ?? "")")
            let indexPath: IndexPath? = row?.indexPath
            if indexPath != nil{
                self.tableView.scrollToRow(at: indexPath ?? IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.tableView.selectRow(at: indexPath ?? IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
            }
            delegate?.settingMessages("not_check_fields".langlocalized(), "danger", .danger)
        }
        if isValid { return validateRepeat() }
        return isValid
    }
    
    func validateRepeat() -> Bool{
        if self.attr?.evitarduplicado == false || self.row?.records.isEmpty ?? false { return true }
        var isValid = true
        self.row?.allCleanedData.forEach{ if $0 == self.dataIdValue { isValid = false } }
        if !isValid { delegate?.settingMessages("Registro duplicado. No se puede insertar", "error", .danger) }
        return isValid
    }
    
    @IBAction func agregarAction(_ sender: Any?) {
        if ((attr?.filasmax ?? 0) != 0) && attr?.filasmax ?? 0 <= (self.row?.records.count)!{
            delegate?.settingMessages("elemts_table_rowmax".langlocalized(), "error", .danger)
            return
        }
            
        if validate() {
            _ = delegate?.didTapSave()
            delegate?.settingMessages("Registro guardado", "success", .success)
        }
    }
    
    @IBAction func agregarCerrarAction(_ sender: Any?) {
        if ((attr?.filasmax ?? 0) != 0) && attr?.filasmax ?? 0 <= (self.row?.records.count)!{
            delegate?.settingMessages("elemts_table_rowmax".langlocalized(), "error", .danger)
            return
        }
        if validate() {
            _ = delegate?.didTapSaveCancel()
            //self.limpiarAction((Any).self)
//            if ss{ self.limpiarAction((Any).self) }
        }
    }
    
    @IBAction func updateDataAction(_ sender: Any?){
        _ = self.validate()
        if validate(){
            _ = delegate?.didTapUpdate()
//            if ss{ self.limpiarAction((Any).self) }
        }
        
    }
        
    override public func viewDidLoad() {
        super.viewDidLoad() 
        // Do any additional setup after loading the view, typically from a nib.
        btnAgregarYcerrar.setTitle(attr?.botonagregarcerrartexto ?? "", for: .normal)
        btnActualizar.setTitle(attr?.botoneditartexto ?? "", for: .normal)
        btnLimpiar.setTitle(attr?.botonlimpiartexto ?? "", for: .normal)
        btnCerrar.setTitle(attr?.botoncerrartexto ?? "", for: .normal)
        btnAgregar.setTitle(attr?.botonagregartexto ?? "", for: .normal)
            
        btnAgregarYcerrar.setTitleColor(UIColor(hexFromString: attr?.colorbotonagregarcerrartexto ?? "#fff"), for: .normal)
        btnAgregarYcerrar.backgroundColor = UIColor(hexFromString: attr?.colorbotonagregarcerrar ?? "#000")
        
        btnAgregar.setTitleColor(UIColor(hexFromString: attr?.colorbotonagregartexto ?? "#fff"), for: .normal)
        btnAgregar.backgroundColor = UIColor(hexFromString: attr?.colorbotonagregar ?? "#000")
        
        btnAgregar.setTitleColor(UIColor(hexFromString: attr?.colorbotonagregartexto ?? "#fff"), for: .normal)
        btnAgregar.backgroundColor = UIColor(hexFromString: attr?.colorbotonagregar ?? "#000")
        
        btnLimpiar.setTitleColor(UIColor(hexFromString: attr?.colorbotonlimpiartexto ?? "#fff"), for: .normal)
        btnLimpiar.backgroundColor = UIColor(hexFromString: attr?.colorbotonlimpiar ?? "#000")
        
        btnCerrar.setTitleColor(UIColor(hexFromString: attr?.colorbotoncerrartexto ?? "#fff"), for: .normal)
        btnCerrar.backgroundColor = UIColor(hexFromString: attr?.colorbotoncerrar ?? "#000")
        
        btnActualizar.setTitleColor(UIColor(hexFromString: attr?.colorbotoneditartexto ?? "#fff"), for: .normal)
        btnActualizar.backgroundColor = UIColor(hexFromString: attr?.colorbotoneditar ?? "#000")
        
        
        self.btnCerrar.layer.cornerRadius = 3.0
        self.btnAgregar.layer.cornerRadius = 3.0
        self.btnLimpiar.layer.cornerRadius = 3.0
        self.btnAgregarYcerrar.layer.cornerRadius = 3.0
        self.tableView.reloadData()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //self.tableView.reloadData()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        
        btnCerrar.isHidden = !(attr?.permisotablacerrar ?? false)
        btnAgregar.isHidden = !(attr?.permisotablaagregarr ?? false)
        btnLimpiar.isHidden = !(attr?.permisotablalimpiar ?? false)
        btnActualizar.isHidden = !(attr?.permisotablaeditarr ?? false)
        btnAgregarYcerrar.isHidden = !(attr?.permisotablaagregarcerrarr ?? false)
        
        if isEdited || isPreview{
            self.btnActualizar.isHidden = false
            self.btnAgregar.isHidden = true
            self.btnAgregarYcerrar.isHidden = true
            self.btnLimpiar.isHidden = false
        }else{
            // We need to clean all rows
            if clearAdd {
                self.limpiarAction((Any).self)
                clearAdd = false
                self.row?.triggerRulesOnChange("tableshowadd")
            }
            self.btnActualizar.isHidden = true
        }
        
        if isPreview{
            self.btnActualizar.isHidden = true
            self.btnLimpiar.isHidden = true
        }
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func validateSingleForm() -> Bool{
        elementsForValidate = [String]()
        validationRowsForm(nil)
        if elementsForValidate.count > 0{ return false }else{ return true }
    }
    
    // Validation Rows By Form
    public func validationRowsForm(_ elements: [BaseRow]?){
        
        if elements != nil{
            for row in elements!{
                validateRowFromForm(row)
            }
        }else{
            for row in self.form.allRows{
                validateRowFromForm(row)
            }
        }
        
    }
    
    public func validateRowFromForm(_ row: BaseRow){
        
        switch row{
        // DIGIPROSDKSO
        case is TextoRow:
            let cell = (row as? TextoRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    cell?.row.value = cell?.txtInput.text != "" ? cell?.txtInput.text : cell?.elemento.validacion.valormetadato
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if (cell?.row.value == nil || cell?.row.value == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            if cell?.atributosPassword?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if (cell?.row.value == nil || cell?.row.value == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        case is TextoAreaRow:
            let cell = (row as? TextoAreaRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if (cell?.row.value == nil || cell?.row.value == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        case is NumeroRow:
            let cell = (row as? NumeroRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if (cell?.row.value == nil || cell?.row.value == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        case is MonedaRow:
            let cell = (row as? MonedaRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if (cell?.row.value == nil || cell?.row.value == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        case is FechaRow:
            let cell = (row as? FechaRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if (cell?.row.value == nil || cell?.txtInput.text == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            if cell?.atributosHora?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if (cell?.row.value == nil || cell?.txtInput.text == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        case is WizardRow:
            let cell = (row as? WizardRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
            }
            break;
        case is LogicoRow:
            let cell = (row as? LogicoRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if cell?.row.value == nil && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        case is RangoFechasRow:
            let cell = (row as? RangoFechasRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if cell?.row.value == nil && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        case is SliderNewRow: // No se puede agregar a una tabla
            let cell = (row as? SliderNewRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
            }
            break;
        case is ListaRow:
            let cell = (row as? ListaRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
                if  (cell?.row.value == nil || cell?.row.value == "--Seleccione--") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }

            }
            
            break;
        case is ListaTemporalRow:
            let cell = (row as? ListaTemporalRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                _ = row.validate()
                cell?.updateIfIsValid()
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }else if (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
                if (cell?.row.value == nil || cell?.row.value == "--Seleccione--" || cell?.row.value == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        case is ComboDinamicoRow:
            let cell = (row as? ComboDinamicoRow)?.cell
            if cell == nil { break }
            self.dataIdValue.setValue(cell?.elemento.validacion.valormetadato, forKey: cell?.elemento._idelemento ?? "");
            if cell?.atributos?.visible ?? false && !row.isHidden {
                _ = row.validate()
                cell?.updateIfIsValid()
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }else if (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
                if (cell?.row.value == nil || cell?.row.value == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        case is CodigoBarrasRow:
            let cell = (row as? CodigoBarrasRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if (cell?.row.value == nil || cell?.row.value == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        case is EscanerNFCRow:
            let cell = (row as? EscanerNFCRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append(row.tag ?? "")
                }
                if (cell?.row.value == nil || cell?.row.value == "") && !(cell?.elemento.validacion.needsValidation ?? false )
                {   cell?.triggerRulesOnChange("nil") }
            }
            break;
        default: break;
        }
        
    }
    
    public func reviewRulesOnColumns(idColumn: String, value: String){
        let baserow = self.row?.formDelegate?.getElementByIdInAllForms(idColumn)
        
        switch baserow{
        case is TextoRow:
            let row = baserow as? TextoRow
            if row?.cell.rulesOnChange.count ?? 0 > 0 {
                for rule in row?.cell.rulesOnChange ?? []
                {   var isColumn = false
                    let rules = FormularioUtilities.shared.rules!.root[rule.name]
                    for condition in rules["conditions"].children{
                        if condition["category"].value! == "table" { isColumn = true }
                    }
                    if isColumn {
                        let auxValue = row?.value
                        row?.value = value
                        _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                        row?.value = auxValue
                        return
                    }
                }
            }
            break;
        case is TextoAreaRow:
            let row = baserow as? TextoAreaRow
            if row?.cell.rulesOnChange.count ?? 0 > 0 {
                for rule in row?.cell.rulesOnChange ?? []
                {   var isColumn = false
                    let rules = FormularioUtilities.shared.rules!.root[rule.name]
                    for condition in rules["conditions"].children{
                        if condition["category"].value! == "table" { isColumn = true }
                    }
                    if isColumn {
                        let auxValue = row?.value
                        row?.value = value
                        _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                        row?.value = auxValue
                        return
                    }
                }
            }
            break;
        case is NumeroRow:
            let row = baserow as? NumeroRow
            if row?.cell.rulesOnChange.count ?? 0 > 0 {
                for rule in row?.cell.rulesOnChange ?? []
                {   var isColumn = false
                    let rules = FormularioUtilities.shared.rules!.root[rule.name]
                    for condition in rules["conditions"].children{
                        if condition["category"].value! == "table" { isColumn = true }
                    }
                    if isColumn {
                        let auxValue = row?.value
                        row?.value = value
                        _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                        row?.value = auxValue
                        return
                    }
                }
            }
            break;
        case is MonedaRow:
            let row = baserow as? MonedaRow
            if row?.cell.rulesOnChange.count ?? 0 > 0 {
                for rule in row?.cell.rulesOnChange ?? []
                {   var isColumn = false
                    let rules = FormularioUtilities.shared.rules!.root[rule.name]
                    for condition in rules["conditions"].children{
                        if condition["category"].value! == "table" { isColumn = true }
                    }
                    if isColumn {
                        let auxValue = row?.value
                        row?.value = value
                        _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                        row?.value = auxValue
                        return
                    }
                }
            }
            break;
        case is FechaRow:
            let row = baserow as? FechaRow
            if row?.cell.rulesOnChange.count ?? 0 > 0 {
                for rule in row?.cell.rulesOnChange ?? []
                {   var isColumn = false
                    let rules = FormularioUtilities.shared.rules!.root[rule.name]
                    for condition in rules["conditions"].children{
                        if condition["category"].value! == "table" { isColumn = true }
                    }
                    if isColumn {
                        let auxValue = row?.value
                        if row?.cell.atributos != nil {
                            _ = row?.cell.asignarFecha(valueDate: value, typeformat: row?.cell.atributos?.formato ?? "dd/MM/yyyy")
                        } else if row?.cell.atributosHora != nil {
                            _ = row?.cell.asignarHora(valueHour: value)
                        }
                        _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                        row?.value = auxValue
                        return
                    }
                }
            }
            break;
        case is BotonRow:
            let row = baserow as? BotonRow
            if row?.cell.rulesOnChange.count ?? 0 > 0 {
                for rule in row?.cell.rulesOnChange ?? []
                {   var isColumn = false
                    let rules = FormularioUtilities.shared.rules!.root[rule.name]
                    for condition in rules["conditions"].children{
                        if condition["category"].value! == "table" { isColumn = true }
                    }
                    if isColumn {
                        let auxValue = row?.value
                        row?.value = value
                        _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                        row?.value = auxValue
                        return
                    }
                }
            }
            break;
        case is LogicoRow:
            let row = baserow as? LogicoRow
            if row?.cell.rulesOnChange.count ?? 0 > 0 {
                for rule in row?.cell.rulesOnChange ?? []
                {   var isColumn = false
                    let rules = FormularioUtilities.shared.rules!.root[rule.name]
                    for condition in rules["conditions"].children{
                        if condition["category"].value! == "table" { isColumn = true }
                    }
                    if isColumn {
                        let auxValue = row?.value
                        row?.value = NSString(string:value).boolValue
                        _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                        row?.value = auxValue
                        return
                    }
                }
            }
            break;
        case is RangoFechasRow:
            let row = baserow as? RangoFechasRow
            if row?.cell.rulesOnChange.count ?? 0 > 0 {
                for rule in row?.cell.rulesOnChange ?? []
                {   var isColumn = false
                    let rules = FormularioUtilities.shared.rules!.root[rule.name]
                    for condition in rules["conditions"].children{
                        if condition["category"].value! == "table" { isColumn = true }
                    }
                    if isColumn {
                        let auxValue = row?.value
                        row?.value = value
                        _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                        row?.value = auxValue
                        return
                    }
                }
            }
            break;
        case is SliderNewRow:
            let row = baserow as? SliderNewRow
            if row?.cell.rulesOnChange.count ?? 0 > 0 {
                for rule in row?.cell.rulesOnChange ?? []
                {   var isColumn = false
                    let rules = FormularioUtilities.shared.rules!.root[rule.name]
                    for condition in rules["conditions"].children{
                        if condition["category"].value! == "table" { isColumn = true }
                    }
                    if isColumn {
                        let auxValue = row?.value
                        row?.value = value
                        _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                        row?.value = auxValue
                        return
                    }
                }
            }
            break;
        case is ListaRow:
            let row = baserow as? ListaRow
            if row?.cell.rulesOnChange.count ?? 0 > 0 {
                for rule in row?.cell.rulesOnChange ?? []
                {   var isColumn = false
                    let rules = FormularioUtilities.shared.rules!.root[rule.name]
                    for condition in rules["conditions"].children{
                        if condition["category"].value! == "table" { isColumn = true }
                    }
                    if isColumn {
                        let auxValue = row?.value
                        row?.value = value
                        _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                        row?.value = auxValue
                        return
                    }
                }
            }
            break;
        case is ComboDinamicoRow:
            if plist.idportal.rawValue.dataI() >= 40 {
                let row = baserow as? ComboDinamicoRow
                if row?.cell.rulesOnChange.count ?? 0 > 0 {
                    for rule in row?.cell.rulesOnChange ?? []
                    {   var isColumn = false
                        let rules = FormularioUtilities.shared.rules!.root[rule.name]
                        for condition in rules["conditions"].children{
                            if condition["category"].value! == "table" { isColumn = true }
                        }
                        if isColumn {
                            let auxValue = row?.value
                            row?.value = value
                            _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                            row?.value = auxValue
                            return
                        }
                    }
                }
            }
            break;
        case is ListaTemporalRow:
            let row = baserow as? ListaTemporalRow
                if row?.cell.rulesOnChange.count ?? 0 > 0 {
                    for rule in row?.cell.rulesOnChange ?? []
                    {   var isColumn = false
                        let rules = FormularioUtilities.shared.rules!.root[rule.name]
                        for condition in rules["conditions"].children{
                            if condition["category"].value! == "table" { isColumn = true }
                        }
                        if isColumn {
                            let auxValue = row?.value
                            row?.value = value
                            _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                            row?.value = auxValue
                            return
                        }
                    }
                }
                break;
        case is CodigoBarrasRow:
            let row = baserow as? CodigoBarrasRow
                if row?.cell.rulesOnChange.count ?? 0 > 0 {
                    for rule in row?.cell.rulesOnChange ?? []
                    {   var isColumn = false
                        let rules = FormularioUtilities.shared.rules!.root[rule.name]
                        for condition in rules["conditions"].children{
                            if condition["category"].value! == "table" { isColumn = true }
                        }
                        if isColumn {
                            let auxValue = row?.value
                            row?.value = value
                            _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                            row?.value = auxValue
                            return
                        }
                    }
                }
                break;
        case is EscanerNFCRow:
         if plist.idportal.rawValue.dataI() >= 39 {
            let row = baserow as? EscanerNFCRow
                if row?.cell.rulesOnChange.count ?? 0 > 0 {
                    for rule in row?.cell.rulesOnChange ?? []
                    {   var isColumn = false
                        let rules = FormularioUtilities.shared.rules!.root[rule.name]
                        for condition in rules["conditions"].children{
                            if condition["category"].value! == "table" { isColumn = true }
                        }
                        if isColumn {
                            let auxValue = row?.value
                            row?.value = value
                            _ = row?.cell.formDelegate?.obtainRules(rString: rule.name, eString: idColumn, vString: nil, forced: false, override: false)
                            row?.value = auxValue
                            return
                        }
                    }
                }
         }
                break;
        default: break;
        }
    }

}

extension TablaPlantillaViewController
{
    public func executeClear()
    {
        self.limpiarAction(Any.self)
    }
    
    public func executeTableAdd()
    {
        self.agregarAction(Any.self)
    }
    
    public func executeAddClear()
    {
        self.agregarCerrarAction(Any.self)
    }
    
    public func executeCloseClear()
    {
        self.closeBtnAction(Any.self)
    }
}
