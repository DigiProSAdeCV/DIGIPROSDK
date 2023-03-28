import Foundation
import WebKit

import Eureka

public class EtiquetaCell: Cell<String>, CellType, WKNavigationDelegate, WKUIDelegate {

    // IBOUTLETS
    @IBOutlet weak public var btnInfo: UIButton!
    @IBOutlet weak var webView: WKWebView!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    
    // PRIVATE
    public var atributos: Atributos_leyenda?
    public var elemento: Elemento = Elemento()
    //public var viewController: Nuevapl?
    
    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    let device = Device()
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        isInfoToolTipVisible = false
        toolTip = nil
        est = nil
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.scrollView.delegate = nil
    }
    
    // MARK: SETTING
    /// SetObject for EtiquetaRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_leyenda
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        
        setVisible(atributos?.visible ?? false)
        initRules()
        setInfo()
    }
    
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
                
        btnInfo.layer.cornerRadius = 13
        btnInfo.layer.borderColor = UIColor.gray.cgColor
        btnInfo.layer.borderWidth = 1
        btnInfo.addTarget(self, action: #selector(setAyuda(_:)), for: .touchDown)
        btnInfo.isHidden = true
        
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self

        let path = Cnstnt.Path.framework?.path(forResource: "etiqueta", ofType: "css")
        var contents = try! String(contentsOfFile: path!)
        contents = contents.replacingOccurrences(of: "\r\n", with: "")
        
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);" +
            "var style = document.createElement('style');" +
            "style.innerHTML = '\(contents)';" +
            "head.appendChild(style);"

        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
        btnInfo.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 15.0)
    }
    
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) {
        guard let _ = self.atributos, let help = atributos?.ayuda else{
            return;
        }
        toogleToolTip(help)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            print("here link Activated!!!")
            if let url = navigationAction.request.url {
                let shared = UIApplication.shared
                if shared.canOpenURL(url) {
                    shared.open(url, options: [:], completionHandler: nil)
                }
            }
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        
        if isInfoToolTipVisible{
            toolTip!.dismiss()
            isInfoToolTipVisible = false
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webViewResizeToContent(webView: self.webView)
    }
     
    public func webViewResizeToContent(webView: WKWebView) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    let h = height as! CGFloat
                    self.setVariableHeight(Height: h)
                })
            }
        })

    }
    
    public func getValor() -> String{
        var doc: String = ""
        webView.evaluateJavaScript("document.documentElement.innerHTML", completionHandler: { (result, error) in
            if let docResult = result as? String {
               doc = docResult
                self.row.value = doc
            }
        })
        return doc
    }
    public func setValor(_ str: String){
        self.webView.isHidden = false
        let source: String = ""
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
        self.webView.loadHTMLString(str, baseURL: nil)
    }
    
    // MARK: Get - Values in terms and conditions
    func idUnicoElemento(idUnico: String, valor: String){
        let bool = atributos!.isencoded
        if bool{
            
        }
        if idUnico.contains("|||\(idUnico)|||") {
            var leyenda : String = idUnico
            idUnico.split(separator: "{").forEach{
                (aux) in
                if String(aux).contains("}}")
                {   String(aux).split(separator: "}").forEach{
                    (idElem) in
                        if String(idElem).contains("formElec_element")
                        {   let textoId = self.formDelegate?.valueElementRow(String(idElem)) ?? ""
                            leyenda = leyenda.replacingOccurrences(of: "{{\(idElem)}}", with: textoId )
                        }
                    }
                }
            }
            
        }
    }
    
    
    func obtainLeyenda (textoLeyenda : String) -> String{
        var textReturn = textoLeyenda
        for rows in self.formDelegate!.getAllRowsFromCurrentForm(){
            switch rows {
            case is TextoRow:
                let base = rows as? TextoRow
                if (rows as? TextoRow)?.cell.atributos != nil{
                    if textoLeyenda.contains("|||\(base?.cell.atributos?.idunico ?? "")|||"){
                       textReturn = textoLeyenda.replacingOccurrences(of: "|||\(base?.cell.atributos?.idunico ?? "")|||", with: "\((rows as? TextoRow)?.cell.elemento.validacion.valor ?? "")")
                    }
                }
                break
            default:
                break
            }
        }
        return textReturn

    }
    
    public func setEncoded(){
        let bool = atributos!.isencoded
        if bool{
            webView.isHidden = false
            let decodedString = atributos!.valor.base64Decoded()
            if decodedString == nil{
                setVisible(false)
            }else{
                
                let html = decodedString?.decodeUrl() ?? ""
                let htmlNew = self.formDelegate?.getLeyendaText(leyenda: html)
                webView.loadHTMLString(htmlNew ?? "", baseURL: nil)
                let stringValue = html.htmlToString
                self.row.value = stringValue
            }
            
            // MARK: - Setting estadisticas
            setEstadistica()
            est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
            est!.Resultado = ""
            est!.KeyStroke += 1
            elemento.estadisticas = est!
            let fechaValorFinal = Date.getTicks()
            self.setEstadisticaV2()
            self.estV2!.FechaValorFinal = fechaValorFinal
            self.estV2!.ValorFinal = ""
            self.estV2!.Cambios += 1
            elemento.estadisticas2 = estV2!
        }else{
            webView.isHidden = false
            let html = atributos!.valor
            let htmlNew = self.formDelegate?.getLeyendaText(leyenda: html)
            webView.loadHTMLString(htmlNew ?? "", baseURL: nil)
            self.row.value = html.htmlToString
        }
    }
    
}

// MARK: - OBJECTFORMDELEGATE
extension EtiquetaCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Leyenda"
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
    public func setAlignment(_ align: String){ }
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) {
        DispatchQueue.main.async {
            self.height = {return h}
            self.layoutIfNeeded()
            (self.row as? EtiquetaRow)?.reload()
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
    public func setInfo(){
        if atributos?.ayuda != nil, !(atributos?.ayuda.isEmpty)!, atributos?.ayuda != ""{
            self.btnInfo.isHidden = false
        }
    }
    
    public func toogleToolTip(_ help: String){
        if isInfoToolTipVisible{
            toolTip?.dismiss()
            isInfoToolTipVisible = false
        }else{
            toolTip = EasyTipView(text: help, preferences: EasyTipView.globalPreferences)
            toolTip?.show(forView: self.btnInfo, withinSuperview: (row as? EtiquetaRow)?.cell.formCell()?.formViewController()?.tableView)
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
    public func setHabilitado(_ bool: Bool){ }
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

extension EtiquetaCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{ return "" }
    public func getRowEnabled()->Bool{
        return self.row.baseCell.isUserInteractionEnabled
    }
    public func getRequired()->Bool{ return false }
    public func getTitleLabel()->String{ return "" }
    public func getSubtitleLabel()->String{ return "" }
}


extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
