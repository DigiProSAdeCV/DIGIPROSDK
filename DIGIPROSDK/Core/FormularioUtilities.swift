//
//  FormularioUtilities.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 5/3/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FormularioUtilities{
    
    public static let shared = FormularioUtilities()
    
    public var currentFormato = FEFormatoData()
    public var currentPlantilla = FEPlantillaData()
    public var currentAnexos = [FEAnexoData]()
    public var atributosPaginas = [Atributos_pagina]()
    public var paginasVisibles = [Atributos_pagina]()
    public var paginasSegmented = [(pag: Int, position: Int)]()
    
    public var globalFlujo = 0
    public var globalIndexFlujo = 0
    public var globalProceso = 0
    public var globalIndexProceso = 0
    
    public var rules: AEXMLDocument?
    public var services: AEXMLDocument?
    public var components: AEXMLDocument?
    public var mathematics: AEXMLDocument?
    public var prefilleddata: AEXMLDocument?
    public var pdfmapping: AEXMLDocument?
    public var rulesAfterWizard: [AEXMLElement] = []
    
    public var elementsInPlantilla = [(id: String, type: String, kind: Any?, element: Elemento?)]()
    
    public func operaciones(_ a: String, _ b: String, _ t: String) -> String{

        var a = a
        var b = b
        
        let aIsNumber = Double(a) != nil ? true : false
        let bIsNumber = Double(b) != nil ? true : false
        
        switch (t) {
        case "-":
            if !aIsNumber || !bIsNumber{
                return "\(a) \(b)"
            }else{
                return String(Double(Double(a)! - Double(b)!))
            }
        case "+":
            if !aIsNumber || !bIsNumber{
                return "\(a) \(b)"
            }else{
                return String(Double(Double(a)! + Double(b)!))
            }
        case "/":
            if !aIsNumber || !bIsNumber{
                return "\(a) \(b)"
            }else{
                return String(Double(Double(a)! / Double(b)!))
            }
        case "*":
            if !aIsNumber || !bIsNumber{
                return "\(a) \(b)"
            }else{
                return String(Double(Double(a)! * Double(b)!))
            }
        case "^":
            if !aIsNumber || !bIsNumber{
                return "\(a) \(b)"
            }else{
                return String(Double(pow(Double(a)!, Double(b)!)))
            }
        case "=":
            if !aIsNumber && !bIsNumber{
                let logicString = a.lowercased() == b.lowercased()
                return logicString ? "true" : "false"
            }else if aIsNumber && bIsNumber{
                let aN = Double(a)
                let bN = Double(b)
                let logicString = aN == bN
                return logicString ? "true" : "false"
            }else if aIsNumber || bIsNumber{
                if a == "0"{
                    a = "false"
                }else if a == "1"{
                    a = "true"
                }
                if b == "0"{
                    b = "false"
                }else if b == "1"{
                    b = "true"
                }
                let logicString = a.lowercased() == b.lowercased()
                return logicString ? "true" : "false"
            }else{
                let aString = String(a)
                let bSgtring = String(b)
                let logicString = aString.lowercased() == bSgtring.lowercased()
                return logicString ? "true" : "false"
            }
        case "!=":
            if !aIsNumber && !bIsNumber{
                let logicString = a.lowercased() != b.lowercased()
                return logicString ? "true" : "false"
            }else if aIsNumber || bIsNumber{
                if a == "0"{
                    a = "false"
                }else if a == "1"{
                    a = "true"
                }
                if b == "0"{
                    b = "false"
                }else if b == "1"{
                    b = "true"
                }
                let logicString = a.lowercased() != b.lowercased()
                return logicString ? "true" : "false"
            }else{
                let aString = String(a)
                let bSgtring = String(b)
                let logicString = aString.lowercased() != bSgtring.lowercased()
                return logicString ? "true" : "false"
            }
        case "&&":
            let aString = String(a)
            let bSgtring = String(b)
            let logicString = returnLogicParameter(aString) && returnLogicParameter(bSgtring)
            return logicString ? "true" : "false"
        case "||":
            let aString = String(a)
            let bSgtring = String(b)
            let logicString = returnLogicParameter(aString) || returnLogicParameter(bSgtring)
            return logicString ? "true" : "false"
        case ">":
            let aString = Double(a)
            let bString = Double(b)
            if aString == nil || bString == nil{ return "false" }
            let logicInt = bString! > aString!
            return logicInt ? "true" : "false"
        case "<":
            let aString = Double(a)
            let bString = Double(b)
            if aString == nil || bString == nil{ return "false" }
            let logicInt = bString! <  aString!
            return logicInt ? "true" : "false"
        case ">=":
            let aString = Double(a)
            let bString = Double(b)
            if aString == nil || bString == nil{ return "false" }
            let logicInt = bString! >= aString!
            return logicInt ? "true" : "false"
        case "<=":
            let aString = Double(a)
            let bString = Double(b)
            if aString == nil || bString == nil{ return "false" }
            let logicInt = bString! <= aString!
            return logicInt ? "true" : "false"
        default:
            return "0"
        }
    }
    
    public func variables(_ varRule: String) -> String
    {
        if varRule == "Hoy"
        {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: date)
        }
        if varRule == "Ahora"
        {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        
        let valorListVar = ConfigurationManager.shared.variablesDataUIAppDelegate.ListVariables.compactMap{$0}.filter{$0.Nombre == varRule }.first
        
        if (valorListVar != nil){ return valorListVar!.Valor }
        return ""
    }
    
    public func variables(_ token: [Formula]) -> String{
        if token[0].value == "Hoy"{
            return "Date()"
        }
        if token[0].value == "Ahora"{
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        if token[0].value == "Celular"{
            return "CelularVariable"
        }
        if token[0].value == "Correo"{
            return "CorreoVariable"
        }
        if token[0].value == "Si"{
            return "si"
        }
        if token[0].value == "No"{
            return "no"
        }
        if token[0].value == "Y tambien"{
            return "&&";
        }
        if token[0].value == "O tambien"{
            return "||"
        }
        if token[0].value == "NuevoDocumento" && FormularioUtilities.shared.currentFormato.DocID == 0{
            if token.indices.contains(2){
                if "si" == token[2].value || "Si" == token[2].value{
                    return "si"
                }else{
                    return "no"
                }
            }else{
                return "si"
            }
        }
        if token[0].value == "NuevoDocumento" && FormularioUtilities.shared.currentFormato.DocID != 0{
            return "no"
        }
        if token[0].value == "EstadoDocumento" {
            for variable in ConfigurationManager.shared.plantillaDataUIAppDelegate.ListVariables {
                // Getting value from Documento
                let id = token[2].value.split{$0 == "-"}.map(String.init)
                if token[2].value == variable.Nombre && id[1] == String(FormularioUtilities.shared.currentFormato.EstadoID) {
                    return "si"
                }
            }
            return "no"
        }
        if token[0].value == "PIIDDocumento" {
            if token[2].value == String(FormularioUtilities.shared.currentFormato.PIID) {
                return "si"
            }
            return "no"
        }
        // Detect if there is more than one variable
        if token.count > 1{
            var result = ""
            var counter = 0
            repeat{
                for variable in ConfigurationManager.shared.variablesDataUIAppDelegate.ListVariables {
                    if variable.Nombre == token[counter].value {
                        result = "\(result) \(variable.Valor)"
                        break
                    }
                }
                counter += 1
            } while counter >= token.count;
            if result == ""{
                for t in token{
                    result = "\(result) \(t.value)"
                }
            }
            return result
        }
        for variable in ConfigurationManager.shared.variablesDataUIAppDelegate.ListVariables {
            if variable.Nombre == token[0].value {
                return variable.Valor;
            }
        }
        return token[0].value
    }
    
    public func returnLogicParameter(_ value: String) -> Bool{
        if value == "true"{
            return true
        }
        if value == "false"{
            return false
        }
        let a1 = Int(value) != nil ? Int(value)! : 0
        return a1 > 0
    }
    
    public func checkIfElementIsVisible(_ elem: Elemento) -> Bool{
        // MARK: TODO Set new elements
        // Assinging to TipoElemento Enum
        let tipoElemento = TipoElemento(rawValue: "\(elem._tipoelemento)") ?? TipoElemento.other
        
        switch tipoElemento {
        case .eventos:
            return false
        case .plantilla:
            return false
        case .pagina:
            return (elem.atributos as? Atributos_pagina)?.visible ?? false
        case .seccion:
            return (elem.atributos as? Atributos_seccion)?.visible ?? false
        case .boton:
            return (elem.atributos as? Atributos_boton)?.visible ?? false
        case .codigobarras:
            return (elem.atributos as? Atributos_codigobarras)?.visible ?? false
        case .codigoqr:
            return (elem.atributos as? Atributos_codigoqr)?.visible ?? false
        case .nfc:
            return (elem.atributos as? Atributos_escanerNFC)?.visible ?? false
        case .comboboxtemporal:
            return (elem.atributos as? Atributos_listatemporal)?.visible ?? false
        case .combodinamico:
            return (elem.atributos as? Atributos_comboDinamico)?.visible ?? false
        case .deslizante:
            return (elem.atributos as? Atributos_Slider)?.visible ?? false
        case .espacio:
            return (elem.atributos as? Atributos_espacio)?.visible ?? false
        case .fecha:
            return (elem.atributos as? Atributos_fecha)?.visible ?? false
        case .hora:
            return (elem.atributos as? Atributos_hora)?.visible ?? false
        case .leyenda:
            return (elem.atributos as? Atributos_leyenda)?.visible ?? false
        case .lista:
            return (elem.atributos as? Atributos_lista)?.visible ?? false
        case .logico:
            return (elem.atributos as? Atributos_logico)?.visible ?? false
        case .logo:
            return (elem.atributos as? Atributos_logo)?.visible ?? false
        case .moneda:
            return (elem.atributos as? Atributos_moneda)?.visible ?? false
        case .numero:
            return (elem.atributos as? Atributos_numero)?.visible ?? false
        case .password:
            return (elem.atributos as? Atributos_password)?.visible ?? false
        case .rangofechas:
            return (elem.atributos as? Atributos_rangofechas)?.visible ?? false
        case .semaforotiempo:
            return false
        case .tabber:
            return (elem.atributos as? Atributos_tabber)?.visible ?? false
        case .tabla:
            return (elem.atributos as? Atributos_tabla)?.visible ?? false
        case .texto:
            return (elem.atributos as? Atributos_texto)?.visible ?? false
        case .textarea:
            return (elem.atributos as? Atributos_textarea)?.visible ?? false
        case .wizard:
            return (elem.atributos as? Atributos_wizard)?.visible ?? false
        case .metodo:
            return false
        case .servicio:
            return false
        case .audio, .voz:
            return (elem.atributos as? Atributos_audio)?.visible ?? false
        case .calculadora:
            return (elem.atributos as? Atributos_calculadora)?.visible ?? false
        case .firma:
            return (elem.atributos as? Atributos_firma)?.visible ?? false
        case .firmafad:
            return (elem.atributos as? Atributos_firmafad)?.visible ?? false
        case .georeferencia:
            return (elem.atributos as? Atributos_georeferencia)?.visible ?? false
        case .imagen:
            return (elem.atributos as? Atributos_imagen)?.visible ?? false
        case .pdfocr:
            return (elem.atributos as? Atributos_PDFOCR)?.visible ?? false
        case .mapa:
            return (elem.atributos as? Atributos_mapa)?.visible ?? false
        case .video:
            return (elem.atributos as? Atributos_video)?.visible ?? false
        case .videollamada:
            return false
        case .huelladigital:
            return (elem.atributos as? Atributos_huelladigital)?.visible ?? false
        case .rostrovivo, .capturafacial:
            return (elem.atributos as? Atributos_rostrovivo)?.visible ?? false
        case .documento:
            return (elem.atributos as? Atributos_documento)?.visible ?? false
        case .marcadodocumentos:
            return (elem.atributos as? Atributos_marcadodocumentos)?.visible ?? false
        case .veridasdocumentcapture:
            return (elem.atributos as? Atributos_VeridasVideoSelfie)?.visible ?? false
        case .veridasphotoselfie:
            return (elem.atributos as? Atributos_VeridasVideoSelfie)?.visible ?? false
        case .veridasvideoselfie:
            return (elem.atributos as? Atributos_VeridasVideoSelfie)?.visible ?? false
        case .ocr:
            return (elem.atributos as? Atributos_OCR)?.visible ?? false
        case .jumio:
            return (elem.atributos as? AtributosJumio)?.visible ?? false
        case .other:
            return false
        }
        
    }
}

