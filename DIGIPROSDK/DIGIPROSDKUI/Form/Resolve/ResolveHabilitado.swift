import Foundation
import UIKit

// MARK: - RESOLVE HABILITADO
extension NuevaPlantillaViewController{
    
    public func resolveHabilitado(_ id: String, _ mode: String, _ string: String) -> Bool {
        
        let element = getElementANY(id)
        
        let tipoElemento = element.type //TipoElemento(rawValue: "\(element.type)") ?? TipoElemento.other
        
        switch tipoElemento{
            // MARK: - BEGIN DIGIPROSDKSO
        case "eventos", "plantilla": break;
        case "pagina":
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"
                {
                    for pagina in FormularioUtilities.shared.paginasVisibles{
                        if pagina.idelemento == id { pagina.habilitado = true; }
                    }
                }else{
                    for pagina in FormularioUtilities.shared.paginasVisibles{
                        if pagina.idelemento == id { pagina.habilitado = false; }
                    }
                }
                self.reloadPages()
            }else if (mode == "afirmacion") {
                for pagina in FormularioUtilities.shared.paginasVisibles{
                    if id == pagina.idelemento{
                        let vvv = pagina.habilitado
                        if string == "true"{ if vvv{ return true } else{ return false }
                        }else{ if !vvv{ return true } else{ return false } }
                    }
                }
            }
            break;
        case "seccion":
            let row: HeaderRow = element.kind as! HeaderRow
            let tabber = self.form.rowBy(tag: row.cell.atributos?.elementopadre ?? "") as? HeaderTabRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"
                {
                    row.cell.elemento.validacion.habilitado = true
                    row.cell.atributos?.habilitado = true
                    row.cell.setHabilitado(true)
                    self.setEnableElementsFromSection(row.tag ?? "", row.cell.atributos ?? Atributos_seccion())
                    if tabber != nil{ tabber?.cell.rldSegments() }
                }else{
                    row.cell.elemento.validacion.habilitado = false
                    row.cell.atributos?.habilitado = false
                    row.cell.setHabilitado(false)
                    self.setEnableElementsFromSection(row.tag ?? "", row.cell.atributos ?? Atributos_seccion())
                    if tabber != nil{ tabber?.cell.rldSegments() }
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "boton":
            let row: BotonRow = element.kind as! BotonRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "comboboxtemporal":
            let row: ListaTemporalRow = element.kind as! ListaTemporalRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "deslizante":
            let row: SliderNewRow = element.kind as! SliderNewRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "espacio": break;
        case "fecha", "hora":
            let row: FechaRow = element.kind as! FechaRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "leyenda":
            let row: EtiquetaRow = element.kind as! EtiquetaRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "lista":
            let row: ListaRow = element.kind as! ListaRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "logico":
            let row: LogicoRow = element.kind as! LogicoRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "logo":
            let row: LogoRow = element.kind as! LogoRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "moneda":
            let row: MonedaRow = element.kind as! MonedaRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "numero":
            let row: NumeroRow = element.kind as! NumeroRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "password":
            let row: TextoRow = element.kind as! TextoRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "rangofechas":
            let row: RangoFechasRow = element.kind as! RangoFechasRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "semaforotiempo": break;
        case "tabber": break;
        case "tabla":
            let row: TablaRow = element.kind as! TablaRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "texto":
            let row: TextoRow = element.kind as! TextoRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "textarea":
            let row: TextoAreaRow = element.kind as! TextoAreaRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "wizard":
            let row: WizardRow = element.kind as! WizardRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "combodinamico":
          if plist.idportal.rawValue.dataI() >= 40 {
            let row: ComboDinamicoRow = element.kind as! ComboDinamicoRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
          }
            break;
        case "marcadodocumentos":
          if plist.idportal.rawValue.dataI() >= 41 {
            let row: MarcadoDocumentoRow = element.kind as! MarcadoDocumentoRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
          }
            break
        case "metodo", "servicio": break;
        case "codigobarras":
            let row: CodigoBarrasRow = element.kind as! CodigoBarrasRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "codigoqr":
          if plist.idportal.rawValue.dataI() >= 39 {
            let row: CodigoQRRow = element.kind as! CodigoQRRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
          }
            break;
        case "nfc":
          if plist.idportal.rawValue.dataI() >= 39 {
            let row: EscanerNFCRow = element.kind as! EscanerNFCRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
          }
            break
        case "audio", "voz":
            let row: AudioRow = element.kind as! AudioRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "calculadora":
            if plist.idportal.rawValue.dataI() >= 39{
                let row: CalculadoraRow = element.kind as! CalculadoraRow
                if (mode == "asignacion"){
                    if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                        row.cell.setHabilitado(true)
                    }else{
                        row.cell.setHabilitado(false)
                    }
                    row.updateCell()
                }else if (mode == "afirmacion") {
                    let vvv = row.cell.elemento.validacion.habilitado
                    if string == "true"{ if vvv{ return true } else{ return false }
                    }else{ if !vvv{ return true } else{ return false } }
                }
                break;
            }
        case "firma":
            let row: FirmaRow = element.kind as! FirmaRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "firmafad":
            if plist.idportal.rawValue.dataI() >= 39{
                let row: FirmaFadRow = element.kind as! FirmaFadRow
                if (mode == "asignacion"){
                    if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                        row.cell.setHabilitado(true)
                    }else{
                        row.cell.setHabilitado(false)
                    }
                    row.updateCell()
                }else if (mode == "afirmacion") {
                    let vvv = row.cell.elemento.validacion.habilitado
                    if string == "true"{ if vvv{ return true } else{ return false }
                    }else{ if !vvv{ return true } else{ return false } }
                }
                break;
            }

        case "georeferencia", "mapa":
            let row: MapaRow = element.kind as! MapaRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "imagen":
            let row: ImagenRow = element.kind as! ImagenRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "video", "videollamada":
            let row: VideoRow = element.kind as! VideoRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        case "documento":
            let row: DocumentoRow = element.kind as! DocumentoRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break
            case "ocr":
                let row: VeridasDocumentOcrRow = element.kind as! VeridasDocumentOcrRow
                if (mode == "asignacion"){
                    if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                        row.cell.setHabilitado(true)
                    }else{
                        row.cell.setHabilitado(false)
                    }
                    row.updateCell()
                }else if (mode == "afirmacion") {
                    let vvv = row.cell.elemento.validacion.habilitado
                    if string == "true"{ if vvv{ return true } else{ return false }
                    }else{ if !vvv{ return true } else{ return false } }
                }
                break
        case "jumio":
            let row: JUMIODocumentOcrRow = element.kind as! JUMIODocumentOcrRow
            if (mode == "asignacion") {
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                } else {
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            } else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                } else{ if !vvv { return true } else { return false } }
            }
            break
        case "huelladigital":
            let row: VeridiumRow = element.kind as! VeridiumRow
            if (mode == "asignacion"){
                if string == "true" || string.lowercased() == "si" || string.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.habilitado
                if string == "true"{ if vvv{ return true } else{ return false }
                }else{ if !vvv{ return true } else{ return false } }
            }
            break;
        default:
            break;
        }
        return false
    }
    
    func resolveHabilitado(_ type: String, _ mode: String, _ rr: ReturnFormulaType, _ elem: Formula, _ formul: [Formula], _ equals: Int) -> String {
        
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
        case "eventos", "plantilla", "pagina": break;
        case "seccion":
            let row: HeaderRow = element.kind as! HeaderRow
            let tabber = self.form.rowBy(tag: row.cell.atributos?.elementopadre ?? "") as? HeaderTabRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"
                {
                    row.cell.elemento.validacion.habilitado = true
                    row.cell.atributos?.habilitado = true
                    row.cell.setHabilitado(true)
                    self.setEnableElementsFromSection(row.tag ?? "", row.cell.atributos ?? Atributos_seccion())
                    if tabber != nil{ tabber?.cell.rldSegments() }
                }else{
                    row.cell.elemento.validacion.habilitado = false
                    row.cell.atributos?.habilitado = false
                    row.cell.setHabilitado(false)
                    self.setEnableElementsFromSection(row.tag ?? "", row.cell.atributos ?? Atributos_seccion())
                    if tabber != nil{ tabber?.cell.rldSegments() }
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "boton":
            let row: BotonRow = element.kind as! BotonRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "comboboxtemporal":
            let row: ListaTemporalRow = element.kind as! ListaTemporalRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "deslizante":
            let row: SliderNewRow = element.kind as! SliderNewRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "espacio": break;
        case "fecha", "hora":
            let row: FechaRow = element.kind as! FechaRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "leyenda":
            let row: EtiquetaRow = element.kind as! EtiquetaRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "lista":
            let row: ListaRow = element.kind as! ListaRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "logico":
            let row: LogicoRow = element.kind as! LogicoRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "logo":
            let row: LogoRow = element.kind as! LogoRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "moneda":
            let row: MonedaRow = element.kind as! MonedaRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "numero":
            let row: NumeroRow = element.kind as! NumeroRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "password":
            let row: TextoRow = element.kind as! TextoRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "rangofechas":
            let row: RangoFechasRow = element.kind as! RangoFechasRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "semaforotiempo": break;
        case "tabber": break;
        case "tabla":
            let row: TablaRow = element.kind as! TablaRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "texto":
            let row: TextoRow = element.kind as! TextoRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "textarea":
            let row: TextoAreaRow = element.kind as! TextoAreaRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "wizard":
            let row: WizardRow = element.kind as! WizardRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "combodinamico":
          if plist.idportal.rawValue.dataI() >= 40 {
            let row: ComboDinamicoRow = element.kind as! ComboDinamicoRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
          }
            break;
        case "marcadodocumentos":
          if plist.idportal.rawValue.dataI() >= 41 {
            let row: MarcadoDocumentoRow = element.kind as! MarcadoDocumentoRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
          }
            break
        case "codigobarras":
            let row: CodigoBarrasRow = element.kind as! CodigoBarrasRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "codigoqr":
          if plist.idportal.rawValue.dataI() >= 39 {
            let row: CodigoQRRow = element.kind as! CodigoQRRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
          }
            break;
        case "nfc":
          if plist.idportal.rawValue.dataI() >= 39 {
            let row: EscanerNFCRow = element.kind as! EscanerNFCRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
          }
            break;
        case "metodo", "servicio": break;
        case "audio", "voz":
            let row: AudioRow = element.kind as! AudioRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "calculadora":
            if plist.idportal.rawValue.dataI() >= 39{
                let row: CalculadoraRow = element.kind as! CalculadoraRow
                if (mode == "asignacion"){
                    if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                        row.cell.setHabilitado(true)
                    }else{
                        row.cell.setHabilitado(false)
                    }
                    row.updateCell()
                }else if (mode == "afirmacion") {
                    let vvv = String(row.cell.elemento.validacion.habilitado)
                    let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                    return result
                }
                break;
            }
        case "firma":
            let row: FirmaRow = element.kind as! FirmaRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "firmafad":
            if plist.idportal.rawValue.dataI() >= 39{
                let row: FirmaFadRow = element.kind as! FirmaFadRow
                if (mode == "asignacion"){
                    if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                        row.cell.setHabilitado(true)
                    }else{
                        row.cell.setHabilitado(false)
                    }
                    row.updateCell()
                }else if (mode == "afirmacion") {
                    let vvv = String(row.cell.elemento.validacion.habilitado)
                    let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                    return result
                }
                break;
            }
        case "georeferencia":
            let row: MapaRow = element.kind as! MapaRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "mapa":
            let row: MapaRow = element.kind as! MapaRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break
        case "imagen":
            let row: ImagenRow = element.kind as! ImagenRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "documento":
            let row: DocumentoRow = element.kind as! DocumentoRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break
        case "video", "videollamada":
            let row: VideoRow = element.kind as! VideoRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "huelladigital":
            let row: VeridiumRow = element.kind as! VeridiumRow
            if (mode == "asignacion"){
                if valueStringInt == "true" || valueStringInt.lowercased() == "si" || valueStringInt.lowercased() == "1"{
                    row.cell.setHabilitado(true)
                }else{
                    row.cell.setHabilitado(false)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.cell.elemento.validacion.habilitado)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        default:
            break;
        }
        
        return ""
    }
    
}

