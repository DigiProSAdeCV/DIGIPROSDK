import Foundation

import Eureka

public final class HeaderTabRow: Row<HeaderTabCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<HeaderTabCell>(nibName: "jwmyqAPYSZecsSu")
    }
}
