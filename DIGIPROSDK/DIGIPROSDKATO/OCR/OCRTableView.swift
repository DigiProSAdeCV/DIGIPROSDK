import Foundation

extension OCRVC: UITableViewDataSource, UITableViewDelegate{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContent.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        // 1 INE/IFE
        // 2 AGUA
        // 3 CFE
        // 4 Pasaporte
        // 5 VISA
        
        switch self.serviceId {
        case 1:
            switch tableContent[indexPath.row] {
            case "Nombre": cell.detailTextLabel?.text = "\(self.objectOCRINE?.nombre ?? "")"; break
            case "Apellido Paterno": cell.detailTextLabel?.text = "\(self.objectOCRINE?.aPaterno ?? "")"; break
            case "Apellido Materno": cell.detailTextLabel?.text = "\(self.objectOCRINE?.aMaterno ?? "")"; break
            case "Calle": cell.detailTextLabel?.text = "\(self.objectOCRINE?.calle ?? "")"; break
            case "Colonia": cell.detailTextLabel?.text = "\(self.objectOCRINE?.colonia ?? "")"; break
            case "Delegación": cell.detailTextLabel?.text = "\(self.objectOCRINE?.delegacion ?? "")"; break
            case "C.P.": cell.detailTextLabel?.text = "\(self.objectOCRINE?.cP ?? "")"; break
            case "Ciudad/Estado": cell.detailTextLabel?.text = "\(self.objectOCRINE?.estado ?? "")"; break
            case "Municipio": cell.detailTextLabel?.text = "\(self.objectOCRINE?.municipio ?? "")"; break
            case "Clave de Elector": cell.detailTextLabel?.text = "\(self.objectOCRINE?.claveElector ?? "")"; break
            case "CURP": cell.detailTextLabel?.text = "\(self.objectOCRINE?.curp ?? "")"; break
            case "Estado": cell.detailTextLabel?.text = "\(self.objectOCRINE?.estado ?? "")"; break
            case "Localidad": cell.detailTextLabel?.text = "\(self.objectOCRINE?.localidad ?? "")"; break
            case "Folio": cell.detailTextLabel?.text = "\(self.objectOCRINE?.folio ?? "")"; break
            case "Registro": cell.detailTextLabel?.text = "\(self.objectOCRINE?.registro ?? "")"; break
            case "Sexo": cell.detailTextLabel?.text = "\(self.objectOCRINE?.sexo ?? "")"; break
            case "Sección": cell.detailTextLabel?.text = "\(self.objectOCRINE?.seccion ?? "")"; break
            case "Vigencia": cell.detailTextLabel?.text = "\(self.objectOCRINE?.vigencia ?? "")"; break
            case "CIC": cell.detailTextLabel?.text = "\(self.objectOCRINE?.cic ?? "")"; break
            case "Emision": cell.detailTextLabel?.text = "\(self.objectOCRINE?.emision ?? "")"; break
            case "OCR": cell.detailTextLabel?.text = "\(self.objectOCRINE?.ocr ?? "")"; break
            case "Fecha de Nacimiento": cell.detailTextLabel?.text = "\(self.objectOCRINE?.fecha ?? "")"; break
            default: cell.textLabel?.text = ""; cell.detailTextLabel?.text = ""; break; }
            break
        case 2:

            break
        case 3:
            switch tableContent[indexPath.row] {
            case "Nombre": cell.detailTextLabel?.text = "\(self.objectOCRCfe?.nombre ?? "")"; break
            case "Calle": cell.detailTextLabel?.text = "\(self.objectOCRCfe?.calle ?? "")"; break
            case "Colonia": cell.detailTextLabel?.text = "\(self.objectOCRCfe?.colonia ?? "")"; break
            case "Delegación": cell.detailTextLabel?.text = "\(self.objectOCRCfe?.delegacion ?? "")"; break
            case "C.P.": cell.detailTextLabel?.text = "\(self.objectOCRCfe?.cP ?? "")"; break
            case "Ciudad/Estado": cell.detailTextLabel?.text = "\(self.objectOCRCfe?.ciudad ?? "")"; break
            default: cell.textLabel?.text = ""; cell.detailTextLabel?.text = ""; break; }
            break
        case 4:
            
            switch tableContent[indexPath.row] {
            case "Clave del país de expedición": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.clavedelpais ?? "")"; break;
            case "Pasaporte No.": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.pasaportenumero ?? "")"; break;
            case "Apellido Paterno": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.aPaterno ?? "")"; break;
            case "Apellido Materno": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.aMaterno ?? "")"; break;
            case "Nombres": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.nombres ?? "")"; break;
            case "Nacionalidad": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.nacionalidad ?? "")"; break;
            case "Fecha de nacimiento": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.fechanacimiento ?? "")"; break;
            case "CURP": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.curp ?? "")"; break;
            case "Sexo": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.sexo ?? "")"; break;
            case "Lugar de nacimiento": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.lugarnacimiento ?? "")"; break;
            case "Fecha de expedición": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.fechaexpedicion ?? "")"; break;
            case "Fecha de caducidad": cell.detailTextLabel?.text = "\(self.objectOCRPasaporte?.fechacaducidad ?? "")"; break;
            default: cell.textLabel?.text = ""; cell.detailTextLabel?.text = ""; break; }
            break
        case 5:
            switch tableContent[indexPath.row] {
            case "Visa Class": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.visaClass ?? "")"; break
            case "Visa Type": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.visaType ?? "")"; break
            case "Surname": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.apellidos ?? "")"; break
            case "Given Names": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.nombre ?? "")"; break
            case "Date of Birth": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.fecha ?? "")"; break
            case "Nationality": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.nacionalidad ?? "")"; break
            case "Sex": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.sexo ?? "")"; break
            case "Date of Issue": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.dateIssue ?? "")"; break
            case "Expires On": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.expiresOn ?? "")"; break
            case "Equivalence Value": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.equivalenceValue ?? "")"; break
                
            case "Document Type": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.documentType ?? "")"; break
            case "Country of Issuance": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.countryIssuance ?? "")"; break
            case "Document Number": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.documentNumber ?? "")"; break
            case "Inventory Control Number": cell.detailTextLabel?.text = "\(self.objectOCRVisa?.inventoryControlNumber ?? "")"; break
            default: cell.textLabel?.text = ""; cell.detailTextLabel?.text = ""; break; }
            break
        default:
            break
        }
        
        cell.textLabel?.text = "\(tableContent[indexPath.row])"
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.isHidden = false
        return cell
    }
    
}
