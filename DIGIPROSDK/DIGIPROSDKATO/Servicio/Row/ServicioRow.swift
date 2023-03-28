import Foundation
import Eureka

public class _ServicioRowOf<T: Equatable>: Row<ServicioCell>, KeyboardReturnHandler {
    
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    open var presentationMode: PresentationMode<UIViewController>?
    open var onPresentCallback: ((FormViewController, SelectorViewController<SelectorRow<Cell>>) -> Void)?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            self.value = String(describing: v)
            return String(describing: v)
        }
        cellProvider = CellProvider<ServicioCell>(nibName: "ZwVvzocbowppujZ", bundle: Cnstnt.Path.framework)
    }
    
    open override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            if let presentationMode = presentationMode {
                if let controller = presentationMode.makeController() {
                    let presented = (UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController
                    if presented == nil{
                        presentationMode.present(controller, row: self, presentingController: self.cell.actionDelegate!)
                    } else {
                        controller.modalPresentationStyle = .fullScreen
                        ((UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController as? UINavigationController)?.present(controller, animated: true, completion: nil)
                    }
                    onPresentCallback?(self.cell.actionDelegate!, controller as! SelectorViewController<SelectorRow<ServicioCell>>)
                } else {
                    presentationMode.present(nil, row: self, presentingController: self.cell.actionDelegate!)
                }
            }
        }
    }
    
    open override func customUpdateCell() {
        super.customUpdateCell()
    }
    
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        
        guard let rowVC = segue.destination as Any as? SelectorViewController<SelectorRow<Cell>> else { return }
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
        
        (segue.destination as? RowControllerType)?.onDismissCallback = presentationMode?.onDismissCallback
    }
}

public final class ServicioRow: _ServicioRowOf<String>, RowType { }

