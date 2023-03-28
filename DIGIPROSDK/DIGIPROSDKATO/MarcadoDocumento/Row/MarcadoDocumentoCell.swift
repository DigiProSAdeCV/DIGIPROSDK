import Foundation
import Eureka

open class MarcadoDocumentoCell: Cell<String>, CellType {
    // IBOUTLETS
    /* @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var stackButtons: UIStackView!
    @IBOutlet weak var vwHabilitadoCheck: UIView!
    @IBOutlet weak var txtInput: UITextView!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var lblMsjtitle: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var bgHabilitado: UIView!
    */
    lazy var headersView: FEHeaderView = {
        let header = FEHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
    lazy var boxSelection: UIView = {
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
    lazy var lblMsjtitle: UILabel = {
        let lblMsjtitle = UILabel()
        lblMsjtitle.translatesAutoresizingMaskIntoConstraints = false
        return lblMsjtitle
    }()
    lazy var txtInput: UILabel = {
        let txtInput = UILabel()
        txtInput.translatesAutoresizingMaskIntoConstraints = false
        txtInput.text = "--Seleccione--"
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
        btnDrop.addTarget(self, action: #selector(self.onClickButton(_:)), for: .touchUpInside)
        btnDrop.translatesAutoresizingMaskIntoConstraints = false
        return btnDrop
    }()
    lazy var stackButtons: UIStackView = {
        let stackButtons = UIStackView()
        stackButtons.isUserInteractionEnabled = false
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
        stackBody.addArrangedSubview(lblMsjtitle)
        stackBody.addArrangedSubview(stackButtons)
        stackBody.addArrangedSubview(boxSelection)
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
    public var atributos: Atributos_marcadodocumentos?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    
    public var gralButton : DLRadioButton = DLRadioButton()
    public var catOptionCheck : Array<FEItemCatalogo> = [FEItemCatalogo]()
    public var catOptionCheck2 : Array<FEListTipoDoc> = [FEListTipoDoc]()
    
    // PRIVATE
    var otherButtons : [DLRadioButton] = []
    var timeLastRule : Date? = nil
    var lastRule : String = ""
    var btnsRequeridos = false
    var totReq = 0
    var auxVisibleViewAnimation = false

    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        rulesOnAction = []
        atributos = nil
        elemento = Elemento()
        est = nil
        (row as? MarcadoDocumentoRow)?.presentationMode = nil
        (row as? MarcadoDocumentoRow)?.customController = nil
    }
    
    // MARK: SETTING
    /// SetObject for MarcadoDocumentoRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_marcadodocumentos
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        self.setOcultarMsjOpcionCatalogo(atributos?.textoopcioncatalogo ?? "")
        self.setValuesList()
        
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
        headersView.viewInfoHelp = (row as? MarcadoDocumentoRow)?.cell.formCell()?.formViewController()?.tableView
        
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

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let row = self.formDelegate?.getElementByIdInAllForms(self.atributos?.elementodocumento.first as? String ?? "")
            if row is DocumentoRow {
                let base = row as? DocumentoRow
                base?.cell.setVariableHeight(Height: 0)
            }
        }
    }
    
    override open func update() {
        super.update()
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
    
    // MARK: - ACTIONS
    
    @objc func onClickButton(_ sender: UIButton){
        (row as? MarcadoDocumentoRow)?.onDisplaySeacthList()
    }
    // MARK: Set - Lanza video tutorial
    @objc func onTapVideo(_ sender: Any) {
        guard let localPath = Cnstnt.Path.framework?.path(forResource: "iOs Listado de Documentos", ofType: "mp4") else {
            debugPrint("video marcado not found")
            return
        }
        let auxPreview = PreviewVideoFADViewController()
        auxPreview.pathPreview = localPath
        auxPreview.isAnimation = true
        auxPreview.titleAnimation = "marcdoc_animation".langlocalized()
        auxPreview.customInit()
        auxPreview.onTapVideo()
        let presenter = Presentr(presentationType: .popup)
        self.formViewController()?.customPresentViewController(presenter, viewController: auxPreview, animated: true)
    }
    
    // Ejecuta la selección de checks
    @objc public func selectedButton(radioButton : DLRadioButton, isRobot: Bool) {
        var listRowDesc = ""
        var listRowId = ""
        var isSelectOK = false
        
        if radioButton.selectedButtons().count > 0
        {
            if (atributos?.requerido ?? false) && (atributos?.opcionrequerida != "")
            {
                isSelectOK = true
                let listReq = atributos?.opcionrequerida.split(separator: ",")
                var selecReq : [Int] = []
                if !self.catOptionCheck.isEmpty
                {
                    radioButton.selectedButtons().forEach{ rdId in
                        print(rdId.tag)
                        listReq?.forEach{ id in
                            if id == String(rdId.tag)
                            {   selecReq.append(rdId.tag) }
                        }
                    }
                } else if !self.catOptionCheck2.isEmpty
                {
                    radioButton.selectedButtons().forEach{ rdId in
                        print(rdId.tag)
                        if listReq?.contains(where: {$0 == String(rdId.tag)}) ?? false
                        {   selecReq.append(rdId.tag)   }
                    }
                }
                if listReq?.count != selecReq.count
                {   if (self.totReq == selecReq.count) {
                    self.headersView.lblTitle.textColor = UIColor.black
                        btnsRequeridos = true
                    } else {
                        self.headersView.lblTitle.textColor = UIColor.red
                        btnsRequeridos = false
                    }
                } else {
                    self.headersView.lblTitle.textColor = UIColor.black
                    btnsRequeridos = true
                }
            } else
            {
                isSelectOK = true
                self.headersView.lblTitle.textColor = UIColor.black
                btnsRequeridos = true
            }
        } else
        {
            if (atributos?.requerido ?? false) && (atributos?.opcionrequerida != "")
            {} else {
                btnsRequeridos = true
                self.headersView.lblTitle.textColor = UIColor.black
            }
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato  = ""
            self.elemento.validacion.id = ""
            
            setEdited(v: "--Seleccione--", isRobot: isRobot)
        }
        
        if isSelectOK
        {   for button in radioButton.selectedButtons()
            {
                listRowId = listRowId != "" ? "\(listRowId),\(button.tag)" : "\(button.tag)"
                listRowDesc = listRowDesc != "" ? "\(listRowDesc),\(button.titleLabel!.text!)" : "\(button.titleLabel!.text!)"
            }
            listRowId = listRowId.replacingOccurrences(of: " *", with: "")
            listRowDesc = listRowDesc.replacingOccurrences(of: " *", with: "")

            switch self.atributos?.tipoasociacion{
            case "idid":
                self.elemento.validacion.valor = listRowId
                self.elemento.validacion.valormetadato  = listRowId
                break
            case "descid":
                self.elemento.validacion.valor = listRowId
                self.elemento.validacion.valormetadato  = listRowDesc
                break
            case "iddesc":
                self.elemento.validacion.valor = listRowDesc
                self.elemento.validacion.valormetadato  = listRowId
                break
            case "descdesc":
                self.elemento.validacion.valor = listRowDesc
                self.elemento.validacion.valormetadato  = listRowDesc
                break
            default:
                self.elemento.validacion.valor = listRowDesc
                self.elemento.validacion.valormetadato  = listRowDesc
                break
            }
            self.elemento.validacion.id = listRowId
            setEdited(v: listRowDesc, isRobot: isRobot ? isRobot: listRowDesc.contains(","))
        }
    }

}

// MARK: - OBJECTFORMDELEGATE
extension MarcadoDocumentoCell: ObjectFormDelegate{
    
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
        est?.Campo = "MarcadoDocumentos"
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
    public func setVariableHeight(Height h: CGFloat) {}
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){ }
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil{
            self.elemento.validacion.needsValidation = atributos?.requerido ?? false
            if atributos?.requerido ?? false {
                var rules = RuleSet<String>()
                rules.add(rule: ReglaListaRequerido())
                self.row.add(ruleSet: rules)
            }
            self.headersView.setRequerido(atributos?.requerido ?? false)
        }
    }
    // MARK: Set - MinMax
    public func setMinMax(){ }
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){ }
    // MARK: Set - OcultarMsjOpcionCatalogo
    public func setOcultarMsjOpcionCatalogo(_ text: String){
        if text == ""{
            self.lblMsjtitle.isHidden = true
        }else{
            self.lblMsjtitle.isHidden = false
            self.lblMsjtitle.text = text
        }
    }
    // MARK: Set - Habilitado
    public func setHabilitado(_ bool: Bool){
        self.elemento.validacion.habilitado = bool
        self.atributos?.habilitado = bool
        if bool{
            self.bgHabilitado.isHidden = true
            self.row.baseCell.isUserInteractionEnabled = true
            self.row.disabled = false
        }else{
            self.bgHabilitado.isHidden = false
            self.row.baseCell.isUserInteractionEnabled = false
            self.row.disabled = true
        }
        self.row.evaluateDisabled()
    }
    // MARK: Set - Edited
    public func setEdited(v: String){ }
    public func setEdited(v: String, isRobot: Bool = false){
        if v == "" || v == "--Seleccione--"{ return }
        if v == "sinSelección"
        {   txtInput.text = "--Seleccione--"
            row.value = nil
            return
        }
        if v.contains("|")
        {
            let auxValues = v.split(separator: "|")
            if v.split(separator: "|").count >= 2{
                txtInput.text = String(auxValues[1])
            }
            row.value = String(auxValues[0])
        } else{
            if isRobot
            {   txtInput.text = "--Seleccione--"
                if self.elemento.validacion.valormetadato != "" {   row.value = self.elemento.validacion.valormetadato  }
            } else
            {   txtInput.text = v.contains(",") && v.contains(txtInput.text ?? "") ? txtInput.text : v  }
        }
         if gralButton.selectedButtons().isEmpty && v != "--Seleccione--" && v != "sinSelección" && (v.contains ("|") || v.contains (","))
        {
            let titGral = gralButton.titleLabel!.text?.contains(" *") ?? false ? gralButton.titleLabel!.text?.replacingOccurrences(of: " *", with: "") : gralButton.titleLabel!.text
            if v.contains("|")
            {
                if v.split(separator: "|").count >= 2{
                    let auxValues = v.split(separator: "|")
                    gralButton.isSelected = (String(auxValues[1]) == titGral) || (String(auxValues[1]) == "\(gralButton.tag)") ? true : false
                    for ids in (String(auxValues[0])).split(separator: ",")
                    {
                        gralButton.isSelected = ("\(gralButton.tag)" == String(ids)) ? true : gralButton.isSelected
                        self.gralButton.otherButtons.forEach { btn in
                            let titBtn = btn.titleLabel!.text!.contains(" *") ? btn.titleLabel!.text!.replacingOccurrences(of: " *", with: "") : btn.titleLabel!.text!
                            btn.isSelected = (String(auxValues[1]) == titBtn) || (String(auxValues[1]) == "\(btn.tag)") || ("\(btn.tag)" == String(ids)) ? true : btn.isSelected
                        }
                    }
                }
            } else if v.contains(",")
            {
                self.gralButton.isSelected = (v.split(separator: ",")).contains(where: { (String($0) == titGral) || (String($0) == "\(self.gralButton.tag)")})
                self.gralButton.otherButtons.forEach { btn in
                    let titBtn = btn.titleLabel!.text!.contains(" *") ? btn.titleLabel!.text!.replacingOccurrences(of: " *", with: "") : btn.titleLabel!.text!
                    btn.isSelected = (v.split(separator: ",")).contains(where: { (String($0) == titBtn) || (String($0) == "\(btn.tag)")})
                }
            }
            self.selectedButton(radioButton: self.gralButton, isRobot: isRobot)
        } else
        {   // MARK: - Setting estadisticas
            setEstadistica()
            est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
            est!.Resultado = v.replaceLineBreak()
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
        }

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
    public func resetValidation(){
        if atributos != nil{
            self.elemento.validacion.needsValidation = atributos?.requerido ?? false
        }
    }
    // MARK: Set - Default Value
    public func setDefaultValue(){
        var rules = RuleSet<String>()
        rules.add(rule: ReglaListaValor())
        self.layoutIfNeeded()
        self.row.add(ruleSet: rules)
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
        if /*row.isValid &&*/ self.btnsRequeridos {
            // Setting row as valid
            if row.value == nil{
                DispatchQueue.main.async {
                    self.headersView.setMessage("")
                    self.layoutIfNeeded()
                }
                self.elemento.validacion.validado = false
            }else{
                resetValidation()
                if btnsRequeridos && (row.value != "" && row.value != "--Seleccione--") {
                    self.elemento.validacion.validado = true
                    self.headersView.setMessage("")
                }else{
                    self.elemento.validacion.validado = false
                    self.headersView.setMessage( "rules_select".langlocalized())
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
        }
    }
    
    // MARK: Set - ValuesList
    public func setValuesList () {
        var isCheck2 = false
        var tamList = 0
        if !self.catOptionCheck2.isEmpty {
            isCheck2 = true
            tamList = self.catOptionCheck2.count
        } else if !self.catOptionCheck.isEmpty {
            isCheck2 = false
            tamList = self.catOptionCheck.count
        }
        self.gralButton = DLRadioButton()
        self.otherButtons = []
        let auxViews = self.stackButtons.arrangedSubviews
        auxViews.forEach{ viewBtn in
            self.stackButtons.removeArrangedSubview(viewBtn)
            viewBtn.removeFromSuperview()
        }
        totReq = 0
        ((row as? MarcadoDocumentoRow)?.customController?.form.last)!.removeAll()
        for i in 0..<tamList {
            let cell = CustomCellMarcadoD()
            var valorItem = isCheck2 ? self.catOptionCheck2[i].Descripcion : self.catOptionCheck[i].Descripcion
            let idItem = isCheck2 ? self.catOptionCheck2[i].CatalogoId : self.catOptionCheck[i].CatalogoId
            
            ((row as? MarcadoDocumentoRow)?.customController?.form.last!)! <<< ListCheckRow<String>(String(idItem))
            { listRow in
                listRow.title = valorItem
                listRow.selectableValue = valorItem
                listRow.value = nil
                let base = row as? DocumentoRow
                base?.cell.setVariableHeight(Height: 0)

            }.onChange(
                { (row) in
                    let lista = ((self.row as? MarcadoDocumentoRow)?.customController?.form.first) as! SelectableSection<ListCheckRow<String>>
                    let selectedValues = "\(lista.selectedRow()?.tag ?? "")"
                    let showedValues = "\(lista.selectedRow()?.selectableValue! ?? "")"
                    if ((self.atributos?.elementodocumento.first) != nil)
                    {   var conCamara = false
                        var conImportar = false
                        self.atributos?.cargacamara.split{$0 == ","}.map(String.init).forEach{ if $0 == selectedValues { conCamara = true }}
                        self.atributos?.cargaimportacion.split{$0 == ","}.map(String.init).forEach{ if $0 == selectedValues { conImportar = true }}
                        let row = self.formDelegate?.getElementByIdInAllForms(self.atributos?.elementodocumento.first as? String ?? "")
                        if row is DocumentoRow
                        {
                            let base = row as? DocumentoRow
                            base?.cell.isMarcado = "\(self.elemento._idelemento)"
                            base?.cell.atributos.permisotipificar = false
                            let tipificacionUnica: NSMutableDictionary = NSMutableDictionary()
                            tipificacionUnica["enabled"] = "true"
                            tipificacionUnica["idtype"] = selectedValues
                            base?.cell.atributos.tipificacionunica = tipificacionUnica
                            base?.cell.setPermisoCamara(conCamara)
                            base?.cell.setPermisoImportar(conImportar)
                            base?.cell.setVisible(true)
                            base?.cell.getTipificacionPermitida()
                            base?.cell.update()
                            if base!.cell.fedocumentos.isEmpty{
                                base?.cell.setVariableHeight(Height: 120)
                            }else{
                                base?.cell.setVariableHeight(Height: 410)
                            }
                        }
                    }
                    self.setEdited(v: showedValues, isRobot: false)
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        (self.row as? MarcadoDocumentoRow)?.customController?.cerrarAction(Any.self)
                    })
                }
            )
            
            if (self.atributos?.requerido ?? false) && (self.atributos?.opcionrequerida != "")
            {   let arrayReq = (self.atributos?.opcionrequerida ?? "").split(separator: ",")
                arrayReq.forEach{ if Int($0) == idItem {
                    valorItem = "\(valorItem) *"
                    totReq += 1 }
                }
            }
            cell.data = CustomDataCell(title: valorItem, id: idItem, tipo: atributos?.tipolista ?? "")
            cell.btnCheck.addTarget(self, action: #selector(MarcadoDocumentoCell.selectedButton), for: UIControl.Event.touchUpInside)
            
            if i == 0{
                self.gralButton = cell.btnCheck
            }else{
                self.otherButtons.append(cell.btnCheck)
                self.gralButton.otherButtons = otherButtons
            }
            self.stackButtons.addArrangedSubview(cell)
        }
        if atributos?.requerido ?? false && atributos?.opcionrequerida != "" && totReq != 0{
            self.headersView.setRequerido(true)
            btnsRequeridos = false
        } else {
            self.headersView.setRequerido(false)
            btnsRequeridos = true
        }
       // heightChecks = CGFloat(30 * (tamList))
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
            if rule["conditions"].children.count == 0{ continue }
            for condition in rule["conditions"].children{
                for subject in condition["subject"].children{
                    if subject["subject"].value == row.tag{
                        if timeLastRule == nil
                        {   timeLastRule = Date()
                            lastRule = rule.name
                            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: subject["verb"].value, forced: false, override: false)
                        } else
                        {
                            let dateFMT = DateFormatter()
                            dateFMT.locale = Locale(identifier: "es_MX")
                            dateFMT.dateFormat = "yyyyMMdd'T'HHmmss.SSSS"
                            let aux = String(format: "%@", dateFMT.string(from: Date()))
                            let aux2 = String(format: "%@", dateFMT.string(from: timeLastRule ?? Date()))
                            let intevalo = (dateFMT.date(from: aux) ?? Date()).timeIntervalSinceReferenceDate - (dateFMT.date(from: aux2) ?? Date()).timeIntervalSinceReferenceDate
                            if (rule.name != lastRule) || (intevalo > 1)
                            {   timeLastRule = Date()
                                lastRule = rule.name
                                _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: subject["verb"].value, forced: false, override: false)
                            } else {return}
                        }
                        
                    }
                }
            }
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
    
    // MARK: - Execute animation
    public func executeAnimation(){
        self.onTapVideo(Any.self)
    }
}

extension MarcadoDocumentoCell{
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
    public func getTxtInput()->String{
        return self.txtInput.text ?? ""
    }
}

struct CustomDataCell {
    var title: String
    var id: Int
    var tipo: String
}

class CustomCellMarcadoD: UIView {
    var data: CustomDataCell? {
        didSet {   guard let data = data else { return }
            btnCheck.setTitle(data.title, for: [])
            btnCheck.tag = data.id
            if data.tipo == "radio"{
                btnCheck.isMultipleSelectionEnabled = false
            } else{
                btnCheck.isMultipleSelectionEnabled = true
                btnCheck.isIconSquare = true
            }
        }
    }
    
    var btnCheck: DLRadioButton = {
        let radioButton = DLRadioButton(frame: .zero)
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.titleLabel!.font = UIFont.systemFont(ofSize: 12)
        radioButton.setTitleColor(.black, for: .normal)
        radioButton.setTitleColor(.white, for: .selected)
        radioButton.titleLabel!.adjustsFontForContentSizeCategory = true
        radioButton.titleLabel!.lineBreakMode = .byWordWrapping
        radioButton.titleLabel!.numberOfLines = 0
        radioButton.iconColor = UIColor.black
        radioButton.indicatorColor = UIColor.black
        radioButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        return radioButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        addSubview(btnCheck)
        NSLayoutConstraint.activate([
            btnCheck.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            btnCheck.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            btnCheck.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            btnCheck.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
