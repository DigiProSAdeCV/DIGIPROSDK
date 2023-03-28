import Foundation

import Eureka

open class _FechaRow: _FechaFieldRow {
    required public init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = DateFormatter()
        dateFormatter?.timeStyle = .none
        dateFormatter?.dateStyle = .medium
        dateFormatter?.locale = Locale(identifier: "es")
        cellProvider = CellProvider<FechaCell>()
    }
}

/// A row with an Date as value where the user can select a date from a picker view.
public final class FechaRow: _FechaRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _FechaFieldRow: Row<FechaCell>, DatePickerRowProtocol, NoValueDisplayTextConformance {
    
    /// The minimum value for this row's UIDatePicker
    open var minimumDate: Date?
    
    /// The maximum value for this row's UIDatePicker
    open var maximumDate: Date?
    
    /// The interval between options for this row's UIDatePicker
    open var minuteInterval: Int?
    
    /// The formatter for the date picked by the user
    open var dateFormatter: DateFormatter?
    
    open var noValueDisplayText: String? = nil
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
