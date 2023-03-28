import Foundation

import Eureka

// MARK: FirmaRow
open class _FirmaRowOf<T: Equatable> : Row<FirmaCell>, KeyboardReturnHandler {
    
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
        cellProvider = CellProvider<FirmaCell>(nibName: "vWslQCnQjKrAoxn", bundle: Cnstnt.Path.framework)
    }
    
    open override func customDidSelect() {
        super.customDidSelect()
    }
    
}

/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public final class FirmaRow: _FirmaRowOf<String>, RowType { }
