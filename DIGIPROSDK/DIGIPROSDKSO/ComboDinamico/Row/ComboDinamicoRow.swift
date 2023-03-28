import Foundation

import Eureka

// MARK: ComboDinamicoRow

open class _ComboDinamicoRowOf<T: Equatable> : Row<ComboDinamicoCell>
{
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellStyle = .default
        cellProvider = CellProvider<ComboDinamicoCell>()
    }
}

/// A generic row with a button. The action of this button can be anything but normally will push a new view controller
/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public final class ComboDinamicoRow: _ComboDinamicoRowOf<String>, RowType { }
