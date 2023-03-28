import UIKit

import Eureka

open class _ListaTemporalRowOf<T: Equatable> : Row<ListaTemporalCell> {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellStyle = .default
        cellProvider = CellProvider<ListaTemporalCell>()
    }
}

 public final class ListaTemporalRow: _ListaTemporalRowOf<String>, RowType { }
