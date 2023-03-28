import Foundation

import Eureka

public class _SliderNewRow: Row<SliderNewCell>, KeyboardReturnHandler{
    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<SliderNewCell>(nibName: "tlCqKGHlLShlKFL", bundle: Cnstnt.Path.framework)
    }
}

public final class SliderNewRow: _SliderNewRow, RowType { }

