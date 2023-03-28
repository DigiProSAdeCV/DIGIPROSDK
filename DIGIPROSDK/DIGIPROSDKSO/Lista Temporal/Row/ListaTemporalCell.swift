import Foundation

import Eureka

public class jsonTemp: EVObject{
    var desc: String = ""
    var id: Int = 0
}

// MARK: ListaTemporalCell
public class ListaTemporalCell: Cell<String>, CellType {
   
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
    public var elemento = Elemento()
    public var atributos: Atributos_listatemporal?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var catalogoDestino: NSMutableDictionary = NSMutableDictionary()
    public var flagEmpty: Bool = false
    public var listItemsTemp : [String] =  []
    
    var banner = NotificationBanner(title: "No hay elementos", subtitle: "Revise la configuracion de la plantilla.", leftView: nil, rightView: nil, style: .success, colors: nil)
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
    }
    
    // MARK: SETTING
    /// SetObject for ListaRemporalRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_listatemporal
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setVisible(atributos?.visible ?? true)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        
        headersView.setTitleText(atributos?.titulo ?? "")
        headersView.setSubtitleText(atributos?.subtitulo ?? "")
        headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false)
        headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false)
        headersView.setAlignment(atributos?.alineadotexto ?? "")
        headersView.setDecoration(atributos?.decoraciontexto ?? "")
        headersView.setTextStyle(atributos?.estilotexto ?? "")
        headersView.btnInfo.isHidden = true
        headersView.viewInfoHelp = (row as? ListaTemporalRow)?.cell.formCell()?.formViewController()?.tableView
        
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
        self.flagEmpty = true
    }
    
    public func setElements(_ v:String){
        setVisible(atributos?.visible ?? true)
        setHabilitado(atributos?.habilitado ?? false)
        
        // TODO: - Detect if is String or Json Object,
        self.listItemsTemp = []
        let listVariables = [jsonTemp](json: v)
        let listVariablesNew = v.split{$0 == ","}.map(String.init)
        
        if listVariables.count > 0{
            self.getCatalogoObjectToJson(data: listVariables)
            for (index, variable) in listVariables.enumerated(){
                var valMostrar = ""
                switch self.atributos?.atributocombomostrar
                {   case "desc":
                        valMostrar = "\(variable.desc)"
                        break;
                    case "val":
                        valMostrar = "\(variable.id)"
                        break;
                    default:
                        valMostrar = "\(variable.desc)"
                        break;
                }
                let desc = self.atributos?.atributodescripcion == "desc" ? "\(variable.desc)" : "\(variable.id)"
                
                self.listItemsTemp.append(String("\(valMostrar)|\(desc)"))
                
                if index == 0{
                    self.elemento.validacion.id = self.atributos?.atributovalor == "desc" ? "\(variable.desc)" : "\(variable.id)"
                    self.setEdited(v: valMostrar, value: desc)
                    _ = self.formDelegate?.resolveValor(self.atributos?.elementoligado ?? "", "asignacion", desc, nil)
                }else{
                    self.headersView.lblTitle.textColor =  self.getRequired() ? UIColor.black : Cnstnt.Color.red2
                }
            }
        }
        
        if listVariablesNew.count == 0{ return }
        if (listVariables.count == 0)
        {
            self.getCatalogoJson(data: listVariablesNew)
            for (index, variable) in listVariablesNew.enumerated(){
                self.listItemsTemp.append(String("\(variable)|\(variable)"))
                if index == 0{
                    self.elemento.validacion.id = "\(variable)"
                    self.setEdited(v: variable)
                    self.setVisible(true)
                    _ = self.formDelegate?.resolveValor(self.atributos?.elementoligado ?? "", "asignacion", "\(variable)" , nil)
                }else{
                    self.headersView.lblTitle.textColor =  self.getRequired() ? UIColor.black : Cnstnt.Color.red2
                }
            }
        }
        self.flagEmpty = true
    }
    
    public func getCatalogoObjectToJson(data: [jsonTemp]){
        let json = data.toJsonString()
        self.elemento.validacion.catalogoDestino = json
    }
    
    public func getCatalogoJson(data: [String]){
        var dictArray: [NSMutableDictionary] = [NSMutableDictionary]()
        for (_, variable) in data.enumerated(){
            self.catalogoDestino = [:]
            
            self.catalogoDestino.setValue(variable, forKey: "Descripcion")
            self.catalogoDestino.setValue(variable, forKey: "Valor")
            dictArray.append(self.catalogoDestino)
        }
       
        let jsonData = try! JSONSerialization.data(withJSONObject: dictArray, options: JSONSerialization.WritingOptions.sortedKeys)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        self.elemento.validacion.catalogoDestino = jsonString
    }
    
    override open func update() {
        super.update()
        // MARK: TODO- Reset function
        if row.value == nil{
            self.txtInput.text = "Es necesario seleccionar una opción"
            self.updateIfIsValid()
        }
    }
    
    // MARK: - INIT
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
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
    
    @objc func onClickDropButton(_ sender: UIButton) {
        if !self.listItemsTemp.isEmpty {
            let controller = ModalListaViewController()
            controller.atributosListaT = self.atributos
            controller.rowListT = self
            controller.listItems = listItemsTemp
            controller.formDelegate = self.formDelegate
            controller.idsItemsSelect = self.atributos?.atributocombomostrar == "desc" ? self.elemento.validacion.valormetadato : self.elemento.validacion.valor
            controller.configure (onFinishedAction: { [unowned self] result in
                switch result {
                case .success( _):
                    let values = controller.valueItemsSelect
                    let ids = controller.idsItemsSelect
                    let valDesc = self.atributos?.atributocombomostrar == "desc" ? values : ids
                    let valId = valDesc == values ? ids : values
                    self.elemento.validacion.id = self.atributos?.atributovalor == "desc" ? valDesc : valId
                    if ids == values {
                        self.setEdited(v: values)
                        self.setVisible(true)
                    } else { self.setEdited(v: values, value: ids) }
                    _ = self.formDelegate?.resolveValor(self.atributos?.elementoligado ?? "", "asignacion", ids , nil)
                    
                    break
                case .failure(let error):
                    print("ERROR BACK SELECT LISTA TEMPORAL: \(error)")
                 break
                }
            })
            
            let presenter = Presentr(presentationType: .fullScreen)
            self.formViewController()?.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
        } else {
            if !self.banner.isDisplaying {
                self.banner.show()
            }
        }
    }
}

// MARK: - OBJECTFORMDELEGATE
extension ListaTemporalCell: ObjectFormDelegate{
    
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
    // MARK: - ESTADISTICAS
    open func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        if atributos != nil{
            est?.Campo = "Lista Temporal"
            est?.NombrePagina = (self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
            est?.OrdenCampo = atributos?.ordencampo ?? 0
            est?.PaginaID = Int(atributos?.elementopadre.replaceFormElec() ?? "0") ?? 0
        }
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
        self.headersView.setRequerido(false)
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
    
    public func setEdited(v: String) {
        self.setEdited(v: v, value: nil)
    }
    public func setEdited(v: String, isRobot: Bool) { }
    // MARK: Set - Edited
    public func setEdited(v: String, value:String? = nil){
        if v == ""{
            self.txtInput.text = "Es necesario seleccionar una opción"
            row.value = nil
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            return
        }
        self.headersView.lblTitle.textColor = UIColor.black
        txtInput.text = v
        row.value = value != nil ? value : v
        
        // MARK: - Setting estadisticas
        setEstadistica()
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = v.replaceLineBreakEstadistic()
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
        triggerEvent("alcambiar")
        triggerRulesOnChange(nil)
        triggerRulesOnAction("change")
        
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
    public func resetValidation(){ }
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
            return
        }
        if row.isValid{ // Setting row as valid
            if row.value == nil{
                DispatchQueue.main.async {
                    self.headersView.setMessage("")
                    self.layoutIfNeeded()
                }
                self.elemento.validacion.validado = false
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            }else{
                DispatchQueue.main.async {
                    self.headersView.setMessage("")
                    self.layoutIfNeeded()
                }
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.valor = row.value?.replaceLineBreak() ?? ""
                    self.elemento.validacion.valormetadato  = self.elemento.validacion.id.replaceLineBreak()
                }else{
                    self.elemento.validacion.validado = false
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                }
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
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato = ""
        }
    }
    // MARK: Events
    public func triggerEvent(_ action: String) { }
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

extension ListaTemporalCell{
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
    public func getSubtitleLabel()->String{ return "" }
}
