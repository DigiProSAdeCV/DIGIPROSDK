//
//  PDFOCRMain.swift
//  DocForm
//
//  Created by Jose Eduardo Rodriguez on 25/01/23.
//

import UIKit

open class PDFOCRMain {
    static func createModule(navigation: UINavigationController, elements: [(id: String, type: String, kind: Any?, element: Elemento?)], pdfData: Data, OCRServiceResults: OCRObject) -> UIViewController {
        let controller: PDFOCRViewController = PDFOCRViewController(elementsInPlantilla: elements, pdfData: pdfData, OCRServiceResults: OCRServiceResults)
        
        //if let view = controller {
            
            let presenter = PDFOCRPresenter()
            let router = PDFOCRRouter()
            let interactor = PDFOCRInteractor()
            
            controller.presenter = presenter
            
            presenter.view = controller
            presenter.interactor = interactor
            presenter.router = router
            
            router.navigation = navigation
            
            interactor.presenter = presenter
            
            return controller
        //}
        //return UIViewController()
    }
}
