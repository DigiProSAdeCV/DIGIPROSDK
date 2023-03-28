import Foundation
import Eureka
#if canImport(VDDocumentCapture)
import VDDocumentCapture
#endif
#if canImport(VDPhotoSelfieCapture)
import VDPhotoSelfieCapture
#endif
#if canImport(VDVideoSelfieCapture)
import VDVideoSelfieCapture
#endif

extension NuevaPlantillaViewController {
    
    public func obtainJsonComponent(id: String) -> NSMutableDictionary{
        var dict: NSMutableDictionary = NSMutableDictionary()
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/\(Cnstnt.Tree.componentes)/\(id).comp"){
            let gettingJSON = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/\(Cnstnt.Tree.componentes)/\(id).comp")
            if let _ = gettingJSON?.data(using: .utf8){
                do {
                    let jsonDict = try JSONSerializer.toDictionary(gettingJSON!)
                    dict = jsonDict as! NSMutableDictionary
                    return dict
                }catch{ return dict }
            }
        }
        return dict
    }
    
    public func obtainComponetsGeneric(_ element: String){
        if FormularioUtilities.shared.components?.root[element] == nil && FormularioUtilities.shared.components?.root[element]["id"] == nil{return}
        if (FormularioUtilities.shared.components?.root[element]["id"].value) ?? "1" == "2"{
            self.arrayOrder = []
            let dictComponet = self.obtainJsonComponent(id: (FormularioUtilities.shared.components?.root[element]["id"].value)!)
            if dictComponet.count == 0{ return }
            let pout = dictComponet["pout"] as? [[String: Any]]
            for order in pout!{
                let orderNames = order["order"] ?? ""
                self.arrayOrder.append((orderNames as? String)!)
            }
        }else if (FormularioUtilities.shared.components?.root[element]["id"].value) ?? "1" == "4" || (FormularioUtilities.shared.components?.root[element]["id"].value) ?? "1" == "13"{
            self.arrayOrder = []
            let dictOCR = self.obtainJsonComponent(id: (FormularioUtilities.shared.components?.root[element]["id"].value)!)
            if dictOCR.count == 0{ return }
            let arrayPin = dictOCR["pout"] as! [[String:Any]]
            var pinParameters = [[String:Any]]()
            for mP in arrayPin{ pinParameters.append(mP) }
            for values in pinParameters{
                let names = values["name"] ?? ""
                self.validAnchors.append((names as? String)!)
            }
            var poutParameters = [[String:Any]]()
            let pout = dictOCR["pout"] as! NSArray
            for pM in pout{ poutParameters.append(pM as! [String : Any]) }
            for value in poutParameters{
                let order = value["order"] ?? 0
                self.arrayOrder.append(String(describing: (order as? Int)!))
            }
        }
        
    }
    
    public func obtainComponents(_ element: String){
        self.obtainComponetsGeneric(element)
        if FormularioUtilities.shared.components == nil{ return }
        
        switch FormularioUtilities.shared.components?.root[element]["id"].value {
        case "1":
            
            // ENCRYPT
            // GET value only from TEXTOROW
            switch FormularioUtilities.shared.components?.root[element]["pin"]["order_2"]["value"].value {
            case "SHA512":
                
                let elem = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_1"]["idelem"].value)!)
                var encoded = (elem.kind as! TextoRow).value
                if encoded == nil{ return }
                encoded = encoded!.sha512()
                
                let _ = self.resolveValor((FormularioUtilities.shared.components?.root[element]["pout"]["order_1"]["idelem"].value)!, "asignacion", encoded!)
                
                break;
            default: break;
            }
            
            // RULE SUCCESS
            if FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value != nil{
                _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value, eString: nil, vString: nil, forced: true)
            }
            
            // RULE ERROR
            if FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value != nil{
                _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value, eString: nil, vString: nil, forced: true)
            }
            
            break;
        case "2":
            
            // VALIDATE
            // Get rows to validate in the document
            var arrayBaseRow: [BaseRow] = [BaseRow]()
            if !self.arrayOrder.isEmpty{
                for order in self.arrayOrder{
                    if let _ = (FormularioUtilities.shared.components?.root[element]["pin"]["order_\(order)"]["idelem"].value){
                        
                        let elemData = getElementANY((FormularioUtilities.shared.components?.root[element]["pout"]["order_\(order)"]["idelem"].value)!)
                        let row = elemData.kind
                        arrayBaseRow.append(row as! BaseRow)
                    }
                }
                let isValid = self.validateComponentForm(nil, arrayBaseRow)
                if isValid{
                    self.setStatusBarNotificationBanner("not_document".langlocalized(), .success, .bottom)
                }else{
                    let path = self.elementsForValidate.first
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                        let indexPath: IndexPath? = self.form.rowBy(tag: "\(path ?? "")")?.indexPath
                        if indexPath != nil{
                            self.tableView.scrollToRow(at: indexPath ?? IndexPath(row: 0, section: 0), at: .top, animated: true)
                            self.tableView.selectRow(at: indexPath ?? IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
                        }
                        for validate in self.elementsForValidate{
                            _ = self.form.rowBy(tag: "\(validate)")?.validate()
                        }
                        let bannerNew = NotificationBanner(title: "alrt_warning".langlocalized(), subtitle: "not_form_fill".langlocalized(), leftView: nil, rightView: self.warningView, style: .warning, colors: nil)
                        bannerNew.show()
                    }
                }
            }
            
            // RULE SUCCESS
            if FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value != nil{
                _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value, eString: nil, vString: nil, forced: true)
            }
            
            // RULE ERROR
            if FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value != nil{
                _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value, eString: nil, vString: nil, forced: true)
            }
            break;
            
        case "4":
            if ConfigurationManager.shared.isConsubanco{
                // OCR INE
                // Get anchors and set values in the rows for the document
                
                let atributos = OcrIneObject()
                for anchor in self.validAnchors{
                    switch anchor{
                    case "Nombre","nombre": atributos.anchornombre = anchor
                    case "Domicilio": atributos.anchordomicilio = anchor
                    case "CURP", "curp": atributos.anchorcurp = anchor
                    case "Seccion", "seccion": atributos.anchorseccion = anchor
                    case "Clave de Elector", "claveelectoral": atributos.anchorclaveelector = anchor
                    case "Vigencia", "vigencia": atributos.anchorvigencia = anchor
                    case "Sexo", "sexo": atributos.anchorsexo = anchor
                    //case "Folio": atributos.anchorfolio = anchor
                    case "Emision", "emision": atributos.anchoremision = anchor
                    case "Registro", "registro": atributos.anchorregistro = anchor
                    case "Municipio", "municipio": atributos.anchormunicipio = anchor
                    case "Localidad", "localidad": atributos.anchorlocalidad = anchor
                    case "Estado", "estado": atributos.anchorestado = anchor
                    case "CIC", "cic": atributos.anchorcic = anchor
                    default: break;
                    }
                }
                
                let controller = OCRVC(nibName: "WkvQfEJcVZMMkqD", bundle: Cnstnt.Path.framework, service: 1)
                controller.modalPresentationStyle = .fullScreen
                controller.objectOCRINE = atributos
                controller.isFromRule = true
                controller.formDelegate = self
                controller.component = element
                controller.validAnchors = self.validAnchors
                let presented = (UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController
                if presented == nil{
                    self.present(controller, animated: true, completion: nil)
                }else{
                    ((UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController as? UINavigationController)?.present(controller, animated: true, completion: nil)
                    if ConfigurationManager.shared.isConsubanco{
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }else{
                // OCR INE
                // Get anchors and set values in the rows for the document
                
                let atributos = OcrIneObject()
                for anchor in self.validAnchors{
                    switch anchor{
                    case "Nombre","nombre": atributos.anchornombre = anchor
                    case "Domicilio": atributos.anchordomicilio = anchor
                    case "CURP", "curp": atributos.anchorcurp = anchor
                    case "Seccion", "seccion": atributos.anchorseccion = anchor
                    case "Clave de Elector", "claveelectoral": atributos.anchorclaveelector = anchor
                    case "Vigencia", "vigencia": atributos.anchorvigencia = anchor
                    case "Sexo", "sexo": atributos.anchorsexo = anchor
                    //case "Folio": atributos.anchorfolio = anchor
                    case "Emision", "emision": atributos.anchoremision = anchor
                    case "Registro", "registro": atributos.anchorregistro = anchor
                    case "Municipio", "municipio": atributos.anchormunicipio = anchor
                    case "Localidad", "localidad": atributos.anchorlocalidad = anchor
                    case "Estado", "estado": atributos.anchorestado = anchor
                    case "CIC", "cic": atributos.anchorcic = anchor
                    default: break;
                    }
                }
                
                let controller = OCRVC(nibName: "WkvQfEJcVZMMkqD", bundle: Cnstnt.Path.framework, service: 1)
                controller.modalPresentationStyle = .fullScreen
                controller.objectOCRINE = atributos
                controller.isFromRule = true
                controller.formDelegate = self
                controller.component = element
                controller.validAnchors = self.validAnchors
                let presented = (UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController
                if presented == nil{
                    self.present(controller, animated: true, completion: nil)
                }else{
                    ((UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController as? UINavigationController)?.present(controller, animated: true, completion: nil)
                    if ConfigurationManager.shared.isConsubanco{
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
            break;
        case "5":
            // OCR CFE
            let atributos = OcrCfeObject()
            for anchor in self.validAnchors{
                switch anchor{
                case "Nombre": atributos.anchornombre = anchor
                default: break;
                }
            }
            
            let controller = OCRVC(nibName: "WkvQfEJcVZMMkqD", bundle: Cnstnt.Path.framework, service: 3)
            controller.modalPresentationStyle = .fullScreen
            controller.objectOCRCfe = atributos
            controller.isFromRule = true
            controller.formDelegate = self
            controller.component = element
            let presented = (UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController
            if presented == nil{
                self.present(controller, animated: true, completion: nil)
            }else{
                ((UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController as? UINavigationController)?.present(controller, animated: true, completion: nil)
            }
            
            
            break
        case "8":
            //Componente para descomponer CURP
            if plist.idportal.rawValue.dataI() >= 39 {
                let elem = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_1"]["idelem"].value)!)
                let curp = (elem.kind as! TextoRow).value ?? ""
                if curp.isEmpty{self.showNotifOrPopupAlert("notiferror", "not_curp_empty".langlocalized())}else{
                    
                    if !(UtilsF.regexMatchesCURP(text: curp)){
                        self.showNotifOrPopupAlert("notiferror", "not_curp_fail".langlocalized())
                    }else{
                        var birthDate = curp[4...9]
                        birthDate.insert("/", at: birthDate.index(birthDate.startIndex, offsetBy: 2))
                        birthDate.insert("/", at: birthDate.index(birthDate.startIndex, offsetBy: 5))
                        let gender = curp[10..<11]
                        let birthEntity = curp[11...12]
                        let key = curp[16..<18]
                        if let pout = FormularioUtilities.shared.components?.root[element]["pout"]["order_1"]["idelem"].value{
                            _ = self.resolveValor(pout, "asignacion", birthDate)
                        }
                        if let pout = FormularioUtilities.shared.components?.root[element]["pout"]["order_2"]["idelem"].value{
                            _ = self.resolveValor(pout, "asignacion", gender)
                        }
                        if let pout = FormularioUtilities.shared.components?.root[element]["pout"]["order_3"]["idelem"].value{
                            _ = self.resolveValor(pout, "asignacion", birthEntity)
                        }
                        if let pout = FormularioUtilities.shared.components?.root[element]["pout"]["order_4"]["idelem"].value{
                            _ = self.resolveValor(pout, "asignacion", key)
                        }
                    }
                    
                }
                
            }
            break
        case "10":
            // VALIDATE Document to List Checkbox
            let document: DocumentoRow? = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_1"]["idelem"].value)!).kind as? DocumentoRow
            let listrow: ListaRow? = getElementANY((FormularioUtilities.shared.components?.root[element]["pout"]["order_1"]["idelem"].value)!).kind as? ListaRow
            
            if listrow != nil
            {
                var error : Bool = true
                if document?.cell.fedocumentos.count == 0 {
                    for radioButton in listrow!.cell.gralButton.selectedButtons()
                    {   var bndOk = false
                        for doctoId in (document?.cell.fedocumentos)!
                        {   if radioButton.tag == doctoId.TipoDocID
                        {   bndOk = true    }
                        }
                        if !bndOk
                        {   radioButton.isSelected = false
                            listrow!.cell.selectedButton(radioButton: radioButton, isRobot: true)
                        }
                    }
                    return
                }
                for radioButton in listrow!.cell.gralButton.selectedButtons()
                {   if radioButton.tag == (document!.cell.fedocumentos.last)?.TipoDocID
                {   for radioButton in listrow!.cell.gralButton.selectedButtons()
                {   var bndOk = false
                    for doctoId in (document?.cell.fedocumentos)!
                    {   if radioButton.tag == doctoId.TipoDocID
                    {   bndOk = true    }
                    }
                    if !bndOk
                    {   radioButton.isSelected = false
                        listrow!.cell.selectedButton(radioButton: radioButton, isRobot: true)
                    }
                }
                self.showNotifOrPopupAlert("notiferror", "not_typo_fail".langlocalized())
                return
                }
                }
                
                if ((listrow!.cell.gralButton.tag == (document!.cell.fedocumentos.last)?.TipoDocID) && (listrow!.cell.gralButton.isSelected == false) )
                {   error = false
                    listrow!.cell.gralButton.isSelected = true;
                    listrow!.cell.selectedButton(radioButton: listrow!.cell.gralButton, isRobot: true)
                    return
                } else
                {   for radioButton in listrow!.cell.gralButton.otherButtons
                {   if radioButton.tag == (document!.cell.fedocumentos.last)?.TipoDocID
                {   error = false
                    radioButton.isSelected = true;
                    listrow!.cell.selectedButton(radioButton: radioButton, isRobot: true)
                    return
                }
                }
                }
                if error
                {   for radioButton in listrow!.cell.gralButton.selectedButtons()
                {   var bndOk = false
                    for doctoId in (document?.cell.fedocumentos)!
                    {   if radioButton.tag == doctoId.TipoDocID
                    {   bndOk = true    }
                    }
                    if !bndOk
                    {   radioButton.isSelected = false
                        listrow!.cell.selectedButton(radioButton: radioButton, isRobot: true)
                    }
                }
                self.showNotifOrPopupAlert("notiferror", "not_typo_fail".langlocalized())
                return
                }
            }
            
            // RULE SUCCESS
            if FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value != nil{
                _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value, eString: nil, vString: nil, forced: true)
            }
            
            // RULE ERROR
            if FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value != nil{
                _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value, eString: nil, vString: nil, forced: true)
            }
            break;
            
        case "11":
            // VALIDATE Document to List Checkbox
            var res: [Bool] = []
            let value = (FormularioUtilities.shared.components?.root[element]["pin"]["order_1"]["value"].value)!
            let document: DocumentoRow? = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_2"]["idelem"].value)!).kind as? DocumentoRow
            if document?.cell.fedocumentos.count == 0 { return }
            let values = value.split{$0 == ","}.map(String.init)
            for val in values{
                let vv = val.split{$0 == ":"}.map(String.init)
                let id = vv[0]
                
                for doc in document!.cell.fedocumentos{
                    if Int(id) == doc.TipoDocID{ res.append(true) }else{ res.append(false) }
                }
            }
            
            if res.count == 0{
                // RULE ERROR
                if FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value != nil{
                    _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value, eString: nil, vString: nil, forced: true)
                }
            }
            
            
            for r in res{
                if r == false{
                    // RULE ERROR
                    if FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value != nil{
                        _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value, eString: nil, vString: nil, forced: true)
                    }
                }
            }
            
            // RULE SUCCESS
            if FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value != nil{
                _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value, eString: nil, vString: nil, forced: true)
            }
            break;
        case "12":
            // OCR VISA
            // Get anchors and set values in the rows for the document
            let atributos = OcrVisaObject()
            for anchor in self.validAnchors{
                switch anchor{
                case "Nombre": atributos.anchorvisa = anchor
                default: break;
                }
            }
            
            let controller = OCRVC(nibName: "WkvQfEJcVZMMkqD", bundle: Cnstnt.Path.framework, service: 5)
            controller.modalPresentationStyle = .fullScreen
            controller.objectOCRVisa = atributos
            controller.isFromRule = true
            controller.formDelegate = self
            controller.component = element
            let presented = (UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController
            if presented == nil{
                self.present(controller, animated: true, completion: nil)
            }else{
                ((UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController as? UINavigationController)?.present(controller, animated: true, completion: nil)
            }
            break;
            
        case "13":
            // OCR PASAPORTE
            // Get anchors and set values in the rows for the document
            let atributos = OcrPasaporteObject()
            for anchor in self.validAnchors{
                switch anchor{
                case "pais": atributos.anchorclavedelpais = anchor; break;
                case "numero": atributos.anchorpasaportenumero = anchor; break;
                case "apellidopaterno": atributos.anchoraPaterno = anchor; break;
                case "apellidomaterno": atributos.anchoraMaterno = anchor; break;
                case "nombre": atributos.anchornombres = anchor; break;
                case "nacionalidad": atributos.anchornacionalidad = anchor; break;
                case "fechanacimiento": atributos.anchorfechanacimiento = anchor; break;
                case "sexo": atributos.anchorsexo = anchor; break;
                case "caducidad": atributos.anchorfechacaducidad = anchor; break;
                default: break;
                }
            }
            
            let controller = OCRVC(nibName: "WkvQfEJcVZMMkqD", bundle: Cnstnt.Path.framework, service: 4)
            controller.modalPresentationStyle = .fullScreen
            controller.objectOCRPasaporte = atributos
            controller.isFromRule = true
            controller.formDelegate = self
            controller.component = element
            let presented = (UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController
            if presented == nil{
                self.present(controller, animated: true, completion: nil)
            }else{
                ((UIApplication.shared.keyWindow?.rootViewController)?.presentedViewController as? UINavigationController)?.present(controller, animated: true, completion: nil)
            }
            break;
            
        case "15":
            //COMPONENTE VALIDACIÓN CURP
            if plist.idportal.rawValue.dataI() >= 39{
                let elemFirstName = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_1"]["idelem"].value)!)
                let firstName = (elemFirstName.kind as! TextoRow).value?.uppercased().folding(options: .diacriticInsensitive, locale: .current) ?? ""
                let rowFirstName = elemFirstName.kind as! TextoRow
                let elemSecondName = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_2"]["idelem"].value)!)
                let secondName = (elemSecondName.kind as! TextoRow).value?.uppercased().folding(options: .diacriticInsensitive, locale: .current) ?? ""
                let elemSurnameP = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_3"]["idelem"].value)!)
                var surnameP = (elemSurnameP.kind as! TextoRow).value?.uppercased().folding(options: .diacriticInsensitive, locale: .current) ?? ""
                let rowsurnameP = elemSurnameP.kind as! TextoRow
                let elemSurnameM = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_4"]["idelem"].value)!)
                let surnameM = (elemSurnameM.kind as! TextoRow).value?.uppercased().folding(options: .diacriticInsensitive, locale: .current) ?? ""
                let rowsurnameM = elemSurnameM.kind as! TextoRow
                let elemBirthdate = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_5"]["idelem"].value)!)
                let birthdate = (elemBirthdate.kind as! FechaRow).value
                let rowbirthdate = elemBirthdate.kind as! FechaRow
                let elemGender = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_6"]["idelem"].value)!)
                let rowGender = elemGender.kind as! ListaRow
                let gender = (elemGender.kind as! ListaRow).value ?? ""
                let catalogoGender = ConfigurationManager.shared.utilities.getCatalogoInLibrary(rowGender.cell.atributos?.catalogoorigen ?? "")
                let elemBirthEntity = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_7"]["idelem"].value)!)
                let rowBirthEntity = elemBirthEntity.kind as! ListaRow
                let birthEntity = (elemBirthEntity.kind as! ListaRow).value ?? ""
                let catalogoBirthEntity = ConfigurationManager.shared.utilities.getCatalogoInLibrary(rowBirthEntity.cell.atributos?.catalogoorigen ?? "")
                let elemCURP = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_8"]["idelem"].value)!)
                let rowCURP = elemCURP.kind as! TextoRow
                let CURP = (elemCURP.kind as! TextoRow).value?.uppercased() ?? ""
                
                if CURP.isEmpty{
                    self.showNotifOrPopupAlert("notiferror", "not_curp_empty".langlocalized())
                    rowCURP.cell.setMessage(String(format: "not_curp_required".langlocalized(), "CURP"), .error)
                }else if firstName.isEmpty && surnameP.isEmpty && surnameM.isEmpty && birthdate == nil && gender.isEmpty && birthEntity.isEmpty {
                    rowFirstName.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Nombre"), .error)
                    rowsurnameP.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Apellido Paterno"), .error)
                    rowsurnameM.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Apellido Materno"), .error)
                    rowbirthdate.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Fecha de nacimiento"), .error)
                    rowBirthEntity.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Entidad de nacimiento"), .error)
                    rowGender.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Género"), .error)
                }else if firstName.isEmpty{
                    rowFirstName.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Nombre"), .error)
                }else if surnameP.isEmpty{
                    rowsurnameP.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Apellido Paterno"), .error)
                }else if surnameM.isEmpty{
                    rowsurnameM.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Apellido Materno"), .error)
                }else if birthdate == nil{
                    rowbirthdate.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Fecha de nacimiento"), .error)
                }else if gender.isEmpty{
                    rowGender.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Género"), .error)
                }else if birthEntity.isEmpty{
                    rowBirthEntity.cell.setMessage(String(format: "not_curp_required".langlocalized(), "Entidad de nacimiento"), .error)
                }else{
                    if !(UtilsF.regexMatchesCURP(text: CURP)){
                        self.showNotifOrPopupAlert("notiferror", "not_curp_fail".langlocalized())
                    }else{
                        let arrayPrep = ["DA ", "DAS ", "DE ", "DEL ", "DER ", "DI ", "DIE ", "DD ", "EL ", "LA ", "LOS ", "LAS ", "LE ", "LES ", "MAC ", "MC ", "VAN ", "VON ", "Y "]
                        let arrayConsonant = ["B", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z"]
                        let arrayBadWords = ["BACA", "BAKA", "BUEI", "BUEY", "CACA", "CACO", "CAGA", "CAGO", "CAKA", "CAKO", "COGE", "COGI", "COJA", "COJE", "COJI", "COJO", "COLA" , "CULO", "FALO", "FETO", "GETA", "GUEI", "GUEY", "JETA", "JOTO", "KACA", "KACO", "KAGA", "KAGO", "KAKA", "KAKO", "KOGE", "KOGI", "KOJA", "KOJE", "KOJI", "KOJO", "KOLA", "KULO", "LILO", "LOCA", "LOCO", "LOKA", "LOKO", "MAME", "MAMO", "MEAR", "MEAS", "MEON", "MIAR", "MION", "MOCO", "MOKO", "MULA", "MULO", "NACA", "NACO", "PEDA", "PEDO", "PENE", "PIPI", "PITO", "POPO", "PUTA", "PUTO", "QULO", "RATA", "ROBA", "ROBE", "ROBO", "RUIN", "SENO", "TETA", "VACA", "VAGA", "VAGO", "VAKA", "VUEI", "VUEY", "WUEI", "WUEY"]
                        var letterFirstName = ""
                        var letterSecondName = ""
                        var letterSurnameP = ""
                        var letterSurnameM = ""
                        if surnameP.prefix(1) == "Ñ"{
                            letterSurnameP = "X\(surnameP[1..<2])"
                            if surnameM.prefix(1) == "Ñ"{
                                letterSurnameM = "X"
                            }else{
                                letterSurnameM = "\(surnameM.prefix(1))"
                            }
                        }else if surnameM.prefix(1) == "Ñ"{
                            if surnameP.prefix(1) == "Ñ"{
                                letterSurnameP = "X\(surnameP[1..<2])"
                            }else{
                                letterSurnameP = "\(surnameP.prefix(2))"
                            }
                            letterSurnameM = "X"
                        }else if surnameP.contains("/") || surnameP.contains("-") || surnameP.contains("."){
                            letterSurnameP = "\(surnameP.prefix(1))X"
                        } else{
                            letterSurnameP = "\(surnameP.prefix(2))"
                            letterSurnameM = "\(surnameM.prefix(1))"
                        }
                        
                        if !surnameP.contains("A") && !surnameP.contains("E") && !surnameP.contains("I") && !surnameP.contains("O") && !surnameP.contains("U"){
                            letterSurnameP = "\(surnameP.prefix(1))X"
                        }
                        
                        
                        
                        if surnameM.isEmpty{
                            letterSurnameM = "X"
                        }
                        
                        for letter in arrayPrep{
                            if surnameP.contains(letter){
                                surnameP = surnameP.replacingOccurrences(of: letter, with: "")
                                letterSurnameP = "\(surnameP.prefix(2))"
                            }
                        }
                        var newString = ""
                        let firstLetter = removeVowels(input: surnameP)
                        var newFirstLetter = ""
                        var nameConsonant = ""
                        for c in arrayConsonant{
                            if surnameP[1..<3].contains(c) || surnameP[1..<4].contains(c){
                                newString = surnameP
                                if newString.contains(c){
                                    newString = newString.replacingOccurrences(of: c, with: "")
                                    letterSurnameP = "\(newString.prefix(2))"
                                    
                                    if letterSurnameP.contains(newFirstLetter){
                                        newFirstLetter = firstLetter[1..<2]
                                    }else{
                                        newFirstLetter = firstLetter[0..<1]
                                    }
                                    
                                }else{
                                    newFirstLetter = firstLetter[1..<2]
                                }
                            }
                        }
                        
                        
                        if firstName.prefix(1) == "Ñ" {
                            letterFirstName = "X"
                        }else{
                            letterFirstName = "\(firstName.prefix(1))"
                        }
                        if !secondName.isEmpty{
                            let compoundName = "\(firstName)\(secondName)"
                            if compoundName.contains("MARIA") || compoundName.contains("MA") || compoundName.contains("MA.") || compoundName.contains("JOSE"){
                                if secondName.prefix(1) == "Ñ"{
                                    letterSecondName = "X"
                                    letterFirstName = ""
                                }else{
                                    letterSecondName = "\(secondName.prefix(1))"
                                    letterFirstName = ""
                                }
                                
                            }
                        }
                        
                        
                        var curpDate = ""
                        if birthdate != nil{
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yy/MM/dd"
                            var todaysDate = dateFormatter.string(from: birthdate!)
                            todaysDate = todaysDate.replacingOccurrences(of: "/", with: "")
                            curpDate = todaysDate
                            
                        }
                        var genderData = ""
                        for g in catalogoGender!.Catalogo{
                            if gender == g.Descripcion{
                                genderData = g.CVECatalogo
                            }
                        }
                        var birthEntityData = ""
                        for be in catalogoBirthEntity!.Catalogo{
                            if birthEntity == be.Descripcion{
                                birthEntityData = be.CVECatalogo
                            }
                        }
                        
                        
                        let thirdLetter = removeVowels(input: firstName)
                        
                        if firstName.prefix(1) == "A" || firstName.prefix(1) == "E" || firstName.prefix(1) == "A" || firstName.prefix(1) == "I" || firstName.prefix(1) == "O" || firstName.prefix(1) == "U" {
                            nameConsonant = thirdLetter[0..<1]
                        }else{
                            nameConsonant = thirdLetter[1..<2]
                        }
                        
                        let key = CURP[16..<18]
                        let letterCurp = CURP[13..<16]
                        
                        var curpValidate = "\(letterSurnameP.uppercased())\(letterSurnameM.uppercased())\(letterFirstName)\(letterSecondName)\(curpDate)\(genderData)\(birthEntityData)\(letterCurp)\(key)"
                        
                        for badWord in arrayBadWords{
                            if curpValidate[0..<4] == badWord{
                                let curpNewValidate = "\(curpValidate[0..<1])X\(letterSurnameM.uppercased())\(letterFirstName)\(letterSecondName)\(curpDate)\(genderData)\(birthEntityData)\(letterCurp)\(key)"
                                curpValidate = curpNewValidate
                            }
                        }
                        
                        if let pout = FormularioUtilities.shared.components?.root[element]["pout"]["order_1"]["idelem"].value{
                            if curpValidate == CURP{
                                self.showNotifOrPopupAlert("notif", "not_curp_ok".langlocalized())
                                _ = self.resolveValor(pout, "asignacion", curpValidate.uppercased() )
                            }else{
                                self.showNotifOrPopupAlert("notiferror", "not_curp_error".langlocalized())
                            }
                            
                        }
                    }
                    
                }
            }
            break
        case "16":
            // Convert base64 to PDF
            let elem = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_1"]["idelem"].value)!)
            let ext = (FormularioUtilities.shared.components?.root[element]["pin"]["order_2"]["value"].value) ?? "txt"
            let elemName = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_3"]["idelem"].value) ?? "")
            var name: String?
            var valuebase64: String?
            if elemName.kind == nil{
                name = "archivotemp"
            }else{
                switch elemName.kind {
                case is TextoRow:
                    name = (elemName.kind as! TextoRow).value ?? "archivotemp";
                    break;
                case is TextoAreaRow:
                    name = (elemName.kind as! TextoAreaRow).value ?? "archivotemp";
                    break;
                default: break;
                }
            }
            switch elem.kind {
            case is TextoRow:
                valuebase64 = (elem.kind as! TextoRow).value ?? "";
                break;
            case is TextoAreaRow:
                valuebase64 = (elem.kind as! TextoAreaRow).value ?? "";
                break;
            default: break;
            }
            if valuebase64 == nil{ return }
            guard let data = Data(base64Encoded: (valuebase64 ?? "") as String, options: .ignoreUnknownCharacters) else{ return }
            
            FCFileManager.createFile(atPath: "\(Cnstnt.Tree.main)/\(name ?? "archivotemp").\(ext)", withContent: data as! NSObject, overwrite: true);
            DispatchQueue.main.async {
                let file = FCFileManager.urlForItem(atPath: "\(Cnstnt.Tree.main)/\(name ?? "archivotemp").\(ext)")
                if file == nil{ return }
                let activityViewController = UIActivityViewController(activityItems: [file!], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                    if completed {
                        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.main)/\(name ?? "archivotemp").\(ext)")
                    }
                }
            }
            
            // RULE SUCCESS
            if FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value != nil{
                _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value, eString: nil, vString: nil, forced: true)
            }
            
            // RULE ERROR
            if FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value != nil{
                _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value, eString: nil, vString: nil, forced: true)
            }
            break;
        case "17":
            //Componente para descomponer FECHA
            if FormularioUtilities.shared.components?.root[element]["pin"]["order_1"]["name"].value == "Fecha"
            {
                let elem = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_1"]["idelem"].value)!)
                if let fecha = (elem.kind as! FechaRow).value
                {
                    let formatter = DateFormatter()
                    formatter.timeZone = TimeZone.current
                    formatter.locale = Locale(identifier: "es_MX")
                    formatter.dateFormat = "yyyy-MM-dd"
                    if formatter.string(from: fecha) != ""
                    {   let fechaOK = formatter.string(from: fecha)
                        let formattDay = FormularioUtilities.shared.components?.root[element]["pin"]["order_2"]["value"].value
                        let formattMonth = FormularioUtilities.shared.components?.root[element]["pin"]["order_3"]["value"].value
                        let formattYear = FormularioUtilities.shared.components?.root[element]["pin"]["order_4"]["value"].value
                        
                        if FormularioUtilities.shared.components?.root[element]["pout"]["order_1"]["name"].value == "Día",
                           let poutD = FormularioUtilities.shared.components?.root[element]["pout"]["order_1"]["idelem"].value
                        {   // d(sin 0) - dd(con 0)
                            var dia = String(fechaOK.split(separator: "-")[2])
                            switch formattDay
                            {   case "d":
                                dia = dia.first == "0" ? String(dia.dropFirst()) : dia
                                break;
                            case "dd":
                                dia = dia.count == 2 ? dia : "0\(dia)"
                                break;
                            default:
                                break;
                            }
                            _ = self.resolveValor(poutD, "asignacion", dia)
                        }
                        
                        if FormularioUtilities.shared.components?.root[element]["pout"]["order_2"]["name"].value == "Mes",
                           let poutM = FormularioUtilities.shared.components?.root[element]["pout"]["order_2"]["idelem"].value
                        {   // s(abreviado) - ss(con letras) - m (sin 0) - mm(con 0)
                            var mes = String(fechaOK.split(separator: "-")[1])
                            switch formattMonth
                            {   case "m":
                                mes = mes.first == "0" ? String(mes.dropFirst()) : mes
                                break;
                            case "mm":
                                mes = mes.count == 2 ? mes : "0\(mes)"
                                break;
                            case "s":
                                let formDate = DateFormatter()
                                formDate.timeZone = TimeZone.current
                                formDate.locale = Locale(identifier: "es_MX")
                                formDate.dateFormat = "MMM d, yyyy"
                                let mesOK = formDate.string(from: fecha)
                                mes = String(mesOK.split(separator: " ")[0])
                                mes = mes.capitalizingFirstLetter()
                                break;
                            case "ss":
                                let formDate = DateFormatter()
                                formDate.timeZone = TimeZone.current
                                formDate.locale = Locale(identifier: "es_MX")
                                formDate.dateFormat = "MMMM yyyy"
                                let mesOK = formDate.string(from: fecha)
                                mes = String(mesOK.split(separator: " ")[0])
                                mes = mes.capitalizingFirstLetter()
                                break;
                            default:
                                break;
                            }
                            _ = self.resolveValor(poutM, "asignacion", mes)
                        }
                        
                        if FormularioUtilities.shared.components?.root[element]["pout"]["order_3"]["name"].value == "Año",
                           let poutA = FormularioUtilities.shared.components?.root[element]["pout"]["order_3"]["idelem"].value
                        {   // y(2 dig) - yy(4 dig)
                            var year = String(fechaOK.split(separator: "-")[0])
                            if formattYear == "y"
                            {   year = String(year.dropFirst())
                                year = String(year.dropFirst())
                            }
                            _ = self.resolveValor(poutA, "asignacion", year)
                        }
                        
                    } else { self.showNotifOrPopupAlert("notiferror", "not_date_fail".langlocalized()) }
                }else { self.showNotifOrPopupAlert("notiferror", "not_date_empty".langlocalized()) }
            }
            break
        case "18":
            //MARK: Captura automática de cara y documento VERIDAS
            // element -> idTagXML del componente que se esta ejecutando
            elemtVDDocument = FormularioUtilities.shared.components?.root[element]
            let configuration: [String : String] = ["closebutton": "YES","documentmobileoval": "YES"]
            if !VDVideoSelfieCapture.isStarted() {
                VDVideoSelfieCapture.setDocumentStringToSearch("documentName") // This document is retrieved, when possible, from VDDocumentCapture
                VDVideoSelfieCapture.start(withDelegate: self, andConfiguration: configuration) }
            break
        case "19":
            //MARK: Detección y captura automática de identificación VERIDAS
            elemtVDDocument = FormularioUtilities.shared.components?.root[element]
            let configuration : [String : String] = ["closebutton": "YES", "obverseflash": "NO"]
            let documents : [String] = ["MX_IDCard_2008","MX_IDCard_2014", "MX_IDCard_2019"]
            if !VDDocumentCapture.isStarted() {
                VDDocumentCapture.start(withDelegate: self, andDocumentIds: documents, andConfiguration: configuration)
            }
            break
        case "20":
            elemtVDDocument = FormularioUtilities.shared.components?.root[element]
            //MARK: Captura automática de cara VERIDAS
            let configuration: [String : String] = ["closebutton": "YES","livephoto": "YES"]
            if !VDPhotoSelfieCapture.isStarted() {
                VDPhotoSelfieCapture.start(withDelegate: self, andConfiguration: configuration) }
            break
        case "21": //Netpay
            self.elemNetPay = element
            let formulario = FormularioUtilities.shared.components?.root[element]
            netPayInfoViewController = NetPayInfoViewController(nibName: "NetPayInfoViewController", bundle: Cnstnt.Path.framework)
            netPayInfoViewController!.delegate = self
            _ = netPayInfoViewController!.view
            
            var componentes: [NetPayComponent] = [NetPayComponent]()
            
            for element in formulario!["pin"].children {
                
                let nombre = element["name"].value!
                var component = NetPayComponent(orden: element.name, nombre: nombre, valor: "")
                
                let idElement = element["idelem"].value
                
                if let id = idElement {
                    let elem = getElementANY(id)
                    
                    switch elem.kind {
                    case is TextoRow:
                        let textoRow: TextoRow = elem.kind as! TextoRow
                        component.valor = textoRow.value ?? ""
                        break
                    case is TextoAreaRow:
                        let textoRow: TextoAreaRow = elem.kind as! TextoAreaRow
                        component.valor = textoRow.value ?? ""
                        break
                    case is NumeroRow:
                        let numeroRow: NumeroRow = elem.kind as! NumeroRow
                        component.valor = numeroRow.value ?? ""
                        break
                    case is MonedaRow:
                        let monedaRow: MonedaRow = elem.kind as! MonedaRow
                        component.valor = monedaRow.value ?? ""
                    default:
                        break
                    }
                    componentes.append(component)
                }
            }
            
            netPayInfoViewController!.configure(with: componentes, completion: {
                self.present(self.netPayInfoViewController!, animated: true, completion: nil)
            })
        case "22":
            let valueRegex = FormularioUtilities.shared.components?.root[element]["pin"]["order_1"]["value"].string
            let elem = getElementANY((FormularioUtilities.shared.components?.root[element]["pin"]["order_2"]["idelem"].value)!)
            let valueElement = (elem.kind as! TextoRow).value ?? ""
            
            let matched = matches(for: valueRegex ?? "", in: valueElement)
            if !matched.isEmpty{
                let poutA = FormularioUtilities.shared.components?.root[element]["pout"]["order_1"]["idelem"].value
                _ = self.resolveValor(poutA!, "asignacion", matched[0])
                print("MATCHED STRING: \(matched[0])")
            }
            
            break
        default: break;
        }
        
    }
    
    func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    public func setOCRDetails(_ service: Int, _ object: AnyObject, _ element: String){
        switch service{
        case 1:
            let atributos = object as? OcrIneObject
            if !self.arrayOrder.isEmpty{
                for order in self.arrayOrder{
                    if let elem = (FormularioUtilities.shared.components?.root[element]["pout"]["order_\(order)"]["idelem"].value){
                        
                        switch order{
                        
                        case "1": let _ = self.resolveValor(elem, "asignacion", atributos?.nombre ?? "")
                        case "2": let _ = self.resolveValor(elem, "asignacion", atributos?.aPaterno ?? "")
                        case "3": let _ = self.resolveValor(elem, "asignacion", atributos?.aMaterno ?? "")
                        case "4": let _ = self.resolveValor(elem, "asignacion", atributos?.calle ?? "")
                        case "5": let _ = self.resolveValor(elem, "asignacion", atributos?.colonia ?? "")
                        case "6": let _ = self.resolveValor(elem, "asignacion", atributos?.delegacion ?? "")
                        case "7": let _ = self.resolveValor(elem, "asignacion", atributos?.ciudad ?? "")
                        case "8": let _ = self.resolveValor(elem, "asignacion", atributos?.cP ?? "")
                        case "9": let _ = self.resolveValor(elem, "asignacion", atributos?.curp ?? "")
                        case "10": let _ = self.resolveValor(elem, "asignacion", atributos?.rfc ?? "")
                        case "11": let _ = self.resolveValor(elem, "asignacion", atributos?.seccion ?? "")
                        case "12": let _ = self.resolveValor(elem, "asignacion", atributos?.claveElector ?? "")
                        case "13": let _ = self.resolveValor(elem, "asignacion", atributos?.vigencia ?? "")
                        case "14": let _ = self.resolveValor(elem, "asignacion", atributos?.fecha ?? "")
                        case "15": let _ = self.resolveValor(elem, "asignacion", atributos?.edad ?? "")
                        case "16": let _ = self.resolveValor(elem, "asignacion", atributos?.sexo ?? "")
                        case "17": let _ = self.resolveValor(elem, "asignacion", atributos?.folio ?? "")
                        case "18": let _ = self.resolveValor(elem, "asignacion", atributos?.registro ?? "")
                        case "19": let _ = self.resolveValor(elem, "asignacion", atributos?.municipio ?? "")
                        case "20": let _ = self.resolveValor(elem, "asignacion", atributos?.localidad ?? "")
                        case "21": let _ = self.resolveValor(elem, "asignacion", atributos?.reposicion ?? "")
                        case "22": let _ = self.resolveValor(elem, "asignacion", atributos?.emision ?? "")
                        case "23": let _ = self.resolveValor(elem, "asignacion", atributos?.estado ?? "")
                        case "24": let _ = self.resolveValor(elem, "asignacion", atributos?.cic ?? "")
                        case "25": let _ = self.resolveValor(elem, "asignacion", atributos?.ocr ?? "")
                        case "26": let _ = self.resolveValor(elem, "asignacion", atributos?.ineanverso ?? "")
                        case "27": let _ = self.resolveValor(elem, "asignacion", atributos?.inereverso ?? "")
                        // Images OCR Ine Front/Back
                        //case "26": let _ = self.resolveValor(elem, "asignacion", atributos.registro)
                        //case "27": let _ = self.resolveValor(elem, "asignacion", atributos.registro)
                        default: break;
                        }
                        
                    }
                }
            }
            break;
        case 4:
            let atributos = object as? OcrPasaporteObject
            if !self.arrayOrder.isEmpty{
                for order in self.arrayOrder{
                    if let elem = (FormularioUtilities.shared.components?.root[element]["pout"]["order_\(order)"]["idelem"].value){
                        
                        switch order{
                        
                        case "1": let _ = self.resolveValor(elem, "asignacion", atributos?.clavedelpais ?? "")
                        case "2": let _ = self.resolveValor(elem, "asignacion", atributos?.pasaportenumero ?? "")
                        case "3": let _ = self.resolveValor(elem, "asignacion", "\(atributos?.aPaterno ?? "")")
                        case "4": let _ = self.resolveValor(elem, "asignacion", "\(atributos?.aMaterno ?? "")")
                        case "5": let _ = self.resolveValor(elem, "asignacion", atributos?.nombres ?? "")
                        case "6": let _ = self.resolveValor(elem, "asignacion", atributos?.nacionalidad ?? "")
                        case "7": let _ = self.resolveValor(elem, "asignacion", atributos?.observaciones ?? "")
                        case "8": let _ = self.resolveValor(elem, "asignacion", atributos?.fechanacimiento ?? "")
                        case "9": let _ = self.resolveValor(elem, "asignacion", atributos?.curp ?? "")
                        case "10": let _ = self.resolveValor(elem, "asignacion", atributos?.sexo ?? "")
                        case "11": let _ = self.resolveValor(elem, "asignacion", atributos?.lugarnacimiento ?? "")
                        case "12": let _ = self.resolveValor(elem, "asignacion", atributos?.fechaexpedicion ?? "")
                        case "13": let _ = self.resolveValor(elem, "asignacion", atributos?.fechacaducidad ?? "")
                        //case "14": let _ = self.resolveValor(elem, "asignacion", atributos?.autoridad ?? "")
                        
                        default: break;
                        }
                        
                    }
                }
            }
            break;
        default: break;
        }
        
        // RULE SUCCESS
        if FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value != nil{
            _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["rulesuccess"].value, eString: nil, vString: nil, forced: true)
        }
        
        // RULE ERROR
        if FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value != nil{
            _ = self.obtainRules(rString: FormularioUtilities.shared.components?.root[element]["response"]["ruleerror"].value, eString: nil, vString: nil, forced: true)
        }
    }
    
    public  func removeVowels(input: String) -> String {
        let vowels: [Character] = ["a", "e", "i", "o", "u", "A", "E", "I", "O", "U"]
        let result = String(input.filter { !vowels.contains($0) })
        return result
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

// MARK: NetPayInfoViewControllerDelegate
extension NuevaPlantillaViewController : NetPayInfoViewControllerDelegate {
    public func checkoutTransaction(netpayResponse: NetPayResponse?) {
        netPayInfoViewController!.dismiss(animated: false, completion: nil)
        if let response = netpayResponse {
            let checkoutVC = PagoExitosoViewController(nibName: "PagoExitosoViewController", bundle: Cnstnt.Path.framework)
            _ = checkoutVC.view

            let formulario = FormularioUtilities.shared.components?.root[self.elemNetPay]
            for element in formulario!["pout"].children {
                if element.name == "order_1" {
                    //Obtener elemento y escribir transactionID
                    if let idElement = element["idelem"].value {
                        let elem = getElementANY(idElement)
                        if elem.kind is TextoRow {
                            let textoRow: TextoRow = elem.kind as! TextoRow
                            textoRow.cell.setEdited(v: response.transactionTokenId ?? "")
                        } else if elem.kind is TextoAreaRow {
                            let textoRow: TextoAreaRow = elem.kind as! TextoAreaRow
                            textoRow.cell.setEdited(v: response.transactionTokenId ?? "")
                            print("Elemento mal configurado")
                        }
                    }
                }
            }
            checkoutVC.configuraRecibo(recibo: response, completion: {
                DispatchQueue.main.async {
                    self.present(checkoutVC, animated: true)
                }
            })
        } else {
            let failVC = PagoFracasadoViewController(nibName: "PagoFracasadoViewController", bundle: Cnstnt.Path.framework)
            _ = failVC.view
            
            DispatchQueue.main.async {
                self.present(failVC, animated: true)
            }
        }
    }
}
