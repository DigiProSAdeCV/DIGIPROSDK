import Foundation
import UIKit


struct OCRIneWordBreak{
    func containsFederal(_ values: [String], _ controller: OCRVC){
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("INSTITUTO NACIONAL") || result.contains("instituto nacional") || result.contains("INSTITUT0 NACIONAL") || result.contains("INSTITUTO NACI0NAL") || result.contains("INSTITUT0 NACI0NAL") || result.contains("institut0 nacional") || result.contains("instituto naci0nal") || result.contains("institut0 naci0nal"){
                    // Detected INE
                    controller.objectOCRINE?.detectedlocalidad = true
                    controller.objectOCRINE?.localidad = ""
                    controller.objectOCRINE?.detectedsexo = true
                    controller.objectOCRINE?.sexo = ""
                }
            }
        }
    }
    
    func containsNombre(_ values: [String], _ controller: OCRVC){
        
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            if word.contains("NOMBRE"){
                let indexNombre = wordResult.firstIndex(of: "NOMBRE")
                if indexNombre != nil{
                    getNombre(wordResult, indexNombre!, controller)
                }
            }
            if word.contains("nombre"){
                let indexNombre = wordResult.firstIndex(of: "nombre")
                if indexNombre != nil{
                    getNombre(wordResult, indexNombre!, controller)
                }
            }
            if word.contains("N0MBRE"){
                let indexNombre = wordResult.firstIndex(of: "N0MBRE")
                if indexNombre != nil{
                    getNombre(wordResult, indexNombre!, controller)
                }
            }
            if word.contains("n0mbre"){
                let indexNombre = wordResult.firstIndex(of: "n0mbre")
                if indexNombre != nil{
                    getNombre(wordResult, indexNombre!, controller)
                }
            }
            if word.contains("NOM3RE"){
                let indexNombre = wordResult.firstIndex(of: "NOM3RE")
                if indexNombre != nil{
                    getNombre(wordResult, indexNombre!, controller)
                }
            }
            if word.contains("nom3re"){
                let indexNombre = wordResult.firstIndex(of: "nom3re")
                if indexNombre != nil{
                    getNombre(wordResult, indexNombre!, controller)
                }
            }
            if word.contains("n0MBRE"){
                let indexNombre = wordResult.firstIndex(of: "n0MBRE")
                if indexNombre != nil{
                    getNombre(wordResult, indexNombre!, controller)
                }
            }
        }
        
        return
    }
    
    func getNombre(_ values: [String], _ index: Int, _ controller: OCRVC){
        // Getting data for Nombre Completo
        // Apellido Paterno +1
        // Apellido Materno +2
        // Nombre o Nombres +3
        
        // Setting values in inputs and changing image validation
        // Setting booleans to true
        // Setting refresh button user enabled to true
        
        if !values.indices.contains(index + 1) {
            return
        }
        
        if !values.indices.contains(index + 2) {
            return
        }
        
        if !values.indices.contains(index + 3) {
            return
        }
        
        if values[index + 1] == "" || values[index + 2] == "" || values[index + 3] == ""{
            return
        }
        
        controller.objectOCRINE?.detectednombre = true
        controller.objectOCRINE?.nombre = values[index + 3].trimmingCharacters(in: .whitespacesAndNewlines)
        controller.objectOCRINE?.aPaterno = values[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
        controller.objectOCRINE?.aMaterno = values[index + 2].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func containsDireccion(_ values: [String], _ controller: OCRVC){
        
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            if word.contains("DOMICILIO"){
                let indexDireccion = wordResult.firstIndex(of: "DOMICILIO")
                if indexDireccion != nil{
                    getDireccion(wordResult, indexDireccion!, controller)
                }
            }
            if word.contains("domicilio"){
                let indexDireccion = wordResult.firstIndex(of: "domicilio")
                if indexDireccion != nil{
                    getDireccion(wordResult, indexDireccion!, controller)
                }
            }
            if word.contains("D0MICILI0"){
                let indexDireccion = wordResult.firstIndex(of: "D0MICILI0")
                if indexDireccion != nil{
                    getDireccion(wordResult, indexDireccion!, controller)
                }
            }
            if word.contains("DOMICILI0"){
                let indexDireccion = wordResult.firstIndex(of: "DOMICILI0")
                if indexDireccion != nil{
                    getDireccion(wordResult, indexDireccion!, controller)
                }
            }
            if word.contains("D0MICILIO"){
                let indexDireccion = wordResult.firstIndex(of: "D0MICILIO")
                if indexDireccion != nil{
                    getDireccion(wordResult, indexDireccion!, controller)
                }
            }
            if word.contains("d0micili0"){
                let indexDireccion = wordResult.firstIndex(of: "d0micili0")
                if indexDireccion != nil{
                    getDireccion(wordResult, indexDireccion!, controller)
                }
            }
            if word.contains("d0micilio"){
                let indexDireccion = wordResult.firstIndex(of: "d0micilio")
                if indexDireccion != nil{
                    getDireccion(wordResult, indexDireccion!, controller)
                }
            }
            if word.contains("domicili0"){
                let indexDireccion = wordResult.firstIndex(of: "domicili0")
                if indexDireccion != nil{
                    getDireccion(wordResult, indexDireccion!, controller)
                }
            }
        }
        
    }
    
    func getDireccion(_ values: [String], _ index: Int, _ controller: OCRVC){
        // Getting data for Domicilio
        // Calle +1
        // Colonia y CP +2
        // Delegación y Estado +3
        
        if !values.indices.contains(index + 2) {
            return
        }
        
        if !values.indices.contains(index + 3) {
            return
        }
        
        if values[index + 2] == "" || values[index + 3] == ""{
            return
        }
        
        let colonia = values[index + 2].regexReplace(regEx: "[\\d]")
        let codigo = values[index + 2].regexReplace(regEx: "[^\\d]")
        let delCol = values[index + 3].split(separator: ",")
        
        if colonia == ""{
            return
        }
        
        if codigo == ""{
            return
        }
        
        if !delCol.indices.contains(0) || !delCol.indices.contains(1){
            return
        }
        
        controller.objectOCRINE?.detecteddomicilio = true
        controller.objectOCRINE?.calle = values[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
        controller.objectOCRINE?.colonia = colonia.trimmingCharacters(in: .whitespacesAndNewlines)
        controller.objectOCRINE?.cP = codigo.trimmingCharacters(in: .whitespacesAndNewlines)
        controller.objectOCRINE?.delegacion = String(delCol[0]).trimmingCharacters(in: .whitespacesAndNewlines)
        controller.objectOCRINE?.ciudad = String(delCol[1]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func containsClaveElector(_ values: [String], _ controller: OCRVC){
        
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("CLAVE DE ELECTOR"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("clave de elector"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("CLAVE DE ELECT0R"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("clave de elect0r"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("CLAVE"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("clave"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("CLAVE"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("clave"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("DE ELECTOR"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("de elector"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("DE ELECT0R"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("de elect0r"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("ELECTOR"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("elector"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("ELECT0R"){
                    getClaveElector(result, 0, controller)
                }
                if result.contains("elect0r"){
                    getClaveElector(result, 0, controller)
                }
            }
        }
        
    }
    
    func getClaveElector(_ values: String, _ index: Int, _ controller: OCRVC){
        // Getting data for Clave de elector
        // Clave de elector +1
        //let claveElector = values.regexMatches(regex: "(\\w{15,18})")
        let claveElector = values.regexMatches(regex: "([A-Z]{6})+([0-9]{6})+([0-9]{2})+([A-Z0-9]{4})")
        if claveElector.count > 0{
            controller.objectOCRINE?.detectedclaveelector = true
            controller.objectOCRINE?.claveElector = claveElector[0].trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func containsCurp(_ values: [String], _ controller: OCRVC){
        
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("CURP"){
                    getCurp(result, 0, controller)
                }
                if result.contains("curp"){
                    getCurp(result, 0, controller)
                }
                if result.contains("Curp"){
                    getCurp(result, 0, controller)
                }
                if result.contains("CUrp"){
                    getCurp(result, 0, controller)
                }
                if result.contains("CURp"){
                    getCurp(result, 0, controller)
                }
            }
        }
        
    }
    
    func getCurp(_ values: String, _ index: Int, _ controller: OCRVC){
        // Getting data for Clave de elector
        // Clave de elector +1
        let curp = values.regexMatches(regex: "(\\w{15,18})")
        //let curp = values.regexMatches(regex: "([A-Z]{4})+([0-9]{6})+([A-Z]{6})+([0-9]{2})")
        
        if curp.count > 0{
            controller.objectOCRINE?.detectedcurp = true
            controller.objectOCRINE?.curp = curp[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let rfc = curp[0].regexMatches(regex: "(\\w{13})")
            controller.objectOCRINE?.rfc = rfc[0].trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func containsSeccion(_ values: [String], _ controller: OCRVC){
        
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("SECCIÓN"){
                    let regex = result.regexMatches(regex: "(SECCIÓN )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("SECCION"){
                    let regex = result.regexMatches(regex: "(SECCION )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("SECCI0N"){
                    let regex = result.regexMatches(regex: "(SECCI0N )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("sección"){
                    let regex = result.regexMatches(regex: "(sección )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("seccion"){
                    let regex = result.regexMatches(regex: "(seccion )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("secci0n"){
                    let regex = result.regexMatches(regex: "(secci0n )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("ECCIÓN"){
                    let regex = result.regexMatches(regex: "(ECCIÓN )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("ECCION"){
                    let regex = result.regexMatches(regex: "(ECCION )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("ECCI0N"){
                    let regex = result.regexMatches(regex: "(ECCI0N )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("CCIÓN"){
                    let regex = result.regexMatches(regex: "(CCIÓN )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("CCION"){
                    let regex = result.regexMatches(regex: "(CCION )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("CCI0N"){
                    let regex = result.regexMatches(regex: "(CCI0N )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("ección"){
                    let regex = result.regexMatches(regex: "(ección )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("eccion"){
                    let regex = result.regexMatches(regex: "(eccion )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("ecci0n"){
                    let regex = result.regexMatches(regex: "(ecci0n )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("cción"){
                    let regex = result.regexMatches(regex: "(cción )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("ccion"){
                    let regex = result.regexMatches(regex: "(ccion )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
                if result.contains("cci0n"){
                    let regex = result.regexMatches(regex: "(cci0n )+([0-9]{4})")
                    if regex.count > 0{
                        getSeccion(regex[0], 0, controller)
                    }
                }
            }
        }
        
    }
    
    func getSeccion(_ values: String, _ index: Int, _ controller: OCRVC){
        // Getting data for Clave de elector
        // Clave de elector +1
        let seccion = values.regexMatches(regex: "([0-9]{4})")
        if seccion.count > 0{
            controller.objectOCRINE?.detectedseccion = true
            controller.objectOCRINE?.seccion = seccion[0].trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func containsEstado(_ values: [String], _ controller: OCRVC){
        
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("ESTADO"){
                    getEstado(result, 0, controller)
                }
                if result.contains("estado"){
                    getEstado(result, 0, controller)
                }
                if result.contains("ESTAD0"){
                    getEstado(result, 0, controller)
                }
                if result.contains("estad0"){
                    getEstado(result, 0, controller)
                }
                if result.contains("3STADO"){
                    getEstado(result, 0, controller)
                }
                if result.contains("3stado"){
                    getEstado(result, 0, controller)
                }
                if result.contains("3STAD0"){
                    getEstado(result, 0, controller)
                }
                if result.contains("3stad0"){
                    getEstado(result, 0, controller)
                }
                if result.contains("STADO"){
                    getEstado(result, 0, controller)
                }
                if result.contains("stado"){
                    getEstado(result, 0, controller)
                }
                if result.contains("STAD0"){
                    getEstado(result, 0, controller)
                }
                if result.contains("stad0"){
                    getEstado(result, 0, controller)
                }
                if result.contains("TADO"){
                    getEstado(result, 0, controller)
                }
                if result.contains("tado"){
                    getEstado(result, 0, controller)
                }
                if result.contains("TAD0"){
                    getEstado(result, 0, controller)
                }
                if result.contains("tad0"){
                    getEstado(result, 0, controller)
                }
            }
        }
        
    }
    
    func getEstado(_ values: String, _ index: Int, _ controller: OCRVC){
        // Getting data for Clave de elector
        // Clave de elector +1
        let estado = values.regexMatches(regex: "([0-9]{2})")
        if estado.count > 0{
            controller.objectOCRINE?.detectedestado = true
            controller.objectOCRINE?.estado = estado[0].trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func containsVigencia(_ values: [String], _ controller: OCRVC){
        
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("VIGENCIA"){
                    let regex = result.regexMatches(regex: "(VIGENCIA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("V1GENCIA"){
                    let regex = result.regexMatches(regex: "(V1GENCIA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("VIGENC1A"){
                    let regex = result.regexMatches(regex: "(VIGENC1A )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("vigencia"){
                    let regex = result.regexMatches(regex: "(vigencia )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("v1gencia"){
                    let regex = result.regexMatches(regex: "(v1gencia )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("vigenc1a"){
                    let regex = result.regexMatches(regex: "(vigenc1a )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("igencia"){
                    let regex = result.regexMatches(regex: "(igencia )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("gencia"){
                    let regex = result.regexMatches(regex: "(gencia )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("IGENCIA"){
                    let regex = result.regexMatches(regex: "(IGENCIA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("GENCIA"){
                    let regex = result.regexMatches(regex: "(GENCIA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("vIGENCIA"){
                    let regex = result.regexMatches(regex: "(vIGENCIA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("viGENCIA"){
                    let regex = result.regexMatches(regex: "(viGENCIA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("vigENCIA"){
                    let regex = result.regexMatches(regex: "(vigENCIA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("vigeNCIA"){
                    let regex = result.regexMatches(regex: "(vigeNCIA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("vigenCIA"){
                    let regex = result.regexMatches(regex: "(vigenCIA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("vigencIA"){
                    let regex = result.regexMatches(regex: "(vigencIA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("vigenciA"){
                    let regex = result.regexMatches(regex: "(vigenciA )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
                if result.contains("vigencia"){
                    let regex = result.regexMatches(regex: "(vigencia )+([0-9]{4})")
                    if regex.count > 0{
                        getVigencia(regex[0], 0, controller)
                    }
                }
            }
        }
        
    }
    
    func getVigencia(_ values: String, _ index: Int, _ controller: OCRVC){
        // Getting data for Clave de elector
        // Clave de elector +1
        let vigencia = values.regexMatches(regex: "([0-9]{4})")
        if vigencia.count > 0{
            controller.objectOCRINE?.detectedvigencia = true
            controller.objectOCRINE?.vigencia = vigencia[0].trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func containsCic(_ values: [String], _ controller: OCRVC){
        
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("IDMEX"){
                    let regex = result.regexMatches(regex: "(IDMEX)+([0-9]{9})")
                    if regex.count > 0{
                        let cic = regex[0].regexReplace(regEx: "(IDMEX)")
                        getCic(cic, 0, controller)
                    }
                }
                if result.contains("I DMEX"){
                    let regex = result.regexMatches(regex: "(I DMEX)+([0-9]{9})")
                    if regex.count > 0{
                        let cic = regex[0].regexReplace(regEx: "(I DMEX)")
                        getCic(cic, 0, controller)
                    }
                }
                if result.contains("ID MEX"){
                    let regex = result.regexMatches(regex: "(ID MEX)+([0-9]{9})")
                    if regex.count > 0{
                        let cic = regex[0].regexReplace(regEx: "(ID MEX)")
                        getCic(cic, 0, controller)
                    }
                }
                if result.contains("IDM EX"){
                    let regex = result.regexMatches(regex: "(IDM EX)+([0-9]{9})")
                    if regex.count > 0{
                        let cic = regex[0].regexReplace(regEx: "(IDM EX)")
                        getCic(cic, 0, controller)
                    }
                }
                if result.contains("IDME X"){
                    let regex = result.regexMatches(regex: "(IDME X)+([0-9]{9})")
                    if regex.count > 0{
                        let cic = regex[0].regexReplace(regEx: "(IDME X)")
                        getCic(cic, 0, controller)
                    }
                }
                if result.contains("idmex"){
                    let regex = result.regexMatches(regex: "(idmex)+([0-9]{9})")
                    if regex.count > 0{
                        let cic = regex[0].regexReplace(regEx: "(idmex)")
                        getCic(cic, 0, controller)
                    }
                }
                if result.contains("i dmex"){
                    let regex = result.regexMatches(regex: "(i dmex)+([0-9]{9})")
                    if regex.count > 0{
                        let cic = regex[0].regexReplace(regEx: "(i dmex)")
                        getCic(cic, 0, controller)
                    }
                }
                if result.contains("id mex"){
                    let regex = result.regexMatches(regex: "(id mex)+([0-9]{9})")
                    if regex.count > 0{
                        let cic = regex[0].regexReplace(regEx: "(id mex)")
                        getCic(cic, 0, controller)
                    }
                }
                if result.contains("idm ex"){
                    let regex = result.regexMatches(regex: "(idm ex)+([0-9]{9})")
                    if regex.count > 0{
                        let cic = regex[0].regexReplace(regEx: "(idm ex)")
                        getCic(cic, 0, controller)
                    }
                }
                if result.contains("idme x"){
                    let regex = result.regexMatches(regex: "(idme x)+([0-9]{9})")
                    if regex.count > 0{
                        let cic = regex[0].regexReplace(regEx: "(idme x)")
                        getCic(cic, 0, controller)
                    }
                }
            }
        }
        
        return
    }
    
    func getCic(_ values: String, _ index: Int, _ controller: OCRVC){
        controller.objectOCRINE?.detectedcic = true
        controller.objectOCRINE?.cic = values.trimmingCharacters(in: .whitespacesAndNewlines)
        
    }
    
    func containsOcr(_ values: [String], _ controller: OCRVC){
        
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("\(controller.objectOCRINE?.seccion ?? "")"){
                    let regex = result.regexMatches(regex: "(\(controller.objectOCRINE?.seccion ?? ""))+([0-9]{9})")
                    if regex.count > 0{
                        getOcr(regex[0], 0, controller)
                    }
                }
            }
        }
        
        return
    }
    
    func getOcr(_ values: String, _ index: Int, _ controller: OCRVC){
        
        controller.objectOCRINE?.detectedocr = true
        controller.objectOCRINE?.ocr = values.trimmingCharacters(in: .whitespacesAndNewlines)
        
    }
    
    func containsEmision(_ values: [String], _ controller: OCRVC){
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("ANO DE REGISTRO") || result.contains("ano de registro") || result.contains("DE REGISTRO") || result.contains("REGISTRO") || result.contains("de registro") || result.contains("registro"){
                    let regex = result.regexMatches(regex: "([0-9]{4} )+([0-9]{2})")
                    for component in regex{
                        let number = component.components(separatedBy: " ")
                        getRegistro(number[0], controller)
                        getEmision(number[1], controller)
                    }
                }
            }
        }
    }
    
    func getRegistro(_ values: String, _ controller: OCRVC){
        controller.objectOCRINE?.detectedregistro = true
        controller.objectOCRINE?.registro = values.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getEmision(_ values: String, _ controller: OCRVC){
        controller.objectOCRINE?.detectedemision = true
        controller.objectOCRINE?.emision = values.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func containsLocalidad(_ values: [String], _ controller: OCRVC){
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("Localidad") || result.contains("localidad") || result.contains("L0CALIDAD") || result.contains("l0calidad") || result.contains("LOCALIDAD") || result.contains("local1dad") || result.contains("LOCAL1DAD"){
                    let regex = result.regexMatches(regex: "([0-9]{4})")
                    if regex.count > 0{
                        getLocalidad(regex[0], controller)
                    }
                }
            }
        }
    }
    
    func getLocalidad(_ values: String, _ controller: OCRVC){
        controller.objectOCRINE?.detectedlocalidad = true
        controller.objectOCRINE?.localidad = values.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func containsMunicipio(_ values: [String], _ controller: OCRVC){
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("MUNICIPIO") || result.contains("municipio") || result.contains("MUNICIPI0") || result.contains("municipi0"){
                    let regex = result.regexMatches(regex: "([0-9]{3})")
                    if regex.count > 0{
                        getMunicipio(regex[0], controller)
                    }
                }
            }
        }
    }
    
    func getMunicipio(_ values: String, _ controller: OCRVC){
        controller.objectOCRINE?.detectedmunicipio = true
        controller.objectOCRINE?.municipio = values.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func containsSexo(_ values: [String], _ controller: OCRVC){
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("SEXO") || result.contains("sexo") || result.contains("SEX0") || result.contains("sex0"){
                    let regex = result.regexMatches(regex: "([HMhm]{1})")
                    if regex.count > 0{
                        getSexo(regex[0], controller)
                    }
                }
            }
        }
    }
    
    func getSexo(_ values: String, _ controller: OCRVC){
        controller.objectOCRINE?.detectedsexo = true
        controller.objectOCRINE?.sexo = values.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func containsFolio(_ values: [String], _ controller: OCRVC){
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("FOLIO") || result.contains("folio") || result.contains("F0LI0") || result.contains("f0li0") || result.contains("F0LIO") || result.contains("FOLI0") || result.contains("foli0") || result.contains("f0lio"){
                    let regex = result.regexMatches(regex: "([0-9]{13})")
                    if regex.count > 0{
                        getFolio(regex[0], controller)
                    }
                }
            }
        }
    }
    
    func getFolio(_ values: String, _ controller: OCRVC){
        controller.objectOCRINE?.detectedfolio = true
        controller.objectOCRINE?.folio = values.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func containsFecha(_ values: [String], _ controller: OCRVC){
        
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            for result in wordResult{
                if result.contains("FECHA"){
                    let indexFecha = wordResult.firstIndex(of: "FECHA")
                    if indexFecha != nil{
                        getFecha(wordResult, indexFecha!, controller)
                    }
                }
                if result.contains("fecha"){
                    let indexFecha = wordResult.firstIndex(of: "fecha")
                    if indexFecha != nil{
                        getFecha(wordResult, indexFecha!, controller)
                    }
                }
                if result.contains("FECHA DE"){
                    let indexFecha = wordResult.firstIndex(of: "FECHA DE")
                    if indexFecha != nil{
                        getFecha(wordResult, indexFecha!, controller)
                    }
                }
                if result.contains("fecha de"){
                    let indexFecha = wordResult.firstIndex(of: "fecha de")
                    if indexFecha != nil{
                        getFecha(wordResult, indexFecha!, controller)
                    }
                }
                if result.contains("FECHA DE NACIMIENTO"){
                    let indexFecha = wordResult.firstIndex(of: "FECHA DE NACIMIENTO")
                    if indexFecha != nil{
                        getFecha(wordResult, indexFecha!, controller)
                    }
                }
                if result.contains("fecha de nacimiento"){
                    let indexFecha = wordResult.firstIndex(of: "fecha de nacimiento")
                    if indexFecha != nil{
                        getFecha(wordResult, indexFecha!, controller)
                    }
                }
            }
        }
    }
    
    func getFecha(_ values: [String], _ index: Int, _ controller: OCRVC){
        if !values.indices.contains(index + 1) {
            return
        }
        
        if values[index + 1] == ""{
            return
        }
        controller.objectOCRINE?.fecha = values[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        let separador = "/"
        var fechaProcesed  = ["01","01","2000"]
        fechaProcesed = (controller.objectOCRINE?.fecha.split{$0 == separador.first}.map(String.init))!
        if fechaProcesed.count > 2{
          let value = formatter.date(from: "\(fechaProcesed[0])/\(fechaProcesed[1])/\(fechaProcesed[2])")
            let birthDate = value
            let today = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: birthDate ?? today, to: today)
            let ageYears = components.year
            //let ageMonths = components.month
            //let ageDays = components.day

            controller.objectOCRINE?.edad = String(ageYears ?? 0)
        }
        
        
       
    }
}

struct OCRCfeWordBreak{
    
    // We need to detect RMU is same as C.P.
    func containsNombreDomicilio(_ values: [String], _ controller: OCRVC){
        for (vIndex, word) in values.enumerated(){
            let wordResult = word.components(separatedBy: "\n")
            var indexRemoved: [Int] = []
            for (index, result) in wordResult.enumerated(){
                let r = result.trimmingCharacters(in: .whitespacesAndNewlines)
                if result.contains("RMU"){
                    let regex = result.regexMatches(regex: "([0-9]{5} )")
                    if regex.count > 0{
                        controller.objectOCRCfe?.rmu = regex[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                if r == ""{ indexRemoved.append(index); continue; }
                let regex = result.regexMatches(regex: "\\d+(\\.\\d+)")
                if regex.count > 0{ indexRemoved.append(index); continue; }
            }
            let newArray = wordResult.enumerated().map{ (index, record) -> String? in
                if !(indexRemoved.contains(index)){ return record; }; return nil;
            }
            let bestArray = newArray.compactMap { $0 }
            if (bestArray.count > 4) && controller.objectOCRCfe?.rmu != ""{
                // 0 Nombre
                // 1 Calle
                // 2 Adicionales Opcional
                // 3 Colonia, CP
                // 4 Ciudad
                // Regex for detecting numbers in all lines
                if !values.indices.contains(vIndex - 2){ return }
                if !values.indices.contains(vIndex - 1){ return }
                if !values.indices.contains(vIndex - 2){ return }
                let cfe = values[vIndex - 2].components(separatedBy: "\n")
                if cfe[0] == "CFE" || cfe[0] == "CHE"{
                    let suminis = values[vIndex - 1].components(separatedBy: "\n")
                    if !(suminis[0].contains("Suministrador")) { return }
                    controller.objectOCRCfe?.nombre = bestArray[0]
                    if bestArray[1].contains(" CP.\(controller.objectOCRCfe!.rmu)"){
                        let calle = bestArray[1].components(separatedBy: " CP.\(controller.objectOCRCfe!.rmu)")
                        controller.objectOCRCfe?.calle = calle[0]
                    }
                    if bestArray[3].contains(". C.P."){
                        let coloniaCP = bestArray[3].components(separatedBy: ". C.P.")
                        controller.objectOCRCfe?.colonia = coloniaCP[0]
                        controller.objectOCRCfe?.cP = coloniaCP[1]
                    }
                    if bestArray[4].contains(", "){
                        let ciudadEstado = bestArray[4].components(separatedBy: ", ")
                        controller.objectOCRCfe?.ciudad = ciudadEstado[1]
                    }
                    getNombreDomicilio(controller)
                }
            }
        }
    }
    
    func getNombreDomicilio(_ controller: OCRVC){
        controller.objectOCRINE?.detectednombre = true
    }
    
}

struct OCRPasaporteWordBreak{
    
    func containsCode(_ values: [String], _ controller: OCRVC){
        for word in values{
            let wordResult = word.components(separatedBy: "\n")
            
            for ww in wordResult{
                
                let regex = ww.regexMatches(regex: "([P]{1}+<[A-Z]{3})")
                if regex.count > 0{
                   getPassNCountry(regex, 0, controller)
                   let name = ww.replacingOccurrences(of: regex[0], with: "")
                   getCompleteName(name, 1, controller)
                }

                // New Passport
                var passcod = ww.regexMatches(regex: "([A-Z]{1}+[0-9]{8})")
                let oldpasscod = ww.regexMatches(regex: "([0-9]{9})")
                if passcod.count == 0{
                    if oldpasscod.count > 0{
                        passcod = oldpasscod
                    }
                }
                if passcod.count > 0{
                    getPassCode(passcod, 0, controller)
                    var next = ww.regexMatches(regex: "([A-Z]{1}+[0-9]{9}+[A-Z]{3})")
                    let oldnext = ww.regexMatches(regex: "([0-9]{10}+[A-Z]{3})")
                    if next.count == 0{
                        if oldnext.count > 0{
                            next = oldnext
                        }
                    }
                    if next.count > 0{
                        let nexxt = ww.replacingOccurrences(of: next[0], with: "")
                        let birth = nexxt.regexMatches(regex: "([0-9]{6})")
                        if birth.count > 0{
                            getBirth(birth, 0, controller)
                        
                            let gender = nexxt.regexMatches(regex: "([0-9]{7}+[A-Z]{1})")
                            if gender.count > 0{
                                getGender(String(gender[0].last!), 0, controller)
                                let nexxxt = nexxt.replacingOccurrences(of: gender[0], with: "")
                                let limit = nexxxt.regexMatches(regex: "([0-9]{6})")
                                if limit.count > 0{
                                    getLimit(limit[0], 0, controller)
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
    }
    
    func getLimit(_ values: String, _ index: Int, _ controller: OCRVC){
        if values == ""{ return }
        controller.objectOCRPasaporte?.detectedfechacaducidad = true
        controller.objectOCRPasaporte?.fechacaducidad = values.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getGender(_ values: String, _ index: Int, _ controller: OCRVC){
        if values == ""{ return }
        controller.objectOCRPasaporte?.detectedsexo = true
        controller.objectOCRPasaporte?.sexo = values.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getBirth(_ values: [String], _ index: Int, _ controller: OCRVC){
        if values[index] == ""{ return }
        controller.objectOCRPasaporte?.detectedfechanacimiento = true
        controller.objectOCRPasaporte?.fechanacimiento = values[index].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getPassCode(_ values: [String], _ index: Int, _ controller: OCRVC){
        if values[index] == ""{ return }
        controller.objectOCRPasaporte?.detectedpasaportenumero = true
        controller.objectOCRPasaporte?.pasaportenumero = values[index].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getPassNCountry(_ values: [String], _ index: Int, _ controller: OCRVC){
        if !values.indices.contains(index) { return }
        if values[index] == ""{ return }
        
        let passport = values[index].regexMatches(regex: "([P]{1})")
        if passport.count > 0{
            controller.objectOCRPasaporte?.detectedtipo = true
            controller.objectOCRPasaporte?.tipo = passport[0].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let country = values[index].regexMatches(regex: "([A-Z]{3})")
        if country.count > 0{
            controller.objectOCRPasaporte?.detectedclavedelpais = true
            controller.objectOCRPasaporte?.clavedelpais = country[0].trimmingCharacters(in: .whitespacesAndNewlines)
            switch country[0] {
            case "MEX":
                controller.objectOCRPasaporte?.detectednacionalidad = true
                controller.objectOCRPasaporte?.nacionalidad = "MEXICANA".trimmingCharacters(in: .whitespacesAndNewlines)
                break;
            default: break;
            }
        }
    }
    
    func getCompleteName(_ values: String, _ index: Int, _ controller: OCRVC){
        if values == ""{ return }
        
        let name = values.components(separatedBy: "<<")
        if name.count < 2 { return }
        let surname = name[0].components(separatedBy: "<")
        
        for (index, n) in surname.enumerated(){
            if n == "" || n == "<"{ continue }
            if index == 0{
                controller.objectOCRPasaporte?.aPaterno = n.trimmingCharacters(in: .whitespacesAndNewlines)
                controller.objectOCRPasaporte?.detectedaPaterno = true
                continue
            }else if index == 1{
                controller.objectOCRPasaporte?.aMaterno = n.trimmingCharacters(in: .whitespacesAndNewlines)
                controller.objectOCRPasaporte?.detectedaMaterno = true
                continue
            }else{
                controller.objectOCRPasaporte?.aMaterno += " \(n.trimmingCharacters(in: .whitespacesAndNewlines))"
                controller.objectOCRPasaporte?.detectedaMaterno = true
                continue
            }
            
            
        }
        if !(controller.objectOCRPasaporte?.detectednombres)!{
            let cleanName = name[1].replacingOccurrences(of: "<", with: " ")
            controller.objectOCRPasaporte?.detectednombres = true
            controller.objectOCRPasaporte?.nombres = cleanName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
}
