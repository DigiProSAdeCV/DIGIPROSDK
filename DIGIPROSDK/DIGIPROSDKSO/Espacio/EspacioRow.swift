import Foundation

import Eureka

public class _EspacioRow: Row<EspacioCell>, KeyboardReturnHandler{
    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            self.value = String(describing: v)
            return String(describing: v)
        }
        cellProvider = CellProvider<EspacioCell>(nibName: "eGonBZAbRdOzcPR", bundle: Cnstnt.Path.framework)
    }
    
}

public final class EspacioRow: _EspacioRow, RowType { }
