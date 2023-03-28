import Foundation

import Eureka

public class NumeroCell: Cell<String>, CellType, UITextFieldDelegate {
    
    // IBOUTLETS
    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var txtInput: UITextField!
    @IBOutlet weak var bgHabilitado: UIView!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var elemento = Elemento()
    public var atributos: Atributos_numero?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    
    // PRIVATE
    var isAlEntrar: Bool = false
    var txtInicial : String = ""
    var isMathematics: Bool = false
    var mathematicsName: [String] = []
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
    }
    
    // MARK: SETTING
    /// SetObject for NumeroRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_numero
        
        txtInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtInput.delegate = self
        txtInput.keyboardType = .decimalPad
        txtInput.autocorrectionType = .no
        txtInput.autocapitalizationType = .sentences
        txtInput.inputAssistantItem.leadingBarButtonGroups.removeAll()
        txtInput.inputAssistantItem.trailingBarButtonGroups.removeAll()
        txtInput.keyboardAppearance = UIKeyboardAppearance.dark
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setPlaceholder(atributos?.mascara ?? "")
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? NumeroRow)?.cell.formCell()?.formViewController()?.tableView
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
        // RESULTADO = MONEDA CELL * NUMERO CELL
        self.txtInput.translatesAutoresizingMaskIntoConstraints = false
        self.txtInput.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 18).isActive = true
        self.txtInput.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        self.txtInput.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        
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
            txtInput.text = ""
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
    
    // MARK: TEXTFIELDDELEGATE
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(of: self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
        row.value = textField.text
        setEstadistica()
        self.setEstadisticaV2()
        if !isAlEntrar{
            isAlEntrar = true
            triggerEvent("alentrar")
        }
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)

        if ( ((txtInicial != "") && (!(textField.text?.isEmpty ?? false)) && (txtInicial != textField.text) ) || ((txtInicial == "") && (!(textField.text?.isEmpty ?? false))))
        {
            triggerEvent("alcambiar")
            triggerRulesOnChange(nil)
            if isMathematics, mathematicsName.count > 0{
                for math in mathematicsName{
                    self.formDelegate?.obtainMathematics(math, nil)
                }
                
            }
        }
        guard var textInput = textField.text else { return }
        
        // MARK: - Setting estadisticas
        setEstadistica()
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = textInput.replaceLineBreakEstadistic()
        est!.KeyStroke += 1
        elemento.estadisticas = est!
        let fechaValorFinal = Date.getTicks()
        self.setEstadisticaV2()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = textInput.replaceLineBreakEstadistic()
        self.estV2!.Cambios += 1
        elemento.estadisticas2 = estV2!
        
        if self.atributos?.separadormiles != "" && textInput != "" {
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.decimal
            if let amount = Int(textInput) {
                let formattedString = formatter.string(for: amount)
                textField.text = formattedString
            } else {
                let textArray = textInput.components(separatedBy: ".")
                textInput = textArray.count == 2 ? textArray[0] : ""
                let decimal = textArray.count == 2 ? textArray[1] : ""
                if textInput.contains(",") {
                    let comas: Set<Character> = [","]
                    textInput.removeAll(where: { comas.contains($0) })
                }
                
                let newAmount = Int(textInput)
                var formattedString = formatter.string(for: newAmount) ?? ""
                formattedString += ".\(decimal)"
                textField.text = formattedString
            }
        }
        if self.atributos?.decimales != 0 && textInput != ""
        {
            guard let textInput = textField.text else { return }
            let textArray = textInput.components(separatedBy: ".")
            var decimal = textArray.count == 2 ? textArray[1] : ""
            if decimal.count < self.atributos?.decimales ?? 0 {
                let faltan = (self.atributos?.decimales ?? 0) - decimal.count
                for _ in 0...(faltan - 1) { decimal += "0" }
            }
            textField.text = "\(textArray[0]).\(decimal)"
        }
        
        isAlEntrar = false
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let charPerm = atributos!.decimales != 0 ? "0123456789." : "0123456789"
        let aSet = NSCharacterSet(charactersIn:charPerm).inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        if (textField.text)!.contains(".") && string != ""
        {
            let textArray = (textField.text)!.components(separatedBy: ".")
            let lastString = textArray.count == 2 ? textArray[1] : ""
            if lastString.count > (atributos!.decimales - 1)
            { //Check number of decimal places
                return false
            }
        }
        return string == numberFiltered
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    
    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    @objc open func textFieldDidChange(_ textField: UITextField) {
        guard let _ = textField.text else {
            row.value = nil
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            return
        }
        if textField.text != "0" && !(textField.text?.contains("0.") ?? false){
            textField.text = textField.text?.replaceZeros()
        }
        if textField.text != "" {
            self.headersView.lblTitle.textColor = UIColor.black
        } else {
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
        }
        
        row.value = textField.text
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
extension NumeroCell: ObjectFormDelegate{
    
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
                heightHeader = 40
            } else if !self.getRequired() || self.headersView.txthelp != "" {
                heightHeader = 25
            }
        }
        if self.headersView.frame.height < 6.0 {
            self.headersView.heightAnchor.constraint(equalToConstant: heightHeader).isActive = true
        }
        
        // Se actualiza el tamaño de la celda, agregando el alto del header
        heightHeader = 60 + CGFloat(heightHeader)
        self.setVariableHeight(Height: heightHeader)
    }
    
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Numero"
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
        txtInput.placeholder = text
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
        if atributos != nil && atributos!.numeromaximo != 0{
            rules.add(rule: ReglaRangoNumerico(minNumber: Int64(atributos?.numerominimo ?? 0), maxNumber: Int64(atributos?.numeromaximo ?? 99999)))
            row.add(ruleSet: rules)
        }else if atributos != nil && atributos!.numerominimo != 0{
            rules.add(rule: ReglaRangoNumerico(minNumber: Int64(atributos?.numerominimo ?? 0), maxNumber: Int64(9999999999999), msg: "El número mínimo es \(atributos?.numerominimo ?? 0)"))
            row.add(ruleSet: rules)
        }
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
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            txtInput.text = v
            row.value = nil
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            return
        }
        self.headersView.lblTitle.textColor = UIColor.black
        txtInput.text = v
        row.value = v
        if (txtInput.text)!.contains("."){
            let cantidad = txtInput.text?.replacingOccurrences(of: ",", with: "")
            let entero = String(cantidad?.split(separator: ".").first ?? "")
            let number = Double(cantidad ?? "0.00")
            var auxCant = String(format: "%.\(atributos!.decimales)f", number ?? 0.0)
            auxCant = auxCant.replacingOccurrences(of: String(auxCant.split(separator: ".").first ?? ""), with: entero)
            txtInput.text = auxCant
        }
        
        textFieldDidChange(txtInput)
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
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato = ""
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
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            }else{
                DispatchQueue.main.async {
                    self.headersView.setMessage("")
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
    public func triggerEvent(_ action: String) {
        // alentrar
        // alcambiar
        if atributos != nil, atributos?.eventos != nil {
            for evento in (atributos?.eventos.expresion)!
            {   if evento._tipoexpression == action
                {
                    DispatchQueue.main.async {
                        self.formDelegate?.addEventAction(evento)
                        self.txtInicial = (action == "alentrar" && (!(self.txtInput.text?.isEmpty ?? false)) ) ? self.txtInput.text! : ""
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
            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: action, forced: false, override: false)
        }
    }
    public func setMathematics(_ bool: Bool, _ id: String){
        isMathematics = bool
        mathematicsName.append(id)
    }
}

extension NumeroCell{
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
