//
//  Requests.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 17/09/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

public class Requests: NSObject{
    
    // Global Variables
    let xmlnstag = [ "xmlns:soapenv" : "\(Obfuscator().reveal(key: ObfuscatedCnstnt.spen))", "xmlns:tem" : "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmp))" ]
    let xmlnstaggeneric = [ "xmlns:bus" : "\(Obfuscator().reveal(key: ObfuscatedCnstnt.cntr))", "xmlns:soapenv" : "\(Obfuscator().reveal(key: ObfuscatedCnstnt.spen))", "xmlns:tem" : "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmp))" ]
    let xmltagjsongeneric = [ "xmlns:soapenv":"\(Obfuscator().reveal(key: ObfuscatedCnstnt.spen))" , "xmlns:tem":"\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmp))"]
    // Global Enum
    enum TypeRequest {
        case codigo
        case skin
        case usuario
        case imgprofile
        case usrprofile
        case registro
        case registroNew
        case activarRegistro
        case activarRegistroNewVersion
        case cambiarContrasenia
        case cambiarContraseniaNewVersion
        case resetContraseniaNewVersion
        case plantillas
        case variables
        case formatos
        case deleteFormatos
        case sendFormatos
        case sendAnexos
        case consultaAnexos
        case transitar
        case consultas
        case pdf
        case pdfPublicado
        case regeneraToken
        // Old Services
        case compareFaces
        case folio
        case sms
        case smsNewVersion
        case validateSms
        case validateSmsNewVersion
        case correo
        case sepomex
        // New Services
        case generic
        case genericJson
        // Logalty
        case requestLogalty
        case saml
        case responseLogalty
        case catalogoRemoto
    }
    
    // Global Functions
    func getURLRequest(_ lenght: String, _ nsurl: URL, _ type: TypeRequest) -> URLRequest{
        
        var mutableR = URLRequest(url: nsurl)
        mutableR.timeoutInterval = ConfigurationManager.shared.timeInterval
        mutableR.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        mutableR.addValue( "text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type" )
        
        switch type {
        case .codigo: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprco))", forHTTPHeaderField: "SOAPAction" ); break;
        case .skin: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprsk))", forHTTPHeaderField: "SOAPAction" ); break;
        case .usuario: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprlg))", forHTTPHeaderField: "SOAPAction" ); break;
        case .imgprofile: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprsnd))", forHTTPHeaderField: "SOAPAction" ); break;
        case .usrprofile: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmpusri))", forHTTPHeaderField: "SOAPAction" ); break;
        case .registro: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprrg))", forHTTPHeaderField: "SOAPAction" ); break;
        case .registroNew: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprrgo))", forHTTPHeaderField: "SOAPAction" ); break;
        case .activarRegistro: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprarg))", forHTTPHeaderField: "SOAPAction" ); break;
        case .activarRegistroNewVersion: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprarco))", forHTTPHeaderField: "SOAPAction" ); break;
        case .cambiarContrasenia: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprcpss))", forHTTPHeaderField: "SOAPAction" ); break;
        case .cambiarContraseniaNewVersion: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprcpsso))", forHTTPHeaderField: "SOAPAction" ); break;
        case .resetContraseniaNewVersion: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprrstpss))", forHTTPHeaderField: "SOAPAction" ); break;
        case .sepomex: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprcdpl))", forHTTPHeaderField: "SOAPAction" ); break;
        case .plantillas: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprobpl))", forHTTPHeaderField: "SOAPAction" ); break;
        case .variables: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprobvr))", forHTTPHeaderField: "SOAPAction" ); break;
        case .formatos: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprcnfr))", forHTTPHeaderField: "SOAPAction" ); break;
        case .deleteFormatos: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprbfor))", forHTTPHeaderField: "SOAPAction" ); break;
        case .sendFormatos: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprenf))", forHTTPHeaderField: "SOAPAction" ); break;
        case .sendAnexos: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprena))", forHTTPHeaderField: "SOAPAction" ); break;
        case .consultaAnexos: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprcnan))", forHTTPHeaderField: "SOAPAction" ); break;
        case .transitar: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprtrf))", forHTTPHeaderField: "SOAPAction" ); break;
        case .consultas: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprcnt))", forHTTPHeaderField: "SOAPAction" ); break;
        case .pdf: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprpdf))", forHTTPHeaderField: "SOAPAction" ); break;
        case .pdfPublicado: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprpdfpublicado))", forHTTPHeaderField: "SOAPAction" ); break;
        case .compareFaces: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprcmfa))", forHTTPHeaderField: "SOAPAction" ); break;
        case .folio: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprfol))", forHTTPHeaderField: "SOAPAction" ); break;
        case .sms: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprsms))", forHTTPHeaderField: "SOAPAction" ); break;
        case .smsNewVersion: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprpnsms))", forHTTPHeaderField: "SOAPAction" ); break;
        case .validateSms: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprvlsms))", forHTTPHeaderField: "SOAPAction" ); break;
        case .validateSmsNewVersion: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprvlsms))", forHTTPHeaderField: "SOAPAction" ); break;
        case .correo: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprsndml))", forHTTPHeaderField: "SOAPAction" ); break;
        case .generic: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprsrgn))", forHTTPHeaderField: "SOAPAction" ); break;
        case .genericJson: mutableR.addValue("\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprsrgns))", forHTTPHeaderField: "SOAPAction"); break;
        case .requestLogalty: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprgnlg))", forHTTPHeaderField: "SOAPAction" ); break;
        case .saml: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprgnsl))", forHTTPHeaderField: "SOAPAction" ); break;
        case .responseLogalty: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprtmply))", forHTTPHeaderField: "SOAPAction" ); break;
        case .catalogoRemoto: mutableR.addValue( "\(Obfuscator().reveal(key: ObfuscatedCnstnt.tmprccrm))", forHTTPHeaderField: "SOAPAction" ); break;
        case .regeneraToken:
            mutableR.addValue( "http://tempuri.org/IApp/RegeneraToken", forHTTPHeaderField: "SOAPAction" ); break;
        }
        if ConfigurationManager.shared.webSecurity || plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco{
            mutableR.addValue("Bearer \(ConfigurationManager.shared.usuarioUIAppDelegate.Token.Token)", forHTTPHeaderField: "Authorization")
        }
        mutableR.addValue( lenght, forHTTPHeaderField: "Content-Length" )
        mutableR.httpMethod = httpMethod.POST.rawValue
        
        return mutableR
    }
    
    // MARK: - GENERIC REST REQUEST
    public func genericJsonRequest(url: String = "\(Obfuscator().reveal(key: ObfuscatedCnstnt.cdl))", httpMethod: String = "POST", parameters: String = "") -> URLRequest{
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        request.httpBody = postData
        return request
    }
    
    //MARK: - GENERIC REQUEST
    
    public func xmlGenericJSONRequest(jsonService jsonservice: NSString) -> AEXMLDocument{
        
        let soapRequest = AEXMLDocument()
        var hashObj = ""
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmltagjsongeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenericoString" )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:json>\(jsonservice as String)</tem:json>"
            hashObj = generateHashToken(soap: soapString)
            service.addChild( name: "request" ).value = hashObj
        }else{
        service.addChild( name: "tem:json" ).value = jsonservice as String
        }
        service.addChild( name: "tem:proyid", value: "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)" )
    
        return soapRequest
    }
    
    public func xmlGenericRequest(idService idservice: String?, mParams mparams: [[String: Any]]?, sParams sparams:[[String: Any]]?, poutParams poutparams:[[String: Any]]?, jsonService: String) -> AEXMLDocument{
        
        let soapRequest = AEXMLDocument()
        
        var hashObj = ""
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmltagjsongeneric )
            let body = envelope.addChild( name: "soapenv:Body" )
            let service = body.addChild( name: "tem:ServicioGenericoString" )
            let soapString = "<tem:json>\(jsonService)</tem:json><tem:proyid>\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)</tem:proyid>"
            
            hashObj = generateHashToken(soap: soapString)
            service.addChild( name: "request" ).value = hashObj
            service.addChild( name: "tem:proyid", value: "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)" )
            
            return soapRequest
        }else{
            let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
            let body = envelope.addChild( name: "soapenv:Body" )
            let service = body.addChild( name: "tem:ServicioGenerico" )
            let json = service.addChild( name: "tem:json" )
            json.addChild( name: "bus:id", value: "\(idservice ?? "")" )
            let pin = json.addChild( name: "bus:pin" )
            let method = pin.addChild( name: "bus:method" )
            
            var methodCounter = 0
            
            if mparams != nil{
                for mP in mparams!{
                    
                    if mP["order"] != nil{
                        let order = mP["order"] as? Int ?? 0
                        var value = mP["value"] as? String ?? ""
                        let dataType = mP["datatype"] as? String ?? ""
                        methodCounter += 1
                        let methodParameter = method.addChild( name: "bus:JsonParameterGenerico" )
                        methodParameter.addChild( name: "bus:datatype", value: "\(dataType)" )
                        methodParameter.addChild( name: "bus:order", value: "\(order)" )
                        if value == "http://cftest.credifiel.mx:17192/sms/sendETCAuthorization"{
                            methodParameter.addChild( name: "bus:value", value: "http://cftest.credifiel.mx:17192/sms/sendTCAuthorization")
                        }else{
                            if value.contains("https://api-originacionqa.ion.com.mx:4434/API_GET_Clientes_CALC_RFC") {
                                value = "https://api-originacionqa.ion.com.mx:4434/MotorApi/API_GET_Clientes_Generar_RFC"
                            }
                            //https://api-originacionqa.ion.com.mx:4434/MotorApi/API_GET_Clientes_Consulta_Completa_Buro
                            if value.contains("https://api-originacionqa.ion.com.mx:4434/API_GET_Clientes_ConsultaCompletaBC") {
                                value = "https://api-originacionqa.ion.com.mx:4434/MotorApi/API_GET_Clientes_Consuta_Score_Buro"
                            }
                            methodParameter.addChild( name: "bus:value", value: "\(value)")
                        }
                        
                    }
                    
                }
            }
            
            let system = pin.addChild( name: "bus:system" )
            
            if sparams != nil{
                for sP in sparams!{
                    if sP["order"] != nil{
                        let order = sP["order"] as? Int ?? 0
                        let value = sP["value"] as? String ?? ""
                        let dataType = sP["datatype"] as? String ?? ""
                        
                        let systemJson1 = system.addChild( name: "bus:JsonParameterGenerico" )
                        systemJson1.addChild( name: "bus:datatype", value: "\(dataType)" )
                        systemJson1.addChild( name: "bus:order", value: "\(order)" )
                        systemJson1.addChild( name: "bus:value", value: "\(value)")
                    }
                }
            }
            
            let pout = json.addChild( name: "bus:pout" )
            
            if poutparams != nil{
                for pM in poutparams!{
                    
                    if pM["order"] != nil{
                        let order = pM["order"] as? Int ?? 0
                        let value = pM["value"] as? String ?? ""
                        let dataType = pM["datatype"] as? String ?? ""
                        let name = pM["name"] as? String ?? ""
                        
                        let poutJson = pout.addChild( name: "bus:JsonParameterGenerico" )
                        poutJson.addChild( name: "bus:datatype", value: "\(dataType)" )
                        poutJson.addChild( name: "bus:order", value: "\(order)" )
                        poutJson.addChild( name: "bus:value", value: "\(value)" )
                        poutJson.addChild( name: "bus:name", value: "\(name)" )
                    }
                    
                }
            }

            service.addChild( name: "tem:proyid", value: "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)" )
            json.addChild( name: "bus:response" )
            
            return soapRequest
        }
    }
    
    
    // Requests
    public func xmlCompareFacesRequest(mParams mparams: [String], poutParams poutparams:[String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "110" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        let methodRostro1 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodRostro1.addChild( name: "bus:datatype", value: "string" )
        methodRostro1.addChild( name: "bus:order", value: "1" )
        methodRostro1.addChild( name: "bus:value", value: mparams[0] )
        let methodRostro2 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodRostro2.addChild( name: "bus:datatype", value: "string" )
        methodRostro2.addChild( name: "bus:order", value: "2" )
        methodRostro2.addChild( name: "bus:value", value: mparams[1] )
        let methodRostro3 = method.addChild(name: "bus:JsonParameterGenerico")
        methodRostro3.addChild(name: "bus:datatype", value: "string")
        methodRostro3.addChild(name: "bus:order", value: "3")
        methodRostro3.addChild(name: "bus:value", value: "FacePlusPlus")
        let _ = pin.addChild( name: "bus:system" )
        let pout = json.addChild( name: "bus:pout" )
        let poutJson = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson.addChild( name: "bus:datatype", value: "string" )
        poutJson.addChild( name: "bus:order", value: "1" )
        poutJson.addChild( name: "bus:value", value: poutparams[0] )
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )
        return soapRequest
    }
    
    public func xmlFolioRequest(mParams mparams: [String], sParams sparams:[String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "1" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        let methodJson = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson.addChild( name: "bus:datatype", value: "string" )
        methodJson.addChild( name: "bus:order", value: "5" )
        methodJson.addChild( name: "bus:value", value: mparams[0] )
        let system = pin.addChild( name: "bus:system" )
        let systemJson1 = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson1.addChild( name: "bus:datatype", value: "int" )
        systemJson1.addChild( name: "bus:order", value: "1" )
        systemJson1.addChild( name: "bus:value", value: sparams[0] ) // ProyectID
        let systemJson2 = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson2.addChild( name: "bus:datatype", value: "int" )
        systemJson2.addChild( name: "bus:order", value: "2" )
        systemJson2.addChild( name: "bus:value", value: sparams[1] ) // ExpID
        let systemJson3 = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson3.addChild( name: "bus:datatype", value: "int" )
        systemJson3.addChild( name: "bus:order", value: "3" )
        systemJson3.addChild( name: "bus:value", value: sparams[2] ) // Grupo ID USer
        let systemJson4 = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson4.addChild( name: "bus:datatype", value: "string" )
        systemJson4.addChild( name: "bus:order", value: "4" )
        systemJson4.addChild( name: "bus:value", value: sparams[3] ) // Login User
        let pout = json.addChild( name: "bus:pout" )
        let poutJson = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson.addChild( name: "bus:datatype", value: "string" )
        poutJson.addChild( name: "bus:order", value: "1" )
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )
        return soapRequest
    }
    
    public func xmlRegistroRequest(mParams mparams: [String], sParams sparams:[String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "2" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        let methodJson1 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson1.addChild( name: "bus:datatype", value: "string" )
        methodJson1.addChild( name: "bus:order", value: "1" )
        methodJson1.addChild( name: "bus:value", value: mparams[0] ) // USUARIO
        let methodJson2 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson2.addChild( name: "bus:datatype", value: "string" )
        methodJson2.addChild( name: "bus:order", value: "2" )
        methodJson2.addChild( name: "bus:value", value: mparams[1] )  // PASSWORD
        let methodJson3 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson3.addChild( name: "bus:datatype", value: "string" )
        methodJson3.addChild( name: "bus:order", value: "3" )
        methodJson3.addChild( name: "bus:value", value: mparams[2] )  // NOMBRE
        let methodJson4 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson4.addChild( name: "bus:datatype", value: "string" )
        methodJson4.addChild( name: "bus:order", value: "4" )
        methodJson4.addChild( name: "bus:value", value: mparams[3] )  // APELLIDO PATERNO
        let methodJson5 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson5.addChild( name: "bus:datatype", value: "string" )
        methodJson5.addChild( name: "bus:order", value: "5" )
        methodJson5.addChild( name: "bus:value", value: mparams[4] )  // APELLIDO MATERNO
        let methodJson6 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson6.addChild( name: "bus:datatype", value: "string" )
        methodJson6.addChild( name: "bus:order", value: "6" )
        methodJson6.addChild( name: "bus:value", value: mparams[5] )  // CORREO ELECTRONICO
        let methodJson7 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson7.addChild( name: "bus:datatype", value: "string" )
        methodJson7.addChild( name: "bus:order", value: "7" )
        methodJson7.addChild( name: "bus:value", value: mparams[6] )  // GRUPO
        let methodJson8 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson8.addChild( name: "bus:datatype", value: "int" )
        methodJson8.addChild( name: "bus:order", value: "8" )
        methodJson8.addChild( name: "bus:value", value: mparams[7] )  // PERFILES
        let system = pin.addChild( name: "bus:system" )
        let systemJson1 = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson1.addChild( name: "bus:datatype", value: "int" )
        systemJson1.addChild( name: "bus:order", value: "9" )
        systemJson1.addChild( name: "bus:value", value: sparams[0] ) // ProyectID
        let pout = json.addChild( name: "bus:pout" )
        let poutJson = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson.addChild( name: "bus:datatype", value: "int" )
        poutJson.addChild( name: "bus:order", value: "1" )
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )
        return soapRequest
    }
    
    public func xmlEnvioSMSRequest(mParams mparams: [String], sParams sparams:[String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "3" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        let methodJson1 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson1.addChild( name: "bus:datatype", value: "string" )
        methodJson1.addChild( name: "bus:order", value: "3" )
        methodJson1.addChild( name: "bus:value", value: mparams[0] )
        let methodJson2 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson2.addChild( name: "bus:datatype", value: "int" )
        methodJson2.addChild( name: "bus:order", value: "4" )
        methodJson2.addChild( name: "bus:value", value: mparams[1] )
        let system = pin.addChild( name: "bus:system" )
        let systemJson1 = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson1.addChild( name: "bus:datatype", value: "int" )
        systemJson1.addChild( name: "bus:order", value: "1" )
        systemJson1.addChild( name: "bus:value", value: sparams[0] ) // ProyectID
        let systemJson2 = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson2.addChild( name: "bus:datatype", value: "string" )
        systemJson2.addChild( name: "bus:order", value: "2" )
        systemJson2.addChild( name: "bus:value", value: sparams[1] ) // USER
        let pout = json.addChild( name: "bus:pout" )
        let poutJson = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson.addChild( name: "bus:datatype", value: "string" )
        poutJson.addChild( name: "bus:order", value: "1" )
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )
        return soapRequest
    }
    
    public func xmlValidarSMSRequest(mParams mparams: [String], sParams sparams:[String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "4" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        let methodJson1 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson1.addChild( name: "bus:datatype", value: "string" )
        methodJson1.addChild( name: "bus:order", value: "3" )
        methodJson1.addChild( name: "bus:value", value: mparams[0] )
        let methodJson2 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson2.addChild( name: "bus:datatype", value: "string" )
        methodJson2.addChild( name: "bus:order", value: "4" )
        methodJson2.addChild( name: "bus:value", value: mparams[1] )
        let system = pin.addChild( name: "bus:system" )
        let systemJson1 = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson1.addChild( name: "bus:datatype", value: "int" )
        systemJson1.addChild( name: "bus:order", value: "1" )
        systemJson1.addChild( name: "bus:value", value: sparams[0] ) // ProyectID
        let systemJson2 = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson2.addChild( name: "bus:datatype", value: "string" )
        systemJson2.addChild( name: "bus:order", value: "2" )
        systemJson2.addChild( name: "bus:value", value: sparams[1] ) // USER
        json.addChild( name: "bus:pout" )
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )
        return soapRequest
    }
    
    public func xmlSepomexRequest(mParams mparams: [String], sParams sparams:[String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "5" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        let methodJson = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson.addChild( name: "bus:datatype", value: "string" )
        methodJson.addChild( name: "bus:order", value: "1" )
        methodJson.addChild( name: "bus:value", value: mparams[0] )
        pin.addChild( name: "bus:system" )
        let pout = json.addChild( name: "bus:pout" )
        let poutJson = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson.addChild( name: "bus:datatype", value: "string" )
        poutJson.addChild( name: "bus:order", value: "1" )
        poutJson.addChild( name: "bus:value", value: sparams[0])
        let poutJson2 = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson2.addChild( name: "bus:datatype", value: "string" )
        poutJson2.addChild( name: "bus:order", value: "2" )
        poutJson2.addChild( name: "bus:value", value: sparams[1])
        let poutJson3 = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson3.addChild( name: "bus:datatype", value: "string" )
        poutJson3.addChild( name: "bus:order", value: "3" )
        poutJson3.addChild( name: "bus:value", value: sparams[2])
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )
        return soapRequest
    }
    
    public func xmlActivacionCorreoRequest(mParams mparams: [String], sParams sparams:[String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "6" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        let methodJson1 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson1.addChild( name: "bus:datatype", value: "string" )
        methodJson1.addChild( name: "bus:order", value: "1" )
        methodJson1.addChild( name: "bus:value", value: mparams[0] )
        let methodJson2 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson2.addChild( name: "bus:datatype", value: "string" )
        methodJson2.addChild( name: "bus:order", value: "2" )
        methodJson2.addChild( name: "bus:value", value: mparams[1] )
        let system = pin.addChild( name: "bus:system" )
        let systemJson = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson.addChild( name: "bus:datatype", value: "int" )
        systemJson.addChild( name: "bus:order", value: "3" )
        systemJson.addChild( name: "bus:value", value: sparams[0] ) // ProyectID
        let pout = json.addChild( name: "bus:pout" )
        let poutJson = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson.addChild( name: "bus:datatype", value: "string" )
        poutJson.addChild( name: "bus:order", value: "1" )
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )
        return soapRequest
    }
    
    public func xmlActivarUsuarioRequest(mParams mparams: [String], sParams sparams:[String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "7" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        let methodJson1 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson1.addChild( name: "bus:datatype", value: "string" )
        methodJson1.addChild( name: "bus:order", value: "2" )
        methodJson1.addChild( name: "bus:value", value: mparams[0])
        methodJson1.addChild( name: "bus:esquema", value: "")
        let system = pin.addChild( name: "bus:system" )
        let systemJson = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson.addChild( name: "bus:datatype", value: "int" )
        systemJson.addChild( name: "bus:order", value: "1" )
        systemJson.addChild( name: "bus:value", value: sparams[0] )
        json.addChild( name: "bus:pout" )
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )
        
        return soapRequest
    }

    public func xmlExisteUsuarioRequest(mParams mparams: [String], sParams sparams:[String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "8" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        let methodJson1 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson1.addChild( name: "bus:datatype", value: "string" )
        methodJson1.addChild( name: "bus:order", value: "2" )
        methodJson1.addChild( name: "bus:value", value: mparams[0] )
        let system = pin.addChild( name: "bus:system" )
        let systemJson = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson.addChild( name: "bus:datatype", value: "int" )
        systemJson.addChild( name: "bus:order", value: "1" )
        systemJson.addChild( name: "bus:value", value: sparams[0] ) // ProyectID
        let pout = json.addChild( name: "bus:pout" )
        let poutJson = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson.addChild( name: "bus:datatype", value: "bool" )
        poutJson.addChild( name: "bus:order", value: "1" )
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )
        
        return soapRequest
    }

    public func xmlSassSirhRequest(mParams mparams: [String], sParams sparams:[String], poutParams poutparams:[String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "9" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        
        let methodJson1 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson1.addChild( name: "bus:datatype", value: "string" )
        methodJson1.addChild( name: "bus:order", value: "2" )
        methodJson1.addChild( name: "bus:value", value: mparams[0] )
        
        let system = pin.addChild( name: "bus:system" )
        let systemJson = system.addChild( name: "bus:JsonParameterGenerico" )
        systemJson.addChild( name: "bus:datatype", value: "String" )
        systemJson.addChild( name: "bus:order", value: "1" )
        systemJson.addChild( name: "bus:value", value: sparams[0] )
        
        let pout = json.addChild( name: "bus:pout" )
        let poutJson = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson.addChild( name: "bus:datatype", value: "string" )
        poutJson.addChild( name: "bus:order", value: "1" )
        poutJson.addChild( name: "bus:value", value: poutparams[0])
        let poutJson2 = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson2.addChild( name: "bus:datatype", value: "string" )
        poutJson2.addChild( name: "bus:order", value: "2" )
        poutJson2.addChild( name: "bus:value", value: poutparams[1])
        let poutJson3 = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson3.addChild( name: "bus:datatype", value: "string" )
        poutJson3.addChild( name: "bus:order", value: "3" )
        poutJson3.addChild( name: "bus:value", value: poutparams[2])
        let poutJson4 = pout.addChild( name: "bus:JsonParameterGenerico" )
        poutJson4.addChild( name: "bus:datatype", value: "string" )
        poutJson4.addChild( name: "bus:order", value: "4" )
        poutJson4.addChild( name: "bus:value", value: poutparams[3])
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )
        
        return soapRequest
    }
    
    //MARK: - Servicios CREDIFIEL
    public func xmlVerificaCurpRfcCredifielRequest(mParams mparams: [String]) -> AEXMLDocument{
        let soapRequest = AEXMLDocument()
        
        let envelope = soapRequest.addChild( name: "soapenv:Envelope", attributes: xmlnstaggeneric )
        let body = envelope.addChild( name: "soapenv:Body" )
        let service = body.addChild( name: "tem:ServicioGenerico" )
        let json = service.addChild( name: "tem:json" )
        json.addChild( name: "bus:id", value: "12" )
        let pin = json.addChild( name: "bus:pin" )
        let method = pin.addChild( name: "bus:method" )
        
        
        let methodJson1 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson1.addChild( name: "bus:datatype", value: "string" )
        methodJson1.addChild( name: "bus:order", value: "1" )
        methodJson1.addChild( name: "bus:value", value: mparams[0] )
        let methodJson2 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson2.addChild( name: "bus:datatype", value: "string" )
        methodJson2.addChild( name: "bus:order", value: "2" )
        methodJson2.addChild( name: "bus:value", value: mparams[1] )
        let methodJson3 = method.addChild( name: "bus:JsonParameterGenerico" )
        methodJson3.addChild( name: "bus:datatype", value: "int" )
        methodJson3.addChild( name: "bus:order", value: "3" )
        methodJson3.addChild( name: "bus:value", value: mparams[2] )
        let methodJson4 = method.addChild(name: "bus:JsonParameterGenerico")
        methodJson4.addChild(name: "bus:datatype", value: "string")
        methodJson4.addChild(name: "bus:order", value: "4")
        methodJson4.addChild(name: "bus:value", value: "http://cftest.credifiel.mx:17192/bp/validateBusinessPartner")
        
        service.addChild( name: "tem:proyid", value: "2" )
        json.addChild( name: "bus:response" )


            return soapRequest
        }

    // MARK: FLOW REQUESTS
    public func codigoRequest() throws -> URLRequest {

        let soapRequest = AEXMLDocument()
        ConfigurationManager.shared.codigoUIAppDelegate.Codigo = ConfigurationManager.shared.codigoUIAppDelegate.Codigo.uppercased()
        let json = JSONSerializer.toJson(ConfigurationManager.shared.codigoUIAppDelegate)
        
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:CheckCodigo"
        )
        check.addChild(
            name: "tem:code",
            value: json
        )
        let soapLenth = String(soapRequest.xml.count)
        let theURL = URL(string: Obfuscator().reveal(key: ObfuscatedCnstnt.hac) )
        var mutableR = getURLRequest(soapLenth, theURL!, .codigo)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)

        return mutableR
    }
    
    public func skinRequest() throws -> URLRequest{
        
        let skinObject = FESkin()
        skinObject.AplicacionID = ConfigurationManager.shared.codigoUIAppDelegate.AplicacionID
        skinObject.ProyectoID = ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID
        let jsonObject = JSONSerializer.toJson(skinObject)
        
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""

        let soapRequest = AEXMLDocument()
        
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ObtieneSkin"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:skin>\(jsonZipB64)</tem:skin>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:skin",
                value: jsonZipB64
            )
        }


        
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .skin)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func usuarioRequest() throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(ConfigurationManager.shared.usuarioUIAppDelegate)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""

        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:Login"
        )

        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco{
            let uuid = UUID().uuidString
            let tokenString = sha512(string: uuid).toBase64()
            ConfigurationManager.shared.usuarioUIAppDelegate.Token.Token = tokenString
            let soapString = "<tem:usuario>\(jsonZipB64)</tem:usuario>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:usuario",
                value: jsonZipB64
            )
        }

        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .usuario)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)

        return mutableR
    }

    func sha512(string: String) -> [UInt8] {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        let data = string.data(using: String.Encoding.utf8 , allowLossyConversion: true)
        let value =  data! as NSData
        CC_SHA512(value.bytes, CC_LONG(value.length), &digest)

        return digest
    }
    
    /// Funcion para encriptar la petición soap
    /// - Parameter soap: soap description String de entrada con la peticion soap
    /// - Returns: description string encriptado con la petición en base64
    public func generateHashToken(soap: String) -> String{
        let token = ConfigurationManager.shared.usuarioUIAppDelegate.Token.Token
        let tokenSha512 = sha512(string: token)
        let tokenBase64 = tokenSha512.toBase64()
        let key = tokenBase64[21..<53]
        let iv = tokenBase64[7..<23]
        ConfigurationManager.shared.keyaes = key
        ConfigurationManager.shared.ivaes = iv

        let encrip = soap.data(using: .utf8, allowLossyConversion: true)?.aesEncrypt(keyData: key.data(using: .utf8, allowLossyConversion: false)!, ivData: iv.data(using: .utf8, allowLossyConversion: false)!, operation: kCCEncrypt)
        return encrip!.base64EncodedString()
    }
    
    // Request token VALMEX
  public func tokenRequest() throws -> URLRequest{
       
      let jsonObject = sha512(string: ConfigurationManager.shared.usuarioUIAppDelegate.User).toBase64()
    
      let soapRequest = AEXMLDocument()
      let soapString = "<tem:usr>\(jsonObject)</tem:usr>"
      let hashObj = generateHashToken(soap: soapString)
      let envelope = soapRequest.addChild(
          name: "soapenv:Envelope",
          attributes: self.xmlnstag
      )
      let body = envelope.addChild(
        name: "soapenv:Body"
      )
      let check = body.addChild(
        name: "tem:RegeneraToken"
      )
      check.addChild(
        name: "request",
        value: hashObj
      )
    
    let soapLenth = String(soapRequest.xml.count)
    let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
    let theURL = URL(string: url)
    var mutableR = getURLRequest(soapLenth, theURL!, .regeneraToken)
    mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)

    return mutableR
   }
    
    // MARK: Image Profile
    public func imageProfileRequest() throws -> URLRequest {
        let soapRequest = AEXMLDocument()
        
        let jsonObject = JSONSerializer.toJson(ConfigurationManager.shared.usuarioUIAppDelegate)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:SendUsrThumbnail"
        )
        check.addChild(
            name: "tem:UserID",
            value: ConfigurationManager.shared.usuarioUIAppDelegate.User
        )
        check.addChild(
            name: "tem:Thumbnail",
            value: jsonZipB64
        )
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let theURL = URL(string: ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString())
        var mutableR = getURLRequest(soapLenth, theURL!, .imgprofile)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    // MARK: User profile data
    public func userProfileRequest() throws -> URLRequest {
        let soapRequest = AEXMLDocument()
        
        let jsonObject = JSONSerializer.toJson(ConfigurationManager.shared.usuarioUIAppDelegate)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""
        
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:SendUserInformation"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:usr>\(jsonZipB64)</tem:usr>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:usr",
                value: jsonZipB64
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let theURL = URL(string: ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString() )
        var mutableR = getURLRequest(soapLenth, theURL!, .usrprofile)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    // MARK: - Registror Request Nueva Version
    public func registroRequest() throws -> URLRequest{
        
        let soapRequest = AEXMLDocument()
        var hashObj = ""
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:Registro"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco{
            let uuid = UUID().uuidString
            let tokenString = sha512(string: uuid).toBase64()
            ConfigurationManager.shared.usuarioUIAppDelegate.Token.Token = tokenString
            let soapString = "<tem:registro>\(JSONSerializer.toJson(ConfigurationManager.shared.registroUIAppDelegate))</tem:registro>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            
            check.addChild(
                name: "tem:registro",
                    
                value: JSONSerializer.toJson(ConfigurationManager.shared.registroUIAppDelegate)
            )
        }

        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .registroNew)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        
        return mutableR
    }
    
    public func activarRegistroRequest() throws -> URLRequest{
        
        let soapRequest = AEXMLDocument()
        var hashObj = ""
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ActivarRegistro"
        )
        
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco{
            let uuid = UUID().uuidString
            let tokenString = sha512(string: uuid).toBase64()
            ConfigurationManager.shared.usuarioUIAppDelegate.Token.Token = tokenString
            let soapString = "<tem:registro>\(JSONSerializer.toJson(ConfigurationManager.shared.registroUIAppDelegate))</tem:registro>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:registro",
                value: JSONSerializer.toJson(ConfigurationManager.shared.registroUIAppDelegate)
            )
        }
        

        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .activarRegistroNewVersion)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    
    public func soapSMSRequest(sms: SmsServicio) throws -> URLRequest{
        
        let soapRequest = AEXMLDocument()
        var hashObj = ""
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco{
            let uuid = UUID().uuidString
            let tokenString = sha512(string: uuid).toBase64()
            ConfigurationManager.shared.usuarioUIAppDelegate.Token.Token = tokenString
            let soapString = "<tem:sms>\(JSONSerializer.toJson(sms))</tem:sms>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:sms",
                value: JSONSerializer.toJson(sms)
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .smsNewVersion)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    
    public func soapValidateSMSRequest(sms: SmsServicio) throws -> URLRequest{
       
        let soapRequest = AEXMLDocument()
        var hashObj = ""
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ValidateSmsCode"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco{
            let uuid = UUID().uuidString
            let tokenString = sha512(string: uuid).toBase64()
            ConfigurationManager.shared.usuarioUIAppDelegate.Token.Token = tokenString
            let soapString = "<tem:sms>\(JSONSerializer.toJson(sms))</tem:sms>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:sms",
                value: JSONSerializer.toJson(sms)
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .validateSmsNewVersion)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    
    public func cambiarContraseniaRequest() throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(ConfigurationManager.shared.usuarioUIAppDelegate)
        var hashObj = ""
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:CambiarPassword"
        )
        
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:usuario>\(jsonObject)</tem:usuario>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:usuario",
                value: JSONSerializer.toJson(ConfigurationManager.shared.usuarioUIAppDelegate)
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .cambiarContraseniaNewVersion)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    
    
    public func resetContraseniaRequest(_ usr: FEUsuario) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(usr)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        
        let soapRequest = AEXMLDocument()
        
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ResetearPassword"
        )
        check.addChild(
            name: "tem:usuario",
            value: JSONSerializer.toJson(jsonZipB64)
        )
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .resetContraseniaNewVersion)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    
    
    public func sepomexRequest(sepomex: SepoMexResult) throws -> URLRequest{
        var hashObj = ""

        let soapRequest = AEXMLDocument()
        
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ObtenerCodigoPostal"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let jsonOBJ = JSONSerializer.toJson(sepomex)//
            let soapString = "<tem:codigo>\(jsonOBJ)</tem:codigo>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:codigo",
                value: JSONSerializer.toJson(sepomex)
            )
        }

        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .sepomex)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }

    public func plantillasRequest() throws -> URLRequest{
        
        let jsonObject = JSONSerializer.toJson(ConfigurationManager.shared.plantillaUIAppDelegate)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""

        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ObtienePlantillas"
        )

        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:plantilla>\(jsonZipB64)</tem:plantilla>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:plantilla",
                value: jsonZipB64
            )
        }

        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .plantillas)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func consultaRemoto(formato: FECatRemoto) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(formato)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        let soapRequest = AEXMLDocument()
        
        var hashObj = ""
        
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:CargaCatalogoRemoto"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:catRemoto>\(jsonZipB64)</tem:catRemoto>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:catRemoto",
                value: jsonZipB64
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        //ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .catalogoRemoto)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func variablesRequest() throws -> URLRequest{
        
        let jsonObject = JSONSerializer.toJson(ConfigurationManager.shared.variablesUIAppDelegate)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""
        
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ObtieneVariables"
        )

        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:variable>\(jsonZipB64)</tem:variable>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )

        }else{
            check.addChild(
                name: "tem:variable",
                value: jsonZipB64
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .variables)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public func formatosRequest(formato: FEConsultaFormato) throws -> URLRequest{
        
        let jsonObject = JSONSerializer.toJson(formato)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""

        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ConsultaFormatos"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:formato>\(jsonZipB64)</tem:formato>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:formato",
                value: jsonZipB64
            )
        }
        let str = soapRequest.xmlCompact
        let filename = getDocumentsDirectory().appendingPathComponent("output.txt")
        do {
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .formatos)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func deleteFormatoRequest(formato: FEConsultaFormato) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(formato)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        
        var hashObj = ""
        
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:BorraFormatoBorrador"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:formato>\(jsonZipB64)</tem:formato>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:formato",
                value: jsonZipB64
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .deleteFormatos)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func sendFormatosRequest(formato: FEConsultaFormato) throws -> URLRequest{
        formato.Formato.JsonDatos = formato.Formato.JsonDatos.replacingOccurrences(of: "\\\"", with: "\\\\\"")
        formato.Formato.JsonDatos = formato.Formato.JsonDatos.replacingOccurrences(of: "\"", with: "\\\"")
        let json = JSONSerializer.toJson(formato)
        _ = ConfigurationManager.shared.utilities.save(info: json, path: "\(Cnstnt.Tree.customBorrador)/bor.bor")
        let gettingXml = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.customBorrador)/bor.bor")
        let compressedData: Data = try! gettingXml!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""

        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:EnviaFormato"
        )

        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:formato>\(jsonZipB64)</tem:formato>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:formato",
                value: jsonZipB64
            )
        }

        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .sendFormatos)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func sendAnexosRequest(consulta: FEConsultaAnexo) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(consulta)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""
        
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:EnviaAnexo"
        )

        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:anexo>\(jsonZipB64)</tem:anexo>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:anexo",
                value: jsonZipB64
            )
        }
        

        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .sendAnexos)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func consultaAnexosRequest(consulta: FEConsultaAnexo) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(consulta)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""

        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ConsultaAnexo"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:anexo>\(jsonZipB64)</tem:anexo>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:anexo",
                value: jsonZipB64
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .consultaAnexos)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func transitaRequest(formato: FEConsultaFormato) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(formato)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""

        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:TransitaFormato"
        )
        
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:formato>\(jsonZipB64)</tem:formato>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:formato",
                value: jsonZipB64
            )
        }

        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .transitar)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func consultaRequest(consulta: FEConsultaTemplate) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(consulta)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        var hashObj = ""
        
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ConsultaTemplate"
        )
        
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:template>\(jsonZipB64)</tem:template>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:template",
                value: jsonZipB64
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .consultas)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func pdfRequest(formato: FEFormatoData) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(formato)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        let soapRequest = AEXMLDocument()
        
        var hashObj = ""
        
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:DescargaPDF"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:formato>\(jsonZipB64)</tem:formato>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:formato",
                value: jsonZipB64
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .pdf)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    // MARK: Download pdf publicado
    public func downloadDOCRequest(formato: FEFormatoData) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(formato)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        let soapRequest = AEXMLDocument()
        
        var hashObj = ""
        
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:ConsultaArchivoPublicado"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:formato>\(jsonZipB64)</tem:formato>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:formato",
                value: jsonZipB64
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .pdfPublicado)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    // MARK: - SERVICIOS
    public func compareFacesRequest(compareFaces: CompareFacesResult) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(compareFaces)
        var hashObj = ""
        //let dataJson = jsonObject.data(using: .utf8)
        //let compressedData: Data = try! dataJson!.gzipped()
        //let jsonZipB64 =  compressedData.base64EncodedString()
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:CompareFaces"
        )
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:subject>\(jsonObject)</tem:subject>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:subject",
                value: jsonObject
            )
        }
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .compareFaces)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func soapFolioRequest(folio: FolioAutomaticoResult) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(folio)
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        _ =  compressedData.base64EncodedString()
        var hashObj = ""

        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:FolioAutomatico"
        )

        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            let soapString = "<tem:folio>\(jsonObject)</tem:folio>"
            hashObj = generateHashToken(soap: soapString)
            check.addChild(
                name: "request",
                value: hashObj
            )
        }else{
            check.addChild(
                name: "tem:folio",
                value: jsonObject
            )
        }

        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .folio)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    
  
    
    public func soapCorreoRequest(correo: CorreoServicio) throws -> URLRequest{
        let jsonObject = JSONSerializer.toJson(correo)
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:SendMail"
        )
        check.addChild(
            name: "tem:correo",
            value: jsonObject
        )
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .correo)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
        
    // MARK: - NEW SERVICIOS
    public func soapNewCompareFacesRequest(mParams mparams: [String], poutParams poutparams:[String]) throws -> URLRequest{
        
        let soapRequest = xmlCompareFacesRequest(mParams: mparams, poutParams: poutparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        
        return mutableR
        
    }
    
    public func soapNewFolioRequest(mParams mparams: [String], sParams sparams:[String]) throws -> URLRequest{
        
        let soapRequest = xmlFolioRequest(mParams: mparams, sParams: sparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func soapNewSMSRequest(mParams mparams: [String], sParams sparams:[String]) throws -> URLRequest{
        
        let soapRequest = xmlEnvioSMSRequest(mParams: mparams, sParams: sparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func soapNewValidateSMSRequest(mParams mparams: [String], sParams sparams:[String]) throws -> URLRequest{
        
        let soapRequest = xmlValidarSMSRequest(mParams: mparams, sParams: sparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func soapNewSepomexRequest(mParams mparams: [String], sParams sparams:[String]) throws -> URLRequest{
        
        let soapRequest = xmlSepomexRequest(mParams: mparams, sParams: sparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func soapNewRegistroRequest(mParams mparams: [String], sParams sparams:[String]) throws -> URLRequest{
        
        let soapRequest = xmlRegistroRequest(mParams: mparams, sParams: sparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func soapNewActivacionCorreoRequest(mParams mparams: [String], sParams sparams:[String]) throws -> URLRequest{
        
        let soapRequest = xmlActivacionCorreoRequest(mParams: mparams, sParams: sparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func soapNewExisteUsuarioRequest(mParams mparams: [String], sParams sparams:[String]) throws -> URLRequest{
        let soapRequest = xmlExisteUsuarioRequest(mParams: mparams, sParams: sparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func soapNewActivarUsuarioRequest(mParams mparams: [String], sParams sparams:[String]) throws -> URLRequest{
        let soapRequest = xmlActivarUsuarioRequest(mParams: mparams, sParams: sparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    
    public func soapNewSassSirhRequest(mParams mparams: [String], sParams sparams:[String], poutParams poutparams: [String]) throws -> URLRequest{
        let soapRequest = xmlSassSirhRequest(mParams: mparams, sParams: sparams, poutParams: poutparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    //MARK: -REQUEST CREDIFIEL
    
    public func soapVerificaCurpRfcCredifielRequest(mParams mparams: [String]) throws -> URLRequest{
        let soapRequest = xmlVerificaCurpRfcCredifielRequest(mParams: mparams)
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .generic)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    // MARK: GENERIC REQUEST
    public func soapGenericRequest(idService idservice: String?, mParams mparams: [[String: Any]]?, sParams sparams: [[String: Any]]?, poutParams poutparams: [[String: Any]]?, jsonService: String) throws -> URLRequest{
        let soapRequest = xmlGenericRequest(idService: idservice ?? "", mParams: mparams ?? [], sParams: sparams ?? [], poutParams: poutparams ?? [], jsonService: jsonService)
        let soapLenth = String(soapRequest.xml.count)
        
        var url = ""
        url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
       
        let theURL = URL(string: url)
        if plist.idportal.rawValue.dataI() <= 39 || ConfigurationManager.shared.isConsubanco || ConfigurationManager.shared.webSecurity{
            var mutableR = getURLRequest(soapLenth, theURL!, .genericJson)
            ConfigurationManager.shared.requestData = soapRequest.xmlCompact
            mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
            return mutableR
        }else{
            var mutableR = getURLRequest(soapLenth, theURL!, .generic)
            ConfigurationManager.shared.requestData = soapRequest.xmlCompact
            mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
            return mutableR
        }
    }
    
    public func soapGenericJSONRequest(jsonService jsonservice: NSString) throws -> URLRequest{
        let soapRequest = xmlGenericJSONRequest(jsonService: jsonservice)
        let soapLenth = String(soapRequest.xml.count)
        var url = ""
        url = ConfigurationManager.shared.codigoUIAppDelegate.WcfServicios.cleanURLString()
        
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .genericJson)
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    // MARK: TESTING
    // MARK: LOGALTY SEND FORMATOS
    public func sendFormatosRequestLogalty(formato: FEConsultaFormato) throws -> URLRequest{
        let formatoJson = formato
        formatoJson.Formato.JsonDatos = formatoJson.Formato.JsonDatos.replacingOccurrences(of: "\"", with: "|")
        let json = JSONSerializer.toJson(formatoJson)
        let jsonObject = json.replacingOccurrences(of: "|", with: "\\\"")
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:GeneraPeticionLogalty"
        )
        check.addChild(
            name: "tem:accept",
            value: jsonZipB64
        )
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .requestLogalty)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func generateSAML(_ json: String) throws -> URLRequest{
        let dataJson = json.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:GeneraSaml"
        )
        check.addChild(
            name: "tem:saml",
            value: jsonZipB64
        )
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .saml)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
    
    public func sendFormatosRequestEndLogalty(formato: FELogaltySaml) throws -> URLRequest{
        let formatoJson = formato
        let json = JSONSerializer.toJson(formatoJson)
        let jsonObject = json
        let dataJson = jsonObject.data(using: .utf8)
        let compressedData: Data = try! dataJson!.gzipped()
        let jsonZipB64 =  compressedData.base64EncodedString()
        let soapRequest = AEXMLDocument()
        let envelope = soapRequest.addChild(
            name: "soapenv:Envelope",
            attributes: self.xmlnstag
        )
        let body = envelope.addChild(
            name: "soapenv:Body"
        )
        let check = body.addChild(
            name: "tem:TerminaProcesoLogalty"
        )
        check.addChild(
            name: "tem:finish",
            value: jsonZipB64
        )
        ConfigurationManager.shared.requestData = soapRequest.xmlCompact
        let soapLenth = String(soapRequest.xml.count)
        let url = ConfigurationManager.shared.codigoUIAppDelegate.WcfFileTransfer.cleanURLString()
        let theURL = URL(string: url)
        var mutableR = getURLRequest(soapLenth, theURL!, .responseLogalty)
        mutableR.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        return mutableR
    }
}

