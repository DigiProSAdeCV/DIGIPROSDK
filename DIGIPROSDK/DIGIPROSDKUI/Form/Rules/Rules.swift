import Foundation
import Eureka

// MARK: - RULES AND SERVICES
extension NuevaPlantillaViewController
{
    public func showNotifOrPopupAlert(_ type: String, _ value: String){
        switch type{
        case "popup": let popup = DangerAlertViewController()
            popup.show(in: self, title: "alrt_service".langlocalized(), description: "\(value)", textButton: "alrt_accept".langlocalized(), imageAlert: UIImage(named: "info_alert", in: Cnstnt.Path.framework, compatibleWith: nil), colorBanner: .blue, colorButton: .blue, colorText: .white); break;
        case "notiferror": setStatusBarNotificationBanner("\(value)", .danger, .bottom); break;
        case "notif": setStatusBarNotificationBanner("\(value)", .success, .bottom); break;
        case "notifinfo": setStatusBarNotificationBanner("\(value)", .info, .bottom); break;
        default: break;
        }
    }
    
    // MARK: - RESOLVING ALL CONDITIONS
    public func resolvingAllCondition(_ conditions: AEXMLElement, _ element: String? = nil, _ vrb: String? = nil, _ forced: Bool? = nil) -> Bool{
        
        var results = [Bool]()
        for condition in conditions.children{
            if element != nil && vrb != nil{
                for subject in condition["subject"].children{
                    if (subject["subject"].value == nil){ continue }
                    if element == subject["subject"].value! || (element == condition["tableidelem"].value ?? "" && condition["category"].value! == "bytable") {
                        results.append(resolveCondition(condition, element, vrb, forced))
                    }else{
                        results.append(resolveCondition(condition, nil, nil, forced))
                    }
                }
            }else{
                results.append(resolveCondition(condition, nil, nil, forced))
            }
        }
        if results.count == 0{
            return false
        }
        for result in results{
            if result == false{
                return false
            }
        }
        return true
    }
    
    // MARK: - RESOLVING ANY CONDITION
    public func resolvingAnyCondition(_ conditions: AEXMLElement, _ element: String? = nil, _ vrb: String? = nil, _ forced: Bool? = nil) -> Bool{
        var results = [Bool]()
        for condition in conditions.children{
            if element != nil && vrb != nil{
                results.append(resolveCondition(condition, element, vrb, forced))
            }else{
                results.append(resolveCondition(condition, nil, nil, forced))
            }
        }
        if results.count == 0{ return true }
        for result in results{ if result{ return true } }
        return false
    }
    
    // MARK: - RESOLVE A CONDITION
    // Reglas Condición
    
    /// Resolve any or all conditions configurated in IDPortal
    /// - Parameters:
    ///   - condition: condition in xml format
    ///   - element: name of the element
    ///   - vrb: verb means kind of action to realize
    ///   - forced: if the rule needs to be executed no matter the condition
    /// - Returns: returns true or false if the rule was success or not
    public func resolveCondition(_ condition: AEXMLElement, _ element: String? = nil, _ vrb: String? = nil, _ forced: Bool? = nil) -> Bool{
        ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando Condición: %@, categoría: %@", condition.name, condition["category"].value ?? ""))
        ConfigurationManager.shared.utilities.log(.action, String(format: "La condición fué ejecutada por: %@ con el verbo: %@", element ?? "", vrb ?? ""))
        
        self.historiaOBJ.Categoria = "Regla"
        self.historiaOBJ.Descripcion = "Evaluando Condición: \(condition.name), categoria:  \(condition["category"].value ?? "" ) La condición fue ejecutada por:  \(element ?? "") con el verbo: \(vrb ?? "")"
        
        let fechaHistoria = Date.getTicks()
        self.historiaOBJ.FechaHistoria = fechaHistoria
        self.historialEstadistico.append(self.historiaOBJ)
        switch condition["category"].value{
        case "withoutcondition":
                return true
            break
        case "elementid": // Caso específico para las reglas que tienen o no tienen elemento
            for subject in condition["subject"].children{
                ConfigurationManager.shared.utilities.log(.log, String(format: "Nombre del elemento: %@", subject.name))
                if forced ?? false{
                    if subject["verb"].error != nil{ return true }
                }else{
                    if subject["verb"].error != nil{ return false }
                }
                return self.resolvingConditionElement( vrb ?? "" , element ?? "" , subject)
            }
            break
        case "document":            // Flujo
            for subject in condition["subject"].children {
                let id = subject["subject"].value!.split{$0 == "_"}.map(String.init)
                
                switch id[0]{
                case "EstadoDoc":
                    if String(FormularioUtilities.shared.currentFormato.EstadoID) == id[1]{ return true }else{ return false }
                case "PIIDdocumento":
                    if String(FormularioUtilities.shared.currentFormato.PIID) == id[1]{ return true }else{ return false }
                default:
                    return false
                }
            }
            break;
        case "permissions":         // Permisos
            for subject in condition["subject"].children {
                let id = subject["subject"].value!.split{$0 == "_"}.map(String.init)
                if FormularioUtilities.shared.variables(id[0]).lowercased() == id[1].lowercased() { return true }else{return false }
            }
            break;
        case "table":               // Tablas por columna
            for subject in condition["subject"].children{
                ConfigurationManager.shared.utilities.log(.log, String(format: "Nombre del elemento (columna en tabla): %@", subject.name))
                return self.resolvingConditionElement( vrb ?? "" , element ?? "" , subject)
            }
            break;
        case "bytable":             // Tablas por filas
            switch condition["rowtype"].value
            {
            case "bynewrow", "byeditrow": // al agregar fila, al editar fila
                if element != nil && element != "formElec_element0" && vrb == condition["rowtype"].value
                {
                    var results = [Bool]()
                    for subject in condition["subject"].children
                    {
                        if (subject["subject"].value != nil)
                        {
                            results.append(self.resolvingConditionElement( subject["verb"].value ?? "" , element ?? "" , subject))
                        }
                    }
                    if results.count == 0 { return false }
                    for result in results{
                        if result == false{
                            return false
                        }
                    }
                    return true
                }else{ return false }
            case "byallrows": // todas deben cumplir
                if element != nil && element != "formElec_element0" && vrb == "byallrows"
                {
                    let tabla = getElementANY(element!)
                    if tabla.type == "tabla"
                    {
                        let row: TablaRow = tabla.kind as! TablaRow
                        var aux = row.value
                        if aux == nil { return false }
                        do{
                            if aux!.contains("catalogodestino") {   aux = self.clearCatalogo(valor: aux ?? "")  }
                            let arrayDictionary = try JSONSerializer.toArray(row.value!)
                            for keyArray in arrayDictionary
                            {   let dictArray = keyArray as! NSMutableDictionary
                                var results = [Bool]()
                                for dict in dictArray
                                {
                                    for subject in condition["subject"].children
                                    {
                                        if (subject["subject"].value != nil)
                                        {
                                            if dict.key as? String == subject["subject"].value
                                            {
                                                let dictValor = dict.value as! NSMutableDictionary
                                                switch subject["verb"].value
                                                {
                                                case "empty","notempty" :
                                                    results.append(self.resolveCategory("", dictValor.value(forKey: "valor") as? String ?? "", subject["verb"].value ?? ""))
                                                    break
                                                case "contains","notcontains", "equals", "notequals", "may" , "mayorequal", "men", "menorequal":
                                                    
                                                    var valueRow = dictValor.value(forKey: "valor") as? String ?? ""
                                                    let valueMetaRow = dictValor.value(forKey: "valormetadato") as? String ?? ""
                                                    if (valueRow.count == 12 || valueRow.count == 27) && valueRow.contains("\\/")
                                                    {
                                                        valueRow = valueRow.replacingOccurrences(of: "\\/", with: "/")
                                                        valueRow = valueRow.replacingOccurrences(of: "-", with: "a")
                                                    }
                                                    let resultValorMeta = self.resolveCategory(valueByType(subject, dictArray), valueMetaRow, subject["verb"].value ?? "")
                                                    let resulVal = self.resolveCategory(valueByType(subject, dictArray), valueRow, subject["verb"].value ?? "")
                                                    
                                                    if (resultValorMeta && resulVal) || (resultValorMeta || resulVal)
                                                    {
                                                        results.append(true)
                                                    }else
                                                    {
                                                        results.append(false)
                                                    }
                                                    break
                                                case "selected":
                                                    let auxValor = dictValor.value(forKey: "valor") as? String ?? ""
                                                    results.append(auxValor == "true" ? true : false)
                                                case "notselected":
                                                    let auxValor = dictValor.value(forKey: "valor") as? String ?? ""
                                                    results.append(auxValor == "false" ? true : false)
                                                case "click":
                                                    let auxId = dictArray.value(forKey: "Acciones") as! NSMutableDictionary
                                                    let id = auxId.value(forKey: "id") as? String ?? "0"
                                                    let auxIdClick = Int(id) ?? 0
                                                    let idRowClick = Int(string: String(row.cell.clickInRow.split(separator: "-").first ?? "") )
                                                    let idBtnClick = String(row.cell.clickInRow.split(separator: "-").last ?? "")
                                                    if (idRowClick == auxIdClick) && (idBtnClick == subject["subject"].value)
                                                    { results.append(true ) } else { results.append(false)}
                                                default:
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                                if results.count == 0 { return false }
                                for result in results{
                                    if result == false{
                                        return false
                                    }
                                }
                            }
                            return true
                        }catch{
                            print(error)
                            return false
                        }
                    } else { return false }
                }else{ return false }
            case "byatleastonerow": // todas las que cumplan
                if element != nil && element != "formElec_element0" && vrb == "byatleastonerow"
                {
                    let tabla = getElementANY(element!)
                    if tabla.type == "tabla"
                    {
                        let row: TablaRow = tabla.kind as! TablaRow
                        var aux = row.value
                        if aux == nil { return false }
                        do{
                            if aux!.contains("catalogodestino") {   aux = self.clearCatalogo(valor: aux ?? "")  }
                            let arrayDictionary = try JSONSerializer.toArray(aux!)
                            var rowsOK = [Int]()
                            for keyArray in arrayDictionary
                            {   let dictArray = keyArray as! NSMutableDictionary
                                var results = [Bool]()
                                for dict in dictArray
                                {
                                    if dict.key as! String == "Acciones"
                                    {   let dictValor = dict.value as! NSMutableDictionary
                                        var id = dictValor.value(forKey: "id") as? String ?? ""
                                        if id == "" { id = "\(dictValor.value(forKey: "id") as? Int ?? 0)"}
                                        rowsOK.append(Int(id) ?? 0)
                                    }
                                    for subject in condition["subject"].children
                                    {
                                        if (subject["subject"].value != nil)
                                        {
                                            if dict.key as? String == subject["subject"].value
                                            {
                                                let dictValor = dict.value as! NSMutableDictionary
                                                switch subject["verb"].value
                                                {
                                                case "empty":
                                                    results.append(self.resolveCategory("", dictValor.value(forKey: "valor") as? String ?? "", subject["verb"].value ?? ""))
                                                    break
                                                case "notempty":
                                                    results.append(self.resolveCategory("", dictValor.value(forKey: "valor") as? String ?? "", subject["verb"].value ?? ""))
                                                    break
                                                case "contains","notcontains", "equals", "notequals", "may" , "mayorequal", "men", "menorequal":
                                                    
                                                    var valueRow = dictValor.value(forKey: "valor") as? String ?? ""
                                                    let valueMetaRow = dictValor.value(forKey: "valormetadato") as? String ?? ""
                                                    if (valueRow.count == 12 || valueRow.count == 27) && valueRow.contains("\\/")
                                                    {
                                                        valueRow = valueRow.replacingOccurrences(of: "\\/", with: "/")
                                                        valueRow = valueRow.replacingOccurrences(of: "-", with: "a")
                                                    }
                                                    let resultValorMeta = self.resolveCategory(valueByType(subject, dictArray), valueMetaRow, subject["verb"].value ?? "")
                                                    let resulVal = self.resolveCategory(valueByType(subject, dictArray), valueRow, subject["verb"].value ?? "")
                                                    
                                                    if (resultValorMeta && resulVal) || (resultValorMeta || resulVal)
                                                    {   results.append(true)
                                                    }else
                                                    {   results.append(false)   }
                                                    
                                                    break
                                                case "selected":
                                                    let auxValor = dictValor.value(forKey: "valor") as? String ?? ""
                                                    results.append(auxValor == "true" || auxValor == "1" ? true : false)
                                                case "notselected":
                                                    let auxValor = dictValor.value(forKey: "valor") as? String ?? ""
                                                    results.append(auxValor == "false" || auxValor == "0" ? true : false)
                                                case "click":
                                                    let auxId = dictArray.value(forKey: "Acciones") as! NSMutableDictionary
                                                    let id = auxId.value(forKey: "id") as? Int ?? -1
                                                    let auxIdClick = Int(id)
                                                    let idRowClick = Int(string: String(row.cell.clickInRow.split(separator: "-").first ?? "") )
                                                    let idBtnClick = String(row.cell.clickInRow.split(separator: "-").last ?? "")
                                                    if (idRowClick == auxIdClick) && (idBtnClick == subject["subject"].value)
                                                    { results.append(true ) } else { results.append(false)}
                                                default:
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                                if results.count == 0 { rowsOK.remove(at: rowsOK.endIndex) }
                                for result in results{
                                    if result == false{
                                        rowsOK.remove(at: rowsOK.endIndex - 1)
                                        break
                                    }
                                }
                            }
                            if rowsOK.count == 0 { return false }
                            // aqui guardo el arreglo de id que cumplen las condiciones
                            UserDefaults.standard.set(rowsOK, forKey: "ArrayRowsOK")
                            return true
                        }catch{
                            print(error)
                            return false
                        }
                    } else { return false }
                }else{ return false }
            default:
                break;
            }
            break;
        default:
            break;
        }
        
        return false
        
    }
    
    /// Method for resolve parser to Array
    func clearCatalogo (valor:String) -> String
    {
        var aux = valor
        aux = aux.replacingOccurrences(of: "\\\\\"", with: ">>")
        let catalogos = aux.components(separatedBy: "catalogodestino")
        var valAux = ""
        for (index, valorCat) in catalogos.enumerated()
        {   var part = valorCat
            if index != 0
            {   if let index = valorCat.firstIndex(of: "[") {
                    if let index2 = valorCat.firstIndex(of: "]") {  part.replaceSubrange(index...index2, with: [" "])   }
                }
                valAux += "catalogodestino"
            }
            valAux += part
        }
        return valAux
    }
    
    /// Method for resolve condition for element
    /// - Parameter vrbRule: Verb on codition of element in form
    /// - Parameter element: Element id that execute condition
    /// - Parameter subject: Object of condition in rules
    public func resolvingConditionElement( _ vrbRule: String, _ element: String? = nil, _ subject :AEXMLElement) -> Bool {
        switch subject["verb"].value {
            
        // This are actions for the principal element
        case "loaded":
            if element == "formElec_element0" && vrbRule == "loaded"{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "true"))
                return true
            }else{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "false"))
                return false
            }
        case "save":
            if element == "formElec_element0" && vrbRule == "save"{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "true"))
                return true
            }else{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "false"))
                return false
            }
        case "validate":
            if element == "formElec_element0" && vrbRule == "validate"{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "true"))
                return true
            }else{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "false"))
                return false
            }
            
        // Detect if device in use
        case "deviceinuse":
            switch subject["predicate"]["value"].value{
            case "iswebcomp", "isandroid":
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["predicate"]["value"].value ?? "", "false"))
                return false
            case "isios", "iswebmov":
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["predicate"]["value"].value ?? "", "true"))
                return true
            default: break;
            }
            break;
            
        // This are actions for anexos of: Audio, Video, Rostro vivo, Firma, Huella digital, Documento, Imagen //
        case "addanexo":
            if element != nil && element != "formElec_element0" && vrbRule == "addanexo"{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "true"))
                return true
            }else{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "false"))
                return false
            }
        case "removeanexo":
            if element != nil && element != "formElec_element0" && vrbRule == "removeanexo"{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "true"))
                return true
            }else{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "false"))
                return false
            }
        case "replaceanexo":
            if element != nil && element != "formElec_element0" && vrbRule == "replaceanexo"{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "true"))
                return true
            }else{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "false"))
                return false
            }
        case "typifyattach":
            if element != nil && element != "formElec_element0" && vrbRule == "typifyattach"{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "true"))
                return true
            }else{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "false"))
                return false
            }
        case "untypifyattach":
            if element != nil && element != "formElec_element0" && vrbRule == "untypifyattach"{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "true"))
                return true
            }else{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "false"))
                return false
            }
            
        // Finish actions for anexos of: Audio, Video, Rostro vivo, Firma, Huella digital, Documento, Imagen
            
        // Actions in Button
        case "click":
            if element != nil && element != "formElec_element0" && vrbRule == "click"{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "true"))
                return true
            }else{
                ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: vrb:%@ res:%@", subject["verb"].value ?? "", "false"))
                return false
            }
        // Finish actions in Button
            
        // General conditions all elements
        case "visible", "visiblecontenido":
            let res = resolveVisible(subject["subject"].value!, "afirmacion", "true")
            ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: elem:%@ cat:%@ vrb:%@ res:%@", subject["subject"].value ?? "", "afirmacion", subject["verb"].value ?? "", "\(res)"))
            return res
        case "notvisible", "notvisiblecontenido":
            let res = resolveVisible(subject["subject"].value!, "afirmacion", "false")
            ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: elem:%@ cat:%@ vrb:%@ res:%@", subject["subject"].value ?? "", "afirmacion", subject["verb"].value ?? "", "\(res)"))
            return res
        case "enabled":
            let res = resolveHabilitado(subject["subject"].value!, "afirmacion", "true")
            ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: elem:%@ cat:%@ vrb:%@ res:%@", subject["subject"].value ?? "", "afirmacion", subject["verb"].value ?? "", "\(res)"))
            return res
        case "notenabled":
            let res = resolveHabilitado(subject["subject"].value!, "afirmacion", "false")
            ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: elem:%@ cat:%@ vrb:%@ res:%@", subject["subject"].value ?? "", "afirmacion", subject["verb"].value ?? "", "\(res)"))
            return res
        case "empty":
            let res = resolveValor(subject["subject"].value!, "afirmacion", "true", "empty")
            ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: elem:%@ cat:%@ vrb:%@ res:%@", subject["subject"].value ?? "", "afirmacion", subject["verb"].value ?? "", "\(res)"))
            return res
        case "notempty":
            let res = resolveValor(subject["subject"].value!, "afirmacion", "false", "notempty")
            ConfigurationManager.shared.utilities.log(.action, String(format: "Evaluando: elem:%@ cat:%@ vrb:%@ res:%@", subject["subject"].value ?? "", "afirmacion", subject["verb"].value ?? "", "\(res)"))
            return res
        // Finish general conditions all elements
            
        // Conditions Barcode, CodeQR, Password, Slider, Date, Hour, List, Currency, Number, RangeDate, Text, MultiText
        case "contains":
            if subject["predicate"]["mode"].value == "words"
            {
                var values: [String] = []
                var results: [Bool] = []
                if subject["predicate"]["value"].all?.count ?? 0 > 0{
                    for val in subject["predicate"]["value"].all! {
                        values.append(val.value ?? "")
                        results.append(resolveValor(subject["subject"].value!, "afirmacion", val.value ?? "", "contains"))
                    }
                }
                if results.count == 1{
                    return results[0]
                }else{
                    for result in results{
                        if result{ return true }
                    }
                    return false
                }
            } else
            {
                return self.resolveValor(subject["subject"].value ?? "", "afirmacion", self.valueByType(subject), "contains")
            }
        case "notcontains":
            return self.resolveValor(subject["subject"].value ?? "", "afirmacion", self.valueByType(subject), "notcontains")
        // Except List
        case "equals":
            return self.resolveValor(subject["subject"].value ?? "", "afirmacion", self.valueByType(subject), "equals")
        // Except List
        case "notequals":
            return self.resolveValor(subject["subject"].value ?? "", "afirmacion", self.valueByType(subject), "notequals")
        // Finish conditions Barcode, CodeQR, Password, Slider, Date, Hour, List, Currency, Number, RangeDate, Text, MultiText
            
        // Conditions Slider, Currency, Number
        case "may":
            return self.resolveValor(subject["subject"].value ?? "", "afirmacion", self.valueByType(subject), "may")
        case "mayorequal":
            return self.resolveValor(subject["subject"].value ?? "", "afirmacion", self.valueByType(subject), "mayorequal")
        case "men":
            return self.resolveValor(subject["subject"].value ?? "", "afirmacion", valueByType(subject), "men")
        case "menorequal":
            return self.resolveValor(subject["subject"].value ?? "", "afirmacion", valueByType(subject), "menorequal")
        // Finish conditions Slider, Currency, Number
            
        // Conditions List, ListTemp
        case "change":
            if element != nil && element != "formElec_element0" && vrbRule == "change"{
                return true
            }else{  return false    }
        // Finish conditions List, COMBO SERVICES
        
        // Conditions Logic
        case "selected":
            let res = self.resolveSeleccionado(subject["subject"].value!, "afirmacion", "true")
            return res
        case "notselected":
            let res = self.resolveSeleccionado(subject["subject"].value!, "afirmacion", "false")
            return res
        // Finish conditions Logic
        
        // Conditions Tabla
        case "tableshowadd": // (nva captura)
            if element != nil && element != "formElec_element0" && vrbRule == "tableshowadd"{ return true }else{ return false }
        case "editing,multi": // (antes de editar registro)
            if element != nil && element != "formElec_element0" && vrbRule == "editing,multi"{ return true }else{ return false }
        case "tableadd,addclear": // (al agregar registro)
            if element != nil && element != "formElec_element0" && vrbRule == "tableadd,addclear"{ return true }else{ return false }
        case "edit": // (Al terminar edición)
            if element != nil && element != "formElec_element0" && vrbRule == "edit"{ return true }else{ return false }
        case "remove": // (Al borrar registro)
            if element != nil && element != "formElec_element0" && vrbRule == "remove"{ return true }else{ return false }
        // Finish conditions Tabla
        
        // Conditions Wizard
        case "backward":
            if element != nil && element != "formElec_element0" && vrbRule == "backward"{ return true }else{ return false }
        case "forward":
            if element != nil && element != "formElec_element0" && vrbRule == "forward"{
                return true
            }else{ return false }
        case "beforefinish":
            if element != nil && element != "formElec_element0" && vrbRule == "beforefinish"{ return true }else{ return false }
        case "afterfinish":
            if element != nil && element != "formElec_element0" && vrbRule == "afterfinish"{ return true }else{ return false }
        // Finish conditions Wizard
        
        // Conditions Page
        case "showpage":
            for pp in FormularioUtilities.shared.paginasVisibles{
                if element == "" || element == nil {
                    if pp.idelemento == FormularioUtilities.shared.paginasVisibles[self.currentPage].idelemento{ return true }
                }else{
                    if pp.idelemento == element{ return true }
                }
            }
            return false
        // Finish conditions Page
        
        default:
            break;
        }
        return false
    }
    
    // MARK: - RESOLVE ALL ACTIONS
    public func resolvingAllActions(_ actions: AEXMLElement, _ conditionsTable: [AEXMLElement]? = nil) -> Int?{
        
        var actionOrder = 0
        while actionOrder < actions.children.count{
            for action in actions.children{
                if (action["order"].value == nil){ continue }
                if Int(action["order"].value!) == actionOrder{
                    if let condTable: [AEXMLElement] = conditionsTable {
                        let res = resolveAction(action, condTable)
                        if res != nil && res == 400{
                            return res
                        }
                    } else {
                        let res = resolveAction(action)
                        if res != nil && res == 400{
                            return res
                        }
                    }
                    actionOrder += 1
                }
            }
            UserDefaults.standard.removeObject(forKey: "ArrayRowsOK")
        }
        return nil
    }
    
    // MARK: - RESOLVE ACTION
    public func resolveAction(_ condition: AEXMLElement, _ conditionTable: [AEXMLElement]? = nil) -> Int?{

        switch condition["verb"].value{
        //Section
        case "habilitarseccion":
            if condition["negation"].value == "true"
            {
                for child in condition["subject"].children{
                    let _ = resolveHabilitado(child.name, "asignacion", "false")
                }
            } else
            {
                for child in condition["subject"].children{
                    let _ = resolveHabilitado(child.name, "asignacion", "true")
                }
            }
            break;
            
        case "asmodal":
            if condition["negation"].value == "true"{
                self.dismiss(animated: true, completion: nil)
                break;
            }
            if condition["subject"].children.count > 0 {
                self.obtainModal(condition["subject"].children[0].name)
                    .then { resolve in
                        print(resolve)
                    }.catch { error in
                        print(error)
                    }
            }
            break;
            
        //Audio, Botón, CalculFina, CodBarras, QR, ComboTemp, Passw, Slider, Docto, Date, Firma, Georef, Hour, HuellaDig, Image, Leyenda, List, Logic, Logo, Currency, Number, Page, Pestañas, RangeDate, RostroV, Section, Table, Text, MultiText, Video, Wizard
        case "visible":
            for child in condition["subject"].children{
                let _ = resolveVisible(child.name, "asignacion", "true")
            }
            break;
        case "notvisible":
            for child in condition["subject"].children{
                let _ = resolveVisible(child.name, "asignacion", "false")
            }
            break;
        //Audio, Botón, CalculFina, CodBarras, QR, Passw, Slider, Docto, Date, Firma, Georef, Hour, HuellaDig, Image, Leyenda, List, Logic, Logo, Currency, Number, RangeDate, RostroV, Table, Text, MultiText, Video, Wizard
        case "visiblecontenido":
            for child in condition["subject"].children{
                let _ = resolveVisible(child.name, "asignacion", "true")
            }
            break;
        case "notvisiblecontenido":
            for child in condition["subject"].children{
                let _ = resolveVisible(child.name, "asignacion", "false")
            }
            break;
            
            
        //Audio, Botón, CodBarras, QR, Passw, Slider, Docto, Date, Firma, Georef, Hour, HuellaDig, Image, List, Logic, Currency, Number, Page, RangeDate, RostroV, Text, MultiText, Video, Wizard
        case "enabled":
            for child in condition["subject"].children{
                let _ = resolveHabilitado(child.name, "asignacion", "true")
            }
            break;
        case "notenabled":
            for child in condition["subject"].children{
                let _ = resolveHabilitado(child.name, "asignacion", "false")
            }
            break;
            
        //Audio, CodBarras, QR, Passw, Slider, Docto, Date, Firma, Georef, Hour, HuellaDig, Image,  Leyenda, List, Logic, Currency, Number, RangeDate, RostroV, Tabla, Text, MultiText, Video
        case "required":
            for child in condition["subject"].children{
                let _ = resolveRequerido(child.name, "asignacion", "true")
            }
            break;
        case "notrequired":
            for child in condition["subject"].children{
                let _ = resolveRequerido(child.name, "asignacion", "false")
            }
            break;
            
        //Pop up & Avisos
        case "showmessage":
            let predicate = condition["predicate"].value
            _ = condition["order"].value
            
            let attributes = xmlParsed.atributos as? Atributos_plantilla
            switch condition["subject"].children.first?.name{
            case "popuperror":
                let bg = UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertaerror ?? "#D93829", alpha: 1.0)
                let txt = UIColor(hexFromString: self.atributosPlantilla?.colortextoalertaerror ?? "#FFFFFF", alpha: 1.0)
                let popup = DangerAlertViewController()
                popup.show(in: self, title: "\(attributes?.titulo ?? "")", description: "\(predicate ?? "")", textButton: "alrt_ok".langlocalized(), imageAlert: UIImage(named: "warning_sign", in: Cnstnt.Path.framework, compatibleWith: nil), colorBanner: bg, colorButton: bg, colorText: txt)
                break;
            case "popupalert":
                let bg = UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertaadvertencia ?? "#FFD500", alpha: 1.0)
                let txt = UIColor(hexFromString: self.atributosPlantilla?.colortextoalertaadvertencia ?? "#FFFFFF", alpha: 1.0)
                let popup = DangerAlertViewController()
                popup.show(in: self, title: "\(attributes?.titulo ?? "")", description: "\(predicate ?? "")", textButton: "alrt_ok".langlocalized(), imageAlert: UIImage(named: "warning_alert", in: Cnstnt.Path.framework, compatibleWith: nil), colorBanner: bg, colorButton: bg, colorText: txt)
                break;
            case "popupinfo":
                let bg = UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertainfo ?? "#3C3CCC", alpha: 1.0)
                let txt = UIColor(hexFromString: self.atributosPlantilla?.colortextoalertainfo ?? "#FFFFFF", alpha: 1.0)
                let popup = DangerAlertViewController()
                popup.show(in: self, title: "\(attributes?.titulo ?? "")", description: "\(predicate ?? "")", textButton: "alrt_ok".langlocalized(), imageAlert: UIImage(named: "info_alert", in: Cnstnt.Path.framework, compatibleWith: nil), colorBanner: bg, colorButton: bg, colorText: txt)
                break;
            case "notiferror":
                let bg = UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertaerror ?? "", alpha: 1.0)
                let txt = UIColor(hexFromString: self.atributosPlantilla?.colortextoalertaerror ?? "", alpha: 1.0)
                setNotificationBanner("\(attributes?.titulo ?? "")", "\(predicate ?? "")", .danger, bg, txt)
                break;
            case "notifalert":
                let bg = UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertaadvertencia ?? "", alpha: 1.0)
                let txt = UIColor(hexFromString: self.atributosPlantilla?.colortextoalertaadvertencia ?? "", alpha: 1.0)
                setNotificationBanner("\(attributes?.titulo ?? "")", "\(predicate ?? "")", .warning, bg, txt)
                break;
            case "notifinfo":
                let bg = UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertainfo ?? "", alpha: 1.0)
                let txt = UIColor(hexFromString: self.atributosPlantilla?.colortextoalertainfo ?? "", alpha: 1.0)
                setNotificationBanner("\(attributes?.titulo ?? "")", "\(predicate ?? "")", .info, bg, txt)
                break;
            default: break;
            }
            break;
            
        //Sin sujeto/elemento
        case "cancel":
            if condition["validate"].error != nil
            {
                self.dismiss(animated: true, completion: nil)
                break;
            }else if condition["save"].error != nil{
                self.dismiss(animated: true, completion: nil)
                break;
            }
            break;
            
        // Wizard, Table
        case "execute":
            switch condition["predicate"].children.first?.name ?? "" {
            case "clear": //limpiar
                let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
                if row is TablaRow
                {
                    let tableCell = (row as? TablaRow)?.cell
                    if tableCell == nil { break }
                    tableCell?.viewController?.executeClear()
                }
                break;
            case "tableshowadd": //modocaptura
                let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
                if row is TablaRow
                {
                    let tableCell = (row as? TablaRow)?.cell
                    if tableCell == nil { break }
                    tableCell?.executeTableShowAdd()
                }
                break;
            case "tableadd": //agregar sin cerrar captura
                let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
                if row is TablaRow
                {
                    let tableCell = (row as? TablaRow)?.cell
                    if tableCell == nil { break }
                    tableCell?.viewController?.executeTableAdd()
                }
                break;
            case "addclear": //agregar y cerrar captura
                let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
                if row is TablaRow
                {
                    let tableCell = (row as? TablaRow)?.cell
                    if tableCell == nil { break }
                    tableCell?.viewController?.executeAddClear()
                }
                break;
            case "closeclear": //cerrar y limpiar captura
                let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
                if row is TablaRow
                {
                    let tableCell = (row as? TablaRow)?.cell
                    if tableCell == nil { break }
                    tableCell?.viewController?.executeCloseClear()
                }
                break;
            case "forward": //avanzar
                let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
                if row is WizardRow
                {
                    let wizardCell = (row as? WizardRow)?.cell
                    if wizardCell == nil { break }
                    wizardCell?.executeForward()
                }
                break;
            case "backward": //regresar
                let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
                if row is WizardRow
                {
                    let wizardCell = (row as? WizardRow)?.cell
                    if wizardCell == nil { break }
                    wizardCell?.executeBackward()
                }
                break;
            case "finish": //finalizar
                let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
                if row is WizardRow
                {
                    let wizardCell = (row as? WizardRow)?.cell
                    if wizardCell == nil { break }
                    wizardCell?.executeFinish()
                    return 400
                }
                break;
            default:
                break;
            }
            break;
            
        //Service
        case "executeservice":
            hud.show(in: self.view)
            for service in condition["subject"].children {
                if FormularioUtilities.shared.services?.root[service.name]["id"].value != nil
                {
                    self.servicioGenerico(service.name)
                } else
                {
                    self.servicioGenericoJSON(service.name)
                }
                
            }
            break;
            
        //Components
        case "executecomponent":
            for component in condition["subject"].children{
                self.obtainComponents(component.name)
            }
            break;
            
        // Rules
        case "executerule":
            let checkCondition = condition["predicate"].value ?? ""
            let rule = condition["subject"].children.first?.name ?? ""
            if checkCondition == "true" {
                _ = self.obtainRules(rString: rule, eString: nil, vString: nil, forced: false, override: false)
            } else {
                _ = self.obtainRules(rString: rule, eString: nil, vString: nil, forced: true, override: true)
            }
            break
            
        //Section, Page
        case "showpagetabber":
            for pageTab in condition["subject"].children{
                var button: UIButton?
                for (index, pagina) in FormularioUtilities.shared.paginasVisibles.enumerated(){
                    if pageTab.name == pagina.idelemento{
                        pagina.visible = true;
                        pagina.habilitado = true;
                        self.pagesScrollView.subviews.forEach({
                            if $0.isKind(of: UIButton.self){
                                if $0.tag == index{
                                    button = $0 as? UIButton
                                }
                            }
                        })
                    }
                }
                self.reloadPages()
                self.segmentSelected(button)
            }
            break;
            
        // Firma FAD, Marcadodocumentos
        case "showanimation":
            let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
            if row is MarcadoDocumentoRow
            {
                let marcadoCell = (row as? MarcadoDocumentoRow)?.cell
                if marcadoCell == nil { break }
                marcadoCell?.executeAnimation()
            } else if row is FirmaFadRow
            {
                let firmaCell = (row as? FirmaFadRow)?.cell
                if firmaCell == nil { break }
                firmaCell?.executeAnimation()
            }
            break;
        //Only FAD
        case "getfaddata":
            for idFirma in condition["subject"].children {
                let row = self.getElementByIdInAllForms(idFirma.name)
                if row is FirmaFadRow
                {
                    let firmaCell = (row as? FirmaFadRow)?.cell
                    if firmaCell == nil { break }
                    firmaCell?.saveValuesFAD()
                }
            }
            break;
            
        case "changesigntext":
            switch condition["predicate"]["mode"].value {
            case "words":
                let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", condition["predicate"]["value"].value ?? "", "terminos")
                break;
            case "element":
                if let idElem = condition["predicate"]["value"].value {
                    let valorElem : String = self.valueElementRow(idElem)
                    if valorElem != "" {
                        let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", valorElem, "terminos")
                    }
                }
                break;
            default:
                break;
            }
            break;
            
        // Text, MultiText
        case "multiplevalue":
            for sub in condition["subject"].children{
                switch condition["predicate"]["mode"].value {
                case "words":
                    let _ = resolveValor(sub.name, "asignacion", condition["predicate"]["value"].value ?? "")
                    break;
                case "varusr":
                    if let varusrTxt = condition["predicate"]["value"].value
                    {   let valorVar : String = self.valueVarUsr(varusrTxt)
                        if valorVar != ""   {
                            let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", valorVar) }
                    }
                    break;
                case "element":
                    if let idElem = condition["predicate"]["value"].value
                    {   let valorElem : String = self.valueElementRow(idElem)
                        if valorElem != ""   {
                            let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", valorElem) }
                    }
                    break;
                default:
                    break;
                }
            }
            break;
            
        // Maths operations
        case "operationon":
            for service in condition["subject"].children{
                if condition["negation"].value == "false" || condition["negation"].value == nil {
                    FormularioUtilities.shared.mathematics?.root[service.name]["enabled"].value = "true"
                    self.obtainMathematics(service.name, true)
                }else{
                    FormularioUtilities.shared.mathematics?.root[service.name]["enabled"].value = "false"
                }
            }
            break;
            
        case "operationexe":
            for service in condition["subject"].children{
                self.obtainMathematics(service.name, true)
            }
            break;
            
        // Wizard
        case "changeformat":
            // Cambiar plantilla para abrir
            let newPlant = condition["predicate"].children.first?.name ?? ""
            if newPlant != ""{
                let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
                if row is WizardRow
                {
                    let wizardCell = (row as? WizardRow)?.cell
                    if wizardCell == nil { break }
                    wizardCell?.atributos?.plantillaabrir = newPlant
                }
            }
            break;
            
        // Wizard set user assigned
        case "reassignuser":
            let reassign = condition["predicate"].children.first?.name ?? ""
            let value = self.valueElementRow(reassign)
            if reassign != ""{
                let row = self.getElementByIdInAllForms(condition["subject"].children.first?.name ?? "")
                if row is WizardRow
                {
                    let wizardCell = (row as? WizardRow)?.cell
                    if wizardCell == nil { break }
                    wizardCell?.atributos?.usuarioasignar = value
                }
            }
            break;
            
        // Prefill
        case "localprefill":
            // Ejecutar prellenado local
            break;
            
        // Mapeo de PDF
        case "downloadFE":
            hud.show(in: self.view)
            for service in condition["subject"].children{
                for map in FormularioUtilities.shared.pdfmapping!.root.children{
                    if service.name == map.name{
                        self.servicioPDF(service.name, "download\(map["downloadtype"].value ?? "")", "\(map["filename"].value ?? "")")
                    }
                }
                
            }
            break;
            
        case "previewFE":
            hud.show(in: self.view)
            for service in condition["subject"].children{
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                    self.servicioPDF(service.name, "preview", "")
                }
            }
            break;
            
        case "downloadDoc":
            hud.show(in: self.view)
            for service in condition["subject"].children{
                self.servicioPDFpublicado(service.name)
            }
            break;
            
        //Georeferencia
        case "coordenadas":
            let element = getElementANY(condition["subject"].children.first?.name ?? "")
            if(element.element != nil){
                switch element.type{
                case "georeferencia":
                    let botonrow: MapaRow = element.kind as! MapaRow
                    botonrow.cell.ruleCoord = true
                    botonrow.cell.btnCallPosicionAction()
                    break
                default:
                    let auxCoord = self.obtainerLocation()
                    let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", auxCoord )
                    self.valueRuleCoor = auxCoord
                    break
                }
            }
            break;
            
        // Plantilla
        case "changemapping":
            break;
            
        case "mappingon":
            for subject in condition["subject"].children
            {
                if condition["negation"].value == "true" {
                    if let index = self.arrayArchivesOn.firstIndex(of: subject.name) {
                        self.arrayArchivesOn.remove(at: index)
                    }
                }else{
                    if !self.arrayArchivesOn.contains(subject.name)
                    {
                        self.arrayArchivesOn.append(subject.name)
                    }
                }
                
            }
            break;
            
        // Button
        case "clicbutton":
            for subject in condition["subject"].children{
                let valueElem = subject.name
                let row = self.getElementByIdInAllForms("\(valueElem)")
                if row == nil{ break; }
                switch row{
                case is WizardRow:
                    FormularioUtilities.shared.rulesAfterWizard.append(condition)
                    break;
                case is BotonRow:
                    (row as? BotonRow)?.cell.triggerRulesOnChange("click")
                    break;
                default: break;
                }
            }
            break;
            
        case "changebuttonurl":
            let element = getElementANY(condition["subject"].children.first?.name ?? "")
            if(element.element != nil){
                if let predicate = condition["predicate"].value{
                    if !predicate.isEmpty{
//                        let botonrow: BotonRow = element.kind as! BotonRow
//                        botonrow.cell.setURLlink(predicate)
//                        botonrow.cell.triggerRulesOnChange("click")
                    }

                }

            }
        break;
            
        //List
        case "filterlist":
            switch condition["predicate"]["mode"].value {
            case "words":
                let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", condition["predicate"]["value"].value ?? "", "filterlist")
                break;
            case "cat":
                let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", condition["predicate"]["value"].value ?? "", "filterlist")
                break;
            case "element":
                if let idElem = condition["predicate"]["value"].value
                {   let valorElem : String = self.valueElementRow(idElem)
                    if valorElem != ""   {
                        let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", valorElem, "filterlist") }
                }
                break;
            default: break;
            }
            break;
            
        // All element's input
        case "value":
            switch condition["predicate"]["mode"].value {
            case "words":
                let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", condition["predicate"]["value"].value ?? "")
                break;
            case "varusr":
                var concat = ""
                if condition["predicate"]["value"].all?.count == 0{ break; }
                for val in condition["predicate"]["value"].all!{
                    if let varusrTxt = val.value{
                        let valorVar : String = self.valueVarUsr(varusrTxt)
                        if valorVar != "" {
                            if concat == ""{
                                concat += valorVar
                            }else{
                                concat += " \(valorVar)"
                            }
                            
                        }
                    }
                }
                let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", concat)
                break;
            case "element":
                if let idElem = condition["predicate"]["value"].value
                {   let valorElem : String = self.valueElementRow(idElem)
                    if valorElem != ""   {
                        let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", valorElem)
                    } else if (UserDefaults.standard.object(forKey: "ArrayRowsOK") != nil)
                    {   let rowsok : [Int] = UserDefaults.standard.object(forKey: "ArrayRowsOK") as? [Int] ?? [Int]()
                        if let condTable: [AEXMLElement] = conditionTable {
                            for conditionT in condTable {
                                if (conditionT["tableidelem"].value != nil) {
                                    let tabla = getElementANY(conditionT["tableidelem"].value ?? "")
                                    let row: TablaRow = tabla.kind as! TablaRow
                                    do{
                                        let arrayDictionary = try JSONSerializer.toArray(row.value!)
                                        rowsok.forEach { id in
                                            for keyArray in arrayDictionary
                                            {   let dictArray = keyArray as! NSMutableDictionary
                                                let dataRow = dictArray["Acciones"] as? NSMutableDictionary ?? NSMutableDictionary()
                                                if (dataRow["id"] as? Int ?? -1) == id
                                                {   let valorElem = (dictArray[idElem] as? NSMutableDictionary ?? NSMutableDictionary())
                                                    if valorElem.count > 0
                                                    {   let valorElem : String = valorElem["valormetadato"] as? String ?? ""
                                                        if valorElem != ""   {
                                                            let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", valorElem) }
                                                    }
                                                }
                                            }
                                        }
                                    }catch{
                                        print(error)
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                break;
            default:
                break;
            }
            break;
            
        case "validate":
            // Getting all elements to validate
            var elements:[BaseRow] = []
            if condition["subject"].children.count == 0{ break; }
            for element in condition["subject"].children{
                let elemData = getElementANY(element.name)
                let row = elemData.kind
                elements.append(row as! BaseRow)
            }
            if elements.count == 0{ break }
            elementsForValidate = [String]()
            validationRowsForm(nil, elements)
            if elementsForValidate.count > 0{
                let path = self.elementsForValidate.first
                let indexPath: IndexPath? = self.form.rowBy(tag: "\(path ?? "")")?.indexPath
                for validate in self.elementsForValidate{
                    _ = self.form.rowBy(tag: "\(validate)")?.validate()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                    if indexPath != nil{
                        self.tableView.scrollToRow(at: indexPath ?? IndexPath(row: 0, section: 0), at: .top, animated: true)
                        self.tableView.selectRow(at: indexPath ?? IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
                    }
                    let bannerNew = NotificationBanner(title: "alrt_warning".langlocalized(), subtitle: "not_form_fill".langlocalized(), leftView: nil, rightView: self.warningView, style: .warning, colors: nil)
                    bannerNew.show()
                }
            }
            break;
            
        case "permisotablaeditarr", "permisotablaeliminarr", "permisotablaagregarr", "permisotablaseleccionarr", "permisotablaagregarcerrarr", "permisotablalimpiar", "permisotablamostrar", "permisotablacerrar", "notpermisotablaeditarr", "notpermisotablaeliminarr", "notpermisotablaagregarr", "notpermisotablaseleccionarr", "notpermisotablaagregarcerrarr", "notpermisotablalimpiar", "notpermisotablamostrar", "notpermisotablacerrar":
            let _ = resolveTablePermissions(condition["subject"].children.first?.name ?? "", "asignacion", condition["verb"].value!)
            break;
            
        // TABLA: filas/columnas en tablas
        case "exportdatabyrow":
            print("\(condition["subject"].children.first?.name ?? "") de exportdatabyrow")//row.cell.clickInRow
            switch condition["predicate"]["mode"].value {
            case "words":
                break;
            case "varusr":
                break;
            case "element":
                if let idElem = condition["predicate"]["value"].value
                {   if let condTable: [AEXMLElement] = conditionTable
                    {   for conditionT in condTable
                        {   if (conditionT["tableidelem"].value != nil)
                            {
                                let tabla = getElementANY(conditionT["tableidelem"].value ?? "")
                                let row: TablaRow = tabla.kind as! TablaRow
                                do{
                                    let arrayDictionary = try JSONSerializer.toArray(row.value!)
                                    if row.cell.clickInRow == "" && (UserDefaults.standard.object(forKey: "ArrayRowsOK") != nil)
                                    {
                                        let rowsok : [Int] = UserDefaults.standard.object(forKey: "ArrayRowsOK") as? [Int] ?? [Int]()
                                        var dictArray = NSMutableDictionary()
                                        for keyArray in arrayDictionary
                                        {   let dictArrayOK = keyArray as! NSMutableDictionary
                                            let dataRow = dictArrayOK["Acciones"] as? NSMutableDictionary ?? NSMutableDictionary()
                                            if (dataRow["id"] as? Int ?? -1) == (rowsok.first ?? 0) {   dictArray = dictArrayOK }
                                        }
                                        let valores = (dictArray[idElem] as? NSMutableDictionary ?? NSMutableDictionary())
                                        let valorElem : String = valores["valormetadato"] as? String ?? ""
                                        if valorElem != ""   { let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", valorElem) }
                                    } else {
                                        for keyArray in arrayDictionary
                                        {   let dictArray = keyArray as! NSMutableDictionary
                                            let valorElem = (dictArray[idElem] as? NSMutableDictionary ?? NSMutableDictionary())
                                            if valorElem.count > 0
                                            {   let valorElem : String = valorElem["valormetadato"] as? String ?? ""
                                                if valorElem != ""   {
                                                    let _ = resolveValor(condition["subject"].children.first?.name ?? "", "asignacion", valorElem) }
                                            }
                                        } }
                                }catch{
                                    print(error)
                                    break;
                                }
                            }
                        }
                    }
                }
                break;
            default:
                break;
            }
            break;
        case "multiedit":
            break;
            
        case "hidecolumnbyrow":
            if let condTable: [AEXMLElement] = conditionTable {
                for conditionT in condTable {
                    if (conditionT["tableidelem"].value != nil) {
                        let tabla = getElementANY(conditionT["tableidelem"].value ?? "")
                        let row: TablaRow = tabla.kind as! TablaRow
                        if tabla.type == "tabla" {
                            let idsOk : [Int] = UserDefaults.standard.object(forKey: "ArrayRowsOK") as? [Int] ?? [Int]()
                            var rowsOk : [Int] = []
                            for (index, value) in row.cell.recordsVisibles.enumerated()
                            {
                                do{
                                    let arrayDictionary = try JSONSerializer.toArray("[\(String(value.json))]")
                                    let dictArray = (arrayDictionary[0] as! NSMutableDictionary)["Acciones"] as? NSMutableDictionary ?? NSMutableDictionary()
                                    if idsOk.contains(dictArray["id"] as? Int ?? -1)
                                    {   rowsOk.append(index)   }
                                }catch{ print("Error en hidecolumnbyrow")    }
                            }
                            if !rowsOk.isEmpty
                            {   for subject in condition["subject"].children{
                                    row.cell.columnByRowHidden.setValue(rowsOk, forKey: subject.name)
                                    row.cell.reloadDesign()
                                }
                            }
                        }
                    }
                }
            }
            break;
            
        case "hiderow":
            let element = condition["subject"].children.first?.name ?? ""
            if element == ""{ break }
            let tabla = getElementANY(element)
            if tabla.type == "tabla"
            {
                let row: TablaRow = tabla.kind as! TablaRow
                if !row.cell.records.isEmpty
                {
                    if let condTable: [AEXMLElement] = conditionTable
                    {
                        for condition in condTable {
                            for subject in condition["subject"].children{
                                if (subject["subject"].value == nil){ continue }
                                print(subject)
                                
                                if (UserDefaults.standard.object(forKey: "ArrayRowsOK") != nil)
                                {
                                    row.cell.recordsHide = UserDefaults.standard.object(forKey: "ArrayRowsOK") as? [Int] ?? [Int]()
                                    row.cell.reloadDesign()
                                } else
                                {
                                    if condition["rowtype"].value == "byallrows"
                                    {
                                        row.cell.recordsHide = [9999]
                                        row.cell.reloadDesign()
                                    } else
                                    {
                                        if self.valuesAllRowsTable(valueTable: row.cell.records, condition: condition, isAll: false)
                                        {
                                            row.cell.recordsHide = UserDefaults.standard.object(forKey: "ArrayRowsOK") as? [Int] ?? [Int]()
                                            row.cell.reloadDesign()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            break;
        
        case "hidecolumn":
            let tabla = getElementANY(condition["subject"].children.first!.name)
            if tabla.type == "tabla"{
                let row: TablaRow = tabla.kind as! TablaRow
                var columnvisual: [String:Any] = [:]
                for (key,value) in row.cell.atributos?.columnasvisualizar ?? [:]
                {
                    if condition["negation"].value == "true" {
                        columnvisual[key] = condition["predicate"].children.contains(where: {($0 as AEXMLElement).name  == key}) ? "true" : value
                    }else{
                        columnvisual[key] = condition["predicate"].children.contains(where: {($0 as AEXMLElement).name  == key}) ? "false" : value
                    }
                }
                row.cell.atributos?.columnasvisualizar = columnvisual
                row.cell.reloadDesign()
            }
            break;
            
        case "allowedit":
            let tabla = getElementANY(condition["subject"].children.first!.name)
            if tabla.type == "tabla"
            {
                let row: TablaRow = tabla.kind as! TablaRow
                let idsOk : [Int] = UserDefaults.standard.object(forKey: "ArrayRowsOK") as? [Int] ?? [Int]()
                let isOverrided = (conditionTable?.first?.name == "isOverrided") ? true : false
                
                if !idsOk.isEmpty || isOverrided
                {
                    var newRowsEdit: [Int] = [Int]()
                    for (index, value) in row.cell.recordsVisibles.enumerated()
                    {
                        do{
                            let arrayDictionary = try JSONSerializer.toArray("[\(String(value.json))]")
                            let dictArray = (arrayDictionary[0] as! NSMutableDictionary)["Acciones"] as? NSMutableDictionary ?? NSMutableDictionary()
                            if condition["negation"].value == "true" {
                                // oculta lápiz
                                if !idsOk.contains(dictArray["id"] as? Int ?? -1) || isOverrided
                                {   newRowsEdit.append(index)   }
                            }else{
                                // muestra lápiz
                                if idsOk.contains(dictArray["id"] as? Int ?? -1) || isOverrided
                                {   newRowsEdit.append(index)   }
                            }
                        }catch{ print("Error en allowedit")    }
                    }
                    if row.cell.recordsEdit != newRowsEdit {
                        row.cell.recordsEdit = newRowsEdit
                        row.cell.reloadDesign()
                    }
                }
            }
            break;
        case "allowdelete":
            let tabla = getElementANY(condition["subject"].children.first!.name)
            if tabla.type == "tabla"
            {
                let row: TablaRow = tabla.kind as! TablaRow
                let idsOk : [Int] = UserDefaults.standard.object(forKey: "ArrayRowsOK") as? [Int] ?? [Int]()
                let isOverrided = (conditionTable?.first?.name == "isOverrided") ? true : false
                
                if !idsOk.isEmpty || isOverrided
                {
                    var newRowsDelete: [Int] = [Int]()
                    for (index, value) in row.cell.recordsVisibles.enumerated()
                    {
                        do{
                            let arrayDictionary = try JSONSerializer.toArray("[\(String(value.json))]")
                            let dictArray = (arrayDictionary[0] as! NSMutableDictionary)["Acciones"] as? NSMutableDictionary ?? NSMutableDictionary()
                            if condition["negation"].value == "true" {
                                // oculta basurero
                                if !idsOk.contains(dictArray["id"] as? Int ?? -1) || isOverrided
                                {   newRowsDelete.append(index)   }
                            }else{
                                // muestra basurero
                                if idsOk.contains(dictArray["id"] as? Int ?? -1) || isOverrided
                                {   newRowsDelete.append(index)   }
                            }
                        }catch{ print("Error en allowdelete")    }
                    }
                    if row.cell.recordsDelete != newRowsDelete {
                        row.cell.recordsDelete = newRowsDelete
                        row.cell.reloadDesign()
                    }
                }
            }
            break;
        case "allowselect":
            let tabla = getElementANY(condition["subject"].children.first!.name)
            if tabla.type == "tabla"
            {
                let row: TablaRow = tabla.kind as! TablaRow
                let idsOk : [Int] = UserDefaults.standard.object(forKey: "ArrayRowsOK") as? [Int] ?? [Int]()
                let isOverrided = (conditionTable?.first?.name == "isOverrided") ? true : false
                
                if !idsOk.isEmpty || isOverrided
                {
                    var newRowsSelect : [Int] = [Int]()
                    for (index, value) in row.cell.recordsVisibles.enumerated()
                    {
                        do{
                            let arrayDictionary = try JSONSerializer.toArray("[\(String(value.json))]")
                            let dictArray = (arrayDictionary[0] as! NSMutableDictionary)["Acciones"] as? NSMutableDictionary ?? NSMutableDictionary()
                            if condition["negation"].value == "true" {
                                // no se puede seleccionar
                                if !idsOk.contains(dictArray["id"] as? Int ?? -1) || isOverrided
                                {   newRowsSelect.append(index)   }
                            }else{
                                // se puede seleccionar
                                if idsOk.contains(dictArray["id"] as? Int ?? -1) || isOverrided
                                {   newRowsSelect.append(index)   }
                            }
                        }catch{ print("Error en allowselect")    }
                    }
                    if row.cell.recordsSelect != newRowsSelect {
                        row.cell.recordsSelect = newRowsSelect
                        row.cell.reloadDesign()
                    }
                }
            }
            break;
        default: break;
        }
        return nil
    }
    
    
    
    public func valuesAllRowsTable(valueTable : [(record: Int, json: String)], condition : AEXMLElement, isAll : Bool) -> Bool
    {
        var dictArray = Array<String>()
        for record in valueTable{ dictArray.append(record.json) }
        do{
            let options = JSONSerialization.WritingOptions(rawValue: 0)
            let data = try JSONSerialization.data(withJSONObject: dictArray, options: options)
            if var string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                string = string.replacingOccurrences(of: "\"{", with: "{") as NSString
                string = string.replacingOccurrences(of: "}}\"", with: "}}") as NSString
                string = string.replacingOccurrences(of: "\\\"", with: "\"") as NSString
                
                let arrayRows = try JSONSerializer.toArray(string as String)
                var rowsOK = [Int]()
                for rowArray in arrayRows
                {
                    let elementsRow = rowArray as! NSMutableDictionary
                    var results = [Bool]()
                    for subject in condition["subject"].children
                    {   if (subject["subject"].value != nil)
                        {
                            if (elementsRow.value(forKey: (subject["subject"].value) ?? "") != nil)
                            {
                                let valuesElem = elementsRow.value(forKey: (subject["subject"].value) ?? "") as! NSMutableDictionary
                                switch subject["verb"].value
                                {
                                    case "empty","notempty" :
                                        results.append(self.resolveCategory("", valuesElem.value(forKey: "valor") as? String ?? "", subject["verb"].value ?? ""))
                                        break
                                    case "contains","notcontains", "equals", "notequals", "may" , "mayorequal", "men", "menorequal":
                                        
                                        var valueRow = valuesElem.value(forKey: "valor") as? String ?? ""
                                        if (valueRow.count == 12 || valueRow.count == 27) && valueRow.contains("\\/")
                                        {
                                            valueRow = valueRow.replacingOccurrences(of: "\\/", with: "/")
                                            valueRow = valueRow.replacingOccurrences(of: "-", with: "a")
                                        }
                                        results.append(self.resolveCategory(valueByType(subject, elementsRow), valueRow, subject["verb"].value ?? ""))
                                        break
                                    case "selected":
                                        let auxValor = valuesElem.value(forKey: "valor") as? String ?? ""
                                        results.append(auxValor == "true" ? true : false)
                                    case "notselected":
                                        let auxValor = valuesElem.value(forKey: "valor") as? String ?? ""
                                        results.append(auxValor == "false" ? true : false)
                                    default:
                                        break
                                }
                            }
                        }
                    }
                    if isAll
                    {   if results.count == 0 { return false }
                        for result in results {
                            if result == false {    return false    }
                        }
                    } else
                    {   var cumple = true
                        for result in results {
                            if result == false {    cumple = false  }   }
                        if cumple && results.count > 0
                        {   if (elementsRow.value(forKey: "Acciones") != nil)
                            {   let auxValues = elementsRow.value(forKey: "Acciones") as! NSMutableDictionary
                                let id = auxValues.value(forKey: "id") as? Int ?? 0
                                rowsOK.append(id)
                            }
                        }
                    }
                }
                if !isAll {
                    if rowsOK.count == 0 { return false }
                    UserDefaults.standard.set(rowsOK, forKey: "ArrayRowsOK") // aqui guardo el arreglo de id que cumplen las condiciones
                    return true
                }
                return true
            }
        }catch { return false }
        return false
    }
    
    /// Method for obtain value of element in template
    /// - Parameter idElem:  Element id in forms
    public func valueElementRow (_ idElem: String ) -> String
    {
        let row = self.getElementByIdInAllForms("\(idElem)")
        var value = ""
        switch row{
        case is TextoRow:
            value = (row as? TextoRow)?.value ?? ""; break;
        case is TextoAreaRow:
            value = (row as? TextoAreaRow)?.value ?? ""; break;
        case is NumeroRow:
            value = (row as? NumeroRow)?.value ?? ""; break;
        case is MonedaRow:
            value = (row as? MonedaRow)?.value ?? ""; break;
        case is FechaRow:
            if (row as? FechaRow)?.cell.atributos != nil{
                value = (row as? FechaRow)?.cell.getValueFecha() ?? ""
            }else if (row as? FechaRow)?.cell.atributosHora != nil{
                value = (row as? FechaRow)?.cell.getValueHora() ?? ""
            }
            break;
        case is WizardRow: break;
        case is BotonRow: break;
        case is LogoRow: break;
        case is LogicoRow:
            value = (row as? LogicoRow)?.cell.getValueString() ?? ""; break;
        case is EtiquetaRow:
            value = (row as? EtiquetaRow)?.value ?? "";break;
        case is RangoFechasRow:
            value = (row as? RangoFechasRow)?.value ?? ""; break;
        case is SliderNewRow:
            value = (row as? SliderNewRow)?.value ?? ""; break;
        case is ListaRow:
            value = (row as? ListaRow)?.cell.elemento.validacion.valor ?? ""; break;
        case is ComboDinamicoRow:
            if plist.idportal.rawValue.dataI() >= 40 {
                value = (row as? ComboDinamicoRow)?.cell.elemento.validacion.valor ?? ""; break;
            }
        case is ListaTemporalRow: break;
        case is HeaderTabRow: break;
        case is HeaderRow: break;
        case is TablaRow:
            value = (row as? TablaRow)?.value ?? ""; break;
        case is MarcadoDocumentoRow:
            if plist.idportal.rawValue.dataI() >= 41 {
                value = (row as? ListaRow)?.cell.elemento.validacion.valormetadato ?? ""; break;
            }
        case is CodigoBarrasRow:
            value = (row as? CodigoBarrasRow)?.value ?? ""; break;
        case is CodigoQRRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                value = (row as? CodigoQRRow)?.value ?? ""; break;
            }
        case is EscanerNFCRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                value = (row as? EscanerNFCRow)?.value ?? ""; break;
            }
        case is CalculadoraRow: break;
        case is AudioRow:
            value = (row as? AudioRow)?.value ?? ""; break;
        case is FirmaRow:
            value = (row as? FirmaRow)?.value ?? ""; break;
        case is FirmaFadRow:
            if plist.idportal.rawValue.dataI() >= 39{
                value = (row as? FirmaFadRow)?.value ?? ""; break;
            }
        case is MapaRow:
            value = (row as? MapaRow)?.value ?? ""; break;
        case is DocumentoRow:
            value = (row as? DocumentoRow)?.value ?? ""; break;
        case is ImagenRow:
            value = (row as? ImagenRow)?.value ?? ""; break;
        case is DocFormRow:
            value = (row as? DocFormRow)?.value ?? ""
            break;
        case is VideoRow:
            value = (row as? VideoRow)?.value ?? ""; break;
        case is VeridiumRow:
            value = (row as? VeridiumRow)?.value ?? ""; break;
        case is VeridasDocumentOcrRow:
            value = (row as? VeridasDocumentOcrRow)?.value ?? ""; break;
        case is JUMIODocumentOcrRow:
            value = (row as? JUMIODocumentOcrRow)?.value ?? ""; break;
        default: break;
        }
        return value
    }
    
    /// Method for obtain value of user variable
    /// - Parameter varUsr: Name of user variable in XML
    public func valueVarUsr (_ varUsr: String) -> String
    {
        var valTypeVar = ""
        switch varUsr
        {
        case "EstadoDoc":
            valTypeVar = String(FormularioUtilities.shared.currentFormato.EstadoID)
            break
        case "PIIDdocumento":
            valTypeVar = String(FormularioUtilities.shared.currentFormato.PIID)
            break
        case "EstadoDocDesc":
            valTypeVar = FormularioUtilities.shared.currentFormato.NombreEstado
            break
        case "PIIDdocumentoDesc":
            valTypeVar = FormularioUtilities.shared.currentFormato.NombreProceso
            break
        case "GuidFormato":
            valTypeVar = ConfigurationManager.shared.guid
            break
        case "Today", "today":
            valTypeVar = FormularioUtilities.shared.variables("Hoy")
            break
        case "Now":
            valTypeVar = FormularioUtilities.shared.variables("Ahora")
            break
        default:
            valTypeVar = FormularioUtilities.shared.variables("\(varUsr)")
            break
        }
        return valTypeVar
    }
    
    /// Method that obtain value to compare, depending on mode type
    /// - Parameter subject: Object with the mode and dato in condition.
    /// - Parameter elementsRow: Dictionary of the rows data in table.
    public func valueByType( _ subject :AEXMLElement, _ elementsRow: NSMutableDictionary? = nil) -> String
    {
        switch  subject["predicate"]["mode"].value {
        case "words":
            if (subject["predicate"]["value"].all)?.count ?? 0 > 1
            {   var values = ""
                (subject["predicate"]["value"].all)?.forEach{ values += String($0.value ?? ""); values += "," }
                return values.last == "," ? String(values.dropLast()) : values
            }else
            {   return subject["predicate"]["value"].value ?? ""    }
        case "varusr":
            if let varCond = subject["predicate"]["value"].value
            {   let valor: String = self.valueVarUsr(varCond)
                if valor != ""  {
                    return valor
                }
            }
            break;
        case "element":
            if let idElem = subject["predicate"]["value"].value
            {
                if elementsRow != nil
                {   for dict in elementsRow ?? NSMutableDictionary()
                    {   if dict.key as! String == idElem
                        {
                            let dictValor = dict.value as! NSMutableDictionary
                            return dictValor.value(forKey: "valor") as? String ?? ""
                        }
                }
                let valorElem : String = self.valueElementRow(idElem)
                if valorElem != ""   {
                    return valorElem
                }
                } else
                {
                    let valorElem : String = self.valueElementRow(idElem)
                    if valorElem != ""   {
                        return valorElem
                    }
                }
                
            }
            break;
        default: break;
        }
        return ""
    }
    
    /// Method for obtain value Metadata of element in template
    /// - Parameter idElem:  Element id in forms
    public func valueMetaElementRow (_ idElem: String ,_ isCombo : String? = nil) -> (value: String, row: BaseRow)
    {
        let row = self.getElementByIdInAllForms("\(idElem)")
        if row == nil { self.combosPend[idElem] = isCombo }
        switch row{
        case is WizardRow: break;
        case is BotonRow: break;
        case is LogoRow: break;
        case is EtiquetaRow: break;
        case is HeaderTabRow: break;
        case is HeaderRow: break;
        case is TextoRow:
            let value = (row as? TextoRow)?.cell.elemento.validacion.valormetadato ?? "" == "" ? (row as? TextoRow)?.value ?? "" : (row as? TextoRow)?.cell.elemento.validacion.valormetadato ?? ""
            return (value: value, row: row!);
        case is TextoAreaRow:
            let value = (row as? TextoAreaRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is NumeroRow:
            let value = (row as? NumeroRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is MonedaRow:
            let value = (row as? MonedaRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is FechaRow:
            let value = (row as? FechaRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is LogicoRow:
            let value = (row as? LogicoRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is RangoFechasRow:
            let value = (row as? RangoFechasRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is SliderNewRow:
            let value = (row as? SliderNewRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is ListaRow:
            let value = (row as? ListaRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is ComboDinamicoRow:
            if plist.idportal.rawValue.dataI() >= 40 {
                let value = (row as? ComboDinamicoRow)?.cell.elemento.validacion.valormetadato ?? "";
                return (value: value, row: row!);
            }
        case is ListaTemporalRow:
            let value = (row as? ListaTemporalRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is TablaRow:
            let value = (row as? TablaRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is MarcadoDocumentoRow:
            if plist.idportal.rawValue.dataI() >= 41 {
                let value = (row as? MarcadoDocumentoRow)?.cell.elemento.validacion.valormetadato ?? "";
                return (value: value, row: row!);
            }
        case is CalculadoraRow: break;
        case is CodigoBarrasRow:
            let value = (row as? CodigoBarrasRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is CodigoQRRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                let value = (row as? CodigoQRRow)?.cell.elemento.validacion.valormetadato ?? "";
                return (value: value, row: row!);
            }
        case is EscanerNFCRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                let value = (row as? EscanerNFCRow)?.cell.elemento.validacion.valormetadato ?? "";
                return (value: value, row: row!);
            }
        case is AudioRow:
            let value = (row as? AudioRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is FirmaRow:
            let value = (row as? FirmaRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is FirmaFadRow:
            if plist.idportal.rawValue.dataI() >= 39{
                let value = (row as? FirmaFadRow)?.cell.elemento.validacion.valormetadato ?? "";
                return (value: value, row: row!);
            }
        case is MapaRow:
            let value = (row as? MapaRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is DocumentoRow:
            let value = (row as? DocumentoRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is ImagenRow:
            let value = (row as? ImagenRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is DocFormRow:
            let value = (row as? DocFormRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is VideoRow:
            let value = (row as? VideoRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is VeridiumRow:
            let value = (row as? VeridiumRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is VeridasDocumentOcrRow:
            let value = (row as? VeridasDocumentOcrRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        case is JUMIODocumentOcrRow:
            let value = (row as? JUMIODocumentOcrRow)?.cell.elemento.validacion.valormetadato ?? "";
            return (value: value, row: row!);
        default: break;
        }
        return (value: "", row: BaseRow());
    }
    
    /// Method for update values items ComboDinamico
    /// - Parameter idsCombo:  Array's id element Combos in order to update
    public func updateDataComboDinamico (idsCombo : [(id: String, row: BaseRow)] ) {
        if idsCombo.count == 0{ return }
        for idCombo in idsCombo {
            (idCombo.row as! ComboDinamicoRow).cell.valueOpen = false
            (idCombo.row as! ComboDinamicoRow).cell.settingValuesCombo()
        }
    }
    
    /// Method in order to assign element like filter in ComboDinamico
    /// - Parameter idsCombo:  Array's id element Combos in order to update
    public func isfilter (idElement : String )-> String
    {
        if self.combosPend[idElement] != nil
        {   return self.combosPend[idElement] ?? ""   }
        return ""
    }
    
    public func obtainerLocation() -> String
    {
        self.locationManager.startUpdatingLocation()
        let auxCoord = "\(self.locationManager.location?.coordinate.latitude ?? 0.0),\(self.locationManager.location?.coordinate.longitude ?? 0.0)"
        self.locationManager.stopUpdatingLocation()
        return auxCoord
    }
    
}

