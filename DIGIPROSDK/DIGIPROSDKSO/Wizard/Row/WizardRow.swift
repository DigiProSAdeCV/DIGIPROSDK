import Foundation

import Eureka

public class _WizardRow: Row<WizardCell> {
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
    }
    
    public override func customUpdateCell() {
        super.customUpdateCell()
    }
    
    public override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
    }
}

/// A row where the user can enter a decimal number.
public final class WizardRow: _WizardRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<WizardCell>(nibName: "ImMtdcZXsuIXqeB", bundle: Cnstnt.Path.framework)
    }
}
