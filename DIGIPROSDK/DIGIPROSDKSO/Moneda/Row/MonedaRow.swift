import Foundation

import Eureka

public class _MonedaRow: Row<MonedaCell>, KeyboardReturnHandler {
    
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            self.value = String(describing: v)
            return String(describing: v)
        }
        cellProvider = CellProvider<MonedaCell>(nibName: "nFHSmhlPSkpcCeG", bundle: Cnstnt.Path.framework)
    }
}

/// A row where the user can enter a decimal number.
public final class MonedaRow: _MonedaRow, RowType { }
