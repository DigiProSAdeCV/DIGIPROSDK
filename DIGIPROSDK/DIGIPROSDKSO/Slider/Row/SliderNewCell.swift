import Foundation

import Eureka

public class SliderNewCell: Cell<String>, CellType, UITextViewDelegate, UITextFieldDelegate {
    
    // IBOUTLETS
    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var bgHabilitado: UIView!
    @IBOutlet weak var sliderView: myCustomSlider!
    @IBOutlet weak var labelMin: UILabel!
    @IBOutlet weak var lblMinValue: UILabel!
    @IBOutlet weak var labelMax: UILabel!
    @IBOutlet weak var lblMaxValue: UILabel!
    @IBOutlet weak var btnClean: UIButton!
    @IBOutlet weak var txtValor: UITextField!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var filtroCombo: [String] = []
    public var elemento = Elemento()
    public var atributos: Atributos_Slider?
    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var valueSlider: String = ""
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    
    // PRIVATE
    var intervaloSlider: Float = 0.0
    var initialValue = ""
    var isMathematics: Bool = false
    var mathematicsName: [String] = []
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        isInfoToolTipVisible = false
        toolTip = nil
        est = nil
        sliderView?.removeTarget(self, action: nil, for: .allEvents)
    }
    
    // MARK: SETTING
    /// SetObject for SliderNewRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_Slider
        if let combo = self.formDelegate?.isfilter(idElement: elemento._idelemento), combo != ""
        {   self.filtroCombo.append(combo)  }

        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        sliderView.prefijo = atributos?.prefijo ?? ""
        sliderView.posfijo = atributos?.postfijo ?? ""
        
        txtValor.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtValor.delegate = self
        txtValor.keyboardType = .decimalPad
        txtValor.autocorrectionType = .no
        txtValor.autocapitalizationType = .sentences
        txtValor.inputAssistantItem.leadingBarButtonGroups.removeAll()
        txtValor.inputAssistantItem.trailingBarButtonGroups.removeAll()
        txtValor.keyboardAppearance = UIKeyboardAppearance.dark
        self.txtValor.text = "\(Float(atributos?.numerominimo ?? 0))"
        
        
        sliderView.value = Float(atributos?.numerominimo ?? 0)
        self.intervaloSlider = 1.0
        sliderView.maximumValue = Float(atributos?.numeromaximo ?? 0)
        self.labelMax.text = "\(Float(atributos?.numeromaximo ?? 0))"
//        self.labelMax.text = "\(atributos?.prefijo ?? "")\(" ")\(Float(atributos?.numeromaximo ?? 0))\(" ")\(atributos?.postfijo ?? "")"
        self.lblMaxValue.text = "máximo"
        sliderView.minimumValue = Float(atributos?.numerominimo ?? 0)
        self.labelMin.text = "\(Float(atributos?.numerominimo ?? 0))"
//        self.labelMin.text = "\(atributos?.prefijo ?? "")\(" ")\(Float(atributos?.numerominimo ?? 0))\(" ")\(atributos?.postfijo ?? "")"
        self.lblMinValue.text = "mínimo"
        
        initRules()
        setEstilo()
//        setPlaceholder(atributos?.mascara ?? "")
        if atributos?.titulo ?? "" == ""{ self.headersView.setOcultarTitulo(true) }else{ self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        if atributos?.subtitulo ?? "" == ""{ self.headersView.setOcultarSubtitulo(true) }else{ self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false) }
        
        
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = self.headersView.txthelp == "" ? true : false
        self.headersView.hiddenTit = false
        self.headersView.hiddenSubtit = false
        self.headersView.setTitleText(headersView.txttitulo)
        self.headersView.setSubtitleText(headersView.txtsubtitulo)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "" )
        self.headersView.setMessage("")
        
        self.headersView.translatesAutoresizingMaskIntoConstraints = false
        self.headersView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        self.headersView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.headersView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        
        self.headersView.setNeedsLayout()
        self.headersView.layoutIfNeeded()
        
        self.sliderView.translatesAutoresizingMaskIntoConstraints = false
        self.sliderView.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 20).isActive = true
        self.sliderView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 65).isActive = true
        self.sliderView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -80).isActive = true
        
        self.labelMin.translatesAutoresizingMaskIntoConstraints = false
        self.labelMin.topAnchor.constraint(equalTo: self.sliderView.bottomAnchor, constant: 5).isActive = true
        self.labelMin.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 35).isActive = true
        
        self.lblMinValue.translatesAutoresizingMaskIntoConstraints = false
        self.lblMinValue.topAnchor.constraint(equalTo: self.labelMin.bottomAnchor, constant: -1).isActive = true
        self.lblMinValue.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 35).isActive = true
    
        self.labelMax.translatesAutoresizingMaskIntoConstraints = false
        self.labelMax.topAnchor.constraint(equalTo: self.sliderView.bottomAnchor, constant: 5).isActive = true
        self.labelMax.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -50).isActive = true
        
        self.lblMaxValue.translatesAutoresizingMaskIntoConstraints = false
        self.lblMaxValue.topAnchor.constraint(equalTo: self.labelMax.bottomAnchor, constant: -1).isActive = true
        self.lblMaxValue.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -50).isActive = true
        
        self.btnClean.translatesAutoresizingMaskIntoConstraints = false
        self.btnClean.topAnchor.constraint(equalTo: self.headersView.bottomAnchor, constant: 25).isActive = true
        self.btnClean.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        self.btnClean.widthAnchor.constraint(equalToConstant: 35).isActive = true
        self.btnClean.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        
        self.txtValor.translatesAutoresizingMaskIntoConstraints = false
        self.txtValor.topAnchor.constraint(equalTo: self.sliderView.bottomAnchor, constant: 30).isActive = true
        self.txtValor.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25).isActive = true
        self.txtValor.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25).isActive = true
        
        self.bgHabilitado.translatesAutoresizingMaskIntoConstraints = false
        self.bgHabilitado.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.bgHabilitado.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.bgHabilitado.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.bgHabilitado.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        self.setHeightFromTitles()
    }
    
    override open func update() {
        super.update()
        self.valueSlider = row.value ?? "0"
        self.sliderView.isEnabled = !row.isDisabled
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
        
        let apiObject = ObjectFormManager<SliderNewCell>()
        apiObject.delegate = self
        
        sliderView.addTarget(self, action: #selector(changeValue(_: _:)), for: .valueChanged)
        btnClean.addTarget(self, action: #selector(cleanAction(_:)), for: .touchDown)
                
        //#Btn Fondo/Redondo
        btnClean.backgroundColor = UIColor.lightGray
        btnClean.layer.cornerRadius = btnClean.frame.height / 2
        btnClean.setImage(UIImage(named: "ic_clean", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        labelMin.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 10.0)
        labelMax.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 10.0)
                
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
    
    @objc func changeValue(_ sender: UISlider, _ event: UIEvent)
    {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                break
            // handle drag began
            case .moved:
                let step: Float = Float(intervaloSlider)
                let roundedValue = round(sender.value / Float(step)) * step
                sender.value = roundedValue
                self.valueSlider = "\(Int(sender.value))"
                self.txtValor.text =  "\(Float((sender.value)))"
                break
            // handle drag moved
            case .ended:
                setEdited(v: self.valueSlider)
                break
            // handle drag ended
            default:
                break
            }
        }
        
    }
   
    @objc public func cleanAction(_ sender: UIButton) {
        
        self.txtValor.text = "\(Float(atributos?.numerominimo ?? 0))"
        sliderView.maximumValue = Float(atributos?.numeromaximo ?? 0)
        sliderView.minimumValue = Float(atributos?.numerominimo ?? 0)
        sliderView.value = Float(atributos?.numerominimo ?? 0)
        valueSlider = String()
        self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
        row.value = nil
        row.validate()
        self.updateIfIsValid()
    }
    
    // MARK: TextViewDelegate
    open func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        // logica para cambiar el valor del slider
        
        let valortxt = txtValor.text!
        if let value = Float(valortxt){
            if (value > (Float(atributos!.numeromaximo))) || (value < (Float(atributos!.numerominimo))){
                
            }else{
//                self.txtValor.text =  "\(Float((sender.value)))"
            }
            sliderView.value = value


            
        }
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
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    @objc open func textFieldDidChange(_ textField: UITextField) {
    }
    
}

// MARK: - OBJECTFORMDELEGATE
extension SliderNewCell: ObjectFormDelegate{
    public func setExpresionRegular() {}
    public func setOcultarTitulo(_ bool: Bool) {}
    public func setOcultarSubtitulo(_ bool: Bool) {}
    public func setTextStyle(_ style: String) {}
    public func setDecoration(_ decor: String) {}
    public func setAlignment(_ align: String) {}
    public func setTitleText(_ text: String) {}
    public func setSubtitleText(_ text: String) {}
    
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Slider"
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
        txtValor.placeholder = text
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
        if !self.headersView.hiddenSubtit && self.headersView.txtsubtitulo != ""{
            hsttl = (CGFloat(sttl) * self.headersView.lblSubtitle.font.lineHeight)
        }
        //Total de labels
        heightHeader = httl + hsttl
        
        // Validación por si no hay titulo ni subtitulos a mostrar
        if (heightHeader - 25) < 0 {
            if !self.getRequired() && self.headersView.txthelp != "" {
                heightHeader = 40
            } else if !self.getRequired() || self.headersView.txthelp != "" {
                heightHeader = 30
            }
        }else {
            heightHeader += hmsg
        }
        
        if self.headersView.frame.height < 6.0 {
            self.headersView.heightAnchor.constraint(equalToConstant: heightHeader).isActive = true
        }
        
        // Se actualiza el tamaño de la celda, agregando el alto del header
        heightHeader = 135 + CGFloat(heightHeader)
        self.setVariableHeight(Height: heightHeader)
    }
    // MARK: Set - Info
    public func setInfo(){
    }
    
    //MARK: Set - Prefijo/Postfijo
    public func setPrefijoPosfijo()
    {
        sliderView.prefijo = atributos?.prefijo ?? ""
        sliderView.posfijo = atributos?.postfijo ?? ""
    }
    
    //MARK: Set - Estilo
    public func setEstilo()
    {
        sliderView.estilo = atributos?.estilos ?? "round"
        sliderView.updateEstilo()
    }
    
    
    public func toogleToolTip(_ help: String){
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
    public func setMinMax() {
            var rules = RuleSet<String>()
            if atributos != nil && atributos!.numeromaximo != 0{
                rules.add(rule: ReglaRangoNumerico(minNumber: Int64(atributos?.numerominimo ?? 0), maxNumber: Int64(atributos?.numeromaximo ?? 99999)))
                row.add(ruleSet: rules)
            }else if atributos != nil && atributos!.numerominimo != 0{
                rules.add(rule: ReglaRangoNumerico(minNumber: Int64(atributos?.numerominimo ?? 0), maxNumber: Int64(9999999999999), msg: "El número mínimo es \(atributos?.numerominimo ?? 0)"))
                row.add(ruleSet: rules)
            }
        
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
        if v == "" || (v == row.value) {
            self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
            return }
        if let valueFloat = Float(v)
        {   if (sliderView.maximumValue >= valueFloat) && (sliderView.minimumValue <= valueFloat)
            {   if (sliderView.value != valueFloat)
                {
//                self.labelValor.text = String(format: "elemts_slider_value".langlocalized(), v)
                    sliderView.value =  valueFloat
                }
            } else
            {   if (sliderView.value != valueFloat)
                {
//                self.labelValor.text = "Valor: \(sliderView.maximumValue < valueFloat ? sliderView.maximumValue : sliderView.minimumValue)"
                    sliderView.value =  sliderView.maximumValue < valueFloat ? sliderView.maximumValue : sliderView.minimumValue
                } else {
                    self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
                    return }
            }
        } else {
            self.headersView.lblTitle.textColor =  self.headersView.lblRequired.isHidden ?  UIColor.black : UIColor.red
            return  }
        self.headersView.lblTitle.textColor = UIColor.black
        valueSlider = v
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
        
        row.validate()
        self.updateIfIsValid()
        triggerEvent("alcambiar")
        triggerRulesOnChange(nil)
        if isMathematics, mathematicsName.count > 0{
            for math in mathematicsName{
                self.formDelegate?.obtainMathematics(math,nil)
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
        if atributos != nil, atributos?.eventos != nil{
            for evento in (atributos?.eventos.expresion)!{
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
    public func setRulesOnChange(){ }
    
    // MARK: Rules on change
    public func triggerRulesOnChange(_ action: String?){
        if rulesOnChange.count == 0{ return }
        for rule in rulesOnChange{
            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: action, forced: false, override: false)
        }
    }
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String)
    {   isMathematics = bool
        mathematicsName.append(id)
    }
}

extension SliderNewCell{
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
