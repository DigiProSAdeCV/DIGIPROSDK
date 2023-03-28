//
//  PDFOCRProtocols.swift
//  DocForm
//
//  Created by Jose Eduardo Rodriguez on 25/01/23.
//

import Foundation

protocol PDFOCRPresenterProtocol : AnyObject {
    func goToBack()
    func visualizeResultsInElement()
}

protocol PDFOCRViewProtocol : AnyObject {}

protocol PDFOCRInteractorProtocol : AnyObject {
}

protocol PDFOCRRouterProtocol : AnyObject {
    func returnScreen()
    func presentFile()
    func presentResults()
    func openComboBox()
}
