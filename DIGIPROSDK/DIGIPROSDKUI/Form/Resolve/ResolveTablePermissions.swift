import Foundation
import UIKit

// MARK: - RESOLVE VISIBLE
extension NuevaPlantillaViewController{
    
    public func resolveTablePermissions(_ id: String, _ mode: String, _ string: String) -> Bool{
        if id == ""{ return false }
        let element = getElementANY(id)
        
        let tipoElemento = element.type //TipoElemento(rawValue: "\(element.type)") ?? TipoElemento.other
        
        switch tipoElemento{
        case "eventos", "plantilla", "pagina", "seccion": break;
        case "boton", "codigobarras", "comboboxtemporal", "deslizante", "espacio": break;
        case "fecha", "hora", "leyenda", "lista", "logico", "logo", "marcadodocumentos": break;
        case "moneda", "numero", "password", "rangofechas", "semaforotiempo": break;
        case "tabber": break;
        case "tabla":
            
            let row: TablaRow = element.kind as! TablaRow
            if (mode == "asignacion"){
                
                switch string{
                case "permisotablaeditarr":
                    row.cell.atributos?.permisotablaeditarr = true
                    break;
                case "notpermisotablaeditarr":
                    row.cell.atributos?.permisotablaeditarr = false
                    break;
                    
                case "permisotablaeliminarr":
                    row.cell.atributos?.permisotablaeliminarr = true
                    break;
                case "notpermisotablaeliminarr":
                    row.cell.atributos?.permisotablaeliminarr = false
                    break;
                    
                case "permisotablaagregarr":
                    row.cell.atributos?.permisotablaagregarr = true
                    break;
                case "notpermisotablaagregarr":
                    row.cell.atributos?.permisotablaagregarr = false
                    break;
                    
                case "permisotablaseleccionarr":
                    row.cell.atributos?.permisotablaseleccionarr = true
                    break;
                case "notpermisotablaseleccionarr":
                    row.cell.atributos?.permisotablaseleccionarr = false
                    break;
                    
                case "permisotablaagregarcerrarr":
                    row.cell.atributos?.permisotablaagregarcerrarr = true
                    break;
                case "notpermisotablaagregarcerrarr":
                    row.cell.atributos?.permisotablaagregarcerrarr = false
                    break;
                 
                case "permisotablalimpiar":
                    row.cell.atributos?.permisotablalimpiar = true
                    break;
                case "notpermisotablalimpiar":
                    row.cell.atributos?.permisotablalimpiar = false
                    break;
                    
                case "permisotablamostrar":
                    row.cell.atributos?.permisotablamostrar = true
                    break;
                case "notpermisotablamostrar":
                    row.cell.atributos?.permisotablamostrar = false
                    break;
                    
                case "permisotablacerrar":
                    row.cell.atributos?.permisotablacerrar = true
                    break;
                case "notpermisotablacerrar":
                    row.cell.atributos?.permisotablacerrar = false
                    break;
                  
                default:
                    break;
                }
                row.cell.setPermissions()
                row.updateCell()
            }else if (mode == "afirmacion") { }
            
            break;
        case "texto", "textarea", "wizard": break;
        case "metodo", "servicio": break;
        case "audio", "voz": break;
        case "calculadora": break;
        case "firma": break;
        case "firmafad": break;
        case "georeferencia", "mapa": break;
        case "imagen": break;
        case "documento": break;
        case "video", "videollamada": break;
        case "huelladigital": break;
        case "rostrovivo", "capturafacial": break;
        default:
            break;
        }
        
        return false
        
    }
    func resolveTablePermissions(_ type: String, _ mode: String, _ rr: ReturnFormulaType, _ elem: Formula, _ formul: [Formula], _ equals: Int) -> String {
        
        let element = getElementANY(elem.id)
        var valueStringInt = ""
        switch rr{
        case .typeString(let string): valueStringInt = string; break
        case .typeInt(let int): valueStringInt = String(int); break
        case .typeArray( _), .typeDictionary( _): break
        default: break
        }
        
        let tipoElemento = elem.tipo //TipoElemento(rawValue: "\(elem.tipo)") ?? TipoElemento.other
        
        switch tipoElemento{
        case "eventos", "plantilla", "pagina", "seccion", "boton", "codigobarras", "comboboxtemporal": break;
        case "deslizante", "espacio", "fecha", "hora", "leyenda", "lista", "logico", "logo", "moneda", "marcadodocumentos": break;
        case "numero", "password", "rangofechas", "semaforotiempo", "tabber": break;
        case "tabla":
            let row: TablaRow = element.kind as! TablaRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    
                    switch type{
                    case "agregarRegistro":
                        row.cell.atributos?.permisotablaagregarr = true
                        break;
                    case "agregarRegistroYCerrar":
                        row.cell.atributos?.permisotablaagregarcerrarr = true
                        break;
                    case "eliminarRegistro":
                        row.cell.atributos?.permisotablaeliminarr = true
                        break;
                    case "limpiarCampos":
                        row.cell.atributos?.permisotablalimpiar = true
                        break;
                    default:
                        break;
                    }
                    
                }else{
                    switch type{
                    case "agregarRegistro":
                        row.cell.atributos?.permisotablaagregarr = false
                        break;
                    case "agregarRegistroYCerrar":
                        row.cell.atributos?.permisotablaagregarcerrarr = false
                        break;
                    case "eliminarRegistro":
                        row.cell.atributos?.permisotablaeliminarr = false
                        break;
                    case "limpiarCampos":
                        row.cell.atributos?.permisotablalimpiar = false
                        break;
                    default:
                        break;
                    }
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.isHidden)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "texto", "textarea", "wizard": break;
        case "metodo", "servicio": break;
        case "audio", "voz", "calculadora", "firma", "firmafad", "georeferencia", "mapa", "imagen", "video", "videollamada", "documento": break;
        case "huelladigital": break;
        case "rostrovivo", "capturafacial": break;
        default:
            break;
        }
        
        return ""
    }
    
}
