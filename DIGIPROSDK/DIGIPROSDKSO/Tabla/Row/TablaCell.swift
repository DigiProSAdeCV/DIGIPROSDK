import Eureka
import UIKit

public struct OrderedDictionary<Tk: Hashable,Tv> : Encodable {
    var keys: Array<Tk> = []
    var values: Dictionary<Tk,Tv> = [:]
    
    init() {}
    
    subscript(index: Int) -> Tv? {
            get {
                let key = self.keys[index]
                return self.values[key]
            }
            set(newValue) {
                let key = self.keys[index]
                if (newValue != nil) {
                    self.values[key] = newValue
                } else {
                    self.values.removeValue(forKey: key)
                    self.keys.remove(at: index)
                }
            }
        }
        
        subscript(key: Tk) -> Tv? {
            get {
                return self.values[key]
            }
            set(newValue) {
                if newValue == nil {
                    self.values.removeValue(forKey: key)
                    self.keys = self.keys.filter {$0 != key}
                } else {
                    let oldValue = self.values.updateValue(newValue!, forKey: key)
                    if oldValue == nil {
                        self.keys.append(key)
                    }
                }
            }
        }
    
        var json: String {
            var result = "{"
            for i in 0..<self.values.count {
                
                let key = self.keys[i] as! String
                
                let value: Any
               if let v = self[i] as? NSMutableDictionary {
                    value = v.toJsonString()
                } else {
                    value = self[i]!
                }
                
                result += "\"\(key)\":\(value)"
                if i == self.values.count-1{
                    //No agregamos coma.
                } else {
                    result += ","
                }
            }
            result += "}"
            return result
        }
    
    public func encode(to encoder: Encoder) throws {}
}

open class TablaCell: Cell<String>, CellType, TablaPlantillaViewControllerDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
     var constantHeight = 0
     var lastItemConstraint: NSLayoutYAxisAnchor = NSLayoutYAxisAnchor()
     var firstcolum = false
    
    // IBOUTLETS
    @IBOutlet weak var lblRequired: UILabel!
    @IBOutlet weak var viewValidation: UIView!
    @IBOutlet weak var bgHabilitado: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var agregarBtn: UIButton!
    @IBOutlet weak var btnMultiEdicion: UIButton!
    
    @IBOutlet weak var spreadSheet: SpreadsheetView!
    @IBOutlet weak var collectionCard: UICollectionView!
    
    // TOTAL CARD
    @IBOutlet weak var totalCard: UIView!
    @IBOutlet weak var lblTotales: UILabel!
    @IBOutlet weak var scrollTotales: UIScrollView!
    
    // PUBLIC
    public var formDelegate: FormularioDelegate?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    
    public var records = [(record: Int, json: String)]()
    public var recordsVisibles = [(record: Int, json: String)]()
    public var recordsHide = [Int]()
    public var recordsEdit : [Int] = [-1]
    public var recordsDelete : [Int] = [-1]
    public var recordsSelect : [Int] = [-1]
    public var columnByRowHidden : NSMutableDictionary = NSMutableDictionary()
    public var elementsForValidate = [String]()
    public var ElementosArray: NSMutableDictionary = NSMutableDictionary()
    public var ElementosCleanArray = [NSMutableDictionary]()
    public var cleanProd: NSMutableDictionary = NSMutableDictionary();
    public var allCleanedData: [NSMutableDictionary] = [NSMutableDictionary]();
    
    // PRIVATE
    public var elemento = Elemento()
    public var atributos: Atributos_tabla?

    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var plantillamapear = ""
    public var theJsonCleanText = ""
    public var jsonService = false
    public var clickInRow : String = ""
    
    var heightCard = 0
    var counter = 0
    var y = 50
    var x = 10
    var w = 0
    var h = 40
    
    var label: UILabel = UILabel()
    var viewHolder: UIView = UIView()
    var rowsTable: Int = 0
    var senderTag: Int = 0
    
    var arrayElementos: Array<Elemento>?
    var dictValues = Dictionary<String, (docid:String, valor:String, valormetadato:String)>()
    
    public var viewController: TablaPlantillaViewController?
    var arrayRows = [String]()
    var emptyArray = [String]()
    public var dataRows = [[String]]()
    var dataRowsVisibles = [[String]]()
    var dataTotales = [[String]]()
    var nameElement = [(id: String, title: String)]()
    var elementsToCalculate = [String]()
    public var ff = [(id: String, formula: String)]()
    var idMultiEdit = [Int]()
    var innerScrollSize: CGFloat = 0
    
    var navigationController: UINavigationController?
    
    deinit{
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        atributos = nil
        elemento = Elemento()
        isInfoToolTipVisible = false
        toolTip = nil
        est = nil
        viewController = nil
        navigationController = nil
        records = [(record: Int, json: String)]()
        recordsVisibles = [(record: Int, json: String)]()
        columnByRowHidden = NSMutableDictionary()
        elementsForValidate = [String]()
        ElementosArray = NSMutableDictionary()
        ElementosCleanArray = [NSMutableDictionary]()
        cleanProd = NSMutableDictionary()
        allCleanedData = [NSMutableDictionary]()
        
        
        (row as? TablaRow)?.presentationMode = nil
    }
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    // MARK: TablaPlantillaViewControllerDelegate
    public func didTapCancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    public func didTapSave() -> Bool{
        self.atributos?.visible = true
        self.setHabilitado(true)
        self.setVisible(true)
        let ss = savingData()
        if ss{ triggerRulesOnChange("tableadd,addclear"); }
        return ss
    }
    
    public func didTapSaveCancel() -> Bool {
        self.atributos?.visible = true
        self.setHabilitado(true)
        self.setVisible(true)
        let ss = savingData(true)
        if ss{ triggerRulesOnChange("tableadd,addclear"); }
        return ss
    }
    
    public func settingMessages(_ mssg: String, _ type: String, _ style: BannerStyle) {
        formDelegate?.setStatusBarNotificationBanner(mssg, style, .bottom)
    }
    
    func savingData(_ isClosing: Bool = false) -> Bool{
        counter += 1
        if jsonService
        {   let valuesService : NSMutableDictionary = cleanProd
            jsonService = false
            cleanProd = NSMutableDictionary()
            for elem in arrayElementos!{
                valuesService.forEach {
                    let idUnicoAUX = elem.validacion.idunico.split(separator: "_")
                    if !idUnicoAUX.isEmpty {
                        let idUni = (idUnicoAUX.count > 1) ? String(idUnicoAUX[1]) : String(idUnicoAUX[0])
                        if idUni == ($0.key as? String ?? "") {
                            elem.validacion.valor = $0.value as? String ?? "" != "" ? $0.value as? String ?? "" : "\($0.value)"
                            elem.validacion.valormetadato = elem.validacion.valor
                        }
                    }
                }
                detectValue(elem: elem, isPrellenado: false)
            }
        } else
        {
            cleanProd = NSMutableDictionary()
            let dictData: NSMutableDictionary = NSMutableDictionary()
            for elem in arrayElementos!{
                detectValue(elem: elem, isPrellenado: false)
                for e in ElementosArray{
                    if elem._idelemento == e.key as! String {
                        dictData.setValue(e.value, forKey: e.key as! String)
                    }
                }
            }
            //print(dictData)
        }
        self.allCleanedData.append(cleanProd)
        self.ElementosCleanArray.append(cleanProd)
        
        var elementosAOrdenar: Dictionary<Int,String> = Dictionary<Int,String>()
        for elemento in arrayElementos! {
            //Obtenemos el campo: ordencampo
            var ordenCampo: Int = 0
            let idelemento: String = elemento._idelemento
            switch elemento.atributos {
            case is Atributos_fecha:
                ordenCampo = (elemento.atributos as! Atributos_fecha).ordencampo
            case is Atributos_tabla:
                ordenCampo = (elemento.atributos as! Atributos_tabla).ordencampo
            case is Atributos_texto_unit:
                ordenCampo = (elemento.atributos as! Atributos_texto_unit).ordencampo
            case is Atributos_hora:
                ordenCampo = (elemento.atributos as! Atributos_hora).ordencampo
            case is Atributos_texto:
                ordenCampo = (elemento.atributos as! Atributos_texto).ordencampo
            case is Atributos_moneda:
                ordenCampo = (elemento.atributos as! Atributos_moneda).ordencampo
            case is Atributos_textarea:
                ordenCampo = (elemento.atributos as! Atributos_textarea).ordencampo
            case is Atributos_comboDinamico:
                ordenCampo = (elemento.atributos as! Atributos_comboDinamico).ordencampo
            case is Atributos_numero:
                ordenCampo = (elemento.atributos as! Atributos_numero).ordencampo
                break
            case is Atributos_PDFOCR:
                ordenCampo = (elemento.atributos as! Atributos_PDFOCR).ordencampo
                break
            default:
                break
            }
            elementosAOrdenar[ordenCampo] = idelemento
        }
        
        let prod: NSMutableDictionary = NSMutableDictionary()
        prod.setValue(counter, forKey: "id")
        prod.setValue("", forKey: "valormetadatorango")
        prod.setValue(ConfigurationManager.shared.utilities.guid(), forKey: "guidanexo")
     
        let elementosOrdenados = elementosAOrdenar.sorted(by: {$0.0 < $1.0})
        var elementosArrayOrdered: OrderedDictionary<String,Any> = OrderedDictionary<String,Any>()
        elementosArrayOrdered["Acciones"] = prod
        
        ElementosArray.setValue(prod, forKey: "Acciones")
        
        for elem in elementosOrdenados {
            elementosArrayOrdered[elem.value] = ElementosArray[elem.value]
        }
   
        let theJsonText = elementosArrayOrdered.json
        theJsonCleanText = elementosArrayOrdered.json
        records.append((record: counter, json: theJsonText))
        
        setVisibility(true)
        self.triggerRulesOnChange("bynewrow") // Al agregar nueva fila registro
        self.lblTitle.textColor = UIColor.black
        
        self.didTapGenerar()
        self.dataToTable(theJsonText)
        self.reloadDesign()
        
        if isClosing{
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true, completion: nil);
                self.formDelegate?.setNestedForm(nil);
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.triggerRulesOnChange("byallrows")
            self.triggerRulesOnChange("byatleastonerow")
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                if self.viewController?.form.allRows.count ?? 0 > 0{
                    for row in (self.viewController?.form.allRows)!{
                        row.baseValue = nil
                        switch row{
                        case is ListaRow:
                            let listarow: ListaRow = row as! ListaRow
                            let tl = listarow.cell.atributos?.tipolista
                            if tl != "combo" {
                                listarow.cell.gralButton.selectedButtons().forEach{$0.isSelected = false}
                                listarow.cell.setEdited(v: "sinSelección", isRobot: true)
                            }
                            if tl == "combo" {
                                listarow.cell.seleccionarValor(desc: "", id: "", isRobot: true)
                            }
                            break;
                        case is TextoRow:
                            let trow: TextoRow = row as! TextoRow
                            if trow.cell.mathematicsName.count > 0 {
                                for math in trow.cell.mathematicsName {
                                    self.formDelegate?.obtainMathematics(math, true)
                                }
                            }
                            break
                        case is NumeroRow:
                            let nrow: NumeroRow = row as! NumeroRow
                            if nrow.cell.mathematicsName.count > 0 {
                                for math in nrow.cell.mathematicsName {
                                    self.formDelegate?.obtainMathematics(math, true)
                                }
                            }
                            break
                        default: break;
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    // MARK: - DATOS PARA LA TABLA
    func dataToTable(_ json: String, _ isUpdating: Bool = false){
        getValuesFromJson(json)
        self.arrayRows = [String]()
        self.emptyArray = [String]()
        for section in viewController!.form.allSections{
            for row in section.allRows{
                
                for dictValue in self.dictValues{
                    if dictValue.key == row.tag{
                        
                        if row is TextoRow{
                            self.arrayRows.append(dictValue.value.valor)
                        }else if row is NumeroRow{
                            self.arrayRows.append(dictValue.value.valor)
                        }else if row is FechaRow{
                            self.arrayRows.append(dictValue.value.valor)
                        }else if row is MonedaRow{
                            self.arrayRows.append(dictValue.value.valor)
                        }else if row is TextoAreaRow{
                            self.arrayRows.append(dictValue.value.valor)
                        }else if row is RangoFechasRow{
                            self.arrayRows.append(dictValue.value.valor)
                        }else if row is ListaRow{
                            self.arrayRows.append(dictValue.value.valor)
                        }else if row is ListaTemporalRow{
                            self.arrayRows.append(dictValue.value.valor)
                        }else if row is SliderNewRow{
                            self.arrayRows.append(dictValue.value.valor)
                        }else if row is LogicoRow{
                            if dictValue.value.valor == "0" || dictValue.value.valor == "" || dictValue.value.valor == "false"{
                                self.arrayRows.append("◻︎")
                            }else if dictValue.value.valor == "1" || dictValue.value.valor == "true"{
                                self.arrayRows.append("☑︎")
                            }
                        }else if row is WizardRow{
                            self.arrayRows.append("wizard|\(((row as? WizardRow)?.cell?.getFinalizarLabel() ?? ""))")
                        }else if row is ComboDinamicoRow{
                            self.arrayRows.append(dictValue.value.valor)
                        }else if row is BotonRow{
                            self.arrayRows.append("boton|\(((row as? BotonRow)?.cell?.getTitleLabel() ?? ""))")
                        }
                    }
                }
                
            }
            
        }
        if arrayRows.isEmpty{
            self.dataRows.append(self.emptyArray)
            self.dataTotales.append(self.emptyArray)
        }else{
            if isUpdating{
                self.dataRows[self.senderTag] = self.arrayRows
            }else{
                self.dataRows.append(self.arrayRows)
            }
        }
        self.setEdited(v: "true")
        _ = self.calculateTotal()
    }
    
    
    private func calcularTotalOperacionMatematica() {
        if self.viewController?.form.allRows.count ?? 0 > 0{
            for row in (self.viewController?.form.allRows)! {
                //row.baseValue = nil
                switch row {
                case is TextoRow:
                    let trow: TextoRow = row as! TextoRow
                    if trow.cell.mathematicsName.count > 0 {
                        for math in trow.cell.mathematicsName {
                            self.formDelegate?.obtainMathematics(math, true)
                        }
                    }
                    break
                case is NumeroRow:
                    let nrow: NumeroRow = row as! NumeroRow
                    if nrow.cell.mathematicsName.count > 0 {
                        for math in nrow.cell.mathematicsName {
                            self.formDelegate?.obtainMathematics(math, true)
                        }
                    }
                    break
                case is MonedaRow:
                    let mrow: MonedaRow = row as! MonedaRow
                    if mrow.cell.mathematicsName.count > 0 {
                        for math in mrow.cell.mathematicsName {
                            self.formDelegate?.obtainMathematics(math, true)
                        }
                    }
                    break;
                case is TextoAreaRow:
                    let tarow: TextoAreaRow = row as! TextoAreaRow
                    if tarow.cell.mathematicsName.count > 0 {
                        for math in tarow.cell.mathematicsName {
                            self.formDelegate?.obtainMathematics(math, true)
                        }
                    }
                     break
                default: break;
                }
            }
        }
    }
    
//    Se llama al momento de totalizar un valor en la tabla:
    public func calculateTotal() -> [(id: String, formula: String)]{
        ff = [(id: String, formula: String)]()
        var operacion = ""
        switch atributos?.operaciontotal{
        case "suma": operacion = "+"; break;
        case "resta": operacion = "-"; break;
        case "promedio": operacion = ","; break;
        default: break;
        }
        if elementsToCalculate.count > 0{
            // Detect if there's anything to calculate
            for elemen in elementsToCalculate{
                // We get the id element
                var formula = ""
                for (ri, row) in allCleanedData.enumerated(){
                    // We get row
                    var dd = ""
                    for (_, data) in row.enumerated(){
                        // We get data
                        if elemen == data.key as? String{
                            // Validate if the data is a number
                            let NaN = Int(data.value as? String ?? "")
                            if NaN != nil{
                                if !recordsHide.contains(ri) {
                                    dd = data.value as? String ?? ""
                                    if formula.count != 0 && formula.last != Character(operacion){
                                        if dd != ""{ formula += operacion } }
                                    
                                    formula += "\(dd.replacingOccurrences(of: "+", with: ""))"
                               }
                            }
                        }
                    }
                }
                ff.append((id: elemen, formula: formula))
            }
        }
        
        return ff
    }
    
    public func didTapUpdate() -> Bool{
        
        cleanProd = NSMutableDictionary()
        for elem in arrayElementos!{
            detectValue(elem: elem, isPrellenado: false)
        }
        var auxId = -1
        self.records.enumerated().forEach { if $0.element == self.recordsVisibles[self.senderTag] { auxId = $0.offset } }
        if auxId != -1 {
            self.allCleanedData[auxId] = cleanProd
            self.ElementosCleanArray[auxId] = cleanProd
        }
        var tablaArray = ElementosArray
        let prod: NSMutableDictionary = NSMutableDictionary()
        prod.setValue(self.senderTag, forKey: "id")
        prod.setValue(true, forKey: "checked")
        prod.setValue(ConfigurationManager.shared.utilities.guid(), forKey: "guidanexo")
        //tablaArray.setValue(prod, forKey: "Acciones")
        tablaArray["Acciones"] = prod
        var theJsonText = ""
        

        if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: tablaArray, options: .sortedKeys){
            theJsonText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
        }
        
        let tablaCleanArray = ElementosCleanArray
        if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: tablaCleanArray, options: .sortedKeys){
            theJsonCleanText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
        }
        
        if self.records.indices.contains(self.senderTag){
            self.records[self.senderTag] = (record: self.senderTag, json: theJsonText)
        }
        setVisibility(true)
        self.triggerRulesOnChange("byeditrow")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.didTapGenerar()
            self.dataToTable(theJsonText, true)
            self.reloadDesign()
            self.triggerRulesOnChange("edit")
            self.triggerRulesOnChange("byallrows")
            self.triggerRulesOnChange("byatleastonerow")
            
            self.navigationController?.dismiss(animated: true, completion: nil)
            self.formDelegate?.setNestedForm(nil)
        }
        
        return true
    }
    
    func insertElementAtIndex(element: String?, index: Int) {
        while arrayRows.count <= index {
            arrayRows.append("")
        }
        arrayRows.insert(element!, at: index)
    }
    
    
    public func didTapGenerar() {
        var dictArray = Array<String>()
        for record in records{
            dictArray.append(record.json)
            
        }
        do{
            let options = JSONSerialization.WritingOptions(rawValue: 0)
            
            let data = try JSONSerialization.data(withJSONObject: dictArray, options: .sortedKeys)
            if var string = String(data: data, encoding: String.Encoding.utf8) {
                string = string.replacingOccurrences(of: "\"{", with: "{")
                string = string.replacingOccurrences(of: "}}\"", with: "}}")
                string = string.replacingOccurrences(of: "\\\"", with: "\"")
                string = string.replacingOccurrences(of: "\\", with: "")
                setEdited(v: string)
                row.validate()
                updateIfIsValid()
            }
        }catch { setEdited(v: "") }
    }
    
    public func getValuesFromJson(_ json: String){
        do{
            let customJson = json.replacingOccurrences(of: "\r\n", with: ",")
            let dict = try JSONSerializer.toDictionary(customJson)

            dictValues = Dictionary<String, (docid: String, valor: String, valormetadato: String)>()

            for dato in dict{
                let dictValor = dato.value as! NSMutableDictionary
                let docid = dictValor.value(forKey: "docid") as? String ?? "0"
                let valor = dictValor.value(forKey: "valor") as? String ?? ""
                let valormetadato = dictValor.value(forKey: "valormetadato") as? String ?? ""
                dictValues["\(dato.key)"] = (docid: docid, valor: valor, valormetadato: valormetadato)
            }
            _ = dictValues.sorted() { $0.key < $1.key }
            
        }catch{ }
    }
    
    // SETTING FROM FORMAT SAVED
    
    public func setValuesFromJson(){
        // Saving data to Json
        if row.value == nil{return}
        do{
            let arrayDictionary = try JSONSerializer.toArray(row.value!)
            for keyArray in arrayDictionary{
                cleanProd = NSMutableDictionary()
                let dictArray = keyArray as! NSMutableDictionary
                var dictCounter = 0
                var elementDict = Dictionary<String, (checked:String?, id:String?, docid:String?, valor:String?, valormetadato:String?)>()
                var jsonGen = "{"
                
                for dict in dictArray{
                    if dict.key as! String == "Acciones"{
                        let dictValor = dict.value as! NSMutableDictionary
                        let checked = dictValor.value(forKey: "checked") as? String ?? "false"
                        let id = dictValor.value(forKey: "id") as? String ?? "0"
                        dictCounter = Int(id) ?? 0
                        let guidanexo = dictValor.value(forKey: "guidanexo") as? String ?? ConfigurationManager.shared.utilities.guid()
                        
                        elementDict["\(dict.key)"] = (checked:checked, id:id, docid:nil, valor:nil, valormetadato:nil)
                        jsonGen += "\"Acciones\":{\"checked\":\"\(checked)\",\"id\":\"\(id)\",\"guidanexo\":\"\(guidanexo)\"},"
                        
                    }
                    if dict.key as! String != "Acciones"{
                        let dictValor = dict.value as! NSMutableDictionary
                        let docid = dictValor.value(forKey: "docid") as? String ?? "0"
                        let valor = dictValor.value(forKey: "valor") as? String ?? ""
                        let valormetadato = dictValor.value(forKey: "valormetadato") as? String ?? ""
                        elementDict["\(dict.key)"] = (checked:nil, id:nil, docid:docid, valor:valor, valormetadato:valormetadato)
                        jsonGen += "\"\(dict.key)\":{\"valor\":\"\(valor)\",\"valormetadato\":\"\(valor)\"},"
                        self.viewController?.reviewRulesOnColumns(idColumn: dict.key as! String, value: valor )
                        setCleanAttributes(idunico: "", idelem: dict.key as! String, valor: valor, metadato: valor)
                    }
                }
                jsonGen = String(jsonGen.dropLast())
                jsonGen += "}"
                // Adding Records
                var duplicateItems = false
                records.forEach{
                    if $0 == (record: dictCounter, json: jsonGen)
                    {   duplicateItems = true}  }
                if !duplicateItems{
                   records.append((record: dictCounter, json: jsonGen))
                    dataToTable(jsonGen)
                    self.allCleanedData.append(cleanProd)
                    self.ElementosCleanArray.append(cleanProd)
                }
            }
            
        }catch{ }
        if records.count > 0{
            self.atributos?.visible = true
            self.setHabilitado(true)
            self.setVisible(true)
            counter += records.count
            self.reloadDesign()
        }
    }
    
    @objc func multieditBtnAction(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        idMultiEdit.append(sender.tag)
    }
    
    @objc func editBtnAction(_ sender: UIButton){
        records.enumerated().forEach { if $0.element == recordsVisibles[sender.tag] { self.senderTag = $0.offset } }
        getValuesFromJson(recordsVisibles[sender.tag].json)
        
        viewController!.isEdited = true
        viewController!.isPreview = false
        navigationController = UINavigationController(rootViewController: viewController!)
        self.formDelegate?.setNestedForm(viewController)
        let presenter = Presentr(presentationType: .fullScreen)
        self.formViewController()?.customPresentViewController(presenter, viewController: navigationController ?? UINavigationController(), animated: true)
        //self.formDelegate?.getFormViewControllerDelegate()?.present(navigationController ?? UINavigationController(), animated: true, completion: nil)
        

        triggerRulesOnChange("editing,multi") //al abrir registro clic en lapiz editar
        triggerRulesOnChange("edit") // al editar registro "edit"

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { self.calcularTotalOperacionMatematica() }
        for section in viewController!.form.allSections{
            for row in section.allRows{
                self.elementRow(e: row, isPreview: false)
            }
        }
        
        if let tableView = viewController?.tableView {
            tableView.reloadData()
        }
    }
    
    @objc func visualizeBtnAction(_ sender: UIButton) {
        
        records.enumerated().forEach { if $0.element == recordsVisibles[sender.tag] { self.senderTag = $0.offset } }
        getValuesFromJson(recordsVisibles[sender.tag].json)
        
        viewController!.isEdited = false
        viewController!.isPreview = true
        navigationController = UINavigationController(rootViewController: viewController!)
        self.formDelegate?.setNestedForm(viewController)
        self.formDelegate?.getFormViewControllerDelegate()?.present(navigationController ?? UINavigationController(), animated: true, completion: nil)
        
        for section in viewController!.form.allSections{
            for row in section.allRows{
                self.elementRow(e: row, isPreview: true)
            }
        }
        viewController?.tableView.reloadData()
        
    }
    
    @objc func wizardBtnAction(_ sender: UIButton){
        self.senderTag = sender.tag
        // Getting info from Wizard
        var idStr = String(self.senderTag)
        let isBorW = idStr.first ?? Character("")
        idStr = String(idStr.dropFirst())
        let colRow = idStr.components(separatedBy: "09990")
        let rowTag = self.nameElement[Int(colRow[0]) ?? 0].id
        
        self.actionTask(String(isBorW), rowTag, Int(colRow[0]) ?? 0, Int(colRow[1]) ?? 0) { success in
            if success{  }
        }
        
    }
    
    func actionTask(_ id: String, _ tagRow: String, _ col: Int, _ row: Int, completion: (_ success: Bool) -> Void){
        // Getting info from Wizard
        var idStr = String(self.senderTag)
        idStr = String(idStr.dropFirst())
        var jsonRow = records[row].json
        var elementsById: [String: Any]?
        var dictArray = Array<String>()
        dictArray.append(jsonRow)
        
        do{
            let options = JSONSerialization.WritingOptions(rawValue: 0)
            let data = try JSONSerialization.data(withJSONObject: dictArray, options: options)
            elementsById = try JSONSerialization.jsonObject(with: (jsonRow.data(using: .utf8)!), options: []) as? [String: Any]
            if var string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                string = string.replacingOccurrences(of: "\"{", with: "{") as NSString
                string = string.replacingOccurrences(of: "}}\"", with: "}}") as NSString
                string = string.replacingOccurrences(of: "\\\"", with: "\"") as NSString
                jsonRow = string as String
            }
        }catch { jsonRow = "" }
        
        let prod: NSMutableDictionary = NSMutableDictionary(); prod.setValue(jsonRow, forKey: "valor"); prod.setValue(jsonRow, forKey: "valormetadato");
        
        let elementosArray:NSMutableDictionary = NSMutableDictionary()
        elementosArray.setValue(prod, forKey: "\(self.row.tag ?? "")")
        
        if elementsById?.count ?? 0 > 0{
            for elem in elementsById!{
                for nmElem in self.nameElement{
                    if elem.key == nmElem.id{
                        elementosArray.setValue(elem.value, forKey: elem.key)
                    }
                }
            }
        }
        
        if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: elementosArray, options: .sortedKeys){
            jsonRow = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
            jsonRow = jsonRow.replacingOccurrences(of: "\\\\\\\"", with: "\\\"")
        }
        
        if id == "9"{
            // Wizard Actions
            let wizardRow = viewController!.form.rowBy(tag: tagRow)
            let attrWizard = (wizardRow as? WizardRow)?.cell.atributos
            if attrWizard == nil { return }
            if attrWizard!.plantillaabrir != ""{
                if FormularioUtilities.shared.prefilleddata != nil{
                    self.formDelegate?.setPrefilledDataToNewForm(attrWizard!.plantillaabrir, json: jsonRow, elements: elementosArray)
                    completion(true)
                }
            }else{
                switch  attrWizard?.tipoguardado ?? ""{
                case "borrador":
                    formDelegate?.wizardActionTabla(id: attrWizard?.tipoguardado ?? "", validar: true, tipo: "borrador", atributos: attrWizard!); break;
                default: break;
                }
                completion(false)
            }
            
        }else if id == "8"{
            // Button Actions
            let buttonrow = viewController!.form.rowBy(tag: tagRow)
            let attrButton = (buttonrow as? BotonRow)?.cell.atributos
            if attrButton == nil { return }
            (buttonrow as? BotonRow)?.cell.botonAction(nil)
            clickInRow = String((elementsById!["Acciones"] as! [String : Any])["id"] as? Int ?? -1)
            clickInRow = String("\(clickInRow)-\(String((buttonrow as? BotonRow)?.cell.elemento._idelemento ?? ""))")
            self.triggerRulesOnChange("byallrows")
            self.triggerRulesOnChange("byatleastonerow")
            ConfigurationManager.shared.elementosArray = elementosArray
            self.clickInRow = ""
            completion(true)
        }else{
            completion(false)
        }
    }
        
    @objc func trashBtnAction(_ sender: UIButton){
        var auxId = 0
        records.enumerated().forEach { if $0.element == recordsVisibles[sender.tag] { auxId = $0.offset } }
        var auxRecordsHide = [Int]()
        recordsHide.forEach {   auxRecordsHide.append( $0 > auxId ? $0 - 1 : $0 )   }
        recordsHide = auxRecordsHide
        if self.recordsVisibles.indices.contains(sender.tag){
            self.recordsVisibles.remove(at: sender.tag)
        }
        if self.records.indices.contains(auxId){
            self.records.remove(at: auxId)
        }
        if self.dataRows.indices.contains(auxId){
            self.dataRows.remove(at: auxId)
        }
        if self.allCleanedData.indices.contains(auxId){
            self.allCleanedData.remove(at: auxId)
        }
        if self.ElementosCleanArray.indices.contains(auxId){
            self.ElementosCleanArray.remove(at: auxId)
        }
        _ = self.calculateTotal()
        //self.reloadDesign()
        self.didTapGenerar()
        self.calcularTotalOperacionMatematica()
        triggerRulesOnChange("remove") // al borrar registro
        if records.count == 0{
            self.lblTitle.textColor =  self.lblRequired.isHidden ?  UIColor.black : UIColor.red
            setVisibility(false)
        }
    }
    
    @IBAction func AgregarBtnAction(_ sender: Any) {
        let btn = sender as? UIButton
        if btn != nil{
            viewController!.clearAdd = true
        }
        
        if ((atributos?.filasmax ?? 0) != 0) && (atributos?.filasmax ?? 0 <= self.records.count){
            setMessage("elemts_table_rowmax".langlocalized(), .error)
            return
        }
        for section in viewController!.form.allSections{
            for row in section.allRows{
                self.elementRow(e: row, isPreview: false)
            }
        }
        
        viewController!.executeClear()
        viewController!.isEdited = false
        viewController!.isPreview = false
        navigationController = UINavigationController(rootViewController: viewController!)
        self.formDelegate?.setNestedForm(viewController)
        self.formDelegate?.getFormViewControllerDelegate()?.present(self.navigationController!, animated: true, completion: nil)
    }
    
    // MARK: SETTING
    public func setObject(obj: Elemento, hijos: Form){
        self.tag = 00001
        w = Int(self.frame.size.width - 20)
        elemento = obj
        atributos = obj.atributos as? Atributos_tabla
        self.elemento.validacion.idunico = atributos?.idunico ?? ""
        initRules()
        if atributos?.titulo ?? "" == ""{ setOcultarTitulo(true) }else{ setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        if atributos?.subtitulo ?? "" == ""{ setOcultarSubtitulo(true) }else{ setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false) }
        setHeightFromTitles()
        setVisible(atributos?.visible ?? false)
        setAlignment(atributos?.alineadotexto ?? "")
        setTextStyle(atributos?.estilotexto ?? "")
       
        setInfo()
        setButtonText()
        setColorButton()
        setPermissions()
        setVisibleObjects(hijos: hijos)
        setDesign()
        
        viewController!.attr = atributos
        viewController!.delegate = self
        viewController!.row = self
        
        if viewController?.form.allRows.count != nil{ self.rowsTable = self.nameElement.count }
        
        if atributos?.columnastotalizar.count ?? 0 > 0{
            for column in (atributos?.columnastotalizar)!{
                if column.value as? String == "true"{
                    elementsToCalculate.append(column.key)
                }
            }
        }
    }
    
    public func setElements(_ elementos: Array<Elemento>){ arrayElementos = elementos }
    
    open override func setup() {
        super.setup()
        
        let apiObject = ObjectFormManager<TablaCell>()
        apiObject.delegate = self
                
        btnInfo.layer.cornerRadius = 13
        btnInfo.layer.borderColor = UIColor.gray.cgColor
        btnInfo.layer.borderWidth = 1
        btnInfo.addTarget(self, action: #selector(setAyuda(_:)), for: .touchDown)
        btnInfo.isHidden = true
        
        self.agregarBtn.layer.cornerRadius = 2.5
        self.btnMultiEdicion.layer.cornerRadius = 2.5
        
        viewController = TablaPlantillaViewController.init(nibName: "ZyNLBrRlHEIiDQy", bundle: Cnstnt.Path.framework)
        
        navigationController = UINavigationController(rootViewController: viewController!)
        
        lblRequired.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 30.0)
        lblMessage.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 13.0)
        lblTitle.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        lblSubtitle.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        btnInfo.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 15.0)
    }
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) {
        guard let _ = self.atributos, let help = atributos?.ayuda else{
            return;
        }
        toogleToolTip(help)
    }
    open override func update() {
        super.update()
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        
        if isInfoToolTipVisible{
            toolTip!.dismiss()
            isInfoToolTipVisible = false
        }
    }
    
    func elementType(e: BaseRow){
        let row = e
        switch row {
        case is TextoRow: self.nameElement.append((row.tag ?? "", ((row as? TextoRow)?.cell?.getTitleLabel() ?? ""))); heightCard += 1; break
        case is NumeroRow: self.nameElement.append((row.tag ?? "", ((row as? NumeroRow)?.cell?.getTitleLabel() ?? ""))); heightCard += 1; break
        case is TextoAreaRow: self.nameElement.append((row.tag ?? "", ((row as? TextoAreaRow)?.cell?.getTitleLabel() ?? ""))); heightCard += 1; break
        case is FechaRow: self.nameElement.append((row.tag ?? "", ((row as? FechaRow)?.cell?.getTitleLabel() ?? ""))); heightCard += 1; break
        case is MonedaRow: self.nameElement.append((row.tag ?? "", ((row as? MonedaRow)?.cell?.getTitleLabel() ?? ""))); heightCard += 1; break
        case is RangoFechasRow: self.nameElement.append((row.tag ?? "", ((row as? RangoFechasRow)?.cell?.getTitleLabel() ?? ""))); heightCard += 1; break
        case is ListaRow: self.nameElement.append((row.tag ?? "", ((row as? ListaRow)?.cell?.getTitleLabel() ?? ""))); heightCard += 1; break
        case is ListaTemporalRow: self.nameElement.append((row.tag ?? "", ((row as? ListaTemporalRow)?.cell?.getTitleLabel() ?? ""))); heightCard += 1; break
        case is SliderNewRow: self.nameElement.append((row.tag ?? "", ((row as? SliderNewRow)?.cell?.getTitleLabel() ?? ""))); heightCard += 1; break
        case is LogicoRow: self.nameElement.append((row.tag ?? "", ((row as? LogicoRow)?.cell?.getTitleLabel() ?? ""))); break
        case is ComboDinamicoRow: self.nameElement.append((row.tag ?? "", ((row as? ComboDinamicoRow)?.cell?.getTitleLabel() ?? ""))); break
        case is WizardRow: self.nameElement.append((row.tag ?? "","wizard|\(((row as? WizardRow)?.cell?.getFinalizarLabel() ?? ""))")); break
        case is BotonRow: self.nameElement.append((row.tag ?? "","boton|\(((row as? BotonRow)?.cell?.getTitleLabel() ?? ""))")); break
        
        default: break
        }
        
    }
    
    func elementRow(e: BaseRow, isPreview: Bool = false){
        let row = e
        switch row {
        case is TextoRow:
            let texto = row as? TextoRow
            for dictValue in self.dictValues{
                if dictValue.key == row.tag{
                    texto?.cell.setEdited(v: dictValue.value.valor)
                    if isPreview{ texto?.cell.setHabilitado(false)
                    }else{ texto?.cell.setHabilitado(true)}
                    texto?.cell.updateData()
                }
            }
            break
        case is NumeroRow:
            let numero = row as? NumeroRow
            for dictValue in self.dictValues{
                if dictValue.key == row.tag{
                    numero?.cell.setEdited(v: dictValue.value.valor)
                    if isPreview{ numero?.cell.setHabilitado(false)
                    }else{ numero?.cell.setHabilitado(true) }
                    numero?.cell.update()
                }
            }
            break
        case is TextoAreaRow:
            let textoArea = row as? TextoAreaRow
            for dictValue in self.dictValues{
                if dictValue.key == row.tag{
                    textoArea?.cell.setEdited(v: dictValue.value.valor)
                    if isPreview{ textoArea?.cell.setHabilitado(false)
                    }else{ textoArea?.cell.setHabilitado(true) }
                    textoArea?.cell.update()
                }
            }
            break
        case is FechaRow:
            let fecha = row as? FechaRow
            for dictValue in self.dictValues{
                if dictValue.key == row.tag{
                    if fecha?.cell.atributos != nil{
                        fecha?.cell.setEditedFecha(v: dictValue.value.valor, format: "dd/MM/yyyy")
                    }
                    if fecha?.cell.atributosHora != nil{
                        fecha?.cell.setEditedHora(v: dictValue.value.valor)
                    }
                    if isPreview{ fecha?.cell.setHabilitado(false)
                    }else{ fecha?.cell.setHabilitado(true) }
                    fecha?.cell.update()
                }
            }
            break
        case is MonedaRow:
            let moneda = row as? MonedaRow
            for dictValue in self.dictValues{
                if dictValue.key == row.tag{
                    moneda?.cell.setEdited(v: dictValue.value.valor)
                    if isPreview{ moneda?.cell.setHabilitado(false)
                    }else{ moneda?.cell.setHabilitado(true) }
                    moneda?.cell.update()
                }
            }
            break
        case is RangoFechasRow:
            let rangoFechas = row as? RangoFechasRow
            for dictValue in self.dictValues{
                if dictValue.key == row.tag{
                    rangoFechas?.cell.setEdited(v: dictValue.value.valor)
                    if isPreview{ rangoFechas?.cell.setHabilitado(false)
                    }else{ rangoFechas?.cell.setHabilitado(true) }
                    rangoFechas?.cell.update()
                }
            }
            break
        case is ListaRow:
            let lista = row as? ListaRow
            for dictValue in self.dictValues{
                if dictValue.key == row.tag{
                    
                    if lista?.cell.atributos?.tipolista != "combo" { lista?.cell.setEdited(v: dictValue.value.valor, isRobot: true); break; }
                    else {
                        var selectedValues = ""
                        var showedValues = ""
                        for item in (lista?.cell.listItemsLista ?? []) {
                            let val = String(item.split(separator: "|").first ?? "")
                            let id = String(item.split(separator: "|").last ?? "")
                            if val == dictValue.value.valor || id == dictValue.value.valor{
                                selectedValues += "\(id)"
                                showedValues += "\(val)"
                            }
                        }
                        if selectedValues != ""{
                            lista?.cell.seleccionarValor(desc: showedValues, id: selectedValues, isRobot: true)
                        }
                    }
                }
                
                //lista?.cell.setEdited(v: dictValue.value.valor)
                if isPreview{ lista?.cell.setHabilitado(false)
                }else{ lista?.cell.setHabilitado(true) }
                lista?.cell.update()
            }
            break
        case is ListaTemporalRow:
            let lista = row as? ListaTemporalRow
            for dictValue in self.dictValues{
                if dictValue.key == row.tag{
                    lista?.cell.setEdited(v: dictValue.value.valor)
                    if isPreview{ lista?.cell.setHabilitado(false)
                    }else{ lista?.cell.setHabilitado(true) }
                    
                    lista?.cell.update()
                    
                }
            }
            break
        case is SliderNewRow:
            let slider = row as? SliderNewRow
            for dictValue in self.dictValues{
                if dictValue.key == row.tag{
                    slider?.cell.setEdited(v: dictValue.value.valor)
                    if isPreview{ slider?.cell.setHabilitado(false)
                    }else{ slider?.cell.setHabilitado(true) }
                    slider?.cell.update()
                }
            }
            break
        case is LogicoRow:
            let logico = row as? LogicoRow
            for dictValue in self.dictValues{
                if dictValue.key == row.tag{
                    logico?.cell.setEdited(v: dictValue.value.valor)
                    if isPreview{ logico?.cell.setHabilitado(false)
                    }else{ logico?.cell.setHabilitado(true) }
                    logico?.cell.update()
                }
            }
            break
        case is BotonRow:
            let boton = row as? BotonRow
            if isPreview{ boton?.cell.setHabilitado(false)
            }else{ boton?.cell.setHabilitado(true) }
            boton?.cell.update()
            break
        default:
            break
        }
    }
    
    func detectValue(elem: Elemento, isPrellenado: Bool){
        if elem.elementos != nil, elem.elementos?.elemento != nil {
            for e in (elem.elementos?.elemento)!{
                detectValue(elem: e, isPrellenado: isPrellenado)
            }
        }else{
            self.setMetaAttributes(elem, isPrellenado)
            self.setMetaCleanAttributes(elem, isPrellenado)
            
        }
    }
    
    public func setCleanAttributes(idunico id: String, idelem e: String, valor l:String, metadato m:String){
        if id != ""{
            cleanProd.setValue(m, forKey: "\(id)");
        }else{
            cleanProd.setValue(m, forKey: "\(e)");
        }
    }
    
    public func setMetaCleanAttributes(_ e: Elemento, _ isPrellenado: Bool){
        let tipoElemento = TipoElemento(rawValue: "\(e._tipoelemento)") ?? TipoElemento.other
        switch tipoElemento {
        case .eventos: break;
        case .plantilla, .pagina, .seccion: break;
        case .boton: break;
        case .combodinamico:
            setCleanAttributes(idunico: e.validacion.idunico, idelem: e._idelemento, valor: e.validacion.id, metadato: e.validacion.id)
            break;
        case .lista, .comboboxtemporal, .marcadodocumentos:
            setCleanAttributes(idunico: e.validacion.idunico, idelem: e._idelemento, valor: e.validacion.id, metadato: e.validacion.id)
            break;
        case .codigobarras, .codigoqr, .nfc, .deslizante, .fecha, .hora, .logico, .moneda, .numero, .password, .rangofechas, .texto, .textarea, .wizard:
            setCleanAttributes(idunico: e.validacion.idunico, idelem: e._idelemento, valor: e.validacion.valor, metadato: e.validacion.valormetadato)
        case .espacio: break;
        case .leyenda: break;
        case .logo: break;
        case .semaforotiempo, .tabber: break;
        case .tabla: break;
        case .metodo, .servicio: break;
        case .other: break;
        case .audio, .calculadora, .firma, .firmafad, .georeferencia, .imagen, .mapa, .video, .videollamada, .voz, .documento, .huelladigital, .rostrovivo, .capturafacial: break;
        case .veridasphotoselfie, .veridasvideoselfie, .veridasdocumentcapture: break ;
        default: break;
        }
    }
    
    public func setMetaAttributes(_ e: Elemento, _ isPrellenado: Bool){
        let tipoElemento = TipoElemento(rawValue: "\(e._tipoelemento)") ?? TipoElemento.other
        
        switch tipoElemento {
            
        case .eventos: break;
        case .plantilla, .pagina, .seccion: break;
        case .boton:
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setDataAttributes(valor: e._tipoelemento, metadato: e._tipoelemento, habilitado: false, visible: false)
            
        case .combodinamico:
            let titulo = (e.atributos as! Atributos_comboDinamico).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .comboboxtemporal:
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setComboboxTempAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, catalogoDestino: e.validacion.catalogoDestino)
            
        case .codigobarras:
            let titulo = (e.atributos as! Atributos_codigobarras).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .codigoqr:
            let titulo = (e.atributos as! Atributos_codigoqr).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .nfc:
            let titulo = (e.atributos as! Atributos_escanerNFC).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .deslizante:
            let titulo = (e.atributos as! Atributos_Slider).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .espacio: break;
        case .fecha:
            let titulo = (e.atributos as! Atributos_fecha).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .hora:
            let titulo = (e.atributos as! Atributos_hora).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .leyenda: break;
        case .lista, .marcadodocumentos:
            let titulo = (e.atributos as! Atributos_lista).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .logico:
            let titulo = (e.atributos as! Atributos_logico).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .logo: break;
        case .moneda:
            let titulo = (e.atributos as! Atributos_moneda).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .numero:
            let titulo = (e.atributos as! Atributos_numero).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .password:
            let titulo = (e.atributos as! Atributos_password).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .rangofechas:
            let titulo = (e.atributos as! Atributos_fecha).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .semaforotiempo, .tabber: break;
        case .tabla: break;
        case .texto:
            //self.ElementosArray.setValue(self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico), forKey: "\(e._idelemento)")
            let titulo = (e.atributos as! Atributos_texto).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
            
            break;
        case .textarea:
            let titulo = (e.atributos as! Atributos_textarea).titulo
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setTablaDataAttributes(valor: e.validacion.valor, metadato: e.validacion.valormetadato, idunico: e.validacion.idunico, titulo: titulo)
             
            break;
        case .wizard:
            self.ElementosArray["\(e._idelemento)"] = self.formDelegate?.setDataAttributes(valor: e._tipoelemento, metadato: e._tipoelemento, habilitado: false, visible: false)
            
            break;
        case .metodo, .servicio: break;
        case .audio, .calculadora, .firma, .firmafad, .georeferencia, .imagen, .mapa, .video, .videollamada, .voz, .huelladigital, .rostrovivo, .capturafacial, .documento: break;
        case .veridasdocumentcapture, .veridasphotoselfie, .veridasvideoselfie:
            break
        case .other: break;
        default: break;
        }
    }
    
    //MARK: Collection View Delegate
        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if (self.records.count == self.recordsHide.count) || (self.recordsHide.count == 1 && self.recordsHide.last == 9999) {
                setVisibility(false); return 0
            } else {
                if !self.recordsHide.isEmpty{
                    dataRowsVisibles = [[String]]()
                    self.recordsVisibles = [(record: Int, json: String)]()
                    for (index, value) in self.dataRows.enumerated(){
                        var isDiff = true
                        for indexHide in self.recordsHide{
                            if index == indexHide { isDiff = false; break; }
                        }
                        if isDiff {
                            self.dataRowsVisibles.append(value)
                            self.recordsVisibles.append(self.records[index])
                        }
                    }
                    return self.dataRowsVisibles.count
                } else {
                    if self.dataRows.count > 0{
                        self.dataRowsVisibles = self.dataRows
                        self.recordsVisibles = self.records
                        return self.dataRowsVisibles.count
                    }else{ return 0 }
                }
            }
        }
        
        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TableCollectionViewCell.identifier, for: indexPath) as! TableCollectionViewCell
            
            // Setting permissions to actions
            // Permiso Multieditar
            cell.btnChck.setImage(UIImage(named: "unchecked", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
            cell.btnChck.setImage(UIImage(named: "checked", in: Cnstnt.Path.framework, compatibleWith: nil), for: .selected)
            if !(atributos?.permisotablamultiedicion ?? false){
                cell.btnChck.isUserInteractionEnabled = false
                cell.btnChck.isEnabled = false
                cell.btnChck.isHidden = true
            }
            cell.btnChck.addTarget(self, action: #selector(self.multieditBtnAction(_ :)), for: .touchUpInside)
            cell.btnChck.tag = indexPath.row
            // Permiso Editar
            if self.recordsEdit.contains(-1) {
                cell.btnEdit.isUserInteractionEnabled = (atributos?.permisotablaeditarr ?? false)
                cell.btnEdit.isEnabled = (atributos?.permisotablaeditarr ?? false)
                cell.btnEdit.isHidden = !(atributos?.permisotablaeditarr ?? false)
            } else {
                let auxVisible = self.recordsEdit.contains(indexPath.row)
                cell.btnEdit.isUserInteractionEnabled = auxVisible
                cell.btnEdit.isEnabled = auxVisible
                cell.btnEdit.isHidden = !auxVisible
            }
            
            cell.btnEdit.addTarget(self, action: #selector(self.editBtnAction(_ :)), for: .touchUpInside)
            cell.btnEdit.tag = indexPath.row
            
            // Permiso Eliminar
            if self.recordsDelete.contains(-1) {
                cell.btnDel.isUserInteractionEnabled = (atributos?.permisotablaeliminarr ?? false)
                cell.btnDel.isEnabled = (atributos?.permisotablaeliminarr ?? false)
                cell.btnDel.isHidden = !(atributos?.permisotablaeliminarr ?? false)
            } else {
                let auxVisible = self.recordsDelete.contains(indexPath.row)
                cell.btnDel.isUserInteractionEnabled = auxVisible
                cell.btnDel.isEnabled = auxVisible
                cell.btnDel.isHidden = !auxVisible
            }
            
            cell.btnDel.addTarget(self, action: #selector(self.trashBtnAction(_ :)), for: .touchUpInside)
            cell.btnDel.tag = indexPath.row
            
            // Permiso Mostrar
            if !(atributos?.permisotablamostrar ?? false){
                cell.btnPrw.isUserInteractionEnabled = false
                cell.btnPrw.isEnabled = false
                cell.btnPrw.isHidden = true
            } else {
                cell.btnPrw.isUserInteractionEnabled = true
                cell.btnPrw.isEnabled = true
                cell.btnPrw.isHidden = false
            }
            cell.btnPrw.addTarget(self, action: #selector(self.visualizeBtnAction(_ :)), for: .touchUpInside)
            cell.btnPrw.tag = indexPath.row
            
            cell.rowTitle.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 16.0)
            
            let obj = dataRowsVisibles[indexPath.row]
            cell.rowTitle.isHidden = true
            //cell.rowTitle.text = "Fila \(indexPath.row + 1)"
            for view in cell.scroll.subviews {
                view.removeFromSuperview()
            }
            let point = CGPoint(x: 5, y: 5)
            var frame = CGRect(origin: point, size: CGSize(width: self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0 - 40, height: 19.5))
            firstcolum = false
            for (index, data) in obj.enumerated(){
                if atributos?.columnasvisualizar.count == 0{ continue }
                var isColumnVisible = false
                for elem in (atributos?.columnasvisualizar) ?? [:] {
                    if elem.key == self.nameElement[index].id && (Bool(elem.value as! String) ?? false)
                    {   isColumnVisible = true  }
                }
                if !isColumnVisible { continue }
                
                var isColumnHidden = false
                if self.columnByRowHidden[self.nameElement[index].id] != nil {
                    let rowsOk : [Int] = (self.columnByRowHidden[self.nameElement[index].id]) as? [Int] ?? []
                    isColumnHidden = rowsOk.contains(indexPath.row) ? true : false
                }
                if isColumnHidden{ continue }
                
                if data.contains("wizard") || data.contains("boton"){
                    let btn = UIButton(frame: frame)
                    let tagRow = self.nameElement[index].id
                    let c = index
                    let r = indexPath.row
                    
                    if data.contains("wizard"){
                        btn.tag = Int("9\(c)09990\(r)") ?? 0
                    }else if data.contains("boton"){
                        btn.tag = Int("8\(c)09990\(r)") ?? 0
                        let buttonrow = viewController!.form.rowBy(tag: tagRow)
                        let attrButton = (buttonrow as? BotonRow)?.cell.atributos
                        
                        if attrButton != nil{
                            if attrButton?.vercomoregistro == false{ continue }
                        }

                    }else{ btn.tag = Int("\(c)00\(r)") ?? 0 }
                    
                    btn.frame.size = CGSize(width: self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0 - 40, height: 40)
                    
                    btn.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                    if ConfigurationManager.shared.isConsubanco{
                        btn.backgroundColor = UIColor(red: 24/255, green: 32/255, blue: 111/255, alpha: 1.0)
                    }else{
                      btn.backgroundColor = #colorLiteral(red: 0, green: 0.6980392157, blue: 0.9490196078, alpha: 1)
                    }
                    btn.setTitleColor(.white, for: .normal)
                    btn.contentHorizontalAlignment = .left
                    let name = data.split{$0 == "|"}.map(String.init)
                    btn.setTitle("\(name.last ?? "")", for: .normal)
                    btn.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
                    btn.addTarget(self, action: #selector(self.wizardBtnAction(_ :)), for: .touchUpInside)
                    frame.origin.y += 45
                    cell.scroll.addSubview(btn)
                }else{
                    frame.size = CGSize(width: self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0 - 50, height: 20.0)
                    
                    let lbl = UILabel()
                    lbl.translatesAutoresizingMaskIntoConstraints = false
                    lbl.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 16.0)
                    lbl.numberOfLines = 0
                    lbl.adjustsFontSizeToFitWidth = false
                    lbl.text = "\(self.nameElement[index].title): \(data)"
                    lbl.tag = index
                    lbl.backgroundColor = UIColor.white
                    
                    frame.origin.y += 20
                    cell.scroll.addSubview(lbl)
                    
                     // MARK: se necesita un primer label para tomarlo como referencia
                    
                    if index == 0 || !firstcolum  {
                        lastItemConstraint = cell.scroll.topAnchor
                        firstcolum = true
                    }
                    
                    NSLayoutConstraint.activate([
                        lbl.topAnchor.constraint(equalTo: lastItemConstraint, constant: 5.0),
                        lbl.widthAnchor.constraint(equalTo: cell.scroll.widthAnchor, multiplier: 0.95),
                        lbl.centerXAnchor.constraint(equalTo: cell.scroll.centerXAnchor)
                    ])
                    
                    lastItemConstraint = lbl.bottomAnchor
                    
                    if index == self.nameElement.count - 1 {
                        // MARK: cuando pinte el ultimo elemento que reinicie el constraint
                        print("ultimo index \(index) == \(self.nameElement.count - 1)")
                        lastItemConstraint = cell.scroll.topAnchor
                    }
                  
                }
            }
            self.innerScrollSize = (frame.origin.y)
            cell.scroll.contentSize = CGSize(width: self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0 - 40, height: frame.origin.y)
            cell.cardHolder.backgroundColor = UIColor.clear
            cell.cardHolder.layer.borderWidth = 3.0
            cell.cardHolder.layer.borderColor = #colorLiteral(red: 0.07843137255, green: 0.4980392157, blue: 0.5764705882, alpha: 1)
            cell.cardHolder.layer.cornerRadius = 10.0
            
            return cell
        }
    
    public func getTotal(_ index: Int)->String{
        // Getting Totales
        for formula in ff{
            if formula.id == self.nameElement[index].id{
                if formula.formula == ""{ return "" }
                if formula.formula.contains(","){
                    let sum = formula.formula.split{$0 == ","}.map(String.init)
                    let doubleArray = sum.map { Float($0)!}
                    let average = (doubleArray as NSArray).value(forKeyPath: "@avg.floatValue")
                    return "\(average ?? 0)"
                }else{
                    let mathExpression = NSExpression(format: "\(formula.formula)")
                    let mathValue = mathExpression.expressionValue(with: nil, context: nil) as? Double
                    let valueString = String(mathValue ?? 0)
                    return "\(valueString)"
                }
                
            }
        }
        return ""
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}

// MARK: - OBJECTFORMDELEGATE
extension TablaCell: ObjectFormDelegate{
    // Protocolos Genéricos
    // Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "Tabla"
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
        self.atributos?.estilotexto = style
        self.lblTitle.font = self.lblTitle.font.setStyle(style)
        self.lblSubtitle.font = self.lblSubtitle.font.setStyle(style)
    }
    // MARK: Set - Decoration
    public func setDecoration(_ decor: String){
        self.atributos?.decoraciontexto = decor
        self.lblTitle.attributedText = self.lblTitle.text?.setDecoration(decor)
        self.lblSubtitle.attributedText = self.lblSubtitle.text?.setDecoration(decor)
    }
    // MARK: Set - Alignment
    public func setAlignment(_ align: String){
        self.atributos?.alineadotexto = align
        self.lblTitle.textAlignment = self.lblTitle.setAlignment(align)
        self.lblSubtitle.textAlignment = self.lblSubtitle.setAlignment(align)
    }
    // MARK: Set - VariableHeight
    public func setVariableHeight(Height h: CGFloat) {
        DispatchQueue.main.async {
            self.height = {return h}
            self.layoutIfNeeded()
            if self.row != nil { self.row.reload() }
            self.formDelegate?.reloadTableViewFormViewController()
        }

    }
    // MARK: Set - Title Text
    public func setTitleText(_ text:String){
        self.lblTitle.text = text
    }
    // MARK: Set - Subtitle Text
    public func setSubtitleText(_ text:String){
        self.lblSubtitle.text = text
    }
    // MARK: Set - Height From Titles
    public func setHeightFromTitles(){
        let ttl = lblTitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        let sttl = lblSubtitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        lblTitle.numberOfLines = ttl
        lblSubtitle.numberOfLines = sttl
        var httl: CGFloat = 0
        var hsttl: CGFloat = 0
        if atributos != nil{
            if atributos?.ocultartitulo ?? false{ if ttl == 0{ httl = -self.lblTitle.font.lineHeight } }else{ httl = (CGFloat(ttl) * self.lblTitle.font.lineHeight) - self.lblTitle.font.lineHeight }
            if atributos?.ocultarsubtitulo ?? false{ if sttl == 0{ hsttl = -self.lblSubtitle.font.lineHeight } }else{ hsttl = (CGFloat(sttl) * self.lblSubtitle.font.lineHeight) - self.lblSubtitle.font.lineHeight }
        }
        let h: CGFloat = httl + hsttl
        let hh = (row as? TablaRow)?.cell.contentView.frame.size.height ?? 0 + h
        setVariableHeight(Height: hh)
    }
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
            toolTip?.show(forView: self.btnInfo, withinSuperview: (row as? TablaRow)?.cell.formCell()?.formViewController()?.tableView)
            isInfoToolTipVisible = true
        }
    }
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){
        // message, valid, alert, error
        if string == ""{ self.lblMessage.text = ""; self.lblMessage.isHidden = true; return; }
        DispatchQueue.main.async {
            self.lblMessage.text = "  \(string)  "
            let colors = self.formDelegate?.getColorsErrors(state)
            self.lblMessage.backgroundColor = colors![0]
            self.lblMessage.textColor = colors![1]
            self.lblMessage.isHidden = false
            self.layoutIfNeeded()
        }
    }
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil{ setRequerido(atributos?.requerido ?? false) }
    }
    // MARK: Set - MinMax
    public func setMinMax(){
        var rules = RuleSet<String>()
        if atributos != nil, atributos!.filasmin != 0{
            rules.add(rule: ReglaMinFila(minFila: UInt(atributos!.filasmin)))
        }
        row.add(ruleSet: rules)
    }
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
    public func setOcultarSubtitulo(_ bool: Bool){
        self.atributos?.ocultarsubtitulo = bool
        if bool{
            self.lblSubtitle.isHidden = true
            self.setSubtitleText("")
        }else{
            self.lblSubtitle.isHidden = false
            if atributos != nil{
                setSubtitleText(atributos?.subtitulo ?? "")
            }
        }
        self.layoutIfNeeded()
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
        row.value = v == "true" ? row.value : v
        
        // MARK: - Setting estadisticas
        setEstadistica()
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = ""
        est!.KeyStroke += 1
        elemento.estadisticas = est!
        let fechaValorFinal = Date.getTicks()
        self.setEstadisticaV2()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = v.replaceLineBreakEstadistic()
        self.estV2!.Cambios += 1
        elemento.estadisticas2 = estV2!
        
        triggerEvent("alcambiar")
        //triggerRulesOnChange(nil) /* "tableshowadd,editing,multi") // en modo edición */
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
            self.lblRequired.isHidden = false
            self.lblTitle.textColor = UIColor.red
        }else{
            self.lblRequired.isHidden = true
            self.lblTitle.textColor = UIColor.black
        }
        self.layoutIfNeeded()
        self.row.add(ruleSet: rules)
    }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        self.lblMessage.isHidden = true
        if row.isValid{
            // Setting row as valid
            if row.value == nil || row.value == elemento._idelemento {
                DispatchQueue.main.async {
                    self.setOcultarSubtitulo(self.atributos?.ocultarsubtitulo ?? false)
                    self.lblMessage.text = ""
                    self.lblMessage.isHidden = true
                    self.viewValidation.backgroundColor = Cnstnt.Color.gray
                    self.layoutIfNeeded()
                }
                self.elemento.validacion.validado = false
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            }else{
                DispatchQueue.main.async {
                    self.setOcultarSubtitulo(self.atributos?.ocultarsubtitulo ?? false)
                    self.lblMessage.text = ""
                    self.lblMessage.isHidden = true
                    self.viewValidation.backgroundColor = Cnstnt.Color.gray
                    self.layoutIfNeeded()
                }
                resetValidation()
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.valor = row.value ?? ""
                    if theJsonCleanText != ""{
                        self.elemento.validacion.valormetadato  = theJsonCleanText
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
                self.viewValidation.backgroundColor = UIColor.red
                if (self.row.validationErrors.count) > 0{
                    self.lblMessage.text = "  \(self.row.validationErrors[0].msg)  "
                    let colors = self.formDelegate?.getColorsErrors(.error)
                    self.lblMessage.backgroundColor = colors![0]
                    self.lblMessage.textColor = colors![1]
                }
                self.lblMessage.isHidden = false
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
    
    // MARK: SET VISIBILITY
    public func setVisibility(_ isStreched: Bool){
        if isStreched{
            if atributos != nil, atributos?.vistamovil == "table"
            {
                self.spreadSheet.isHidden = false
                self.totalCard.isHidden = true
                self.setVariableHeight(Height: 360)
            } else if atributos != nil, atributos?.vistamovil == "cards"
            {
                self.collectionCard.isHidden = false
                if self.atributos?.vertotales ?? false{
                    self.totalCard.isHidden = false
                }else{
                    self.totalCard.isHidden = true
                }
            }
        }else{
            self.spreadSheet.isHidden = true
            self.collectionCard.isHidden = true
            self.totalCard.isHidden = true
            self.setVariableHeight(Height: 100)
        }
    }
    // MARK: RELOAD TOTALES
    public func reloadTotales(){
        for view in self.scrollTotales.subviews { if (view as? UILabel) != nil{ view.removeFromSuperview() } }
        let point = CGPoint(x: 0, y: 5)
        var frame = CGRect(origin: point, size: CGSize(width: self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0 - 40, height: 19.5))
        if dataRows.count == 0 {
            self.totalCard.isHidden = true
            self.setVariableHeight(Height: 360)
            return
        }
        for (index, _) in dataRows[0].enumerated(){
            let total = getTotal(index)
            if total == ""{ continue }
            let title = self.nameElement[index].title
            if title.contains("wizard") || title.contains("boton"){ continue }
            if index != 0{ frame.origin.y += 20 }
            let lbl = UILabel(frame: frame)
            lbl.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
            lbl.numberOfLines = 0
            lbl.text = "\(self.nameElement[index].title): \(total)"
            lbl.layer.addBorder(edge: .bottom, color: .black, thickness: 1.0)
            if index % 2 == 0{ lbl.backgroundColor = UIColor.lightGray
            }else{ lbl.backgroundColor = UIColor.white }
            self.scrollTotales.addSubview(lbl)
        }
        if frame.origin.y <= 20 || !(self.atributos?.vertotales ?? true){
            self.totalCard.isHidden = true
            self.setVariableHeight(Height: 360)
            return
        }else{
            self.totalCard.isHidden = false
            self.setVariableHeight(Height: 500)
        }
        self.scrollTotales.contentSize = CGSize(width: self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0 - 40, height: (frame.origin.y + 19.5))
    }
    // MARK: RELOAD DESIGN
    public func reloadDesign() {
        if atributos != nil, atributos?.vistamovil == "table"{
            self.spreadSheet.reloadData()
            self.totalCard.isHidden = true
            self.setVariableHeight(Height: 360)
        }else if atributos?.vistamovil == "cards"{
            self.collectionCard.isHidden = false
            self.collectionCard.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { self.reloadTotales() }
        }
    }
    
    // MARK: VISIBLE OBJECTS
    public func setVisibleObjects(hijos: Form){
        self.heightCard = 0
        self.nameElement = [(id: String, title: String)]()
        for elem in hijos.allRows{
            self.elementType(e: elem)
            switch elem {
            case is TextoRow, is TextoAreaRow, is NumeroRow, is MonedaRow, is FechaRow, is LogicoRow, is RangoFechasRow, is SliderNewRow, is ListaRow, is ListaTemporalRow, is TablaRow,is BotonRow, is ButtonRow, is ComboDinamicoRow: break;
            default: elem.hidden = true; elem.evaluateHidden(); break;
            }
        }
        viewController!.form = hijos
    }
    
    // MARK: DESIGN
    public func setDesign(){
        self.contentView.backgroundColor = UIColor.white
        self.collectionCard.backgroundColor = UIColor.white
        // We are setting the design as Table or as Collectin View Card
        if atributos != nil, atributos?.vistamovil == "table"{
            self.collectionCard.isHidden = true
            self.totalCard.isHidden = true
            self.spreadSheet.isHidden = false
            
            // Setting table view
            self.spreadSheet.dataSource = self
            self.spreadSheet.delegate = self
            self.spreadSheet.backgroundColor = .clear
            self.spreadSheet.gridStyle = .solid(width: 1, color: .darkGray)
            self.spreadSheet.register(FilaCell.self, forCellWithReuseIdentifier: String(describing: FilaCell.self))
            self.spreadSheet.register(EditCell.self, forCellWithReuseIdentifier: String(describing: EditCell.self))
            self.spreadSheet.register(DataCell.self, forCellWithReuseIdentifier: String(describing: DataCell.self))
            self.spreadSheet.register(TitleCell.self, forCellWithReuseIdentifier: String(describing: TitleCell.self))
            self.spreadSheet.register(RowCell.self, forCellWithReuseIdentifier: String(describing: RowCell.self))
            self.spreadSheet.register(TrashCell.self, forCellWithReuseIdentifier: String(describing: TrashCell.self))
            self.spreadSheet.register(PreviewCell.self, forCellWithReuseIdentifier: String(describing: PreviewCell.self))
            self.spreadSheet.register(WzrdCell.self, forCellWithReuseIdentifier: String(describing: WzrdCell.self))
        }else if atributos?.vistamovil == "cards"{
            
            self.collectionCard.isHidden = false
            self.collectionCard.backgroundColor = UIColor.white
            self.spreadSheet.isHidden = true
            // Setting card view
            self.collectionCard.delegate = self
            self.collectionCard.dataSource = self
            
            collectionCard.register(TableCollectionViewCell.self, forCellWithReuseIdentifier: TableCollectionViewCell.identifier)
            
            self.collectionCard.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let layout = self.collectionCard.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0 - 40, height: collectionCard.frame.height)
            layout.minimumLineSpacing = 0.0
            layout.minimumInteritemSpacing = 0.0
            
            self.collectionCard.setCollectionViewLayout(layout, animated: true)
            collectionCard.backgroundColor = UIColor.clear
        }
    }
    // MARK: PERMISSIONS
    public func setPermissions(){
        
        if ConfigurationManager.shared.isInEditionMode{
            setHabilitado(false)
        }else{
            setHabilitado(true)
        }
        
        btnMultiEdicion.isHidden = !(atributos?.permisotablamultiedicion ?? false)
        agregarBtn.isHidden = !(atributos?.permisotablamostrar ?? false)
        
        // Setting permiso importar
        // TODO: - permisotablaimportarr
        
        // Setting permiso seleccionar
        // TODO: - permisotablaseleccionarr
        
    }
    
    public func setButtonText(){
        agregarBtn.setTitle(atributos?.botonnuevotexto ?? "", for: .normal)
        // TODO: - botonimportartexto
    }
    
    public func setColorButton(){
        agregarBtn.setTitleColor(UIColor(hexFromString: atributos?.colorbotonnuevotexto ?? "#fff"), for: .normal)
        agregarBtn.backgroundColor = UIColor(hexFromString: atributos?.colorbotonnuevo ?? "#000")
    }
    // MARK: Excecution for RulesOnProperties
    public func setRulesOnProperties(){
        if rulesOnProperties.count == 0{ return }
        if self.atributos?.visible ?? false{ triggerRulesOnProperties("visible") }else{ triggerRulesOnProperties("notvisible") }
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
        var auxRule: [AEXMLElement] = []
        rulesOnChange.forEach
        {   let auxItem = $0
            if !auxRule.contains(where: {auxItem === $0})
            {   auxRule.append($0)}
        }
        if row != nil{
            for rule in auxRule{
                if rule["conditions"].children.count == 0{ continue }
                for condition in rule["conditions"].children{
                    if condition["category"].value == "bytable" &&  condition["tableidelem"].value == row.tag
                    {   if action == condition["rowtype"].value
                        {
                            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: condition["rowtype"].value, forced: false, override: false)
                        }
                    } else {
                    for subject in condition["subject"].children{
                        if subject["subject"].value == row.tag{
                            if action == nil
                            {
                                _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: subject["verb"].value, forced: false, override: false)
                            } else if action == subject["verb"].value
                            {
                                _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: subject["verb"].value, forced: false, override: false)
                            }
                        }
                    }
                    }
                }
            }
        }

    }
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){ }
}


extension TablaCell{
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{
        return self.lblMessage.text ?? ""
    }
    public func getRowEnabled()->Bool{
        return self.row.baseCell.isUserInteractionEnabled
    }
    public func getRequired()->Bool{
        return self.lblRequired.isHidden
    }
    public func getTitleLabel()->String{
        return self.lblTitle.text ?? ""
    }
    public func getSubtitleLabel()->String{
        return self.lblSubtitle.text ?? ""
    }
    public func executeTableShowAdd(){
        self.AgregarBtnAction(Any.self)
    }
}


extension CALayer {

    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }

        border.backgroundColor = color.cgColor;

        self.addSublayer(border)
    }

}

