import Foundation

import Eureka

// MARK: SwitchRow

open class _LogicoRow: Row<LogicoCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

/// Boolean row that has a UISwitch as accessoryType
public final class LogicoRow: _LogicoRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<LogicoCell>()
    }
}
