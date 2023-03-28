import Foundation

import Eureka

public class _CodigoBarrasRow: Row<CodigoBarrasCell>, KeyboardReturnHandler{
    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    open var presentationMode: PresentationMode<UIViewController>?
    open var onPresentCallback: ((FormViewController, SelectorViewController<SelectorRow<Cell>>) -> Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<CodigoBarrasCell>()
        let controller = CodigoBarrasViewController(nibName: "eSsJnfvToaWKxor", bundle: Cnstnt.Path.framework)
        controller.flag = "codigoBarra"
        controller.row = self
        //controller.modalPresentationStyle = .fullScreen
        presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return controller
            }, onDismiss: { [weak self] vc in
                vc.dismiss(animated: true)
                if !controller.reset, controller.textValidation != ""{
                    self?.value = controller.textValidation
                    self?.cell.setEdited(v: controller.textValidation)
                }
        })
    }
    
    func customSelect(){
        if !isDisabled {
            if let presentationMode = presentationMode {
                if let controller = presentationMode.makeController() {
                    presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
                    onPresentCallback?(cell.formViewController()!, controller as! SelectorViewController<SelectorRow<CodigoBarrasCell>>)
                } else {
                    presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
                }
            }
        }
    }
    
    open override func customDidSelect() {
        super.customDidSelect()
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

public final class CodigoBarrasRow: _CodigoBarrasRow, RowType { }
