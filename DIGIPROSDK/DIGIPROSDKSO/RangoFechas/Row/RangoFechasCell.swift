import Foundation

import Eureka

public class RangoFechasCell: Cell<String>, CellType, UITextFieldDelegate, CalendarDateRangePickerViewControllerDelegate {
    
    // IBOUTLETS
    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var txtInput: UITextField!
    @IBOutlet weak var bgHabilitado: UIView!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var filtroCombo: [String] = []
    
    // PRIVATE
    var navigationController: UINavigationController?
    public var elemento = Elemento()
    public var atributos: Atributos_rangofechas?

    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var formato = ""
    public let formatter = DateFormatter()
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        isInfoToolTipVisible = false
        toolTip = nil
        est = nil
        estV2 = nil
        txtInput.text = ""
    }
    
    @IBAction func RangoBtnAction(_ sender: Any) {
        let dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        dateRangePickerViewController.delegate = self
        
        setMinMax(dateRangePickerViewController)
        setValorInValorFin(dateRangePickerViewController)
        dateRangePickerViewController.title = "elemts_range".langlocalized()
        navigationController = UINavigationController(rootViewController: dateRangePickerViewController)
        (row as? RangoFechasRow)?.baseCell.formViewController()?.navigationController?.present(navigationController!, animated: true, completion: nil)
    }
    
    public func didTapCancel() {
        row.value = nil
        txtInput.text = ""
        self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
        self.updateIfIsValid()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    public func didTapDoneWithDateRange(startDate: Date!, endDate: Date!) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "\(self.formato)"
        var start = dateformatter.string(from: startDate)
        var end = dateformatter.string(from: endDate)
        start = start.replacingOccurrences(of: "/", with: "\(atributos!.separador)")
        end = end.replacingOccurrences(of: "/", with: "\(atributos!.separador)")
        
        self.row.value = "\(start) - \(end)"
        self.elemento.validacion.valormetadatoinicial = "\(start)"
        self.elemento.validacion.valormetadatofinal = "\(end)"
        self.elemento.validacion.valormetadatorango = "\(start) - \(end)".replaceLineBreak()
        setEdited(v: "\(start) - \(end)")
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        
        if isInfoToolTipVisible{
            toolTip!.dismiss()
            isInfoToolTipVisible = false
        }
    }
    
    // MARK: SETTING
    /// SetObject for RangoFechasRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_rangofechas
        if let combo = self.formDelegate?.isfilter(idElement: elemento._idelemento), combo != ""
        {   self.filtroCombo.append(combo)  }
        
        txtInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtInput.delegate = self
        txtInput.keyboardType = .default
        txtInput.autocorrectionType = .no
        txtInput.autocapitalizationType = .sentences
        txtInput.inputAssistantItem.leadingBarButtonGroups.removeAll()
        txtInput.inputAssistantItem.trailingBarButtonGroups.removeAll()
        txtInput.keyboardAppearance = UIKeyboardAppearance.dark
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        
        if atributos?.valorinicial != nil, atributos?.valorfinal != nil{
            if atributos?.valorinicial.isEmpty ?? true && atributos?.valorfinal.isEmpty ?? true{
                txtInput.text = ""
            }else{
                let valorinicial = atributos?.valorinicial.replacingOccurrences(of: "/", with: "\(atributos!.separador)")
                let valorfinal = atributos?.valorfinal.replacingOccurrences(of: "/", with: "\(atributos!.separador)")
                txtInput.text = "\(valorinicial ?? "") - \(valorfinal ?? "")"
            }
        }
        
        if atributos!.formato != ""{
//            self.formato = atributos!.formato.replacingOccurrences(of: "m", with: "M")
//            self.formato = self.formato.replacingOccurrences(of: "n/", with: "")
//            self.formato = self.formato.replacingOccurrences(of: "j", with: "EEEE")
//            self.formato = self.formato.replacingOccurrences(of: "/", with: "\(atributos!.separador)")
//            self.formatter.dateFormat = "\(self.formato)"
//            self.formatter.locale = Locale(identifier: "es_MX")
            self.formato = self.formatterDate(type: self.atributos?.formato ?? "")
        }
        
        initRules()
        setPlaceholder(atributos?.mascara ?? "")
        
        if atributos?.titulo ?? "" == ""{ self.headersView.setOcultarTitulo(true) }else{ self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        if atributos?.subtitulo ?? "" == ""{ self.headersView.setOcultarSubtitulo(true) }else{ self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false) }
        
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.viewInfoHelp = (row as? RangoFechasRow)?.cell.formCell()?.formViewController()?.tableView
        self.headersView.hiddenTit = false
        self.headersView.hiddenSubtit = false
        self.headersView.setTitleText(headersView.txttitulo)
        self.headersView.setSubtitleText(headersView.txtsubtitulo)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
        self.headersView.setMessage("")
        
        self.headersView.translatesAutoresizingMaskIntoConstraints = false
        self.headersView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        self.headersView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.headersView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        
        self.headersView.setNeedsLayout()
        self.headersView.layoutIfNeeded()
        
//        self.lblCurrency.translatesAutoresizingMaskIntoConstraints = false
//        self.lblCurrency.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 15).isActive = true
//        self.lblCurrency.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 18).isActive = true
//        self.lblCurrency.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -150).isActive = true
        
        self.txtInput.translatesAutoresizingMaskIntoConstraints = false
        self.txtInput.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 15).isActive = true
        self.txtInput.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 35).isActive = true
        self.txtInput.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        
        self.bgHabilitado.translatesAutoresizingMaskIntoConstraints = false
        self.bgHabilitado.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.bgHabilitado.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.bgHabilitado.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.bgHabilitado.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader)
    }
    
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        
        let apiObject = ObjectFormManager<RangoFechasCell>()
        apiObject.delegate = self
        txtInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtInput.delegate = self
        txtInput.keyboardType = .default
        txtInput.autocorrectionType = .no
        txtInput.autocapitalizationType = .sentences
        txtInput.inputAssistantItem.leadingBarButtonGroups.removeAll()
        txtInput.inputAssistantItem.trailingBarButtonGroups.removeAll()
        txtInput.keyboardAppearance = UIKeyboardAppearance.dark
        
//        lblRequired.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 30.0)
//        txtInput.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 16.0)
//        lblMessage.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
//        lblTitle.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
//        lblSubtitle.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
//        btnInfo.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 15.0)
    }
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) {
        guard let _ = self.atributos, let help = atributos?.ayuda else{
            return;
        }
        toogleToolTip(help)
    }
    override open func update() {
        super.update()
    }
    
    // MARK: TextFieldDelegate
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.RangoBtnAction((Any).self)
        setEstadistica()
        self.setEstadisticaV2()
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
        self.setEstadisticaV2()
        let fechaValorFinal = Date.getTicks()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = textField.text!.replaceLineBreakEstadistic()
        elemento.estadisticas2 = estV2!
        triggerEvent("alcambiar")
        triggerRulesOnChange(nil)
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    
    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // Update data ComboDinamico
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    @objc open func textFieldDidChange(_ textField: UITextField) {
        
        guard let _ = textField.text else {
            row.value = nil
            self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
            self.updateIfIsValid()
            return
        }
        self.headersView.lblTitle.textColor = UIColor.black
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

extension RangoFechasCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Rango Fecha"
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
    // MARK: Set - TextStyle
    public func setTextStyle(_ style: String){
    }
    // MARK: Set - Decoration
    public func setDecoration(_ decor: String){
    }
    // MARK: Set - Alignment
    public func setAlignment(_ align: String){
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
        txtInput.placeholder = text
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
            toolTip?.show(forView: self.headersView.btnInfo, withinSuperview: (row as? RangoFechasRow)?.cell.formCell()?.formViewController()?.tableView)
            isInfoToolTipVisible = true
        }
    }
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){
        // message, valid, alert, error
        self.headersView.setMessage(string)
    }
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil{ setRequerido(atributos?.requerido ?? false)
        }
    }
    // MARK: Set - MinMax
    public func setMinMax(){ }
    public func setMinMax(_ calendar: CalendarDateRangePickerViewController)
    {
        atributos?.fechamax = atributos?.fechamax == 0 ? -9999 : atributos!.fechamax
        atributos?.fechamin = atributos?.fechamin == 0 ? -9999 : atributos!.fechamin

        if let fecMaxR = atributos?.fechamax, fecMaxR != -9999
        {
            calendar.maximumDate = Calendar.current.date(byAdding: .day, value: fecMaxR, to: Date())!
        }
        if let fecMinR = atributos?.fechamin, fecMinR != -9999
        {
            calendar.minimumDate = Calendar.current.date(byAdding: .day, value: (fecMinR * -1), to: Date())!
        }
        
    }
    
    // MARK: Set - ValorInValorFin
    public func setValorInValorFin(_ calendar: CalendarDateRangePickerViewController)
    {
        if (atributos?.valorinicial != "" && atributos?.valorfinal != "")
        {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "dd/MM/yyyy"
            
            if let valorInicial = dateformatter.date(from: atributos!.valorinicial), let valorFinal = dateformatter.date(from: atributos!.valorfinal)
            {
                calendar.selectedStartDate = valorInicial
                calendar.selectedEndDate = valorFinal
                
            }
        } else {
            calendar.selectedStartDate = Date()
            let fecMaxR = (atributos?.fechamax == -9999 || atributos!.fechamax > 10 ) ? 10 : (atributos!.fechamax / 2)
            calendar.selectedEndDate = Calendar.current.date(byAdding: .day, value: fecMaxR, to: Date())
        }
    }
    
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){ }
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
            self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
            return }
        self.headersView.lblTitle.textColor = UIColor.black
        txtInput.text = v
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
        
        textFieldDidChange(txtInput)
        triggerEvent("alcambiar")
        triggerRulesOnChange(nil)
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
            self.elemento.validacion.valormetadatorango = ""
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
                self.elemento.validacion.valormetadatorango = ""
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
                    self.elemento.validacion.valormetadato = ""
                    
                    
                }else{
                    self.elemento.validacion.validado = false
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                    self.elemento.validacion.valormetadatorango = ""
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
            self.elemento.validacion.valormetadatorango = ""
        }
    }
    // MARK: Events
    public func triggerEvent(_ action: String)
    {   // alentrar
        // alcambiar
        if atributos != nil, atributos?.eventos != nil{
            for evento in (atributos?.eventos.expresion)!{
                if evento._tipoexpression == action
                {   DispatchQueue.main.async
                    {
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
    public func setMathematics(_ bool: Bool, _ id: String){ }
    
    
    func formatterDate(type: String) -> String
    {
        switch type
        {
            case "d/m/Y":
                return "dd\(atributos!.separador)MM\(atributos!.separador)yyyy"
                
            case "j/n/y":
                return "d\(atributos!.separador)M\(atributos!.separador)yy"
            case "m/d/Y":
                return "MM\(atributos!.separador)dd\(atributos!.separador)yyyy"
            case "n/j/y":
                return "M\(atributos!.separador)d\(atributos!.separador)yy"
            case "Y/m/d":
                return "yyyy\(atributos!.separador)MM\(atributos!.separador)dd"
            case "y/n/j":
                return "yy\(atributos!.separador)M\(atributos!.separador)d"
            default:
                return "dd/MM/yyyy"
        }
    }
    
}

extension RangoFechasCell{
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
