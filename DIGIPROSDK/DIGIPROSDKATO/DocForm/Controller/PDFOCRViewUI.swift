//
//  PDFOCRViewUI.swift
//  DocForm
//
//  Created by Jose Eduardo Rodriguez on 25/01/23.
//

import UIKit
import PDFKit

protocol PDFOCRViewUIDelegate: AnyObject {
    func notifyBack()
    func presentPDF()
    func assignResults()
    func openComboBox()
}

class PDFOCRViewUI: UIView, ViewScrollable {
    var contentView: UIView = UIView()
    var mainScrollView: UIScrollView = UIScrollView()
    
    weak var delegate: PDFOCRViewUIDelegate?
    var navigationController: UINavigationController?
    private var pdfData: Data = Data()
    var ocrCounter: OCRObject = OCRObject()
    var selectS: Array<Int> = Array<Int>()
    var indexS: Array<Int> = Array<Int>()
    var elementsSelectedOrdered: Array<String> = Array<String>()
    
    convenience init(pdfData: Data, ocrCounter: OCRObject, delegate: PDFOCRViewUIDelegate) {
        self.init()
        self.ocrCounter = ocrCounter
        self.pdfData = pdfData
        self.delegate = delegate
        setupImage()
    }
    
    lazy var imageDocument: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.isUserInteractionEnabled = true
        return image
    }()
    /*lazy var closeControllerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemRed
        button.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, with: nil), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(goToBack(_:)), for: UIControl.Event.touchUpInside)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        return button
    }()*/
    lazy var visualizeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.blue
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setTitle("Visualizar", for: .normal)
        button.addTarget(self, action: #selector(presentFile(_:)), for: UIControl.Event.touchUpInside)
        button.layer.cornerRadius = 8
        return button
    }()
    lazy var wordSelected: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Selecciona la palabra a asignar:"
        label.textColor = UIColor.black
        label.font = .italicSystemFont(ofSize: 15)
        return label
    }()
    lazy var staticResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Resultado"
        label.textColor = UIColor.black
        label.font = .italicSystemFont(ofSize: 15)
        return label
    }()
    lazy var wordsArraySelected: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = UIColor.black
        textView.font = .italicSystemFont(ofSize: 14)
        textView.backgroundColor = UIColor.white
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .caption1), size: 15)
        return textView
    }()
    lazy var assignToElement: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Asignar al elemento:"
        label.font = .italicSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        label.font = .italicSystemFont(ofSize: 15)
        return label
    }()
    lazy var elementsforAssignButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .italicSystemFont(ofSize: 13)
        button.layer.borderWidth = 1.2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        button.setTitle("Selecciona el campo de texto deseado.\t↓", for: UIControl.State.normal)
        button.addTarget(self, action: #selector(openComboBox(_:)), for: UIControl.Event.touchUpInside)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        return button
    }()
    lazy var assignButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setTitle("Asignar", for: .normal)
        button.addTarget(self, action: #selector(assignResults(_:)), for: UIControl.Event.touchUpInside)
        button.layer.cornerRadius = 8
        return button
    }()
    lazy var wordsCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = UIColor.clear
        collection.register(PDFOCRCollectionViewCell.self, forCellWithReuseIdentifier: PDFOCRCollectionViewCell.NSIdentifier)
        collection.register(HeaderForSectionsReusableView.self, forSupplementaryViewOfKind: HeaderForSectionsReusableView.headerKind, withReuseIdentifier: HeaderForSectionsReusableView.ReusableViewIdentifier)
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        configScroll() // Initialize Scroll
        let views: [UIView] = [/*closeControllerButton, */imageDocument, visualizeButton, wordSelected, wordsCollection, staticResultLabel, wordsArraySelected, assignToElement, elementsforAssignButton, assignButton]
        
        views.forEach({ contentView.addSubview($0) })
        setupCollectionView()
        assignButton.isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        wordsCollection.allowsMultipleSelection = true
        wordsCollection.delegate = self
        wordsCollection.dataSource = self
    }
    
    private func setupImage() {
        let fileStream: String = pdfData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        if let data = Data(base64Encoded: fileStream, options: .ignoreUnknownCharacters) {
            let thumbnailSize = CGSize(width: 500, height: 500)
            DispatchQueue.main.async {
                self.imageDocument.image = self.generatePdfThumbnail(of: thumbnailSize, for: URL(string: fileStream)!, data: data, atPage: 0)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //closeControllerButton.layer.cornerRadius = closeControllerButton.frame.height / 2
        NSLayoutConstraint.activate([
//            closeControllerButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
//            closeControllerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
//            closeControllerButton.heightAnchor.constraint(equalToConstant: 40),
//            closeControllerButton.widthAnchor.constraint(equalToConstant: 40),
            imageDocument.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            imageDocument.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageDocument.heightAnchor.constraint(equalToConstant: 240),
            imageDocument.widthAnchor.constraint(equalToConstant: 165),
            
            visualizeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            visualizeButton.widthAnchor.constraint(equalToConstant: 120),
            visualizeButton.bottomAnchor.constraint(equalTo: imageDocument.bottomAnchor),
            
            wordSelected.topAnchor.constraint(equalTo: imageDocument.bottomAnchor, constant: 20),
            wordSelected.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            wordsCollection.topAnchor.constraint(equalTo: wordSelected.bottomAnchor, constant: 10),
            wordsCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wordsCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            wordsCollection.heightAnchor.constraint(equalToConstant: CGFloat(ocrCounter.OCR.count * 240)),
            
            staticResultLabel.topAnchor.constraint(equalTo: wordsCollection.bottomAnchor, constant: 20),
            staticResultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            wordsArraySelected.topAnchor.constraint(equalTo: staticResultLabel.bottomAnchor, constant: 8),
            wordsArraySelected.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            wordsArraySelected.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            wordsArraySelected.heightAnchor.constraint(equalToConstant: 60),
            
            assignToElement.topAnchor.constraint(equalTo: wordsArraySelected.bottomAnchor, constant: 20),
            assignToElement.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            elementsforAssignButton.topAnchor.constraint(equalTo: assignToElement.bottomAnchor, constant: 10.0),
            elementsforAssignButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            elementsforAssignButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            elementsforAssignButton.heightAnchor.constraint(equalToConstant: 35),
            
            assignButton.topAnchor.constraint(equalTo: assignToElement.bottomAnchor, constant: 70),
            assignButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            assignButton.widthAnchor.constraint(equalToConstant: 195),
            assignButton.heightAnchor.constraint(equalToConstant: 48),
            assignButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }
    
    // MARK: UICollectionViewCompositionalLayout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            
            let pairItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(148), heightDimension: .fractionalHeight(0.20)))
            pairItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 3)
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .absolute(160)), subitems: [pairItem])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 6, leading: 6, bottom: 0, trailing: 6)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.boundarySupplementaryItems = [
                .init(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50)), elementKind: HeaderForSectionsReusableView.headerKind, alignment: .topLeading)
            ]
            return section
        }
    }
    /// Function generates an Image from a PDF
    private func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, data documentData: Data, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(data: documentData)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }
    
    @objc func goToBack(_ sender: UIButton) {
        delegate?.notifyBack()
    }
    
    @objc func presentFile(_ sender: UIButton) {
        delegate?.presentPDF()
    }
    
    @objc func assignResults(_ sender: UIButton) {
        delegate?.assignResults()
    }
    
    @objc func openComboBox(_ sender: UIButton) {
        delegate?.openComboBox()
    }
}

extension PDFOCRViewUI: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplementaryElement = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderForSectionsReusableView.ReusableViewIdentifier, for: indexPath) as! HeaderForSectionsReusableView
        supplementaryElement.titleLabel.text = "Página \(indexPath.section + 1)"
        return supplementaryElement
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PDFOCRCollectionViewCell.NSIdentifier, for: indexPath) as! PDFOCRCollectionViewCell
        cell.titleLabel.text = " \(ocrCounter.OCR[indexPath.section].words[indexPath.row])"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        var dataP = -1
        var indexP = -1
        var selectP = -1
        var result = 0
        
        for data in elementsSelectedOrdered {
            dataP = dataP + 1
            if data == ocrCounter.OCR[indexPath.section].words[indexPath.row] {
                for index in indexS {
                    indexP = indexP + 1
                    if index == indexPath.row {
                        for select in selectS {
                            selectP = selectP + 1
                            if select == indexPath.section {
                                //if ((dataP == indexP) && (selectP == indexP)) {
                                    result = dataP
                                    
                                //}
                            }
                        }
                    }
                }
            }
        }
        
        elementsSelectedOrdered.remove(at: result)
        indexS.remove(at: result)
        selectS.remove(at: result)
        
        self.wordsArraySelected.text = "\(elementsSelectedOrdered.compactMap({ $0 }).joined(separator: ", "))".replacingOccurrences(of: ",", with: "")
        
        assignButton.isEnabled = elementsSelectedOrdered.count > 0 ? true : false
        assignButton.isEnabled = elementsforAssignButton.titleLabel?.text == "Selecciona el campo de texto deseado.\t↓" ? false : true
        assignButton.backgroundColor = assignButton.isEnabled ? UIColor.systemBlue : UIColor.lightGray
        if elementsSelectedOrdered.count > 0 && elementsforAssignButton.titleLabel?.text != "Selecciona el campo de texto deseado.\t↓" {
            assignButton.backgroundColor = UIColor.systemBlue
            assignButton.isEnabled = true
        } else {
            assignButton.backgroundColor = UIColor.lightGray
            assignButton.isEnabled = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        elementsSelectedOrdered.append(ocrCounter.OCR[indexPath.section].words[indexPath.row])
        indexS.append(indexPath.row)
        selectS.append(indexPath.section)
        
        self.wordsArraySelected.text = "\(elementsSelectedOrdered.compactMap({ $0 }).joined(separator: ", "))".replacingOccurrences(of: ",", with: "")
        
        assignButton.isEnabled = elementsSelectedOrdered.count > 0 ? true : false
        assignButton.isEnabled = elementsforAssignButton.titleLabel?.text == "Selecciona el campo de texto deseado.\t↓" ? false : true
        assignButton.backgroundColor = assignButton.isEnabled ? UIColor.systemBlue : UIColor.lightGray
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ocrCounter.OCR.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ocrCounter.OCR[section].words.count
    }
}
