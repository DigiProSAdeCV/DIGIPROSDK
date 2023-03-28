import Foundation
import Eureka

extension NuevaPlantillaViewController{
    
    func setValueElemento(){

        for dictValue in self.dictValues{
            
            for form in self.forms{
                
                for row in form.allRows{
                    
                    if row.tag ?? "" == dictValue.key{
                        
                        switch row{
                        case is TextoRow:
                            if dictValue.value.valor == "" { break; }
                            let base = row as? TextoRow
                            if base?.cell.atributos != nil{ base?.cell.setEdited(v: dictValue.value.valor) }
                            if base?.cell.atributosPassword != nil{ base?.cell.setEdited(v: dictValue.value.valor) }
                            break;
                        case is TextoAreaRow:
                            if dictValue.value.valor == "" { break; }
                            let base = row as? TextoAreaRow
                            base?.cell.setEdited(v: dictValue.value.valor)
                            break;
                        case is NumeroRow:
                            if dictValue.value.valor == "" { break; }
                            let base = row as? NumeroRow
                            base?.cell.setEdited(v: dictValue.value.valor)
                            break;
                        case is MonedaRow:
                            if dictValue.value.valor == "" { break; }
                            let base = row as? MonedaRow
                            base?.cell.setEdited(v: dictValue.value.valor)
                            break;
                        case is FechaRow:
                            if dictValue.value.valor == "" { break; }
                            let base = row as? FechaRow
                            if base?.cell.atributos != nil{ base?.cell.setEditedFecha(v: dictValue.value.valor, format: base?.cell.atributos?.formato ?? "dd/MM/yyyy")}
                            if base?.cell.atributosHora != nil{ base?.cell.setEditedHora(v: dictValue.value.valor) }
                            break;
                        case is WizardRow: break;
                        case is BotonRow: break;
                        case is LogoRow: break;
                        case is LogicoRow:
                            if dictValue.value.valor == "" { break; }
                            let base = row as? LogicoRow
                            base?.cell.setEdited(v: dictValue.value.valor)
                            break;
                        case is EtiquetaRow: break;
                        case is RangoFechasRow:
                            if dictValue.value.valor == "" { break; }
                            let base = row as? RangoFechasRow
                            base?.cell.setEdited(v: dictValue.value.valor)
                            break;
                        case is SliderNewRow:
                            if dictValue.value.valor == "" { break; }
                            let base = row as? SliderNewRow
                            base?.cell.setEdited(v: dictValue.value.valor)
                            break;
                        case is ListaRow:
                            if dictValue.value.valor == "" || dictValue.value.valor == "0" || dictValue.value.valor.isEmpty{ break; }
                            let base = row as? ListaRow
                            var values: String
                            self.valuesArray = Array<String>()
                            values = dictValue.value.valor
                            valuesArray = values.split{$0 == ","}.map(String.init)
                            if self.valuesArray?.count == 0 { break; }
                            
                            if base?.cell.atributos?.tipolista != "combo" {
                                 base?.cell.setEdited(v: dictValue.value.valor, isRobot: true);
                                break;
                            } else {
                                var selectedValues = ""
                                var showedValues = ""
                                for item in (base?.cell.listItemsLista ?? []) {
                                    let val = String(item.split(separator: "|").first ?? "")
                                    let id = String(item.split(separator: "|").last ?? "")
                                    for valArray in self.valuesArray!{
                                        if val.lowercased() == valArray.lowercased() ||
                                                id.lowercased() == valArray.lowercased() ||
                                                val.lowercased() == values.lowercased(){
                                            selectedValues += "\(id)"
                                            showedValues += "\(val)"
                                        }
                                    }
                                }
                                if selectedValues != ""{
                                    base?.cell.seleccionarValor(desc: showedValues, id: selectedValues, isRobot: true)
                                }
                            }
                            break;
                        case is ListaTemporalRow: break;
                        case is HeaderTabRow: break;
                        case is HeaderRow: break;
                        case is TablaRow:
                            if dictValue.value.valor == "" { break; }
                            let base = row as? TablaRow
                            base?.cell.setEdited(v: dictValue.value.valor)
                            base?.cell.setValuesFromJson()
                            base?.cell.elemento.validacion.valor = base?.cell.row.value ?? ""
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                            break;
                        case is ComboDinamicoRow:
                         if plist.idportal.rawValue.dataI() >= 40 {
                            if dictValue.value.valor == "" { break; }
                            let base = row as? ComboDinamicoRow
                            base?.cell.valueOpen = true
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                            base?.cell.elemento.validacion.valor = dictValue.value.valor
                            base?.cell.elemento.validacion.valormetadatoinicial = dictValue.value.valor
                         }
                            break;
                        case is MarcadoDocumentoRow:
                         if plist.idportal.rawValue.dataI() >= 41 {
                            if dictValue.value.valor == "" { break; }
                            let base = row as? MarcadoDocumentoRow
                            var values: String = dictValue.value.valor
                            if values.contains(";")
                            {   values = values.replacingOccurrences(of: ";", with: ",")    }
                            if !values.contains(",") {  values += ","}
                            base?.cell.setEdited(v: values, isRobot: true);
                            base?.value = values
                            break;
                         }
                            break;
                        case is CodigoBarrasRow:
                            if dictValue.value.valor == "" { break; }
                            let base = row as? CodigoBarrasRow
                            base?.cell.setEdited(v: dictValue.value.valor)
                            break;
                        case is CodigoQRRow:
                         if plist.idportal.rawValue.dataI() >= 39 {
                            if dictValue.value.valor == "" { break; }
                            let base = row as? CodigoQRRow
                            base?.cell.setEdited(v: dictValue.value.valor)
                         }
                            break;
                        case is EscanerNFCRow:
                         if plist.idportal.rawValue.dataI() >= 39 {
                            if dictValue.value.valor == "" { break; }
                            let base = row as? EscanerNFCRow
                            base?.cell.setEdited(v: dictValue.value.valor)
                         }
                            break;
                        case is CalculadoraRow: break;
                        case is AudioRow:
                            let base = row as? AudioRow
                            base?.cell.elemento.validacion.valor = dictValue.value.valor
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                            break;
                        case is FirmaRow:
                            let base = row as? FirmaRow
                            base?.cell.elemento.validacion.valor = dictValue.value.valor
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                            break;
                        case is FirmaFadRow:
                            if plist.idportal.rawValue.dataI() >= 39{
                                let base = row as? FirmaFadRow
                                base?.cell.elemento.validacion.valor = dictValue.value.valor
                                base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                                base?.cell.elemento.validacion.personafirma = dictValue.value.nameFirm
                                base?.cell.elemento.validacion.fecha = dictValue.value.dateFirm
                                base?.cell.elemento.validacion.georeferencia = dictValue.value.georefFirm
                                base?.cell.elemento.validacion.dispositivo = dictValue.value.deviceFirm
                                break;
                            }
                        case is MapaRow:
                            let base = row as? MapaRow
                            base?.cell.elemento.validacion.valor = dictValue.value.valor
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                            if base?.cell.atributos != nil {
                                base?.cell.setEdited(v: dictValue.value.valor)
                            }
                            break;
                        case is DocumentoRow:
                            let base = row as? DocumentoRow
                            base?.cell.elemento.validacion.valor = dictValue.value.tipodoc
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.metadatostipodoc
                            break;
                        case is ImagenRow:
                            let base = row as? ImagenRow
                            base?.cell.elemento.validacion.valor = dictValue.value.valor
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                            break;
                        case is DocFormRow:
                            let base = row as? DocFormRow
                            base?.cell.elemento.validacion.valor = dictValue.value.tipodoc
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.metadatostipodoc
                            break;
                        case is VideoRow:
                            let base = row as? VideoRow
                            base?.cell.elemento.validacion.valor = dictValue.value.valor
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                            break;
                        case is VeridasDocumentOcrRow:
                            let base = row as? VeridasDocumentOcrRow
                            base?.cell.elemento.validacion.valor = dictValue.value.valor
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                            break;
                        case is JUMIODocumentOcrRow:
                            let base = row as? JUMIODocumentOcrRow
                            base?.cell.elemento.validacion.valor = dictValue.value.valor
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                            break;
                        case is VeridiumRow:
                            let base = row as? VeridiumRow
                            base?.cell.elemento.validacion.valor = dictValue.value.valor
                            base?.cell.elemento.validacion.valormetadato = dictValue.value.valormetadato
                            break;
                        default: break;
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for anexo in (FormularioUtilities.shared.currentFormato.Anexos){
            
            for form in self.forms{
                
                for row in form.allRows{
                    
                    if row.tag ?? "" == anexo.ElementoId{
                        
                        switch row{
                        case is CalculadoraRow: break;
                        case is AudioRow:
                            let base = row as? AudioRow
                            if row.tag ?? "" == anexo.ElementoId{
                                base?.cell.setAnexoOption(anexo)
                            }
                            break;
                        case is FirmaRow:
                            let base = row as? FirmaRow
                            if anexo.DocID != 0 && !anexo.Reemplazado && row.tag ?? "" == anexo.ElementoId{
                                base?.cell.setAnexoOption(anexo)
                            }else{
                                if anexo.DocID == 0 && row.tag ?? "" == anexo.ElementoId { base?.cell.didSetLocalAnexo(anexo) }
                            }
                            break;
                        case is FirmaFadRow:
                            let base = row as? FirmaFadRow
                            var arrayAnexos: [FEAnexoData] = [FEAnexoData]()
                            
                            for anexo in (FormularioUtilities.shared.currentFormato.Anexos){
                                print("ANEXOS FIRMA FAD: \(anexo)")
                                if anexo.DocID != 0 && !anexo.Reemplazado && row.tag ?? "" == anexo.ElementoId{
                                    arrayAnexos.append(anexo)
                                    base?.cell.setAnexoOption(arrayAnexos)
                                }else{
                                     if anexo.DocID == 0 && row.tag ?? "" == anexo.ElementoId {
                                        arrayAnexos.append(anexo)
                                        base?.cell.didSetLocalAnexo(arrayAnexos) }
                                }
                            }
                                if anexo.DocID != 0 && !anexo.Reemplazado && row.tag ?? "" == anexo.ElementoId{
                                    base?.cell.setAnexoOption(anexo)
                                }else{
                                     if anexo.DocID == 0 && row.tag ?? "" == anexo.ElementoId {
                                        base?.cell.didSetLocalAnexo(anexo) }
                                }
                                break;
                            
                        case is MapaRow:
                            let base = row as? MapaRow
                            if anexo.DocID != 0 && !anexo.Reemplazado && row.tag ?? "" == anexo.ElementoId{
                                base?.cell.setAnexoOption(anexo)
                            }else{
                                if anexo.DocID == 0 && row.tag ?? "" == anexo.ElementoId { base?.cell.didSetLocalAnexo(anexo) }
                            }
                            break;
                        case is DocumentoRow:
                            let base = row as? DocumentoRow
                            var arrayAnexos: [FEAnexoData] = [FEAnexoData]()
                            var bnd = -1
                            for anexo in (FormularioUtilities.shared.currentFormato.Anexos){
                                if anexo.ElementoId != row.tag ?? ""{ continue }
                                if row.tag ?? "" == anexo.ElementoId {
                                    if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)") {
                                        if !anexo.Borrado && !arrayAnexos.contains(anexo) {
                                            if anexo.DocID != 0 {   anexo.Descargado = true }
                                            arrayAnexos.append(anexo)
                                            bnd = 0
                                        }
                                    }else if !anexo.Reemplazado && !anexo.Borrado && !arrayAnexos.contains(anexo) {
                                        arrayAnexos.append(anexo)
                                        bnd = 1
                                    }else if !arrayAnexos.contains(anexo){
                                        arrayAnexos.append(anexo)
                                        bnd = 1
                                    }
                                }
                            }
                            if bnd == 0 {   base?.cell.didSetLocalAnexoDoc(arrayAnexos) }
                            else if bnd == 1 {   base?.cell.setAnexoOptionDoc(arrayAnexos)  }
                            break;
                        case is ImagenRow:
                            let base = row as? ImagenRow
                            if anexo.DocID != 0 && !anexo.Reemplazado && row.tag ?? "" == anexo.ElementoId{
                                let localPath = "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"
                                if FCFileManager.existsItem(atPath: localPath){
                                    base?.cell.didSetLocalAnexo(anexo)
                                }else {
                                    base?.cell.setAnexoOption(anexo)
                                }
                            }else{
                                if anexo.DocID == 0 && row.tag ?? "" == anexo.ElementoId { base?.cell.didSetLocalAnexo(anexo) }
                            }
                            break;
                        case is DocFormRow:
                            let base = row as? DocFormRow
                            if row.tag ?? "" == anexo.ElementoId {
                                if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
                                    base?.cell.ui.replaceDocumentStackView.isHidden = false
                                    base?.cell.ui.lblTypeDoc.isHidden = true
                                    base?.cell.didSetLocalAnexo(anexo)
                                } else {
                                    base?.cell.ui.replaceDocumentStackView.isHidden = false
                                    base?.cell.ui.lblTypeDoc.isHidden = true
                                    base?.cell.setAnexoOption(anexo)
                                }
                            } else {
                                if anexo.DocID == 0 && row.tag ?? "" == anexo.ElementoId {
                                    base?.cell.ui.replaceDocumentStackView.isHidden = false
                                    base?.cell.ui.lblTypeDoc.isHidden = true
                                    base?.cell.didSetLocalAnexo(anexo)
                                }
                            }
                            break;
                        case is VideoRow:
                            let base = row as? VideoRow
                            if anexo.DocID != 0 && !anexo.Reemplazado && row.tag ?? "" == anexo.ElementoId{
                                base?.cell.setAnexoOption(anexo)
                            }else{
                                if anexo.DocID == 0 && row.tag ?? "" == anexo.ElementoId {
                                    base?.cell.didSetLocalAnexo(anexo) }
                            }
                            break;
                        case is VeridiumRow:
                            let base = row as? VeridiumRow
                            if anexo.DocID != 0 && !anexo.Reemplazado && row.tag ?? "" == anexo.ElementoId{
                                base?.cell.setAnexoOption(anexo)
                            }else{
                                if anexo.DocID == 0 && row.tag ?? "" == anexo.ElementoId { base?.cell.didSetLocalAnexo(anexo) }
                            }
                            break;
                        default: break;
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }

}

