//
//  PDFOCRRouter.swift
//  DocForm
//
//  Created by Jose Eduardo Rodriguez on 25/01/23.
//

import UIKit

class PDFOCRRouter: ComboElementsViewControllerDelegate {
    func didTapElementAtIndexPath(_ row: Int) {
        
    }
    
    var navigation: UINavigationController?
    
}

extension PDFOCRRouter: PDFOCRRouterProtocol {
    func openComboBox() {
        
        //navigation?.pushViewController(comboController, animated: true)
    }
    
    func presentResults() {
        // Asignar a un campo.
    }
    
    func presentFile() {
//        navigation?.pushViewController(UIViewController(), animated: true)
    }
    
    func returnScreen() {
        //navigation?.popViewController(animated: true)
    }
}
