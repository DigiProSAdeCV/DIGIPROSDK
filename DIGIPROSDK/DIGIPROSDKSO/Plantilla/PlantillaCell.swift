import Foundation

import Eureka

public class PlantillaCell: Cell<String>, CellType {
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    // PRIVATE
    public var atributos: Atributos_plantilla?
    public var elemento = Elemento()
        
    var isInfoToolTipVisible = false
    var toolTip: EasyTipView?
    var est: FEEstadistica? = nil
    var isAlEntrar: Bool = false
    var formulaLoop: Int = 0
    var txtInicial : String = ""
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
    }
    
    // MARK: SETTING
    /// SetObject for TextoRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_plantilla
    }
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) { }
    override open func update() {
        super.update()
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
        let apiObject = ObjectFormManager<PlantillaCell>()
        apiObject.delegate = self
        height = {return 1}
    }
    
   open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
    
}

// MARK: - OBJECTFORMDELEGATE
extension PlantillaCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // MARK: - ESTADISTICAS
    public func setEstadistica(){ }
    public func setEstadisticaV2(){}
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
    // MARK: Set - Height From Titles
    public func setHeightFromTitles(){ }
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
    public func setOcultarTitulo(_ bool: Bool){ }
    // MARK: Set - OcultarSubtitulo
    public func setOcultarSubtitulo(_ bool: Bool){ }
    // MARK: Set - Habilitado
    public func setHabilitado(_ bool: Bool){ }
    // MARK: Set - Edited
    public func setEdited(v: String){ }
    public func setEdited(v: String, isRobot: Bool) { }
    // MARK: Set - Visible
    public func setVisible(_ bool: Bool){ }
    // MARK: Set - Validation
    public func resetValidation(){ }
    // MARK: Set - Requerido
    public func setRequerido(_ bool: Bool){ }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){ }
    // MARK: Events
    public func triggerEvent(_ action: String) {   // alentrar
        // alcambiar
        if atributos != nil, atributos?.eventos != nil {
            for evento in (atributos?.eventos.expresion)! {
                if evento._tipoexpression == action {
                    DispatchQueue.main.async {
                        self.formDelegate?.addEventAction(evento)
                    }
                }
            }
        }
      
    }
    // MARK: Excecution for RulesOnProperties
    public func setRulesOnProperties(){
        triggerRulesOnProperties("")
    }
    
    // MARK: Excecution for RulesOnChange
    public func setRulesOnChange(){ }
    
    // MARK: Rules on properties
    public func triggerRulesOnProperties(_ action: String){
        if rulesOnProperties.count == 0{ return }
        for rule in rulesOnProperties{
            if rule.vrb == action{
                _ = self.formDelegate?.obtainRules(rString: rule.xml.name, eString: row.tag, vString: rule.vrb, forced: false, override: false)
            }
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
    public func setMathematics(_ bool: Bool, _ id: String){
        isMathematics = bool
        mathematicsName.append(id)
    }
}

extension PlantillaCell: GetInfoRowDelegate{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{ return "" }
    public func getRowEnabled()->Bool{ return self.row.baseCell.isUserInteractionEnabled }
    public func getRequired()->Bool{ return false }
    public func getTitleLabel()->String{ return "" }
    public func getSubtitleLabel()->String{ return "" }
}
