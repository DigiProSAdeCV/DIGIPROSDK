import Foundation

import Eureka

open class FechaCell: Cell<Date>, CellType, UITextFieldDelegate {
    
    // IBOUTLETS
    
    lazy var headersView: FEHeaderView = {
        let header = FEHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
    lazy var boxDecorate: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(txtInput)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.clipsToBounds = false
        NSLayoutConstraint.activate([
            txtInput.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            txtInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            txtInput.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            txtInput.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            view.heightAnchor.constraint(equalToConstant: 44),
        ])
        return view
    }()
    lazy var txtInput: UITextField = {
        let txtInput = UITextField()
        txtInput.translatesAutoresizingMaskIntoConstraints = false
        return txtInput
    }()
    lazy var formatLabel: UILabel = {
        let txtInput = UILabel()
        txtInput.translatesAutoresizingMaskIntoConstraints = false
        return txtInput
    }()
    lazy var stackBody: UIStackView = {
        let stackBody = UIStackView()
        stackBody.axis = .vertical
        stackBody.spacing = 5
        stackBody.distribution = .fill
        stackBody.addArrangedSubview(headersView)
        stackBody.addArrangedSubview(boxDecorate)
        stackBody.addArrangedSubview(formatLabel)
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
    public var elemento = Elemento()
    public var atributos: Atributos_fecha?
    public var atributosHora: Atributos_hora?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var datePicker: UIDatePicker
    public var formato = ""
    public let formatter = DateFormatter()
    
    // PRIVATE
    var isAlEntrar: Bool = false
    var txtInicial : String = ""

    //Observables
    private var observeTextInput: NSKeyValueObservation?
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        est = nil
        datePicker.removeTarget(self, action: nil, for: .allEvents)
        observeTextInput?.invalidate()
    }
    
    // MARK: SETTING
    /// SetObject for FechaRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_fecha
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        if atributos?.formato != ""{
            self.formato = atributos!.formato
            self.formatterDate(type: self.formato)
            self.formatter.locale = Locale(identifier: "es_MX")
            self.datePicker.locale = Locale(identifier: "es_MX")
        }
        
        self.formatLabel.text = self.getFormatDate(format: self.formato)
        self.setObservableObjects()
        
        guard let atr = self.atributos else { return }
        if atr.mascara.isEmpty {
            self.txtInput.placeholder = self.getFormatDate(format: self.formato)
        } else {
            setPlaceholder(atributos?.mascara ?? "")
        }
        
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
        headersView.viewInfoHelp = (row as? FechaRow)?.cell.formCell()?.formViewController()?.tableView
        
        self.printHeader()
    }
    
    /// SetObject for FechaRow(Hora),
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObjectHora(obj: Elemento){
        elemento = obj
        atributosHora = obj.atributos as? Atributos_hora
        
        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(timePickerValueChanged(_:)), for: .valueChanged)
        datePicker.setDate(row.value ?? Date(), animated: row is CountDownPickerRow)
        datePicker.minimumDate = (row as? DatePickerRowProtocol)?.minimumDate
        datePicker.maximumDate = (row as? DatePickerRowProtocol)?.maximumDate
        if let minuteIntervalValue = (row as? DatePickerRowProtocol)?.minuteInterval {
            datePicker.minuteInterval = minuteIntervalValue
        }
        
        if atributosHora?.hora != ""{
            self.formato = (atributosHora?.hora.replacingOccurrences(of: "i", with: "mm"))!
            self.formatter.dateFormat = "\(self.formato)"
            self.formatter.locale = Locale(identifier: "es_MX")
            self.datePicker.locale = Locale(identifier: "es_MX")
        }
        
        self.formatLabel.text = self.formato.replacingOccurrences(of: "h", with: "H")
        self.formatLabel.text = self.formatLabel.text!.replacingOccurrences(of: "a", with: "AM/PM")
        self.setObservableObjects()
        
        guard let atr = self.atributosHora else { return }
        if atr.mascara.isEmpty {
            self.txtInput.placeholder = self.formatLabel.text
        } else {
            setPlaceholder(atributosHora?.mascara ?? "")
        }
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setVisible(atributosHora?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributosHora?.habilitado ?? false) }
        
        headersView.setTitleText(atributosHora?.titulo ?? "")
        headersView.setSubtitleText(atributosHora?.subtitulo ?? "")
        headersView.setHelpText(atributosHora?.ayuda ?? "")
        headersView.setRequerido(atributosHora?.requerido ?? false)
        headersView.setOcultarTitulo(atributosHora?.ocultartitulo ?? false)
        headersView.setOcultarSubtitulo(atributosHora?.ocultarsubtitulo ?? false)
        headersView.setAlignment(atributosHora?.alineadotexto ?? "")
        headersView.setDecoration(atributosHora?.decoraciontexto ?? "")
        headersView.setTextStyle(atributosHora?.estilotexto ?? "")
        headersView.btnInfo.isHidden = atributosHora?.ayuda == "" ? true : false
        headersView.viewInfoHelp = (row as? FechaRow)?.cell.formCell()?.formViewController()?.tableView
        
        self.printHeader()
    }
    
    func printHeader(){
        //extra para no repetir código
        accessoryType = .none
        editingAccessoryType =  .none
        txtInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtInput.delegate = self
        txtInput.isUserInteractionEnabled = false
        
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
    }
    
    
    ///Sets the 'NSKeyValueObservation' variables in our class. Remember to call .invalidate() in the deinit() if you add more observable objects.
    func setObservableObjects() {
        self.observeTextInput  = txtInput.observe(\UITextField.text, options: [.new,.old]) { textField, change in
            if let newValue = change.newValue as? String {
                if newValue != "" {
                    self.showFormatText()
                }
            }
        }
    }
    
    override open func update() {
        super.update()
        // MARK: TODO- Reset function
        if row.value == nil{
            txtInput.text = ""
            self.headersView.lblTitle.textColor =  self.getRequired() ? UIColor.black : Cnstnt.Color.red2
        }
        self.updateIfIsValid()
    }
    
    // MARK: - INIT
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
        self.textLabel?.isHidden = true
        self.detailTextLabel?.isHidden = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        
        self.headersView.lblTitle.textColor = UIColor.black
        row.value = datePicker.date
        txtInput.text = formatter.string(from: datePicker.date)

        if self.headersView.isInfoToolTipVisible{
            self.headersView.toolTip!.dismiss()
            self.headersView.isInfoToolTipVisible = false
        }
        
        if !isAlEntrar{
            isAlEntrar = true
            triggerEvent("alentrar")
            triggerRulesOnChange(nil)
            setRulesOnProperties()
        }
        
    }
    
    // MARK: TEXTFIELDDELEGATE
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        (row as? FechaRow)?.didSelect()
        setEstadistica()
        self.setEstadisticaV2()
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        let fechaValorFinal = Date.getTicks()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = textField.text!.replaceLineBreakEstadistic()
        elemento.estadisticas2 = estV2!
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
        guard let _ = textField.text else {
            row.value = nil
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            self.updateIfIsValid()
            triggerRulesOnChange(nil)
            return
        }
        if textField.text != "" {
            self.headersView.lblTitle.textColor = UIColor.black
        } else {
            self.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
        }
    }
    
    // MARK: - PROTOCOLS FUNCTIONS
    open override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder
    }
    
    override open var canBecomeFirstResponder: Bool {
        return !row.isDisabled
    }
    
    override open var inputView: UIView? {
        if let v = row.value {
            datePicker.setDate(v, animated:row is CountDownRow)
        }
        return datePicker
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        self.headersView.lblTitle.textColor = UIColor.black
        row.value = sender.date
        txtInput.text = formatter.string(from: datePicker.date)
        //self.formatText = self.getFormatDate(format: self.formato)
        //self.setFormatText()
        self.updateIfIsValid()
        if ( ((txtInicial != "") && (!(txtInput.text?.isEmpty ?? false)) && (txtInicial != txtInput.text) ) || ((txtInicial == "") && (!(txtInput.text?.isEmpty ?? false))))
        {
            triggerEvent("alcambiar")
            triggerRulesOnChange(nil)
            setRulesOnProperties()
        }
        isAlEntrar = false
    }
    
    @objc func timePickerValueChanged(_ sender: UIDatePicker) {
        self.headersView.lblTitle.textColor = UIColor.black
        row.value = sender.date
        txtInput.text = formatter.string(from: datePicker.date)
        self.updateIfIsValid()
        if ( ((txtInicial != "") && (!(txtInput.text?.isEmpty ?? false)) && (txtInicial != txtInput.text) ) || ((txtInicial == "") && (!(txtInput.text?.isEmpty ?? false))))
        {
            triggerEvent("alcambiar")
            triggerRulesOnChange(nil)
        }
        isAlEntrar = false
    }
    
}

// MARK: - OBJECTFORMDELEGATE
extension FechaCell: ObjectFormDelegate{
    
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
        if atributos != nil{
            est?.Campo = "Fecha"
            est?.NombrePagina = (self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
            est?.OrdenCampo = atributos?.ordencampo ?? 0
            est?.PaginaID = Int(atributos?.elementopadre.replaceFormElec() ?? "0") ?? 0
        }else if atributosHora != nil{
            est?.Campo = "Hora"
            est?.NombrePagina = (self.formDelegate?.getPageTitle(atributosHora?.elementopadre ?? "") ?? "").replaceLineBreak()
            est?.OrdenCampo = atributosHora?.ordencampo ?? 0
            est?.PaginaID = Int(atributosHora?.elementopadre.replaceFormElec() ?? "0") ?? 0
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
        }else if atributosHora != nil{
            self.estV2?.IdElemento = elemento._idelemento
            self.estV2?.Titulo = atributosHora?.titulo ?? ""
            self.estV2?.Pagina = (self.formDelegate?.getPageTitle(atributosHora?.elementopadre ?? "") ?? "").replaceLineBreak()
            self.estV2?.IdPagina = self.formDelegate?.getPageID(atributos?.elementopadre ?? "") ?? ""
        }
    }
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) {}
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
                var rules = RuleSet<Date>()
                rules.add(rule: ReglaRequerido())
                self.row.add(ruleSet: rules)
            }
            self.headersView.setRequerido(atributos?.requerido ?? false)
        } else if atributosHora != nil{
            self.elemento.validacion.needsValidation = atributosHora?.requerido ?? false
            if atributosHora?.requerido ?? false {
                var rules = RuleSet<Date>()
                rules.add(rule: ReglaRequerido())
                self.row.add(ruleSet: rules)
            }
            self.headersView.setRequerido(atributosHora?.requerido ?? false)
        }
    }
    // MARK: Set - MinMax
    public func setMinMax()
    {
        if let fecMax = atributos?.fechamax, fecMax != "-9999"
        {
            let auxdays : Int = Int(string: fecMax) ?? 0
            datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: auxdays, to: Date())!
        }
        if let fecMin = atributos?.fechamin, fecMin != "-9999"
        {
            let auxdays : Int = ( Int(string: fecMin) ?? 0 ) * -1
            datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: auxdays, to: Date())!        }
    }
    
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){ }
    // MARK: Set - Habilitado
    public func setHabilitado(_ bool: Bool){
        self.elemento.validacion.habilitado = bool
        if atributos != nil{
            self.atributos?.habilitado = bool
        }else if atributosHora != nil{
            self.atributosHora?.habilitado = bool
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
    public func setEdited(v: String, isRobot: Bool) { }
    // MARK: Set - Edited
    
    // TODO: Poner condicion para el formato
    public func setEditedFecha(v: String, format: String){
        if v == ""{
            self.headersView.lblTitle.textColor = self.getRequired() ?  UIColor.black : Cnstnt.Color.red2
            return
        }
        self.headersView.lblTitle.textColor = UIColor.black
        self.txtInput.text = self.asignarFecha(valueDate: v, typeformat: format)
        setEstadistica()
        // MARK: - Estadística
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
        updateIfIsValid()
        textFieldDidChange(txtInput)
        triggerRulesOnChange(nil)
        setRulesOnProperties()
        //triggerEvent("alentrar")
    }
    
    public func asignarFecha(valueDate: String, typeformat: String) -> String
    {
        self.formatterDate(type: typeformat)
        self.formatter.locale = Locale(identifier: "es_MX")
        if valueDate == "Date()" {
            let dateString = self.formatter.string(from: Date())
            let value = self.formatter.date(from: dateString)
            self.row.value = value
            return dateString
        } else {
            var separador = atributos?.separador ?? "/"
            if !valueDate.contains(separador) { separador = self.separadorContains(fecha: valueDate) }
            let fechaProcesed = valueDate.split{$0 == separador.first}.map(String.init)
            if fechaProcesed.count == 3{
                let value = self.formatter.date(from: "\(fechaProcesed[0])\(atributos?.separador ?? "/")\(fechaProcesed[1])\(atributos?.separador ?? "/")\(fechaProcesed[2])")
                if value != nil{
                    self.row.value = value
                    return self.formatter.string(from: value!)
                }else{
                    var fecha = ""
                    if "\(fechaProcesed[2])".count > 4 {
                        var data = ""
                        var bnd = false
                        "\(fechaProcesed[2])".forEach{ if $0.isNumber && !bnd { data += "\($0)"} else {bnd = true}}
                        fecha = "\(fechaProcesed[0])\(atributos?.separador ?? "/")\(fechaProcesed[1])\(atributos?.separador ?? "/")\(data)"
                    } else {
                        fecha = "\(fechaProcesed[0])\(atributos?.separador ?? "/")\(fechaProcesed[1])\(atributos?.separador ?? "/")\(fechaProcesed[2])"
                    }
                    let value = self.formatterContains(date: fecha)
                    if value != nil{
                        self.row.value = self.formatter.date(from: value ?? "")
                        return value ?? ""
                    }
                }
            }else{
                if fechaProcesed[0].count == 8 {
                    let start = valueDate.index(valueDate.startIndex, offsetBy: 4)
                    let end = valueDate.index(valueDate.endIndex, offsetBy: -2)
                    let range = start..<end
                    let mes = valueDate[range]
                    let anio = valueDate.prefix(4)
                    let dia = valueDate.suffix(2)
                    let value = self.formatter.date(from: "\(dia)/\(mes)/\(anio)")
                    self.row.value = value
                    return self.formatter.string(from: value!)
                }else{
                    let value = self.formatter.date(from: "\(1)/\(1)/\(2018)")
                    if value != nil{
                        self.row.value = value
                        return self.formatter.string(from: value!)
                    }
                }
            }
        }
        return ""
    }
    
    func separadorContains(fecha: String) -> String
    {   if fecha.contains("/") {
            return "/"
        } else if fecha.contains("-") {
            return "-"
        } else if fecha.contains("_") {
            return "_"
        } else if fecha.contains(".") {
            var totPunto = 0
            fecha.forEach{if $0 == "." { totPunto += 1 }}
            if totPunto > 1 {return "."}
        }
        return atributos?.separador ?? "/"
    }
    
    
    /// Sets the appropiate format text to formatLabel.
    /// - Parameter text: the specified format text to be displayed
    private func showFormatText() {
        if let _ = self.atributosHora {
            DispatchQueue.main.async {
                self.formatLabel.isHidden = false
                if self.formatLabel.alpha <= 0.0 {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.formatLabel.alpha = 1.0
                    })
                }
            }
        } else if let _ = self.atributos {
            DispatchQueue.main.async {
            self.formatLabel.isHidden = false
            if self.formatLabel.alpha <= 0.0 {
                self.formatLabel.isHidden = false
                    UIView.animate(withDuration: 0.3, animations: {
                        self.formatLabel.alpha = 1.0
                    })
                }
            }
        }
    }
    
    
    /// Gets the appropiate date format given the users configuration.
    /// - Parameter format: the specified format to be parsed
    /// - Returns: a string with the proper date format to be displayed
    private func getFormatDate(format: String) -> String
    {
        guard let atributos = self.atributos else {
            #if DEBUG
            print("Atributos nulos")
            #endif
            return "dd/mm/yyyy"
        }
        
        switch format
        {
            case "d/m/Y":
                return "dd\(atributos.separador)mm\(atributos.separador)yyyy"
                
            case "j/n/y":
                return "d\(atributos.separador)m\(atributos.separador)yy"
                
            case "m/d/Y":
                return "mm\(atributos.separador)dd\(atributos.separador)yyyy"
                
            case "n/j/y":
                return "m\(atributos.separador)d\(atributos.separador)yy"
                
            case "Y/m/d":
                return "yyyy\(atributos.separador)mm\(atributos.separador)dd"
                
            case "y/n/j":
                return "yy\(atributos.separador)m\(atributos.separador)d"
                
            default:
                return "dd/mm/yyyy"
        }
    }
    
    func formatterDate(type: String)
    {
        guard let atributos = self.atributos else {
            #if DEBUG
            print("Atributos nulos")
            #endif
            return
        }
        
        switch type
        {
            case "d/m/Y":
                self.formatter.dateFormat = "dd\(atributos.separador)MM\(atributos.separador)yyyy"
                break
            case "j/n/y":
                self.formatter.dateFormat = "d\(atributos.separador)M\(atributos.separador)yy"
                break
            case "m/d/Y":
                self.formatter.dateFormat = "MM\(atributos.separador)dd\(atributos.separador)yyyy"
                break
            case "n/j/y":
                self.formatter.dateFormat = "M\(atributos.separador)d\(atributos.separador)yy"
                break
            case "Y/m/d":
                self.formatter.dateFormat = "yyyy\(atributos.separador)MM\(atributos.separador)dd"
                break
            case "y/n/j":
                self.formatter.dateFormat = "yy\(atributos.separador)M\(atributos.separador)d"
                break
            default:
                self.formatter.dateFormat = "dd/MM/yyyy"
                break
        }
    }
    
    func formatterContains(date: String) -> String?
    {
        let formato = DateFormatter()
        formato.dateFormat = "dd\(atributos!.separador)MM\(atributos!.separador)yyyy"
        if let aux = formato.date(from: date) {
            return self.formatter.string(from: aux)
        }
        formato.dateFormat = "d\(atributos!.separador)M\(atributos!.separador)yy"
        if let aux = formato.date(from: date) {
            return self.formatter.string(from: aux)
        }
        formato.dateFormat = "MM\(atributos!.separador)dd\(atributos!.separador)yyyy"
        if let aux = formato.date(from: date) {
            return self.formatter.string(from: aux)
        }
        formato.dateFormat = "M\(atributos!.separador)d\(atributos!.separador)yy"
        if let aux = formato.date(from: date) {
            return self.formatter.string(from: aux)
        }
        formato.dateFormat = "yyyy\(atributos!.separador)MM\(atributos!.separador)dd"
        if let aux = formato.date(from: date) {
            return self.formatter.string(from: aux)
        }
        formato.dateFormat = "yy\(atributos!.separador)M\(atributos!.separador)d"
        if let aux = formato.date(from: date) {
            return self.formatter.string(from: aux)
        }
        formato.dateFormat = "dd/MM/yyyy"
        if let aux = formato.date(from: date) {
            return self.formatter.string(from: aux)
        }
        return nil
    }
    
    public func setEditedHora(v: String){
        if v == "" {
            if row.value == nil || row.value == nil {
                self.headersView.lblTitle.textColor = self.getRequired() ?  UIColor.black : Cnstnt.Color.red2
                triggerRulesOnChange("empty")
                triggerRulesOnChange("notcontains")
            }
            return
        }
        self.headersView.lblTitle.textColor = UIColor.black
        txtInput.text = self.asignarHora(valueHour: v)
        
        setEstadistica()
        self.setEstadisticaV2()
        // MARK: - Estadística
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = v.replaceLineBreakEstadistic()
        est!.KeyStroke += 1
        elemento.estadisticas = est!
        updateIfIsValid()
        textFieldDidChange(txtInput)
        triggerRulesOnChange(nil)
    }
    
    public func asignarHora(valueHour : String) -> String
    {
        let formatMetaValue = DateFormatter()
        formatMetaValue.locale = Locale(identifier: "es_MX")
        var horaChange = ""
        var auxDate : Date? = nil
        guard let atributos = atributosHora else { return ""}
        if atributos.hora.contains("i a"){
            formatMetaValue.dateFormat = "h:mm a"
            let horaChange1 = formatMetaValue.date(from: valueHour) ?? Date()
            horaChange = formatMetaValue.string(from: horaChange1)
            auxDate = formatMetaValue.date(from: horaChange)
        }else{
            formatMetaValue.dateFormat = "H:mm"
            auxDate = formatMetaValue.date(from: valueHour)
        }
        if valueHour.contains(".m.")
        {
            formatMetaValue.dateFormat = "h:mm a"
            let horaChange1 = formatMetaValue.date(from: valueHour) ?? Date()
            formatMetaValue.dateFormat = "H:mm"
            horaChange = formatMetaValue.string(from: horaChange1)
            auxDate = formatMetaValue.date(from: horaChange)
        }
        if horaChange == "" {
            formatMetaValue.dateFormat = "H:mm"
            auxDate = formatMetaValue.date(from: valueHour)
        }
        if auxDate != nil{
            row.value = auxDate
            return formatMetaValue.string(from: auxDate!)
        }
        return ""
    }

    public func setEdited(v: String){ }
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
        if self.atributosHora != nil{
            self.atributosHora?.visible = bool
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
        if atributosHora != nil{
            self.elemento.validacion.needsValidation = atributosHora?.requerido ?? false
        }
    }
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
                if row.isValid && row.value != nil {
                    self.elemento.validacion.validado = true
                    if atributos != nil{
                        let formatMetaValue = DateFormatter()
                        formatMetaValue.dateFormat = "yyyyMMdd"
                        self.elemento.validacion.valor = txtInput.text!
                        self.elemento.validacion.valormetadato  = formatMetaValue.string(from: row.value!)
                    }
                    if atributosHora != nil{
                        let formatMetaValue = DateFormatter()
                        formatMetaValue.dateFormat = "H:mm"
                        self.elemento.validacion.valor = txtInput.text!
                        self.elemento.validacion.valormetadato  = formatMetaValue.string(from: row.value!)
                    }
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
        if atributos != nil, atributos?.eventos != nil{
            for evento in (atributos?.eventos.expresion)!{
                if evento._tipoexpression == action{
                    DispatchQueue.main.async {
                        self.formDelegate?.addEventAction(evento)
                        self.txtInicial = (action == "alentrar" && (!(self.txtInput.text?.isEmpty ?? false)) ) ? self.txtInput.text! : self.txtInicial
                        if self.txtInicial != "" {  self.datePicker.setDate(self.row.value ?? Date(), animated:self.row is CountDownRow)   }
                    }
                }
            }
        }
        
        if atributosHora != nil, atributosHora?.eventos != nil{
            for evento in (atributosHora?.eventos.expresion)!{
                if evento._tipoexpression == action{
                    DispatchQueue.main.async {
                        self.formDelegate?.addEventAction(evento)
                        self.txtInicial = (action == "alentrar" && (!(self.txtInput.text?.isEmpty ?? false)) ) ? self.txtInput.text! : ""
                        if self.txtInicial != "" {  self.datePicker.setDate(self.row.value ?? Date(), animated:self.row is CountDownRow)   }
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
        } else if self.atributosHora != nil
        {
            if self.atributosHora?.habilitado ?? false{ triggerRulesOnProperties("enabled") }else{ triggerRulesOnProperties("notenabled") }
            if self.atributosHora?.visible ?? false{
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
}

extension FechaCell{
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
    public func getValueFecha()->String{
        if row.value != nil {
            return self.txtInput.text!
        } else {
            return ""
        }
    }
    public func getValueHora()->String{
        if row.value != nil {
            return self.txtInput.text!
        } else {
            return ""
        }
    }
}
