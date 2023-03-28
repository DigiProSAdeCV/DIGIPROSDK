import Foundation
import Eureka
extension NuevaPlantillaViewController{
    
    public func executeRulesOnProperties(indexPage:Int){
            for baserow in self.forms[indexPage].allRows{
                switch baserow{
                case is PlantillaRow: break;
                case is PaginaRow: break;
                case is TextoRow:
                    let row = baserow as? TextoRow
                    row?.cell.setRulesOnProperties();
                    row?.cell.setRulesOnChange();
                    break;
                case is TextoAreaRow:
                    let row = baserow as? TextoAreaRow
                    row?.cell.setRulesOnProperties();
                    row?.cell.setRulesOnChange();
                    break;
                case is NumeroRow:
                    let row = baserow as? NumeroRow
                    row?.cell.setRulesOnProperties();
                    break;
                case is MonedaRow:
                    let row = baserow as? MonedaRow
                    row?.cell.setRulesOnProperties();
                    break;
                case is FechaRow:
                    let row = baserow as? FechaRow
                    row?.cell.setRulesOnProperties();
                    row?.cell.setRulesOnChange();
                    break;
                case is WizardRow:
                    let row = baserow as? WizardRow
                    row?.cell.setRulesOnProperties();
                    break;
                case is BotonRow:
                    let row = baserow as? BotonRow
                    row?.cell.setRulesOnProperties();
                    break;
                case is LogoRow:
                    let row = baserow as? LogoRow
                    row?.cell.setRulesOnProperties();
                    break;
                case is LogicoRow:
                    let row = baserow as? LogicoRow
                    row?.cell.setRulesOnProperties();
                    break;
                case is EtiquetaRow:
                    let row = baserow as? EtiquetaRow
                    row?.cell.setRulesOnProperties();
                    break;
                case is RangoFechasRow:
                    let row = baserow as? RangoFechasRow
                    row?.cell.setRulesOnProperties();
                    row?.cell.setRulesOnChange();
                    break;
                case is SliderNewRow:
                    let row = baserow as? SliderNewRow
                    row?.cell.setRulesOnProperties();
                    break;
                case is ListaRow:
                    let row = baserow as? ListaRow
                    row?.cell.setRulesOnProperties();
                    row?.cell.setRulesOnChange();
                    break;
                case is ComboDinamicoRow:
                    if plist.idportal.rawValue.dataI() >= 40 {
                        let row = baserow as? ComboDinamicoRow
                        row?.cell.setRulesOnProperties();
                    }
                    break;
                case is ListaTemporalRow:
                    let row = baserow as? ListaTemporalRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is HeaderTabRow:
                    let row = baserow as? HeaderTabRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is HeaderRow:
                    let row = baserow as? HeaderRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is TablaRow:
                    let row = baserow as? TablaRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is MarcadoDocumentoRow:
                 if plist.idportal.rawValue.dataI() >= 41 {
                    let row = baserow as? MarcadoDocumentoRow
                        row?.cell.setRulesOnProperties();
                 }
                    break;
                case is CodigoBarrasRow:
                    let row = baserow as? CodigoBarrasRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is CodigoQRRow:
                 if plist.idportal.rawValue.dataI() >= 39 {
                    let row = baserow as? CodigoQRRow
                        row?.cell.setRulesOnProperties();
                 }
                        break;
                case is EscanerNFCRow:
                 if plist.idportal.rawValue.dataI() >= 39 {
                    let row = baserow as? EscanerNFCRow
                        row?.cell.setRulesOnProperties();
                 }
                        break;
                case is CalculadoraRow:
                    if plist.idportal.rawValue.dataI() >= 39{
                        let row = baserow as? CalculadoraRow
                        row?.cell.setRulesOnProperties();
                        break;
                    }
                case is AudioRow:
                    let row = baserow as? AudioRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is FirmaRow:
                    let row = baserow as? FirmaRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is FirmaFadRow:
                    if plist.idportal.rawValue.dataI() >= 39{
                        let row = baserow as? FirmaFadRow
                        row?.cell.setRulesOnProperties();
                        break;
                    }
                case is MapaRow:
                    let row = baserow as? MapaRow
                        row?.cell.setRulesOnProperties();
                        row?.cell.setRulesOnChange();
                        break;
                case is DocumentoRow:
                    let row = baserow as? DocumentoRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is ImagenRow:
                    let row = baserow as? ImagenRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is DocFormRow:
                    let row = baserow as? DocFormRow
                    row?.cell.setRulesOnProperties();
                    break;
                case is VideoRow:
                        let row = baserow as? VideoRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is VeridasDocumentOcrRow:
                        let row = baserow as? VeridasDocumentOcrRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is JUMIODocumentOcrRow:
                        let row = baserow as? JUMIODocumentOcrRow
                        row?.cell.setRulesOnProperties();
                        break;
                case is VeridiumRow:
                    let row = baserow as? VeridiumRow
                        row?.cell.setRulesOnProperties();
                        break;
                default: break;
                }
        }
    }
    
    public func setRuleByRowInForms(_ id: String, _ vrb: String, _ condition: AEXMLElement){
        
        if condition["enabled"].value == "false"{ return }
        
        for form in self.forms{
            
            let baserow = form.rowBy(tag: id)
            if baserow == nil{ continue }
            
            switch baserow{
            case is PlantillaRow:
                let row = baserow as? PlantillaRow
                row?.cell.rulesOnProperties.append((condition, vrb)); break;
            case is PaginaRow:
                let row = baserow as? PaginaRow
                row?.cell.rulesOnChange.append(condition); break;
            case is TextoRow:
                let row = baserow as? TextoRow
                switch vrb{
                case "contains", "notcontains", "empty", "notempty", "equals", "notequals":
                    var found = false
                    if row?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (row?.cell.rulesOnChange)!{ if rule.name == condition.name{ found = true; break; } } }
                    if found == false{ row?.cell.rulesOnChange.append(condition); break; }
                    break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    var found = false
                    if row?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (row?.cell.rulesOnProperties)!{ if rule.vrb == condition.name{ found = true; break; } } }
                    if found == false{ row?.cell.rulesOnProperties.append((condition, vrb)); break; }
                    break;
                default: break;
                }
            case is TextoAreaRow:
                let row = baserow as? TextoAreaRow
                switch vrb{
                case "contains", "notcontains", "empty", "notempty", "equals", "notequals":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is NumeroRow:
                let row = baserow as? NumeroRow
                switch vrb{
                case "contains", "notcontains", "empty", "notempty", "equals", "notequals", "may","mayorequal", "men", "menorequal":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is MonedaRow:
                let row = baserow as? MonedaRow
                switch vrb{
                case "contains", "notcontains", "empty", "notempty", "equals", "notequals", "may","mayorequal", "men", "menorequal":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is FechaRow:
                let row = baserow as? FechaRow
                switch vrb{
                case "contains", "notcontains", "empty", "notempty", "equals", "notequals":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is WizardRow:
                let row = baserow as? WizardRow
                switch vrb{
                case "backward", "forward", "beforefinish", "afterfinish":
                    row?.cell.rulesOnChange.append(condition); break;
                case "notenabled", "enabled":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is BotonRow:
                let row = baserow as? BotonRow
                switch vrb{
                case "click":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is LogoRow:
                let row = baserow as? LogoRow
                switch vrb{
                case "visible", "notvisible", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is LogicoRow:
                let row = baserow as? LogicoRow
                switch vrb{
                case "selected", "notselected":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is EtiquetaRow:
                let row = baserow as? EtiquetaRow
                switch vrb{
                case "visible", "notvisible", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is RangoFechasRow:
                let row = baserow as? RangoFechasRow
                switch vrb{
                case "contains", "notcontains", "equals", "notequals","empty", "notempty":
                    row?.cell.rulesOnChange.append(condition);
                    break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is SliderNewRow:
                let row = baserow as? SliderNewRow
                switch vrb{
                case "contains", "notcontains", "empty", "notempty", "equals", "notequals", "may","mayorequal", "men", "menorequal":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is ListaRow:
                let row = baserow as? ListaRow

                switch vrb{
                case "change":
                    var found = false
                    if row?.cell.rulesOnAction.count ?? 0 > 0{ for rule in (row?.cell.rulesOnAction)!{ if rule.name == condition.name{ found = true; break; } } }
                    if found == false{ row?.cell.rulesOnAction.append(condition); break; }
                case "contains", "notcontains", "empty", "notempty":
                    var found = false
                    if row?.cell.rulesOnChange.count ?? 0 > 0{ for rule in (row?.cell.rulesOnChange)!{ if rule.name == condition.name{ found = true; break; } } }
                    if found == false{ row?.cell.rulesOnChange.append(condition); break; }
                    break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    var found = false
                    if row?.cell.rulesOnProperties.count ?? 0 > 0{ for rule in (row?.cell.rulesOnProperties)!{ if rule.vrb == condition.name{ found = true; break; } } }
                    if found == false{ row?.cell.rulesOnProperties.append((condition, vrb)); break; }
                    break;
                default: break;
                }
            case is MarcadoDocumentoRow:
             if plist.idportal.rawValue.dataI() >= 41 {
                let row = baserow as? MarcadoDocumentoRow
                switch vrb{
                case "change":
                    row?.cell.rulesOnAction.append(condition); break;
                case "contains", "notcontains", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
             }
            case is ComboDinamicoRow:
              if plist.idportal.rawValue.dataI() >= 40 {
                let row = baserow as? ComboDinamicoRow
                switch vrb{
                case "change":
                    row?.cell.rulesOnAction.append(condition); break;
                case "contains", "notcontains", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            }
            case is ListaTemporalRow:
                let row = baserow as? ListaTemporalRow
                switch vrb{
                case "change":
                    row?.cell.rulesOnAction.append(condition); break;
                case "contains", "notcontains", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is HeaderTabRow:
                let row = baserow as? HeaderTabRow
                switch vrb{
                case "visible", "notvisible", "enabled", "notenabled":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is HeaderRow:
                let row = baserow as? HeaderRow
                switch vrb{
                case "visible", "notvisible", "enabled", "notenabled":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is TablaRow:
                let row = baserow as? TablaRow
                switch vrb{
                case "tableshowadd","editing,multi", "tableadd,addclear", "edit", "remove", "bynewrow","byeditrow", "byallrows", "byatleastonerow" :
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is CodigoBarrasRow:
                let row = baserow as? CodigoBarrasRow
                switch vrb{
                case "contains", "notcontains", "empty", "notempty", "equals", "notequals":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is CodigoQRRow:
              if plist.idportal.rawValue.dataI() >= 39 {
                let row = baserow as? CodigoQRRow
                switch vrb{
                case "contains", "notcontains", "empty", "notempty", "equals", "notequals":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            }
            case is EscanerNFCRow:
              if plist.idportal.rawValue.dataI() >= 39 {
                let row = baserow as? EscanerNFCRow
                switch vrb{
                case "contains", "notcontains", "empty", "notempty", "equals", "notequals":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
             }
            case is CalculadoraRow:
                if plist.idportal.rawValue.dataI() >= 39{
                    let row = baserow as? CalculadoraRow
                    switch vrb{
                    case "visible", "notvisible", "visiblecontenido", "notvisiblecontenido":
                        row?.cell.rulesOnProperties.append((condition, vrb));
                        break;
                    default: break;
                    }
                }
            case is AudioRow:
                let row = baserow as? AudioRow
                switch vrb{
                case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is FirmaRow:
                let row = baserow as? FirmaRow
                switch vrb{
                case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is FirmaFadRow:
                if plist.idportal.rawValue.dataI() >= 39{
                    let row = baserow as? FirmaFadRow
                    switch vrb{
                    case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty":
                        row?.cell.rulesOnChange.append(condition); break;
                    case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                        row?.cell.rulesOnProperties.append((condition, vrb));
                        break;
                    default: break;
                    }
                }
            case is MapaRow:
                let row = baserow as? MapaRow
                switch vrb{
                case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is DocumentoRow:
                let row = baserow as? DocumentoRow
                switch vrb{
                case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty", "typifyattach", "untypifyattach":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is ImagenRow:
                let row = baserow as? ImagenRow
                switch vrb{
                case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is DocFormRow:
                let row = baserow as? DocFormRow
                switch vrb {
                case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is VideoRow:
                let row = baserow as? VideoRow
                switch vrb{
                case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            case is VeridasDocumentOcrRow:
                    let row = baserow as? VeridasDocumentOcrRow
                    switch vrb{
                    case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty":
                        row?.cell.rulesOnChange.append(condition); break;
                    case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                        row?.cell.rulesOnProperties.append((condition, vrb));
                        break;
                    default: break;
                    }
                break
            case is JUMIODocumentOcrRow:
                let row = baserow as? JUMIODocumentOcrRow
                switch vrb {
                case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
                break
            case is VeridiumRow:
                let row = baserow as? VeridiumRow
                switch vrb{
                case "addanexo", "removeanexo", "replaceanexo", "empty", "notempty":
                    row?.cell.rulesOnChange.append(condition); break;
                case "visible", "notvisible", "enabled", "notenabled", "visiblecontenido", "notvisiblecontenido":
                    row?.cell.rulesOnProperties.append((condition, vrb));
                    break;
                default: break;
                }
            default: break;
            }
            
        }
        
    }
    
    public func settingRules() -> Bool{
        
        if FormularioUtilities.shared.rules == nil{ return false }
        
        for rule in FormularioUtilities.shared.rules!.root.children{
            // Detecting Rule
            if rule["enabled"].value == "true"{
                // Conditions
                for condition in rule["conditions"].children{
                    // Subjects
                    for subject in condition["subject"].children{
                        if (subject["subject"].value == nil){ continue }
                        let ss = subject["subject"].value ?? ""
                        let vrb = subject["verb"].value ?? ""
                        if condition["category"].value == "document"{
                            setRuleByRowInForms("formElec_element0", "document", rule)
                        }else if condition["category"].value == "permissions" {
                            setRuleByRowInForms("formElec_element0", "permissions", rule)
                        }else if condition["category"].value == "bytable" {
                            if condition["tableidelem"].value == ""{ continue }
                            setRuleByRowInForms(condition["tableidelem"].value ?? "", condition["rowtype"].value ?? "", rule)
                        }else {
                            if ss == "" || vrb == ""{ continue }
                            setRuleByRowInForms(ss, vrb, rule)
                        }
                    }
                }
                
            }
            
        }
        return false
        
    }

    public func obtainRules(rString rlString: String? = nil, eString element: String? = nil, vString vrb: String? = nil, forced isForced: Bool? = nil, override isOverrided: Bool? = nil)->Promise<Bool>{

        return Promise<Bool>{ resolve, reject in
         
            if FormularioUtilities.shared.rules == nil{ reject(APIErrorResponse.defaultError) }
            if FormularioUtilities.shared.rules != nil{
                if isOverrided ?? false && rlString != nil{
                    let rule = FormularioUtilities.shared.rules!.root[rlString!]
                    var conditionsTable : [AEXMLElement] = []
                    for condition in rule["conditions"].children{
                        if condition["category"].value! == "bytable"
                        { conditionsTable.append(AEXMLElement(name: "isOverrided")) }
                    }
                    if !conditionsTable.isEmpty {
                        let res = resolvingAllActions(rule["actions"], conditionsTable)
                        if res != nil && res == 400{
                            resolve(true)
                            return
                        }
                    } else {
                        let res = resolvingAllActions(rule["actions"])
                        if res != nil && res == 400{
                            resolve(true)
                            return
                        }
                    }
                    resolve(true)
                }else{
                    if rlString != nil{
                        let rule = FormularioUtilities.shared.rules!.root[rlString!]
                        // Detecting Rule
                        if rule["enabled"].value == "true"{
                            // We detect a rule
                            switch rule["logic"].value {
                            case "all":
                                // Detecting element and verb
                                var result: Bool = false
                                if element != nil && vrb != nil{
                                    result = resolvingAllCondition(rule["conditions"], element, vrb, isForced)
                                }else{
                                    result = resolvingAllCondition(rule["conditions"], nil, nil, isForced)
                                }
                                // We need to resolve all Actions
                                if result{
                                    var conditionsTable : [AEXMLElement] = []
                                    for condition in rule["conditions"].children{
                                        if condition["category"].value! == "bytable"
                                        {   conditionsTable.append(condition)   }
                                    }
                                    if !conditionsTable.isEmpty {
                                        let res = resolvingAllActions(rule["actions"], conditionsTable)
                                        if res != nil && res == 400{
                                            resolve(true)
                                            return
                                        }
                                    } else {
                                        let res = resolvingAllActions(rule["actions"])
                                        if res != nil && res == 400{
                                            resolve(true)
                                            return
                                        }
                                    }
                                }
                                resolve(true)
                                break;
                            case "any":
                                var result: Bool
                                if element != nil && vrb != nil{
                                    result = resolvingAnyCondition(rule["conditions"], element, vrb, isForced)
                                }else{
                                    result = resolvingAnyCondition(rule["conditions"], nil, nil, isForced)
                                }
                                // We need to resolve all Actions
                                if result{
                                    var conditionsTable : [AEXMLElement] = []
                                    for condition in rule["conditions"].children{
                                        if condition["category"].value! == "bytable"
                                        {   conditionsTable.append(condition)  }
                                    }
                                    if !conditionsTable.isEmpty {
                                        let res = resolvingAllActions(rule["actions"], conditionsTable)
                                        if res != nil && res == 400{
                                            resolve(true)
                                            return
                                        }
                                    } else {
                                        let res = resolvingAllActions(rule["actions"])
                                        if res != nil && res == 400{
                                            resolve(true)
                                            return
                                        }
                                    }
                                }
                                resolve(true)
                                break;
                            default: break;
                            }
                            // Kind of Logic - ALL, ANY
                        }
                    }else{
                        for rule in FormularioUtilities.shared.rules!.root.children{
                            // Detecting Rule
                            if rule["enabled"].value == "true"{
                                // We detect a rule
                                switch rule["logic"].value {
                                case "all":
                                    // Detecting element and verb
                                    var result: Bool
                                    if element != nil && vrb != nil{
                                        result = resolvingAllCondition(rule["conditions"], element, vrb, isForced)
                                    }else{
                                        result = resolvingAllCondition(rule["conditions"], nil, nil, isForced)
                                    }
                                    // We need to resolve all Actions
                                    if result{
                                        var conditionsTable : [AEXMLElement] = []
                                        for condition in rule["conditions"].children{
                                            if condition["category"].value! == "bytable"
                                            {   conditionsTable.append(condition)  }
                                        }
                                        if !conditionsTable.isEmpty {
                                            let res = resolvingAllActions(rule["actions"], conditionsTable)
                                            if res != nil && res == 400{
                                                resolve(true)
                                                return
                                            }
                                        } else {
                                            let res = resolvingAllActions(rule["actions"])
                                            if res != nil && res == 400{
                                                resolve(true)
                                                return
                                            }
                                        }
                                    }
                                    resolve(true)
                                    break;
                                case "any":
                                    var result: Bool
                                    if element != nil && vrb != nil{
                                        result = resolvingAnyCondition(rule["conditions"], element, vrb, isForced)
                                    }else{
                                        result = resolvingAnyCondition(rule["conditions"], nil, nil, isForced)
                                    }
                                    // We need to resolve all Actions
                                    if result{
                                        var conditionsTable : [AEXMLElement] = []
                                        for condition in rule["conditions"].children{
                                            if condition["category"].value! == "bytable"
                                            {   conditionsTable.append(condition)  }
                                        }
                                        if !conditionsTable.isEmpty {
                                            let res = resolvingAllActions(rule["actions"], conditionsTable)
                                            if res != nil && res == 400{
                                                resolve(true)
                                                return
                                            }
                                        } else {
                                            let res = resolvingAllActions(rule["actions"])
                                            if res != nil && res == 400{
                                                resolve(true)
                                                return
                                            }
                                        }
                                    }
                                    resolve(true)
                                    break;
                                default: break;
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
}

