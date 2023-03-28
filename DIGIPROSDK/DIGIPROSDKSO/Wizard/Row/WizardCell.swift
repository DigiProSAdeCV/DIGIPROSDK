import Foundation

import Eureka

public class WizardCell: Cell<String>, CellType {
    
    // IBOUTLETS
    @IBOutlet weak var regresarBtn: UIButton!
    @IBOutlet weak var avanzarBtn: UIButton!
    @IBOutlet weak var finalizarBtn: UIButton!
    
    @IBOutlet public weak var regresarBtnFooter: UIButton!
    @IBOutlet public weak var avanzarBtnFooter: UIButton!
    @IBOutlet public weak var finalizarBtnFooter: UIButton!
    
    @IBOutlet weak var verticalStack: UIStackView!
    @IBOutlet weak var horizontalStack: UIStackView!
    @IBOutlet weak var lblPagination: UILabel!
    
    @IBOutlet weak var constAlineacion: NSLayoutConstraint!
    @IBOutlet weak var bgHabilitado: UIView!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var anchoWizard: NSLayoutConstraint!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    
    // PRIVATE
    public var elemento = Elemento()
    public var atributos: Atributos_wizard?
    
    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var hL: CGFloat = 0
    public var hC: CGFloat = 0
    public var hR: CGFloat = 0
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        isInfoToolTipVisible = false
        toolTip = nil
        est = nil
    }
    
    var btnVisibles: Int = 0
    var isInFooter: Bool = false
    
    lazy var buttonARegresar: UIButton = {
        let properties = UIButton()
        properties.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        properties.translatesAutoresizingMaskIntoConstraints = false
        properties.setTitle("", for: .normal)
        properties.titleLabel?.numberOfLines = 0
        properties.titleLabel?.adjustsFontSizeToFitWidth = true
        properties.titleLabel?.sizeToFit()
        properties.backgroundColor = UIColor.orange
        properties.addTarget(self, action: #selector(buttonAToggle), for: .touchUpInside)
        properties.isUserInteractionEnabled = true
        properties.layer.cornerRadius = 5
        properties.contentEdgeInsets = UIEdgeInsets(top: 5,left: 10,bottom: 5,right: 10)
        return properties
    }()
    
    lazy var buttonBAvanzar: UIButton = {
        let properties = UIButton()
        properties.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        properties.titleLabel?.adjustsFontSizeToFitWidth = true
        properties.titleLabel?.sizeToFit()
        properties.translatesAutoresizingMaskIntoConstraints = false
        properties.setTitle("", for: .normal)
        properties.titleLabel?.numberOfLines = 0
        properties.backgroundColor = UIColor.orange
        properties.addTarget(self, action: #selector(buttonBToggle), for: .touchUpInside)
        properties.isUserInteractionEnabled = true
        properties.layer.cornerRadius = 5
        properties.contentEdgeInsets = UIEdgeInsets(top: 5,left: 10,bottom: 5,right: 10)
        return properties
    }()
    
    lazy var buttonCFinalizar: UIButton = {
        let properties = UIButton()
        properties.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        properties.titleLabel?.adjustsFontSizeToFitWidth = true
        properties.titleLabel?.sizeToFit()
        properties.translatesAutoresizingMaskIntoConstraints = false
        properties.setTitle("", for: .normal)
        properties.titleLabel?.numberOfLines = 0
        properties.backgroundColor = UIColor.orange
        properties.addTarget(self, action: #selector(buttonCToggle), for: .touchUpInside)
        properties.isUserInteractionEnabled = true
        properties.layer.cornerRadius = 5
        properties.contentEdgeInsets = UIEdgeInsets(top: 5,left: 10,bottom: 5,right: 10)
        return properties
    }()
    
    lazy var HStack: UIStackView = {
        let prop = UIStackView()
        prop.axis = .horizontal
        prop.alignment = .center
        prop.distribution = .fillProportionally
        prop.isHidden = false
        prop.translatesAutoresizingMaskIntoConstraints = false
        prop.spacing = 8
        prop.isUserInteractionEnabled = true
        return prop
    }()
    
    @objc func buttonAToggle() {
        if isInFooter{
            let page = getPaginaNavigation(direction: false) ?? ""
            let res = formDelegate?.wizardAction(id: page, validar: atributos?.validacion ?? false, tipo: "regresar", atributos: atributos!) ?? false
            if res{
                self.triggerRulesOnChange("backward")
            }
        }else{
            if atributos?.paginaregresar ?? "" != "" || atributos?.validacion ?? false{
                let res = formDelegate?.wizardAction(id: atributos?.paginaregresar ?? "", validar: atributos?.validacion ?? false, tipo: "regresar", atributos: atributos!) ?? false
                if res{
                    self.triggerRulesOnChange("backward")
                }
            }else{
                self.triggerRulesOnChange("backward")
            }
        }
        est!.KeyStroke += 1
        self.estV2?.Cambios += 1
    }
    
    @objc func buttonBToggle() {
        if isInFooter{
            let page = getPaginaNavigation(direction: true) ?? ""
            let res = formDelegate?.wizardAction(id: page, validar: atributos?.validacion ?? false, tipo: "avanzar", atributos: atributos!) ?? false
            if res{
                self.triggerRulesOnChange("backward")
            }
        }else{
            if atributos?.paginaavanzar ?? "" != "" || atributos?.validacion ?? false {
                let res = formDelegate?.wizardAction(id: atributos?.paginaavanzar ?? "", validar: atributos?.validacion ?? false, tipo: "avanzar", atributos: atributos!) ?? false
                if res{
                    self.triggerRulesOnChange("forward")
                }
            }else{
                self.triggerRulesOnChange("forward")
            }
        }
        est!.KeyStroke += 1
        self.estV2?.Cambios += 1
    }
    
    @objc func buttonCToggle() {
        
        self.formDelegate?.obtainRules(rString: nil, eString: self.row.tag, vString: "beforefinish", forced: false, override: false)
            .then({ response in
                self.formDelegate?.obtainRules(rString: nil, eString: "formElec_element0", vString: "save", forced: false, override: false)
                    .then({ response in
                        self.doWizardAction()
                    }).catch({ error in
                        self.doWizardAction()
                    })
            }).catch({ error in
                self.doWizardAction()
            })
        
    }
    
    // "backward", "forward", "beforefinish", "afterfinish"
    @IBAction public func regresarBtnAction(_ sender: UIButton) {
        if isInFooter{
            let page = getPaginaNavigation(direction: false) ?? ""
            let res = formDelegate?.wizardAction(id: page, validar: atributos?.validacion ?? false, tipo: "regresar", atributos: atributos!) ?? false
            if res{
                self.triggerRulesOnChange("backward")
            }
        }else{
            if atributos?.paginaregresar ?? "" != "" || atributos?.validacion ?? false{
                let res = formDelegate?.wizardAction(id: atributos?.paginaregresar ?? "", validar: atributos?.validacion ?? false, tipo: "regresar", atributos: atributos!) ?? false
                if res{
                    self.triggerRulesOnChange("backward")
                }
            }else{
                self.triggerRulesOnChange("backward")
            }
        }
        est!.KeyStroke += 1
        self.estV2?.Cambios += 1
    }
    @IBAction public func avanzarBtnAction(_ sender: UIButton) {
        if isInFooter{
            let page = getPaginaNavigation(direction: true) ?? ""
            let res = formDelegate?.wizardAction(id: page, validar: atributos?.validacion ?? false, tipo: "avanzar", atributos: atributos!) ?? false
            if res{
                self.triggerRulesOnChange("backward")
            }
        }else{
            if atributos?.paginaavanzar ?? "" != "" || atributos?.validacion ?? false {
                let res = formDelegate?.wizardAction(id: atributos?.paginaavanzar ?? "", validar: atributos?.validacion ?? false, tipo: "avanzar", atributos: atributos!) ?? false
                if res{
                    self.triggerRulesOnChange("forward")
                }
            }else{
                self.triggerRulesOnChange("forward")
            }
        }
        est!.KeyStroke += 1
        self.estV2?.Cambios += 1
    }
    @IBAction public func finalizarBtnAction(_ sender: UIButton) {
        // This needs a little hack to always true for validations
        self.formDelegate?.obtainRules(rString: nil, eString: self.row.tag, vString: "beforefinish", forced: false, override: false)
            .then({ response in
                self.formDelegate?.obtainRules(rString: nil, eString: "formElec_element0", vString: "save", forced: false, override: false)
                    .then({ response in
                        self.doWizardAction()
                    }).catch({ error in
                        self.doWizardAction()
                    })
            }).catch({ error in
                self.doWizardAction()
            })
    }
    
    func doWizardAction(){
        let fechaValorFinal = Date.getTicks()
        switch self.atributos?.tipoguardado ?? ""{
        case "publicacion": // Publicación (normal)
            self.estV2!.FechaValorFinal = fechaValorFinal
            self.estV2?.ValorFinal = "publicacion"
            self.setEstadisticaV2()
            _ = self.formDelegate?.wizardAction(id: self.atributos?.tareafinalizar ?? "", validar: self.atributos?.validacion ?? true, tipo: "publicacion", atributos: self.atributos!); break;
        case "metadatos": // Metadatos (sin reemplazar y sólo publicados)
            self.estV2!.FechaValorFinal = fechaValorFinal
            self.estV2?.ValorFinal = "metadatos"
            self.setEstadisticaV2()
            _ = self.formDelegate?.wizardAction(id: self.atributos?.tareafinalizar ?? "", validar: self.atributos?.validacion ?? false, tipo: "metadatos", atributos: self.atributos!); break;
        case "borrador": // Borrador (sin reemplazar y sin metadatos)
            self.estV2!.FechaValorFinal = fechaValorFinal
            self.estV2?.ValorFinal = "borrador"
            self.setEstadisticaV2()
            _ = self.formDelegate?.wizardAction(id: self.atributos?.tareafinalizar ?? "", validar: self.atributos?.validacion ?? false, tipo: "borrador", atributos: self.atributos!); break;
        case "borradorSinSalir": // Borrador sin salir (sin reemplazar y sin metadatos)
            self.estV2!.FechaValorFinal = fechaValorFinal
            self.estV2?.ValorFinal = "borradorSinSalir"
            self.setEstadisticaV2()
            _ = self.formDelegate?.wizardAction(id: self.atributos?.tareafinalizar ?? "", validar: false, tipo: "borradorSinSalir", atributos: self.atributos!); break;
        case "nada": // Salir (no guardar)
            self.estV2!.FechaValorFinal = fechaValorFinal
            self.estV2?.ValorFinal = "nada"
            self.setEstadisticaV2()
            _ = self.formDelegate?.wizardAction(id: self.atributos?.tareafinalizar ?? "", validar: false, tipo: "nada", atributos: self.atributos!); break;
        case "modoboton": // No hacer nada (uso para prellenado)
            self.estV2!.FechaValorFinal = fechaValorFinal
            self.estV2?.ValorFinal = "modoboton"
            self.setEstadisticaV2()
            _ = self.formDelegate?.wizardAction(id: self.atributos?.tareafinalizar ?? "", validar: false, tipo: "modoboton", atributos: self.atributos!); break;
        case "remplazametadatosehijos": // Reemplazo metadatos e hijos (el padre permanece)
            self.estV2!.FechaValorFinal = fechaValorFinal
            self.estV2?.ValorFinal = "remplazametadatosehijos"
            self.setEstadisticaV2()
            _ = self.formDelegate?.wizardAction(id: self.atributos?.tareafinalizar ?? "", validar: false, tipo: "remplazametadatosehijos", atributos: self.atributos!); break;
        default:
            self.estV2!.FechaValorFinal = fechaValorFinal
            self.estV2?.ValorFinal = "publicacion"
            self.setEstadisticaV2()
            _ = self.formDelegate?.wizardAction(id: self.atributos?.tareafinalizar ?? "", validar: true, tipo: "publicacion", atributos: self.atributos!); break;
        }
        self.est!.KeyStroke += 1
        self.estV2?.Cambios += 1
    }
    
    // MARK: SETTING
    /// SetObject for WizardRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_wizard
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        self.horizontalStack.isHidden = true
        
        let textoAvanzar = atributos?.textoavanzar.htmlDecoded
        let textoRegresar = atributos?.textoregresar.htmlDecoded
        let textoFinalizar = atributos?.textofinalizar.htmlDecoded
        
        regresarBtn.setTitle(textoRegresar ?? "", for: .normal)
        avanzarBtn.setTitle(textoAvanzar ?? "", for: .normal)
        finalizarBtn.setTitle(textoFinalizar ?? "", for: .normal)
        
        setColors()
        setEstadistica()
        self.setEstadisticaV2()
        initRules()
        setVisible(atributos?.visible ?? false)
        setHabilitado(atributos?.habilitado ?? false)
        //putHorizontalButtonsWithoutStack()
        putHorizontalWizardButtons()
        //setWidth(atributos?.ancho ?? "normal")
        //setAlignment(atributos?.alineadotexto ?? "")
        setDecoration(atributos?.decoraciontexto ?? "")
        setTextStyle(atributos?.estilotexto ?? "")
        setInfo()
    }
    
    public func putHorizontalWizardButtons() {
        verticalStack.removeFromSuperview()
        regresarBtn.removeFromSuperview()
        avanzarBtn.removeFromSuperview()
        finalizarBtn.removeFromSuperview()
        self.horizontalStack.isHidden = true
        self.addSubview(HStack)
        
        NSLayoutConstraint.activate([
            HStack.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.95),
            HStack.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.00),
            HStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            HStack.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        let textoAvanzar = atributos?.textoavanzar.htmlDecoded
        let textoRegresar = atributos?.textoregresar.htmlDecoded
        let textoFinalizar = atributos?.textofinalizar.htmlDecoded
        
        buttonARegresar.setTitle(textoRegresar ?? "", for: .normal)
        buttonBAvanzar.setTitle(textoAvanzar ?? "", for: .normal)
        buttonCFinalizar.setTitle(textoFinalizar ?? "", for: .normal)
        

        
        if (atributos?.visibleregresar ?? false) {
            HStack.addArrangedSubview(buttonARegresar)
            btnVisibles += 1
        }
        
        if (atributos?.visibleavanzar ?? false){
            btnVisibles += 1
            HStack.addArrangedSubview(buttonBAvanzar)
        }
        
        if (atributos?.visiblefinalizar ?? false) {
            HStack.addArrangedSubview(buttonCFinalizar)
            btnVisibles += 1
        }
        
        if btnVisibles == 1 {
            if atributos?.ancho == "normal" {
                HStack.addArrangedSubview(UIView())
                HStack.addArrangedSubview(UIView())
                HStack.distribution = .fillEqually
            } else {
                HStack.distribution = .fillEqually
            }
        } else if btnVisibles == 2 {
            if atributos?.ancho == "normal" {
                HStack.addArrangedSubview(UIView())
                HStack.distribution = .fillEqually
            } else {
                HStack.distribution = .fillEqually
            }
        } else {
            HStack.distribution = .fillEqually
        }
        
        buttonARegresar.addTarget(self, action: #selector(buttonAToggle), for: .touchUpInside)
        buttonBAvanzar.addTarget(self, action: #selector(buttonBToggle), for: .touchUpInside)
        buttonCFinalizar.addTarget(self, action: #selector(buttonCToggle), for: .touchUpInside)
        
    }

    public func putHorizontalButtonsWithoutStack() {
        
        verticalStack.removeFromSuperview()
        regresarBtn.removeFromSuperview()
        avanzarBtn.removeFromSuperview()
        finalizarBtn.removeFromSuperview()
        self.horizontalStack.isHidden = true

        if !(atributos?.visibleregresar ?? false){
            buttonARegresar.isHidden = true
        }else{
            btnVisibles += 1
        }
        if !(atributos?.visibleavanzar ?? false){
            buttonBAvanzar.isHidden = true
        }else{
            btnVisibles += 1
        }

        if !(atributos?.visiblefinalizar ?? false){
            buttonCFinalizar.isHidden = true
        }else{
            btnVisibles += 1
        }
        
        let widthScreen = (self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 10
        var widthXButton = (widthScreen / CGFloat(btnVisibles)) - 5
        if widthXButton.isInfinite{ widthXButton = 0 }
        
        self.addSubview(buttonARegresar)
        self.addSubview(buttonBAvanzar)
        self.addSubview(buttonCFinalizar)
        
        let textoAvanzar = atributos?.textoavanzar.htmlDecoded
        let textoRegresar = atributos?.textoregresar.htmlDecoded
        let textoFinalizar = atributos?.textofinalizar.htmlDecoded
        
        buttonARegresar.setTitle(textoRegresar ?? "", for: .normal)
        buttonBAvanzar.setTitle(textoAvanzar ?? "", for: .normal)
        buttonCFinalizar.setTitle(textoFinalizar ?? "", for: .normal)
                
        let tl = buttonARegresar.titleLabel?.calculateMaxLines(widthXButton)
        var hl = (CGFloat(tl ?? 0) * (buttonARegresar.titleLabel?.font.lineHeight ?? 0.0))
        hl += 15.0
        
        let tc = buttonBAvanzar.titleLabel?.calculateMaxLines(widthXButton)
        var hc = (CGFloat(tc ?? 0) * (buttonBAvanzar.titleLabel?.font.lineHeight ?? 0.0))
        hc += 15.0
        
        let tr = buttonCFinalizar.titleLabel?.calculateMaxLines(widthXButton)
        var hr = (CGFloat(tr ?? 0) * (buttonCFinalizar.titleLabel?.font.lineHeight ?? 0.0))
        hr += 15.0
        
        NSLayoutConstraint.activate([
            buttonARegresar.widthAnchor.constraint(equalToConstant: buttonARegresar.isHidden ? 0 : widthXButton),
            buttonARegresar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: buttonARegresar.isHidden ? 0 : 5.0),
            buttonARegresar.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            buttonARegresar.heightAnchor.constraint(equalToConstant: hl)
        ])
        
        NSLayoutConstraint.activate([
            buttonBAvanzar.widthAnchor.constraint(equalToConstant: buttonBAvanzar.isHidden ? 0 : widthXButton),
            buttonBAvanzar.leadingAnchor.constraint(equalTo: self.buttonARegresar.rightAnchor, constant: buttonBAvanzar.isHidden ? 0 : 5.0),
            buttonBAvanzar.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            buttonBAvanzar.heightAnchor.constraint(equalToConstant: hc)
        ])
        
        NSLayoutConstraint.activate([
            buttonCFinalizar.widthAnchor.constraint(equalToConstant: buttonCFinalizar.isHidden ? 0 : widthXButton),
            buttonCFinalizar.leadingAnchor.constraint(equalTo: self.buttonBAvanzar.trailingAnchor, constant: buttonCFinalizar.isHidden ? 0 : 5.0),
            buttonCFinalizar.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            buttonCFinalizar.heightAnchor.constraint(equalToConstant: hr)
        ])
        
        buttonARegresar.addTarget(self, action: #selector(buttonAToggle), for: .touchUpInside)
        buttonBAvanzar.addTarget(self, action: #selector(buttonBToggle), for: .touchUpInside)
        buttonCFinalizar.addTarget(self, action: #selector(buttonCToggle), for: .touchUpInside)
        
        let maxH = [hl, hc, hr]
        self.height = { return ((maxH.max() ?? 0.0) + 10) }
    }
    
    public func setFooterOption(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_wizard
        isInFooter = true
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        self.verticalStack.isHidden = true
        self.lblPagination.isHidden = false
        regresarBtnFooter.setTitle("", for: .normal)
        avanzarBtnFooter.setTitle("", for: .normal)
        finalizarBtnFooter.setTitle("", for: .normal)
        
        regresarBtnFooter.setImage(UIImage(named: "baseline_chevron_left_black_24pt", in: Cnstnt.Path.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        avanzarBtnFooter.setImage(UIImage(named: "baseline_chevron_right_black_24pt", in: Cnstnt.Path.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        finalizarBtnFooter.setImage(UIImage(named: "baseline_done_black_24pt", in: Cnstnt.Path.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        regresarBtnFooter.translatesAutoresizingMaskIntoConstraints = false
        finalizarBtnFooter.translatesAutoresizingMaskIntoConstraints = false
        avanzarBtnFooter.translatesAutoresizingMaskIntoConstraints = false
        
        regresarBtnFooter.widthAnchor.constraint(equalToConstant: 0).isActive = true
        finalizarBtnFooter.widthAnchor.constraint(equalToConstant: 0).isActive = true
        avanzarBtnFooter.widthAnchor.constraint(equalToConstant: 0).isActive = true
                
        setColors()
        setEstadistica()
        self.setEstadisticaV2()
        initRules()
        setVisible(atributos?.visible ?? false)
        setHabilitado(atributos?.habilitado ?? false)
        setWidth(atributos?.ancho ?? "normal")
        setAlignment(atributos?.alineadotexto ?? "")
        setDecoration(atributos?.decoraciontexto ?? "")
        setTextStyle(atributos?.estilotexto ?? "")
        setInfo()
    }
    
    override open func update() {
        super.update()
        //        self.setAlignment(self.atributos?.alineadotexto ?? "")
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
        
        let apiObject = ObjectFormManager<WizardCell>()
        apiObject.delegate = self
        
        btnInfo.layer.cornerRadius = 13
        btnInfo.layer.borderColor = UIColor.gray.cgColor
        btnInfo.layer.borderWidth = 1
        btnInfo.addTarget(self, action: #selector(setAyuda(_:)), for: .touchDown)
        btnInfo.isHidden = true
        
        regresarBtn.layer.cornerRadius = 5.0
        finalizarBtn.layer.cornerRadius = 5.0
        avanzarBtn.layer.cornerRadius = 5.0
        
        regresarBtnFooter.layer.cornerRadius = 5.0
        finalizarBtnFooter.layer.cornerRadius = 5.0
        avanzarBtnFooter.layer.cornerRadius = 5.0
        
        
        btnInfo.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 15.0)
        regresarBtn.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        finalizarBtn.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        avanzarBtn.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
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
    
    public func getPaginaNavigation(direction: Bool)->String?{
        // true - up
        // false - down
        let page = formDelegate?.getCurrentPage() ?? 0
        let pageString = FormularioUtilities.shared.paginasVisibles[page].idelemento
        for (index, nav) in atributos!.navegacion.enumerated(){
            if nav == pageString{
                if direction{
                    if atributos?.navegacion.indices.contains(index+1) ?? false{ return atributos?.navegacion[index + 1]}
                }else{
                    if atributos?.navegacion.indices.contains(index-1) ?? false{ return atributos?.navegacion[index - 1]}
                }
            }
        }
        return nil
    }
    
    public func refreshNavigation(){
        let page = formDelegate?.getCurrentPage() ?? 0
        let pages = FormularioUtilities.shared.paginasVisibles.count - 1
        
        let pageLbl = page + 1
        let pagesLbl = FormularioUtilities.shared.paginasVisibles.count
        self.lblPagination.text = "\(pageLbl) de \(pagesLbl)"
        let screenSize: CGRect = UIScreen.main.bounds
        let tamCompleto = (screenSize.width - 20)
        let half = (tamCompleto / 2) - 10
        
        if atributos?.navegacion.count == 0 || atributos?.navegacion.count == 1 {
            
            for c in regresarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = 0 } }
            for c in finalizarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = tamCompleto } }
            for c in avanzarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = 0 } }
            
        }else{
            if page == 0 || page == -1{
                
                for c in regresarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = 0 } }
                for c in finalizarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = 0 } }
                for c in avanzarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = tamCompleto } }
                
            }else if page == pages{
                
                for c in regresarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = half } }
                for c in finalizarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = half } }
                for c in avanzarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = 0 } }
                
            }else{
                
                for c in regresarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = half } }
                for c in finalizarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = 0 } }
                for c in avanzarBtnFooter.constraints { if c.firstAttribute == .width { c.constant = half } }
                
            }
        }
        
    }
    
    public func setColors(){
        
        if isInFooter{
            regresarBtnFooter.backgroundColor = UIColor(hexFromString: atributos?.colorfondoregresar ?? "#3c8dbc")
            regresarBtnFooter.tintColor = UIColor(hexFromString: atributos?.colortextoregresar ?? "#ffffff")
            
            avanzarBtnFooter.backgroundColor = UIColor(hexFromString: atributos?.colorfondoavanzar ?? "#3c8dbc")
            avanzarBtnFooter.tintColor = UIColor(hexFromString: atributos?.colortextoavanzar ?? "#ffffff")
            
            finalizarBtnFooter.backgroundColor = UIColor(hexFromString: atributos?.colorfondofinalizar ?? "#3c8dbc")
            finalizarBtnFooter.tintColor = UIColor(hexFromString: atributos?.colortextofinalizar ?? "#ffffff")
            
        }else{
            buttonARegresar.backgroundColor = UIColor(hexFromString: atributos?.colorfondoregresar ?? "#3c8dbc")
            buttonARegresar.setTitleColor(UIColor(hexFromString: atributos?.colortextoregresar ?? "#ffffff"), for: .normal)
            
            buttonBAvanzar.backgroundColor = UIColor(hexFromString: atributos?.colorfondoavanzar ?? "#3c8dbc")
            buttonBAvanzar.setTitleColor(UIColor(hexFromString: atributos?.colortextoavanzar ?? "#ffffff"), for: .normal)
            
            buttonCFinalizar.backgroundColor = UIColor(hexFromString: atributos?.colorfondofinalizar ?? "#3c8dbc")
            buttonCFinalizar.setTitleColor(UIColor(hexFromString: atributos?.colortextofinalizar ?? "#ffffff"), for: .normal)
        }
        
    }
    
}

// MARK: - OBJECTFORMDELEGATE
extension WizardCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Wizard"
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
    public func setTextStyle(_ style: String){ }
    // MARK: Set - Decoration
    public func setDecoration(_ decor: String){ }
    // MARK: Set - Alignment
    public func setAlignment(_ align: String)
    {
        if atributos?.ancho != "completo" && self.anchoWizard.constant != (UIScreen.main.bounds.width - 20)
        {
            let screenSize: CGRect = UIScreen.main.bounds
            var widthView = screenSize.width
            if (UIDevice.current.model.contains("iPad")) {
                widthView = widthView < self.contentView.frame.size.width ? self.contentView.frame.size.width : widthView   }
            switch align
            {
            case "left", "justify" :
                let centroStack = (widthView / 2) - ((self.anchoWizard.constant / 2) + 10)
                self.constAlineacion.constant = centroStack
                break
            case "center" :
                self.constAlineacion.constant = 0
                break;
            case "right" :
                let centroStack = ((widthView / 2) - ((self.anchoWizard.constant / 2) + 10)) * -1
                self.constAlineacion.constant = centroStack
                
                break;
            default: break;
            }
        }
    }
    // MARK: Set - Width
    public func setWidth(_ width: String)
    {
        let titBoton1 : String = regresarBtn.titleLabel?.text ?? "".htmlDecoded
        let titBoton2 : String = avanzarBtn.titleLabel?.text ?? "".htmlDecoded
        let titBoton3 : String = finalizarBtn.titleLabel?.text ?? "".htmlDecoded
        
        let sizeTit1 = titBoton1.size(withAttributes:[.font: UIFont.systemFont(ofSize:13.0)])
        let sizeTit2 = titBoton2.size(withAttributes:[.font: UIFont.systemFont(ofSize:13.0)])
        let sizeTit3 = titBoton3.size(withAttributes:[.font: UIFont.systemFont(ofSize:13.0)])
        // let size = tit.intrinsicContentSize.width --> SWIFT 5
        
        let screenSize: CGRect = UIScreen.main.bounds
        let tamCompleto = (screenSize.width - 20)
        switch width
        {
        case "normal" :
            let tamNormal = (screenSize.width / (UIDevice.current.model.contains("iPad") ? 4 : 2.2))
            let anchoRegresar = sizeTit1.width < tamNormal ? tamNormal : sizeTit1.width < (tamCompleto/2) ? sizeTit1.width : tamCompleto
            let anchoAvanzar = sizeTit2.width < tamNormal ? tamNormal : sizeTit2.width < (tamCompleto/2) ? sizeTit2.width : tamCompleto
            let anchoFinalizar = sizeTit3.width < tamNormal ? tamNormal : sizeTit3.width < (tamCompleto/2) ? sizeTit3.width : tamCompleto
            self.anchoWizard.constant = CGFloat([ Int(anchoRegresar), Int(anchoAvanzar), Int(anchoFinalizar)].reduce(Int.max, { min($0, $1) }))
            
            break
        case "completo" :
            self.anchoWizard.constant = tamCompleto
            break;
        default:
            let tamNormal = (screenSize.width / (UIDevice.current.model.contains("iPad") ? 4 : 2.2))
            let anchoRegresar = sizeTit1.width < tamNormal ? tamNormal : sizeTit1.width < (tamCompleto/2) ? sizeTit1.width : tamCompleto
            let anchoAvanzar = sizeTit2.width < tamNormal ? tamNormal : sizeTit2.width < (tamCompleto/2) ? sizeTit2.width : tamCompleto
            let anchoFinalizar = sizeTit3.width < tamNormal ? tamNormal : sizeTit3.width < (tamCompleto/2) ? sizeTit3.width : tamCompleto
            self.anchoWizard.constant = CGFloat([ Int(anchoRegresar), Int(anchoAvanzar), Int(anchoFinalizar)].reduce(Int.max, { min($0, $1) }))
            
            break;
            
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
    public func setHeightFromTitles() { }
    // MARK: Set - Title Text
    public func setTitleText(_ text:String){ }
    // MARK: Set - Subtitle Text
    public func setSubtitleText(_ text:String){ }
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){ }
    // MARK: Set - Info
    public func setInfo(){ }
    
    public func toogleToolTip(_ help: String){
        if isInfoToolTipVisible{
            toolTip?.dismiss()
            isInfoToolTipVisible = false
        }else{
            toolTip = EasyTipView(text: help, preferences: EasyTipView.globalPreferences)
            toolTip?.show(forView: self.btnInfo, withinSuperview: (row as? WizardRow)?.cell.formCell()?.formViewController()?.tableView)
            isInfoToolTipVisible = true
        }
    }
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){ }
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
    }
    // MARK: Set - MinMax
    public func setMinMax(){ }
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){ }
    // MARK: Set - OcultarTitulo
    public func setOcultarTitulo(_ bool: Bool){ }
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
    public func resetValidation(){ }
    // MARK: Set - Requerido
    public func setRequerido(_ bool: Bool){ }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){ }
    // MARK: Events
    public func triggerEvent(_ action: String) { }
    // MARK: Excecution for RulesOnProperties
    public func setRulesOnProperties(){
        if rulesOnProperties.count == 0{ return }
        if self.atributos?.habilitado ?? false{ triggerRulesOnProperties("enabled") }else{ triggerRulesOnProperties("notenabled") }
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
    public func triggerRulesOnChange(_ action: String?) {
        if rulesOnChange.count > 0{
            promiseExecuteRules(0, rulesOnChange, action)
        }
    }
    
    func promiseExecuteRules(_ ruleIndex: Int, _ rules: [AEXMLElement], _ action: String?){
        if rules.indices.contains(ruleIndex){
            self.formDelegate?.obtainRules(rString: rules[ruleIndex].name, eString: row.tag, vString: action, forced: false, override: false)
                .then { result in
                    let count = ruleIndex + 1
                    self.promiseExecuteRules(count, rules, action)
            }.catch { error in
                let count = ruleIndex + 1
                self.promiseExecuteRules(count, rules, action)
            }
        }
    }
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){ }
}

extension WizardCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{ return "" }
    public func getRowEnabled()->Bool{ return self.row.baseCell.isUserInteractionEnabled }
    public func getRequired()->Bool{ return false }
    public func getTitleLabel()->String{ return "" }
    public func getRegresarLabel()->String{ return self.atributos?.textoregresar ?? "" }
    public func getAvanzarLabel()->String{ return self.atributos?.textoavanzar ?? "" }
    public func getFinalizarLabel()->String{ return self.atributos?.textofinalizar ?? "" }
    public func getSubtitleLabel()->String{ return "" }
    public func executeForward(){ self.avanzarBtnAction(self.buttonBAvanzar) } // self.avanzarBtn
    public func executeBackward(){ self.regresarBtnAction(self.buttonARegresar)  } // self.regresarBtn
    public func executeFinish(){ self.doWizardAction() } // self.finalizarBtn
}
