import Foundation

import Eureka

open class HeaderTabCell: Cell<String>, CellType{
    
    public var sects: [(id:String, attributes:Atributos_seccion, elements:[String])] = [(id:String, attributes:Atributos_seccion, elements:[String])]()
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    
    // PRIVATE
    public var elemento = Elemento()
    public var atributos: Atributos_tabber?

    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
    }
    
    let pagesScrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        v.isScrollEnabled = true
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        return v
    }()
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func setup() {
        super.setup()
        height = { return 40 }
        selectionStyle = .none
    }
    
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) { }
    
    @objc func segmentSelected(_ sender:UIButton?) {
        if sender?.tag ?? -1 == -1{ return }
        let normal = UIColor(hexFromString: "#3d9970")
        let activo = UIColor(hexFromString: "#3c8dbc")
        self.pagesScrollView.subviews.forEach({
            if $0.isKind(of: UIButton.self){
                $0.backgroundColor = normal
                $0.isUserInteractionEnabled = true
            }
        })
        sender?.backgroundColor = activo
        sender?.isUserInteractionEnabled = false
        segmentedControlAction(sender?.tag ?? 0)
    }
    
    override open func update() {
        super.update()
    }

    public func rldSegments(){
        var totalWidth: CGFloat = 0.0
        let normal = UIColor(hexFromString: "#3d9970")
        let _ = UIColor(hexFromString: "#3c8dbc")
        let inhabilitado = UIColor(hexFromString: "#cccccc")
        
        self.pagesScrollView.subviews.forEach({
            if $0.isKind(of: UIButton.self){
                let pagina = sects[$0.tag]
                if pagina.attributes.habilitado{
                    if pagina.attributes.visible{
                        for c in $0.constraints { if c.firstAttribute == .width { c.constant = $0.intrinsicContentSize.width + 20 } }
                        $0.isHidden = false
                        $0.isUserInteractionEnabled = true
                        $0.backgroundColor = normal
                        totalWidth += $0.intrinsicContentSize.width + 20.0
                    }else if !pagina.attributes.visible{
                        for c in $0.constraints { if c.firstAttribute == .width { c.constant = 0 } }
                        $0.isHidden = true
                    }
                }else{
                    for c in $0.constraints { if c.firstAttribute == .width { c.constant = $0.intrinsicContentSize.width + 20 } }
                    $0.isHidden = false
                    $0.isUserInteractionEnabled = false
                    $0.backgroundColor = inhabilitado
                    totalWidth += $0.intrinsicContentSize.width + 20.0
                }
            }
        })
        pagesScrollView.layoutIfNeeded()
        pagesScrollView.layoutSubviews()
        pagesScrollView.contentSize = CGSize(width: totalWidth, height: 40)
        self.selectOption(0)
    }
    
    public func setObject(obj: Elemento, _ sections: [(id:String, attributes:Atributos_seccion, elements:[String])]){
        
        elemento = obj
        atributos = obj.atributos as? Atributos_tabber
        
        sects = sections

        var firstVisibility: UIButton? = nil
        addSubview(pagesScrollView)
        pagesScrollView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0).isActive = true
        pagesScrollView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
        pagesScrollView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0).isActive = true
        pagesScrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0).isActive = true
        
        var leading = pagesScrollView.leadingAnchor
        var totalWidth: CGFloat = 0.0
        
        let normal = UIColor(hexFromString: "#3d9970")
        let inhabilitado = UIColor(hexFromString: "#cccccc")
        
        for (index, pagina) in sects.enumerated(){
            
            let label = UIButton()
            label.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            label.setTitle(pagina.attributes.titulo, for: .normal)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.addTarget(self, action: #selector(segmentSelected(_:)), for: .touchUpInside)
            label.tag = index
            
            pagesScrollView.addSubview(label)
            label.leadingAnchor.constraint(equalTo: leading, constant: 0).isActive = true
            label.topAnchor.constraint(equalTo: pagesScrollView.topAnchor, constant: 0).isActive = true
            label.heightAnchor.constraint(equalToConstant: 40).isActive = true
            if pagina.attributes.habilitado{
                if pagina.attributes.visible{
                    label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width + 20).isActive = true
                    leading = label.trailingAnchor
                    label.isHidden = false
                    label.isUserInteractionEnabled = true
                    label.backgroundColor = normal
                    totalWidth += label.intrinsicContentSize.width + 20.0
                    if firstVisibility == nil{
                        firstVisibility = label
                    }
                }else if !pagina.attributes.visible{
                    label.widthAnchor.constraint(equalToConstant: 0).isActive = true
                    leading = label.trailingAnchor
                    label.isHidden = true
                }
            }else{
                label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width + 20).isActive = true
                leading = label.trailingAnchor
                label.isHidden = false
                label.isUserInteractionEnabled = false
                label.backgroundColor = inhabilitado
                totalWidth += label.intrinsicContentSize.width + 20.0
            }
        }
        
        pagesScrollView.contentSize = CGSize(width: totalWidth, height: 40)
        
        self.setVisible(atributos?.visible ?? true)

        if totalWidth > 0.0{
            self.segmentSelected(firstVisibility!)
        }
    }
    
    public func selectOption(_ index: Int){
        self.pagesScrollView.subviews.forEach({
            if $0.isKind(of: UIButton.self){
                if $0.tag == index{
                    self.segmentSelected($0 as? UIButton)
                    return
                }
            }
        })
    }
    
    public func segmentedControlAction(_ ii: Int) {
        
        for (index, ss) in sects.enumerated(){
            
            if index == ii{
                let row = self.formDelegate?.getSectionByIdInCurrentForm("\(ss.id)_tab")
                row?.hidden = false
                row?.evaluateHidden()
            }else{
                let row = self.formDelegate?.getSectionByIdInCurrentForm("\(ss.id)_tab")
                row?.hidden = true
                row?.evaluateHidden()
            }
            
        }

    }
    
}

extension HeaderTabCell: ObjectFormDelegate{
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
    public func setAlignment(_ align: String){ }
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) { }
    // MARK: Set - Title Text
    public func setTitleText(_ text:String){ }
    // MARK: Set - Subtitle Text
    public func setSubtitleText(_ text:String){ }
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){ }
    // MARK: Set - Info
    public func setInfo(){ }
    
    public func setHeightFromTitles() { }
    
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
    public func setOcultarTitulo(_ bool: Bool){ }
    // MARK: Set - OcultarSubtitulo
    public func setOcultarSubtitulo(_ bool: Bool){ }
    // MARK: Set - Habilitado
    public func setHabilitado(_ bool: Bool){ }
    // MARK: Set - Edited
    public func setEdited(v: String){ }
    public func setEdited(v: String, isRobot: Bool) { }
    // MARK: Set - Visible
    public func setVisible(_ bool: Bool){
        self.elemento.validacion.visible = bool
        self.atributos?.visible = bool
       
    }
    // MARK: Set - Validation
    public func resetValidation(){ }
    // MARK: Set - Requerido
    public func setRequerido(_ bool: Bool){ }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){ }
    // MARK: Events
    public func triggerEvent(_ action: String) { }
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
