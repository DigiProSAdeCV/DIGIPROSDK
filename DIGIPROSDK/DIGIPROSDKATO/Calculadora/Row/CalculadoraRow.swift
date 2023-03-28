import UIKit

import Eureka

public class _CalculadoraRow: Row<CalculadoraCell>, KeyboardReturnHandler{
    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<CalculadoraCell>(nibName: "OazKxFFqktwcNlC", bundle: Cnstnt.Path.framework)
    }
}

public final class CalculadoraRow: _CalculadoraRow, RowType { }
