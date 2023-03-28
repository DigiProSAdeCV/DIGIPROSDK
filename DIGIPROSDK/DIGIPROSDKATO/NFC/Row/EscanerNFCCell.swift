import Foundation

import Eureka

public class EscanerNFCCell: Cell<String>, CellType, UITextViewDelegate {
    
    // IBOUTLETS
    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var bgHabilitado: UIView!
    @IBOutlet weak var btnEscanear: UIButton!
    @IBOutlet weak var txtInput: UITextView!
    //PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var filtroCombo: [String] = []
    // PRIVATE
    public var elemento = Elemento()
    public var atributos: Atributos_escanerNFC?

    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    var isAlEntrar: Bool = false
    var formulaLoop: Int = 0
    var txtInicial : String = ""

    @IBAction func btnEscanearAction(_ sender: UIButton)
    {
        (row as? EscanerNFCRow)?.customselect()
    }
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        isInfoToolTipVisible = false
        toolTip = nil
        est = nil
        (row as? EscanerNFCRow)?.presentationMode = nil
    }
    
    // MARK: SETTING
    /// SetObject for EscanerNFCRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_escanerNFC
        if let combo = self.formDelegate?.isfilter(idElement: elemento._idelemento), combo != ""
        {   self.filtroCombo.append(combo)  }
        
        btnEscanear.backgroundColor = UIColor(hexFromString: "#1E88E5")
        btnEscanear.layer.cornerRadius = btnEscanear.frame.height / 2
        btnEscanear.setImage(UIImage(named: "ic_NFC", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        txtInput.delegate = self
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        if atributos?.titulo ?? "" == ""{ self.headersView.setOcultarTitulo(true) }else{ self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        if atributos?.subtitulo ?? "" == ""{ self.headersView.setOcultarSubtitulo(true) }else{ self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false) }
        
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false)}
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? EscanerNFCRow)?.cell.formCell()?.formViewController()?.tableView
        self.headersView.hiddenTit = false
        self.headersView.hiddenSubtit = false
        
        self.headersView.setTitleText(headersView.txttitulo)
        self.headersView.setSubtitleText(headersView.txtsubtitulo)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
        self.headersView.setMessage("")
        
        //setAlignment(atributos?.alineadotexto ?? "")
        
        let icon = UIImage(named: "ic_NFC", in: Cnstnt.Path.framework, compatibleWith: nil)
        btnEscanear.translatesAutoresizingMaskIntoConstraints = false
        btnEscanear.setImage(icon, for: .normal)
        
        self.headersView.translatesAutoresizingMaskIntoConstraints = false
        self.headersView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        self.headersView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.headersView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        
        if headersView.lblTitle.text?.count ?? 0 > 120 {
            headersView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        }else if headersView.lblTitle.text?.count ?? 0 > 50{
            headersView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }else {
            headersView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        self.btnEscanear.translatesAutoresizingMaskIntoConstraints = false
        self.btnEscanear.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 10).isActive = true
        
        self.txtInput.translatesAutoresizingMaskIntoConstraints = false
        self.txtInput.topAnchor.constraint(equalTo: self.btnEscanear.bottomAnchor, constant: 20).isActive = true
        self.txtInput.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        self.txtInput.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        
        self.bgHabilitado.translatesAutoresizingMaskIntoConstraints = false
        self.bgHabilitado.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.bgHabilitado.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.bgHabilitado.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.bgHabilitado.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader)
       // btnEscanear.setTitle("elemts_qr_btn".langlocalized(), for: .normal)
    }
    
    override open func update() {
        super.update()
        // MARK: TODO- Reset function
        if row.value == nil{
            txtInput.text = ""
            self.updateIfIsValid()
        }
        //self.setAlignment(self.atributos?.alineadotexto ?? "")
    }
    
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        
        let apiObject = ObjectFormManager<EscanerNFCCell>()
        apiObject.delegate = self
        btnEscanear.backgroundColor = UIColor(hexFromString: atributos?.colorescaner ?? "#1E88E5")
        btnEscanear.layer.cornerRadius = btnEscanear.frame.height / 2
        btnEscanear.setImage(UIImage(named: "ic_NFC", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        txtInput.delegate = self
    }
    
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) {
        guard let _ = self.atributos, let help = atributos?.ayuda else{
            return;
        }
        toogleToolTip(help)
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        
        if isInfoToolTipVisible{
            toolTip!.dismiss()
            isInfoToolTipVisible = false
        }
    }
    
    // MARK: TextViewDelegate
    open func textViewDidBeginEditing(_ textView: UITextView) {
        formViewController()?.beginEditing(of: self)
        formViewController()?.textInputDidBeginEditing(textView, cell: self)
        if txtInput.textColor == UIColor.lightGray{
            textView.text = ""
            row.value = textView.text
            txtInput.textColor = UIColor.black
        }else{
            row.value = textView.text
            txtInput.textColor = UIColor.black
        }
        formulaLoop = 0
        if !isAlEntrar{
            isAlEntrar = true
            triggerEvent("alentrar")
        }
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textView, cell: self)
        
        if textView.text.isEmpty{
            txtInput.textColor = UIColor.lightGray
        }
        textViewDidChange(textView)
        if ( ((txtInicial != "") && (!(textView.text?.isEmpty ?? false)) && (txtInicial != textView.text) ) || ((txtInicial == "") && (!(textView.text?.isEmpty ?? false))))
        {
            triggerEvent("alcambiar")
            triggerRulesOnChange(nil)
            formulaLoop += 1
        }
        isAlEntrar = false
        
    }
    
    open func textViewShouldReturn(_ textView: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textView, cell: self) ?? true
    }
    
    open func textView(_ textView: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textView, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
    }
    
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textView, cell: self) ?? true
    }
    
    open func textViewShouldClear(_ textView: UITextView) -> Bool {
        return formViewController()?.textInputShouldClear(textView, cell: self) ?? true
    }
    
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textView, cell: self) ?? true
    }
    
    @objc open func textViewDidChange(_ textView: UITextView) {
       
        guard let _ = textView.text else {
            row.value = nil
            self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            return
        }
        
        if self.atributos != nil{
            textView.text = textView.text!.upperLower(atributos?.mayusculasminusculas ?? "normal")
        }
        if textView.text != "" {
            self.headersView.lblTitle.textColor = UIColor.black
        } else {
            self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ? UIColor.black : UIColor.red
            self.headersView.setHeightFromTitles()
            setVariableHeight(Height: self.headersView.heightHeader)
        }
        row.value = textView.text
        row.validate()
        self.updateIfIsValid()

    }
    
    // MARK: - PROTOCOLS FUNCTIONS
    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && txtInput.canBecomeFirstResponder == true
    }
    
    open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
        return txtInput.becomeFirstResponder()
    }
    
    open override func cellResignFirstResponder() -> Bool {
        return txtInput.resignFirstResponder()
    }
    
}

// MARK: - OBJECTFORMDELEGATE
extension EscanerNFCCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "NFC"
        if atributos != nil{
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
    }
    
    // MARK: Set - TextStyle
    public func setTextStyle(_ style: String){
        self.atributos?.estilotexto = style
        self.headersView.lblTitle.font = self.headersView.lblTitle.font.setStyle(style)
        self.headersView.lblSubtitle.font = self.headersView.lblSubtitle.font.setStyle(style)
    }
    // MARK: Set - Decoration
    public func setDecoration(_ decor: String){
        self.atributos?.decoraciontexto = decor
        self.headersView.lblTitle.attributedText = self.headersView.lblTitle.text?.setDecoration(decor)
        self.headersView.lblSubtitle.attributedText = self.headersView.lblSubtitle.text?.setDecoration(decor)
    }
    // MARK: Set - Alignment
    public func setAlignment(_ align: String){
        self.atributos?.alineadotexto = align
        self.headersView.lblTitle.textAlignment = self.headersView.lblTitle.setAlignment(align)
        self.headersView.lblSubtitle.textAlignment = self.headersView.lblSubtitle.setAlignment(align)
        
        let screenSize: CGRect = UIScreen.main.bounds
        var widthView = screenSize.width
        if (UIDevice.current.model.contains("iPad")) {
        widthView = widthView < self.contentView.frame.size.width ? self.contentView.frame.size.width : widthView   }
//        switch align
//        {
//            case "left", "justify" :
//                self.constAlineacion.constant = (((widthView / 2) - ((constAncho.constant / 2) + 30) ) * -1)
//                break
//            case "center" :
//                self.constAlineacion.constant = 0
//                break;
//            case "right" :
//                self.constAlineacion.constant = ((widthView / 2) - ((constAncho.constant / 2) + 30) )
//                break;
//            default:
//                self.constAlineacion.constant = (((widthView / 2) - ((constAncho.constant / 2) + 30) ) * -1)
//                break;
//        }
    }
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) {
        DispatchQueue.main.async {
            self.height = {return h}
            self.layoutIfNeeded()
            self.row.reload()
            self.formDelegate?.reloadTableViewFormViewController()
        }
    }
    // MARK: Set - Title Text
    public func setTitleText(_ text:String){
    }
    // MARK: Set - Subtitle Text
    public func setSubtitleText(_ text:String){
    }
    
    // MARK: Set - Height From Titles
    public func setHeightFromTitles(){
    }

    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){
    }
    // MARK: Set - Info
    public func setInfo(){
        if atributos?.ayuda != nil, !(atributos?.ayuda.isEmpty)!, atributos?.ayuda != ""{
            self.headersView.btnInfo.isHidden = false
        }
    }
    
    public func toogleToolTip(_ help: String){
        if isInfoToolTipVisible{
            toolTip?.dismiss()
            isInfoToolTipVisible = false
        }else{
            toolTip = EasyTipView(text: help, preferences: EasyTipView.globalPreferences)
            toolTip?.show(forView: self.headersView.btnInfo, withinSuperview: (row as? EscanerNFCRow)?.cell.formCell()?.formViewController()?.tableView)
            isInfoToolTipVisible = true
        }
    }
    
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){
        self.headersView.setMessage(string)
    }
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil{ setRequerido(atributos?.requerido ?? false) }
    }
    // MARK: Set - MinMax
    public func setMinMax(){ }
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){
        /*var rules = RuleSet<String>()
        if atributos != nil, atributos!.expresionregular != ""{
            atributos?.expresionregular = atributos!.expresionregular.replaceRegex()
            if atributos!.regexrerrormsg != ""{
                rules.add(rule: ReglaExpReg(regExpr: atributos!.expresionregular, allowsEmpty: atributos!.requerido, msg: "\(atributos!.regexrerrormsg)", id: nil))
            }else{
                rules.add(rule: ReglaExpReg(regExpr: atributos!.expresionregular, allowsEmpty: atributos!.requerido, msg: "El campo no cumple la expresión: \(atributos!.expresionregular)", id: nil))
            }
        }
        row.add(ruleSet: rules)*/
    }
    
    // MARK: Set - OcultarTitulo
    public func setOcultarTitulo(_ bool: Bool){
    }
    // MARK: Set - OcultarSubtitulo
    public func setOcultarSubtitulo(_ bool: Bool){
    }
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
    public func setEdited(v: String){
        if v == ""{
            txtInput.text = v
            row.value = nil
            self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            return
        }
        self.headersView.lblTitle.textColor = UIColor.black
        txtInput.text = v
        txtInput.textColor = UIColor.black
        row.value = v
        
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
        
        textViewDidChange(txtInput)
        if !txtInput.isFirstResponder{
            if formulaLoop == 0{
                triggerEvent("alcambiar")
                triggerRulesOnChange(nil)
            }
            formulaLoop += 1
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
    // MARK: Set - Requerido
    public func setRequerido(_ bool: Bool){
        self.elemento.validacion.needsValidation = bool
        self.atributos?.requerido = bool
        var rules = RuleSet<String>()
        if bool{
            rules.add(rule: ReglaRequerido())
            self.headersView.lblRequired.isHidden = false
            self.headersView.lblTitle.textColor = UIColor.red
        }else{
            self.headersView.lblRequired.isHidden = true
            self.headersView.lblTitle.textColor = UIColor.black
        }
        self.layoutIfNeeded()
        self.row.add(ruleSet: rules)
    }
    
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        self.headersView.lblMessage.isHidden = true
        if isDefault{
            // Setting Default
            DispatchQueue.main.async {
                if self.atributos != nil{ self.setOcultarSubtitulo(self.atributos?.ocultarsubtitulo ?? false) }
                self.headersView.lblMessage.text = ""
                self.headersView.lblMessage.isHidden = true
//                self.viewValidation.backgroundColor = Cnstnt.Color.gray
                self.layoutIfNeeded()
            }
            resetValidation()
            self.elemento.validacion.validado = false
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato = ""
            return
        }
        if row.isValid{
            // Setting row as valid
            if row.value == nil{
                DispatchQueue.main.async {
                    self.setOcultarSubtitulo(self.atributos?.ocultarsubtitulo ?? false)
                    self.headersView.lblMessage.text = ""
                    self.headersView.lblMessage.isHidden = true
//                    self.viewValidation.backgroundColor = Cnstnt.Color.gray
                    self.layoutIfNeeded()
                }
                self.elemento.validacion.validado = false
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            }else{
                DispatchQueue.main.async {
                    self.setOcultarSubtitulo(self.atributos?.ocultarsubtitulo ?? false)
                    self.headersView.lblMessage.text = ""
                    self.headersView.lblMessage.isHidden = true
//                    self.viewValidation.backgroundColor = UIColor.green
                    self.layoutIfNeeded()
                }
                resetValidation()
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.valor = row.value?.replaceLineBreak() ?? ""
                    self.elemento.validacion.valormetadato  = row.value?.replaceLineBreak() ?? ""
                }else{
                    self.elemento.validacion.validado = false
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                }
            }
        }else{
            // Throw the first error printed in the label
            DispatchQueue.main.async {
//                self.viewValidation.backgroundColor = UIColor.red
                if (self.row.validationErrors.count) > 0{
                    self.headersView.lblMessage.text = "  \(self.row.validationErrors[0].msg)  "
                    let colors = self.formDelegate?.getColorsErrors(.error)
                    self.headersView.lblMessage.backgroundColor = .clear
                    self.headersView.lblMessage.textColor = Cnstnt.Color.red2
                }
                self.headersView.lblMessage.isHidden = false
                self.layoutIfNeeded()
            }
            self.elemento.validacion.needsValidation = true
            self.elemento.validacion.validado = false
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato = ""
        }
    }
    // MARK: Events
    public func triggerEvent(_ action: String) {
        // alentrar
        // alcambiar
        /*if atributos != nil, atributos?.eventos != nil{
            for evento in (atributos?.eventos.expresion)!{
                if evento._tipoexpression == action{
                    DispatchQueue.main.async {
                        self.formDelegate?.addEventAction(evento)
                        self.txtInicial = (action == "alentrar" && (!(self.txtInput.text?.isEmpty ?? false)) ) ? self.txtInput.text! : ""
                    }
                }
            }
        }*/
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
            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: action, forced: false, override: false)
        }
    }
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){ }
}

extension EscanerNFCCell{
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
}
