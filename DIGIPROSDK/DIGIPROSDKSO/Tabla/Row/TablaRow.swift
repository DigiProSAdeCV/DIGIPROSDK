import Foundation

import Eureka

// MARK: SeccionRow
open class _TablaRowOf<T: Equatable> : Row<TablaCell> {
    open var presentationMode: PresentationMode<UIViewController>?
    open var onPresentCallback: ((FormViewController, SelectorViewController<SelectorRow<Cell>>) -> Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellStyle = .default
        cellProvider = CellProvider<TablaCell>(nibName: "zJaRNNGXEbKREdn", bundle: Cnstnt.Path.framework)
    }
    
    
    open override func customUpdateCell() {
        super.customUpdateCell()
    }
    
}

/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public final class TablaRow: _TablaRowOf<String>, RowType { }
