//
//  PDFOCRPresenter.swift
//  DocForm
//
//  Created by Jose Eduardo Rodriguez on 25/01/23.
//

import Foundation

class PDFOCRPresenter {
    var interactor: PDFOCRInteractorProtocol?
    weak var view: PDFOCRViewProtocol?
    var router: PDFOCRRouterProtocol?
}

extension PDFOCRPresenter: PDFOCRPresenterProtocol {
    func visualizeResultsInElement() {
        router?.presentResults()
    }
    
    func goToBack() {
        router?.returnScreen()
    }
}
