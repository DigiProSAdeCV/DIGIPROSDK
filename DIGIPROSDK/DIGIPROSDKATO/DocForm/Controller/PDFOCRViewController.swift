//
//  PDFOCRViewController.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 09/01/23.
//

import UIKit

protocol PDFOCRViewControllerDelegate: AnyObject {
    func updateDictionaryData(elements: Array<[String:String]>)
}

class PDFOCRViewController: UIViewController {
    
    var presenter: PDFOCRPresenterProtocol?
    private var OCRServiceResults: OCRObject
    var viewOCR : PDFOCRViewUI?
    private var pdfData: Data
    weak var delegate: PDFOCRViewControllerDelegate?
    private var elementsInPlantilla: [(id: String, type: String, kind: Any?, element: Elemento?)] = []
    private lazy var newElementsInPlantilla: [(id: String, type: String, kind: Any?, element: Elemento?)] = []
    private lazy var dictionaryAndElements: Array<[String: String]> = Array<[String: String]>()
    var index: Int = 0
    
    init(elementsInPlantilla: [(id: String, type: String, kind: Any?, element: Elemento?)], pdfData: Data, presenter: PDFOCRPresenterProtocol? = nil, OCRServiceResults: OCRObject) {
        self.presenter = presenter
        self.pdfData = pdfData
        self.elementsInPlantilla = elementsInPlantilla
        self.OCRServiceResults = OCRServiceResults
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        viewOCR = PDFOCRViewUI(pdfData: pdfData, ocrCounter: OCRServiceResults, delegate: self)
        view = viewOCR
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newElementsInPlantilla = elementsInPlantilla.filter ({
            $0.type == "fecha" || $0.type == "texto" || $0.type == "numero"
        }).sorted { eleme1, elem2 in
            let first = eleme1.element?.atributos as? Atributos_Generales
            let second = elem2.element?.atributos as? Atributos_Generales
            return first?.titulo ?? "" < second?.titulo ?? ""
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.updateDictionaryData(elements: self.dictionaryAndElements)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewOCR?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        viewOCR?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        viewOCR?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        viewOCR?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
}

extension PDFOCRViewController: PDFOCRViewProtocol {}

extension PDFOCRViewController: PDFOCRViewUIDelegate {
    func openComboBox() {
        let comboController = ComboElementsViewController(elements: newElementsInPlantilla, delegate: self)
        self.present(comboController, animated: true)
    }
    
    func assignResults() {
        // Key - FormElec id : Value - UITextView String
        let dict = ["\(newElementsInPlantilla[index].id)": "\(viewOCR?.wordsArraySelected.text ?? "")"]
        dictionaryAndElements.append(dict)
        viewOCR?.wordsArraySelected.text = "" // Clean UITextView
        viewOCR?.wordsCollection.reloadData() // Clean Cells and information
        viewOCR?.elementsSelectedOrdered.removeAll() // Clean Array information
        viewOCR?.selectS.removeAll()
        viewOCR?.indexS.removeAll()
        viewOCR?.elementsforAssignButton.setTitle("Selecciona el campo de texto deseado.\t↓", for: UIControl.State.normal)
        
        viewOCR?.assignButton.isEnabled = false
        viewOCR?.assignButton.backgroundColor = UIColor.lightGray
    }
    
    func presentPDF() {
        let preview = WebPDFViewControllerMain.create(pdfString: pdfData.base64EncodedString(), nameOfFile: "")
        self.present(preview, animated: true)
    }
    
    func notifyBack() {
        
    }
}

extension PDFOCRViewController: ComboElementsViewControllerDelegate {
    func didTapElementAtIndexPath(_ row: Int) {
        self.index = row
        let model = newElementsInPlantilla[row].element?.atributos as? Atributos_Generales
        viewOCR?.elementsforAssignButton.setTitle(model?.titulo ?? "", for: UIControl.State.normal)
        if viewOCR?.elementsSelectedOrdered.count ?? 0 > 0 {
            viewOCR?.assignButton.isEnabled = true
            viewOCR?.assignButton.backgroundColor = UIColor.systemBlue
        } else {
            viewOCR?.assignButton.isEnabled = false
            viewOCR?.assignButton.backgroundColor = UIColor.lightGray
        }
    }
}
