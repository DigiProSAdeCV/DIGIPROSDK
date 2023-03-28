//
//  UniversalFunctions.swift
//  DGFmwrk
//
//  Created by Jonathan Viloria M on 1/11/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation

public protocol ObjectFormDelegate: AnyObject {
    func setEstadistica()
    func setEstadisticaV2()
    func setTextStyle(_ style: String)
    func setDecoration(_ decor: String)
    func setAlignment(_ align: String)
    func setVariableHeight(Height h: CGFloat)
    func setTitleText(_ text:String)
    func setSubtitleText(_ text:String)
    func setHeightFromTitles()
    func setPlaceholder(_ text:String)
    func setInfo()
    func toogleToolTip(_ help: String)
    func setMessage(_ string: String, _ state: enumErrorType)
    func initRules()
    func setMinMax()
    func setExpresionRegular()
    func setOcultarTitulo(_ bool: Bool)
    func setOcultarSubtitulo(_ bool: Bool)
    func setHabilitado(_ bool: Bool)
    func setEdited(v: String)
    func setEdited(v: String, isRobot: Bool)
    func setVisible(_ bool: Bool)
    func setRequerido(_ bool: Bool)
    func resetValidation()
    func updateIfIsValid(isDefault: Bool)

    func triggerEvent(_ action: String)
    func setRulesOnProperties()
    func setRulesOnChange()
    func triggerRulesOnProperties(_ action: String)
    func triggerRulesOnChange(_ action: String?)

    func setMathematics(_ bool: Bool, _ id: String)
}

public final class ObjectFormManager<Delegate: ObjectFormDelegate>: NSObject {
    public weak var delegate: ObjectFormDelegate?
}

public protocol AttachedFormDelegate: AnyObject {
    func didSetLocalAnexo(_ feAnexo: FEAnexoData)
    func setAnexoOption(_ anexo: FEAnexoData)
    func setAttributesToController()
    func setPreview(_ sender: Any)
    func setDownloadAnexo(_ sender: Any)
    func setAnexo(_ anexo: FEAnexoData)
}

public final class AttachedFormManager<Delegate: AttachedFormDelegate>: NSObject {
    public weak var delegate: AttachedFormDelegate?
}

public protocol GetInfoRowDelegate: AnyObject{
    func getMessageText()->String
    func getRowEnabled()->Bool
    func getRequired()->Bool
    func getTitleLabel()->String
    func getSubtitleLabel()->String
}

public final class InfoRowManager<Delegate: GetInfoRowDelegate>: NSObject {
    public weak var delegate: GetInfoRowDelegate?
}

public protocol MetaFormDelegate: AnyObject {
    func didClose()
    func didSave()
    func savingData()
    func didUpdateData(_ tipoDoc: String, _ idDoc: Int)
}

public final class MetaFormManager<Delegate: MetaFormDelegate>: NSObject {
    public weak var delegate: MetaFormDelegate?
}
