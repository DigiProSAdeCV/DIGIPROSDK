import Foundation

import Eureka

public class BotonCell: Cell<String>, CellType {
    
    lazy var headersView: FEHeaderView = {
        let header = FEHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
    lazy var bgHabilitado: UIView = {
        let bgHabilitado = UIView()
        bgHabilitado.translatesAutoresizingMaskIntoConstraints = false
        return bgHabilitado
    }()
    lazy var genericBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        btn.titleLabel?.numberOfLines = 0
        btn.addTarget(self, action: #selector(self.botonAction(_:)), for: .touchUpInside)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    lazy var genericLblBtn: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var stackBody: UIStackView = {
        let stackBody = UIStackView()
        stackBody.axis = .vertical
        stackBody.spacing = 5
        stackBody.distribution = .fill
        stackBody.addArrangedSubview(headersView)
        stackBody.addArrangedSubview(genericBtn)
        stackBody.addArrangedSubview(genericLblBtn)
        stackBody.translatesAutoresizingMaskIntoConstraints = false
        return stackBody
    }()
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var elemento = Elemento()
    public var atributos: Atributos_boton?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var clickCount: Int = 0
    public var isEvento : Bool = false
    public var estiloBotones: String = ""
    //public var xmlParsed = Elemento()
    //public var xmlAEXML = AEXMLDocument()
    
    // PRIVATE
    var h: CGFloat = 0.0
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
    }
    
    // MARK: SETTING
    /// SetObject for BotonRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_boton
        self.clickCount = 0
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
       
        headersView.setTitleText(atributos?.titulo ?? "")
        headersView.setHelpText(atributos?.ayuda ?? "")
        headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false)
        headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false)
        headersView.setAlignment(atributos?.alineadotexto ?? "")
        headersView.btnInfo.isHidden = atributos?.ayuda == "" ? true : false
        headersView.viewInfoHelp = (row as? BotonRow)?.cell.formCell()?.formViewController()?.tableView
        
     
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
            
            genericBtn.heightAnchor.constraint(equalToConstant: 40),
        ])
       
        self.genericLblBtn.text = atributos?.valor.htmlDecoded ?? "Boton"

        self.genericBtn = self.formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.genericBtn, nameIcono: "ic_touch", titulo: self.genericLblBtn.text!, colorFondo: self.atributos?.colorfondo ?? "#3c8dbc", colorTxt: self.atributos?.colortexto ?? "#ffffff") ?? UIButton()
        self.genericLblBtn.isHidden = self.genericBtn.titleLabel?.text == self.genericLblBtn.text! ? true : false
        setAlignmentWidth(atributos?.alineadotexto ?? "left", atributos?.ancho ?? "normal")
    }
    
    override open func update() {
        super.update()
    }
    
    // MARK: - INIT
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
    }
    
    open override func didSelect() {
        super.didSelect()
        if self.headersView.isInfoToolTipVisible{
            self.headersView.toolTip!.dismiss()
            self.headersView.isInfoToolTipVisible = false
        }
    }
    
    @objc public func botonAction(_ sender: UIButton?) {
        clickCount += 1
        
        setEstadistica()
        self.setEstadisticaV2()
        let fechaValorFinal = Date.getTicks()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.Cambios += 1
        self.estV2!.ValorFinal = "CLICK"
        elemento.estadisticas2 = estV2!
        // MARK: - Estadística
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = ""
        est!.KeyStroke += 1
        elemento.estadisticas = est!
        if atributos?.cantidadmaximaclic ?? 0 == 0 || atributos?.cantidadmaximaclic == nil{
            triggerEvent("aldarclick")
            triggerRulesOnChange("click")
            setURLlink(atributos?.urllink ?? "")
        }else{
            if clickCount <= atributos!.cantidadmaximaclic{
                triggerEvent("aldarclick")
                triggerRulesOnChange("click")
                setURLlink(atributos?.urllink ?? "")
            }else{
                self.setMessage("elemts_btn_max".langlocalized(), .error)
            }
        }
    }

}

// MARK: - OBJECTFORMDELEGATE
extension BotonCell: ObjectFormDelegate{
    
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
        est?.Campo = "Boton"
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
    }
    // MARK: Set - Height
    public func setHeight(_ tamanio: String){ }
    // MARK: Set - Width
    public func setWidth(_ width: String, tit titBoton: String){ }
    public func setAlignmentWidth(_ align: String, _ width: String){
        
        switch width {
        case "normal":
            switch align {
            case "left", "justify", "flex-start" :
                stackBody.alignment = .leading
                break
            case "center" :
                stackBody.alignment = .center
                break
            case "right", "flex-end" :
                stackBody.alignment = .trailing
                break
            default:
                stackBody.alignment = .leading
                break
            }
            NSLayoutConstraint.activate([
                genericBtn.widthAnchor.constraint(equalToConstant: (estiloBotones != "circulofondo" && estiloBotones != "circuloborde") ? 105 : 40.0),
            ])
            break
        case "completo":
            stackBody.alignment = .center
            NSLayoutConstraint.activate([
                genericBtn.widthAnchor.constraint(equalTo: stackBody.widthAnchor),
            ])
            
            break
        default:
            break
        }

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
    
    // MARK: Set - URLlink
    public func setURLlink(_ urllink: String){
        if urllink == ""{ return }
        DispatchQueue.main.async
        {   //guard let stringUrl = URL(string: urllink) else {   return  }
            if !self.isEvento
            {   if UIApplication.shared.canOpenURL(URL(fileURLWithPath: urllink) )
                {
                    UIApplication.shared.open(URL(fileURLWithPath: urllink), completionHandler: { (success) in
                        
                    })
                }
            }
        }
    }
    
    // MARK: Set - Validation
    public func resetValidation(){ }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){ }
    // MARK: Events
    public func triggerEvent(_ action: String) {
        // alentrar
        // alcambiar
        if atributos != nil, atributos?.eventos != nil {
            for evento in (atributos?.eventos.expresion)!{
                if evento._tipoexpression == action{
                    DispatchQueue.main.async {
                        self.isEvento = true
                        self.formDelegate?.addEventAction(evento);
                        self.isEvento = false
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
    public func setRulesOnChange(){ }
    
    // MARK: Rules on change
    public func triggerRulesOnChange(_ action: String?){
        if rulesOnChange.count == 0{ return }
        for rule in rulesOnChange{
            if rule["enabled"].value == "true"{
                if rule["conditions"].children.count == 0{ continue }
                for condition in rule["conditions"].children{
                    for subject in condition["subject"].children{
                        if subject["subject"].value == row.tag{
                            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: subject["verb"].value, forced: false, override: false)
                        }
                    }
                }
            }
        }
    }
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){ }
}

extension BotonCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{ return "" }
    public func getRowEnabled()->Bool{ return self.row.baseCell.isUserInteractionEnabled }
    public func getRequired()->Bool{ return false }
    public func getTitleLabel()->String{ return atributos?.valor ?? "" }
    public func getSubtitleLabel()->String{ return "" }
}

extension String {
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string

        return decoded ?? self
    }
}
