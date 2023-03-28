import Foundation

import Eureka

extension NuevaPlantillaViewController{
    
    public func obtainModal(_ element: String) -> Promise<Bool>{
        
        return Promise<Bool>{ resolve, reject in
            let form = getElementsFromSectionToModal(element)
            if form.allRows.count == 0{ reject(APIErrorResponse.defaultError) }
            let controller = ModalViewController(nibName: "yHTCdkjEhoGdnbk", bundle: Cnstnt.Path.framework)
            controller.initForm(form, self)
            controller.modalPresentationStyle = .fullScreen
            let presenter = Presentr(presentationType: .popup)
            presenter.dismissOnSwipe = false
            presenter.dismissOnTap = false
            
            self.customPresentViewController(presenter, viewController: controller, animated: true, completion: {
                controller.setVisibleRows()
                resolve(true)
            })
        }
        
    }
    
}
