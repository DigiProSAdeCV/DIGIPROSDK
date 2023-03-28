import Foundation

import Eureka

public class _RangoFechasRow: Row<RangoFechasCell>, KeyboardReturnHandler{
    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    open var presentationMode: PresentationMode<UIViewController>?
    open var onPresentCallback: ((FormViewController, SelectorViewController<SelectorRow<Cell>>) -> Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellStyle = .default
        cellProvider = CellProvider<RangoFechasCell>(nibName: "CXimrlBHkoRttsO", bundle: Cnstnt.Path.framework)
        
    }
    
    open override func customUpdateCell() {
        super.customUpdateCell()
    }

}

public final class RangoFechasRow: _RangoFechasRow, RowType { }
