import Foundation

import Eureka

// MARK: VideoRow
open class _VideoRowOf<T: Equatable> : Row<VideoCell>, KeyboardReturnHandler {
    
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    open var presentationMode: PresentationMode<UIViewController>?
    open var onPresentCallback: ((FormViewController, SelectorViewController<SelectorRow<Cell>>) -> Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            self.value = String(describing: v)
            return String(describing: "")
        }
        cellProvider = CellProvider<VideoCell>.init()
        
    }
    
}

/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public final class VideoRow: _VideoRowOf<String>, RowType {}
