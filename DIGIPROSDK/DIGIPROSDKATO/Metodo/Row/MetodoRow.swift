import Foundation

import Eureka

public class _MetodoRow: Row<MetodoCell>, KeyboardReturnHandler {
    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?

    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<MetodoCell>(nibName: "aRKQbPJWgNiGmqb", bundle: Cnstnt.Path.framework)
    }
}

public final class MetodoRow: _MetodoRow, RowType { }

