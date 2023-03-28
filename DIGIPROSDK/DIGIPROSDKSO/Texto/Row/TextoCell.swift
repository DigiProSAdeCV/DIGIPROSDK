import Foundation
import Eureka
import UIKit

public class TextoCell: Cell<String>, CellType, UITextFieldDelegate {
    
    // IBOUTLETS
    @IBOutlet weak public var headersView: HeaderView!
    @IBOutlet weak var txtInput: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var lblMask: UILabel!
    @IBOutlet weak var bgHabilitado: UIView!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var filtroCombo: [(id: String, row: BaseRow)] = []
    public var elemento = Elemento()
    public var atributos: Atributos_texto?
    public var atributosPassword: Atributos_password?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    
    // PRIVATE
    var isAlEntrar: Bool = false
    var txtInicial : String = ""
    var isMathematics: Bool = false
    var mathematicsName: [String] = []
    var initialValue = ""
    var esqueleto: String = ""
    var counterRange: Int = 0
    var iconClick = true
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        atributosPassword = nil
        elemento = Elemento()
        est = nil
    }
    
    // MARK: SETTING
    /// SetObject for TextoRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_texto
        
        if self.atributos != nil, self.atributos?.esqueletoformato != nil, !(self.atributos?.esqueletoformato?.contains("Seleccione..") ?? false){
            esqueleto = self.atributos?.esqueletoformato ?? ""
            esqueleto = esqueleto.replacingOccurrences(of: "D", with: "0")
            esqueleto = esqueleto.replacingOccurrences(of: "L", with: "A")
            esqueleto = esqueleto.replacingOccurrences(of: "*", with: "*")
            if self .atributos?.esqueletoformato == ""{
                self.lblMask.isHidden = true
            }else{
                lblMask.isHidden = false
            }
            lblMask.text = esqueleto
            self.eyeButton.isHidden = true
            
            for char in esqueleto{
                if char == "0" || char == "A" || char == "*"{
                    counterRange += 1
                }
            }
        }

        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setPlaceholder(atributos?.mascara ?? "")
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? TextoRow)?.cell.formCell()?.formViewController()?.tableView
        self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false)
        self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
        
        self.printHeader()
        
        self.lblMask.translatesAutoresizingMaskIntoConstraints = false
        self.lblMask.topAnchor.constraint(equalTo: self.txtInput.bottomAnchor, constant: 5).isActive = true
        self.lblMask.leadingAnchor.constraint(equalTo: self.txtInput.leadingAnchor, constant: 0).isActive = true
        self.lblMask.trailingAnchor.constraint(equalTo: self.txtInput.trailingAnchor, constant: 0).isActive = true
    }
    
    /// SetObject for TextoRow(Password),
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObjectPassword(obj: Elemento){
        self.contentView.backgroundColor = UIColor.white
        elemento = obj
        atributosPassword = obj.atributos as? Atributos_password
        
        txtInput.isSecureTextEntry = true
        self.eyeButton.isHidden = false
        self.elemento.validacion.idunico  = atributosPassword?.idunico ?? ""
        initRules()
        setPlaceholder(atributosPassword?.mascara ?? "")
        setVisible(atributosPassword?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributosPassword?.habilitado ?? false) }
        
        self.headersView.txttitulo = atributosPassword?.titulo ?? ""
        self.headersView.txtsubtitulo = atributosPassword?.subtitulo ?? ""
        self.headersView.txthelp = atributosPassword?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? TextoRow)?.cell.formCell()?.formViewController()?.tableView
        self.headersView.setAlignment(atributosPassword?.alineadotexto ?? "")
        self.headersView.setDecoration(atributosPassword?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributosPassword?.estilotexto ?? "")
        self.headersView.setOcultarTitulo(atributosPassword?.ocultartitulo ?? false)
        self.headersView.setOcultarSubtitulo(atributosPassword?.ocultarsubtitulo ?? false)
        
        self.printHeader()
        
        self.eyeButton.translatesAutoresizingMaskIntoConstraints = false
        self.eyeButton.topAnchor.constraint(equalTo: self.txtInput.topAnchor, constant: 0).isActive = true
        self.eyeButton.trailingAnchor.constraint(equalTo: self.txtInput.trailingAnchor, constant: -5).isActive = true
        self.eyeButton.bottomAnchor.constraint(equalTo: self.txtInput.bottomAnchor, constant: 0).isActive = true
    }
    
    func printHeader(){
        //extra para no repetir código
        txtInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtInput.delegate = self
        txtInput.keyboardType = .default
        txtInput.autocorrectionType = .no
        txtInput.autocapitalizationType = .sentences
        txtInput.inputAssistantItem.leadingBarButtonGroups.removeAll()
        txtInput.inputAssistantItem.trailingBarButtonGroups.removeAll()
        txtInput.keyboardAppearance = UIKeyboardAppearance.dark
        
        self.headersView.translatesAutoresizingMaskIntoConstraints = false
        self.headersView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4).isActive = true
        self.headersView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.headersView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        
        self.headersView.setNeedsLayout()
        self.headersView.layoutIfNeeded()
        
        self.txtInput.translatesAutoresizingMaskIntoConstraints = false
        self.txtInput.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 20).isActive = true
        self.txtInput.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        self.txtInput.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        
        self.bgHabilitado.translatesAutoresizingMaskIntoConstraints = false
        self.bgHabilitado.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.bgHabilitado.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.bgHabilitado.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.bgHabilitado.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.setHeightFromTitles()
    }
    
    func updateData(){
        if row.value == nil{
            txtInput.text = ""
            self.updateIfIsValid()
        }else{
            self.setEdited(v: row.value ?? "")
            self.updateIfIsValid()
        }
    }
    
    override open func update() {
        super.update()
        // MARK: TODO- Reset function
//        if txtInput.text != ""{
//            self.updateIfIsValid()
//        }
//        if row.value == nil{
//            txtInput.text = ""
//            self.updateIfIsValid()
//        }
    }
    
    @IBAction func btnEyeAction(_ sender: Any) {
        
        if(iconClick == true) {
            self.eyeButton.setTitle("usr_lbl_pass_hide".langlocalized(), for: .normal)
            self.txtInput.isSecureTextEntry = false
        } else {
            self.eyeButton.setTitle("usr_lbl_pass_show".langlocalized(), for: .normal)
            self.txtInput.isSecureTextEntry = true
        }
        
        iconClick = !iconClick
    }
    
    // MARK: - INIT
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.white
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
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(of: self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
        initialValue = textField.text ?? ""
        row.value = textField.text
        setEstadistica()
        setEstadisticaV2()
        self.estV2!.Cambios += 1
        if !isAlEntrar{
            isAlEntrar = true
            triggerEvent("alentrar")
        }
        // Cada vez que text field se convierte en becomeFirst
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        let fechaValorFinal = Date.getTicks()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = textField.text!.replaceLineBreakEstadistic()
        elemento.estadisticas2 = estV2!
        if initialValue == textField.text ?? ""{ return }
        textFieldDidChange(textField)
        triggerEvent("alcambiar")
        triggerRulesOnChange(nil)
        if isMathematics, mathematicsName.count > 0{
            for math in mathematicsName{
                self.formDelegate?.obtainMathematics(math, nil)
            }
        }
        isAlEntrar = false
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
        // regresa cada vez que ingresamos un string
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
        // AQUI FUE DONDE ASIGNAMOS EL VALOR DEL COMBO AL TEXTFIELD
        guard let _ = textField.text else {
            row.value = nil
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            self.eyeButton.isHidden = true
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            return
        }
        
        if self.atributos != nil {
            if atributos?.longitudmaxima != 0{
                if (textField.text?.count)! > (atributos?.longitudmaxima)!{
                    textField.text = textField.text!.substring(to: atributos?.longitudmaxima ?? textField.text!.count)
                }
            }
        } else if self.atributosPassword != nil{
            if atributosPassword?.longitudmaxima != 0{
                if (textField.text?.count)! > (atributosPassword?.longitudmaxima)!{
                    textField.text = textField.text!.substring(to: atributosPassword?.longitudmaxima ?? textField.text!.count)
                }
            }
        }
        
        if self.atributos != nil{
            textField.text = textField.text!.upperLower(atributos?.mayusculasminusculas ?? "normal")
        }
        if self.atributos != nil, self.atributos?.esqueletoformato != nil, !(self.atributos?.esqueletoformato?.contains("Seleccione..") ?? false){
            row.value = txtInput.text
            let mask = JMStringMask(mask: esqueleto)
            let maskedString = mask.mask(string: txtInput.text ?? "")
            lblMask.text = maskedString
        }else{
            row.value = txtInput.text
        }
        if textField.text != "" {
            self.eyeButton.isHidden = self.atributosPassword != nil ? false : true
//            self.lblMask.text = ""
            self.headersView.lblTitle.textColor = UIColor.black
        } else {
            self.eyeButton.isHidden = true
            lblMask.text = esqueleto != "" ? esqueleto : ""
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
        }
        row.validate()
        self.updateIfIsValid()
        if filtroCombo.count > 0{
            DispatchQueue.main.async {
                self.formDelegate?.updateDataComboDinamico(idsCombo: self.filtroCombo)
            }
        }
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
extension TextoCell: ObjectFormDelegate{
    
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
        DispatchQueue.main.async {
            self.headersView.lblRequired.numberOfLines = 3
        }
        
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
        heightHeader = httl + hsttl
        
        // Validación por si no hay titulo ni subtitulos a mostrar
        if (heightHeader - 25) < 0 {
            if !self.getRequired() && self.headersView.txthelp != "" {
                heightHeader = 40
            } else if !self.getRequired() || self.headersView.txthelp != "" {
                heightHeader = 40
            }
        }else {
            heightHeader += hmsg
        }
        
        if self.headersView.frame.height < 6.0 {
            self.headersView.heightAnchor.constraint(equalToConstant: heightHeader).isActive = true
        }
        if self.lblMask.isHidden{
            heightHeader -= 10
        }
        
        // Validación extra para celda texto
        if self.atributos?.esqueletoformato != nil, !(self.atributos?.esqueletoformato?.contains("Seleccione..") ?? false){
            heightHeader = 70 + CGFloat(heightHeader)
        }else{
            heightHeader = 60 + CGFloat(heightHeader)
        }
        
        // Se actualiza el tamaño de la celda, agregando el alto del header
        self.setVariableHeight(Height: heightHeader * 1.3)
    }
    
    // Protocolos Genéricos
    // MARK: - ESTADISTICAS
    public func setEstadistica() {
        if est != nil { return }
        est = FEEstadistica()
        if atributos != nil{
            est?.Campo = "Texto"
            est?.NombrePagina = (self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
            est?.OrdenCampo = atributos?.ordencampo ?? 0
            est?.PaginaID = Int(atributos?.elementopadre.replaceFormElec() ?? "0") ?? 0
        }else if atributosPassword != nil{
            est?.Campo = "Password"
            est?.NombrePagina = (self.formDelegate?.getPageTitle(atributosPassword?.elementopadre ?? "") ?? "").replaceLineBreak()
            est?.OrdenCampo = atributosPassword?.ordencampo ?? 0
            est?.PaginaID = Int(atributosPassword?.elementopadre.replaceFormElec() ?? "0") ?? 0
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

            let tituloDePagina = self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "").replaceLineBreak()
            self.estV2?.Pagina = tituloDePagina ?? ""
            self.estV2?.IdPagina = self.formDelegate?.getPageID(atributos?.elementopadre ?? "") ?? ""
        }else if atributosPassword != nil{
            self.estV2?.IdElemento = elemento._idelemento
            self.estV2?.Titulo = atributosPassword?.titulo ?? ""
            self.estV2?.Pagina = (self.formDelegate?.getPageTitle(atributosPassword?.elementopadre ?? "") ?? "").replaceLineBreak()
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
        self.txtInput.text = self.txtInput.text?.replacingOccurrences(of: " ", with: "")
        setMinMax()
        setExpresionRegular()
        if atributos != nil{
            if self.atributos?.esqueletoformato != nil, !(self.atributos?.esqueletoformato?.contains("Seleccione..") ?? false){setExactMask()};
            self.elemento.validacion.needsValidation = atributos?.requerido ?? false
            if atributos?.requerido ?? false {
                var rules = RuleSet<String>()
                rules.add(rule: ReglaRequerido())
                self.row.add(ruleSet: rules)
            }
            self.headersView.setRequerido(atributos?.requerido ?? false)
        }else if atributosPassword != nil{
            self.elemento.validacion.needsValidation = atributosPassword?.requerido ?? false
            if atributosPassword?.requerido ?? false {
                var rules = RuleSet<String>()
                rules.add(rule: ReglaRequerido())
                self.row.add(ruleSet: rules)
            }
            self.headersView.setRequerido(atributosPassword?.requerido ?? false)
        }
    }
    // MARK: Set - MinMax
    public func setMinMax(){
        var rules = RuleSet<String>()
        if atributos != nil && atributos!.longitudminima != 0{
            rules.add(rule:ReglaMinLongitud(minLength: UInt(atributos!.longitudminima)))
        }
        
        if atributos != nil && atributos!.longitudmaxima != 0{
            rules.add(rule: ReglaMaxLongitud(maxLength: UInt(atributos!.longitudmaxima), msg: String(format: NSLocalizedString("rules_max_char", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), String(atributos?.longitudmaxima ?? 0))))
        }
        if atributosPassword != nil && atributosPassword!.longitudminima != 0{
            rules.add(rule: ReglaMinLongitud(minLength: UInt(atributosPassword!.longitudminima)))
        }
        if atributosPassword != nil && atributosPassword!.longitudmaxima != 0{
            rules.add(rule: ReglaMaxLongitud(maxLength: UInt(atributosPassword!.longitudmaxima), msg: String(format: NSLocalizedString("rules_max_char", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), String(atributosPassword?.longitudmaxima ?? 0))))
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
        if atributosPassword != nil, atributosPassword!.expresionregular != ""{
            atributosPassword?.expresionregular = atributosPassword!.expresionregular.replaceRegex()
            if atributosPassword!.regexrerrormsg != ""{
                rules.add(rule: ReglaExpReg(regExpr: atributosPassword!.expresionregular, allowsEmpty: atributosPassword!.requerido, msg: "\(atributosPassword!.regexrerrormsg)", id: nil))
            }else if atributosPassword!.mascara != ""{
                rules.add(rule: ReglaExpReg(regExpr: atributosPassword!.expresionregular, allowsEmpty: atributosPassword!.requerido, msg: "\(atributosPassword!.mascara)", id: nil))
            }else{
                rules.add(rule: ReglaExpReg(regExpr: atributosPassword!.expresionregular, allowsEmpty: atributosPassword!.requerido, msg: String(format: NSLocalizedString("rules_value", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), atributosPassword!.expresionregular), id: nil))
            }
        }
        row.add(ruleSet: rules)
    }
    // MARK: Set - Habilitado
    public func setHabilitado(_ bool: Bool){
        self.elemento.validacion.habilitado = bool
        if atributos != nil{
            self.atributos?.habilitado = bool
        }else if atributosPassword != nil{
            self.atributosPassword?.habilitado = bool
        }
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
            if self.txtInput.text != v {
                txtInput.text = v
                row.value = nil
                self.updateIfIsValid()
                triggerRulesOnChange(nil)
            }
            return
        }
        
        if row.value == v { return }
        self.headersView.lblTitle.textColor = UIColor.black
        txtInput.text = v
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
        if self.atributosPassword != nil{
            self.atributosPassword?.visible = bool
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
        if atributosPassword != nil{
            self.elemento.validacion.needsValidation = atributosPassword?.requerido ?? false
        }
    }
    // MARK: Set - Exact Mask
    public func setExactMask(){
        var rules = RuleSet<String>()
        rules.add(rule: ReglaExactaLongitud(exactLength: UInt(counterRange)))
        self.layoutIfNeeded()
        self.row.add(ruleSet: rules)
    }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        if row.value == nil && (row.isValid){
            self.elemento.validacion.validado = false
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato = ""
            DispatchQueue.main.async {
                self.headersView.setMessage("")
                self.layoutIfNeeded()
            }
            return
        }
        if row.isValid{
            DispatchQueue.main.async {
                self.headersView.setMessage("")
                self.layoutIfNeeded()
            }
            resetValidation()
            self.elemento.validacion.validado = true
            if self.atributos != nil, self.atributos?.esqueletoformato != nil, !(self.atributos?.esqueletoformato?.contains("Seleccione..") ?? false){
                let mask = JMStringMask(mask: esqueleto)
                let maskedString = mask.mask(string: txtInput.text ?? "")
                self.elemento.validacion.valor = row.value?.replaceLineBreak() ?? ""
                self.elemento.validacion.valormetadato = maskedString ?? ""
            }else{
                self.elemento.validacion.valor = row.value?.replaceLineBreak() ?? ""
                self.elemento.validacion.valormetadato  = row.value?.replaceLineBreak() ?? ""
            }
        }else{
            DispatchQueue.main.async {
                if (self.row.validationErrors.count) > 0{
                    if !self.txtInput.text!.isEmpty{
                        self.headersView.setMessage("  \(self.row.validationErrors[0].msg)  ")
                    }else if self.row.validationErrors[0].msg.lowercased().contains("requerido"){
                        self.headersView.setMessage("  \(self.row.validationErrors[0].msg)  ")
                    }
                    //
                }
            }
            self.elemento.validacion.validado = false
            self.elemento.validacion.needsValidation = true
        }
        
    }
    // MARK: Events
    public func triggerEvent(_ action: String)
    {   // alentrar
        // alcambiar
        if atributos != nil, atributos?.eventos != nil {
            for evento in (atributos?.eventos.expresion)! {
                if evento._tipoexpression == action {
                    DispatchQueue.main.async {
                        self.formDelegate?.addEventAction(evento)
                        self.txtInicial = (action == "alentrar" && (!(self.txtInput.text?.isEmpty ?? false)) ) ? self.txtInput.text! : ""
                    }
                }
            }
        }
        
       if self.atributosPassword != nil, self.atributosPassword != nil {
            for evento in (self.atributosPassword?.eventos.expresion)! {
                if evento._tipoexpression == action {
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
        if self.atributos != nil
        {
            if self.atributos?.habilitado ?? false{ triggerRulesOnProperties("enabled") }else{ triggerRulesOnProperties("notenabled") }
            if self.atributos?.visible ?? false{
                triggerRulesOnProperties("visible")
                triggerRulesOnProperties("visiblecontenido")
            }else{
                triggerRulesOnProperties("notvisible")
                triggerRulesOnProperties("notvisiblecontenido")
            }
        } else if self.atributosPassword != nil
        {
            if self.atributosPassword?.habilitado ?? false{ triggerRulesOnProperties("enabled") }else{ triggerRulesOnProperties("notenabled") }
            if self.atributosPassword?.visible ?? false{
                triggerRulesOnProperties("visible")
                triggerRulesOnProperties("visiblecontenido")
            }else{
                triggerRulesOnProperties("notvisible")
                triggerRulesOnProperties("notvisiblecontenido")
            }
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
            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: action, forced: false, override: false)
        }
    }
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){
        isMathematics = bool
        mathematicsName.append(id)
    }
}

extension TextoCell: GetInfoRowDelegate{
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
