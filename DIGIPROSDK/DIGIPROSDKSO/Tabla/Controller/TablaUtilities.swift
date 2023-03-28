import Foundation


extension TablaCell: SpreadsheetViewDelegate, SpreadsheetViewDataSource{
    
    // MARK: - DATASOURCE SPREADSHEETVIEW
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow column: Int) -> CGFloat {
        if (records.count == 0) || (self.records.count == self.recordsHide.count) ||
            (self.recordsHide.count == 1 && self.recordsHide.last == 9999)
        { return 0 }
        return 30
    }
    
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if (records.count == 0) || (self.records.count == self.recordsHide.count) ||
            (self.recordsHide.count == 1 && self.recordsHide.last == 9999)
        { return 0 }
        
        switch column{
        case 0,1,2: return 50
        case 3:
            if atributos?.mostrarconsecutivofila ?? false{ return 25 }else{ return 0 }
        default:
            if atributos?.columnasvisualizar.count == 0{ return 90 }
            for elem in (atributos?.columnasvisualizar)!{
                if elem.key == self.nameElement[column - 4].id && !(Bool(elem.value as! String) ?? true){
                    return 0
                }
            }
            
            return 90
        }
    }
    
    public func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        if (records.count == 0) || (self.records.count == self.recordsHide.count) ||
        (self.recordsHide.count == 1 && self.recordsHide.last == 9999) {
            return 0
        }else{
            return 1 + 1 + 1 + 1 + self.rowsTable
        }
        
    }
    
    public func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        if (records.count == 0) || (self.records.count == self.recordsHide.count) ||
        (self.recordsHide.count == 1 && self.recordsHide.last == 9999) {
            return 0
        }else{
            if !self.recordsHide.isEmpty
            {   dataRowsVisibles = [[String]]()
                self.recordsVisibles = [(record: Int, json: String)]()
                for (index, value) in self.dataRows.enumerated()
                {   var isDiff = true
                    for indexHide in self.recordsHide
                    {   if index == indexHide {isDiff = false; break;}  }
                    if isDiff {
                        self.dataRowsVisibles.append(value)
                        self.recordsVisibles.append(self.records[index])
                    }
                }
            } else {
                self.dataRowsVisibles = self.dataRows
                self.recordsVisibles = self.records
            }
            return 2 + (self.records.count - self.recordsHide.count)
        }
        
    }
    
    public func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        if (records.count == 0) || (self.records.count == self.recordsHide.count) ||
        (self.recordsHide.count == 1 && self.recordsHide.last == 9999) {
            return 0
        }else{
            return 4
        }
        
    }
    
    public func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        if (records.count == 0) || (self.records.count == self.recordsHide.count) ||
        (self.recordsHide.count == 1 && self.recordsHide.last == 9999) {
            return 0
        }else{
            return 1
        }
    }
    
    public func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        if (records.count == 0) || (self.records.count == self.recordsHide.count) ||
        (self.recordsHide.count == 1 && self.recordsHide.last == 9999)
        { return [] }
        
        if recordsVisibles.count > 0 {
            let last = recordsVisibles.endIndex + 1
            return [CellRange(from: (row: last, column: 0), to: (row: last, column: 3))]
        }; return []
    }
    
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> CellSpread? {
        if recordsVisibles.count == 0{
            return nil
        }else{
            // Blank
            // Column 0, Row 0
            if case (0,0) = (indexPath.column, indexPath.row){
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: RowCell.self), for: indexPath) as! RowCell
                cell.label.text = ""
                cell.label.textColor = UIColor(hexFromString: atributos!.colorheadertexto)
                cell.label.backgroundColor = UIColor(hexFromString: atributos!.colorheader)
                return cell
            // Blank
            // Column 1, Row 0
            }else if case (1,0) = (indexPath.column, indexPath.row){
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: RowCell.self), for: indexPath) as! RowCell
                cell.label.text = ""
                cell.label.textColor = UIColor(hexFromString: atributos!.colorheadertexto)
                cell.label.backgroundColor = UIColor(hexFromString: atributos!.colorheader)
                return cell
            // Blank
            // Columnn 2, Row 0
            }else if case (2,0) = (indexPath.column, indexPath.row){
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: RowCell.self), for: indexPath) as! RowCell
                cell.label.text = ""
                cell.label.textColor = UIColor(hexFromString: atributos!.colorheadertexto)
                cell.label.backgroundColor = UIColor(hexFromString: atributos!.colorheader)
                return cell
            // No. Label
            // Columnn 3, Row 0
            }else if case (3,0) = (indexPath.column, indexPath.row){
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: RowCell.self), for: indexPath) as! RowCell
                cell.label.text = "No."
                cell.label.textColor = UIColor(hexFromString: atributos!.colorheadertexto)
                cell.label.backgroundColor = UIColor(hexFromString: atributos!.colorheader)
                return cell
            // Edit button
            // Columnn 0, Row 1
            }else if case (0,1...(records.count + 1)) = (indexPath.column, indexPath.row){
                if !dataRowsVisibles.indices.contains(indexPath.row - 1){
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: RowCell.self), for: indexPath) as! RowCell
                    cell.label.text = "elemts_table_total".langlocalized()
                    return cell
                }
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: EditCell.self), for: indexPath) as! EditCell
                cell.button.setTitle("✏️", for: .normal)
                if !(atributos?.permisotablaeditarr ?? false){
                    cell.button.backgroundColor = UIColor(hexFromString: "#222222", alpha: 0.6)
                    cell.button.isUserInteractionEnabled = false
                    cell.button.isEnabled = false
                }else{
                    cell.button.backgroundColor = .clear
                    cell.button.isUserInteractionEnabled = true
                    cell.button.isEnabled = true
                }
                if indexPath.row != 0{
                    cell.button.addTarget(self, action: #selector(self.editBtnAction(_ :)), for: .touchUpInside)
                    cell.button.tag = indexPath.row - 1
                }
                return cell
            // Trash button
            // Column 1, Row 1
            }else if case (1,1...(records.count + 1)) = (indexPath.column, indexPath.row){
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TrashCell.self), for: indexPath) as! TrashCell
                if !dataRowsVisibles.indices.contains(indexPath.row - 1){
                    return cell
                }
                cell.button.setTitle("🗑", for: .normal)
                if !(atributos?.permisotablaeliminarr ?? false){
                    cell.button.backgroundColor = UIColor(hexFromString: "#222222", alpha: 0.6)
                    cell.button.isUserInteractionEnabled = false
                    cell.button.isEnabled = false
                }else{
                    cell.button.backgroundColor = .clear
                    cell.button.isUserInteractionEnabled = true
                    cell.button.isEnabled = true
                }
                if indexPath.row != 0{
                    cell.button.addTarget(self, action: #selector(self.trashBtnAction(_ :)), for: .touchUpInside)
                    cell.button.tag = indexPath.row - 1
                }
                return cell
            // Preview button
            // Colum 2, Row 1
            }else if case (2,1...(records.count + 1)) = (indexPath.column, indexPath.row){
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: PreviewCell.self), for: indexPath) as! PreviewCell
                if !dataRowsVisibles.indices.contains(indexPath.row - 1){
                    return cell
                }
                cell.button.setTitle("👁‍🗨", for: .normal)
                if !(atributos?.permisotablamostrar ?? false){
                    cell.button.backgroundColor = UIColor(hexFromString: "#222222", alpha: 0.6)
                    cell.button.isUserInteractionEnabled = false
                    cell.button.isEnabled = false
                }else{
                    cell.button.backgroundColor = .clear
                    cell.button.isUserInteractionEnabled = true
                    cell.button.isEnabled = true
                }
                if indexPath.row != 0{
                    cell.button.addTarget(self, action: #selector(self.visualizeBtnAction(_ :)), for: .touchUpInside)
                    cell.button.tag = indexPath.row - 1
                }
                return cell
            // Number of the row
            // Colum 3, Row 1
            }else if case (3, 1...(records.count + 1)) = (indexPath.column, indexPath.row) {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: FilaCell.self), for: indexPath) as! FilaCell
                cell.label.text = "\(indexPath.row)"
                return cell
            // Data of rows
            // Column 3, Row 1 >
            }else if case (4...(self.nameElement.count + 4) ,1...(records.count + 1)) = (indexPath.column, indexPath.row){
                
                if dataRowsVisibles.indices.contains(indexPath.row - 1){
                    var isColumnHidden = false
                    if self.columnByRowHidden[self.nameElement[indexPath.column - 4].id] != nil {
                        let rowsOk : [Int] = (self.columnByRowHidden[self.nameElement[indexPath.column - 4].id]) as? [Int] ?? []
                        isColumnHidden = rowsOk.contains(indexPath.row - 1) ? true : false
                    }
                    if isColumnHidden{
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
                        cell.label.text = ""
                        return cell
                    }
                    
                    let txt = dataRowsVisibles[indexPath.row - 1][indexPath.column - 4]
                    if txt.contains("wizard") || txt.contains("boton"){
                        
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: WzrdCell.self), for: indexPath) as! WzrdCell
                        cell.button.addTarget(self, action: #selector(self.wizardBtnAction(_ :)), for: .touchUpInside)
                        let c = indexPath.column - 4
                        let r = indexPath.row - 1
                        cell.button.setTitle(txt.replacingOccurrences(of: "wizard|", with: "").replacingOccurrences(of: "boton|", with: ""), for: .normal)
                        let idBtnWzr = txt.contains("wizard") ? "9" : "8"
                        cell.button.tag = Int("\(idBtnWzr)\(c)09990\(r)") ?? 0
                        
                        return cell
                    }else{
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
                        cell.label.text = txt
                        return cell
                    }
                }else{
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
                    // Getting Totales
                    for formula in ff{
                        if formula.id == self.nameElement[indexPath.column - 4].id{
                            
                            if formula.formula == ""{
                                cell.label.text = "-"
                                return cell
                            }
                            if formula.formula.contains(","){
                                let sum = formula.formula.split{$0 == ","}.map(String.init)
                                let doubleArray = sum.map { Float($0)!}
                                let average = (doubleArray as NSArray).value(forKeyPath: "@avg.floatValue")
                                cell.label.text = "\(average ?? 0)"
                                return cell
                            }else{
                                let mathExpression = NSExpression(format: "\(formula.formula)")
                                let mathValue = mathExpression.expressionValue(with: nil, context: nil) as? Double
                                let valueString = String(mathValue ?? 0)
                                cell.label.text = "\(valueString)"
                                return cell
                            }
                            
                        }
                    }
                    cell.label.text = "-"
                    return cell
                }
                
            // Title of rows
            // Column 3, Row 0 >
            }else if case (4...(self.nameElement.count + 3), 0) = (indexPath.column, indexPath.row){
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TitleCell.self), for: indexPath) as! TitleCell
                cell.label.text = self.nameElement[indexPath.column - 4].title
                cell.label.textColor = UIColor(hexFromString: atributos!.colorheadertexto)
                cell.label.backgroundColor = UIColor(hexFromString: atributos!.colorheader)
                return cell
            }
            
        }
        return nil
    }
    
    
    // MARK: - DELEGATE SPREADSHEETVIEW
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        //print("Selected: (row: \(indexPath.row), column: \(indexPath.column))")
        //print("DATA: \(dataRows[indexPath.row - 1][indexPath.column - 4])")
        //print("INDEX: \(indexPath.row)")
    }
    
    
}
