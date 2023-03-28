import Foundation

extension OCRVC{
    
    func resetting(_ service: Int){
        
        // 1 INE/IFE
        // 2 AGUA
        // 3 CFE
        // 4 Pasaporte
        // 5 VISA
        
        switch service {
        case 1:
            resetObjectIne()
            break
        case 2:
            resetObjectAgua()
            break
        case 3:
            resetObjectCfe()
            break
        case 4:
            resetObjectPasaporte()
            break
        case 5:
            resetObjectVisa()
            break
        default:
            break
        }
        
    }
    
    
    func resetObjectIne(){
        objectOCRINE?.detectedcic =             false
        objectOCRINE?.detectedocr =             false
        objectOCRINE?.detectedclaveelector =    false
        objectOCRINE?.detectedcurp =            false
        objectOCRINE?.detecteddomicilio =       false
        objectOCRINE?.detectedemision =         false
        objectOCRINE?.detectedestado =          false
        objectOCRINE?.detectedfolio =           false
        objectOCRINE?.detectedlocalidad =       false
        objectOCRINE?.detectedmunicipio =       false
        objectOCRINE?.detectednombre =          false
        objectOCRINE?.detectedregistro =        false
        objectOCRINE?.detectedseccion =         false
        objectOCRINE?.detectedsexo =            false
        objectOCRINE?.detectedvigencia =        false
        objectOCRINE?.detectedfecha =           false
        
        objectOCRINE?.nombre =                  ""
        objectOCRINE?.aPaterno =                ""
        objectOCRINE?.aMaterno =                ""
        objectOCRINE?.calle =                   ""
        objectOCRINE?.colonia =                 ""
        objectOCRINE?.delegacion =              ""
        objectOCRINE?.ciudad =                  ""
        objectOCRINE?.cP =                      ""
        objectOCRINE?.curp =                    ""
        objectOCRINE?.rfc =                     ""
        objectOCRINE?.seccion =                 ""
        objectOCRINE?.claveElector =            ""
        objectOCRINE?.vigencia =                ""
        objectOCRINE?.fecha =                   ""
        objectOCRINE?.edad =                    ""
        objectOCRINE?.sexo =                    ""
        objectOCRINE?.folio =                   ""
        objectOCRINE?.registro =                ""
        objectOCRINE?.municipio =               ""
        objectOCRINE?.localidad =               ""
        objectOCRINE?.reposicion =              ""
        objectOCRINE?.estado =                  ""
        objectOCRINE?.cic =                     ""
        objectOCRINE?.ocr =                     ""
        objectOCRINE?.emision =                 ""
    }
    
    func resetObjectAgua(){
        
    }
    
    func resetObjectCfe(){
        
    }
    
    func resetObjectPasaporte(){
        
        // Validation Anchors
        objectOCRPasaporte?.detectedtipo =                      false
        objectOCRPasaporte?.detectedclavedelpais =              false
        objectOCRPasaporte?.detectedpasaportenumero =           false
        objectOCRPasaporte?.detectedaPaterno =                  false
        objectOCRPasaporte?.detectedaMaterno =                  false
        objectOCRPasaporte?.detectednombres =                   false
        objectOCRPasaporte?.detectednacionalidad =              false
        objectOCRPasaporte?.detectedobservaciones =             false
        objectOCRPasaporte?.detectedfechanacimiento =           false
        objectOCRPasaporte?.detectedcurp =                      false
        objectOCRPasaporte?.detectedsexo =                      false
        objectOCRPasaporte?.detectedlugarnacimiento =           false
        objectOCRPasaporte?.detectedfechaexpedicion =           false
        objectOCRPasaporte?.detectedfechacaducidad =            false
        objectOCRPasaporte?.detectedautoridad =                 false
        
        objectOCRPasaporte?.tipo =                              ""
        objectOCRPasaporte?.clavedelpais =                      ""
        objectOCRPasaporte?.pasaportenumero =                   ""
        objectOCRPasaporte?.aPaterno =                          ""
        objectOCRPasaporte?.aMaterno =                          ""
        objectOCRPasaporte?.nombres =                           ""
        objectOCRPasaporte?.nacionalidad =                      ""
        objectOCRPasaporte?.observaciones =                     ""
        objectOCRPasaporte?.fechanacimiento =                   ""
        objectOCRPasaporte?.curp =                              ""
        objectOCRPasaporte?.sexo =                              ""
        objectOCRPasaporte?.lugarnacimiento =                   ""
        objectOCRPasaporte?.fechaexpedicion =                   ""
        objectOCRPasaporte?.fechacaducidad =                    ""
        objectOCRPasaporte?.autoridad =                         ""
    }
    
    func resetObjectVisa(){
        
        // Validation Anchors
        objectOCRVisa?.detectedvisa =                         false
        objectOCRVisa?.detectedsurname =                      false
        objectOCRVisa?.detectedgivennames =                   false
        objectOCRVisa?.detecteddatebirth =                    false
        objectOCRVisa?.detectednationality =                  false
        objectOCRVisa?.detectedsex =                          false
        objectOCRVisa?.detecteddateissue =                    false
        objectOCRVisa?.detectedexpireson =                    false
        objectOCRVisa?.detectedequivalencevalue =             false
        objectOCRVisa?.detecteddocumenttype =                 false
        objectOCRVisa?.detectedcountryissuance =              false
        objectOCRVisa?.detecteddocumentnumber =               false
        objectOCRVisa?.detectedinventorycontrolnumber =       false
        
        objectOCRVisa?.visaClass =                  ""
        objectOCRVisa?.visaType =                   ""
        objectOCRVisa?.apellidos =                  ""
        objectOCRVisa?.aPaterno =                   ""
        objectOCRVisa?.aMaterno =                   ""
        objectOCRVisa?.nombre =                     ""
        objectOCRVisa?.fecha =                      ""
        objectOCRVisa?.nacionalidad =               ""
        objectOCRVisa?.sexo =                       ""
        objectOCRVisa?.dateIssue =                  ""
        objectOCRVisa?.expiresOn =                  ""
        objectOCRVisa?.equivalenceValue =           ""
        objectOCRVisa?.documentType =               ""
        objectOCRVisa?.countryIssuance =            ""
        objectOCRVisa?.documentNumber =             ""
        objectOCRVisa?.inventoryControlNumber =     ""
    }
    
}
