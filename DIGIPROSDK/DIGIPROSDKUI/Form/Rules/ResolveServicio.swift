import Foundation
import CommonCrypto

import Eureka
import MobileCoreServices
import PDFKit

extension NuevaPlantillaViewController{
    
    public func showLoading(){
        self.hud.dismiss(animated: true)
        DispatchQueue.main.async{
            self.hud.show(in: self.view)
        }
    }
    
    public func stopLoading(){
        DispatchQueue.main.async{
            self.hud.dismiss(animated: true)
        }
    }
    
    public func getSystemParameters(_ sysName: String) -> [String:String]{
        var valueParameter: String = ""
        switch sysName {
        case "proyid":
            valueParameter = "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)"
            break
        case "expid":
            valueParameter = "\(ConfigurationManager.shared.plantillaDataUIAppDelegate.ExpID)"
            break
        case "grupoid":
            valueParameter = "\(ConfigurationManager.shared.usuarioUIAppDelegate.GrupoAdminID)"
            break
        case "user":
            valueParameter = "\(ConfigurationManager.shared.usuarioUIAppDelegate.User)"
            break
        case "Grupo":
            valueParameter = "\(ConfigurationManager.shared.codigoUIAppDelegate.GrupoRegistro)"
            break
        case "Perfiles":
            valueParameter = "\(ConfigurationManager.shared.codigoUIAppDelegate.Perfiles)"
            break
        case "Tipo de Sms":
            valueParameter = "1"
        case "ticket": valueParameter = ""
            break
        case "Url del sitio (solo el portal, sin pagina, ejem: http://algo.com/portal)":
            valueParameter = Obfuscator().reveal(key: ObfuscatedCnstnt.uptl)
            break
        default:
            
            break
        }
        if valueParameter.isEmpty{
           return ["":""]
        }else{
           return [sysName:valueParameter]
        }
        
    }

    // AQUI SE HACE LA OBTENCIÓN DE LOS DATOS RESPECTO AL SERVICIO
    public func obtainJson(id: String) -> NSMutableDictionary?{
        if FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/\(Cnstnt.Tree.servicios)/\(id).ser"){
            let gettingJSON = ConfigurationManager.shared.utilities.read(asString: "\(Cnstnt.Tree.codigos)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)/\(Cnstnt.Tree.servicios)/\(id).ser")
            if let _ = gettingJSON?.data(using: .utf8){
                do {
                    let jsonDict = try JSONSerializer.toDictionary(gettingJSON!)
                    return jsonDict as? NSMutableDictionary
                }catch{ return nil }
            }
        }
        return nil
    }
    
    func decodeXML(aexmlD: AEXMLDocument, r: String = "") -> String{
        var returnObj: String = ""
        do{
            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                let encodigSoapTest = try self.decodeReturnSoap(aexmlD["s:Envelope"]["s:Body"]["response"].string)
                let jsonDict = try JSONSerializer.toDictionary(encodigSoapTest)
                if let returnobj = jsonDict["ReturnedObject"] as? String{
                    returnObj = returnobj
                }
            }else{
                
                returnObj = r
            }

        }catch{
            let e = "alrt_error_try".langlocalized()
            ConfigurationManager.shared.utilities.writeLogger("\(e)\r\n", .error)
            
        }
        return returnObj
    }
    
    public func servicioGenericoJSON(_ element: String){
        
        self.historiaOBJ.Categoria = "ServicioV2"
        let fechaHistoria = Date.getTicks()
        self.historiaOBJ.FechaHistoria = fechaHistoria
        let nameService = FormularioUtilities.shared.services?.root[element]["initialmethod"].value ?? ""
        let dllService = FormularioUtilities.shared.services?.root[element]["assemblypath"].value ?? ""
        let sufijoEnt = FormularioUtilities.shared.services?.root[element]["prefijoentrada"].value ?? ""
        let sufijoSal = FormularioUtilities.shared.services?.root[element]["prefijosalida"].value ?? ""
        let elemData = getElementService(sufijoEnt, false)
        //elemData.updateValue(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID, forKey: "proyid")
        //elemData.updateValue(FormularioUtilities.shared.currentFormato.ExpID, forKey: "expid")
        
        if nameService.contains("SolicitayDescargaSellado"){
            self.compareFaceFlag = true
        }
        ConfigurationManager.shared.assemblypath = FormularioUtilities.shared.services?.root[element]["assemblypath"].value ?? ""
        ConfigurationManager.shared.initialmethod = FormularioUtilities.shared.services?.root[element]["initialmethod"].value ?? ""
        let dictService = ["initialmethod":"\(nameService)","assemblypath":"\(dllService)", "data": elemData] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        let request = Requests()
        let _ = request.xmlGenericJSONRequest(jsonService: NSString(string: jsonString))
        let response = sdkAPI?.soapGenericJsonSync(delegate: self, jsonService: NSString(string: jsonString))
        let jsonService = response!["s:Envelope"]["s:Body"]["ServicioGenericoStringResponse"]["ServicioGenericoStringResult"].value
        let responseDecode = self.decodeXML(aexmlD: response!, r: jsonService ?? "")
        
        if (jsonService?.data(using: .utf8) != nil) || (responseDecode != "") {
            do {
                let valorResponse = jsonService != nil ? jsonService! : responseDecode
                let jsonDict = try JSONSerializer.toDictionary(valorResponse)
                let dataService = jsonDict["data"] as! NSMutableDictionary
                let responseService = jsonDict["response"] as! NSMutableDictionary
                let servicesuccess = responseService["servicesuccess"] as! Bool
                let success = responseService["success"] as! Bool

                if servicesuccess && success{
                    // RULE SUCCESS
                    self.historiaOBJ.Descripcion = "\(nameService): con respuesta: Consulta Exitosa"
                    if plist.idportal.rawValue.dataI() >= 42{
                        if let dictFormato = dataService["formatodata"] {
                            self.saveFormat(feFormato: dictFormato as! String)
                        }
                    }

                    let arrayData = getElementService(sufijoSal, true)
                    for elem in arrayData
                    {
                        let aux = String((elem.value as! String).split(separator: "-").last ?? "")
                        if dataService[aux] != nil
                        {
                            if (elem.value as? String ?? "").contains("istable")
                            {   let value = (dataService[aux] as? NSArray) ?? []
                                 var valueString = ""
                                for rows in value
                                {   let row = rows as? NSMutableDictionary ?? NSMutableDictionary()
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: row)
                                        if let json = String(data: jsonData, encoding: .utf8) {
                                            valueString = "\(valueString)\(json)|"
                                        }
                                    } catch {
                                        print("something went wrong with parsing json")
                                    }
                                }
                                _ = self.resolveValor(elem.key, "asignacion", valueString)
                            } else
                            {
                                let valStr = (dataService[aux] as? String)
                                if valStr != nil{
                                    _ = self.resolveValor(elem.key, "asignacion", valStr ?? "")
                                    continue
                                }
                                let valBool = (dataService[aux] as? Bool)
                                if valBool != nil{
                                    let strBool = String(valBool ?? false)
                                    _ = self.resolveValor(elem.key, "asignacion", strBool)
                                    continue
                                }
                                let valInt = (dataService[aux] as? Int)
                                if valInt != nil{
                                    let strInt = String(valInt ?? 0)
                                    _ = self.resolveValor(elem.key, "asignacion", strInt)
                                    continue
                                }
                            }
                        }
                    }
                    stopLoading()
                    //Si es exitoso el servicio obtiene reglas a ejecutar
                    if let rulesSuccess = FormularioUtilities.shared.services?.root[element]["response"]["rulesuccess"]{
                        //Tiempo de espera para las reglas: (milisegundos)
                        let time = FormularioUtilities.shared.services?.root[element]["response"] ["waittofinish"].value != nil ? FormularioUtilities.shared.services?.root[element]["response"] ["waittofinish"].value ?? "" : ""
                        // Evaluar las reglas: (bool)
                        let auxEvaluate = FormularioUtilities.shared.services?.root[element]["response"] ["evaluaterules"].value != nil ? FormularioUtilities.shared.services?.root[element]["response"] ["evaluaterules"].value ?? "" : ""
                          
                        if Bool(auxEvaluate) ?? false {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(time) ?? 0), execute: {
                                for rule in rulesSuccess.children {
                                    _ = self.obtainRules(rString: rule.name, eString: nil, vString: nil, forced: true, override: false)
                                }
                            })
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(time) ?? 0), execute: {
                                for rule in rulesSuccess.children {
                                    _ = self.obtainRules(rString: rule.name, eString: nil, vString: nil, forced: true, override: true)
                                }
                            })
                        }
                    }
                }else{
                    stopLoading()
                    // RULE ERROR
                    self.historiaOBJ.Descripcion = "\(nameService): con respuesta: Consulta No Exitosa"
                    if let rulesError = FormularioUtilities.shared.services?.root[element]["response"]["ruleerror"] {
                        //Tiempo de espera para las reglas: (milisegundos)
                        let time = FormularioUtilities.shared.services?.root[element]["response"] ["waittofinish"].value != nil ? FormularioUtilities.shared.services?.root[element]["response"] ["waittofinish"].value ?? "0" : "0"
                        // Evaluar las reglas: (bool)
                        let auxEvaluate = FormularioUtilities.shared.services?.root[element]["response"] ["evaluaterules"].value != nil ? FormularioUtilities.shared.services?.root[element]["response"] ["evaluaterules"].value ?? "false" : "false"
                          
                        if Bool(auxEvaluate) ?? false {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(time) ?? 0), execute: {
                                for rule in rulesError.children{
                                    _ = self.obtainRules(rString: rule.name, eString: nil, vString: nil, forced: true, override: false)
                                }
                            })
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(time) ?? 0), execute: {
                                for rule in rulesError.children {
                                    _ = self.obtainRules(rString: rule.name, eString: nil, vString: nil, forced: true, override: true)
                                }
                            })
                        }
                    }
                }
               
                if let servicemessage = responseService["servicemessage"] as? String
                {
                    self.historiaOBJ.Descripcion += "\(nameService): \(servicemessage)"
                    if FormularioUtilities.shared.services?.root[element]["response"]["showmessage"].value == "true"{
                        self.showNotifOrPopupAlert((FormularioUtilities.shared.services?.root[element]["response"]["messagetype"].value)!, servicemessage)
                        
                    }
                }
                return
            }catch{ stopLoading() }
        }
        self.historialEstadistico.append(self.historiaOBJ)
        return
    }

    public func saveFormat(feFormato: String){
        let newFormat = FEFormatoData(json: feFormato)
        _ = ConfigurationManager.shared.utilities.save(info: newFormat.JsonDatos, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(newFormat.FlujoID)/\(newFormat.PIID)/\(newFormat.Guid)_\(newFormat.ExpID)_\(newFormat.TipoDocID)-\(newFormat.FlujoID)-\(newFormat.PIID).json")
        let json = JSONSerializer.toJson(newFormat)
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(newFormat.FlujoID)/\(newFormat.PIID)/\(newFormat.Guid)_\(newFormat.ExpID)_\(newFormat.TipoDocID)-\(newFormat.FlujoID)-\(newFormat.PIID).bor")

        plaCot.TipoDocID = newFormat.TipoDocID
        plaCot.ExpID = newFormat.ExpID
        plaCot.FlujoID = newFormat.FlujoID

        self.openPlantillaCot(pla: plaCot, formato: newFormat)
    }
    
    
    public func servicioGenerico(_ element: String){
        
        var firmaFadBool = false
        var rowFirmaFad: Any?
        let dictService = self.obtainJson(id: (FormularioUtilities.shared.services?.root[element]["id"].value ?? "0"))
        //115.ser
        if dictService != nil {
            ConfigurationManager.shared.initialmethod = dictService?["name"] as? String ?? ""
            self.historiaOBJ.Categoria = "ServicioV1"
            let fechaHistoria = Date.getTicks()
            self.historiaOBJ.FechaHistoria = fechaHistoria
            let pin = dictService?["pin"] as! NSDictionary
            let arrayPin = pin["method"] as! NSArray
            
            var pinParameters = [[String:Any]]()
            var valueData = ""
            for mP in arrayPin{
                pinParameters.append(mP as! [String : Any])
            }
            
            for index in 1...pinParameters.count{
                
                let values = pinParameters[index - 1]["value"] as? String ?? ""
                let order = pinParameters[index - 1]["order"] as? Int ?? 0
                let name = pinParameters[index - 1]["name"] as? String ?? ""
                let nameDict = self.getSystemParameters(name)
                let options = pinParameters[index - 1]["options"] as? NSDictionary
                if options != nil{
                    for option in options!{
                        if option.key as? String ?? "" == "FacePlusPlus"{
                            pinParameters[index - 1]["value"] = "FacePlusPlus"
                        }
                    }
                }
                if values.isEmpty{
                    if ((FormularioUtilities.shared.services?.root[element]["pin"]["order_\(order)"]["name"].value?.contains("Es PDF (1 o 0)")) != nil){
                        if name.contains("Es PDF (1 o 0)"){
                            if FormularioUtilities.shared.services?.root[element]["pin"]["order_\(order)"]["value"].value == "0"{
                                pinParameters[index - 1]["value"] = "0"
                            }else{
                                pinParameters[index - 1]["value"] = "1"
                            }
                            
                        }
                    }

                        
                    
                    
                    if let _ = (FormularioUtilities.shared.services?.root[element]["pin"]["order_\(order)"]["idelem"].value){
                        
                        
                        let elemData = getElementANY((FormularioUtilities.shared.services?.root[element]["pin"]["order_\(order)"]["idelem"].value)!)
                        rowFirmaFad = elemData.kind
                        let row = elemData.kind
                        switch row{
                        case is TextoRow:
                            let base = row as? TextoRow
                            if base?.cell.atributos != nil{
                                valueData = base?.value ?? ""
                            }
                            if base?.cell.atributosPassword != nil{
                                valueData = base?.value ?? ""
                            }
                            break;
                        case is TextoAreaRow:
                            let base = row as? TextoAreaRow
                            valueData = base?.value ?? ""
                            break;
                        case is NumeroRow:
                            let base = row as? NumeroRow
                            valueData = base?.value ?? ""
                            break;
                        case is MonedaRow:
                            let base = row as? MonedaRow
                            let valueMoneda = base?.cell.elemento.validacion.valor ?? ""
                            valueData = valueMoneda.replacingOccurrences(of: "$", with: "")
                            break;
                        case is FechaRow:
                            let base = row as? FechaRow
                            if base?.cell.atributos != nil{
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyyMMdd"
                                let stringDate = dateFormatter.string(from: base!.value!)
                                valueData =  stringDate
                                
                            }
                            if base?.cell.atributosHora != nil{
                                valueData = base?.cell.elemento.validacion.valor ?? ""
                            }
                            break;
                        case is WizardRow: break;
                        case is BotonRow: break;
                        case is LogoRow: break;
                        case is LogicoRow:
                            let base = row as? LogicoRow
                            valueData = base?.cell.elemento.validacion.valor ?? ""
                            break;
                        case is EtiquetaRow: break;
                        case is RangoFechasRow:
                            let base = row as? RangoFechasRow
                            valueData = base?.cell.elemento.validacion.valor ?? ""
                            break;
                        case is SliderNewRow:
                            let base = row as? SliderNewRow
                            valueData = base?.cell.elemento.validacion.valor ?? ""
                            break;
                        case is ListaRow:
                            let base = row as? ListaRow
                            valueData = base?.cell.elemento.validacion.valormetadato ?? ""
                            if base?.cell.atributos?.tipolista != "combo"
                            {   if base?.cell.gralButton.selectedButtons().count == 0 {
                                    valueData = ""
                                }
                            }
                            break;
                        case is ComboDinamicoRow:
                         if plist.idportal.rawValue.dataI() >= 40 {
                            let base = row as? ComboDinamicoRow
                            valueData = base?.cell.elemento.validacion.valormetadato ?? ""
                         }
                            break;
                        case is ListaTemporalRow:
                            let base = row as? ListaTemporalRow
                            valueData = base?.cell.elemento.validacion.id ?? ""
                            break;
                        case is HeaderTabRow: break;
                        case is HeaderRow: break;
                        case is TablaRow:
                            // TODO: - Create a new way to get all info from Tabla
                            let base = row as? TablaRow
                            valueData = base?.cell.elemento.validacion.valormetadato ?? ""
                            break;
                        case is MarcadoDocumentoRow:
                         if plist.idportal.rawValue.dataI() >= 41 {
                            let base = row as? MarcadoDocumentoRow
                            valueData = base?.cell.elemento.validacion.valormetadato ?? ""
                            let list = base?.customController?.form.first as! SelectableSection<ListCheckRow<String>>
                            if (list.selectedRow()?.tag == "--Seleccione--") && base?.cell.gralButton.selectedButtons().count == 0 {
                                valueData = ""
                            }
                         }
                            break;
                        case is CodigoBarrasRow:
                            let base = row as? CodigoBarrasRow
                            valueData = base?.value ?? ""
                            break;
                        case is CodigoQRRow:
                         if plist.idportal.rawValue.dataI() >= 39 {
                            let base = row as? CodigoQRRow
                            valueData = base?.value ?? ""
                         }
                            break;
                        case is EscanerNFCRow: break;
                        case is CalculadoraRow: break;
                        case is AudioRow: break;
                        case is FirmaRow:
                            let base = row as? FirmaRow
                            let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(base?.cell.path ?? "")")
                            let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                            valueData = anexoBase64
                            break;
                        case is FirmaFadRow:
                            if plist.idportal.rawValue.dataI() >= 39{
                                firmaFadBool = true
                                let base = row as? FirmaFadRow
                                valueData = base?.cell.atributos.hashCrypt ?? ""
                                break;
                            }
                        case is MapaRow:
                            let base = row as? MapaRow
                            let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(base?.cell.path ?? "")")
                            let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                            valueData = anexoBase64
                            break;
                        case is DocumentoRow: break;
                        case is DocFormRow:
                            let base = row as? VideoRow
                            let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(base?.cell.path ?? "")")
                            let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                            valueData = anexoBase64
                            break;
                        case is ImagenRow:
                            let base = row as? ImagenRow
                            // Detect if file exist
                            let exist = FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(base?.cell.path ?? "0")")
                            if exist && base?.cell.path != ""{
                                let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(base?.cell.path ?? "")")
                                let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                                valueData = anexoBase64
                            }else{
                                if base?.cell.anexo != nil{
                                    //We're going to download the attachment
                                    let isDownloaded = self.sdkAPI?.DGSDKdownloadAttachmentSync(delegate: self, anexo: (base?.cell.anexo)!) ?? false
                                    if isDownloaded{
                                        base?.cell.setAnexo((base?.cell.anexo)!)
                                        let exist = FCFileManager.existsItem(atPath: "\(Cnstnt.Tree.anexos)/\(base?.cell.anexo?.FileName ?? "")")
                                        if exist && base?.cell.anexo?.FileName != ""{
                                            let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(base?.cell.anexo?.FileName ?? "")")
                                            let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                                            valueData = anexoBase64
                                        }
                                    }
                                }
                            }
                            break;
                        case is VideoRow:
                            let base = row as? VideoRow
                            let fileData = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(base?.cell.path ?? "")")
                            let anexoBase64 = fileData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) ?? ""
                            valueData = anexoBase64
                            break;
                        case is VeridasDocumentOcrRow:
                            _ = row as? VeridasDocumentOcrRow
                            break
                        case is JUMIODocumentOcrRow:
                            _ = row as? JUMIODocumentOcrRow
                            break
                        case is VeridiumRow:
                            break;
                        default: valueData = ""; break;
                        }
                        
                        if nameDict.keys.first!.description == name{
                            if !nameDict.first!.value.isEmpty{
                                pinParameters[index - 1]["value"] = nameDict.first!.value
                            }
                        }else{
                            pinParameters[index - 1]["value"] = "\(String(describing: valueData))"
                        }
                    }else{
                        if nameDict.keys.first!.description == name{
                            if !nameDict.first!.value.isEmpty{
                                pinParameters[index - 1]["value"] = nameDict.first!.value
                            }
                        }
                    }
                    
                }
            }
            
            var sysParameters = [[String:Any]]()
            let arraySys = pin["system"] as! NSArray
            for sP in arraySys{
                sysParameters.append(sP as! [String : Any])
            }
            if !sysParameters.isEmpty{
                
                for index in 1...sysParameters.count{
                    let name = sysParameters[index - 1]["name"] as! String
                    let nameDict = self.getSystemParameters(name)

                    if nameDict.keys.first!.description == name{
                        if !nameDict.first!.value.isEmpty{
                           sysParameters[index - 1]["value"] = nameDict.first!.value
                        }
                    }
                }
                
            }
            var poutParameters = [[String:Any]]()
            
            let pout = dictService?["pout"] as! NSArray
            for pM in pout{
                poutParameters.append(pM as! [String : Any])
            }
            var tmp_parameters = dictService?["pin"] as! [String:Any]
            var tmp_systemParameters = tmp_parameters["system"]

            tmp_systemParameters = sysParameters
            tmp_parameters["system"] = tmp_systemParameters
            tmp_parameters["method"] = pinParameters
                        
            dictService?["pin"] = tmp_parameters


            var jsonService = ""
            if let theJSONData = try? JSONSerialization.data(
                withJSONObject: dictService!,
                options: []) {
                let theJSONText = String(data: theJSONData,
                                         encoding: String.Encoding.utf8)
                jsonService = theJSONText!
            }
            
            let request = Requests()
            // REVISAR CON #ALEX xmlGenericRequesT Y soapGenericSync
            let _ = request.xmlGenericRequest(idService: (FormularioUtilities.shared.services?.root[element]["id"].value)!, mParams: pinParameters, sParams: sysParameters, poutParams: poutParameters, jsonService: jsonService)
            
            let response = sdkAPI?.soapGenericSync(delegate: self, idService: (FormularioUtilities.shared.services?.root[element]["id"].value)!, mParams: pinParameters, sParams: sysParameters, poutParams: poutParameters, jsonService: jsonService)
            
            if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                let responseService = self.decodeXML(aexmlD: response!, r: "")
                self.historiaOBJ.Descripcion = "\(dictService?["name"] as? String ?? ""): con respuesta: Consulta Exitosa"
                
                do {
                    let jsonDict = try JSONSerializer.toDictionary(responseService)
                    let dataService = jsonDict["data"] as! NSMutableDictionary
                    let pout = jsonDict["pout"] as! [[String:Any]]
                    
                    let elemData = getElementANY((FormularioUtilities.shared.services?.root[element]["pout"]["order_1"]["idelem"].value) ?? "")
                    self.folioEconsubanco = dataService["Folio"] as? String ?? ""
                    _ = self.resolveValor(elemData.id, "asignacion", "\(dataService["Folio"] ?? "")")
                    
                    if !poutParameters.isEmpty{
                        for index in 1...poutParameters.count{
                            let orderA = poutParameters[index - 1]["order"] as! Int
                            let elemData = getElementANY((FormularioUtilities.shared.services?.root[element]["pout"]["order_\(orderA)"]["idelem"].value) ?? "")
                            for i in 1...pout.count{
                                let orderB = pout[i - 1]["order"] as! Int
                                if orderA == orderB{
                                    let value =  pout[i - 1]["value"]
                                    _ = self.resolveValor(elemData.id, "asignacion", "\(value ?? "")")
                                }
                            }
                            
                        }
                    }
                    if let responseServ =  jsonDict["response"] as? NSMutableDictionary{
                        if responseServ["showmessage"] as? Bool ?? false {
                            if let message = responseServ["servicemessage"] as? String{
                                self.showNotifOrPopupAlert((FormularioUtilities.shared.services?.root[element]["response"]["messagetype"].value) ?? "", message )
                            }
                        }
                        
                        if let error = responseServ["error"] as? String{
                            self.historiaOBJ.Descripcion = "\(dictService?["name"] as? String ?? ""): con respuesta: Consulta no Exitosa \(error)"
                            self.showNotifOrPopupAlert("notiferror", error)
                        }
                        if responseServ["servicesuccess"] as? Bool ?? false {
                            if FormularioUtilities.shared.services?.root[element]["response"]["rulesuccess"].value != nil{
                                _ = self.obtainRules(rString: FormularioUtilities.shared.services?.root[element]["response"]["rulesuccess"].value, eString: nil, vString: nil, forced: true, override: true)
                            }
                        }else{
                            if FormularioUtilities.shared.services?.root[element]["response"]["ruleerror"].value != nil{
                                _ = self.obtainRules(rString: FormularioUtilities.shared.services?.root[element]["response"]["ruleerror"].value, eString: nil, vString: nil, forced: true, override: true)
                            }
                        }
                    }
                    
                    
                }catch{ }
            }
            

            if firmaFadBool{
                stopLoading()
                let rowFirma =  rowFirmaFad as! FirmaFadRow
                let poutString = response?["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:pout"]["a:JsonParameterGenerico"]["a:value"].string//response?["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:pin"]["a:method"]["a:JsonParameterGenerico"]["a:value"].string
                if !poutString!.isEmpty{
                    do{
                        let jsonDict = try JSONSerializer.toDictionary(poutString!)
                        rowFirma.cell.elemento.validacion.guidtimestamp = jsonDict["id"] as! String
                        rowFirma.cell.cert = true
                        rowFirma.cell.imageCert.isHidden = false
                        rowFirma.cell.imageCert.image = UIImage(named: "ic_cert", in: Cnstnt.Path.framework, compatibleWith: nil)
                        
                        if response!["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].value == "true"{
                            stopLoading()
                        }
                    }catch{ stopLoading() }
                }
                return
            }else{
                stopLoading()
                let message = response?["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicemessage"].value
                
                _ = response?["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:pout"].value
                let poutString = response?["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:pout"]["a:JsonParameterGenerico"]["a:value"].string
                if !poutString!.isEmpty{
                    self.folioEconsubanco = poutString!
                    if ((FormularioUtilities.shared.services?.root[element]["pout"]["order_1"]["idelem"].value) != nil){
                        _ = self.resolveValor((FormularioUtilities.shared.services?.root[element]["pout"]["order_1"]["idelem"].value)!, "asignacion", poutString!)
                    }
                }
                
                if response!["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:pout"].children.count == 0{ stopLoading();return }
                
                if !poutParameters.isEmpty{
                    for index in 1...poutParameters.count{
                        let order = poutParameters[index - 1]["order"] as! Int
                        
                        if let pout = FormularioUtilities.shared.services?.root[element]["pout"]["order_\(order)"]["idelem"].value{
                            let poutValue = response!["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:pout"].children[index - 1]["a:value"].value
                            
                            if poutValue != nil{
                                _ = self.resolveValor(pout, "asignacion", poutValue!)
                            }
                            
                        }
                        
                    }
                }
                
                // Messages from service
                if FormularioUtilities.shared.services?.root[element]["response"]["showmessage"].value == "true"{
                    if message != nil, message != ""{
                        self.showNotifOrPopupAlert((FormularioUtilities.shared.services?.root[element]["response"]["messagetype"].value)!, message ?? "")
                    }
                }
                if response!["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:error"].value != nil{
                    self.showNotifOrPopupAlert("notiferror",  (response!["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:error"].value)!)
                }
                
                if response!["s:Envelope"]["s:Body"]["ServicioGenericoResponse"]["ServicioGenericoResult"]["a:response"]["a:servicesuccess"].value == "true"{
                    // RULE SUCCESS
                    if FormularioUtilities.shared.services?.root[element]["response"]["rulesuccess"].value != nil{
                        _ = self.obtainRules(rString: FormularioUtilities.shared.services?.root[element]["response"]["rulesuccess"].value, eString: nil, vString: nil, forced: true, override: true)
                    }
                }else{
                    // RULE ERROR
                    if FormularioUtilities.shared.services?.root[element]["response"]["ruleerror"].value != nil{
                        _ = self.obtainRules(rString: FormularioUtilities.shared.services?.root[element]["response"]["ruleerror"].value, eString: nil, vString: nil, forced: true, override: true)
                    }
                }
                self.historialEstadistico.append(self.historiaOBJ)
                return
            }
            
            
        }else{
            if (FormularioUtilities.shared.services?.root[element]["initialmethod"].value ?? "") != "" {
                self.servicioGenericoJSON(element)
            } else {
                stopLoading()
            }
        }
        
        
    }
    
    enum EncriptError: Error {
        case invalidData
        case InvalidParameters
        case InvalidXml
    }
    
    func decodeReturnSoap(_ getEncodeData: String) throws -> String {
        guard let decodedData = Data(base64Encoded: getEncodeData) else {  throw EncriptError.invalidData }
        let decryptSoap = decodedData.aesEncrypt(keyData: ConfigurationManager.shared.keyaes.data(using: .utf8, allowLossyConversion: false)!, ivData: ConfigurationManager.shared.ivaes.data(using: .utf8, allowLossyConversion: false)!, operation: kCCDecrypt)
        
        if decryptSoap.isEmpty {
            throw EncriptError.invalidData
        }
        
        guard let encodingSoap = String(bytes: decryptSoap, encoding: .utf8)  else {  throw EncriptError.invalidData }
        return encodingSoap
    }
    
    
    /// Method to execute with pdf (download || preview)
    /// - Parameter element: name service
    /// - Parameter action: action type  with pdf
    public func servicioPDF(_ element: String, _ action: String, _ fileName: String){
        let formato = FEFormatoData()
        formato.DocID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
        formato.ExpID = FormularioUtilities.shared.currentFormato.ExpID
        formato.GuidPdf = element
        formato.TipoDocID = FormularioUtilities.shared.currentFormato.TipoDocID
        var json = getJSonDatosValues()
        json = json.replacingOccurrences(of: "\\\"", with: "\\\\\"")
        json = json.replacingOccurrences(of: "\"", with: "\\\"")
        formato.JsonDatos = json
        
        let semaphore = DispatchSemaphore (value: 0)
        let request = Requests()
        let mutableRequest: URLRequest
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            _ = self.sdkAPI!.DGSDKRestoreTokenSecurityV2(delegate: self)
        }
        do{
            mutableRequest = try request.pdfRequest(formato: formato)
            let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                guard data != nil && error == nil else { return; }
                
                let doc = try! AEXMLDocument(xml: data!)
                do{
                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                        let encodigSoapTest = try
                            self.decodeReturnSoap(doc["s:Envelope"]["s:Body"]["response"].string)
                        let jsonDict = try JSONSerializer.toDictionary(encodigSoapTest)
                        if let returnobj = jsonDict["ReturnedObject"] as? String  {
                            let bodyData = Data(base64Encoded: returnobj)!
                            let decompressedData: Data
                            if bodyData.isGzipped {
                                decompressedData = try! bodyData.gunzipped()
                            } else {
                                decompressedData = bodyData
                            }
                            self.stopLoading()
                            let decodedString = String(data: decompressedData, encoding: .utf8)!
                            let response = AjaxResponseSimple(json: decodedString)
                            if response.Success{
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)\r\n", .info)
                                guard let data = Data(base64Encoded: response.ReturnedObject ?? "", options: .ignoreUnknownCharacters)else {
                                    semaphore.signal()
                                    return
                                }
                                //_ = ConfigurationManager.shared.utilities.save(object: data, path: "\(Cnstnt.Tree.main)/\(formato.GuidPdf).pdf")
                                switch action {
                                case "downloadpdf", "downloaddocx", "downloadxlsx":
                                    
                                    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray).firstObject as? String ?? ""
                                    
                                    if paths != ""
                                    {   var completeUrl = URL(fileURLWithPath: paths)
                                        
                                        switch action {
                                        case "downloadpdf":
                                            FCFileManager.createFile(atPath: "\(Cnstnt.Tree.main)/\(fileName.stringBefore(".")).pdf", withContent: data as NSObject, overwrite: true);
                                            DispatchQueue.main.async {
                                                let file = FCFileManager.urlForItem(atPath: "\(Cnstnt.Tree.main)/\(fileName.stringBefore(".")).pdf")
                                                if file == nil{ return }
                                                let activityViewController = UIActivityViewController(activityItems: [file!], applicationActivities: nil)
                                                self.present(activityViewController, animated: true, completion: nil)
                                                activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                                    if completed {
                                                        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.main)/\(fileName.stringBefore(".")).pdf")
                                                    }
                                                }
                                            }

                                            completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/\(formato.GuidPdf).pdf")
                                        case "downloaddocx":
                                            FCFileManager.createFile(atPath: "\(Cnstnt.Tree.main)/\(fileName)", withContent: data as NSObject, overwrite: true);
                                            DispatchQueue.main.async {
                                                let file = FCFileManager.urlForItem(atPath: "\(Cnstnt.Tree.main)/\(fileName)")
                                                if file == nil{ return }
                                                let activityViewController = UIActivityViewController(activityItems: [file!], applicationActivities: nil)
                                                self.present(activityViewController, animated: true, completion: nil)
                                                activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                                    if completed {
                                                        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.main)/\(fileName)")
                                                    }
                                                }
                                            }

                                            completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/\(formato.GuidPdf).pages")
                                        case "downloadxlsx":
                                            FCFileManager.createFile(atPath: "\(Cnstnt.Tree.main)/\(fileName)", withContent: data as NSObject, overwrite: true);
                                            DispatchQueue.main.async {
                                                let file = FCFileManager.urlForItem(atPath: "\(Cnstnt.Tree.main)/\(fileName)")
                                                if file == nil{ return }
                                                let activityViewController = UIActivityViewController(activityItems: [file!], applicationActivities: nil)
                                                self.present(activityViewController, animated: true, completion: nil)
                                                activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                                    if completed {
                                                        FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.main)/\(fileName)")
                                                    }
                                                }
                                            }

                                            completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/\(formato.GuidPdf).numbers")
                                        default: break;
                                        }
                                        
                                    }
                                    break;
                                case "preview":
                                    DispatchQueue.main.async {
                                        WebPDFViewController.show(in: self, pdfString: response.ReturnedObject)
                                    }
                                    break;
                                default: break;
                                }
                                
                                semaphore.signal()
                            }else{
                                self.stopLoading()
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)\r\n", .error)
                                DispatchQueue.main.async {
                                    self.showNotifOrPopupAlert("notiferror", "alrt_file_download".langlocalized())  }
                                semaphore.signal()
                            }
                        }
                    }else{
                        let getPdfResult = doc["s:Envelope"]["s:Body"]["DescargaPDFResponse"]["DescargaPDFResult"].string
                        let bodyData = Data(base64Encoded: getPdfResult)!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        self.stopLoading()
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponseSimple(json: decodedString)
                        if response.Success{
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)\r\n", .info)
                            guard let data = Data(base64Encoded: response.ReturnedObject ?? "", options: .ignoreUnknownCharacters)else {
                                semaphore.signal()
                                return
                            }
                            //_ = ConfigurationManager.shared.utilities.save(object: data, path: "\(Cnstnt.Tree.main)/\(formato.GuidPdf).pdf")
                            switch action {
                            case "downloadpdf", "downloaddocx", "downloadxlsx":
                                
                                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray).firstObject as? String ?? ""
                                
                                if paths != ""
                                {   var completeUrl = URL(fileURLWithPath: paths)
                                    
                                    switch action {
                                    case "downloadpdf":
                                        FCFileManager.createFile(atPath: "\(Cnstnt.Tree.main)/\(fileName.stringBefore(".")).pdf", withContent: data as NSObject, overwrite: true);
                                        DispatchQueue.main.async {
                                            let file = FCFileManager.urlForItem(atPath: "\(Cnstnt.Tree.main)/\(fileName.stringBefore(".")).pdf")
                                            if file == nil{ return }
                                            let activityViewController = UIActivityViewController(activityItems: [file!], applicationActivities: nil)
                                            self.present(activityViewController, animated: true, completion: nil)
                                            activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                                if completed {
                                                    FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.main)/\(fileName.stringBefore(".")).pdf")
                                                }
                                            }
                                        }

                                        completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/\(formato.GuidPdf).pdf")
                                    case "downloaddocx":
                                        FCFileManager.createFile(atPath: "\(Cnstnt.Tree.main)/\(fileName)", withContent: data as NSObject, overwrite: true);
                                        DispatchQueue.main.async {
                                            let file = FCFileManager.urlForItem(atPath: "\(Cnstnt.Tree.main)/\(fileName)")
                                            if file == nil{ return }
                                            let activityViewController = UIActivityViewController(activityItems: [file!], applicationActivities: nil)
                                            self.present(activityViewController, animated: true, completion: nil)
                                            activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                                if completed {
                                                    FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.main)/\(fileName)")
                                                }
                                            }
                                        }

                                        completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/\(formato.GuidPdf).pages")
                                    case "downloadxlsx":
                                        FCFileManager.createFile(atPath: "\(Cnstnt.Tree.main)/\(fileName)", withContent: data as NSObject, overwrite: true);
                                        DispatchQueue.main.async {
                                            let file = FCFileManager.urlForItem(atPath: "\(Cnstnt.Tree.main)/\(fileName)")
                                            if file == nil{ return }
                                            let activityViewController = UIActivityViewController(activityItems: [file!], applicationActivities: nil)
                                            self.present(activityViewController, animated: true, completion: nil)
                                            activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                                if completed {
                                                    FCFileManager.removeItem(atPath: "\(Cnstnt.Tree.main)/\(fileName)")
                                                }
                                            }
                                        }

                                        completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/\(formato.GuidPdf).numbers")
                                    default: break;
                                    }
                                    
                                }
                                break;
                            case "preview":
                                DispatchQueue.main.async {
                                    WebPDFViewController.show(in: self, pdfString: response.ReturnedObject)
                                }
                                break;
                            default: break;
                            }
                            
                            semaphore.signal()
                        }else{
                            self.stopLoading()
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)\r\n", .error)
                            DispatchQueue.main.async {
                                self.showNotifOrPopupAlert("notiferror", "alrt_file_download".langlocalized())  }
                            semaphore.signal()
                        }
                    }
                }catch{ self.stopLoading() }
            })
            task.resume()
            semaphore.wait()
        }catch{ }
    }
    
    
    
    /// Method to execute with pdf hijo (download)
    /// - Parameter element: name service
    public func servicioPDFpublicado(_ element: String){
        let formato = FEFormatoData()
        formato.Guid = FormularioUtilities.shared.currentFormato.Guid
        formato.GuidPdf = element
        formato.DocID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
        formato.EstadoApp = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
        formato.Resumen = ConfigurationManager.shared.usuarioUIAppDelegate.Password
        formato.Usuario = ConfigurationManager.shared.usuarioUIAppDelegate.User
        formato.NombreEstado = ConfigurationManager.shared.utilities.getIPAddress()
        
        let semaphore = DispatchSemaphore (value: 0)
        let request = Requests()
        let mutableRequest: URLRequest
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            _ = self.sdkAPI!.DGSDKRestoreTokenSecurityV2(delegate: self)
        }
        do{
            mutableRequest = try request.downloadDOCRequest(formato: formato)
            let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: {(data, response, error) in
                guard data != nil && error == nil else { return; }
                
                let doc = try! AEXMLDocument(xml: data!)
                
                do{
                    if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
                        let encodigSoapTest = try
                            self.decodeReturnSoap(doc["s:Envelope"]["s:Body"]["response"].string)
                        let jsonDict = try JSONSerializer.toDictionary(encodigSoapTest)
                        if let returnobj = jsonDict["ReturnedObject"] as? String  {
                            let bodyData = Data(base64Encoded: returnobj)!
                            let decompressedData: Data
                            if bodyData.isGzipped {
                                decompressedData = try! bodyData.gunzipped()
                            } else {
                                decompressedData = bodyData
                            }
                            self.stopLoading()
                            let decodedString = String(data: decompressedData, encoding: .utf8)!
                            let response = AjaxResponseSimple(json: decodedString)
                            if response.Success{
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)\r\n", .info)
                                guard let data = Data(base64Encoded: response.ReturnedObject ?? "", options: .ignoreUnknownCharacters)else {
                                    semaphore.signal()
                                    return
                                }
                                if let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray).firstObject as? String ?? nil
                                {   var completeUrl = URL(fileURLWithPath: paths)
                                    completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/\(formato.GuidPdf)")
                                    completeUrl.appendPathExtension("pdf")
                                    do {
                                        try data.write(to: completeUrl, options: .atomic)
                                        if FileManager.default.fileExists(atPath: completeUrl.path), let pdf = FileManager.default.contents(atPath: completeUrl.path)
                                        {   DispatchQueue.main.async {
                                                let activityViewController = UIActivityViewController(activityItems: [pdf], applicationActivities: nil)
                                                self.present(activityViewController, animated: true, completion: {
                                                    do {   try FileManager.default.removeItem(at: completeUrl)
                                                    }catch { }
                                                })
                                            }
                                        }
                                    } catch {
                                        DispatchQueue.main.async {
                                            self.showNotifOrPopupAlert("notiferror", "Incorrect download") }
                                    }
                                }
                                semaphore.signal()
                            }else{
                                ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)\r\n", .error)
                                DispatchQueue.main.async {
                                    self.showNotifOrPopupAlert("notiferror", "alrt_file_download".langlocalized())  }
                                semaphore.signal()
                            }
                        }
                    }else{
                        let getPdfResult = doc["s:Envelope"]["s:Body"]["ConsultaArchivoPublicadoResponse"]["ConsultaArchivoPublicadoResult"].string
                        let bodyData = Data(base64Encoded: getPdfResult)!
                        let decompressedData: Data
                        if bodyData.isGzipped {
                            decompressedData = try! bodyData.gunzipped()
                        } else {
                            decompressedData = bodyData
                        }
                        self.stopLoading()
                        let decodedString = String(data: decompressedData, encoding: .utf8)!
                        let response = AjaxResponseSimple(json: decodedString)
                        if response.Success{
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)\r\n", .info)
                            guard let data = Data(base64Encoded: response.ReturnedObject ?? "", options: .ignoreUnknownCharacters)else {
                                semaphore.signal()
                                return
                            }
                            if let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray).firstObject as? String ?? nil
                            {   var completeUrl = URL(fileURLWithPath: paths)
                                completeUrl.appendPathComponent("\(Cnstnt.Tree.main)/\(formato.GuidPdf)")
                                completeUrl.appendPathExtension("pdf")
                                do {
                                    try data.write(to: completeUrl, options: .atomic)
                                    if FileManager.default.fileExists(atPath: completeUrl.path), let pdf = FileManager.default.contents(atPath: completeUrl.path)
                                    {   DispatchQueue.main.async {
                                            let activityViewController = UIActivityViewController(activityItems: [pdf], applicationActivities: nil)
                                            self.present(activityViewController, animated: true, completion: {
                                                do {   try FileManager.default.removeItem(at: completeUrl)
                                                }catch { }
                                            })
                                        }
                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        self.showNotifOrPopupAlert("notiferror", "Incorrect download") }
                                }
                            }
                            semaphore.signal()
                        }else{
                            ConfigurationManager.shared.utilities.writeLogger("\(response.Mensaje)\r\n", .error)
                            DispatchQueue.main.async {
                                self.showNotifOrPopupAlert("notiferror", "alrt_file_download".langlocalized())  }
                            semaphore.signal()
                        }
                    }
                }catch{ }
            })
            task.resume()
            semaphore.wait()
        }catch{ }
    }
}

extension String {
    func stringBefore(_ delimiter: Character) -> String {
        if let index = firstIndex(of: delimiter) {
            return String(prefix(upTo: index))
        } else {
            return ""
        }
    }
    
    func stringAfter(_ delimiter: Character) -> String {
        if let index = firstIndex(of: delimiter) {
            return String(suffix(from: index).dropFirst())
        } else {
            return ""
        }
    }
}


