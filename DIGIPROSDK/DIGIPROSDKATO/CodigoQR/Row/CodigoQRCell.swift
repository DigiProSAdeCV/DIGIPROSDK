import Foundation

import Eureka

public class CodigoQRCell: Cell<String>, CellType, UITextFieldDelegate {
    
    // IBOUTLETS
    @IBOutlet weak var heightTxtQR: NSLayoutConstraint!
    @IBOutlet weak var heightImgQR: NSLayoutConstraint!
    
    lazy var headersView: FEHeaderView = {
        let header = FEHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
 
    lazy var txtInput: UITextField = {
        let txtInput = UITextField()
        txtInput.delegate = self
        txtInput.layer.borderWidth = 1
        txtInput.layer.cornerRadius = 8
        txtInput.layer.borderColor = UIColor.lightGray.cgColor
        txtInput.keyboardType = .numberPad
        txtInput.autocorrectionType = .no
        txtInput.autocapitalizationType = .sentences
        txtInput.inputAssistantItem.leadingBarButtonGroups.removeAll()
        txtInput.inputAssistantItem.trailingBarButtonGroups.removeAll()
        txtInput.keyboardAppearance = UIKeyboardAppearance.dark
        txtInput.translatesAutoresizingMaskIntoConstraints = false
        return txtInput
    }()
    lazy var btnEscanear: UIButton = {
        let btnDrop = UIButton()
        btnDrop.addTarget(self, action: #selector(self.btnEscanearAction(_:)), for: .touchUpInside)
        btnDrop.translatesAutoresizingMaskIntoConstraints = false
        return btnDrop
    }()
    lazy var lblEscanear: UILabel = {
        let lbl = UILabel()
        lbl.text = "Escanear"
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var stackBody: UIStackView = {
        let stackBody = UIStackView()
        stackBody.axis = .vertical
        stackBody.spacing = 5
        stackBody.alignment = .center
        stackBody.addArrangedSubview(headersView)
        stackBody.addArrangedSubview(imgCodeQR)
        stackBody.addArrangedSubview(txtInput)
        stackBody.addArrangedSubview(btnEscanear)
        stackBody.addArrangedSubview(lblEscanear)
        stackBody.translatesAutoresizingMaskIntoConstraints = false
        return stackBody
    }()
    
    lazy var bgHabilitado: UIView = {
        let bgHabilitado = UIView()
        bgHabilitado.translatesAutoresizingMaskIntoConstraints = false
        return bgHabilitado
    }()
    
    lazy var imgCodeQR: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var filtroCombo: [String] = []
    public var elemento = Elemento()
    public var atributos: Atributos_codigoqr?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var estiloBotones: String = ""

    // PRIVATE
    var isAlEntrar: Bool = false
    var formulaLoop: Int = 0
    var txtInicial : String = ""
    var auxTamTitSubT : Double = 0.0

    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
        (row as? CodigoQRRow)?.presentationMode = nil
    }
    
    @objc func btnEscanearAction(_ sender: UIButton)
    {
        (row as? CodigoQRRow)?.customselect()
    }
    
    @IBAction func btnGernarQR(_ sender: UIButton)
    {   //con prellenado
        _ = self.formDelegate?.resolveValorQR(self.atributos?.prellenadomapeocampos ?? "", elemento._idelemento)
    }
    // MARK: SETTING
    /// SetObject for CodigoQRRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_codigoqr
        if let combo = self.formDelegate?.isfilter(idElement: elemento._idelemento), combo != ""
        {   self.filtroCombo.append(combo)  }
        
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
        headersView.viewInfoHelp = (row as? CodigoQRRow)?.cell.formCell()?.formViewController()?.tableView
        
        setCodeQR(self.atributos?.generarcodigoautomatico ?? false, self.atributos?.prellenadomapeocampos ?? "", atributos?.permitirprellenadoexterno ?? false)
        
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
            
            headersView.widthAnchor.constraint(equalTo: stackBody.widthAnchor),
            txtInput.widthAnchor.constraint(equalTo: stackBody.widthAnchor),
            txtInput.heightAnchor.constraint(equalToConstant: 45),
            
            btnEscanear.heightAnchor.constraint(equalToConstant: 40),
            btnEscanear.widthAnchor.constraint(equalToConstant: (estiloBotones != "circulofondo" && estiloBotones != "circuloborde") ? 105 : 40.0),
            
            imgCodeQR.heightAnchor.constraint(equalToConstant: 95),
            imgCodeQR.widthAnchor.constraint(equalToConstant: 95)
        ])
        
      
        btnEscanear = formDelegate?.configButton(tipo: estiloBotones, btnStyle: self.btnEscanear, nameIcono: "ic_qr_code", titulo: self.lblEscanear.text!, colorFondo: "#1E88E5", colorTxt: "000000") ?? UIButton()
        self.lblEscanear.isHidden = self.btnEscanear.titleLabel?.text == self.lblEscanear.text! ? true : false
        self.lblEscanear.font = UIFont(name: ConfigurationManager.shared.fontLatoBlod, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
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
            self.headersView.toolTip?.dismiss()
            self.headersView.isInfoToolTipVisible = false
        }
    }
    
    // MARK: TextViewDelegate
    open func textFieldDidBeginEditing(_ textView: UITextField) {
       // UIView.animate(withDuration: 0.25) { self.bottomLine.backgroundColor = UIColor.systemBlue }
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
    
    open func textFieldDidEndEditing(_ textView: UITextField) {
      //  UIView.animate(withDuration: 0.25) { self.bottomLine.backgroundColor = UIColor.gray }
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textView, cell: self)
        
        if textView.text == nil || textView.text == ""{
            txtInput.textColor = UIColor.lightGray
        }
        
        guard let _ = textView.text else {
            row.value = nil
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
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
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
        }
        row.value = textView.text
        row.validate()
        self.updateIfIsValid()
        setCodeQR(self.atributos?.generarcodigoautomatico ?? false, self.atributos?.prellenadomapeocampos ?? "", atributos?.permitirprellenadoexterno ?? false)
        

        if ( ((txtInicial != "") && (!(textView.text?.isEmpty ?? false)) && (txtInicial != textView.text) ) || ((txtInicial == "") && (!(textView.text?.isEmpty ?? false))))
        {
            triggerEvent("alcambiar")
            triggerRulesOnChange(nil)
            formulaLoop += 1
        }
        isAlEntrar = false
        
        
    }
    
    open func textFieldShouldReturn(_ textView: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textView, cell: self) ?? true
    }
    
    open func textField(_ textView: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textView, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
    }
    
    open func textFieldShouldBeginEditing(_ textView: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textView, cell: self) ?? true
    }
    
    open func textFieldShouldClear(_ textView: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textView, cell: self) ?? true
    }
    
    open func textFieldShouldEndEditing(_ textView: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textView, cell: self) ?? true
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
extension CodigoQRCell: ObjectFormDelegate{
    public func toogleToolTip(_ help: String) {}
    public func setTextStyle(_ style: String) {}
    public func setDecoration(_ decor: String) {}
    public func setAlignment(_ align: String) {}
    public func setTitleText(_ text: String) {}
    public func setSubtitleText(_ text: String) {}
    public func setPlaceholder(_ text: String) {}
    public func setInfo() {}
    public func setOcultarTitulo(_ bool: Bool) {}
    public func setOcultarSubtitulo(_ bool: Bool) {}
    
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){
        self.headersView.setMessage(string)
    }
    // MARK: Set - Height From Titles
    public func setHeightFromTitles(){}
    // Protocolos Genéricos
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Codigo QR"
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

    
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) { }
    
    
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil{
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
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            return
        }
        self.headersView.lblTitle.textColor = UIColor.black
        txtInput.text = v
        txtInput.textColor = UIColor.black
        row.value = v
        self.updateIfIsValid()
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
        
        //textViewDidChange(txtInput)
        if !txtInput.isFirstResponder{
            if formulaLoop == 0{
                triggerEvent("alcambiar")
                triggerRulesOnChange(nil)
            }
            formulaLoop += 1
        }
        setCodeQR(self.atributos?.generarcodigoautomatico ?? false, self.atributos?.prellenadomapeocampos ?? "", atributos?.permitirprellenadoexterno ?? false)
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
        self.row.add(ruleSet: rules)
    }
    
    // MARK: Set - QR automático o Lectura
    public func setCodeQR(_ generarQR: Bool, _ prellenado: String, _ readPrellenar: Bool){
        
        if readPrellenar {
            setQRfromPrefilled()
            imgCodeQR.isHidden = true
        } else {
            if generarQR {
                let image = generateQRCode(from: self.txtInput.text ?? "")
                if image != nil {
                    self.imgCodeQR.image = image
                    imgCodeQR.isHidden = false
                } else {
                    self.imgCodeQR.image = nil
                    imgCodeQR.isHidden = true
                }
            } else {
                imgCodeQR.isHidden = true
            }
        }
        layoutIfNeeded()
        row.reload()
    }
    
    // MARK: Set - Valores qrPrellenado
    public func setQRfromPrefilled()
    {
        do{
            let dict = try JSONSerialization.jsonObject(with: "\(self.txtInput.text ?? "")".data(using: .utf8)!, options: .mutableContainers)
            if let aux = (dict as! NSArray).firstObject as? NSDictionary {
                aux.forEach{ _ = self.formDelegate?.resolveValor("formElec_element\($0.key)", "asignacion", $0.value as! String, nil) }
            }
        } catch{ }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        if string != ""
        {
            let data = string.data(using: String.Encoding.ascii)
            guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
            qrFilter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 12, y: 12)
            if let output = qrFilter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        if isDefault{
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
//                self.viewValidation.backgroundColor = UIColor.red
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

extension CodigoQRCell{
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
