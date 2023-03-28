import Foundation

import Eureka

public class _PaginaRow: Row<PaginaCell>, KeyboardReturnHandler{
    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            self.value = String(describing: v)
            return String(describing: v)
        }
        cellProvider = CellProvider<PaginaCell>(nibName: "zswjQdQXbSlUZTV", bundle: Cnstnt.Path.framework)
    }
    
}

public final class PaginaRow: _PaginaRow, RowType { }
