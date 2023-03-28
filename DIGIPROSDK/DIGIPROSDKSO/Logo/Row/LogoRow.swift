import Foundation

import Eureka

public class _LogoRow: Row<LogoCell>, KeyboardReturnHandler {
    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<LogoCell>(nibName: "cnFagKDSBMKwqPh", bundle: Cnstnt.Path.framework)
    }
    
    
    public override func updateCell() {
        if UIDevice.current.orientation.isLandscape{
            self.cell.layoutIfNeeded()
        }else{
           self.cell.layoutIfNeeded()
        }
    }
}

public final class LogoRow: _LogoRow, RowType { }
