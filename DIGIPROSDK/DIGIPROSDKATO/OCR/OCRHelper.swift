import Foundation

extension OCRVC{
    
    func settingAnchors(_ service: Int){
        
        // 1 INE/IFE
        // 2 AGUA
        // 3 CFE
        // 4 Pasaporte
        // 5 VISA
        
        switch service {
        case 1:
            setObjectIne()
            tableView.reloadData()
            break
        case 2:
            setObjectAgua()
            tableView.reloadData()
            break
        case 3:
            setObjectCfe()
            tableView.reloadData()
            break
        case 4:
            setObjectPasaporte()
            tableView.reloadData()
            break
        case 5:
            setObjectVisa()
            tableView.reloadData()
            break
        default:
            break
        }
        
    }
    
    func setObjectIne(){
        validAnchors = [String]()
        tableContent = [String]()
        
        if objectOCRINE?.anchornombre != ""{
            validAnchors.append("Nombre")
            tableContent.append("Nombre")
            tableContent.append("Apellido Paterno")
            tableContent.append("Apellido Materno")
            tableContent.append("Fecha de Nacimiento")
        }
        if objectOCRINE?.anchordomicilio != ""{
            validAnchors.append("Domicilio")
            tableContent.append("Calle")
            tableContent.append("Colonia")
            tableContent.append("Delegación")
            tableContent.append("C.P.")
            tableContent.append("Ciudad/Estado")
        }
        if objectOCRINE?.anchorclaveelector != ""{
            validAnchors.append("Clave de Elector")
            tableContent.append("Clave de Elector")
        }
        if objectOCRINE?.anchorcurp != ""{
            validAnchors.append("CURP")
            tableContent.append("CURP")
        }
        if objectOCRINE?.anchorestado != ""{
            validAnchors.append("Estado")
            tableContent.append("Estado")
        }
        if objectOCRINE?.anchorlocalidad != ""{
            validAnchors.append("Localidad")
            tableContent.append("Localidad")
        }
        if objectOCRINE?.anchorfolio != ""{
            validAnchors.append("Folio")
            tableContent.append("Folio")
        }
        if objectOCRINE?.anchormunicipio != ""{
            validAnchors.append("Municipio")
            tableContent.append("Municipio")
        }
        if objectOCRINE?.anchorsexo != ""{
            validAnchors.append("Sexo")
            tableContent.append("Sexo")
        }
        if objectOCRINE?.anchorseccion != ""{
            validAnchors.append("Sección")
            tableContent.append("Sección")
        }
        if objectOCRINE?.anchorregistro != ""{
            validAnchors.append("Registro")
            tableContent.append("Registro")
        }
        if objectOCRINE?.anchorvigencia != ""{
            validAnchors.append("Vigencia")
            tableContent.append("Vigencia")
        }
        if objectOCRINE?.anchorcic != ""{
            validAnchors.append("CIC")
            tableContent.append("CIC")
            validAnchors.append("OCR")
            tableContent.append("OCR")
        }
        if objectOCRINE?.anchoremision != ""{
            validAnchors.append("Emision")
            tableContent.append("Emision")
        }
    }
    
    func setObjectAgua(){
        validAnchors = [String]()
        tableContent = [String]()
        
    }
    
    func setObjectCfe(){
        validAnchors = [String]()
        tableContent = [String]()
        if objectOCRCfe?.anchornombre != ""{
            validAnchors.append("Nombre y Domicilio")
            tableContent.append("Nombre")
            tableContent.append("Calle")
            tableContent.append("Colonia")
            tableContent.append("Delegación")
            tableContent.append("C.P.")
            tableContent.append("Ciudad/Estado")
        }
    }
    
    func setObjectPasaporte(){
        validAnchors = [String]()
        tableContent = [String]()
        if objectOCRPasaporte?.anchorclavedelpais != ""{
            validAnchors.append("Clave del país de expedición")
            tableContent.append("Clave del país de expedición")
        }
        if objectOCRPasaporte?.anchorpasaportenumero != ""{
            validAnchors.append("Pasaporte No.")
            tableContent.append("Pasaporte No.")
        }
        if objectOCRPasaporte?.anchoraPaterno != ""{
            validAnchors.append("Apellido Paterno")
            tableContent.append("Apellido Paterno")
        }
        if objectOCRPasaporte?.anchoraMaterno != ""{
            validAnchors.append("Apellido Materno")
            tableContent.append("Apellido Materno")
        }
        if objectOCRPasaporte?.anchornombres != ""{
            validAnchors.append("Nombres")
            tableContent.append("Nombres")
        }
        if objectOCRPasaporte?.anchornacionalidad != ""{
            validAnchors.append("Nacionalidad")
            tableContent.append("Nacionalidad")
        }
        if objectOCRPasaporte?.anchorfechanacimiento != ""{
            validAnchors.append("Fecha de nacimiento")
            tableContent.append("Fecha de nacimiento")
        }
        if objectOCRPasaporte?.anchorcurp != ""{
            validAnchors.append("CURP")
            tableContent.append("CURP")
        }
        if objectOCRPasaporte?.anchorsexo != ""{
            validAnchors.append("Sexo")
            tableContent.append("Sexo")
        }
        if objectOCRPasaporte?.anchorlugarnacimiento != ""{
            validAnchors.append("Lugar de nacimiento")
            tableContent.append("Lugar de nacimiento")
        }
        if objectOCRPasaporte?.anchorfechaexpedicion != ""{
            validAnchors.append("Fecha de expedición")
            tableContent.append("Fecha de expedición")
        }
        if objectOCRPasaporte?.anchorfechacaducidad != ""{
            validAnchors.append("Fecha de caducidad")
            tableContent.append("Fecha de caducidad")
        }
    }
    
    func setObjectVisa(){
        validAnchors = [String]()
        tableContent = [String]()
        
        if objectOCRVisa?.anchorvisa != ""{
            validAnchors.append("Visa Class")
            tableContent.append("Visa Class")
            tableContent.append("Visa Type")
        }
        if objectOCRVisa?.anchorsurname != ""{
            validAnchors.append("Surname")
            tableContent.append("Surname")
        }
        if objectOCRVisa?.anchorgivennames != ""{
            validAnchors.append("Given Names")
            tableContent.append("Given Names")
        }
        if objectOCRVisa?.anchordatebirth != ""{
            validAnchors.append("Date of Birth")
            tableContent.append("Date of Birth")
        }
        if objectOCRVisa?.anchornationality != ""{
            validAnchors.append("Nationality")
            tableContent.append("Nationality")
        }
        if objectOCRVisa?.anchorsex != ""{
            validAnchors.append("Sex")
            tableContent.append("Sex")
        }
        if objectOCRVisa?.anchordateissue != ""{
            validAnchors.append("Date of Issue")
            tableContent.append("Date of Issue")
        }
        if objectOCRVisa?.anchorexpireson != ""{
            validAnchors.append("Expires On")
            tableContent.append("Expires On")
        }
        if objectOCRVisa?.anchorequivalencevalue != ""{
            validAnchors.append("Equivalence Value")
            tableContent.append("Equivalence Value")
        }
        if objectOCRVisa?.anchordocumenttype != ""{
            validAnchors.append("Document Type")
            tableContent.append("Document Type")
        }
        if objectOCRVisa?.anchorcountryissuance != ""{
            validAnchors.append("Country of Issuance")
            tableContent.append("Country of Issuance")
        }
        if objectOCRVisa?.anchordocumentnumber != ""{
            validAnchors.append("Document Number")
            tableContent.append("Document Number")
        }
        if objectOCRVisa?.anchorinventorycontrolnumber != ""{
            validAnchors.append("Inventory Control Number")
            tableContent.append("Inventory Control Number")
        }
    }
    
}
