import Eureka
import UIKit

// MARK: ListaCell
open class ListaCell: Cell<String>, CellType {
    
    lazy var headersView: FEHeaderView = {
        let header = FEHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
    lazy var listBoxSelection: UIView = {
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
        stackBody.addArrangedSubview(listBoxSelection)
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
    public var elemento = Elemento()
    public var atributos: Atributos_lista?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var catalogoItems : Array<FEItemCatalogo> = [FEItemCatalogo]() //Original
    public var catOptionCheck : Array<FEItemCatalogo> = [FEItemCatalogo]() //Ordenado
    public var gralButton : DLRadioButton = DLRadioButton()
    public var listItemsLista : [String] =  []
    
    // PRIVATE
    var banner = NotificationBanner(title: "No hay elementos", subtitle: "Revise la configuracion de la plantilla.", leftView: nil, rightView: nil, style: .success, colors: nil)
    var otherButtons : [DLRadioButton] = [];
    var heightChecks: CGFloat = 0.0
    var heightHeaderCell : CGFloat = 0.0

    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
    }
    
    // MARK: SETTING
    /// SetObject for ListaRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
    
        elemento = obj
        atributos = obj.atributos as? Atributos_lista
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        
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
        headersView.viewInfoHelp = (row as? ListaRow)?.cell.formCell()?.formViewController()?.tableView
        
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
            break;
        case "descid":
            self.elemento.validacion.valor = id
            self.elemento.validacion.valormetadato = desc
            break;
        case "iddesc":
            self.elemento.validacion.valor = desc
            self.elemento.validacion.valormetadato  = id
            break;
        case "descdesc":
            self.elemento.validacion.valor = desc
            self.elemento.validacion.valormetadato = desc
            break;
        default:
            self.elemento.validacion.valor = id
            self.elemento.validacion.valormetadato = desc
            break;
        }
        self.elemento.validacion.id = id
    }
    
    public func seleccionarValor (desc: String, id: String, isRobot: Bool)
    {
        // MARK: Esquema
        if self.atributos?.configjson != "" && self.atributos?.configjson != "{}"{
            do{
                let esquemaDict = try JSONSerialization.jsonObject(with: self.atributos?.configjson.data(using: .utf8)! ?? Data(), options: []) as? [String: Any]
                if esquemaDict?.count ?? 0 > 0{
                    for catalogo in self.catalogoItems{
                        if catalogo.CatalogoId == Int(id){
                            let jsonDict = try JSONSerialization.jsonObject(with: catalogo.Json.data(using: .utf8)!, options: []) as? [[String: Any]]
                            if jsonDict?.count ?? 0 > 0{
                                for jDict in jsonDict!{
                                    let camp = jDict["Campo"] as? String
                                    let val = jDict["Valor"] as? String
                                    
                                    for esquema in esquemaDict!{
                                        if camp == esquema.key{
                                            do {
                                                var formula = try JSONSerialization.jsonObject(with: (esquema.value as! String).data(using: .utf8)!, options: []) as? [NSDictionary]
                                                let f1:NSDictionary = [ "value": "=", "type": "equal" ]
                                                let f2:NSDictionary = [ "value": "\(val ?? "")", "type": "character" ]
                                                formula?.append(f1)
                                                formula?.append(f2)
                                                if let theJSONData = try? JSONSerialization.data(withJSONObject: formula!, options: []) {
                                                    let theJSONText = String(data: theJSONData, encoding: .ascii)
                                                    _ = self.formDelegate?.recursiveTokenFormula(theJSONText, nil, "asignacion", false)
                                                }
                                            } catch{
                                                _ = self.formDelegate?.resolveValor(esquema.value as? String ?? "", "asignacion", val ?? "" , nil)
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    
                }
            }catch{ }
        }
        
        // Changing values if has a parent
        if self.atributos?.cascadahijo != ""{
            if let row: ListaRow = self.formDelegate?.getElementByIdInAllForms(self.atributos?.cascadahijo ?? "") as? ListaRow {
                // TODO: DETECT IF CASCADA GOES TO COMBO; CHECKBOX OR RADIO
                if row.cell.atributos?.tipolista == "combo"{
                    // Getting configurations
                    var cascadaArray = Array<String>()
                    cascadaArray = self.atributos?.configuracioncascada.split{$0 == ";"}.map(String.init) ?? []
                    for cascada in cascadaArray{
                        let values = cascada.split{$0 == ":"}.map(String.init)
                        if values[0] == id {
                            let list = row.cell.listItemsLista
                            let arrayValues = values[1].split{$0 == ","}.map(String.init)
                            var listItemsCascada : [String] =  []
                            for (_, val) in arrayValues.sorted().enumerated(){
                                list.forEach({item in
                                    if String(item.split(separator: "|").last ?? "") ==  "\(val)"{
                                        listItemsCascada.append(item)
                                    }
                                })
                            }
                            if !listItemsCascada.isEmpty{
                                row.cell.listItemsLista = listItemsCascada
                                if listItemsCascada.count == 1{
                                    let item = listItemsCascada[0]
                                    let valRobot = String(item.split(separator: "|").first ?? "")
                                    let idRobot = String(item.split(separator: "|").last ?? "")
                                    row.cell.seleccionarValor(desc: valRobot, id: idRobot, isRobot: false)
                                }
                            }
                            break;
                        }else{
                            row.cell.guardarValor(desc: "", id: "")
                            row.cell.setEdited(v: "")
                            row.cell.txtInput.text = "Es necesario seleccionar una opción"
                            row.cell.listItemsLista =  []
                            for catalogo in row.cell.catalogoItems {
                                let item = "\(catalogo.Descripcion)|\(String(catalogo.CatalogoId))"
                                row.cell.listItemsLista.append(item)
                            }
                        }
                    }
                    row.updateCell()
                    row.cell.formCell()?.formViewController()?.tableView.reloadData()
                } else {
                    print("Añadir configuracion para heck o radio. creo")
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
            self.guardarValor(desc: desc, id: id)
            self.setEdited(v: desc, isRobot: isRobot)
        })
    }
    
    @objc @IBAction public func selectedButton(radioButton : DLRadioButton, isRobot: Bool = true) {
        var listRowDesc = ""
        var listRowId = ""
        var isSelectOK = false
        
        if radioButton.selectedButtons().count > 0
        {
            if atributos?.todasopcionesrequeridas ?? false && atributos?.requerido ?? false
            {   if radioButton.selectedButtons().count == self.catOptionCheck.count {
                    isSelectOK = true
                } else if ((atributos!.maxopcionesseleccionar != 0) && (atributos!.maxopcionesseleccionar == atributos!.minopcionesseleccionar) && (atributos!.maxopcionesseleccionar == self.catOptionCheck.count) && (radioButton.selectedButtons().count < self.catOptionCheck.count))
                {   isSelectOK = true
                    let alert = UIAlertController(
                        title: "alrt_warning".langlocalized(),
                        message: "elemts_radio".langlocalized(),
                        preferredStyle: UIAlertController.Style.alert
                    )
                    alert.addAction(UIAlertAction(title: "alrt_accept".langlocalized(), style: .default, handler: nil))
                    (row as? ListaRow)?.cell.formCell()?.formViewController()?.present(alert, animated: true, completion: nil)
                }
            }else {
                if radioButton.selectedButtons().count >= atributos?.minopcionesseleccionar ?? 0
                {
                    atributos?.maxopcionesseleccionar = atributos?.maxopcionesseleccionar != 0 ? atributos?.maxopcionesseleccionar ?? 0 : self.catOptionCheck.count
                    if radioButton.selectedButtons().count <= atributos?.maxopcionesseleccionar ?? self.catOptionCheck.count {
                        isSelectOK = true   }
                }
            }
        } else
        {
            self.guardarValor(desc: "", id: "")
            setEdited(v: "sinSelección", isRobot: isRobot)
        }
        
        if isSelectOK
        {   for button in radioButton.selectedButtons()
            {
                listRowId = listRowId != "" ? "\(listRowId),\(button.tag)" : "\(button.tag)"
                listRowDesc = listRowDesc != "" ? "\(listRowDesc),\(button.titleLabel!.text ?? "")" : "\(button.titleLabel!.text ?? "")"
            }
            self.guardarValor(desc: listRowDesc, id: listRowId)
            setEdited(v: listRowDesc, isRobot: isRobot)
        } else
        {
            if radioButton.selectedButtons().count >= atributos!.maxopcionesseleccionar
            {   (radioButton.selectedButtons().first)?.isSelected = false   }
            let alert = UIAlertController(
                title: "alrt_warning".langlocalized(),
                message: "elemts_radio_range".langlocalized(),
                preferredStyle: UIAlertController.Style.alert
            )
            
            alert.addAction(UIAlertAction(title: "alrt_accept".langlocalized(), style: .default, handler: nil))
            (row as? ListaRow)?.cell.formCell()?.formViewController()?.present(alert, animated: true, completion: nil)
            triggerRulesOnChange(nil)
            triggerEvent("alcambiar")
            triggerRulesOnAction("change")
        }
    }
    
    @objc func onClickDropButton(_ sender: UIButton) {
        if listItemsLista.count > 0 {
            let controller = ModalListaViewController()
            controller.atributosLista = self.atributos
            controller.rowLista = self
            controller.listItems = self.listItemsLista
            controller.formDelegate = self.formDelegate
            controller.buscar = self.atributos?.modobusqueda ?? false
            controller.idsItemsSelect = self.elemento.validacion.id
            controller.configure (onFinishedAction: { [unowned self] result in
                switch result {
                    case .success( _):
                        let values = controller.valueItemsSelect
                        let ids = controller.idsItemsSelect
                        self.seleccionarValor(desc: values, id: ids, isRobot: false)
                        break
                    case .failure(let error):
                        print("ERROR BACK SELECT LISTA: \(error)")
                     break
                }
            })
                
            let presenter = Presentr(presentationType: .fullScreen)
            self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
        }else {
            if !self.banner.isDisplaying {
                self.banner.show()
            }
        }
    }
}

// MARK: - OBJECTFORMDELEGATE
extension ListaCell: ObjectFormDelegate{
    
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
    public func setHeightFromTitles(){ }
    
    
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Lista"
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
        self.atributos?.habilitado = bool
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
    public func setEdited(v: String){ }
    public func setEdited(v: String, isRobot: Bool = false){
        if (v == "") || (v == "--Seleccione--") || (v == "sinSelección") { txtInput.text = "Es necesario seleccionar una opción" }
        if v == "" || v == "--Seleccione--" {
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            row.value = nil
            return }
        row.value = v != "sinSelección" ? v : ""
        if v == "sinSelección" {
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            return }
        txtInput.text = v
        if atributos?.tipolista != "combo" && gralButton.selectedButtons().isEmpty && v != "sinSelección"
        {
            if gralButton.titleLabel!.text == nil{ return }
            if (v.contains(gralButton.titleLabel!.text!)) || (v.contains("\(gralButton.tag)")){
                gralButton.isSelected = true;
            }
            for radioButton in self.gralButton.otherButtons{
                if (v.contains(radioButton.titleLabel!.text!)) || (v.contains("\(radioButton.tag)")){
                    radioButton.isSelected = true;  }
            }
            self.selectedButton(radioButton: self.gralButton, isRobot: isRobot)
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
            
            self.headersView.lblTitle.textColor = UIColor.black
            row.validate()
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            if isRobot{ return }
            triggerEvent("alcambiar")
            triggerRulesOnAction("change")
            
        }

    }
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
        self.headersView.lblMessage.isHidden = true
        if isDefault{ // Setting Default
            DispatchQueue.main.async {
                self.headersView.setMessage("")
                self.layoutIfNeeded()
            }
            resetValidation()
            self.elemento.validacion.validado = false
            self.guardarValor(desc: "", id: "")
            return
        }
        if row.isValid{ // Setting row as valid
            if row.value == nil{
                DispatchQueue.main.async {
                    self.headersView.setMessage("")
                    self.layoutIfNeeded()
                }
                self.elemento.validacion.validado = false
            }else{
                resetValidation()
                if row.isValid && (row.value != "" && row.value != "--Seleccione--") {
                    self.elemento.validacion.validado = true
                    self.headersView.setMessage("")
                }else{
                    self.elemento.validacion.validado = false
                    self.headersView.setMessage("rules_select".langlocalized())
                }
                self.layoutIfNeeded()
            }
        }else{
            // Throw the first error printed in the label
            DispatchQueue.main.async {
                if (self.row.validationErrors.count) > 0{
                    self.headersView.setMessage("  \(self.row.validationErrors[0].msg)  ")
                }
            }
            self.elemento.validacion.needsValidation = true
            self.elemento.validacion.validado = false
        }
    }
    
    // MARK: Set - TypeList
    public func setTypeList(_ typeList: String) {
        if typeList != "combo" {
            self.listBoxSelection.isHidden = true
            self.stackButtons.isHidden = false
            // Con combo, el Stack de Views no tendrá información.
            if !catalogoItems.isEmpty {
                switch self.atributos?.ordenitems {
                case "idasc":
                    self.catOptionCheck = catalogoItems.sorted(by: { (pl, pls) -> Bool in return pl.CatalogoId < pls.CatalogoId })
                    break;
                case "iddesc":
                    self.catOptionCheck = catalogoItems.sorted(by: { (pl, pls) -> Bool in return pl.CatalogoId > pls.CatalogoId })
                    break;
                case "alphaasc":
                    self.catOptionCheck = catalogoItems.sorted(by: { (pl, pls) -> Bool in return pl.Descripcion < pls.Descripcion })
                    break;
                case "alphadesc":
                    self.catOptionCheck = catalogoItems.sorted(by: { (pl, pls) -> Bool in return pl.Descripcion > pls.Descripcion })
                    break;
                default:
                    self.catOptionCheck = self.catalogoItems
                    break;
                }
                self.reloadCheck()
            }
        } else {
            self.txtInput.text = "Es necesario seleccionar una opción"
            self.listBoxSelection.isHidden = false
            self.stackButtons.isHidden = true
            if self.listItemsLista.count == 1 {
                let item = listItemsLista[0]
                let val = String(item.split(separator: "|").first ?? "")
                let id = String(item.split(separator: "|").last ?? "")
                self.seleccionarValor(desc: val, id: id, isRobot: false)
            }
        }
    }
    
    public func reloadCheck() {
        self.gralButton = DLRadioButton()
        self.otherButtons = [];
        let auxViews = self.stackButtons.arrangedSubviews
        auxViews.forEach{ viewBtn in
            self.stackButtons.removeArrangedSubview(viewBtn)
            viewBtn.removeFromSuperview()
        }
        for (index, option) in self.catOptionCheck.enumerated(){
            let cell = CustomView()
            var campoGlobal: Bool = false
            if option.Json != "" {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: option.Json.data(using: .utf8)!, options: []) as? [[String: Any]]
                    if jsonDict?.count ?? 0 > 0 {
                        for jDict in jsonDict! {
                            let campo = jDict["Campo"] as? String ?? ""
                            // Si campo viene vacío no se toma, Campo = ImagenFE
                            if campo != "" {
                                campoGlobal = true
                                let val = jDict["Valor"] as? String ?? ""
                                DispatchQueue.main.async {
                                    cell.imageInList.isHidden = false
                                }
                                if val == "" {
                                    DispatchQueue.main.async {
                                        cell.notContainImage()
                                    }
                                }
                                DispatchQueue.global(qos: .background).async {
                                    if val.contains("/") {
                                        // Draw a image when the value is a URL
                                        let urlStr = String.determineRelativeAndAbsoluteURL(url: val)
                                        cell.imageInList.DGPFetchImageByURL(url: urlStr)
                                    } else {
                                        // Draw image when the value is text
                                        let svgImage = val.replacingOccurrences(of: "fas fa-", with: "")
                                        if svgImage == "20" || svgImage == "300" {
                                            DispatchQueue.main.async {
                                                cell.notContainImage()
                                            }
                                        } else {
                                        DispatchQueue.main.async {
                                            cell.imageInList.image = UIImage(named: svgImage, in: Cnstnt.Path.framework, compatibleWith: nil)
                                        }
                                        }
                                    }
                                }
                            } else { // Campo is empty
                                DispatchQueue.main.async {
                                    cell.notContainImage()
                                }
                            }
                        }
                    }
                } catch { print("Error to serializar") }
            } else { // There are no a result in the JSON
                DispatchQueue.main.async {
                    cell.notContainImage()
                }
            }
            
            let valList = option.Descripcion
            cell.data = CustomData(title: valList, id: option.CatalogoId, tipo: atributos?.tipolista ?? "")
            if campoGlobal {
                cell.setAutoLayout(imageUbication: atributos?.imageposition ?? "")
            } else { cell.notContainImage() }
            cell.btnCheck.setTitle(valList, for: UIControl.State.normal)
            cell.btnCheck.addTarget(self, action: #selector(ListaCell.selectedButton), for: UIControl.Event.touchUpInside);
            
            if index == 0 {
                self.gralButton = cell.btnCheck
            } else {
                self.otherButtons.append(cell.btnCheck)
                self.gralButton.otherButtons = otherButtons;
            }
            self.stackButtons.addArrangedSubview(cell)
        }
    }
    
    // MARK: Events
    public func triggerEvent(_ action: String) {
        // alentrar
        // alcambiar
        if atributos != nil, atributos?.eventos != nil {
            for evento in (atributos?.eventos.expresion)! {
                if evento._tipoexpression == action{
                    DispatchQueue.main.async {
                        self.formDelegate?.addEventAction(evento)
                    }
                }
            }
        }
    }
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
    public func setRulesOnChange(){
        triggerRulesOnChange(nil)
    }
    
    // MARK: Rules on change
    public func triggerRulesOnChange(_ action: String?){
        if rulesOnChange.count == 0{ return }
        for rule in rulesOnChange{
            if rule["conditions"].children.count == 0{ continue }
            for condition in rule["conditions"].children{
                for subject in condition["subject"].children{
                    if subject["subject"].value == row.tag{
                        if subject["verb"].value == "contains" || subject["verb"].value == "notcontains" || subject["verb"].value == "empty" || subject["verb"].value == "notempty"{
                            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: subject["verb"].value, forced: false, override: false)
                        }
                    }
                }
            }
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

extension ListaCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{
        return self.headersView.lblMessage.text ?? ""
    }
    public func getRowEnabled()->Bool{
        return self.row.baseCell.isUserInteractionEnabled
    }
    public func getRequired()->Bool{
        return self.headersView.required
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

struct CustomData {
    var title: String
    var id: Int
    var tipo: String
}
