import Foundation

import Eureka

public class MetodoCell: Cell<String>, CellType, APIDelegate {
    
    var sdkAPI : APIManager<MetodoCell>?
    public var atributos: Atributos_metodo?
    public var formDelegate: FormularioDelegate?
    public var elemento: Elemento?
    
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
        
    deinit{
        formDelegate = nil
        atributos = nil
        elemento = Elemento()
    }
    
    public func setObject(obj: Elemento){
        elemento = obj
        atributos = obj.atributos as? Atributos_metodo
        sdkAPI = APIManager<MetodoCell>()
        sdkAPI?.delegate = self
        row.hidden = true
    }
    
    public func setFecha(_ result: FechaResult){
        if result.fecha != ""{
            let rslt = self.gettinFormula(result.fecha)
            switch rslt{
            case .typeString(let str):
                let date = str.split{$0 == "-"}.map(String.init)
                let setRslt = FechaResultFormulas(json: atributos?.parametrossalida)
                if setRslt.anio != ""{
                    settingFormula(setRslt.anio, date[0])
                }
                if setRslt.mes != ""{
                    settingFormula(setRslt.mes, date[1])
                }
                if setRslt.dia != ""{
                    settingFormula(setRslt.dia, date[2])
                }
                break
            case .typeInt( _): break
            case .typeArray( _): break
            case .typeDictionary( _): break
            case .typeNil( _): break
            default: break;
            }
        }
    }
    
    func gettinFormula(_ str: String) -> ReturnFormulaType{
        var formula: [NSDictionary]?
        if let dataFromString = str.data(using: .utf8, allowLossyConversion: false) {
            do{
                formula = try JSONSerialization.jsonObject(with: dataFromString, options: []) as? [NSDictionary]
                if let theJSONData = try? JSONSerialization.data(withJSONObject: formula!, options: []) {
                    let theJSONText = String(data: theJSONData, encoding: .ascii)
                    return (self.formDelegate?.recursiveTokenFormula(theJSONText, nil, "asignacion", false))!
                }
            }catch{ formula = [NSDictionary]() }
        }else{ formula = [NSDictionary]() }
        return ReturnFormulaType.typeNil(nil)
    }
    
    func settingFormula(_ str: String, _ ocrStr: String){
        
        var formula: [NSDictionary]?
        if let dataFromString = str.data(using: .utf8, allowLossyConversion: false) {
            do{
                formula = try JSONSerialization.jsonObject(with: dataFromString, options: []) as? [NSDictionary]
                if formula?.count == 0{ return }
                if formula?.count == 1{
                    let f1:NSDictionary = [ "value": ".", "type": "point" ]
                    let f2:NSDictionary = [ "value": "mensaje", "type": "propiedadvariable" ]
                    formula?.append(f1)
                    formula?.append(f2)
                }
                let f1:NSDictionary = [ "value": "=", "type": "equal" ]
                let f2:NSDictionary = [ "value": "\(ocrStr)", "type": "character" ]
                formula?.append(f1)
                formula?.append(f2)
                if let theJSONData = try? JSONSerialization.data(withJSONObject: formula!, options: []) {
                    let theJSONText = String(data: theJSONData, encoding: .ascii)
                    _ = self.formDelegate?.recursiveTokenFormula(theJSONText, nil, "asignacion", false)
                }
            }catch{ formula = [NSDictionary]() }
        }else{ formula = [NSDictionary]() }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    open override func setup() {
        super.setup()
        self.backgroundColor = UIColor.clear
        height = {return 0}
    }
    
    override open func update() {
        super.update()
    }
    
}
