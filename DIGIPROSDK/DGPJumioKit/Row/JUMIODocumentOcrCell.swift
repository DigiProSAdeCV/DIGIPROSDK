//
//  JUMIODocumentOcrCell.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 26/02/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import UIKit
import Eureka

open class JUMIODocumentOcrCell: Cell<String>, CellType {
    
    // MARK: Global Var.
    public var formDelegate: FormularioDelegate?
    //var sdkAPI : APIManager<JUMIODocumentOcrCell>?
    public var rulesOnProperties: [(xml: AEXMLElement, vrb: String)] = []
    public var rulesOnChange: [AEXMLElement] = []
    public var atributos: AtributosJumio?
    public var elemento = Elemento()
    public var atributosOCR: OcrIneObject = OcrIneObject()
    public var est: FEEstadistica? = nil
    public var estV2: FEEstadistica2? = nil
    public var genericRow: JUMIODocumentOcrRow! { return row as? JUMIODocumentOcrRow }
    public var isSectionHeader: Bool = false
    public var isTab: Bool = false
    
    private lazy var cellUserInterface = JUMIOUIView(delegate: self)
    
    // MARK: Init
    open override func update() {
        super.update()
        
    }
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
    }
    
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cellUserInterface)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setObject(obj: Elemento) {
        elemento = obj
        atributos = obj.atributos as? AtributosJumio
        
        self.elemento.validacion.idunico  = atributos?.idunico ?? ""
        initRules()
        if atributos?.titulo ?? "" == ""{ setOcultarTitulo(true) }else{ setOcultarTitulo(atributos?.ocultartitulo ?? false) }
        setHeightFromTitles()
        setVisible(atributos?.visible ?? false)
        if ConfigurationManager.shared.isInEditionMode {
            setHabilitado(false)
        }
        else {
            setHabilitado(atributos?.habilitado ?? false)
        }
        setAlignment(atributos?.alineadotexto ?? "")
        setDecoration(atributos?.decoraciontexto ?? "")
        setTextStyle(atributos?.estilotexto ?? "")
        setInfo()
        
        cellUserInterface.editButton.setTitle("  \(atributos?.textoocr ?? "OCR")  ", for: UIControl.State.normal)
        cellUserInterface.editButton.setTitle("  \(atributos?.textocorreccion ?? "OCR")  ", for: UIControl.State.normal)
        
        cellUserInterface.editButton.isHidden = true
        cellUserInterface.lblRequired.isHidden = true
    }
    
    // MARK: layoutSubviews
    open override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            cellUserInterface.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellUserInterface.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellUserInterface.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellUserInterface.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}

// MARK: JUMIOUIViewDelegate
extension JUMIODocumentOcrCell: JUMIOUIViewDelegate {
    func ocrJumioButtonAction() {
        
    }
    
    func editButtonAction() {
        
    }
    
    func btnInfoAction() {
        
    }
}

// MARK: ObjectFormDelegate
extension JUMIODocumentOcrCell: ObjectFormDelegate {
    public func setHeightFromTitles() {
        
    }
    
    public func setEdited(v: String, isRobot: Bool) {
        
    }
    
    public func setEstadistica() {
        if est != nil { return }
        est = FEEstadistica()
        est?.Campo = "OCR"
        est?.NombrePagina = (formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
        est?.OrdenCampo = atributos?.ordencampo ?? 0
        est?.PaginaID = Int(atributos?.elementopadre.replaceFormElec() ?? "0") ?? 0
        est?.FechaEntrada = ConfigurationManager.shared.utilities.getFormatDate()
        est?.Latitud = ConfigurationManager.shared.latitud
        est?.Longitud = ConfigurationManager.shared.longitud
        est?.Usuario = ConfigurationManager.shared.usuarioUIAppDelegate.User
        est?.Dispositivo = UIDevice().model
        est?.NombrePlantilla = (formDelegate?.getPlantillaTitle() ?? "").replaceLineBreak()
        est?.Sesion = ConfigurationManager.shared.guid
        est?.PlantillaID = 0
        est?.CampoID = Int(elemento._idelemento.replaceFormElec()) ?? 0
    }
    public func setEstadisticaV2(){
        if self.estV2 != nil { return }
        self.estV2 = FEEstadistica2()
        if self.atributos != nil {
            estV2?.IdElemento = elemento._idelemento
            estV2?.Titulo = atributos?.titulo ?? ""
            estV2?.Pagina = (formDelegate?.getPageTitle(atributos?.elementopadre ?? "") ?? "").replaceLineBreak()
            estV2?.IdPagina = formDelegate?.getPageID(atributos?.elementopadre ?? "") ?? ""
        }
    }
    
    public func setTextStyle(_ style: String) {
        
    }
    
    public func setDecoration(_ decor: String) {
        
    }
    
    public func setAlignment(_ align: String) {
        
    }
    
    public func setVariableHeight(Height h: CGFloat) {
        DispatchQueue.main.async {
            self.height = { return h }
            self.layoutIfNeeded()
            self.genericRow.reload()
            self.formDelegate?.reloadTableViewFormViewController()
        }
    }
    
    public func setTitleText(_ text: String) {
        cellUserInterface.lblTitle.text = text
    }
    
    public func setSubtitleText(_ text: String) {
        cellUserInterface.lblSubtitle.text = text
    }
    
    public func setPlaceholder(_ text: String) {
        
    }
    
    public func setInfo() {
        if atributos?.ayuda != nil, !(atributos?.ayuda.isEmpty)!, atributos?.ayuda != ""{
            cellUserInterface.btnInfo.isHidden = false
        }
    }
    
    public func setAyuda(_ sender: Any) {
        
    }
    
    public func toogleToolTip(_ help: String) {
        
    }
    
    public func setMessage(_ string: String, _ state: enumErrorType) {
        
    }
    
    public func initRules() {
        
    }
    
    public func setMinMax() {
        
    }
    
    public func setExpresionRegular() {
        
    }
    
    public func setOcultarTitulo(_ bool: Bool) {
        self.atributos?.ocultartitulo = bool
        if bool {
            cellUserInterface.lblTitle.isHidden = true
            self.setTitleText("")
        } else {
            cellUserInterface.lblTitle.isHidden = false
            if atributos != nil {
                setTitleText(atributos?.titulo ?? "")
            }
        }
        self.layoutIfNeeded()
    }
    
    public func setOcultarSubtitulo(_ bool: Bool) {
        self.atributos?.ocultarsubtitulo = "\(bool)"
        if bool {
            cellUserInterface.lblSubtitle.isHidden = true
            self.setSubtitleText("")
        } else {
            cellUserInterface.lblSubtitle.isHidden = false
            if atributos != nil {
                setSubtitleText(atributos?.subtitulo ?? "")
            }
        }
        self.layoutIfNeeded()
    }
    
    public func setHabilitado(_ bool: Bool) {
        self.elemento.validacion.habilitado = bool
        self.atributos?.habilitado = bool
        if bool {
            cellUserInterface.bgHabilitado.isHidden = true;
            row.baseCell.isUserInteractionEnabled = true
            row.disabled = false
        } else {
            cellUserInterface.bgHabilitado.isHidden = false;
            row.baseCell.isUserInteractionEnabled = false
            row.disabled = true
        }
        row.evaluateDisabled()
    }
    
    public func setEdited(v: String) {
        if v != "" {
            cellUserInterface.lblMoreInfo.text = v
            cellUserInterface.lblMoreInfo.isHidden = false
            row.value = v
        } else {
            cellUserInterface.lblMoreInfo.text = ""
            cellUserInterface.lblMoreInfo.isHidden = true
            row.value = nil
        }
        
        // MARK: - Setting estadisticas
        setEstadistica()
        est!.FechaSalida = ConfigurationManager.shared.utilities.getFormatDate()
        est!.Resultado = v.replaceLineBreakEstadistic()
        est!.KeyStroke += 1
        elemento.estadisticas = est!
        
        self.setEstadisticaV2()
        let fechaValorFinal = Date.getTicks()
        self.estV2!.FechaValorFinal = fechaValorFinal
        self.estV2!.ValorFinal = v.replaceLineBreakEstadistic()
        self.estV2!.Cambios += 1
        elemento.estadisticas2 = estV2!
    }
    
    public func setVisible(_ bool: Bool) {
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
    
    public func setRequerido(_ bool: Bool) {
        
    }
    
    public func resetValidation() {
        
    }
    
    public func updateIfIsValid(isDefault: Bool) {
        
    }
    
    public func triggerEvent(_ action: String) {
        
    }
    
    public func setRulesOnProperties() {
        
    }
    
    public func setRulesOnChange() {
        
    }
    
    public func triggerRulesOnProperties(_ action: String) {
        
    }
    
    public func triggerRulesOnChange(_ action: String?) {
        
    }
    
    public func setMathematics(_ bool: Bool, _ id: String) {
        
    }
}

extension JUMIODocumentOcrCell {
    // Get's for every IBOUTLET in side the component
    public func getMessageText()->String{ return "" }
    public func getRowEnabled()->Bool{ return self.row.baseCell.isUserInteractionEnabled }
    public func getRequired()->Bool{ return false }
    public func getTitleLabel()->String{ return "" }
    public func getSubtitleLabel()->String{ return "" }
}
/*
 // MARK: APIDelegate
 extension JUMIODocumentOcrCell: APIDelegate {
     public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
     public func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
     public func sendStatusCodeMessage(message: String, error: enumErrorType) {}
     public func didSendError(message: String, error: enumErrorType) {}
     public func didSendResponse(message: String, error: enumErrorType) {}
     public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
 }
 */
