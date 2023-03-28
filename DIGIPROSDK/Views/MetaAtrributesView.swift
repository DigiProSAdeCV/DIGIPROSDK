import Foundation
import UIKit

public class MetaDataTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet public weak var lblRequeridoMD: UILabel!
    @IBOutlet public weak var lblNameMD: UILabel!
    @IBOutlet public weak var textFieldMD: UITextField!
    @IBOutlet public weak var boolMD: UIButton!
    @IBOutlet public weak var listMD: UIButton!
    public static let identifier = "MDCELL"
    public var maxLongMeta: Int = 0
    public var minLongMeta: Int = 0
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.lblNameMD.text = ""
        self.textFieldMD.text = ""
        self.textFieldMD.placeholder = ""
        self.textFieldMD.textColor = .black
        self.listMD.setTitle(" Seleccione...      ", for: .normal)
        self.listMD.setImage(UIImage(named: "ic_arrowDown", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        self.boolMD.setImage(UIImage(named: "ic_uncheck", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
    }
    public override func setSelected(_ selected: Bool, animated: Bool) { super.setSelected(selected, animated: animated) }
}

public class MetaAttributesViewController: UIViewController, UITextFieldDelegate{
    
    public var metaDataTableView: UITableView = {
        
        return UITableView()
    }()
    public var metaBtnCancel: UIButton = {
        
        return UIButton()
    }()
    public var metaBtnGuardar: UIButton = {
            
        return UIButton()
    }()
    public var documentType: UIPickerView = {
            
        return UIPickerView()
    }()
    public var lblTipoDoc: UILabel = {
            
        return UILabel()
    }()
    
    public var docID: Int = 0
    public var arrayMetadatos: [FEListMetadatosHijos] = []
    public var listAllowed: [FEListTipoDoc] = []
    public var fedocumento: FEDocumento = FEDocumento()
    public var feanexo: FEAnexoData = FEAnexoData()
    public var delegate: MetaFormDelegate?
    var listaInMeta = false
    var dataListaInMeta : Array<FEItemCatalogo> = [FEItemCatalogo]()
    var indextableview: Int = 0 // bnd index campo en View Metadatos
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.addViews()
        self.setConstraints()
        self.setLayout()
        self.setFunctions()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func triggerClose(_ sender: UIButton){
        delegate?.didClose()
    }
    
    @objc func triggerSave(_ sender: UIButton){
        delegate?.didSave()
    }
    
    func addViews(){
        self.view.addSubview(metaDataTableView)
        self.view.addSubview(metaBtnCancel)
        self.view.addSubview(metaBtnGuardar)
        self.view.addSubview(documentType)
        self.view.addSubview(lblTipoDoc)
    }
    func setFunctions(){
        metaBtnCancel.addTarget(self, action: #selector(triggerClose(_:)), for: .touchUpInside)
        metaBtnGuardar.addTarget(self, action: #selector(triggerSave(_:)), for: .touchUpInside)
    }
    func setLayout(){
        self.view.backgroundColor = UIColor(hexFromString: "#222222", alpha: 0.8) //"#444444"
        
        let nibMD = UINib(nibName: "KHFSnImyzOBlprQ", bundle: Cnstnt.Path.framework)
        self.metaDataTableView.register(nibMD, forCellReuseIdentifier: MetaDataTableViewCell.identifier)
        self.metaDataTableView.layer.cornerRadius = 6.0
        self.metaDataTableView.layer.borderWidth = 1.0
        self.metaDataTableView.dataSource = self
        self.metaDataTableView.delegate = self
        
        self.metaBtnCancel.backgroundColor = Cnstnt.Color.red
        self.metaBtnCancel.layer.cornerRadius = 20
        self.metaBtnCancel.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        self.metaBtnGuardar.setImage(UIImage(named: "baseline_done_black_24pt", in: Cnstnt.Path.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.metaBtnGuardar.tintColor = .white
        
        self.metaBtnGuardar.backgroundColor = Cnstnt.Color.green
        
        self.lblTipoDoc.text = ""
        self.lblTipoDoc.textAlignment = .left
        self.lblTipoDoc.lineBreakMode = .byWordWrapping
        self.lblTipoDoc.numberOfLines = 0
        self.lblTipoDoc.textColor = Cnstnt.Color.whitelight
        
        self.documentType.isHidden = true
        self.documentType.dataSource = self
        self.documentType.delegate = self
        self.documentType.layer.cornerRadius = 5
        self.documentType.backgroundColor = .white
    }
    func setConstraints(){
        self.metaDataTableView.translatesAutoresizingMaskIntoConstraints = false
        self.metaBtnCancel.translatesAutoresizingMaskIntoConstraints = false
        self.metaBtnGuardar.translatesAutoresizingMaskIntoConstraints = false
        self.documentType.translatesAutoresizingMaskIntoConstraints = false
        self.lblTipoDoc.translatesAutoresizingMaskIntoConstraints = false
        
        metaBtnCancel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        metaBtnCancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        metaBtnCancel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5).isActive = true
        metaBtnCancel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = false
        metaBtnCancel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -5).isActive = true
        metaBtnCancel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = false
        
        lblTipoDoc.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5).isActive = true
        lblTipoDoc.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 15).isActive = true
        lblTipoDoc.rightAnchor.constraint(equalTo: self.metaBtnCancel.leftAnchor, constant: -15).isActive = true
        lblTipoDoc.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = false
        
        metaDataTableView.topAnchor.constraint(equalTo: self.lblTipoDoc.bottomAnchor, constant: 5).isActive = true
        metaDataTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        metaDataTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        metaDataTableView.bottomAnchor.constraint(equalTo: self.metaBtnGuardar.topAnchor, constant: -5).isActive = true
        
        metaBtnGuardar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = false
        metaBtnGuardar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        metaBtnGuardar.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = false
        metaBtnGuardar.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = false
        metaBtnGuardar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5).isActive = true
        metaBtnGuardar.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        
        documentType.topAnchor.constraint(equalTo: self.lblTipoDoc.bottomAnchor, constant: 5).isActive = true
        documentType.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        documentType.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        documentType.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5).isActive = true
        documentType.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        documentType.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, multiplier: 0).isActive = true

    }
    
}

extension MetaAttributesViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { if ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc.count == 0{ return 0 }else{ return listAllowed.count + 1 } }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { if row == 0{ return "rules_select".langlocalized() }else{ return listAllowed[row - 1].Descripcion } }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0{ return }
        self.documentType.isHidden = true
        let desc = listAllowed[row - 1].Descripcion
        let id = listAllowed[row - 1].CatalogoId
        
        for list in self.listAllowed{
            if list.CatalogoId != id{ continue }
            self.fedocumento.TipoDocID = id
            self.fedocumento.TipoDoc = desc
            self.docID = id
            list.current = 1
            break
        }
        
        self.metaDataTableView.reloadData()
        delegate?.didUpdateData(self.fedocumento.TipoDoc, self.fedocumento.TipoDocID ?? 0)
        delegate?.savingData();
        delegate?.didClose()
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font =  UIFont(name: ConfigurationManager.shared.fontApp, size: 16.0)
            pickerLabel?.textAlignment = .center
        }
        if row == 0{ pickerLabel?.text = "rules_select".langlocalized() }else{ pickerLabel?.text = listAllowed[row - 1].Descripcion }
        return pickerLabel!
    }
}

extension MetaAttributesViewController: UITableViewDelegate, UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayMetadatos.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = metaDataTableView.dequeueReusableCell(withIdentifier: "MDCELL", for: indexPath) as! MetaDataTableViewCell
        
        let obj = self.arrayMetadatos.isEmpty ? FEListMetadatosHijos() : self.arrayMetadatos[indexPath.row]
        
        cell.lblRequeridoMD.isHidden = !obj.Obligatorio
        cell.textFieldMD.tag = indexPath.row
        cell.textFieldMD.delegate = self
        cell.textFieldMD.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if self.docID == obj.TipoDoc{
            var objMeta = FEListMetadatosHijos()
            if self.fedocumento != FEDocumento() {
                objMeta = self.fedocumento.Metadatos.first(where: {$0.Nombre == obj.Nombre}) ?? objMeta
            }
            if objMeta.NombreCampo != "" { cell.textFieldMD.text = objMeta.NombreCampo }
            cell.lblNameMD.text = obj.Nombre
            cell.textFieldMD.placeholder = obj.Mascara
            cell.textFieldMD.keyboardType = .emailAddress
            cell.textFieldMD.textColor = .black
            if obj.TipoDato.contains("datetime") || obj.TipoDato.contains("DD/MM/AAAA") || obj.TipoDato.contains("AAAA/MM/DD") || obj.TipoDato.contains("DD-MM-AAAA") || obj.TipoDato.contains("AAAA-MM-DD") {
                cell.textFieldMD.addTarget(self, action: #selector(showDatePicker(_:)), for: .editingDidBegin)
                cell.textFieldMD.isEnabled = obj.EsEditable
                cell.boolMD.isHidden = true
                cell.listMD.isHidden = true
                return cell
            }else if obj.TipoDato.contains("Catalogo"){
                cell.textFieldMD.placeholder = ""
                cell.textFieldMD.textColor = .white
                cell.boolMD.isHidden = true
                cell.listMD.isHidden = false
                cell.listMD.tag = indexPath.row
                cell.listMD.addTarget(self, action: #selector(showListAction(_:)), for: .touchUpInside)
                if objMeta.NombreCampo != "" {
                    if objMeta.NombreCampo.split(separator: "|").count == 3 {
                        let _Desc = String(objMeta.NombreCampo.split(separator: "|").last ?? "")
                        cell.listMD.setTitle(_Desc, for: .normal)
                    }
                }
                cell.listMD.isEnabled = obj.EsEditable
                return cell
            }else if obj.TipoDato.contains("Money"){
                cell.textFieldMD.keyboardType = .numberPad
                cell.boolMD.isHidden = true
                cell.listMD.isHidden = true
                cell.textFieldMD.isEnabled = obj.EsEditable
                cell.maxLongMeta = obj.Longitud_Maxima
                cell.minLongMeta = obj.Longitud_Minima
                return cell
            }else if obj.TipoDato.contains("Int") || obj.TipoDato.contains("bigint") || obj.TipoDato.contains("Tinyint"){
                cell.textFieldMD.keyboardType = .numberPad
                cell.boolMD.isHidden = true
                cell.listMD.isHidden = true
                cell.textFieldMD.isEnabled = obj.EsEditable
                cell.maxLongMeta = obj.Longitud_Maxima
                cell.minLongMeta = obj.Longitud_Minima
                return cell
            }else if obj.TipoDato.contains("bit"){
                cell.textFieldMD.placeholder = ""
                cell.textFieldMD.textColor = .white
                cell.textFieldMD.isEnabled = false
                cell.listMD.isHidden = true
                cell.boolMD.isHidden = false
                cell.boolMD.setTitle("false", for: []);
                cell.boolMD.tag = indexPath.row
                cell.boolMD.addTarget(self, action: #selector(checkAction), for: .touchUpInside)
                if objMeta.NombreCampo != "" && objMeta.NombreCampo == "true"{
                    cell.boolMD.setTitle("true", for: []);
                    cell.boolMD.setImage(UIImage(named: "ic_check_c", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
                }
                cell.boolMD.isEnabled = obj.EsEditable
                return cell
            }else{
                cell.boolMD.isHidden = true
                cell.listMD.isHidden = true
                cell.textFieldMD.isEnabled = obj.EsEditable
                cell.maxLongMeta = obj.Longitud_Maxima
                cell.minLongMeta = obj.Longitud_Minima
                return cell
            }
            
        }
        return cell
        
        
        
        for meta in self.arrayMetadatos{
            if self.docID == meta.TipoDoc{
                cell.lblNameMD.text = meta.Nombre
                cell.textFieldMD.placeholder = meta.Mascara
            }else{
                cell.lblNameMD.text = ""
                cell.textFieldMD.placeholder = ""
            }
        }
        return cell
    }
    
    /*public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0//35.0
    }*/
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.indextableview = textField.tag
        self.metaDataTableView.selectRow(at: IndexPath(row: textField.tag, section: 0), animated: true, scrollPosition: .middle)
        //maxLogMeta - minLogMeta
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let cell = metaDataTableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as! MetaDataTableViewCell
        if cell.minLongMeta != 0{
            if (textField.text?.count)! < (cell.minLongMeta){
                print("No cumple el minimo")
            }
        }
    }
    
    @objc open func textFieldDidChange(_ textField: UITextField) {
        guard let _ = textField.text else { return }
        let cell = metaDataTableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as! MetaDataTableViewCell
        if cell.maxLongMeta != 0{
            if (textField.text?.count)! > (cell.maxLongMeta){
                textField.text = textField.text!.substring(to: cell.maxLongMeta )
            }
        }
    }
    
    // muestra la lista
    @objc func showListAction(_ sender: UIButton) {
        
        let obj = self.arrayMetadatos[sender.tag]
        let catalogos = ConfigurationManager.shared.utilities.getCatalogoInLibrary(obj.Accion.replacingOccurrences(of: "Web_BuscaCatalogo ", with: ""))
        if catalogos?.Catalogo.count ?? 0 > 0{
            for catalogo in catalogos!.Catalogo {
                self.dataListaInMeta.append(catalogo)
            }
            self.listaInMeta = true
            self.indextableview = sender.tag
            self.documentType.reloadComponent(0)
            self.documentType.selectRow(0, inComponent: 0, animated: false)
            self.documentType.isHidden = false
            self.metaDataTableView.isHidden = true
            self.metaBtnGuardar.isHidden = true
            //self.metaBtnRedo.isHidden = true
        }
    }
    
    @objc func checkAction(sender: UIButton) {
        if sender.titleLabel?.text == "false" {
            sender.setTitle("true", for: [])
            sender.setImage(UIImage(named: "ic_check_c", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        } else if sender.titleLabel?.text == "true" {
            sender.setTitle("false", for: [])
            sender.setImage(UIImage(named: "ic_uncheck", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        }
    }
    
    @objc func showDatePicker(_ sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        sender.text = formatDate(tag: sender.tag, date: Date())
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        sender.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(_ sender:UIDatePicker) {
        let cell = self.metaDataTableView.cellForRow(at:IndexPath(row: self.indextableview, section: 0)) as! MetaDataTableViewCell
        let date = formatDate(tag: nil, date: sender.date)
        cell.textFieldMD.text = date
    }
    
    func formatDate(tag: Int?, date: Date) -> String {
        
        let index: Int
        if let tag = tag {
            index = tag
        } else {
            index = self.indextableview
        }
        
        let obj = self.arrayMetadatos[index]
        var formatt = obj.TipoDato.replacingOccurrences(of: " ", with: "")
        formatt = formatt.replacingOccurrences(of: "DD", with: "dd")
        formatt = formatt.replacingOccurrences(of: "AAAA", with: "yyyy")
        let dateFormatter = DateFormatter()
        if formatt == "datetime" {
            dateFormatter.dateStyle = DateFormatter.Style.medium
        } else {
            formatt = formatt.replacingOccurrences(of: "datetime", with: "")
            dateFormatter.dateFormat = formatt
        }
        
        return dateFormatter.string(from: date)
    }
}
