import Foundation

import Eureka

public class _TextoAreaRow: Row<TextoAreaCell>, KeyboardReturnHandler{
    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            self.value = String(describing: v)
            return String(describing: v)
        }
        cellProvider = CellProvider<TextoAreaCell>(nibName: "CWOJqVATXpVOJys", bundle: Cnstnt.Path.framework)
    }
}

public final class TextoAreaRow: _TextoAreaRow, RowType { }
