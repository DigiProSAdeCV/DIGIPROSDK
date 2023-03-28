//
//  DocFormCell.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 27/12/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import UIKit
import Eureka
import MobileCoreServices
import PDFKit

open class DocFormCell: Cell<String>, CellType, UINavigationControllerDelegate {
    public var formDelegate: FormularioDelegate?
    public var elemento = Elemento()
    public var atributos: Atributos_PDFOCR?
    var sdkAPI : APIManager<DocFormCell>?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    // Anexos
    public var anexo: FEAnexoData?
    public var anexosDict = [ (id: "", url: ""), (id: "", url: "") ]
    public var docTypeDict = [(catalogoId: 0, descripcion: ""),(catalogoId: 0, description: "" )] as [Any]
    public var isServiceMessageDisplayed = 0
    // Tipificación
    public var tipUnica: Int?
    public var listAllowed: [FEListTipoDoc] = []
    public var path = ""
    public var pathOCR: String = ""
    public var fedocumento: FEDocumento = FEDocumento()
    public var fedocReemp : FEDocumento = FEDocumento()
    public var anexoReemp: FEAnexoData?
    public var startReemp : Bool = false
    
    lazy var arrayAnexosReemp = [(key: Int, value: FEDocumento)]()
    lazy var idAnexoReemp: Int = -1
    lazy var fedocumentos : [FEDocumento] = [FEDocumento]()
    public var isMarcado: String = ""
    var anexosRecup:  [FEAnexoData]?
    lazy var historicImage: String = ""
    var docID: Int = 0
    var arrayMetadatos: [FEListMetadatosHijos] = []
    // MARK: User Interface
    lazy var vw: MetaAttributesViewController = MetaAttributesViewController()
    lazy var ui: PDFOCRUIView = PDFOCRUIView(delegate: self)
    
    //* Service
    lazy var ocrObject: OCRObject = OCRObject()
    private lazy var dictionaryAndElements: Array<[String: String]> = Array<[String: String]>()
    
    // MARK: SETTINGS
    /// SetObject for DocFormRow,
    /// Default configuration with attributes, rules and parameters
    /// - Parameter obj: Current element taken from XML Configuration
    public func setObject(object: Elemento) {
        elemento = object
        atributos = object.atributos as? Atributos_PDFOCR
        
        elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode{ setHabilitado(false) }else{ setHabilitado(atributos?.habilitado ?? false) }
        ui.headersView.txttitulo = atributos?.titulo ?? ""
        ui.headersView.txtsubtitulo = atributos?.subtitulo ?? ""
        ui.headersView.txthelp = atributos?.ayuda ?? ""
        ui.headersView.btnInfo.isHidden = ui.headersView.txthelp == "" ? true : false
        ui.headersView.viewInfoHelp = (row as? DocFormRow)?.cell.formCell()?.formViewController()?.tableView
        ui.headersView.setOcultarTitulo(atributos?.ocultartitulo ?? false)
        ui.headersView.setOcultarSubtitulo(atributos?.ocultarsubtitulo ?? false)
        ui.headersView.setAlignment(atributos?.alineadotexto ?? "")
        ui.headersView.setDecoration(atributos?.decoraciontexto ?? "")
        ui.headersView.setTextStyle(atributos?.estilotexto ?? "")
        
        ui.headersView.setNeedsLayout()
        ui.headersView.layoutIfNeeded()
        ui.btnAddDocumentLabel.isHidden = ui.btnAddDocument.titleLabel?.text == ui.btnAddDocumentLabel.text! ? true : false
        
        ui.btnTrashLabel.isHidden = ui.btnTrashDocument.titleLabel?.text == ui.btnTrashLabel.text! ? true : false
        
        ui.btnReplaceLabel.isHidden = ui.btnReplaceDocument.titleLabel?.text == ui.btnReplaceLabel.text! ? true : false
        ui.replaceDocumentStackView.isHidden = true
        ui.btnAddDocument.backgroundColor = UIColor(hexFromString: atributos?.colortomarfoto ?? "#1E88E5")
        
        getTipificacionPermitida()
        setHeightFromTitles()
    }
    
    // MARK: Setup
    open override func setup() {
        super.setup()
        let apiMeta = MetaFormManager<DocFormCell>()
        apiMeta.delegate = self
        
        sdkAPI = APIManager<DocFormCell>()
        sdkAPI?.delegate = self
        
        self.addSubview(vw.view)
        vw.view.isHidden = true
        vw.view.translatesAutoresizingMaskIntoConstraints = false
        
        vw.view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        vw.view.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        vw.view.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        vw.view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        vw.delegate = apiMeta.delegate
        anexo?.Extension = ".PDF"
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(watchPreview(_:)))
        gesture.cancelsTouchesInView = true
        gesture.numberOfTapsRequired = 1
        ui.imgPreview.addGestureRecognizer(gesture)
    }
    
    // MARK: INIT
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(ui)
        // Historic will setup configuration when we need to get a historic of document.
        let viewsThatWillBeHidden: [UIView] = [
            ui.typeDocButton, ui.imgPreview, ui.GeneralStackView, ui.bgHabilitado, ui.btnShowResults, ui.historicDocumentStackView, ui.OCRButton
        ]
        viewsThatWillBeHidden.forEach({ $0.isHidden = true })
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        elemento = Elemento()
        atributos = nil
        formDelegate = nil
        rulesOnProperties = []
        rulesOnChange = []
        est = nil
        (row as? DocFormRow)?.presentationMode = nil
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
        if ui.headersView.isInfoToolTipVisible{
            ui.headersView.toolTip!.dismiss()
            ui.headersView.isInfoToolTipVisible = false
        }
    }
    
    /// Reload the cell height
    /// - Parameter height: Height of the new cell
    public func updateCellHeight(with height: CGFloat) {
        DispatchQueue.main.async {
            self.height = { return height }
            self.layoutIfNeeded()
            self.row.reload()
            self.formDelegate?.reloadTableViewFormViewController()
        }
    }
    
    func addDocument() {
        let alert = UIAlertController(title: "Agregar", message: "", preferredStyle: .actionSheet)
        
        let alertDocuments = UIAlertAction(title: "Por almacenamiento", style: .default , handler:{ (UIAlertAction)in
            self.openFiles()
        })
        alert.addAction(alertDocuments)
        
        let alertEmptyDoc = UIAlertAction(title: "Documento vacio", style: .default, handler:{ [self] (UIAlertAction)in
            self.sinImgAction()
        })
        alert.addAction(alertEmptyDoc)
        
        let alertCancel = UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            self.anexoReemp = nil
            self.fedocReemp = FEDocumento()
            self.startReemp = false
        })
        alert.addAction(alertCancel)
        
        alertDocuments.isEnabled = atributos?.permisoimportar ?? false
        
        self.formDelegate?.getFormViewControllerDelegate()?.present(alert, animated: true, completion: { })
    }
    
    func showResults() {
        var dataObject = Data()
        if fedocumentos.count > 0 {
            guard let data = ConfigurationManager.shared.utilities.getDataFromFile("\(Cnstnt.Tree.anexos)/\(self.fedocumentos[0].URL)") else {
                return
            }
            dataObject = data
        } else {
            let localPath = "\(Cnstnt.Tree.anexos)/\(historicImage)"
            if FCFileManager.existsItem(atPath: localPath) {
                let file = ConfigurationManager.shared.utilities.read(asData: localPath)
                dataObject = file ?? Data()
            }
        }
        
        let navigation = self.formViewController()?.navigationController
        let controller = PDFOCRMain.createModule(navigation: navigation!, elements: FormularioUtilities.shared.elementsInPlantilla, pdfData: dataObject, OCRServiceResults: ocrObject)
        let cont = controller as! PDFOCRViewController
        cont.delegate = self
        self.formViewController()?.present(controller, animated: true)
    }
    
    func removeDocument() {
        updateCellHeight(with: ui.originalCellHeight)
        
        ui.addDocumentStackView.isHidden = false
        ui.btnAddDocument.isHidden = false
        ui.btnShowResults.isHidden = true
        ui.OCRButton.isHidden = true
        ui.btnAddDocumentLabel.isHidden = ui.btnAddDocument.titleLabel?.text == ui.btnAddDocumentLabel.text! ? true : false
        ui.headersView.setMessage("")
        ui.GeneralStackView.isHidden = true
        
        ui.imgPreview.image = nil
        ui.imgPreview.isHidden = true
        
        ui.typeDocButton.isHidden = true
        ui.lblTypeDoc.isHidden = true
        ui.btnMeta.isHidden = true
        
        //self.anexosDict[1] = (id: "", url: "")
        let anexosDictCounter = anexosDict.count
        for ele in 1...anexosDictCounter - 1 {
            anexosDict[ele] = (id: "", url: "")
        }
        
        self.elemento.validacion.valor = ""
        self.elemento.validacion.valormetadato = ""
        self.docID = 0
        
        ui.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
        fedocumentos.removeAll()
        row.value = nil
        row.validate()
        self.updateIfIsValid()
        triggerRulesOnChange("removeanexo")
    }
    
    func replaceDocument() {
        if ui.btnReplaceLabel.text == "Sustituir" {
            self.fedocReemp = self.fedocumento
            self.anexoReemp = self.anexo
            self.startReemp = true
            addDocument()
            
        } else if ui.btnReplaceLabel.text == "Deshacer" {
            FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.fedocReemp.Nombre { $0.Reemplazado = false }}
            if self.fedocReemp.TipoDocID != self.fedocumento.TipoDocID
            {   var menos = false; var mas = false;
                for list in self.listAllowed{
                    if list.CatalogoId == self.fedocReemp.TipoDocID && !mas { list.current += 1 ; mas = true}
                    if list.CatalogoId == self.fedocumento.TipoDocID && !menos { list.current -= 1; menos = true }
                }
            }
            if !historicImage.isEmpty {
                setValue(v: historicImage)
                anexosDict[1] = (id: "1", url: "\(historicImage)")
            }
            
            anexoReemp?.Reemplazado = false
            fedocumento = self.fedocReemp
            anexo = self.anexoReemp
            anexoReemp = nil
            fedocReemp = FEDocumento()
            startReemp = false
            fedocumentos.removeAll()
            
            ui.btnReplaceLabel.text = "Sustituir"
            ui.btnReplaceDocument.setImage(UIImage(named: "ic_sustituir", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
            setEdited(v: fedocumento.Nombre) // Returns to its original image.
        }
    }
    func historicOfDocuments() {
        // Get Anexos history.
    }
    @objc func watchPreview(_ sender: UITapGestureRecognizer) {
        if let data =
            ConfigurationManager.shared.utilities.getDataFromFile("\(Cnstnt.Tree.anexos)/\(self.fedocumentos.last?.URL ?? "")") {
            let fileStream : String = data.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
            let preview = WebPDFViewControllerMain.create(pdfString: fileStream, nameOfFile: "")
            preview.modalPresentationStyle = .overFullScreen
            self.formViewController()?.present(preview, animated: true)
        } else {
            let localPath = "\(Cnstnt.Tree.anexos)/\(historicImage)"
            if FCFileManager.existsItem(atPath: localPath) {
                let file = ConfigurationManager.shared.utilities.read(asData: localPath)
                let stream = file?.base64EncodedString() ?? ""
                let preview = WebPDFViewControllerMain.create(pdfString: stream, nameOfFile: "")
                preview.modalPresentationStyle = .overFullScreen
                self.formViewController()?.present(preview, animated: true)
            }
        }
    }
    
    func typeDocAction() {
        vw.view.isHidden = false
        vw.lblTipoDoc.text = "elemts_meta_select".langlocalized()
        vw.listAllowed = self.listAllowed
        vw.fedocumento = self.fedocumento
        vw.arrayMetadatos = self.arrayMetadatos
        vw.metaDataTableView.isHidden = true
        vw.documentType.isHidden = false
        vw.documentType.reloadAllComponents()
        vw.documentType.selectRow(0, inComponent: 0, animated: false)
        vw.metaBtnGuardar.isHidden = true
    }
    
    func metaAction() {
        vw.view.isHidden = false
        vw.lblTipoDoc.text = "elemts_meta_write".langlocalized()
        vw.listAllowed = self.listAllowed
        vw.docID = self.docID
        vw.fedocumento = self.fedocumento
        vw.arrayMetadatos = self.arrayMetadatos
        vw.metaDataTableView.isHidden = false
        vw.metaDataTableView.reloadData()
        vw.documentType.isHidden = true
        vw.metaBtnGuardar.isHidden = false
    }
    
    private func openFiles(){
        let documentTypes = [String(kUTTypePDF)]
        let importMenu = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        importMenu.delegate = self
        importMenu.allowsMultipleSelection = false
        importMenu.modalPresentationStyle = .popover
        let presenter = Presentr(presentationType: .popup)
        self.formViewController()?.customPresentViewController(presenter, viewController: importMenu, animated: true, completion: nil)
    }
    
    private func sinImgAction() {
        let image = UIImage(named: "file-pdf", in: Cnstnt.Path.framework, compatibleWith: nil)
        let guid = ConfigurationManager.shared.utilities.guid()
        let p = "\(guid).ane"
        let doc = FEDocumento()
        doc.guid = "\(guid)"
        doc.ImageString = ""
        doc.Nombre = p
        doc.Path = p
        doc.Ext = ".PDF"
        doc.URL = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
        doc.TipoDoc = ""
        doc.TipoDocID = 0
        ui.btnReplaceLabel.text = "Deshacer"
        ui.btnReplaceDocument.setImage(UIImage(named: "ic_deshacer", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        for list in self.listAllowed{
            if self.tipUnica == nil{ break }
            if list.CatalogoId != tipUnica{ continue }
            doc.TipoDocID = tipUnica ?? 0
            doc.TipoDoc = list.Descripcion
            list.current += 1
        }
        doc.TipoDocID = tipUnica ?? 0
        fedocumentos.append(doc)
        // Guardamos el id y ruta del anexo en el array global
        anexosDict.append((id: "\(self.fedocumentos.count - 1)", url: doc.URL))
        
        if let image = image {
            let document = PDFDocument()
            let pdfPage = PDFPage(image: image)
            document.insert(pdfPage!, at: 0)
            let _ = ConfigurationManager.shared.utilities.savePDFToFolder(document, doc.URL)
        }
        setEdited(v: doc.URL)
        savingData()
    }
    
    private func ocrPDF() {
        let spinner = JGProgressHUD(style: .dark)
        var pdfString = ""
        spinner.textLabel.text = "Ejecutando servicio"
        if fedocumentos.count > 0 {
            guard let dataObject = ConfigurationManager.shared.utilities.getDataFromFile("\(Cnstnt.Tree.anexos)/\(self.fedocumentos[0].URL)") else {
                return
            }
            pdfString = dataObject.base64EncodedString()
        } else {
            let localPath = "\(Cnstnt.Tree.anexos)/\(historicImage)"
            if FCFileManager.existsItem(atPath: localPath) {
                let file = ConfigurationManager.shared.utilities.read(asData: localPath)
                pdfString = file?.base64EncodedString() ?? ""
            }
        }
        spinner.show(in: self.contentView, animated: true)
        self.keepAndConsumeService(pdfString: pdfString, spinner: spinner)
    }
    
    private func keepAndConsumeService(pdfString: String, spinner: JGProgressHUD) {
        let data: [String: Any] = ["pdf":"\(pdfString)"]
        DispatchQueue.global().async {
            self.sdkAPI?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioOCR.FormRecognizer", assemblypath: "ServiciosDigipro.dll", data: data).then({ response in
                
                self.serializeObject(serialize: response) { result in
                    switch result {
                    case .success(let success):
                        // Pass by reference
                        self.ocrObject = success
                        self.formDelegate?.setStatusBarNotificationBanner("Solicitud Exitosa", .success, .bottom)
                        self.ui.OCRButton.isHidden = true
                        self.ui.btnShowResults.isHidden = false
                        spinner.dismiss(animated: true)
                    case .failure(let failure):
                        self.formDelegate?.setStatusBarNotificationBanner(failure.localizedDescription, .danger, .bottom)
                        spinner.dismiss(animated: true)
                    }
                }
            }).catch({ error in
                print(error.localizedDescription)
                spinner.dismiss(animated: true)
                self.formDelegate?.setStatusBarNotificationBanner("No se logró completar la operación.", .danger, .bottom)
            })
        }
    }
    
    private func serializeObject(serialize response: String, completion: @escaping (Result<OCRObject, Error>) -> Void) {
        do {
            let dictionary = try JSONSerializer.toDictionary(response)
            guard let data = dictionary["data"] as? NSMutableDictionary else {
                completion(.failure(OCRPDFServiceError.invalidConversion))
                return
            }
            guard let ocr = data["OCR"] as? Array<NSDictionary> else {
                completion(.failure(OCRPDFServiceError.invalidConversion))
                return
            }
            let pdfObject = OCRObject()
            ocr.forEach { dict in
                
                let modelPDF = OCRService(dictionary: dict)
                let words = dict["Palabras"] as? Array<String>
                words?.forEach({ word in
                    modelPDF.words.append(word)
                })
                pdfObject.OCR.append(modelPDF)
            }
            completion(.success(pdfObject))
        } catch {
            print("Response no se logró convertir a diccionario")
            completion(.failure(OCRPDFServiceError.invalidDictionarySerializer))
        }
    }
    
    // MARK: Set - Preview
    @objc public func setPreview(_ sender: Any) {
        if "\(anexosDict[1].url)" == "" && !ui.imgPreview.isHidden {
            self.setDownloadAnexo(Any.self)
        } else {
            let localPath = "\(Cnstnt.Tree.anexos)/\(self.anexosDict[1].url)"
            if FCFileManager.existsItem(atPath: localPath){
                let file = ConfigurationManager.shared.utilities.read(asData: localPath)
                let fileString : String = file?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0)) ?? String()
                let preview = WebPDFViewControllerMain.create(pdfString: fileString, nameOfFile: "")
                preview.modalPresentationStyle = .overFullScreen
                self.formViewController()?.present(preview, animated: true)
            }
        }
    }
    
    // MARK: Set - Download Anexo
    @objc public func setDownloadAnexo(_ sender: Any) {
        self.setMessage("hud_downloading".langlocalized(), .info)
        ui.bgHabilitado.isHidden = false
        (row as? DocFormRow)?.disabled = true
        (row as? DocFormRow)?.evaluateDisabled()
        if self.anexo != nil{
            self.sdkAPI?.DGSDKformatoAnexos(delegate: self, anexo: self.anexo!, estado: FormularioUtilities.shared.currentFormato.EstadoApp)
                .then{ response in
                    self.setAnexo(response)
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.setPreview(_:)))
                    self.ui.imgPreview.isUserInteractionEnabled = true
                    self.ui.imgPreview.addGestureRecognizer(tapGestureRecognizer)
                    self.ui.btnShowResults.isHidden = true
                    self.ui.OCRButton.isHidden = false
                    self.ui.trashDocumentStackView.isHidden = true
                    self.ui.replaceDocumentStackView.isHidden = false
                }.catch{ error in
                    self.ui.bgHabilitado.isHidden = true
                    (self.row as? DocFormRow)?.disabled = false
                    (self.row as? DocFormRow)?.evaluateDisabled()
                    self.setMessage("elemts_attch_error".langlocalized(), .info)
            }
        }
    }
    
    // MARK: Close Meta View
    @objc func closeMetaAction(_ sender: Any) {
        vw.view.isHidden = true
    }
    // MARK: Save Meta View
    @objc func saveMetaAction(_ sender: Any) {
        // Saving meta attibutes to the Document Typed
        let obj = fedocumento
        obj.Metadatos = []
        for (index, meta) in arrayMetadatos.enumerated(){
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = self.vw.metaDataTableView.cellForRow(at: indexPath) as? MetaDataTableViewCell {
                let m = meta
                m.NombreCampo = cell.textFieldMD.text ?? ""
                obj.Metadatos.append(m)
            }
            
        }
        var counterFe = 0
        if fedocumento.Metadatos.count == 0{
            counterFe += 1
        }
        if counterFe == 0{
            let tipodoc: NSMutableDictionary = NSMutableDictionary();
            let meta: NSMutableDictionary = NSMutableDictionary();

            tipodoc.setValue("\(String(fedocumento.TipoDocID ?? 0))", forKey: "\(fedocumento.guid)");
            let metadatos: NSMutableDictionary = NSMutableDictionary();
            for metaFe in fedocumento.Metadatos{
                metadatos.setValue("\(metaFe.NombreCampo)", forKey: "\(metaFe.Nombre)");
            }
            meta.setValue(metadatos, forKey: "\(fedocumento.guid)");
            anexosDict.append((id: "\(0)", url: "\(fedocumento.Nombre)"))

            elemento.validacion.valor = tipodoc.toJsonString()
            elemento.validacion.valormetadato = meta.toJsonString()
            setEdited(v: fedocumento.URL)
        }
    }
    
    // MARK: - TIPIFYCATION
    // MARK: Set Permiso Tipificar
    public func setPermisoTipificar(_ bool: Bool){
        if bool {
            ui.typeDocButton.isHidden = false
            ui.btnAddDocument.isHidden = false
            ui.lblTypeDoc.isHidden = false
        } else {
            ui.typeDocButton.isHidden = true
            ui.btnAddDocument.isHidden = true
            ui.lblTypeDoc.isHidden = true
        }
    }
    
    // MARK: Get All Tipyfication options
    public func getTipificacionPermitida() {
        // Getting tipificacion única
        let tipificacionUnica = atributos?.tipodoc
        if tipificacionUnica != 0 {
            self.tipUnica = tipificacionUnica
            for idDoc in ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc{
                if self.tipUnica == idDoc.CatalogoId {
                    idDoc.min = 0
                    idDoc.max = 1
                    idDoc.Activo = true
                } else { idDoc.Activo = false }
            }
        } else {
            for idDoc in ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc{
                idDoc.min = 0
                idDoc.max = 1
                idDoc.Activo = true
            }
        }
        for list in ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc{
            if list.Activo {
                listAllowed.append(list)
            }
        }
    }
    
    // MARK: Get Metas
    func getMetaData()->Bool{
        self.arrayMetadatos = []
        let metas = ConfigurationManager.shared.plantillaDataUIAppDelegate.ListMetadatosHijos
        if metas.count == 0{ return false }
        for meta in metas{
            if self.fedocumento.TipoDocID == meta.TipoDoc{
                self.arrayMetadatos.append(meta)
            }
        }
        if self.arrayMetadatos.count == 0{ return false }
        self.vw.metaDataTableView.reloadData()
        return true
    }
    
    // MARK: Saving Data from Metas
    public func savingData(){
        let tipodoc: NSMutableDictionary = NSMutableDictionary();
        let meta: NSMutableDictionary = NSMutableDictionary();
        
        tipodoc.setValue("\(String(fedocumento.TipoDocID ?? 0))", forKey: "\(fedocumento.guid)");
        self.anexosDict[1] = (id: "\(0)", url: "\(anexosDict.last?.url ?? "")")
        
        self.elemento.validacion.valor = tipodoc.toJsonString()
        self.elemento.validacion.valormetadato = meta.toJsonString()
        self.setEdited(v: "\(anexosDict.last?.url ?? "")")
        
        if self.getMetaData(){ ui.btnAddDocument.isHidden = false }else{ ui.btnAddDocument.isHidden = true }
    }
    
    // MARK: layoutSubviews
    open override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            ui.topAnchor.constraint(equalTo: contentView.topAnchor),
            ui.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ui.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ui.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}

// MARK: UIDocumentPickerDelegate
extension DocFormCell: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard !urls.isEmpty else { return } // Solo funciona para URL no vacía
        
        urls.forEach { url in
            let fileExtension = String(describing: url).fileExtension()
            let doc = FEDocumento()
            switch ConfigurationManager.shared.utilities.detectExtension(ext: fileExtension) {
            case 1:
                let imageURL = url
                let guid = ConfigurationManager.shared.utilities.guid()
                _ = try? UIImage(withContentsOfUrl: imageURL)
                let p = "\(guid).ane"
                doc.guid = "\(guid)"
                doc.isKindImage = true
                doc.Ext = fileExtension.lowercased()
                doc.ImageString = ""
                doc.Nombre = p
                doc.Path = p
                doc.URL = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
                doc.TipoDoc = ""
                doc.TipoDocID = 0
            default:
                let guid = ConfigurationManager.shared.utilities.guid()
                let docData = try? Data(contentsOf: url)
                let p = "\(guid).ane"
                doc.guid = "\(guid)"
                doc.isKindImage = true
                doc.Ext = fileExtension.lowercased()
                doc.ImageString = "ic_doc"
                doc.Nombre = p
                doc.Path = p
                doc.URL = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
                doc.TipoDoc = ""
                doc.TipoDocID = 0
                if startReemp {
                    FormularioUtilities.shared.currentFormato.Anexos.forEach{ if $0.FileName == self.fedocumento.Nombre { $0.Reemplazado = true }}
                    if self.anexoReemp != nil {
                        self.anexoReemp?.Reemplazado = true
                        doc.DocID = self.anexoReemp?.DocID ?? -1
                    }
                    for list in self.listAllowed {
                        if list.CatalogoId != self.fedocumento.TipoDocID { continue }
                        list.current -= 1
                        break
                    }
                    if anexosRecup != nil {
                        for (_, data) in (anexosRecup ?? [FEAnexoData]() ).enumerated(){
                            if data.FileName == self.fedocumentos[idAnexoReemp].Nombre {
                                data.Reemplazado = true
                                doc.DocID = data.DocID
                            }
                        }
                    }
                    ui.btnReplaceLabel.text = "Deshacer"
                    ui.btnReplaceDocument.setImage(UIImage(named: "ic_deshacer", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
                    // Guardamos el id con "r" y ruta del nuevo anexo en el array global
                    fedocumentos.removeAll()
                    fedocumentos.append(doc)
                } else {
                    if tipUnica != nil {
                        for list in self.listAllowed {
                            if list.CatalogoId != tipUnica{ continue }
                            doc.TipoDocID = tipUnica ?? 0
                            doc.TipoDoc = list.Descripcion
                            list.current += 1
                        }
                    }
                    self.fedocumentos.append(doc)
                    // Guarda el id y ruta del anexo en el array global
                    self.anexosDict.append((id: "\(self.fedocumentos.count - 1)", url: doc.URL))
                }
                let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(docData! as NSData, doc.URL)
                if isMarcado != "" {
                    _ = self.formDelegate?.resolveValor(self.isMarcado, "asignacion", "\(String(describing: doc.TipoDocID))|\(doc.TipoDoc)" , nil)
                }
                break;
            }
            setEdited(v: doc.URL)
            savingData()
        }
    }
    
    public func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        let presenter = Presentr(presentationType: .popup)
        self.formViewController()?.customPresentViewController(presenter, viewController: documentPicker, animated: true, completion: nil)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if startReemp {
            var auxArrayReemp = [(key: Int, value: FEDocumento)]()
            arrayAnexosReemp.forEach({
                if $0 != (key: self.idAnexoReemp, value: self.arrayAnexosReemp[self.idAnexoReemp].value) { auxArrayReemp.append($0) }
            })
            self.arrayAnexosReemp = auxArrayReemp
            self.startReemp = false
            self.idAnexoReemp = -1
        }
    }
}

// MARK: PDFOCRUIViewDelegate
extension DocFormCell: PDFOCRUIViewDelegate {
    func addDocumentProtocol() {
        addDocument()
    }
    
    func removeDocumentProtocol() {
        removeDocument()
    }
    
    func replaceDocumentProtocol() {
        replaceDocument()
    }
    
    func typeDocProtocol() {
        typeDocAction()
    }
    
    func metaActionProtocol() {
        metaAction()
    }
    
    func showResultsProtocol() {
        showResults()
    }
    
    func ocrPDFProtocol() {
        ocrPDF()
    }
    
    func historicOfDocumentsProtocol() {
        historicOfDocuments()
    }
}

// MARK: MetaFormDelegate
extension DocFormCell: MetaFormDelegate {
    public func didClose() {
        closeMetaAction(Any.self)
    }
    
    public func didSave() {
        saveMetaAction(Any.self)
        closeMetaAction(Any.self)
    }
    
    public func didUpdateData(_ tipoDoc: String, _ idDoc: Int) {
        ui.typeDocButton.setTitle("\(tipoDoc)", for: .normal)
        ui.lblTypeDoc.text = "\(tipoDoc)"
        docID = idDoc
    }
}
// MARK: PDFOCRViewControllerDelegate
extension DocFormCell: PDFOCRViewControllerDelegate {
    func updateDictionaryData(elements: Array<[String : String]>) {
        elements.forEach { elem in
            for i in elem {
                _ = self.formDelegate?.resolveValor(i.key, "asignacion", i.value, "")
            }
        }
    }
}

// MARK: ObjectFormDelegate
extension DocFormCell: ObjectFormDelegate {
    public func setVariableHeight(Height h: CGFloat) {}
    public func toogleToolTip(_ help: String) { }
    public func setTextStyle(_ style: String){ }
    public func setDecoration(_ decor: String){ }
    public func setAlignment(_ align: String){ }
    public func setTitleText(_ text:String){ }
    public func setSubtitleText(_ text:String){ }
    public func setInfo(){ }
    public func setOcultarTitulo(_ bool: Bool){ }
    public func setOcultarSubtitulo(_ bool: Bool){ }
    public func setRequerido(_ bool: Bool){}
    // MARK: Set - Message
    public func setMessage(_ string: String, _ state: enumErrorType){
        ui.headersView.setMessage(string)
    }
    // MARK: Set - Height From Titles
    public func setHeightFromTitles(){
        var heightHeader : CGFloat = 0.0
        let ttl = ui.headersView.lblTitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        let sttl = ui.headersView.lblSubtitle.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        let msgerr = ui.headersView.lblMessage.calculateMaxLines(((self.formDelegate?.getFormViewControllerDelegate()?.tableView.frame.width ?? 0) - 50))
        ui.headersView.lblTitle.numberOfLines = ttl
        ui.headersView.lblSubtitle.numberOfLines = sttl
        ui.headersView.lblMessage.numberOfLines = msgerr
        
        var httl: CGFloat = 0
        var hsttl: CGFloat = 0
        let hmsg: CGFloat = (CGFloat(msgerr) * ui.headersView.lblMessage.font.lineHeight) //1 estatico para error
        if !ui.headersView.hiddenTit {
            httl = (CGFloat(ttl) * ui.headersView.lblTitle.font.lineHeight)
        }
        if !ui.headersView.hiddenSubtit {
            hsttl = (CGFloat(sttl) * ui.headersView.lblSubtitle.font.lineHeight)
        }
        //Total de labels
        heightHeader = httl + hsttl + hmsg
        
        // Validación por si no hay titulo ni subtitulos a mostrar
        if (heightHeader - 25) < 0 {
            if !self.getRequired() && ui.headersView.txthelp != "" {
                heightHeader = 40
            } else if !self.getRequired() || ui.headersView.txthelp != "" {
                heightHeader = 25
            }
        }
        if ui.headersView.frame.height < 6.0 {
            ui.headersView.heightAnchor.constraint(equalToConstant: heightHeader).isActive = true
        }
        updateCellHeight(with: ui.originalCellHeight)
    }
    
    // Protocolos Genéricos - Set's
    // MARK: - ESTADISTICAS
    public func setEstadistica(){
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "DocForm"
        est?.NombrePagina = (self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
        est?.OrdenCampo = atributos?.ordencampo ?? 0
        est?.PaginaID = Int(atributos?.elementopadre.replaceFormElec() ?? "0") ?? 0
        est?.FechaEntrada = ConfigurationManager.shared.utilities.getFormatDate()
        est?.Latitud = ConfigurationManager.shared.latitud
        est?.Longitud = ConfigurationManager.shared.longitud
        est?.Usuario = ConfigurationManager.shared.usuarioUIAppDelegate.User
        est?.Dispositivo = UIDevice().model
        est?.NombrePlantilla = (self.formDelegate?.getPlantillaTitle() ?? "").replaceLineBreak()
        est?.Sesion = ConfigurationManager.shared.guid
        est?.PlantillaID = 0
        est?.CampoID = Int(elemento._idelemento.replaceFormElec()) ?? 0
    }
    
    public func setEstadisticaV2(){
        if self.estV2 != nil { return }
        self.estV2 = FEEstadistica2()
        if self.atributos != nil{
            self.estV2?.IdElemento = elemento._idelemento
            self.estV2?.Titulo = atributos?.titulo ?? ""
            self.estV2?.Pagina = (self.formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
            self.estV2?.IdPagina = self.formDelegate?.getPageID(atributos?.elementopadre ?? "") ?? ""
        }
    }
    
    // MARK: Set - Placeholder
    public func setPlaceholder(_ text:String){ }
    // MARK: - SET Init Rules
    public func initRules(){
        row.removeAllRules()
        setMinMax()
        setExpresionRegular()
        if atributos != nil{
            self.elemento.validacion.needsValidation = atributos?.requerido ?? false
            if atributos?.requerido ?? false {
                var rules = RuleSet<String>()
                rules.add(rule: ReglaRequerido())
                self.row.add(ruleSet: rules)
            }
            ui.headersView.setRequerido(atributos?.requerido ?? false)
        }
    }
    // MARK: Set - MinMax
    public func setMinMax(){ }
    // MARK: Set - ExpresionRegular
    public func setExpresionRegular(){ }
    // MARK: Set - Habilitado
    public func setHabilitado(_ bool: Bool){
        self.elemento.validacion.habilitado = bool
        self.atributos?.habilitado = bool
        if bool{
            ui.bgHabilitado.isHidden = true;
            row.baseCell.isUserInteractionEnabled = true
            row.disabled = false
        }else{
            ui.bgHabilitado.isHidden = false;
            row.baseCell.isUserInteractionEnabled = false
            row.disabled = true
        }
        self.row.evaluateDisabled()
    }
    // MARK: Set - Edited
    public func setEdited(v: String){
        if v != "" {
            ui.btnTrashDocument.isHidden = false
            if tipUnica == nil && atributos?.permisotipificar ?? false == false{
                self.setValue(v: v)
            } else {
                if tipUnica != nil{
                    self.setValue(v: v)
                } else {
                    if atributos?.permisotipificar ?? false{
                        if (self.elemento.validacion.valor != "" && self.elemento.validacion.valormetadato != "") {
                            self.setPermisoTipificar(atributos?.permisotipificar ?? false)
                            self.setValue(v: v)
                        }
                    }
                }
            }
            if row.value != nil || row.value != ""{ triggerRulesOnChange("notempty") }
        } else {
            self.anexosDict[1] = (id: "", url: "")
            self.docTypeDict[1] = (catalogoId: 0, descripcion: "")

            ui.headersView.lblTitle.textColor = self.getRequired() ? UIColor.black : Cnstnt.Color.red2
            row.value = nil
            updateIfIsValid()
            updateCellHeight(with: ui.newCellHeight)
            if row.value == nil || row.value == ""{ triggerRulesOnChange("empty") }
        }
        
        // MARK: - Setting estadisticas
        setEstadistica()
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = v.replaceLineBreakEstadistic()
        est!.KeyStroke += 1
        let fechaValorFinal = Date.getTicks()
        self.setEstadisticaV2()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = v.replaceLineBreakEstadistic()
        self.estV2!.Cambios += 1
        elemento.estadisticas2 = estV2!
        
        elemento.estadisticas = est!
        
        triggerRulesOnChange("addanexo")
        triggerEvent("alterminarcaptura")
    }
    public func setEdited(v: String, isRobot: Bool) { }
    public func setValue(v: String){
        let tipodoc: NSMutableDictionary = NSMutableDictionary();
        tipodoc.setValue("\(String(fedocumento.TipoDocID ?? 0))", forKey: "\(fedocumento.guid)");
        self.anexosDict[1] = (id: "\(0)", url: "\(fedocumento.Nombre)")
        
        self.elemento.validacion.valor = tipodoc.toJsonString()
        
        self.anexosDict[1] = (id: "1", url: v)
        self.docTypeDict[1] = (catalogoId: self.fedocumento.TipoDocID, descripcion: self.fedocumento.TipoDoc)
        
        let localPath = "\(Cnstnt.Tree.anexos)/\(v)"
        if FCFileManager.existsItem(atPath: localPath) {
            let file = ConfigurationManager.shared.utilities.read(asData: localPath)
            generateBase64FromData(file: file)
        }
        
        if plist.idportal.rawValue.dataI() >= 39 {
            let localPathOCR = "\(Cnstnt.Tree.anexos)/\(v)"
            if localPathOCR.contains("Anverso") || localPathOCR.contains("Reverso") || localPathOCR.contains("Veridas") {
                if FCFileManager.existsItem(atPath: localPath){
                    self.pathOCR = localPathOCR
                    let file = ConfigurationManager.shared.utilities.read(asData: localPath)
                    generateBase64FromData(file: file)
                }
            }
        }
        
        ui.addDocumentStackView.isHidden = true
        ui.imgPreview.isHidden = false
        ui.GeneralStackView.isHidden = false
        ui.btnShowResults.isHidden = true
        ui.OCRButton.isHidden = false
        updateCellHeight(with: ui.newCellHeight)
        ui.headersView.lblTitle.textColor = UIColor.black
        row.value = v
        updateIfIsValid()
    }
    
    // MARK: PDF
    /// Generates a base64 from a Data variable
    /// - Parameter file: Takes a saved file and convert it to a Data object
    private func generateBase64FromData(file: Data?) {
        let fileStream: String = file?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0)) ?? String()
        if let data = Data(base64Encoded: fileStream, options: .ignoreUnknownCharacters) {
            let thumbnailSize = CGSize(width: 500, height: 500)
            ui.imgPreview.image = generatePdfThumbnail(of: thumbnailSize, for: URL(string: fileStream)!, data: data, atPage: 0)
            ui.imgPreview.isHidden = false
            ui.OCRButton.isHidden = false
        }
    }
    
    /// Function generates an Image from a PDF
    private func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, data documentData: Data, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(data: documentData)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }
    
    // MARK: Set - Visible
    public func setVisible(_ bool: Bool){
        self.elemento.validacion.visible = bool
        if self.atributos != nil{
            self.atributos?.visible = bool
            if bool {
                self.row.hidden = false
            }else{
                self.row.hidden = true
            }
        }
        self.row.evaluateHidden()
    }
    // MARK: Set - Validation
    public func resetValidation(){
        if atributos != nil{
            self.elemento.validacion.needsValidation = atributos?.requerido ?? false
        }
    }
    // MARK: UpdateIfIsValid
    public func updateIfIsValid(isDefault: Bool = false){
        if row.isValid{ // Setting row as valid
            if row.value == nil {
                ui.headersView.setMessage("")
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? DocFormRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.validado = false
                self.elemento.validacion.valor = ""
                self.elemento.validacion.valormetadato = ""
            } else {
                ui.headersView.setMessage("")
                resetValidation()
                self.elemento.validacion.anexos = [(id: String, url: String)]()
                self.elemento.validacion.anexos = (row as? DocFormRow)?.cell.anexosDict
                self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
                self.elemento.validacion.attData = ((row as? DocFormRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                
                if row.isValid && row.value != "" {
                    self.elemento.validacion.validado = true
                    self.elemento.validacion.attData = ((row as? DocFormRow)?.cell.docTypeDict as? [(catalogoId: Int, descripcion: String)])
                } else {
                    self.elemento.validacion.validado = false
                    self.elemento.validacion.valor = ""
                    self.elemento.validacion.valormetadato = ""
                }
                self.elemento.validacion.docid = "0"
                self.elemento.validacion.tipodoc = "\(self.atributos?.tipodoc ?? 0)"
            }
        } else {
            // Throw the first error printed in the label
            if (self.row.validationErrors.count) > 0{
                ui.headersView.setMessage("  \(self.row.validationErrors[0].msg)  ")
            }
            self.elemento.validacion.anexos = [(id: String, url: String)]()
            self.elemento.validacion.anexos = (row as? DocFormRow)?.cell.anexosDict
            self.elemento.validacion.attData = [(catalogoId: Int, descripcion: String)]()
            self.elemento.validacion.needsValidation = true
            self.elemento.validacion.validado = false
            self.elemento.validacion.valor = ""
            self.elemento.validacion.valormetadato = ""
        }
    }
    // MARK: Events
    public func triggerEvent(_ action: String) {
        // alentrar
        // alcambiar
        if atributos != nil, atributos?.eventos != nil {
            for evento in (atributos?.eventos.expresion)!{
                if evento._tipoexpression == action {
                    DispatchQueue.main.async {
                        self.formDelegate?.addEventAction(evento)
                    }
                }
            }
        }
    }
    // MARK: Excecution for RulesOnProperties
    public func setRulesOnProperties() {
        if rulesOnChange.count > 0{
            if row.value == nil || row.value == ""{ triggerRulesOnChange("empty") }
            if row.value != nil || row.value != ""{ triggerRulesOnChange("notempty") }
        }
        if rulesOnProperties.count == 0{
            if self.atributos?.habilitado ?? false{ triggerRulesOnProperties("enabled") }else{ triggerRulesOnProperties("notenabled") }
            if self.atributos?.visible ?? false{
                triggerRulesOnProperties("visible")
                triggerRulesOnProperties("visiblecontenido")
            }else{
                triggerRulesOnProperties("notvisible")
                triggerRulesOnProperties("notvisiblecontenido")
            }
        }
    }
    // MARK: Rules on properties
    public func triggerRulesOnProperties(_ action: String) {
        if rulesOnProperties.count == 0{ return }
        for rule in rulesOnProperties{
            if rule.vrb == action{
                _ = self.formDelegate?.obtainRules(rString: rule.xml.name, eString: row.tag, vString: rule.vrb, forced: false, override: false)
            }
        }
    }
    
    // MARK: Excecution for RulesOnChange
    public func setRulesOnChange(){ }
    
    // MARK: Rules on change
    public func triggerRulesOnChange(_ action: String?) {
        if rulesOnChange.count == 0 { return }
        for rule in rulesOnChange{
            _ = self.formDelegate?.obtainRules(rString: rule.name, eString: row.tag, vString: action, forced: false, override: false)
        }
    }
    // MARK: Mathematics
    public func setMathematics(_ bool: Bool, _ id: String){ }
}

// MARK: AttachedFormDelegate
extension DocFormCell: AttachedFormDelegate {
    public func setAttributesToController() { }
    
    func setMetaValues() -> Bool {
        if self.anexo?.DocID != 0 {
            ui.trashDocumentStackView.isHidden = true
            ui.replaceDocumentStackView.isHidden = false
        }
        if self.elemento.validacion.valor == "" {
            guard let ane = self.anexo else{ return false }
            if ane.Guid == FormularioUtilities.shared.currentFormato.Guid{
                let fedoc = FEDocumento()
                fedoc.guid = self.anexo?.GuidAnexo ?? ""
                fedoc.isKindImage = true
                let fileExtension = ane.FileName.fileExtension().lowercased()
                fedoc.Ext = fileExtension
                fedoc.ImageString = ""
                fedoc.Nombre = ane.FileName.cleanAnexosDocPath()
                fedoc.Path = ane.FileName.cleanAnexosDocPath()
                fedoc.URL = ane.FileName
                fedoc.TipoDocID = self.anexo?.TipoDocID ?? 0
                for docType in listAllowed{
                    if ane.TipoDocID == docType.CatalogoId {
                        fedoc.TipoDoc = docType.Descripcion
                    }
                }
                self.docID = fedoc.TipoDocID ?? 0
                if self.elemento.validacion.valormetadato != "" {
                    let vmeta = self.elemento.validacion.valormetadato.data(using: .utf8)
                    do {
                        let metadoc = (try JSONSerialization.jsonObject(with: vmeta!, options: []) as? [String: Any])!
                    
                        for meta in metadoc{
                            for mm in meta.value as? [String: Any] ?? [:]{
                                let m = FEListMetadatosHijos()
                                m.Nombre = mm.key
                                m.NombreCampo = mm.value as? String ?? ""
                                fedoc.Metadatos.append(m)
                            }
                        }
                    } catch {}
                }
                ui.typeDocButton.setTitle("\(fedoc.TipoDoc)", for: .normal)
                ui.lblTypeDoc.text = "\(fedoc.TipoDoc)"
                self.fedocumento = fedoc
                if self.getMetaData(){ ui.btnAddDocument.isHidden = false }else{ ui.btnAddDocument.isHidden = true }
                return true
            }
        }
                
        let vvalor = elemento.validacion.valor.data(using: .utf8)
        let vmeta = elemento.validacion.valormetadato.data(using: .utf8)
        do {
            let tipodoc = (try JSONSerialization.jsonObject(with: vvalor!, options: []) as? [String: Any])!
            let metadoc = (try JSONSerialization.jsonObject(with: vmeta!, options: []) as? [String: Any])!
            for tipo in tipodoc {
                guard let ane = self.anexo else{ return false }
                if ane.Guid == FormularioUtilities.shared.currentFormato.Guid{
                    let fedoc = FEDocumento()
                    fedoc.guid = "\(tipo.key)"
                    fedoc.isKindImage = true
                    let fileExtension = ane.FileName.fileExtension().lowercased()
                    fedoc.Ext = fileExtension
                    fedoc.ImageString = ""
                    fedoc.Nombre = ane.FileName.cleanAnexosDocPath()
                    fedoc.Path = ane.FileName.cleanAnexosDocPath()
                    fedoc.URL = ane.FileName
                    fedoc.TipoDocID = Int(tipo.value as? String ?? "0") ?? 0
                    if ane.TipoDocID == 0{
                        ane.TipoDocID = Int(tipo.value as? String ?? "0") ?? 0
                    }
                    for docType in listAllowed {
                        if ane.TipoDocID == docType.CatalogoId{
                            fedoc.TipoDoc = docType.Descripcion
                        }
                    }
                    self.docID = fedoc.TipoDocID ?? 0
                    for meta in metadoc{
                        for mm in meta.value as? [String: Any] ?? [:]{
                            let m = FEListMetadatosHijos()
                            m.Nombre = mm.key
                            m.NombreCampo = mm.value as? String ?? ""
                            fedoc.Metadatos.append(m)
                        }
                    }
                    ui.typeDocButton.setTitle("\(fedoc.TipoDoc)", for: .normal)
                    ui.lblTypeDoc.text = "\(fedoc.TipoDoc)"
                    self.fedocumento = fedoc
                    if self.getMetaData(){ ui.btnAddDocument.isHidden = false } else { ui.btnAddDocument.isHidden = true }
                }
            }
            return true

        } catch { return false }
    }
    
    // MARK: Set - Local Anexo
    public func didSetLocalAnexo(_ feAnexo: FEAnexoData){
        anexo = feAnexo
        if self.anexo?.DocID != 0 {
            ui.btnAddDocument.isHidden = true
            ui.btnAddDocumentLabel.isHidden = true
        }
        _ = setMetaValues()
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(feAnexo.FileName)"){
            historicImage = feAnexo.FileName
            setEdited(v: "\(feAnexo.FileName)")
        }else{
            setMessage("elemts_attch_server".langlocalized(), .info)
        }
    }
    
    // MARK: Set - Anexo Option
    public func setAnexoOption(_ anexo: FEAnexoData) {
        self.anexo = anexo
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setDownloadAnexo(_:)))
        ui.imgPreview.isUserInteractionEnabled = true
        ui.imgPreview.addGestureRecognizer(tapGestureRecognizer)
        
        ui.imgPreview.image = UIImage(named: "download-attachment", in: Cnstnt.Path.framework, compatibleWith: nil)
        ui.imgPreview.isUserInteractionEnabled = true
        ui.imgPreview.isHidden = false
        ui.btnAddDocument.isHidden = true
        ui.OCRButton.isHidden = false
        ui.btnShowResults.isHidden = true
        ui.btnAddDocumentLabel.isHidden = true
        
        updateCellHeight(with: ui.newCellHeight)
        
        anexosDict[0] = (id: "reemplazo", url: anexo.FileName)
        triggerRulesOnChange("replaceanexo")
    }
    
    // MARK: Set - Anexo
    public func setAnexo(_ anexo: FEAnexoData) {
        ui.bgHabilitado.isHidden = true
        (row as? DocFormRow)?.disabled = false
        (row as? DocFormRow)?.evaluateDisabled()
        _ = setMetaValues()
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(anexo.FileName)"){
            setEdited(v: "\(anexo.FileName)")
            self.setMessage("elemts_attch_recover".langlocalized(), .info)
        }
    }
}

// MARK: Extern UI Functions
extension DocFormCell {
    public func getMessageText() -> String{
        return ui.headersView.lblMessage.text ?? ""
    }
    public func getRowEnabled() -> Bool{
        return row.baseCell.isUserInteractionEnabled
    }
    public func getRequired() -> Bool{
        return ui.headersView.lblRequired.isHidden
    }
    public func getTitleLabel() -> String{
        return ui.headersView.lblTitle.text ?? ""
    }
    public func getSubtitleLabel() -> String{
        return ui.headersView.lblSubtitle.text ?? ""
    }
}

// MARK: APIDelegate
extension DocFormCell: APIDelegate {
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
}

