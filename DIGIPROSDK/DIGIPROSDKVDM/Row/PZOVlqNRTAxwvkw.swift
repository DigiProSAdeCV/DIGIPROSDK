import Foundation

import Eureka

// MARK: VeridiumRow
open class _VeridiumRowOf<T: Equatable> : Row<VeridiumCell>, KeyboardReturnHandler {
    
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    open var presentationMode: PresentationMode<UIViewController>?
    open var onPresentCallback: ((FormViewController, SelectorViewController<SelectorRow<Cell>>) -> Void)?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            self.value = String(describing: v)
            return String(describing: v)
        }
        cellProvider = CellProvider<VeridiumCell>(nibName: "fSERIqRPgFEaDYv", bundle: Cnstnt.Path.framework)
    }
    
}

/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public final class VeridiumRow: _VeridiumRowOf<String>, RowType { }
