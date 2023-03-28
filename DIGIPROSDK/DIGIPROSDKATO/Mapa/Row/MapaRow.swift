import Foundation

import Eureka

// MARK: MapaRow
open class _MapaRowOf<T: Equatable> : Row<MapaCell>, KeyboardReturnHandler {
    
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    open var presentationMode: PresentationMode<UIViewController>?
    open var onPresentCallback: ((FormViewController, SelectorViewController<SelectorRow<Cell>>) -> Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            self.value = String(describing: v)
            return String(describing: v)
        }
        cellProvider = CellProvider<MapaCell>(nibName: "qBucBDHXkgXnZgS", bundle: Cnstnt.Path.framework)
    }
    
}

/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public final class MapaRow: _MapaRowOf<String>, RowType {}
