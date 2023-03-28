import Foundation

import Eureka

// MARK: ListaRow

open class _ListaRowOf<T: Equatable> : Row<ListaCell> {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellStyle = .default
        cellProvider = CellProvider<ListaCell>()
    }
}

/// A generic row with a button. The action of this button can be anything but normally will push a new view controller
/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public final class ListaRow: _ListaRowOf<String>, RowType { }
