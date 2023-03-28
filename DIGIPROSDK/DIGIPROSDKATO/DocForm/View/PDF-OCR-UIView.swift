//
//  PDF-OCR-UIView.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 04/01/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import UIKit

protocol PDFOCRUIViewDelegate: AnyObject {
    func addDocumentProtocol()
    func removeDocumentProtocol()
    func replaceDocumentProtocol()
    func typeDocProtocol()
    func metaActionProtocol()
    func showResultsProtocol()
    func ocrPDFProtocol()
    func historicOfDocumentsProtocol()
}

class PDFOCRUIView: UIView {
    
    lazy var originalCellHeight: CGFloat = 175.0
    lazy var newCellHeight: CGFloat = 425.0
    weak var delegate: PDFOCRUIViewDelegate?
    convenience init(delegate: PDFOCRUIViewDelegate) {
        self.init()
        self.delegate = delegate
    }
    lazy var bgHabilitado: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var headersView: HeaderView = {
        let view = HeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    // BOTON AGREGAR DOCUMENTO
    lazy var btnAddDocument: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.blue
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setImage(UIImage(named: "ic_meta", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(addDocument(_:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var btnAddDocumentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Agregar"
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        return label
    }()
    lazy var addDocumentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(btnAddDocument)
        stackView.addArrangedSubview(btnAddDocumentLabel)
        return stackView
    }()
    
    lazy var btnTrashDocument: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.red
        button.setImage(UIImage(named: "ic_cleanMeta", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(removeDocument(_:)), for: UIControl.Event.touchUpInside)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        return button
    }()
    lazy var btnTrashLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Eliminar"
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        return label
    }()
    lazy var trashDocumentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(btnTrashDocument)
        stackView.addArrangedSubview(btnTrashLabel)
        return stackView
    }()
    
    lazy var btnReplaceDocument: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemYellow
        button.setImage(UIImage(named: "ic_sustituir", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(replaceDocument(_:)), for: UIControl.Event.touchUpInside)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        return button
    }()
    lazy var btnReplaceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sustituir"
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        return label
    }()
    lazy var replaceDocumentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(btnReplaceDocument)
        stackView.addArrangedSubview(btnReplaceLabel)
        return stackView
    }()
    
    lazy var btnHistoricDocument: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.blue
        button.addTarget(self, action: #selector(historicOfDocuments(_:)), for: UIControl.Event.touchUpInside)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        return button
    }()
    lazy var btnHistoricLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Historico"
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        return label
    }()
    lazy var historicDocumentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(btnHistoricDocument)
        stackView.addArrangedSubview(btnHistoricLabel)
        return stackView
    }()
    
    lazy var GeneralStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8.5
        stackView.addArrangedSubview(trashDocumentStackView)
        stackView.addArrangedSubview(replaceDocumentStackView)
        stackView.addArrangedSubview(historicDocumentStackView)
        return stackView
    }()
    
    lazy var typeDocButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(typeDocAction(_:)), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        button.tintColor = .white
        return button
    }()
    lazy var lblTypeDoc: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var btnMeta: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.setImage(UIImage(named: "ic_down", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(metaAction(_:)), for: UIControl.Event.touchUpInside)
        button.tintColor = .white
        return button
    }()
    lazy var OCRButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemBlue
        button.addTarget(self, action: #selector(ocrPDF(_:)), for: UIControl.Event.touchUpInside)
        button.setTitle("Realizar OCR", for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        return button
    }()
    lazy var btnShowResults: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemBlue
        button.addTarget(self, action: #selector(showResults(_:)), for: UIControl.Event.touchUpInside)
        button.setTitle("Mostrar Resultados", for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        return button
    }()
    
    lazy var imgPreview: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        return image
    }()
    
    public func addViewsToParent() {
        
        let secondaryViews: [UIView] = [bgHabilitado, headersView, addDocumentStackView, imgPreview, GeneralStackView, btnShowResults, typeDocButton, btnMeta, lblTypeDoc, OCRButton]
        secondaryViews.forEach { self.addSubview($0) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addViewsToParent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        btnAddDocument.layer.cornerRadius = btnAddDocument.frame.height / 2
        btnTrashDocument.layer.cornerRadius = btnTrashDocument.frame.height / 2
        btnReplaceDocument.layer.cornerRadius = btnReplaceDocument.frame.height / 2
        btnHistoricDocument.layer.cornerRadius = btnHistoricDocument.frame.height / 2
        btnShowResults.layer.cornerRadius = 8
        OCRButton.layer.cornerRadius = 8
        
        NSLayoutConstraint.activate([
            
            bgHabilitado.topAnchor.constraint(equalTo: topAnchor),
            bgHabilitado.bottomAnchor.constraint(equalTo: bottomAnchor),
            bgHabilitado.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgHabilitado.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            headersView.topAnchor.constraint(equalTo: topAnchor),
            headersView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headersView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headersView.heightAnchor.constraint(equalToConstant: 55),
            
            addDocumentStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            addDocumentStackView.topAnchor.constraint(equalTo: headersView.bottomAnchor, constant: 35),
            addDocumentStackView.heightAnchor.constraint(equalToConstant: 55),
            
            imgPreview.topAnchor.constraint(equalTo: headersView.bottomAnchor, constant: 30),
            imgPreview.heightAnchor.constraint(equalToConstant: 180),
            imgPreview.widthAnchor.constraint(equalToConstant: 165),
            imgPreview.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            GeneralStackView.topAnchor.constraint(equalTo: imgPreview.bottomAnchor, constant: 30),
            GeneralStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            
            OCRButton.topAnchor.constraint(equalTo: GeneralStackView.bottomAnchor, constant: 15),
            OCRButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            OCRButton.heightAnchor.constraint(equalToConstant: 38),
            OCRButton.widthAnchor.constraint(equalToConstant: 210),
            
            btnShowResults.topAnchor.constraint(equalTo: GeneralStackView.bottomAnchor, constant: 15),
            btnShowResults.centerXAnchor.constraint(equalTo: centerXAnchor),
            btnShowResults.heightAnchor.constraint(equalToConstant: 38),
            btnShowResults.widthAnchor.constraint(equalToConstant: 215),
            
            typeDocButton.topAnchor.constraint(equalTo: GeneralStackView.bottomAnchor, constant: 5),
            typeDocButton.leadingAnchor.constraint(equalTo: lblTypeDoc.leadingAnchor, constant: 5),
            typeDocButton.heightAnchor.constraint(equalToConstant: 40.0),
            
            lblTypeDoc.topAnchor.constraint(equalTo: GeneralStackView.bottomAnchor, constant: 5),
            lblTypeDoc.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            
            btnMeta.topAnchor.constraint(equalTo: imgPreview.bottomAnchor, constant: 5),
            btnMeta.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            btnMeta.widthAnchor.constraint(equalToConstant: 40.0),
            btnMeta.heightAnchor.constraint(equalToConstant: 40.0),
        ])
    }
    
    @objc private func showResults(_ sender: UIButton) {
        delegate?.showResultsProtocol()
    }
    @objc private func ocrPDF(_ sender: UIButton) {
        delegate?.ocrPDFProtocol()
    }
    @objc private func metaAction(_ sender: UIButton) {
        delegate?.metaActionProtocol()
    }
    @objc private func typeDocAction(_ sender: UIButton) {
        delegate?.typeDocProtocol()
    }
    @objc private func historicOfDocuments(_ sender: UIButton) {
        delegate?.historicOfDocumentsProtocol()
    }
    @objc private func replaceDocument(_ sender: UIButton) {
        delegate?.replaceDocumentProtocol()
    }
    @objc private func removeDocument(_ sender: UIButton) {
        delegate?.removeDocumentProtocol()
    }
    @objc private func addDocument(_ sender: UIButton) {
        delegate?.addDocumentProtocol()
    }
}

