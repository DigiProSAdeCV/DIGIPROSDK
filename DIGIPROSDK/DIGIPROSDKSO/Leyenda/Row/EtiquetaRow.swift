import Foundation

import Eureka

public class _EtiquetaRow: Row<EtiquetaCell>, KeyboardReturnHandler {
    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<EtiquetaCell>(nibName: "nQAxAvMMFyDBluq", bundle: Cnstnt.Path.framework)
    }
}

public final class EtiquetaRow: _EtiquetaRow, RowType { }
