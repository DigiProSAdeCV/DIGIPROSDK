import Foundation

extension OCRVC{
    
    @objc func settingResults(){
        
        if (validAnchors.isEmpty || validAnchors.count <= 0) && self.isImageDetected {
            self.guardarAction(self)
        }
        if validAnchors.isEmpty || validAnchors.count <= 0{ return }
        
        // 1 INE/IFE
        // 2 AGUA
        // 3 CFE
        // 4 Pasaporte
        // 5 VISA
        
        switch serviceId {
        case 1:
            switch validAnchors[0]{
            case "Nombre": if (objectOCRINE?.detectednombre)!{ let location = validAnchors.firstIndex(of: "Nombre"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Domicilio": if (objectOCRINE?.detecteddomicilio)!{ let location = validAnchors.firstIndex(of: "Domicilio"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Clave de Elector": if (objectOCRINE?.detectedclaveelector)!{ let location = validAnchors.firstIndex(of: "Clave de Elector"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "CURP": if (objectOCRINE?.detectedcurp)!{ let location = validAnchors.firstIndex(of: "CURP"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Estado": if (objectOCRINE?.detectedestado)!{ let location = validAnchors.firstIndex(of: "Estado"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Localidad": if (objectOCRINE?.detectedlocalidad)!{ let location = validAnchors.firstIndex(of: "Localidad"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Folio": if (objectOCRINE?.detectedfolio)!{ let location = validAnchors.firstIndex(of: "Folio"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Municipio": if (objectOCRINE?.detectedmunicipio)!{ let location = validAnchors.firstIndex(of: "Municipio"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Sexo": if (objectOCRINE?.detectedsexo)!{ let location = validAnchors.firstIndex(of: "Sexo"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Sección": if (objectOCRINE?.detectedseccion)!{ let location = validAnchors.firstIndex(of: "Sección"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Registro": if (objectOCRINE?.detectedregistro)!{ let location = validAnchors.firstIndex(of: "Registro"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Vigencia": if (objectOCRINE?.detectedvigencia)!{ let location = validAnchors.firstIndex(of: "Vigencia"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Emision": if (objectOCRINE?.detectedemision)!{ let location = validAnchors.firstIndex(of: "Emision"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "CIC": if (objectOCRINE?.detectedcic)!{ let location = validAnchors.firstIndex(of: "CIC"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "OCR": if (objectOCRINE?.detectedocr)!{ let location = validAnchors.firstIndex(of: "OCR"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            default: break
            }
            tableView.reloadData()
            if (validAnchors.isEmpty || validAnchors.count <= 0) && self.isImageDetected { self.guardarAction(self) }
            if validAnchors.isEmpty || validAnchors.count <= 0{ return }
            if validAnchors[0] == "CIC" || validAnchors[0] == "OCR"{ frontImage.alpha = CGFloat(0.5); backImage.alpha = CGFloat(1); isReverso = true }
            break
        case 2:
            
            
            break
        case 3:
            switch validAnchors[0]{
            case "Nombre y Domicilio": if (objectOCRCfe?.detectednombre)!{ let location = validAnchors.firstIndex(of: "Nombre y Domicilio"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            default: break
            }
            tableView.reloadData()
            if (validAnchors.isEmpty || validAnchors.count <= 0) && self.isImageDetected { self.guardarAction(self) }
            if validAnchors.isEmpty || validAnchors.count <= 0{ return }
            break
        case 4:
            switch validAnchors[0]{
            case "Clave del país de expedición": if (objectOCRPasaporte?.detectedclavedelpais)!{ let location = validAnchors.firstIndex(of: "Clave del país de expedición"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            case "Pasaporte No.": if (objectOCRPasaporte?.detectedpasaportenumero)!{ let location = validAnchors.firstIndex(of: "Pasaporte No."); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            case "Apellido Paterno": if (objectOCRPasaporte?.detectedaPaterno)!{ let location = validAnchors.firstIndex(of: "Apellido Paterno"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            case "Apellido Materno": if (objectOCRPasaporte?.detectedaMaterno)!{ let location = validAnchors.firstIndex(of: "Apellido Materno"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            case "Nombres": if (objectOCRPasaporte?.detectednombres)!{ let location = validAnchors.firstIndex(of: "Nombres"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            case "Nacionalidad": if (objectOCRPasaporte?.detectednacionalidad)!{ let location = validAnchors.firstIndex(of: "Nacionalidad"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Fecha de nacimiento": if (objectOCRPasaporte?.detectedfechanacimiento)!{ let location = validAnchors.firstIndex(of: "Fecha de nacimiento"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            case "CURP": if (objectOCRPasaporte?.detectedcurp)!{ let location = validAnchors.firstIndex(of: "CURP"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            case "Sexo": if (objectOCRPasaporte?.detectedsexo)!{ let location = validAnchors.firstIndex(of: "Sexo"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            case "Lugar de nacimiento": if (objectOCRPasaporte?.detectedlugarnacimiento)!{ let location = validAnchors.firstIndex(of: "Lugar de nacimiento"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            case "Fecha de expedición": if (objectOCRPasaporte?.detectedfechanacimiento)!{ let location = validAnchors.firstIndex(of: "Fecha de expedición"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            case "Fecha de caducidad": if (objectOCRPasaporte?.detectedfechacaducidad)!{ let location = validAnchors.firstIndex(of: "Fecha de caducidad"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break;
            default: break
            }
            tableView.reloadData()
            if (validAnchors.isEmpty || validAnchors.count <= 0) { self.guardarAction(self) }
            if validAnchors.isEmpty || validAnchors.count <= 0{ return }
            break
        case 5:
            switch validAnchors[0]{
            case "Visa Class": if (objectOCRVisa?.detectedvisa)!{ let location = validAnchors.firstIndex(of: "Visa Class"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Surname": if (objectOCRVisa?.detectedsurname)!{ let location = validAnchors.firstIndex(of: "Surname"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Given Names": if (objectOCRVisa?.detectedgivennames)!{ let location = validAnchors.firstIndex(of: "Given Names"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Date of Birth": if (objectOCRVisa?.detecteddatebirth)!{ let location = validAnchors.firstIndex(of: "Date of Birth"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Nationality": if (objectOCRVisa?.detectednationality)!{ let location = validAnchors.firstIndex(of: "Nationality"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Sex": if (objectOCRVisa?.detectedsex)!{ let location = validAnchors.firstIndex(of: "Sex"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Date of Issue": if (objectOCRVisa?.detecteddateissue)!{ let location = validAnchors.firstIndex(of: "Date of Issue"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Expires On": if (objectOCRVisa?.detectedexpireson)!{ let location = validAnchors.firstIndex(of: "Expires On"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Equivalence Value": if (objectOCRVisa?.detectedequivalencevalue)!{ let location = validAnchors.firstIndex(of: "Equivalence Value"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Document Type": if (objectOCRVisa?.detecteddocumenttype)!{ let location = validAnchors.firstIndex(of: "Document Type"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Country of Issuance": if (objectOCRVisa?.detectedcountryissuance)!{ let location = validAnchors.firstIndex(of: "Country of Issuance"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Document Number": if (objectOCRVisa?.detecteddocumentnumber)!{ let location = validAnchors.firstIndex(of: "Document Number"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            case "Inventory Control Number": if (objectOCRVisa?.detectedinventorycontrolnumber)!{ let location = validAnchors.firstIndex(of: "Inventory Control Number"); validAnchors.remove(at: location!); self.tableView.reloadData() }; break
            default: break
            }
            tableView.reloadData()
            if (validAnchors.isEmpty || validAnchors.count <= 0) && self.isImageDetected { self.guardarAction(self) }
            if validAnchors.isEmpty || validAnchors.count <= 0{ return }
            if validAnchors[0] == "Document Type" || validAnchors[0] == "Country of Issuance"{ frontImage.alpha = CGFloat(0.5); backImage.alpha = CGFloat(1); isReverso = true }
            break
        default:
            break
        }
        
        
        
    }
    
}
