import UIKit
import Eureka

open class _MarcadoDocumentoRowOf<T: Equatable>: Row<MarcadoDocumentoCell> {
    open var presentationMode: PresentationMode<UIViewController>?
    open var onPresentCallback: ((FormViewController, SelectorViewController<SelectorRow<Cell>>) -> Void)?
    open var customController: MarcadoDocumentoViewController?
    
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellStyle = .default
        cellProvider = CellProvider<MarcadoDocumentoCell>()
        customController = MarcadoDocumentoViewController(nibName: "MDSBusMdlrJCpBZ", bundle: Cnstnt.Path.framework)
    }
    open override func customDidSelect() {
        super.customDidSelect()
       
    }
    
    public func onDisplaySeacthList(){
        if !isDisabled {
            if let presentationMode = presentationMode {
                if let controller = presentationMode.makeController() {
                    presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
                    onPresentCallback?(cell.formViewController()!, controller as! SelectorViewController<SelectorRow<MarcadoDocumentoCell>>)
                } else {
                    presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
                }
            }
        }
    }
    
    open override func customUpdateCell() {
        super.customUpdateCell()
    }
    
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
    }
    
}
/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public final class MarcadoDocumentoRow: _MarcadoDocumentoRowOf<String>, RowType { }

