import Foundation

import Eureka

open class HeaderCell: Cell<String>, CellType{
    
    // IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var bgHabilitado: UIView!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var sects: [(id:String, attributes:Atributos_seccion, elements:[String])] = [(id:String, attributes:Atributos_seccion, elements:[String])]()
    
    // PRIVATE
    public var elemento = Elemento()
    public var atributos: Atributos_seccion?
    
    public var isSectionHeader: Bool = false
    public var isTab: Bool = false
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
    }
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func setup() {
        super.setup()
        selectionStyle = .none
        lblTitle.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
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
    
    public func setElements(_ section: [(id:String, attributes: Atributos_seccion, elements: [String])]){
        sects = section
    }
    
    public func setObjectTab(obj: Elemento, isTab: Bool){
        elemento = obj
        atributos = obj.atributos as? Atributos_seccion
        lblTitle.isHidden = true
        height = {return 1}
        self.isTab = isTab
    }
    
    public func setObject(obj: Elemento, title: String, isSctHeader: Bool){
        elemento = obj
        atributos = obj.atributos as? Atributos_seccion
        isSectionHeader = isSctHeader
//        switcher.isOn = atributos?.visible ?? false
        if isSctHeader{
//            switcher.isHidden = false
            if atributos?.titulo ?? "" == ""{ setOcultarTitulo(true) }else{ setOcultarTitulo(atributos?.ocultartitulo ?? false) }
            setHeightFromTitles()
        }else{
//            switcher.isHidden = true
            lblTitle.isHidden = !isSctHeader
            height = {return 1}
        }
        
        self.elemento.validacion.visible = atributos?.visible ?? false
        if self.atributos != nil{
            self.atributos?.visible = atributos?.visible ?? false
            if atributos?.visible ?? false {
                self.row.hidden = false
            }else{
                self.row.hidden = true
            }
        }
        self.row.evaluateHidden()
        setAlignment("center")
        setBck_Clr()
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        self.setVisible(sender.isOn)
    }
    
    
}

extension HeaderCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){ }
    public func setEstadisticaV2(){ }
    // MARK: Set - TextStyle
    public func setTextStyle(_ style: String){ }
    // MARK: Set - Decoration
    public func setDecoration(_ decor: String){ }
    // MARK: Set - Alignment
    public func setAlignment(_ align: String){
        if atributos != nil{
            self.atributos?.alineadotexto = align
        }
        self.lblTitle.textAlignment = self.lblTitle.setAlignment(align)
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
        self.lblTitle.text = text
    }
    // MARK: Set - Subtitle Text
    public func setSubtitleText(_ text:String){ }
    // MARK: Set - Height From Titles
    public func setHeightFromTitles(){
        let ttl = lblTitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 10))
        lblTitle.numberOfLines = ttl
        var httl: CGFloat = 0
        if atributos != nil{
            if atributos?.ocultartitulo ?? false{ if ttl == 0{ httl = -self.lblTitle.font.lineHeight } }else{ httl = (CGFloat(ttl) * self.lblTitle.font.lineHeight) - self.lblTitle.font.lineHeight }
        }
        
        let h: CGFloat = httl
        let hh = (row as? HeaderRow)?.cell.contentView.frame.size.height ?? 0 + h
        setVariableHeight(Height: hh)
    }
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){ }
    // MARK: Set - Info
    public func setInfo(){ }
    
    public func toogleToolTip(_ help: String){ }
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){ }
    // MARK: - SET Init Rules
    public func initRules(){ }
    // MARK: Set - MinMax
    public func setMinMax(){ }
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){ }
    // MARK: Set - OcultarTitulo
    public func setOcultarTitulo(_ bool: Bool){
        self.atributos?.ocultartitulo = bool
        if bool{
            self.lblTitle.isHidden = true
            self.setTitleText("")
        }else{
            self.lblTitle.isHidden = false
            if atributos != nil{
                setTitleText(atributos?.titulo ?? "")
            }
        }
        self.layoutIfNeeded()
    }
    // MARK: Set - OcultarSubtitulo
    public func setOcultarSubtitulo(_ bool: Bool){ }
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
        self.atributos?.visible = bool
        self.formDelegate?.setVisibleEnableElementsFromSection(row.tag ?? "", atributos ?? Atributos_seccion(), false, true)
    }
    // MARK: Set - Validation
    public func resetValidation(){ }
    // MARK: Set - Requerido
    public func setRequerido(_ bool: Bool){ }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){ }
    // MARK: Events
    public func triggerEvent(_ action: String) { }
    // MARK: Set - Background & Text Color
    public func setBck_Clr(){
        if (atributos?.colorheader ?? "" == "#fff" && atributos?.colorheadertexto ?? "" == "#fff") || (atributos?.colorheader ?? "" == "#ffffff" && atributos?.colorheadertexto ?? "" == "#ffffff"){
            lblTitle.textColor = UIColor.init(hexFromString: "#000", alpha: 1)
        }else{
            self.backgroundColor = UIColor.init(hexFromString: atributos?.colorheader ?? "#fff", alpha: 1)
            lblTitle.textColor = UIColor.init(hexFromString: atributos?.colorheadertexto ?? "#000", alpha: 1)
        }
    }
    // MARK: Excecution for RulesOnProperties
    public func setRulesOnProperties(){
        triggerRulesOnProperties("")
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

extension HeaderCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{ return "" }
    public func getRowEnabled()->Bool{ return self.row.baseCell.isUserInteractionEnabled }
    public func getRequired()->Bool{ return false }
    public func getTitleLabel()->String{ return lblTitle.text ?? "" }
    public func getSubtitleLabel()->String{ return "" }
}
