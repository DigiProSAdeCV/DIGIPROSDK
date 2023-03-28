import Foundation

import Eureka

public class TextoAreaCell: Cell<String>, CellType, UITextViewDelegate {
    
    // IBOUTLETS
    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var txtInput: UITextView!
    @IBOutlet weak var bgHabilitado: UIView!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var elemento = Elemento()
    public var atributos: Atributos_textarea?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil

        
    // PRIVATE
    var isAlEntrar: Bool = false
    var txtInicial : String = ""
    var isMathematics: Bool = false
    var mathematicsName: [String] = []
    var orgRowHeight: CGFloat = 0.0
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
    }
    
    // MARK: SETTING
    /// SetObject for TextoArea,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_textarea
        
        txtInput.delegate = self
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setPlaceholder(atributos?.mascara ?? "")
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? TextoAreaRow)?.cell.formCell()?.formViewController()?.tableView
        self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false)
        self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
        
        self.headersView.translatesAutoresizingMaskIntoConstraints = false
        self.headersView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        self.headersView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.headersView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        
        self.headersView.setNeedsLayout()
        self.headersView.layoutIfNeeded()
        
        self.txtInput.translatesAutoresizingMaskIntoConstraints = false
        self.txtInput.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 10).isActive = true
        self.txtInput.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        self.txtInput.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        self.txtInput.layer.borderWidth = 1
        self.txtInput.layer.borderColor = UIColor.gray.cgColor
        self.txtInput.layer.cornerRadius = 10
        
        self.bgHabilitado.translatesAutoresizingMaskIntoConstraints = false
        self.bgHabilitado.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.bgHabilitado.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.bgHabilitado.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.bgHabilitado.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.setHeightFromTitles()
    }
    
    override open func update() {
        super.update()
        // MARK: TODO- Reset function
        if row.value == nil{
            setPlaceholder(atributos?.mascara ?? "")
            self.updateIfIsValid()
        }
        
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
        row.deselect()
        
        if self.headersView.isInfoToolTipVisible{
            self.headersView.toolTip!.dismiss()
            self.headersView.isInfoToolTipVisible = false
        }
    }
    
    // MARK: TextViewDelegate
    open func textViewDidBeginEditing(_ textView: UITextView) {
        formViewController()?.beginEditing(of: self)
        formViewController()?.textInputDidBeginEditing(textView, cell: self)
        if txtInput.textColor == UIColor.lightGray{ textView.text = "" }
        row.value = textView.text
        txtInput.textColor = UIColor.black
        setEstadistica()
        setEstadisticaV2()
        self.estV2!.Cambios += 1
        if !isAlEntrar{
            isAlEntrar = true
            triggerEvent("alentrar")
        }
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textView, cell: self)
        textViewDidChange(textView)
        let fechaValorFinal = Date.getTicks()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = txtInput.text!.replaceLineBreakEstadistic()
        elemento.estadisticas2 = estV2!
        if textView.text.isEmpty{
            setPlaceholder(atributos?.mascara ?? "")
        }
        
        if ( ((txtInicial != "") && (!(textView.text?.isEmpty ?? false)) && (txtInicial != textView.text) ) || ((txtInicial == "") && (!(textView.text?.isEmpty ?? false))))
        {
            triggerEvent("alcambiar")
            triggerRulesOnChange(nil)
            if isMathematics, mathematicsName.count > 0{
                for math in mathematicsName{
                    self.formDelegate?.obtainMathematics(math, nil)
                }
            }
        }
        isAlEntrar = false
        setHeightTextField()
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
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            return
        }
        
        if self.atributos != nil{
            if atributos?.longitudmaxima != 0{
                if (textView.text?.count)! > (atributos?.longitudmaxima)!{
                    textView.text = textView.text!.substring(to: atributos?.longitudmaxima ?? textView.text!.count)
                }
            }
        }
        
        if self.atributos != nil{
            textView.text = textView.text!.upperLower(atributos?.mayusculasminusculas ?? "normal")
        }
        
        if textView.text != "" {
            self.headersView.lblTitle.textColor = UIColor.black
        } else {
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
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
extension TextoAreaCell: ObjectFormDelegate{
    
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
    public func setHeightFromTitles(){
        var heightHeader : CGFloat = 0.0
        let ttl = self.headersView.lblTitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        let sttl = self.headersView.lblSubtitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        let msgerr = self.headersView.lblMessage.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        self.headersView.lblTitle.numberOfLines = ttl
        self.headersView.lblSubtitle.numberOfLines = sttl
        self.headersView.lblMessage.numberOfLines = msgerr
        
        var httl: CGFloat = 0
        var hsttl: CGFloat = 0
        let hmsg: CGFloat = (CGFloat(msgerr) * self.headersView.lblMessage.font.lineHeight) //1 estatico para error
        if !self.headersView.hiddenTit {
            httl = (CGFloat(ttl) * self.headersView.lblTitle.font.lineHeight)
        }
        if !self.headersView.hiddenSubtit {
            hsttl = (CGFloat(sttl) * self.headersView.lblSubtitle.font.lineHeight)
        }
        //Total de labels
        heightHeader = httl + hsttl + hmsg
        
        // Validación por si no hay titulo ni subtitulos a mostrar
        if (heightHeader - 25) < 0 {
            if !self.getRequired() && self.headersView.txthelp != "" {
                heightHeader = 50
            } else if !self.getRequired() || self.headersView.txthelp != "" {
                heightHeader = 45
            }
        }
            self.headersView.heightAnchor.constraint(equalToConstant: heightHeader).isActive = true
        if !self.getRequired() || self.headersView.btnInfo.isHidden || self.headersView.lblTitle.isHidden || self.headersView.lblSubtitle.isHidden {
            heightHeader += 20
        }
        
        heightHeader = 60 + CGFloat(heightHeader)
        self.orgRowHeight = CGFloat(heightHeader) - 30.0
        // Se actualiza el tamaño de la celda, agregando el alto del header
        self.setVariableHeight(Height: heightHeader)
    }
    
    // Protocolos Genéricos
    // MARK: - ESTADISTICAS
    open func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        if atributos != nil{
            est?.Campo = "Area Texto"
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
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) {
        DispatchQueue.main.async {
            self.height = {return h}
            self.layoutIfNeeded()
            self.row.reload()
            self.formDelegate?.reloadTableViewFormViewController()
        }
    }
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){
        txtInput.text = text
        txtInput.textColor = UIColor.lightGray
    }
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil{
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
    public func setMinMax(){
        var rules = RuleSet<String>()
        if atributos != nil, atributos!.longitudminima != 0{
            rules.add(rule: ReglaMinLongitud(minLength: UInt(atributos!.longitudminima)))
        }
        if atributos != nil, atributos!.longitudmaxima != 0{
            rules.add(rule: ReglaMaxLongitud(maxLength: UInt(atributos!.longitudmaxima), msg: String(format: NSLocalizedString("rules_max_char", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), String(atributos?.longitudmaxima ?? 0))))
        }
        row.add(ruleSet: rules)
    }
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){
        var rules = RuleSet<String>()
        if atributos != nil, atributos!.expresionregular != ""{
            atributos?.expresionregular = atributos!.expresionregular.replaceRegex()
            if atributos!.regexrerrormsg != ""{
                rules.add(rule: ReglaExpReg(regExpr: atributos!.expresionregular, allowsEmpty: atributos!.requerido, msg: "\(atributos!.regexrerrormsg)", id: nil))
            }else if atributos!.mascara != ""{
                rules.add(rule: ReglaExpReg(regExpr: atributos!.expresionregular, allowsEmpty: atributos!.requerido, msg: "\(atributos!.mascara)", id: nil))
            }else{
                rules.add(rule: ReglaExpReg(regExpr: atributos!.expresionregular, allowsEmpty: atributos!.requerido, msg: String(format: NSLocalizedString("rules_value", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), atributos!.expresionregular), id: nil))
            }
        }
        row.add(ruleSet: rules)
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
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : UIColor.red
            txtInput.text = v
            row.value = nil
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            return
        }
        self.headersView.lblTitle.textColor = UIColor.black
        txtInput.text = v
        txtInput.textColor = UIColor.black
        row.value = v
        
        // MARK: - Setting estadisticas
        let fechaValorFinal = Date.getTicks()
        self.setEstadisticaV2()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = v.replaceLineBreakEstadistic()
        self.estV2!.Cambios += 1
        elemento.estadisticas2 = estV2!
        setEstadistica()
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = v.replaceLineBreakEstadistic()
        est!.KeyStroke += 1
        elemento.estadisticas = est!
        
        textViewDidChange(txtInput)
        setHeightTextField()
        if !txtInput.isFirstResponder{
            triggerEvent("alcambiar")
            triggerRulesOnChange(nil)
            if isMathematics, mathematicsName.count > 0{
                for math in mathematicsName{
                    self.formDelegate?.obtainMathematics(math, nil)
                }
                
            }
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
    // MARK: Set - Height TextView
    public func setHeightTextField(){
        if self.txtInput.contentSize.height > 85{
            self.txtInput.contentSize.height = 85
        }
        let httl: CGFloat = self.txtInput.contentSize.height
        let hh = orgRowHeight + httl
        self.setVariableHeight(Height: hh)
        
    }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        self.headersView.lblMessage.isHidden = true
        if isDefault{ // Setting Default
            cleanValues()
            resetValidation()
            return
        }
        if row.isValid{
            // Setting row as valid
            if row.value == nil{
                cleanValues()
            }else{
                cleanValues()
                resetValidation()
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.valor = row.value?.replaceLineBreak() ?? ""
                    self.elemento.validacion.valormetadato  = row.value?.replaceLineBreak() ?? ""
                }
            }
        }else{
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
    func cleanValues() {
        DispatchQueue.main.async {
            self.headersView.setMessage("")
            self.layoutIfNeeded()
        }
        self.elemento.validacion.validado = false
        self.elemento.validacion.valor = ""
        self.elemento.validacion.valormetadato = ""
    }
    // MARK: Events
    public func triggerEvent(_ action: String) {
        // alentrar
        // alcambiar
        if atributos != nil && atributos?.eventos != nil{
            if atributos?.eventos.expresion.count ?? 0 > 0{
                for expresion in (atributos?.eventos.expresion)!{
                    if expresion._tipoexpression == action{
                        DispatchQueue.main.async {
                            self.formDelegate?.addEventAction(expresion)
                            self.txtInicial = (action == "alentrar" && (!(self.txtInput.text?.isEmpty ?? false)) ) ? self.txtInput.text! : ""
                        }
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
    public func setRulesOnChange()
    {   if row.value == nil || row.value == nil
        {   self.triggerRulesOnChange("empty")
            self.triggerRulesOnChange("notcontains")
        } else
        {
            self.triggerRulesOnChange(nil)
        }
    }
    
    // MARK: Rules on change
    public func triggerRulesOnChange(_ action: String?){
        if rulesOnChange.count == 0{ return }
        for rule in rulesOnChange{
            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: action, forced: false, override: false)
        }
    }
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){
        isMathematics = bool
        mathematicsName.append(id)
    }
}

extension TextoAreaCell{
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
