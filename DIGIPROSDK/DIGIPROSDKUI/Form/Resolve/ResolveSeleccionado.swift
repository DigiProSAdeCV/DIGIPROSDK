import Foundation
import UIKit

// MARK: - RESOLVE SELECCIONADO
extension NuevaPlantillaViewController{
    
    func resolveSeleccionado(_ id: String, _ mode: String, _ string: String) -> Bool {
        
        let element = getElementANY(id)
        
        let tipoElemento = element.type //TipoElemento(rawValue: "\(element.type)") ?? TipoElemento.other
        
        switch tipoElemento{
        case "eventos", "plantilla", "pagina", "seccion": break;
        case "boton", "codigobarras", "comboboxtemporal", "deslizante", "espacio": break;
        case "fecha", "hora", "leyenda", "lista", "marcadodocumentos": break;
        case "logico":
            let row: LogicoRow = element.kind as! LogicoRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setEdited(v: "true")
                }else{
                    row.cell.setEdited(v: "false")
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.value
                if string == "true"{
                    if vvv ?? false{ return true } else{ return false }
                }else{
                    if !(vvv ?? false){ return true } else{ return false }
                }
            }
            break;
        case "logo", "moneda", "numero", "password", "rangofechas": break;
        case "semaforotiempo": break;
        case "tabber": break;
        case "tabla", "texto", "textarea", "wizard": break;
        case "metodo", "servicio": break;
        case "audio", "voz", "calculadora", "firma", "firmafad", "georeferencia", "mapa", "imagen", "documento": break;
        case "video", "videollamada": break;
        case "huelladigital": break;
        case "rostrovivo", "capturafacial": break;
        default:
            break;
        }
        
        return false
    }
    
    func resolveSeleccionado(_ type: String, _ mode: String, _ rr: ReturnFormulaType, _ elem: Formula, _ formul: [Formula], _ equals: Int) -> String {
        
        let element = getElementANY(elem.id)
        var valueStringInt = ""
        switch rr{
        case .typeString(let string): valueStringInt = string; break
        case .typeInt(let int): valueStringInt = String(int); break
        case .typeArray( _), .typeDictionary( _): break
        default: break
        }
        
        let tipoElemento = elem.tipo //TipoElemento(rawValue: "\(elem.tipo)") ?? TipoElemento.other
        
        switch tipoElemento {
        case "eventos", "plantilla", "pagina", "seccion": break;
        case "boton", "codigobarras", "comboboxtemporal", "deslizante", "espacio": break;
        case "fecha", "hora", "leyenda", "lista", "marcadodocumentos": break;
        case "logico":
            let row: LogicoRow = element.kind as! LogicoRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setEdited(v: "true")
                }else{
                    row.cell.setEdited(v: "false")
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.value?.description
                var result: String?
                if vvv == nil{
                    result = FormularioUtilities.shared.operaciones(valueStringInt, "false", formul[equals].value)
                }else{
                    result = FormularioUtilities.shared.operaciones(valueStringInt, vvv!, formul[equals].value)
                }
                return result!
            }
            break;
        case "logo", "moneda", "numero", "password", "rangofechas": break;
        case "semaforotiempo": break;
        case "tabber": break;
        case "tabla", "texto", "textarea", "wizard": break;
        case "metodo", "servicio": break;
        case "audio", "voz", "calculadora", "firma", "firmafad", "georeferencia", "mapa", "imagen", "documento": break;
        case "video", "videollamada": break;
        case "huelladigital": break;
        case "rostrovivo", "capturafacial": break;
        default:
            break;
        }
        
        return ""
    }
    
}
