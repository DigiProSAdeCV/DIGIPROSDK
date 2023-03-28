import Foundation

import Eureka

extension NuevaPlantillaViewController{
    
    public func obtainConcat(_ element: String){
        
        var identifiers = [(elem:String, id:String)]()
        var formula = FormularioUtilities.shared.mathematics?.root[element]["formula"].value!
        let split = formula?.split{$0 == "="}.map(String.init)
        formula = split?[1]
        let resultado = split?[0]
        var resultadoBaseRow: Any?
        
        for identifier in (FormularioUtilities.shared.mathematics?.root[element]["identifiers"].children)! {
            identifiers.append((identifier["idelem"].value!, identifier["identif"].value!))
            let elem = getElementANY(identifier["idelem"].value!)
            if elem.kind == nil{
                // We need to check variables values
                if let varusrTxt = identifier["idelem"].value{
                    let valorVar : String = self.valueVarUsr(varusrTxt)
                    if valorVar != "" {
                        if formula?.contains("\(varusrTxt)") ?? false{
                            formula = formula!.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(valorVar)")
                        }
                    }
                }
                continue
            }
            switch elem.kind {
                case is NumeroRow:

                    let number = String((elem.kind as? NumeroRow)?.value ?? "")
                    if formula?.contains("\(identifier["identif"].value!)") ?? false{
                        formula = formula!.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(number)")
                    }
                    if resultado?.contains(identifier["identif"].value!) ?? false{
                        resultadoBaseRow = elem.kind
                    }
                    break;
                case is TextoRow:
                    
                    let number = (elem.kind as? TextoRow)?.value ?? ""
                //Revisamos que no reemplace en caso que uno de los valores contenga el nombre del identificador del resultado
                if (((formula?.contains("\(identifier["identif"].value!)")) != nil) && (!(resultado!.contains("\(identifier["identif"].value!)")))) {
                    formula = formula!.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(number)")
                }
                if resultado?.contains(identifier["identif"].value!) ?? false{
                    resultadoBaseRow = elem.kind
                }
                    break;
                case is TextoAreaRow:
                    let number = (elem.kind as? TextoAreaRow)?.value ?? ""
                    
                    if (((formula?.contains("\(identifier["identif"].value!)")) != nil) && (!(resultado!.contains("\(identifier["identif"].value!)")))) {
                        formula = formula!.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(number)")
                    }
                    if resultado?.contains(identifier["identif"].value!) ?? false{
                        resultadoBaseRow = elem.kind
                    }
                    break

                case is MonedaRow:
                    
                    let number = String((elem.kind as? MonedaRow)?.value ?? "")
                    
                    if (((formula?.contains("\(identifier["identif"].value!)")) != nil) && (!(resultado!.contains("\(identifier["identif"].value!)")))) {
                        formula = formula!.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(number)")
                    }

                    if resultado?.contains(identifier["identif"].value!) ?? false{
                        resultadoBaseRow = elem.kind
                    }
                    break
                default: return }
            }
        // Replacing operations
        formula = formula!.replacingOccurrences(of: "+", with: "")

        switch resultadoBaseRow{
        case is NumeroRow: (resultadoBaseRow as? NumeroRow)?.cell.setEdited(v: formula ?? ""); break;
        case is TextoRow: (resultadoBaseRow as? TextoRow)?.cell.setEdited(v: formula ?? ""); break;
        case is TextoAreaRow: (resultadoBaseRow as? TextoAreaRow)?.cell.setEdited(v: formula ?? ""); break;
        case is MonedaRow: (resultadoBaseRow as? MonedaRow)?.cell.setEdited(v: formula ?? ""); break
        default: break;
        }
        
    }
    
    public func obtainMathematics(_ element: String, _ isForced: Bool? = nil){
        
        if FormularioUtilities.shared.mathematics == nil{ return }

        // Get identifiers
        if FormularioUtilities.shared.mathematics?.root[element]["enabled"].value ?? "false" == "true" || isForced != nil {
            
            if FormularioUtilities.shared.mathematics?.root[element]["stringConcat"].value ?? "false" == "true"{ obtainConcat(element); return; }
            
            
            var identifiers = [(elem:String, id:String)]()
            if  var formula = FormularioUtilities.shared.mathematics?.root[element]["formula"].value{
                let split = formula.split{$0 == "="}.map(String.init)
                formula = split[1]
                var isTable = false
                var resultadoBaseRow: Any?
                
                if formula.contains("tc_") {
                    isTable = true
                    formula = formula.replacingOccurrences(of: "tc_", with: "")
                }
                for identifier in (FormularioUtilities.shared.mathematics?.root[element]["identifiers"].children)! {
                    identifiers.append((identifier["idelem"].value!, identifier["identif"].value!))
                    let elem = getElementANY(identifier["idelem"].value!)
                    if identifier["identif"].value != nil, identifier["identif"].value == split[0]{
                        resultadoBaseRow = elem.kind
                        continue
                    }
                    switch elem.kind {
                        case is NumeroRow:
                            if isTable
                            {
                                let elemT = getElementANY((elem.kind as? NumeroRow)?.cell.atributos!.elementopadre ?? "")
                                if elemT.kind is TablaRow
                                {
                                    for colum in ((elemT.kind as? TablaRow)?.cell.ff)!
                                    {   if colum.id == elem.id
                                    {   if formula.contains("\(identifier["identif"].value!)") {
                                        formula = formula.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(colum.formula)")
                                            }
                                        }
                                    }
                                }
                            } else
                            {
                                let number = Double((elem.kind as? NumeroRow)?.value ?? "0.0")
                                if formula.contains("redondear(\(identifier["identif"].value!))") {
                                    let xround = number?.rounded()
                                    formula = formula.replacingOccurrences(of: "redondear(\(identifier["identif"].value!))", with: "\(xround ?? 0)")
                                }else{
                                    if formula.contains("\(identifier["identif"].value!)") {
                                        formula = formula.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(number ?? 0.0)")
                                    }
                                }
                            }
                            
                            break;
                        case is TextoRow:
                            if isTable
                            {
                                let elemT = getElementANY((elem.kind as? TextoRow)?.cell.atributos!.elementopadre ?? "")
                                if elemT.kind is TablaRow
                                {   for colum in ((elemT.kind as? TablaRow)?.cell.ff)!
                                    {   if colum.id == identifier["idelem"].value!
                                    {   if formula.contains("\(identifier["identif"].value!)") {
                                        formula = formula.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(colum.formula)")
                                            }
                                        }
                                    }
                                }
                            } else
                            {
                                                        
                                let number = Double((elem.kind as? TextoRow)?.value ?? "0.0")
                                if formula.contains("redondear(\(identifier["identif"].value!))") {
                                    let xround = number?.rounded()
                                    formula = formula.replacingOccurrences(of: "redondear(\(identifier["identif"].value!))", with: "\(xround ?? 0)")
                                }else{
                                    if formula.contains("\(identifier["identif"].value!)") {
                                        formula = formula.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(number ?? 0.0)")
                                    }
                                }
                            }
                            
                            break;
                        case is MonedaRow:
                            if isTable
                            {
                                let elemT = getElementANY((elem.kind as? MonedaRow)?.cell.atributos!.elementopadre ?? "")
                                if elemT.kind is TablaRow
                                {   for colum in ((elemT.kind as? TablaRow)?.cell.ff)!
                                    {   if colum.id == identifier["idelem"].value!
                                    {   if formula.contains("\(identifier["identif"].value!)") {
                                        formula = formula.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(colum.formula)")
                                            }
                                        }
                                    }
                                }
                            } else
                            {
                                let number = Double((elem.kind as? MonedaRow)?.value ?? "0.0")
                                if formula.contains("redondear(\(identifier["identif"].value!))") {
                                    let xround = number?.rounded()
                                    formula = formula.replacingOccurrences(of: "redondear(\(identifier["identif"].value!))", with: "\(xround ?? 0)")
                                }else{
                                    if formula.contains("\(identifier["identif"].value!)") {
                                        formula = formula.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(number ?? 0.0)")
                                    }
                                }
                            }
                            
                            break
                        case is TextoAreaRow:
                            if isTable
                            {
                                let elemT = getElementANY((elem.kind as? TextoAreaRow)?.cell.atributos!.elementopadre ?? "")
                                if elemT.kind is TablaRow
                                {   for colum in ((elemT.kind as? TablaRow)?.cell.ff)!
                                    {   if colum.id == identifier["idelem"].value!
                                    {   if formula.contains("\(identifier["identif"].value!)") {
                                        formula = formula.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(colum.formula)")
                                            }
                                        }
                                    }
                                }
                            } else
                            {
                                let number = Double((elem.kind as? TextoAreaRow)?.value ?? "0.0")
                                if formula.contains("redondear(\(identifier["identif"].value!))") {
                                    let xround = number?.rounded()
                                    formula = formula.replacingOccurrences(of: "redondear(\(identifier["identif"].value!))", with: "\(xround ?? 0)")
                                }else{
                                    if formula.contains("\(identifier["identif"].value!)") {
                                        formula = formula.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(number ?? 0.0)")
                                    }
                                }
                            }
                            
                            break;
                        case is SliderNewRow:
                            if isTable
                            {
                                let elemT = getElementANY((elem.kind as? SliderNewRow)?.cell.atributos!.elementopadre ?? "")
                                if elemT.kind is TablaRow
                                {
                                    for colum in ((elemT.kind as? TablaRow)?.cell.ff)!
                                    {   if colum.id == elem.id
                                    {   if formula.contains("\(identifier["identif"].value!)") {
                                        formula = formula.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(colum.formula)")
                                            }
                                        }
                                    }
                                }
                            } else
                            {
                                let slider = Double((elem.kind as? SliderNewRow)?.value ?? "0.0")
                                if formula.contains("redondear(\(identifier["identif"].value!))") {
                                    let xround = slider?.rounded()
                                    formula = formula.replacingOccurrences(of: "redondear(\(identifier["identif"].value!))", with: "\(xround ?? 0)")
                                }else{
                                    if formula.contains("\(identifier["identif"].value!)") {
                                        formula = formula.replacingOccurrences(of: "\(identifier["identif"].value!)", with: "\(slider ?? 0.0)")
                                    }
                                }
                            }
                            
                            break;
                        default: return
                        }
                    }
                // Replacing operations
                formula = formula.replacingOccurrences(of: "entero", with: "trunc")
                formula = formula.replacingOccurrences(of: "promedio", with: "average")
                
                if let openParenthesisRange = formula.range(of: "max("),
                    let closeParenthesisRange = formula.range(of: ")", range: openParenthesisRange.upperBound..<formula.endIndex) {
                    let range = openParenthesisRange.upperBound..<(closeParenthesisRange.lowerBound)
                    let result = String(formula[range])
                    var clean = result.replacingOccurrences(of: "0.0,", with: "")
                    clean = clean.replacingOccurrences(of: "0.0", with: "")
                    let max = clean.split{$0 == ","}.map(String.init)
                    if max.count > 0{
                        formula = formula.replacingOccurrences(of: "max(\(result))", with: "\(max.max() ?? "0")")
                    }else{
                        formula = formula.replacingOccurrences(of: "max(\(result))", with: "0")
                    }
                    
                }
                
                if let openParenthesisRange = formula.range(of: "min("),
                    let closeParenthesisRange = formula.range(of: ")", range: openParenthesisRange.upperBound..<formula.endIndex) {
                    let range = openParenthesisRange.upperBound..<(closeParenthesisRange.lowerBound)
                    let result = String(formula[range])
                    var clean = result.replacingOccurrences(of: "0.0,", with: "")
                    clean = clean.replacingOccurrences(of: "0.0", with: "")
                    let min = clean.split{$0 == ","}.map(String.init)
                    if min.count > 0{
                        formula = formula.replacingOccurrences(of: "min(\(result))", with: "\(min.min() ?? "0")")
                    }else{
                        formula = formula.replacingOccurrences(of: "min(\(result))", with: "0")
                    }
                }
                
                if let openParenthesisRange = formula.range(of: "average("),
                    let closeParenthesisRange = formula.range(of: ")", range: openParenthesisRange.upperBound..<formula.endIndex) {
                    let range = openParenthesisRange.upperBound..<(closeParenthesisRange.lowerBound)
                    let result = String(formula[range])
                    let sum = result.split{$0 == ","}.map(String.init)
                    let doubleArray = sum.map { Float($0)!}
                    let average = (doubleArray as NSArray).value(forKeyPath: "@avg.floatValue")
                    formula = formula.replacingOccurrences(of: "average(\(result))", with: "\(average ?? 0)")
                }
                
                guard formula != "" else {
                    switch resultadoBaseRow{
                    case is NumeroRow:
                        (resultadoBaseRow as? NumeroRow)?.cell.setEdited(v: "");
                        break;
                    case is TextoRow:
                        (resultadoBaseRow as? TextoRow)?.cell.setEdited(v: "");
                        break;
                    case is MonedaRow:
                        (resultadoBaseRow as? MonedaRow)?.cell.setEdited(v: "");
                        break;
                    case is TextoAreaRow:
                        (resultadoBaseRow as? TextoAreaRow)?.cell.setEdited(v: "");
                        break;
                    default: break;
                    }
                    return
                }
                
                var mathExpression: NSExpression
                
                if formula.contains(",") {
                    let array = formula.components(separatedBy:",")
                    let numbers = array.map { Double($0)! }
                    mathExpression = NSExpression(forFunction:"average:", arguments:[NSExpression(forConstantValue:numbers)])
                } else {
                    mathExpression = NSExpression(format: "\(formula)")
                }

                let mathValue = mathExpression.expressionValue(with: nil, context: nil) as? Double
                var valueString = String(mathValue ?? 0)
                //Aqui obtiene el valor, pero se sale si es 0
                if valueString == "inf" || valueString == "0.0"{ return }
                
                // MARK: si es entero regresar sin decimales
                
                if valueString.contains(".0") ||  valueString.contains(".00") {
                    valueString = String((valueString as NSString).integerValue)
                }
                
                switch resultadoBaseRow{
                case is NumeroRow:
                    (resultadoBaseRow as? NumeroRow)?.cell.setEdited(v: valueString);
                    break;
                case is TextoRow:
                    (resultadoBaseRow as? TextoRow)?.cell.setEdited(v: valueString);
                    break;
                case is MonedaRow:
                    (resultadoBaseRow as? MonedaRow)?.cell.setEdited(v: valueString);
                    break;
                case is TextoAreaRow:
                    (resultadoBaseRow as? TextoAreaRow)?.cell.setEdited(v: valueString);
                    break;
                default: break;
                }

            }


            
        }
        
    }
    
}
