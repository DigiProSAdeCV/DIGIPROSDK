import Foundation
import UIKit

import Eureka

// MARK: - RESOLVE VALOR
extension NuevaPlantillaViewController{
    
    public func resolveCategory(_ ruleValue: String, _ subjectValue: String, _ category: String)->Bool{
        
        let rlValue = ruleValue.lowercased()
        let sbValue = subjectValue.lowercased()
        switch category{
        case "empty":
            let res = FormularioUtilities.shared.operaciones("", sbValue, "=")
            if res == "true"{ return true }else{ return false }
        case "notempty":
            let res = FormularioUtilities.shared.operaciones("", sbValue, "=")
            if res == "false"{ return true }else{ return false }
        case "contains":
            if sbValue.contains(rlValue){
                return true
            }else{
                if sbValue == rlValue{ return true }
                return false
            }
        case "notcontains":
            if sbValue.contains(rlValue){
                return false
            }else{
                if sbValue == rlValue{ return false }
                return true
            }
        case "equals":
            let res = FormularioUtilities.shared.operaciones(rlValue, sbValue, "=")
            if res == "true"{ return true }else{ return false }
        case "notequals":
            let res = FormularioUtilities.shared.operaciones(rlValue, sbValue, "!=")
            if res == "true"{ return true }else{ return false }
        case "may":
            let res = FormularioUtilities.shared.operaciones(rlValue, sbValue, ">")
            if res == "true"{ return true }else{ return false }
        case "mayorequal":
            let res = FormularioUtilities.shared.operaciones(rlValue, sbValue, ">=")
            if res == "true"{ return true }else{ return false }
        case "men":
            let res = FormularioUtilities.shared.operaciones(rlValue, sbValue, "<")
            if res == "true"{ return true }else{ return false }
        case "menorequal":
            let res = FormularioUtilities.shared.operaciones(rlValue, sbValue, "<=")
            if res == "true"{ return true }else{ return false }
        default: break;
        }
        
        return false
    }
    
    public func resolveValor(_ id: String, _ mode: String, _ string: String, _ category: String? = nil) -> Bool{
        if id == ""{ return false }
        let element = getElementANY(id)
        
        // Cleaning string
        let str = string.cleanFormulaResolveString()
        
        let tipoElemento = element.type //TipoElemento(rawValue: "\(element.type)") ?? TipoElemento.other
        
        switch tipoElemento {
        case "eventos", "plantilla", "pagina", "seccion": break;
        case "boton": break;
        case "comboboxtemporal":
            let listarow: ListaTemporalRow = element.kind as! ListaTemporalRow
            let nv: String = listarow.cell.elemento.validacion.valormetadato
            if (mode == "asignacion"){
                listarow.cell.setElements(str)
            }else if (mode == "afirmacion") {
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", nv, "empty");
                    case "notempty": return resolveCategory("", nv, "notempty");
                    case "contains": return resolveCategory(str, nv, "contains");
                    case "notcontains": return resolveCategory(str, nv, "notcontains");
                    default: break;
                    }
                }else{ return resolveCategory(str, nv, "equals") }
                
            }
            break;
        case "deslizante":
            let row: SliderNewRow = element.kind as! SliderNewRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }else if (mode == "afirmacion") {
                var vvv = row.value
                if vvv == nil{ vvv = "" }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    case "contains": return resolveCategory(str, vvv!, "contains");
                    case "notcontains": return resolveCategory(str, vvv!, "notcontains");
                    case "equals": return resolveCategory(str, vvv!, "equals");
                    case "notequals": return resolveCategory(str, vvv!, "notequals");
                    case "may": return resolveCategory(str, vvv!, "may");
                    case "mayorequal": return resolveCategory(str, vvv!, "mayorequal");
                    case "men": return resolveCategory(str, vvv!, "men");
                    case "menorequal": return resolveCategory(str, vvv!, "menorequal");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv!, "equals") }
                
            }
            break;
        case "espacio": break;
        case "fecha":
            let row: FechaRow = element.kind as! FechaRow
            if (mode == "asignacion"){
                row.cell.setEditedFecha(v: str, format: row.cell.atributos?.formato ?? "dd/MM/yyyy")
            }else if (mode == "afirmacion") {
                let vvv = row.value
                let formatter = DateFormatter()
                formatter.dateFormat = row.cell.formato
                let dateString = vvv == nil ? "" : formatter.string(from: vvv!)
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", dateString, "empty");
                    case "notempty": return resolveCategory("", dateString, "notempty");
                    case "contains": return resolveCategory(str, dateString, "contains");
                    case "notcontains": return resolveCategory(str, dateString, "notcontains");
                    case "equals": return resolveCategory(str, dateString, "equals");
                    case "notequals": return resolveCategory(str, dateString, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, dateString, "equals") }
                
            }
            break;
        case "hora":
            let row: FechaRow = element.kind as! FechaRow
            if (mode == "asignacion"){
                row.cell.setEditedHora(v: str)
            }else if (mode == "afirmacion") {
                let vvv = row.value
                let formatter = DateFormatter()
                formatter.dateFormat = row.cell.formato
                var dateString = vvv == nil ? "" : formatter.string(from: vvv!)
                if dateString.contains(".m.") && row.cell.formato == "H:mm"
                {   if dateString.contains("p.m.") && String(dateString.split(separator: ":").first ?? "").count == 1
                    {   var hourAux = Int(String(dateString.split(separator: ":").first ?? "")) ?? 0
                        hourAux = 12 + hourAux
                        dateString = "\(hourAux):\(String(dateString.split(separator: ":").last ?? ""))"
                    } else if dateString.contains("a.m.") && String(dateString.split(separator: ":").first ?? "") == "12"
                    {   dateString = "0:\(String(dateString.split(separator: ":").last ?? ""))"    }
                    dateString = (dateString.replacingOccurrences(of: " a.m.", with: "")).replacingOccurrences(of: " p.m.", with: "")
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", dateString, "empty");
                    case "notempty": return resolveCategory("", dateString, "notempty");
                    case "contains": return resolveCategory(str, dateString, "contains");
                    case "notcontains": return resolveCategory(str, dateString, "notcontains");
                    case "equals": return resolveCategory(str, dateString, "equals");
                    case "notequals": return resolveCategory(str, dateString, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, dateString, "equals") }
                
            }
            break;
        case "leyenda":
            let row: EtiquetaRow = element.kind as! EtiquetaRow
            if (mode == "asignacion"){
                row.cell.setValor(str)
                row.updateCell()
            }else if ( mode == "afirmacion") {
                let vvv = row.cell.getValor()
                return resolveCategory(str, vvv, "equals")
            }
            break;
        case "lista":
            let listarow: ListaRow = element.kind as! ListaRow
            let tl = listarow.cell.atributos?.tipolista
            
            if (mode == "asignacion")
            {   if category != nil
                {   if category == "filterlist"{
                        self.filtrosArray = Array<String>()
                        //if combo, filtraba con propiedad = listarow.cell.atributos?.filtrarcatalogo.filtrar == true ? str.split{$0 == ","}.map(String.init) : Array<String>()
                        filtrosArray = str.split{$0 == ","}.map(String.init)
                        listarow.cell.atributos?.minopcionesseleccionar = filtrosArray?.count ?? 0
                        listarow.cell.atributos?.maxopcionesseleccionar = filtrosArray?.count ?? 0
                    }
                    
                    let catalogos = ConfigurationManager.shared.utilities.getCatalogoInLibrary(listarow.cell.atributos?.catalogoorigen ?? "")
                    if catalogos != nil
                    {   let auxCatalogo = catalogos!.Catalogo
                        if auxCatalogo.count != 0 && !(self.filtrosArray?.isEmpty ?? true)
                        {
                            var filterCatalogo : Array<FEItemCatalogo> = [FEItemCatalogo]()
                            for item in auxCatalogo
                            {   self.filtrosArray?.forEach
                                {  if "\(item.CatalogoId)" == $0
                                    {
                                        filterCatalogo.append(item)
                                        if listarow.cell.atributos?.tipolista == "combo" {
                                            let itemOK = "\(item.Descripcion)|\(String(item.CatalogoId))"
                                            listarow.cell.listItemsLista.append(itemOK)
                                        }
                                    }
                                }
                            }
                            
                            if tl != "combo" {
                                listarow.cell.catOptionCheck = filterCatalogo
                                listarow.cell.reloadCheck()
                            }else if tl == "combo" {
                                listarow.cell.catalogoItems = filterCatalogo
                                listarow.cell.seleccionarValor(desc: "", id: "", isRobot: true)
                            }
                        }
                    }
                } else
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute:
                    {
                        if tl != "combo"
                        {
                            if ((listarow.cell.gralButton.selectedButtons().count == 1) && ((listarow.cell.gralButton.selectedButtons().first)?.tag == Int(str)))
                            {
                                listarow.cell.setEdited(v: str, isRobot: true)
                            } else {
                                listarow.cell.gralButton.selectedButtons().forEach{$0.isSelected = false}
                                listarow.cell.setEdited(v: str, isRobot: true)
                            }
                        }else if tl == "combo"
                        {
                            if str == "--Seleccione--" {
                                listarow.cell.seleccionarValor(desc: "", id: "", isRobot: true)
                            }else {
                                for item in listarow.cell.listItemsLista {
                                    let val = String(item.split(separator: "|").first ?? "")
                                    let id = String(item.split(separator: "|").last ?? "")
                                    if val == str || id == str {
                                        listarow.cell.seleccionarValor(desc: val, id: id, isRobot: true)
                                    }
                                }
                            }
                        }
                    })
                }
            }
            
            if (mode == "afirmacion")
            {
                var vvv: String = ""
                if tl != "combo"
                {
                    for radioButton in listarow.cell.gralButton.selectedButtons() { vvv += "\(radioButton.tag)" }
                }else if tl == "combo"
                {
                    let auxValor = listarow.cell.atributos?.tipoasociacion.first == "d" ? listarow.cell.elemento.validacion.valor : listarow.cell.elemento.validacion.valormetadato
                    vvv = listarow.cell.elemento.validacion.id != "" ? listarow.cell.elemento.validacion.id : auxValor
                }
                if category != nil
                {
                    switch category!{
                    case "empty": return resolveCategory("", vvv, "empty");
                    case "notempty": return resolveCategory("", vvv, "notempty");
                    case "contains":
                        if tl == "combo" {
                            /*if str.contains(",")
                            {   var result : [Bool] = []
                                str.split(separator: ",").forEach {val in
                                    result.append(resolveCategory(String(val), vvv, "contains"))
                                }
                                for res in result{
                                    if res == false{ return false } }
                                return true
                            }*/
                            return resolveCategory(str, vvv, "contains");
                        } else {
                            var results = [Bool]()
                            for radioButton in listarow.cell.gralButton.selectedButtons() {
                                results.append(resolveCategory(str, "\(radioButton.tag)", "contains"))
                            }
                            if results.count == 0{ return false }
                            for result in results{
                                if result{ return true }
                            }
                        }
                        return false
                    case "notcontains":
                        if tl == "combo" {
                            /*if str.contains(",")
                            {   var result : [Bool] = []
                                str.split(separator: ",").forEach {val in
                                    result.append(resolveCategory(String(val), vvv, "notcontains"))
                                }
                                for res in result{
                                    if res == false{ return false } }
                                return true
                            }*/
                            return resolveCategory(str, vvv, "notcontains");
                        } else {
                            var results = [Bool]()
                            for radioButton in listarow.cell.gralButton.selectedButtons() {
                                results.append(resolveCategory(str, "\(radioButton.tag)", "notcontains"))
                            }
                            if results.count == 0{ return false }
                            for result in results{
                                if result == false{ return false }
                            }
                        }
                        return true
                    case "equals": return resolveCategory(str, vvv, "equals");
                    case "notequals": return resolveCategory(str, vvv, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv, "equals") }
                
            }
            break;
        case "logico":
            let row: LogicoRow = element.kind as! LogicoRow
            if (mode == "asignacion"){
                if str == ""{
                    row.cell.setEdited(v: "false")
                }else{
                    row.cell.setEdited(v: str)
                }
                
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? false)
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv, "empty");
                    case "notempty": return resolveCategory("", vvv, "notempty");
                    case "contains": return resolveCategory(str, vvv, "contains");
                    case "notcontains": return resolveCategory(str, vvv, "notcontains");
                    case "equals": return resolveCategory(str, vvv, "equals");
                    case "notequals": return resolveCategory(str, vvv, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv, "equals") }
                
            }
            break;
        case "logo": break;
        case "moneda":
            let row: MonedaRow = element.kind as! MonedaRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }else if (mode == "afirmacion") {
                var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    case "contains": return resolveCategory(str, vvv!, "contains");
                    case "notcontains": return resolveCategory(str, vvv!, "notcontains");
                    case "equals": return resolveCategory(str, vvv!, "equals");
                    case "notequals": return resolveCategory(str, vvv!, "notequals");
                    case "may": return resolveCategory(str, vvv!, "may");
                    case "mayorequal": return resolveCategory(str, vvv!, "mayorequal");
                    case "men": return resolveCategory(str, vvv!, "men");
                    case "menorequal": return resolveCategory(str, vvv!, "menorequal");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv!, "equals") }
                
            }
            break;
        case "numero":
            let row: NumeroRow = element.kind as! NumeroRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }else if (mode == "afirmacion") {
                var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    case "contains": return resolveCategory(str, vvv!, "contains");
                    case "notcontains": return resolveCategory(str, vvv!, "notcontains");
                    case "equals": return resolveCategory(str, vvv!, "equals");
                    case "notequals": return resolveCategory(str, vvv!, "notequals");
                    case "may": return resolveCategory(str, vvv!, "may");
                    case "mayorequal": return resolveCategory(str, vvv!, "mayorequal");
                    case "men": return resolveCategory(str, vvv!, "men");
                    case "menorequal": return resolveCategory(str, vvv!, "menorequal");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv!, "equals") }
                
            }
            break;
        case "password":
            let row: TextoRow = element.kind as! TextoRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }else if (mode == "afirmacion") {
                var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    case "contains": return resolveCategory(str, vvv!, "contains");
                    case "notcontains": return resolveCategory(str, vvv!, "notcontains");
                    case "equals": return resolveCategory(str, vvv!, "equals");
                    case "notequals": return resolveCategory(str, vvv!, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv!, "equals") }
                
            }
            break;
        case "rangofechas":
            let row: RangoFechasRow = element.kind as! RangoFechasRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }else if (mode == "afirmacion") {
                var vvv = row.value?.replacingOccurrences(of: "-", with: "a")
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    case "contains": return resolveCategory(str, vvv!, "contains");
                    case "notcontains": return resolveCategory(str, vvv!, "notcontains");
                    case "equals": return resolveCategory(str, vvv!, "equals");
                    case "notequals": return resolveCategory(str, vvv!, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv!, "equals") }
                
            }
            break;
        case "semaforotiempo": break;
        case "tabber": break;
        case "tabla":
            let row: TablaRow = element.kind as! TablaRow
            if (mode == "asignacion"){
                row.cell.records.removeAll()
                row.cell.recordsVisibles.removeAll()
                row.cell.allCleanedData.removeAll()
                row.cell.ElementosCleanArray.removeAll()
                row.cell.dataRows.removeAll()
                
                let arrayValuess = str.split(separator: "|")
                for value in arrayValuess
                {
                    do {
                        let valuesRowIdUnico = try JSONSerializer.toDictionary(String(value))
                        row.cell.cleanProd = valuesRowIdUnico as? NSMutableDictionary ?? NSMutableDictionary()
                        row.cell.jsonService = true
                        let _ = row.cell.didTapSaveCancel()
                        row.updateCell()
                    } catch {
                        
                    }
                }
            }
            break;
        case "texto":
            let row: TextoRow = element.kind as! TextoRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }else if (mode == "afirmacion") {
                var vvv = row.value
                if vvv == nil{ vvv = "" }
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    case "contains": return resolveCategory(str, vvv!, "contains");
                    case "notcontains": return resolveCategory(str, vvv!, "notcontains");
                    case "equals": return resolveCategory(str, vvv!, "equals");
                    case "notequals": return resolveCategory(str, vvv!, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv!, "equals") }
                
            }
            break;
        case "textarea":
            let row: TextoAreaRow = element.kind as! TextoAreaRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }else if (mode == "afirmacion") {
                var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    case "contains": return resolveCategory(str, vvv!, "contains");
                    case "notcontains": return resolveCategory(str, vvv!, "notcontains");
                    case "equals": return resolveCategory(str, vvv!, "equals");
                    case "notequals": return resolveCategory(str, vvv!, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv!, "equals") }
                
            }
            break;
        case "wizard": break;
        case "combodinamico":
          if plist.idportal.rawValue.dataI() >= 40 {
            let row: ComboDinamicoRow = element.kind as! ComboDinamicoRow
            if (mode == "asignacion"){
                if row.cell.atributos?.tipolista == "combo"{
                    row.cell.settingValuesCombo(isRobot: true)
                    var valorDesc = ""
                    var valorid = ""
                    row.cell.listItemsCombo.forEach{ item in
                        let val = String(item.split(separator: "|").first ?? "")
                        let id = String(item.split(separator: "|").last ?? "")
                        if (val == str) || (id == str) {
                            valorDesc = val
                            valorid = id
                            row.cell.selectItem(valor: valorDesc, valormetadato: valorid)
                        }
                    }
                }else {
                    row.cell.gralButton.selectedButtons().forEach{$0.isSelected = false}
                    row.cell.setEdited(v: str)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.valormetadato
                var valInt = str
                if valInt.count == 2 && valInt.first == "0" { valInt = valInt.replacingOccurrences(of: "0", with: "")}
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv, "empty");
                    case "notempty": return resolveCategory("", vvv, "notempty");
                    case "contains": return resolveCategory(valInt, vvv, "contains");
                    case "notcontains": return resolveCategory(valInt, vvv, "notcontains");
                    case "equals": return resolveCategory(valInt, vvv, "equals");
                    case "notequals": return resolveCategory(valInt, vvv, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv, "equals") }
                
            }
          }
            break;
        case "marcadodocumentos":
          if plist.idportal.rawValue.dataI() >= 41 {
            let listarow: MarcadoDocumentoRow = element.kind as! MarcadoDocumentoRow
            var nv: String? = ""
            var idSel = ""
            var titSel = ""
            if str.contains("|")
            {   idSel = String(str.split(separator: "|")[0])
                if str.split(separator: "|").count >= 2{
                    titSel = String(str.split(separator: "|")[1])
                }
            } else
            {   idSel = str }
            
            for radioButton in listarow.cell.gralButton.selectedButtons()
            {   if !idSel.contains("OFF") || idSel.replacingOccurrences(of: "OFF", with: "") != String(radioButton.tag)
                {
                    nv = nv != "" ? "\(String(nv ?? "")),\(String(radioButton.tag))" : String(radioButton.tag)
                }
            }
            
            if ((mode == "afirmacion") && (nv == "") ){
                return false    }
            
            if (mode == "asignacion")
            {
                if category != nil {
                    if category == "filterlist"{
                        self.filtrosArray = Array<String>()
                        self.filtrosArray = str.split{$0 == ","}.map(String.init)
                    }
                    if filtrosArray?.count ?? 0 > 0
                    {
                        if listarow.cell.atributos?.catalogoorigen == "9999"
                        {
                            var filterCatalogo : Array<FEListTipoDoc> = [FEListTipoDoc]()
                            let listTipoDoc = ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc
                            for listTD in listTipoDoc
                            {   let dataListTD = listTD as FEListTipoDoc
                                self.filtrosArray?.forEach
                                {  if String(dataListTD.CatalogoId) == $0 {
                                        filterCatalogo.append(dataListTD)
                                    }
                                }
                            }
                            listarow.cell.catOptionCheck2 = filterCatalogo
                            var auxSelec : [String] = []
                            //if listarow.cell.gralButton.selectedButtons().count > 0 {   listarow.cell.gralButton.selectedButtons().forEach{btn in auxSelec.append(String(btn.titleLabel?.text ?? ""))}   }
                            listarow.value?.split(separator: ",").forEach({
                                auxSelec.append(String($0))
                            })
                            listarow.cell.setValuesList()
                            if !auxSelec.isEmpty
                            {
                                let titGral = listarow.cell.gralButton.titleLabel!.text!.contains(" *") ? listarow.cell.gralButton.titleLabel!.text!.replacingOccurrences(of: " *", with: "") : listarow.cell.gralButton.titleLabel!.text!
                                listarow.cell.gralButton.isSelected = auxSelec.contains(titGral) || auxSelec.contains("\(listarow.cell.gralButton.tag)") ? true : false
                                listarow.cell.gralButton.otherButtons.forEach { btn in
                                    let titBtn = btn.titleLabel!.text!.contains(" *") ? btn.titleLabel!.text!.replacingOccurrences(of: " *", with: "") : btn.titleLabel!.text!
                                    btn.isSelected = auxSelec.contains(titBtn) || auxSelec.contains("\(btn.tag)") ? true : false
                                }
                                listarow.cell.selectedButton(radioButton: listarow.cell.gralButton, isRobot: true)
                            }
                        } else
                        {
                            let catalogos = ConfigurationManager.shared.utilities.getCatalogoInLibrary(listarow.cell.atributos?.catalogoorigen ?? "")
                            if catalogos?.Catalogo.count ?? 0 > 0 {
                                var filterCatalogo : Array<FEItemCatalogo> = [FEItemCatalogo]()
                                for catalogo in catalogos!.Catalogo {
                                    self.filtrosArray?.forEach
                                    {   if String(catalogo.CatalogoId) == $0
                                        {
                                            filterCatalogo.append(catalogo)
                                        }
                                    }
                                }
                                listarow.cell.catOptionCheck = filterCatalogo
                                var auxSelec : [String] = []
                                if listarow.cell.gralButton.selectedButtons().count > 0
                                {   listarow.cell.gralButton.selectedButtons().forEach{btn in auxSelec.append(String(btn.titleLabel?.text ?? ""))}   }
                                listarow.cell.setValuesList()
                                if !auxSelec.isEmpty
                                {   listarow.cell.gralButton.isSelected = auxSelec.contains(listarow.cell.gralButton.titleLabel?.text ?? "")
                                    listarow.cell.gralButton.otherButtons.forEach{btn in
                                        btn.isSelected = auxSelec.contains(btn.titleLabel?.text ?? "")
                                    }
                                }
                            }
                        }
                    }
                } else
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute:
                    {
                        if str.contains("OFF")
                        {   var sinSeleccion = false
                            if ((listarow.cell.gralButton.selectedButtons().count == 1) && ((listarow.cell.gralButton.selectedButtons().first)?.tag == Int(idSel))) {
                                (listarow.cell.gralButton.selectedButtons().first)?.isSelected = false
                                listarow.cell.setEdited(v: "sinSelección", isRobot: false)
                                sinSeleccion = true
                            } else {
                                listarow.cell.gralButton.selectedButtons().forEach{$0.isSelected = false}
                                if nv == "" {
                                    listarow.cell.setEdited(v: "sinSelección", isRobot: false)
                                    sinSeleccion = true
                                } else {
                                    listarow.cell.setEdited(v: "\(String(nv ?? ""))|--Seleccione--", isRobot: false)
                                }
                            }
                            if sinSeleccion
                            {   let row = self.getElementByIdInAllForms(listarow.cell.atributos?.elementodocumento.first as? String ?? "")
                                if row is DocumentoRow
                                {   let base = row as? DocumentoRow
                                    let tipificacionUnica: NSMutableDictionary = NSMutableDictionary()
                                    tipificacionUnica["enabled"] = ""
                                    tipificacionUnica["idtype"] = ""
                                    base?.cell.atributos.tipificacionunica = tipificacionUnica
                                    base?.cell.setVisible(false)
                                    base?.cell.update()
                                }
                            }
                        } else
                        {
                            if ((listarow.cell.gralButton.selectedButtons().count == 1) && ((listarow.cell.gralButton.selectedButtons().first)?.tag == Int(idSel))) || (nv == "" && idSel != "")
                            {
                                listarow.cell.setEdited(v: str, isRobot: false)
                            } else {
                                //NV+STR
                                var exist = false
                                nv?.split(separator: ",").forEach{ if $0 == idSel {exist = true}}
                                if !exist
                                {
                                    if titSel != "" {
                                        nv = "\(String(nv ?? "")),\(String(idSel))|\(titSel)"
                                    } else {    nv = "\(String(nv ?? "")),\(String(idSel))|--Seleccione--"   }
                                    listarow.cell.gralButton.selectedButtons().forEach{$0.isSelected = false}
                                    listarow.cell.setEdited(v: nv ?? "", isRobot: false)
                                }
                                
                            }
                        }
                    })
                }
            }
            if (mode == "afirmacion") {
                let vvv = nv ?? ""
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv, "empty");
                    case "notempty": return resolveCategory("", vvv, "notempty");
                    case "contains":
                        return resolveCategory(str, vvv, "contains");
                    case "notcontains": return resolveCategory(str, vvv, "notcontains");
                    case "equals": return resolveCategory(str, vvv, "equals");
                    case "notequals": return resolveCategory(str, vvv, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv, "equals") }
                
            }
          }
            break;
        case "metodo", "servicio": break;
        case "codigobarras":
            let row: CodigoBarrasRow = element.kind as! CodigoBarrasRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }else if (mode == "afirmacion") {
                var vvv = row.value
                if vvv == nil{ vvv = "" }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    case "contains": return resolveCategory(str, vvv!, "contains");
                    case "notcontains": return resolveCategory(str, vvv!, "notcontains");
                    case "equals": return resolveCategory(str, vvv!, "equals");
                    case "notequals": return resolveCategory(str, vvv!, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv!, "equals") }
                
            }
            break;
        case "codigoqr":
          if plist.idportal.rawValue.dataI() >= 39 {
            let row: CodigoQRRow = element.kind as! CodigoQRRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }else if (mode == "afirmacion") {
                var vvv = row.value
                if vvv == nil{ vvv = "" }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    case "contains": return resolveCategory(str, vvv!, "contains");
                    case "notcontains": return resolveCategory(str, vvv!, "notcontains");
                    case "equals": return resolveCategory(str, vvv!, "equals");
                    case "notequals": return resolveCategory(str, vvv!, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv!, "equals") }
                
            }
          }
            break;
        case "nfc":
          if plist.idportal.rawValue.dataI() >= 39 {
            let row: EscanerNFCRow = element.kind as! EscanerNFCRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }else if (mode == "afirmacion") {
                var vvv = row.value
                if vvv == nil{ vvv = "" }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    case "contains": return resolveCategory(str, vvv!, "contains");
                    case "notcontains": return resolveCategory(str, vvv!, "notcontains");
                    case "equals": return resolveCategory(str, vvv!, "equals");
                    case "notequals": return resolveCategory(str, vvv!, "notequals");
                    default: break;
                    }
                }else{ return resolveCategory(str, vvv!, "equals") }
                
            }
          }
            break;
        case "audio", "voz":
            let row: AudioRow = element.kind as! AudioRow
            if (mode == "afirmacion")
            {   var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    default: break;
                    }
                }
            }
            break;
        case "calculadora": break;
        case "firma":
            let row: FirmaRow = element.kind as! FirmaRow
            if (mode == "asignacion"){
                if category == "terminos"{
                    row.cell.atributos?.acuerdofirma = str
                }
            }else if (mode == "afirmacion") {
                var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    default: break;
                    }
                }
            }
            break;
        case "firmafad":
             if plist.idportal.rawValue.dataI() >= 39{
                let row: FirmaFadRow = element.kind as! FirmaFadRow
                if (mode == "asignacion"){
                    if category == "terminos"{
                        row.cell.atributos?.acuerdofirma = str
                    }
                }else if (mode == "afirmacion") {
                    var vvv = row.value
                    if vvv == nil{
                        vvv = ""
                    }
                    
                    if category != nil{
                        switch category!{
                        case "empty": return resolveCategory("", vvv!, "empty");
                        case "notempty": return resolveCategory("", vvv!, "notempty");
                        default: break;
                        }
                    }
                }
                break;
             }

        case "georeferencia":
            let row: MapaRow = element.kind as! MapaRow
            if (mode == "afirmacion")
            {   var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    default: break;
                    }
                }
            }
            break;
        case  "mapa":
            let row: MapaRow = element.kind as! MapaRow
            if (mode == "afirmacion")
            {   var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    default: break;
                    }
                }
            }
            break
        case "imagen":
            let row: ImagenRow = element.kind as! ImagenRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }
            
            if (mode == "afirmacion")
            {   var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    default: break;
                    }
                }
            }
            break;
        case "documento":
            let row: DocumentoRow = element.kind as! DocumentoRow
            if (mode == "afirmacion")
            {   var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    default: break;
                    }
                }
            }
            break;
        case "video", "videollamada":
            let row: VideoRow = element.kind as! VideoRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: str)
            }
            if (mode == "afirmacion")
            {   var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    default: break;
                    }
                }
            }
            break;
         case "ocr":
                break
        case "huelladigital":
            let row: VeridiumRow = element.kind as! VeridiumRow
            if (mode == "afirmacion")
            {   var vvv = row.value
                if vvv == nil{
                    vvv = ""
                }
                
                if category != nil{
                    switch category!{
                    case "empty": return resolveCategory("", vvv!, "empty");
                    case "notempty": return resolveCategory("", vvv!, "notempty");
                    default: break;
                    }
                }
            }
            break;
        default:
            break;
        }
        
        return false
    }
    
    func resolveValor(_ type: String, _ mode: String, _ rr: ReturnFormulaType, _ elem: Formula, _ formul: [Formula], _ equals: Int) -> String {
        
        let element = getElementANY(elem.id)
        var valueStringInt = ""
        switch rr{
        case .typeString(let string): valueStringInt = string; break
        case .typeInt(let int): valueStringInt = String(int); break
        case .typeArray( _), .typeDictionary( _): break
        default: break
        }
        
        valueStringInt = valueStringInt.cleanFormulaResolveString()
        
        let tipoElemento = element.type //TipoElemento(rawValue: "\(elem.tipo)") ?? TipoElemento.other

        switch tipoElemento{
        case "eventos", "plantilla", "pagina", "seccion": break;
        case "boton": break;
        case "comboboxtemporal":
            let listarow: ListaTemporalRow = element.kind as! ListaTemporalRow
            let nv: String = listarow.cell.elemento.validacion.valormetadato
            if (mode == "asignacion"){
                listarow.cell.setElements(valueStringInt)
                listarow.updateCell()
            }else if (mode == "afirmacion") {
                if nv == "" { return "0" }
                let result = FormularioUtilities.shared.operaciones(valueStringInt, nv, formul[equals].value)
                return result
            }
            break;
        case "deslizante":
            let row: SliderNewRow = element.kind as! SliderNewRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "espacio": break;
        case "fecha":
            let row: FechaRow = element.kind as! FechaRow
            if (mode == "asignacion"){
                row.cell.setEditedFecha(v: valueStringInt.replacingOccurrences(of: " ", with: "/"), format: row.cell.atributos?.formato ?? "dd/MM/yyyy")
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.getValueFecha()
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "hora":
            let row: FechaRow = element.kind as! FechaRow
            if (mode == "asignacion"){
                row.cell.setEditedHora(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.getValueHora()
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "leyenda":
            let row: EtiquetaRow = element.kind as! EtiquetaRow
            if (mode == "asignacion"){
                row.cell.setValor(valueStringInt)
                row.updateCell()
            }else if ( mode == "afirmacion") {
                let vvv = row.cell.getValor()
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "lista":
            let listarow: ListaRow = element.kind as! ListaRow
            _ = listarow.cell.atributos?.tipoasociacion
            let tl = listarow.cell.atributos?.tipolista
            var nv: String? = ""
            if tl != "combo"
            {
                for radioButton in listarow.cell.gralButton.selectedButtons()
                { nv = nv != "" ? "\(String(describing: nv)),\(radioButton.tag)" : "\(radioButton.tag)" }
            } else {
                let auxValor = listarow.cell.atributos?.tipoasociacion.first == "d" ? listarow.cell.elemento.validacion.valor : listarow.cell.elemento.validacion.valormetadato
                nv = listarow.cell.elemento.validacion.id != "" ? listarow.cell.elemento.validacion.id : auxValor
            }
            
            if ((mode == "afirmacion") && (nv == "")) { return "0" }
            
            if tl != "combo"
            {   if (mode == "asignacion")
                {   DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute:
                    {   if ((listarow.cell.gralButton.selectedButtons().count == 1) && ((listarow.cell.gralButton.selectedButtons().first)?.tag == Int(valueStringInt)))
                        {
                            listarow.cell.setEdited(v: valueStringInt, isRobot: true)
                        } else {
                            listarow.cell.gralButton.selectedButtons().forEach{$0.isSelected = false}
                            listarow.cell.setEdited(v: valueStringInt, isRobot: true)
                        }
                    })
                }
            } else if tl == "combo" {
                let catalogoOption = ConfigurationManager.shared.utilities.getCatalogoInLibrary(listarow.cell.atributos?.catalogoorigen ?? "")
                var desc = ""
                if catalogoOption != nil{
                    for catData in catalogoOption!.Catalogo{
                        if valueStringInt == catData.CVECatalogo{
                            desc = catData.Descripcion
                        }
                    }
                }
                let selectedValues = desc
                let showedValues = desc
                
                var showedValuesModify = showedValues.replacingOccurrences(of: "\r\n", with: ",")
                if showedValuesModify != ""{
                    listarow.value = selectedValues
                    showedValuesModify = String(showedValuesModify.dropLast())
                    listarow.cell.seleccionarValor(desc: showedValuesModify, id: selectedValues, isRobot: true)
                }else{
                    listarow.value = nil
                }
            }
            if (mode == "afirmacion") {
                let result = FormularioUtilities.shared.operaciones(valueStringInt, nv!, formul[equals].value)
                return result
            }
            break;
        case "marcadodocumentos": //
          if plist.idportal.rawValue.dataI() >= 41 {
            let listarow: MarcadoDocumentoRow = element.kind as! MarcadoDocumentoRow
            _ = listarow.cell.atributos?.tipoasociacion
            let tl = listarow.cell.atributos?.tipolista
            var nv: String? = ""
            if tl != "combo"
            {
                for radioButton in listarow.cell.gralButton.selectedButtons()
                {
                    nv = nv != "" ? "\(String(describing: nv)),\(radioButton.tag)" : "\(radioButton.tag)"
                }
                
                if ((mode == "afirmacion") && (nv == "") ){
                    return "0"
                }
                
                if (mode == "asignacion")
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute:
                    {
                        if ((listarow.cell.gralButton.selectedButtons().count == 1) && ((listarow.cell.gralButton.selectedButtons().first)?.tag == Int(valueStringInt)))
                        {
                            listarow.cell.setEdited(v: valueStringInt, isRobot: true)
                        } else {
                            listarow.cell.gralButton.selectedButtons().forEach{$0.isSelected = false}
                            listarow.cell.setEdited(v: valueStringInt, isRobot: true)
                        }
                    })
                }
            }
            if tl == "combo"
            {
                guard let lista = listarow.customController?.form.first as? SelectableSection<ListCheckRow<String>> else{ return "0" }
                nv = lista.selectedRow()?.tag != "--Seleccione--" ? lista.selectedRow()?.tag : ""
                if nv == nil { nv = "" }
                if ((mode == "afirmacion") && (nv == "")) { return "0" }
                
                if (mode == "asignacion") {
                    
                    let catalogoOption = ConfigurationManager.shared.utilities.getCatalogoInLibrary(listarow.cell.atributos?.catalogoorigen ?? "")
                    for (_, lstcell) in lista.allRows.enumerated() {
                        let cell = lstcell as? ListCheckRow<String>
                        cell?.value = nil
                        
                        if cell?.tag == valueStringInt{
                            cell?.tag = "ISROBOT||\(cell?.tag ?? "")"
                            cell?.didSelect()
                            cell?.value = cell?.selectableValue
                        }
                    }

                    var selectedValues = ""
                    var showedValues = ""
                    var desc = ""
                    if catalogoOption != nil{
                        for catData in catalogoOption!.Catalogo{
                            if valueStringInt == catData.CVECatalogo{
                                desc = catData.Descripcion
                            }
                        }
                    }
                    
                    if tl == "combo"{
                        selectedValues += "\(lista.selectedRow()?.tag ?? "")"
                        showedValues += "\(lista.selectedRow()?.selectableValue! ?? "")"
                    }
                    selectedValues = desc
                    showedValues = desc
                    
                    var showedValuesModify = showedValues.replacingOccurrences(of: "\r\n", with: ",")
                    if showedValuesModify != ""{
                        listarow.value = selectedValues
                    }else{
                        listarow.value = nil
                    }
                    showedValuesModify = String(showedValuesModify.dropLast())
                    if listarow.isValid {
                        element.element?.validacion.validado = true
                        element.element?.validacion.valor = selectedValues
                        element.element?.validacion.valormetadato = showedValuesModify
                    }else{
                        element.element?.validacion.validado = false
                        element.element?.validacion.valor = selectedValues
                        element.element?.validacion.valormetadato = showedValuesModify
                    }
                }
            }
            if (mode == "afirmacion") {
                let result = FormularioUtilities.shared.operaciones(valueStringInt, nv!, formul[equals].value)
                return result
            }
          }
            break;
        case "logico":
            let row: LogicoRow = element.kind as! LogicoRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? false)
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "logo": break;
        case "moneda":
            let row: MonedaRow = element.kind as! MonedaRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "numero":
            let row: NumeroRow = element.kind as! NumeroRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "password":
            let row: TextoRow = element.kind as! TextoRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "rangofechas":
            let row: RangoFechasRow = element.kind as! RangoFechasRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "semaforotiempo": break;
        case "tabber": break;
        case "tabla":
            let row: TablaRow = element.kind as! TablaRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "texto":
            let row: TextoRow = element.kind as! TextoRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "textarea":
            let row: TextoAreaRow = element.kind as! TextoAreaRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "wizard": break;
        case "combodinamico":
          if plist.idportal.rawValue.dataI() >= 40 {
            let row: ComboDinamicoRow = element.kind as! ComboDinamicoRow
            if (mode == "asignacion"){
                if row.cell.atributos?.tipolista == "combo"{
                    var valorDesc = ""
                    var valorid = ""
                    row.cell.listItemsCombo.forEach{
                        let val = String($0.split(separator: "|").first ?? "")
                        let id = String($0.split(separator: "|").last ?? "")
                        if (val == valueStringInt) || (id == valueStringInt) {
                            valorDesc = val
                            valorid = id
                        }
                    }
                    row.cell.selectItem(valor: valorDesc, valormetadato: valorid)
                }else
                {
                    row.cell.gralButton.selectedButtons().forEach{$0.isSelected = false}
                    row.cell.setEdited(v: valueStringInt)
                }
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
          }
            break;
        case "codigobarras":
            let row: CodigoBarrasRow = element.kind as! CodigoBarrasRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = row.cell.elemento.validacion.valormetadato
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
            break;
        case "codigoqr":
          if plist.idportal.rawValue.dataI() >= 39 {
            let row: CodigoQRRow = element.kind as! CodigoQRRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
          }
            break;
        case "nfc":
          if plist.idportal.rawValue.dataI() >= 39 {
            let row: EscanerNFCRow = element.kind as! EscanerNFCRow
            if (mode == "asignacion"){
                row.cell.setEdited(v: valueStringInt)
                row.updateCell()
            }else if (mode == "afirmacion") {
                let vvv = String(row.value ?? "")
                let result = FormularioUtilities.shared.operaciones(valueStringInt, vvv, formul[equals].value)
                return result
            }
          }
            break;
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
        
        return ""
    }
    
    public func resolveValorQR(_ namePrellenado: String, _ idQRgenerado: String)->Bool
    {
        var stringQR = ""
        let dictQR = NSMutableDictionary()
        if FormularioUtilities.shared.prefilleddata != nil
        {
            if let prefilledDocument = FormularioUtilities.shared.prefilleddata?.root[namePrellenado]
            {
                for mapeo in (prefilledDocument["mapeo"].children){
                    if mapeo["mapeoHijos"].error != nil { continue }
                    if mapeo["mapeoHijos"].children.count == 0{ continue }
                    for childs in mapeo["mapeoHijos"].children{
                        if childs["idelem"].value ?? "" == "" { continue }
                        let valor : String = self.valueElementRow(childs["idelem"].value ?? "")
                        let ids = childs["destination"].all
                        for id in ids!
                        {   if ((id.value)?.contains("formElec_element"))! {
                                let idOK : String = id.value!.replacingOccurrences(of: "formElec_element", with: "")
                                dictQR.setValue("\(valor)" , forKey: "\(idOK)")
                            }
                        }
                    }
                }
            }
        }
        stringQR = "\(dictQR as! [String : String])".replacingOccurrences(of: "[", with: "[{").replacingOccurrences(of: "]", with: "}]")
        _ = self.resolveValor(idQRgenerado, "asignacion", "\(stringQR)", nil)
        return false
        
    }
    
}
