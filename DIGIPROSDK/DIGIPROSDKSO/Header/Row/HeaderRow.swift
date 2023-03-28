import Foundation

import Eureka

public final class HeaderRow: Row<HeaderCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<HeaderCell>(nibName: "UvZaozMsUJEmHVu")
    }
}
