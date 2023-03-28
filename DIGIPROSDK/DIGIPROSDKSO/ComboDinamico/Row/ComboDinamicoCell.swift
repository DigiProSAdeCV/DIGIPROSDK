import Eureka
import UIKit

// MARK: ComboDinamicoCell
open class ComboDinamicoCell: Cell<String>, CellType, APIDelegate {
    
    lazy var headersView: FEHeaderView = {
        let header = FEHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
    lazy var comboBoxSelection: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(txtInput)
        view.addSubview(arrow)
        view.addSubview(btnDrop)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.clipsToBounds = false
        NSLayoutConstraint.activate([
            txtInput.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            txtInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            txtInput.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -5),
            
            arrow.centerYAnchor.constraint(equalTo: txtInput.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            arrow.heightAnchor.constraint(equalToConstant: 30.0),
            arrow.widthAnchor.constraint(equalToConstant: 30.0),
            
            btnDrop.topAnchor.constraint(equalTo: view.topAnchor),
            btnDrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            btnDrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            btnDrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            view.heightAnchor.constraint(equalToConstant: 44),
        ])
        return view
    }()
    lazy var txtInput: UILabel = {
        let txtInput = UILabel()
        txtInput.translatesAutoresizingMaskIntoConstraints = false
        return txtInput
    }()
    lazy var arrow: UIImageView = {
        let arrow = UIImageView()
        arrow.image = UIImage(named: "ic_arrow_dropDown", in: Cnstnt.Path.framework, compatibleWith: nil)
        arrow.translatesAutoresizingMaskIntoConstraints = false
        return arrow
    }()
    lazy var btnDrop: UIButton = {
        let btnDrop = UIButton()
        btnDrop.addTarget(self, action: #selector(self.onClickDropButton(_:)), for: .touchUpInside)
        btnDrop.translatesAutoresizingMaskIntoConstraints = false
        return btnDrop
    }()
    lazy var stackButtons: UIStackView = {
        let stackButtons = UIStackView()
        stackButtons.axis = .vertical
        stackButtons.spacing = 0
        stackButtons.distribution = .fillProportionally
        stackButtons.translatesAutoresizingMaskIntoConstraints = false
        return stackButtons
    }()
    lazy var stackBody: UIStackView = {
        let stackBody = UIStackView()
        stackBody.axis = .vertical
        stackBody.spacing = 5
        stackBody.distribution = .fill
        stackBody.addArrangedSubview(headersView)
        stackBody.addArrangedSubview(comboBoxSelection)
        stackBody.addArrangedSubview(stackButtons)
        stackBody.translatesAutoresizingMaskIntoConstraints = false
        return stackBody
    }()
    
    lazy var bgHabilitado: UIView = {
        let bgHabilitado = UIView()
        bgHabilitado.translatesAutoresizingMaskIntoConstraints = false
        return bgHabilitado
    }()
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var rulesOnAction: [AEXMLElement] = []
    public var filtroCombo: [(id: String, row: BaseRow)] = []
    public var elemento = Elemento()
    public var atributos: Atributos_comboDinamico?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var datosCatalogo: FECatRemotoData?
    public var valueOpen: Bool = false
    public var filtrosOK = Array<FECatRemotoFiltros>()
    public var gralButton : DLRadioButton = DLRadioButton()
    public var listItemsCombo : [String] =  []
    public var setListItemsInCombo : [String] = [String]()
    lazy var banner = NotificationBanner(title: "No hay elementos", subtitle: "Revise la configuracion de la plantilla.", leftView: nil, rightView: nil, style: .success, colors: nil)
    var sdkAPI : APIManager<ComboDinamicoCell>?
    var msjErrorCat : String = ""
    var otherButtons : [DLRadioButton] = [];
    var arrayId: [Any] = []
    var valueInit: String = ""
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
    }
    
    // MARK: SETTING
    /// SetObject for ComboDinamicoRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_comboDinamico
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        if (atributos?.tipolista ?? "").contains("nil") { atributos?.tipolista = "combo" }
        self.setTypeList(atributos?.tipolista ?? "combo")
        
        headersView.setTitleText(atributos?.titulo ?? "")
        headersView.setSubtitleText(atributos?.subtitulo ?? "")
        headersView.setHelpText(atributos?.ayuda ?? "")
        headersView.setRequerido(atributos?.requerido ?? false)
        headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false)
        headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false)
        headersView.setAlignment(atributos?.alineadotexto ?? "")
        headersView.setDecoration(atributos?.decoraciontexto ?? "")
        headersView.setTextStyle(atributos?.estilotexto ?? "")
        headersView.btnInfo.isHidden = atributos?.ayuda == "" ? true : false
        headersView.viewInfoHelp = (row as? ComboDinamicoRow)?.cell.formCell()?.formViewController()?.tableView

        contentView.addSubview(stackBody)
        contentView.addSubview(bgHabilitado)
        NSLayoutConstraint.activate([
          
            stackBody.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackBody.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackBody.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackBody.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            bgHabilitado.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgHabilitado.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bgHabilitado.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bgHabilitado.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        self.setTypeList(atributos?.tipolista ??  "")
        self.sdkAPI = APIManager<ComboDinamicoCell>()
        setMode(atributos?.modocolumnas ?? false)
    }
    
    override open func update() {
        super.update()
    }
    
    // MARK: - INIT
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        if self.headersView.isInfoToolTipVisible{
            self.headersView.toolTip!.dismiss()
            self.headersView.isInfoToolTipVisible = false
        }
    }
    
    // MARK: - FUNTIONS
    public func guardarValor (desc: String, id: String)
    {
        switch self.atributos?.tipoasociacion {
        case "idid":
            self.elemento.validacion.valor = id
            self.elemento.validacion.valormetadato  = id
            self.elemento.validacion.valormetadatoinicial = desc
            break;
        case "descid":
            self.elemento.validacion.valor = id
            self.elemento.validacion.valormetadato = desc
            self.elemento.validacion.valormetadatoinicial = desc
            break;
        case "iddesc":
            self.elemento.validacion.valor = desc
            self.elemento.validacion.valormetadato = id
            self.elemento.validacion.valormetadatoinicial = desc
            break;
        case "descdesc":
            self.elemento.validacion.valor = desc
            self.elemento.validacion.valormetadato = desc
            self.elemento.validacion.valormetadatoinicial = desc
            break;
        default:
            self.elemento.validacion.valor = desc
            self.elemento.validacion.valormetadato = id
            self.elemento.validacion.valormetadatoinicial = desc
            break;
        }
        self.elemento.validacion.id = id
    }
    
    public func selectItem (valor: String, valormetadato: String)
    {
        self.guardarValor(desc: valor, id: valormetadato)
        self.setEdited(v: valor)
        if self.filtroCombo.count > 0{
            DispatchQueue.main.async {
                self.formDelegate?.updateDataComboDinamico(idsCombo: self.filtroCombo)
            }
        }
        
        // Esquema
        if self.atributos?.configjson != "" {
            do{
                let esquemaDict : [String: String] = try JSONSerializer.toDictionary(self.atributos?.configjson ?? "") as! [String : String]
                if esquemaDict.count > 0{
                    if self.datosCatalogo?.Table.count ?? 0 > 0 {
                        for fila in (self.datosCatalogo!.Table) {
                            let auxIdFila = fila[self.atributos?.valorid ?? ""] ?? ""
                            if "\(auxIdFila)" == self.elemento.validacion.id {
                                for esquema in esquemaDict {
                                    if let value = fila[esquema.key] as? String{
                                        _ = self.formDelegate?.resolveValor(esquema.value , "asignacion", value , nil)
                                    }
                                    if let value = fila[esquema.key] as? Int{
                                        _ = self.formDelegate?.resolveValor(esquema.value , "asignacion", String(value) , nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }catch{ }
        }
    }
    
    public func reloadCheck(lista:[String] ) {
        if valueOpen { self.valueInit = row.value ?? (txtInput.text ?? "") }
        clearList()
        lista.forEach {
            let val = String($0.split(separator: "|").first ?? "")
            let id = String($0.split(separator: "|").last ?? "")
            
            let cell = CustomView()
            var intID = 0
            if (Int(string: id) != nil) {
                intID = Int(string: id) ?? 0
            } else {
                intID = self.arrayId.count
                self.arrayId.append(id);
            }
            cell.data = CustomData(title: "\(val)\t", id: intID, tipo: self.atributos?.tipolista ?? "combo")
            cell.constraintsForComboDinamicoConfiguration()
            
            cell.btnCheck.addTarget(self, action: #selector(ComboDinamicoCell.selectedButton(radioButton:)), for: .touchUpInside)
            
            DispatchQueue.main.async {
                cell.imageInList.isHidden = true
            }
            if lista.first == $0 {
                self.gralButton = cell.btnCheck
                if lista.count == 1 && (atributos?.tipolista ?? "") == "radio" {
                    self.gralButton.isSelected = true
                    self.selectItem(valor: val, valormetadato: id)
                }
            } else {
                self.otherButtons.append(cell.btnCheck)
                self.gralButton.otherButtons = otherButtons;
            }
            self.stackButtons.addArrangedSubview(cell)
        }
        let heightChecks = CGFloat(45 * (lista.count))
        self.stackButtons.heightAnchor.constraint(equalToConstant: heightChecks).isActive = true
       // self.heightHeaderCell = self.heightHeaderCell + self.heightChecks + 36.0
        // Sets a height for the stack view that contain the cell.
       // setVariableHeight(Height: self.heightHeaderCell)
        
        if valueOpen {
            setEdited(v: self.valueInit)
        }
    }
    
    @objc @IBAction public func selectedButton(radioButton : DLRadioButton) {
        self.valueOpen = false
        var listRowDesc = ""
        var listRowId = ""
        let isSelectOK = radioButton.selectedButtons().count > 0 ? true : false
        
        if isSelectOK {
            for button in radioButton.selectedButtons() {
                if self.arrayId.isEmpty {
                    listRowId = listRowId != "" ? "\(listRowId),\(button.tag)" : "\(button.tag)"
                } else {
                    let auxID = self.arrayId[button.tag] as? String ?? ""
                    listRowId = listRowId != "" ? "\(listRowId),\(auxID)" : "\(auxID)"
                }
                listRowDesc = listRowDesc != "" ? "\(listRowDesc),\(button.titleLabel!.text!)" : "\(button.titleLabel!.text ?? "")"
            }
            self.selectItem(valor: listRowDesc, valormetadato: listRowId)
        } else {
            let alert = UIAlertController(
                title: "alrt_warning".langlocalized(),
                message: "elemts_radio_range".langlocalized(),
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "alrt_accept".langlocalized(), style: .default, handler: nil))
            (row as? ComboDinamicoRow)?.cell.formCell()?.formViewController()?.present(alert, animated: true, completion: nil)
            
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato  = ""
            self.elemento.validacion.valormetadatoinicial = ""
            self.elemento.validacion.id = ""
            setEdited(v: "")
            triggerEvent("alcambiar")
            triggerRulesOnAction("change")
        }
    }
    
    private func getCatRemotoFiltros() {
        if ConfigurationManager.shared.utilities.isConnected(){
            ConfigurationManager.shared.catRemotoUIAppDelegate.CatDocId = Int(self.atributos?.catalogofuente ?? "0") ?? 0
            ConfigurationManager.shared.catRemotoUIAppDelegate.Top = self.atributos?.cantidadopciones ?? 0
            // Servicio que se ejecuta para optener las listas
            let response = self.sdkAPI?.DGSDKdownloadCatRemoto(delegate: self)
            if response != nil {
                self.datosCatalogo = response!
                if self.datosCatalogo?.Table.count ?? 0 > 0 {
                    (row as? ComboDinamicoRow)?.cell.setMessage("", .success)
                    var auxValorFila = ""
                    var auxIdFila = ""
                    
                    self.clearList()
                    
                    if (self.atributos?.valorid ?? "").count != 0 && (self.atributos?.valordescripcion ?? "").count != 0 {
                        var auxLista : [String] =  []
                        for fila in (self.datosCatalogo!.Table) {
                            let keysData = (self.atributos?.valordescripcion ?? "").split(separator: ",")
                            for keyD in keysData {
                                auxValorFila = "\(auxValorFila) \(String(describing: fila["\(keyD)"] ?? ""))"
                            }
                            let keyID = self.atributos?.valorid ?? ""
                            auxIdFila = String(describing: fila[keyID] ?? "")
                            
                            auxLista.append(String("\(auxValorFila)|\(auxIdFila)"))
                            auxValorFila = ""
                        }
                        
                        if self.atributos?.tipolista != "combo" && !auxLista.isEmpty {
                            self.reloadCheck(lista: auxLista)
                        } else {
                            // Apenas se asigna valor a listItemsCombo
                            self.setListItemsInCombo = auxLista
                            if !valueOpen {
                                if self.setListItemsInCombo.count == 1 {
                                    let item = self.setListItemsInCombo[0]
                                    let val = String(item.split(separator: "|").first ?? "")
                                    let id = String(item.split(separator: "|").last ?? "")
                                    self.selectItem(valor: val, valormetadato: id)
                                }
                            }
                            var container : Bool = false
                            var rowItem = String(row.value ?? "")
                            if rowItem.first == " " {  rowItem.removeFirst() }
                            self.setListItemsInCombo.forEach({ item in
                                let val = String(item.split(separator: "|").first ?? "")
                                if val == rowItem { container = true}
                            })
                            if !container && String(row.value ?? "") != "" && (self.setListItemsInCombo.count > 1) {
                                setEdited(v: "")
                            }
                        }
                    }
                } else {
                    self.clearList()
                    self.elemento.validacion.id = ""
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                    self.elemento.validacion.valormetadatoinicial = ""
                    self.setEdited(v: "")
                }
            } else {
                self.clearList()
                self.elemento.validacion.id = ""
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
                self.elemento.validacion.valormetadatoinicial = ""
                self.setEdited(v: "")
            }
            (row as? ComboDinamicoRow)?.updateCell()
            (row as? ComboDinamicoRow)?.cell.formCell()?.formViewController()?.tableView.reloadData()
        } else{
            let rightView = UIImageView(image: UIImage(named: "warning_sign", in: Cnstnt.Path.framework, compatibleWith: nil))
            let bannerNew = NotificationBanner(title: "", subtitle: "alrt_error_internet".langlocalized(), leftView: nil, rightView: rightView, style: .danger, colors: nil)
            bannerNew.show()
        }
    }
    
    public func queryValue (isRobot : Bool = false) {
        if ConfigurationManager.shared.utilities.isConnected(){
            ConfigurationManager.shared.catRemotoUIAppDelegate.CatDocId = Int(self.atributos?.catalogofuente ?? "0") ?? 0
            ConfigurationManager.shared.catRemotoUIAppDelegate.Top = self.atributos?.cantidadopciones ?? 0
     // Servicio que se ejecuta para optener las listas
            let response = self.sdkAPI?.DGSDKdownloadCatRemoto(delegate: self)
            if response != nil{
                self.datosCatalogo = response!
                if self.datosCatalogo?.Table.count ?? 0 > 0 {
                    (row as? ComboDinamicoRow)?.cell.setMessage("", .success)
                    var auxValorFila = ""
                    var auxIdFila = ""
                    self.clearList ()
                    if (self.atributos?.valorid ?? "").count != 0 && (self.atributos?.valordescripcion ?? "").count != 0 {
                        var auxLista : [String] =  []
                        for fila in (self.datosCatalogo!.Table) {
                            let keysData = (self.atributos?.valordescripcion ?? "").split(separator: ",")
                            for keyD in keysData {
                                auxValorFila = "\(auxValorFila) \(String(describing: fila["\(keyD)"] ?? ""))"
                            }
                            let keyID = self.atributos?.valorid ?? ""
                            auxIdFila = String(describing: fila[keyID] ?? "")
                            
                            auxLista.append(String("\(auxValorFila)|\(auxIdFila)"))
                            auxValorFila = ""
                        }
                        
                        if self.atributos?.tipolista != "combo" && !auxLista.isEmpty {
                            self.reloadCheck(lista: auxLista)
                        } else {
                            self.listItemsCombo = auxLista
                            if !valueOpen {
                                if self.setListItemsInCombo.count == 1 {
                                    let item = self.setListItemsInCombo[0]
                                    let val = String(item.split(separator: "|").first ?? "")
                                    let id = String(item.split(separator: "|").last ?? "")
                                    self.selectItem(valor: val, valormetadato: id)
                                }
                            }
                            var container : Bool = false
                            var rowItem = String(row.value ?? "")
                            if rowItem.first == " " {  rowItem.removeFirst() }
                            self.listItemsCombo.forEach({ item in
                                let val = String(item.split(separator: "|").first ?? "")
                                if val == rowItem { container = true}
                            })
                            if !container && String(row.value ?? "") != "" && (self.listItemsCombo.count > 1) {
                                setEdited(v: "")
                            }
                        }
                    }
                } else {
                    self.clearList()
                    self.elemento.validacion.id = ""
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                    self.elemento.validacion.valormetadatoinicial = ""
                    self.setEdited(v: "")
                }
            } else {
                self.clearList()
                self.elemento.validacion.id = ""
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
                self.elemento.validacion.valormetadatoinicial = ""
                self.setEdited(v: "")
                
            }
            (row as? ComboDinamicoRow)?.updateCell()
            (row as? ComboDinamicoRow)?.cell.formCell()?.formViewController()?.tableView.reloadData()
        }else{
            let rightView = UIImageView(image: UIImage(named: "warning_sign", in: Cnstnt.Path.framework, compatibleWith: nil))
            let bannerNew = NotificationBanner(title: "", subtitle: "alrt_error_internet".langlocalized(), leftView: nil, rightView: rightView, style: .danger, colors: nil)
            bannerNew.show()
        }
    }
    
    func clearList() {
        if self.atributos?.tipolista != "combo" {
            self.gralButton = DLRadioButton()
            self.otherButtons = [];
            let auxViews = self.stackButtons.arrangedSubviews
            auxViews.forEach{ viewBtn in
                self.stackButtons.removeArrangedSubview(viewBtn)
                viewBtn.removeFromSuperview()
            }
        } else {
            self.listItemsCombo = []
        }
    }
    
    public func settingValuesSync()->Promise<Bool>{
        return Promise<Bool>{ resolve, reject in
            if !ConfigurationManager.shared.utilities.checkNetwork() {
                reject(ConfigurationManager.shared.utilities.errorGen(Domain.sdk, ApiErrors.connection, false, "Revise su conexión a Internet.", "apimng_log_nodata"))
                self.banner = NotificationBanner(title: "No se puede consultar el catálogo, favor de consultarlo mas tarde")
            }
            self.settingValuesCombo()
            resolve(true)
        }
    }
    
    public func settingValuesCombo (isRobot : Bool = false) {
        let auxfiltros : FEVariableData = ConfigurationManager.shared.variablesDataUIAppDelegate.ListCatDocumento.first(where: {$0.UserId == Int(self.atributos?.catalogofuente ?? "0")}) ?? FEVariableData()
        
        if auxfiltros.UserId != 0
        {   do {
                let arrayFiltros = try JSONSerialization.jsonObject(with: auxfiltros.Valor.data(using: .utf8)!, options: .mutableContainers)
                var filtrosCombo = Array<FECatRemotoFiltros>()
                for filtros in (arrayFiltros as! NSArray)
                {   if let filtro = filtros as? NSDictionary
                    {
                        let auxFiltro : FECatRemotoFiltros = FECatRemotoFiltros()
                        auxFiltro.Operador = filtro["Operador"] as! String
                        auxFiltro.Tabla = filtro["Tabla"] as! String
                        var idFiltro = ""
                        self.atributos?.camposfiltros.forEach {
                            let keyFiltro =  String(describing: filtro["NombreCampo"] ?? "").replacingOccurrences(of: " ", with: "")
                            idFiltro = String(describing: $0.value(forKey: keyFiltro) ?? "") }
                    
                    let valRow = self.formDelegate?.valueMetaElementRow(idFiltro, nil)
                    auxFiltro.Valor = valRow?.value ?? ""
                    
                    if auxFiltro.Valor == ""{
                        // We identify the ID Element
                        // Detect if is already in the array
                        switch valRow?.row {
                        case is TextoRow:
                            let comboRow = (valRow!.row as! TextoRow)
                            var isIn = false
                            for filtro in comboRow.cell.filtroCombo{
                                if filtro.row.tag == comboRow.tag ?? ""{ isIn = true }
                            }
                            if !isIn{ comboRow.cell.filtroCombo.append((id: valRow!.row.tag ?? "", row: row)) }
                            break;
                        case is ComboDinamicoRow:
                            let comboRow = (valRow!.row as! ComboDinamicoRow)
                            var isIn = false
                            for filtro in comboRow.cell.filtroCombo{
                                if filtro.row.tag == comboRow.tag ?? ""{ isIn = true }
                            }
                            if !isIn{ comboRow.cell.filtroCombo.append((id: valRow!.row.tag ?? "", row: row)) }
                        default: break;
                        }
                    }
                    filtrosCombo.append(auxFiltro)
                    }
                }
                ConfigurationManager.shared.catRemotoUIAppDelegate.Filtros = filtrosCombo
            } catch{ }
        }
        if self.atributos?.campobusqueda ?? "" != "" {
            var filtrosCombo = ConfigurationManager.shared.catRemotoUIAppDelegate.Filtros
            let auxFiltro : FECatRemotoFiltros = FECatRemotoFiltros()
            auxFiltro.Operador = "LIKE"
            auxFiltro.Tabla = self.atributos?.campobusqueda ?? ""
            auxFiltro.Valor = ""
            filtrosCombo.append(auxFiltro)
            ConfigurationManager.shared.catRemotoUIAppDelegate.Filtros = filtrosCombo
        }
        self.filtrosOK = ConfigurationManager.shared.catRemotoUIAppDelegate.Filtros
        self.getCatRemotoFiltros()
        self.queryValue(isRobot: isRobot)
    }
    
   @objc func onClickDropButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            let datosCatalogo = self.datosCatalogo
            if datosCatalogo?.Table.count ?? 0 > 0 {
                let controller = ModalListaViewController()
                controller.atributosComboD = self.atributos
                controller.rowCombo = self
                controller.listItems = self.setListItemsInCombo
                controller.formDelegate = self.formDelegate
                controller.buscar = true
                controller.idsItemsSelect = self.elemento.validacion.valormetadato
                controller.configure (onFinishedAction: { [unowned self] result in
                    switch result {
                    case .success( _):
                        let values = controller.valueItemsSelect
                        let ids = controller.idsItemsSelect
                        print("values \(values)")
                        // values es el valor que se seleccionó
                        print("ids \(ids)")
                        self.valueOpen = false
                        self.selectItem(valor: values, valormetadato: ids)
                        break
                    case .failure(let error):
                        print("ERROR BACK SELECT COMBO: \(error)")
                        break
                    }
                })
                let presenter = Presentr(presentationType: .fullScreen)
                self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
            } else { // Datos Catalogo is empty
                if !self.banner.isDisplaying {
                    self.banner = NotificationBanner(title: "No se puede consultar el catálogo, favor de consultarlo mas tarde")
                    self.banner.show()
                }
            }
        }
    }
    
    // MARK: - APIDELEGATE
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) {  }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendError(message: String, error: enumErrorType) {  }
    public func didSendResponse(message: String, error: enumErrorType) {   }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {   }
}

// MARK: - OBJECTFORMDELEGATE
extension ComboDinamicoCell: ObjectFormDelegate{
    
    public func toogleToolTip(_ help: String) { }
    public func setTextStyle(_ style: String){ }
    public func setDecoration(_ decor: String){ }
    public func setAlignment(_ align: String){ }
    public func setTitleText(_ text:String){ }
    public func setSubtitleText(_ text:String){ }
    public func setInfo(){ }
    public func setOcultarTitulo(_ bool: Bool){ }
    public func setOcultarSubtitulo(_ bool: Bool){ }
    public func setRequerido(_ bool: Bool){}
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){
        self.headersView.setMessage(string)
    }
    // MARK: Set - Height From Titles
    public func setHeightFromTitles(){}
    
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "ComboDinamico"
        est?.NombrePagina = (self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
        est?.OrdenCampo = atributos?.ordencampo ?? 0
        est?.PaginaID = Int(atributos?.elementopadre.replaceFormElec() ?? "0") ?? 0
        est?.FechaEntrada = ConfigurationManager.shared.utilities.getFormatDate()
        est?.Latitud = ConfigurationManager.shared.latitud
        est?.Longitud = ConfigurationManager.shared.longitud
        est?.Usuario = ConfigurationManager.shared.usuarioUIAppDelegate.User
        est?.Dispositivo = UIDevice().model
        est?.NombrePlantilla = (self.formDelegate?.getPlantillaTitle() ?? "").replaceLineBreak()
        est?.Sesion = ConfigurationManager.shared.guid
        est?.PlantillaID = 0
        est?.CampoID = Int(elemento._idelemento.replaceFormElec()) ?? 0
    }
    public func setEstadisticaV2(){
        if self.estV2 != nil { return }
        self.estV2 = FEEstadistica2()
        if self.atributos != nil{
            self.estV2?.IdElemento = elemento._idelemento
            self.estV2?.Titulo = atributos?.titulo ?? ""
            self.estV2?.Pagina = (self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
            self.estV2?.IdPagina = self.formDelegate?.getPageID(atributos?.elementopadre ?? "") ?? ""
        }
        self.estV2?.ValorFinal = elemento.validacion.valormetadato
    }
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) {}
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){ }
    // MARK: Set - TypeList
    public func setTypeList(_ typeList: String) {
        if typeList != "combo" {
            comboBoxSelection.isHidden = true
        }else {
            self.txtInput.text = "Es necesario seleccionar una opción"
            comboBoxSelection.isHidden = false
        }
    }
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil {
            self.elemento.validacion.needsValidation = atributos?.requerido ?? false
            if atributos?.requerido ?? false {
                var rules = RuleSet<String>()
                rules.add(rule: ReglaRequerido())
                self.row.add(ruleSet: rules)
            }
            self.headersView.setRequerido(atributos?.requerido ?? false)
        }
    }
    // MARK: Set - MinMax
    public func setMinMax(){ }
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){ }
    // MARK: Set - Habilitado
    public func setHabilitado(_ bool: Bool){
        self.elemento.validacion.habilitado = bool
        if bool{
            self.bgHabilitado.isHidden = true;
            self.row.baseCell.isUserInteractionEnabled = true
            self.row.disabled = false
        }else{
            self.bgHabilitado.isHidden = false;
            self.row.baseCell.isUserInteractionEnabled = false
            self.row.disabled = true
        }
        self.row.evaluateDisabled()
    }
    // MARK: Set - Edited
    public func setEdited(v: String){
        if v == "" || v == "--Seleccione--" {
            self.txtInput.text = "Es necesario seleccionar una opción"
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            row.value = nil
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            return
        }
        self.headersView.lblTitle.textColor = UIColor.black
        txtInput.text = v
        row.value = v
        
        if atributos?.tipolista != "combo" && gralButton.selectedButtons().isEmpty
        {
            let temValueOpen = self.valueOpen
            if gralButton.titleLabel!.text == nil{ return }
            let idGral = self.arrayId.isEmpty ? "\(gralButton.tag)" : self.arrayId[gralButton.tag] as? String ?? ""
            gralButton.isSelected = (v.split(separator: ",")).contains(where: { (String($0) == (gralButton.titleLabel!.text!)) || (String($0) == idGral)})
            for radioButton in self.gralButton.otherButtons{
                let idOthers = self.arrayId.isEmpty ? "\(radioButton.tag)" : self.arrayId[radioButton.tag] as? String ?? ""
                radioButton.isSelected = (v.split(separator: ",")).contains(where: { (String($0) == (radioButton.titleLabel!.text!)) || (String($0) == idOthers)})
            }
            self.selectedButton(radioButton: self.gralButton)
            self.valueOpen = temValueOpen
        } else
        {   // MARK: - Setting estadisticas
            setEstadistica()
            est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
            est!.Resultado = v.replaceLineBreak()
            est!.KeyStroke += 1
            elemento.estadisticas = est!
            let fechaValorFinal = Date.getTicks()
            self.setEstadisticaV2()
            self.estV2!.FechaValorFinal = fechaValorFinal
            self.estV2!.ValorFinal = v.replaceLineBreakEstadistic()
            self.estV2!.Cambios += 1
            elemento.estadisticas2 = estV2!
            
            row.validate()
            self.updateIfIsValid()
            triggerEvent("")
            triggerRulesOnChange(nil)
            triggerRulesOnAction(nil)
        }
    }
    public func setEdited(v: String, isRobot: Bool) { }
    // MARK: Set - Visible
    public func setVisible(_ bool: Bool){
        self.elemento.validacion.visible = bool
        if self.atributos != nil{
            self.atributos?.visible = bool
            if bool {
                self.row.hidden = false
            }else{
                self.row.hidden = true
            }
        }
        self.row.evaluateHidden()
    }
    // MARK: Set - Validation
    public func resetValidation(){
        if atributos != nil{
            self.elemento.validacion.needsValidation = atributos?.requerido ?? false
        }
    }
    // MARK: Set - Default Value
    public func setDefaultValue(){
        var rules = RuleSet<String>()
        rules.add(rule: ReglaListaValor())
        self.layoutIfNeeded()
        self.row.add(ruleSet: rules)
    }
    
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        if isDefault{ // Setting Default
            DispatchQueue.main.async {
                self.headersView.setMessage("")
                self.layoutIfNeeded()
            }
            resetValidation()
            self.elemento.validacion.validado = false
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato = ""
            self.elemento.validacion.valormetadatoinicial = ""
            return
        }
        if row.isValid{
            // Setting row as valid
            if row.value == nil{
                DispatchQueue.main.async {
                    self.headersView.setMessage("")
                    self.layoutIfNeeded()
                }
                self.elemento.validacion.validado = false
            }else{
                DispatchQueue.main.async {
                    self.headersView.setMessage("")
                    self.layoutIfNeeded()
                }
                resetValidation()
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                }else{
                    self.elemento.validacion.validado = false
                }
            }
        }else{
            DispatchQueue.main.async {
                if (self.row.validationErrors.count) > 0 && self.datosCatalogo != nil {
                    self.headersView.setMessage("  \(self.row.validationErrors[0].msg)  ")
                } else {
                    //Si esta vacio no debe ser requerido:
                    self.atributos?.requerido = false
                    self.headersView.lblRequired.isHidden = true
                }
                self.layoutIfNeeded()
            }
            self.elemento.validacion.needsValidation = true
            self.elemento.validacion.validado = false
        }
    }
    // MARK: Set - Mode List/Table
    public func setMode(_ modeTable: Bool)
    {
        if modeTable
        {
            //agregar código para que see vea tipo columnas(tabla)
        }
    }
    
    // MARK: Events
    public func triggerEvent(_ action: String)  {   }
    
    // MARK: Excecution for RulesOnProperties
    public func setRulesOnProperties(){
        if rulesOnProperties.count == 0{ return }
        if self.atributos?.habilitado ?? false{ triggerRulesOnProperties("enabled") }else{ triggerRulesOnProperties("notenabled") }
        if self.atributos?.visible ?? false{
            triggerRulesOnProperties("visible")
            triggerRulesOnProperties("visiblecontenido")
        }else{
            triggerRulesOnProperties("notvisible")
            triggerRulesOnProperties("notvisiblecontenido")
        }
    }
    
    // MARK: Rules on properties
    public func triggerRulesOnProperties(_ action: String){
        if rulesOnProperties.count == 0{ return }
        for rule in rulesOnProperties{
            if rule.vrb == action{
                _ = self.formDelegate?.obtainRules(rString: rule.xml.name, eString: row.tag, vString: rule.vrb, forced: false, override: false)
            }
        }
    }
    
    // MARK: Excecution for RulesOnChange
    public func setRulesOnChange(){ }
    
    // MARK: Rules on change
    public func triggerRulesOnChange(_ action: String?){
        if rulesOnChange.count == 0{ return }
        for rule in rulesOnChange{
            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: action, forced: false, override: false)
        }
    }
    // MARK: Rules on action
    public func triggerRulesOnAction(_ action: String?){
        if rulesOnAction.count == 0{ return }
        for rule in rulesOnAction{
            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: action, forced: false, override: false)
        }
    }
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){ }
}

extension ComboDinamicoCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{
        return self.headersView.lblMessage.text ?? ""
    }
    public func getRowEnabled()->Bool{
        return self.row.baseCell.isUserInteractionEnabled
    }
    public func getRequired()->Bool{
        return self.headersView.lblRequired.isHidden
    }
    public func getTitleLabel()->String{
        return self.headersView.lblTitle.text ?? ""
    }
    public func getSubtitleLabel()->String{
        return self.headersView.lblSubtitle.text ?? ""
    }
    public func getTxtInput()->String{
        return self.txtInput.text ?? ""
    }
}
