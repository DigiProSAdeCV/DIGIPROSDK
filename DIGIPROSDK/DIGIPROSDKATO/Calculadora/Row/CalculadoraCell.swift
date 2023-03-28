import Foundation

import Eureka

public class CalculadoraCell: Cell<String>, CellType, UITextViewDelegate {
    
    // IBOUTLETS
    @IBOutlet weak var headersView: HeaderView!
    @IBOutlet weak var bgHabilitado: UIView!
    @IBOutlet weak var firstTitleSliderLabel: UILabel!
    @IBOutlet weak var secondTitleSliderLabel: UILabel!
    @IBOutlet weak var firstSlider: myCustomSlider!
    @IBOutlet weak var secondSlider: myCustomSlider!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var prestamoLabel: UILabel!
    @IBOutlet weak var interesLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tnaLabel: UILabel!
    @IBOutlet weak var teaLabel: UILabel!
    @IBOutlet weak var temLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var bottomLine: UIView!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    
    // PRIVATE
    public var atributos: Atributos_calculadora?
    public var elemento = Elemento()
    
    var isInfoToolTipVisible = false
    var toolTip: EasyTipView?
    var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    
    var minimumValue: Int = 100
    var firstSliderValue: Double = 0
    var secondSliderValue: Double = 0
    var plazo: Double = 0.0
    var importe: Double = 0.0
    var cuota: Double = 0.0
    var buttonTag: Int = 0
    var tna: Double = 0.0
    var total: Double = 0.0
    var valueSlider: String = ""
    var intervaloMes: Int = 0
    var intervaloImporte: Int = 0
    var roundedValueFirst: Float = 0.0
    var roundedValueSecond: Float = 0.0
   
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        isInfoToolTipVisible = false
        toolTip = nil
        est = nil
        firstSlider?.removeTarget(self, action: nil, for: .allEvents)
        secondSlider?.removeTarget(self, action: nil, for: .allEvents)
        segmentedControl?.removeTarget(self, action: nil, for: .allEvents)
    }
    
    // MARK: SETTING
    /// SetObject for CalculadoraRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_calculadora
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        
        initRules()
        if atributos?.titulo ?? "" == ""{ self.headersView.setOcultarTitulo(true) }else{ self.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        if atributos?.subtitulo ?? "" == ""{ self.headersView.setOcultarSubtitulo(true) }else{ self.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false) }

        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
       
        self.headersView.txttitulo = atributos?.titulo ?? ""
        self.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
//        self.headersView.txthelp = atributos?.ayuda ?? ""
        self.headersView.btnInfo.isHidden = true
        self.headersView.hiddenTit = false
        self.headersView.hiddenSubtit = false
        
        self.headersView.setTitleText(headersView.txttitulo)
        self.headersView.setSubtitleText(headersView.txtsubtitulo)
        self.headersView.setAlignment(atributos?.alineadotexto ?? "")
        self.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        self.headersView.setTextStyle(atributos?.estilotexto ?? "")
        self.headersView.setMessage("")
        
        self.firstTitleSliderLabel.text = atributos?.idplazo.uppercased()
        self.secondTitleSliderLabel.text = atributos?.idimporte.uppercased()
        self.resultLabel.text = "$ 0"
        self.firstSlider.value = Float(atributos?.minmes ?? 0)
        self.firstSlider.minimumValue = Float(atributos?.minmes ?? 0)
        self.firstSlider.maximumValue = Float(atributos?.maxmes ?? 0)
        self.secondSlider.value = Float(atributos?.minimporte ?? 0)
        self.secondSlider.minimumValue = Float(atributos?.minimporte ?? 0)
        self.secondSlider.maximumValue = Float(atributos?.maximporte ?? 0)
        self.plazo = Double(atributos?.minmes ?? 0)
        self.importe = Double(atributos?.minimporte ?? 0)
        
        self.plazo = Double(atributos?.minmes ?? 0)
        self.tna = Double(atributos?.tasanominalanual ?? 0)
        self.importe = Double(atributos?.minimporte ?? 0)
        self.total = Double(atributos?.minimporte ?? 0)
        self.intervaloMes = Int(atributos?.intervalomeses ?? 0)
        self.intervaloImporte = Int(atributos?.intervaloimporte ?? 0)
        
        self.teaLabel.text = "\(self.teaValue())%"
        self.temLabel.text = "\(self.temValue())%"
        self.segmentedControl.selectedSegmentIndex = 0
        self.buttonTag = 1
        self.firstSlider.label.text = "\(atributos?.minmes ?? 0)"
        self.firstTitleSliderLabel.text = atributos?.idplazo.uppercased()
        self.secondTitleSliderLabel.text = atributos?.idimporte.uppercased()
        self.resultLabel.text = "$ 0"
        
        self.firstSlider.minimumValue = Float(atributos?.minmes ?? 0)
        self.firstSlider.maximumValue = Float(atributos?.maxmes ?? 0)
        
        self.secondSlider.label.text = "\(atributos?.minimporte ?? 0)"
        self.secondSlider.minimumValue = Float(atributos?.minimporte ?? 0)
        self.secondSlider.maximumValue = Float(atributos?.maximporte ?? 0)
        
        self.firstSlider.value = Float(self.plazo)
        self.secondSlider.value = Float(self.importe)
        self.firstSliderValue = Double(self.plazo)
        self.secondSliderValue = Double(self.importe)
        
        self.resultLabel.text = "$ \(self.cuotaFormula(plazo: Double(self.firstSliderValue), importe: Double(self.secondSliderValue), cuota: nil))"
        self.cuota = self.cuotaFormula(plazo: Double(self.firstSliderValue), importe: Double(self.secondSliderValue), cuota: nil)
        self.totalLabel.text = "$\(Double(self.firstSliderValue) * self.cuotaFormula(plazo: Double(self.firstSliderValue), importe: Double(self.secondSliderValue), cuota: nil))"
        self.total = Double(self.firstSliderValue) * self.cuotaFormula(plazo: Double(self.firstSliderValue), importe: Double(self.secondSliderValue), cuota: nil)
        self.prestamoLabel.text = "$\(self.importe)"
        self.interesLabel.text = "$\(self.total - self.importe)"
        self.teaLabel.text = "\(self.teaValue())%"
        self.temLabel.text = "\(self.temValue())%"
        
        self.headersView.translatesAutoresizingMaskIntoConstraints = false
        self.headersView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        self.headersView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.headersView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        
        self.headersView.setNeedsLayout()
        self.headersView.layoutIfNeeded()
        
        
        
        self.headersView.setHeightFromTitles()
        setVariableHeight(Height: self.headersView.heightHeader)
        
        
    }
    
    override open func update() {
        super.update()
        
        self.teaLabel.text = "\(self.teaValue())%"
        self.temLabel.text = "\(self.temValue())%"
        self.tnaLabel.text = "\(self.tna * 100) %"
        self.interesLabel.text = "\(self.total - self.importe)"
        
        self.firstSlider.isEnabled = true
        self.firstSlider.isEnabled = true
        self.secondSlider.isEnabled = true
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
        let apiObject = ObjectFormManager<CalculadoraCell>()
        apiObject.delegate = self
        
        self.firstSlider.addTarget(self, action: #selector(sliderVlaue(_:_:)), for: .valueChanged)
        self.secondSlider.addTarget(self, action: #selector(sliderVlaue(_:_:)), for: .valueChanged)
        self.segmentedControl.addTarget(self, action: #selector(actionSegmented(_:)), for: .valueChanged)
        self.firstSlider.tag = 1
        self.secondSlider.tag = 2
        self.firstSlider.layer.cornerRadius = 5.0
        self.secondSlider.layer.cornerRadius = 5.0
        self.resultLabel.layer.cornerRadius = 16.0
        self.resultLabel.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.resultLabel.layer.borderWidth = 1.0
        
    }
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) { }
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        
        if isInfoToolTipVisible{
            toolTip!.dismiss()
            isInfoToolTipVisible = false
        }
    }
    
    @objc func sliderVlaue(_ sender: UISlider, _ event: UIEvent) {
        
        switch sender.tag {
        case 1:
            row.value = self.resultLabel.text
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.updateIfIsValid()
            }
            self.firstSliderValue = Double(sender.value)
            break
        case 2:
            row.value = self.resultLabel.text
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.updateIfIsValid()
            }
            self.secondSliderValue = Double(sender.value)
            break
        default:
            break
        }
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                break
            // handle drag began
            case .moved:
                
                if self.buttonTag == 1 && sender.tag == 1{
                    let step: Float = Float(intervaloMes)
                    self.roundedValueFirst = round(sender.value / Float(step)) * step
                    sender.value = self.roundedValueFirst
                    self.firstSliderValue = Double(self.roundedValueFirst)
                }else if self.buttonTag == 1 && sender.tag == 2{
                    let step: Float = Float(intervaloImporte)
                    self.roundedValueSecond = round(sender.value / Float(step)) * step
                    sender.value = self.roundedValueSecond
                    self.secondSliderValue = Double(self.roundedValueSecond)
                }else if self.buttonTag == 2 && sender.tag == 2{
                    let step: Float = Float(intervaloImporte)
                    self.roundedValueSecond = round(sender.value / Float(step)) * step
                    sender.value = self.roundedValueSecond
                    self.secondSliderValue = Double(self.roundedValueSecond)
                }else if self.buttonTag == 3 && sender.tag == 2{
                    let step: Float = Float(intervaloMes)
                    self.roundedValueFirst = round(sender.value / Float(step)) * step
                    sender.value = self.roundedValueFirst
                    self.firstSliderValue = Double(self.roundedValueFirst)
                }
                
                break
            // handle drag moved
            case .ended:
                break
            // handle drag ended
            default:
                break
            }
        }
        
        if self.buttonTag == 1{
            
            self.plazo = Double(self.firstSliderValue)
            self.importe = Double(self.secondSliderValue)
            self.resultLabel.text = "$ \(self.cuotaFormula(plazo: Double(self.firstSliderValue), importe: Double(self.secondSliderValue), cuota: nil))"
            self.totalLabel.text = "$\(Double(self.firstSliderValue) * self.cuotaFormula(plazo: Double(self.firstSliderValue), importe: Double(self.secondSliderValue), cuota: nil))"
            self.total = Double(self.firstSliderValue) * self.cuotaFormula(plazo: Double(self.firstSliderValue), importe: Double(self.secondSliderValue), cuota: nil)
            self.cuota = Double(self.cuotaFormula(plazo: Double(self.firstSliderValue), importe: Double(self.secondSliderValue), cuota: nil))
            self.prestamoLabel.text = "$\(self.importe)"
            self.interesLabel.text = "$\(self.total - self.importe)"
            self.teaLabel.text = "\(self.teaValue())%"
            self.temLabel.text = "\(self.temValue())%"
            
        }else if self.buttonTag == 2{
            
            self.importe = Double(self.secondSliderValue)
            self.cuota = Double(self.firstSliderValue)
            self.resultLabel.text = "\(self.cuotaFormula(plazo: nil, importe: Double(self.secondSliderValue), cuota: Double(self.firstSliderValue))) M."
            self.totalLabel.text = "$\(Double(self.firstSliderValue) * self.cuotaFormula(plazo: nil, importe: Double(self.secondSliderValue), cuota: Double(self.firstSliderValue)))"
            self.total = Double(self.firstSliderValue) * self.cuotaFormula(plazo: nil, importe: Double(self.secondSliderValue), cuota: Double(self.firstSliderValue))
            self.prestamoLabel.text = "$\(self.importe)"
            self.interesLabel.text = "$\(self.total - self.importe)"
            self.teaLabel.text = "\(self.teaValue())%"
            self.temLabel.text = "\(self.temValue())%"
            
        }else if self.buttonTag == 3{
            
            self.plazo = Double(self.secondSliderValue)
            self.cuota = Double(self.firstSliderValue)
            self.resultLabel.text = "$ \(self.cuotaFormula(plazo: Double(self.secondSliderValue), importe: nil, cuota: Double(self.firstSliderValue)))"
            self.totalLabel.text = "$\(self.secondSliderValue * self.firstSliderValue)"
            self.total = self.secondSliderValue * self.firstSliderValue
            self.prestamoLabel.text = "$\(self.importe)"
            self.interesLabel.text = "$\(self.total - self.importe)"
            self.teaLabel.text = "\(self.teaValue())%"
            self.temLabel.text = "\(self.temValue())%"
            
        }
        
    }
    
    @objc func actionSegmented(_ sender: UISegmentedControl){
        
        if sender.selectedSegmentIndex == 0{
            
            self.buttonTag = 1
            self.firstSlider.label.text = "\(atributos!.minmes)"
            self.firstTitleSliderLabel.text = atributos?.idplazo.uppercased()
            self.secondTitleSliderLabel.text = atributos?.idimporte.uppercased()
            self.resultLabel.text = "$ 0"
    
            self.firstSlider.minimumValue = Float(atributos!.minmes)
            self.firstSlider.maximumValue = Float(atributos!.maxmes)
           
            self.secondSlider.label.text = "\(atributos!.minimporte)"
            self.secondSlider.minimumValue = Float(atributos!.minimporte)
            self.secondSlider.maximumValue = Float(atributos!.maximporte)
            
            self.firstSlider.value = Float(self.plazo)
            self.secondSlider.value = Float(self.importe)
            self.firstSliderValue = Double(self.plazo)
            self.secondSliderValue = Double(self.importe)
            
            self.firstSlider.updateLabel()
            self.secondSlider.updateLabel()
            row.value = nil
            self.resultLabel.text = "$ \(self.cuotaFormula(plazo: Double(self.firstSliderValue), importe: Double(self.secondSliderValue), cuota: nil))"
            self.cuota = self.cuotaFormula(plazo: Double(self.firstSliderValue), importe: Double(self.secondSliderValue), cuota: nil)
            self.totalLabel.text = "$\(Int(Double(self.firstSliderValue) * self.cuota))"
            self.total = Double(self.firstSliderValue) * self.cuota
            self.prestamoLabel.text = "$\(self.importe)"
            self.interesLabel.text = "$\(self.total - self.importe)"
            self.teaLabel.text = "\(self.teaValue())%"
            self.temLabel.text = "\(self.temValue())%"
            
        }else if sender.selectedSegmentIndex == 1{
            
            self.buttonTag = 2
            self.firstSlider.label.text = "\(minimumValue)"
            self.firstTitleSliderLabel.text = atributos?.idcuota.uppercased()
            self.secondTitleSliderLabel.text = atributos?.idimporte.uppercased()
            self.resultLabel.text = "0 M."
            self.firstSlider.value = 1
            self.firstSlider.minimumValue = Float(minimumValue)
            self.firstSlider.maximumValue = Float(atributos!.maximporte)
            self.secondSlider.label.text = "\(atributos!.minimporte)"
            self.secondSlider.value = 1
            self.secondSlider.minimumValue = Float(atributos!.minimporte)
            self.secondSlider.maximumValue = Float(atributos!.maximporte)
            
            self.firstSlider.value = Float(self.cuota)
            self.secondSlider.value = Float(self.importe)
            self.firstSliderValue = Double(self.cuota)
            self.secondSliderValue = Double(self.importe)
           
            self.firstSlider.updateLabel()
            self.secondSlider.updateLabel()
            
            row.value = nil
            self.resultLabel.text = "\(self.cuotaFormula(plazo: nil, importe: Double(self.secondSliderValue), cuota: Double(self.firstSliderValue))) M."
            self.totalLabel.text = "$\(Double(self.firstSliderValue) * self.cuotaFormula(plazo: nil, importe: Double(self.secondSliderValue), cuota: Double(self.firstSliderValue)))"
            self.prestamoLabel.text = "$\(self.importe)"
            self.total = Double(self.firstSliderValue) * self.cuotaFormula(plazo: nil, importe: Double(self.secondSliderValue), cuota: Double(self.firstSliderValue))
            self.interesLabel.text = "$\(self.total - self.importe)"
            self.temLabel.text = "\(self.temValue())%"
           
            
        }else if sender.selectedSegmentIndex == 2{
            
            self.buttonTag = 3
            self.firstSlider.label.text = "\(minimumValue)"
            self.firstTitleSliderLabel.text = atributos?.idcuota.uppercased()
            self.secondTitleSliderLabel.text = atributos?.idplazo.uppercased()
            self.resultLabel.text = "$ 0"
            
            self.firstSlider.minimumValue = Float(minimumValue)
            self.firstSlider.maximumValue = Float(atributos!.maximporte)
            self.secondSlider.label.text = "\(atributos!.minmes)"
            
            self.secondSlider.minimumValue = Float(atributos!.minmes)
            self.secondSlider.maximumValue = Float(atributos!.maxmes)
           
            row.value = nil
            
            self.firstSlider.value = Float(self.cuota)
            self.secondSlider.value = Float(self.plazo)
            
            self.firstSliderValue = Double(self.cuota)
            self.secondSliderValue = Double(self.plazo)
        
            self.firstSlider.updateLabel()
            self.secondSlider.updateLabel()
            
            self.resultLabel.text = "$ \(self.cuotaFormula(plazo: Double(self.secondSliderValue), importe: nil, cuota: Double(self.firstSliderValue)))"
            self.totalLabel.text = "$\(self.secondSliderValue * self.firstSliderValue)"
            self.prestamoLabel.text = "$\(self.importe)"
            self.total = self.secondSliderValue * self.firstSliderValue
            self.interesLabel.text = "$\(self.total - self.importe)"
            self.teaLabel.text = "\(self.teaValue())%"
            self.temLabel.text = "\(self.temValue())%"
            
        }
        
    }
    
    @objc func actionButtons(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            
            self.buttonTag = sender.tag
            self.firstSlider.label.text = "\(atributos!.minmes)"
            self.firstTitleSliderLabel.text = atributos?.idplazo.uppercased()
            self.secondTitleSliderLabel.text = atributos?.idimporte.uppercased()
            self.resultLabel.text = "$ 0"
            self.firstSlider.value = Float(atributos!.minmes)
            self.firstSlider.minimumValue = Float(atributos!.minmes)
            self.firstSlider.maximumValue = Float(atributos!.maxmes)
            
            self.secondSlider.label.text = "\(atributos!.minimporte)"
            self.secondSlider.value = Float(atributos!.minimporte)
            self.secondSlider.minimumValue = Float(atributos!.minimporte)
            self.secondSlider.maximumValue = Float(atributos!.maximporte)
            
            break
        case 2:
            self.buttonTag = sender.tag
            self.firstSlider.label.text = "\(minimumValue)"
            self.firstTitleSliderLabel.text = atributos?.idcuota.uppercased()
            self.secondTitleSliderLabel.text = atributos?.idimporte.uppercased()
            self.resultLabel.text = "0 M."
            self.firstSlider.value = Float(minimumValue)
            self.firstSlider.minimumValue = Float(minimumValue)
            self.firstSlider.maximumValue = Float(atributos!.maximporte)
            self.secondSlider.label.text = "\(atributos!.minimporte)"
            self.secondSlider.value = Float(atributos!.minimporte)
            self.secondSlider.minimumValue = Float(atributos!.minimporte)
            self.secondSlider.maximumValue = Float(atributos!.maximporte)
            
            break
        case 3:
            self.buttonTag = sender.tag
            self.firstSlider.label.text = "\(minimumValue)"
            self.firstTitleSliderLabel.text = atributos?.idcuota.uppercased()
            self.secondTitleSliderLabel.text = atributos?.idplazo.uppercased()
            self.resultLabel.text = "$ 0"
            self.firstSlider.value = Float(minimumValue)
            self.firstSlider.minimumValue = Float(minimumValue)
            self.firstSlider.maximumValue = Float(atributos!.maximporte)
            self.secondSlider.label.text = "\(atributos!.minmes)"
            self.secondSlider.value = Float(atributos!.minmes)
            self.secondSlider.minimumValue = Float(atributos!.minmes)
            self.secondSlider.maximumValue = Float(atributos!.maxmes)
            
            break
        default:
            break
        }
        
    }
    //MARK: - FORMULAS CALCULADORA
    //Formula Tasa Efectiva Anual (TEA)
    func teaValue() -> Double{
        let tna: Double = self.tna
        let plazo: Double = self.plazo
        let firstResult = (tna/plazo) + 1
        
        let secondResult = plazo
        let result = pow(firstResult, secondResult) - 1
        let result2 = result * 100
        
        let roundResult = Double(round(100 * result2)/100)
        
        return roundResult
    }
    
    // Formula Tasa Efectiva Mensual (TEM)
    func temValue() -> Double{
        
        let firstresult = 1 + teaValue()
        let secondResult = (1/Int(self.plazo)) - 1
        
        let result = pow(firstresult, Double(secondResult))
        let _ = Double(round(10000 * result)/1000)
        if self.plazo >= 24{
           return 0.84
        }else{
           return 0.83
        }
        
    }
    
    //Formula Cuota
    
    func cuotaFormula(plazo: Double?, importe: Double?, cuota: Double?) -> Double{
        
        if plazo != nil && importe != nil{
            let tem  = temValue() * 0.01
            
            let one = 1.0 + tem
            let two = pow(one, plazo!)
            let first = tem * two
            
            let secondResult = 1 + tem
            let secondPow = pow(secondResult, plazo!) - 1
            
            let div = first/secondPow
            let resultNew = importe! * (div)
            let roundResult = Double(round(1000 * resultNew)/1000)
            
            return roundResult
            
        }else if importe != nil && cuota != nil{
            
            let tem = temValue() * 0.01
            
            let mult = importe! * tem / cuota!
            
            let first: Double = 1.0 - mult
            let one: Double = 1.0 / (first)
            
            let oneLog = log10(one)
            
            
            let secondResult = 1 + tem
            let logSecond = log10(secondResult)
            
            let div = oneLog / logSecond
            
            let result = Double(round(1000*div)/1000)
            
            return result
            
        }else if cuota != nil && plazo != nil{
            
            let tem = temValue() * 0.01
            
            let one = 1.0 + tem
            let two = pow(one, plazo!)
            
            let first = tem * two
            
            let secondResult: Double = 1 + tem
            let secondPow = pow(secondResult, plazo!) - 1
            let div = (first / secondPow)
            
            return cuota! / div
            
        }
        
        return 0.0
        
    }
    
}

extension CalculadoraCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Calculadora"
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
            let h2 = h + 200
            self.height = {return h2}
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
    public func setPlaceholder(_ text:String){ }
    // MARK: Set - Info
    public func setInfo(){ }
    
    public func toogleToolTip(_ help: String){ }
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){
        // message, valid, alert, error
    }
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
        if v == ""{ return }
        row.value = v
        resultLabel.text = v
        row.validate()
        updateIfIsValid()
        
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
    public func resetValidation(){ }
    // MARK: Set - Requerido
    public func setRequerido(_ bool: Bool){ }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        self.headersView.lblMessage.isHidden = true
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
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.valor = resultLabel.text ?? ""
                    self.elemento.validacion.valormetadato  = resultLabel.text ?? ""
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
    public func triggerEvent(_ action: String) { }
    // MARK: Excecution for RulesOnProperties
    public func setRulesOnProperties(){
        if rulesOnProperties.count == 0{ return }
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

extension CalculadoraCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{
        return self.headersView.lblMessage.text ?? ""
    }
    public func getRowEnabled()->Bool{
        return self.row.baseCell.isUserInteractionEnabled
    }
    public func getRequired()->Bool{ return false }
    public func getTitleLabel()->String{
        return self.headersView.lblTitle.text ?? ""
    }
    public func getSubtitleLabel()->String{
        return self.headersView.lblSubtitle.text ?? ""
    }
}
