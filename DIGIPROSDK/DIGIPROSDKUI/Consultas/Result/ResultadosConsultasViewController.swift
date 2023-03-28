import Foundation
import UIKit


public class ResultadosConsultasDataCell: UITableViewCell{
    @IBOutlet weak var innerVw: UIView!
}

public class ResultadosConsultasViewController: UIViewController, APIDelegate, UITextFieldDelegate{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var buttonPag: UIButton!
    
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    
    public var json = ""
    public var reporte: FETipoReporte?
    public var consulta: FEConsultaTemplate?
    public var dictionary: [[(key: String, value: Any)]]?
    public var backupDictionary: [[(key: String, value: Any)]]?
    public var filteredDictionary: [[(key: String, value: Any)]]?
    public var filters: [String] = [String]()
    public var paginations: [String] = [String]()
    public var isSearching = false
    public var globalFilter: String = ""
    
    let odd = UIColor(hexFromString: "#f9f9f9", alpha: 1.0)
    let even = UIColor(hexFromString: "#d3d3d3", alpha: 1.0)
    
    var pickerFilter: UIPickerView = UIPickerView()
    var pickerPagination: UIPickerView = UIPickerView()
    var device: Device?
    
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var backButton: UIButton!
    
    @IBOutlet weak var srchbar: UISearchBar!
    
    var sdkAPI = APIManager<ResultadosConsultasViewController>()

    @IBOutlet weak var tblView: PagingTableView!
    @IBOutlet weak var btnFiltros: UIButton!
    @IBOutlet weak var btnPaginacion: UIButton!
    
    @IBOutlet weak var lblCounter: UILabel!
    
    @IBAction func btnActionFiltros(_ sender: Any) {
        self.pickerFilter.isHidden = false
    }
    
    @IBAction func btnActionPaginacion(_ sender: Any) {
        self.pickerPagination.isHidden = false
    }
    
    @IBAction func backAction(_ sender: UIButton) {
       self.navigationController?.popViewController(animated: true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        changeIconBack()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.titleLabel.text = "cnslvw_lbl_title_detail".langlocalized()
        self.btnPaginacion.setTitle("cnslvw_btn_pagination".langlocalized(), for: .normal)
        self.buttonLabel.text = "cnslvw_btn_filter".langlocalized()
        
        if ConfigurationManager.shared.isConsubanco{ btnPaginacion.isHidden = true }
        
        device = Device()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        sdkAPI.delegate = self
        paginations = ["10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]
        dictionary = convertToDictionary(text: (consulta?.JsonConsulta)!)
        backupDictionary = dictionary
        self.tblView.pagingDelegate = self
        self.tblView.register(UINib(nibName: "pRSpmYGgOEVXGSS", bundle: Cnstnt.Path.framework), forCellReuseIdentifier: "Cell")
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.estimatedRowHeight = 200
        
        let currentCount = dictionary?.count
        let finalCount = consulta?.TotalRegistros
        lblCounter.text = String(format: "cnslvw_lbl_counter".langlocalized(), String(currentCount ?? 0), String(finalCount ?? 0))

        self.buttonLabel.layer.cornerRadius = 10.0
        self.pickerFilter.isHidden = true
        self.pickerFilter.dataSource = self
        self.pickerFilter.delegate = self
        self.pickerFilter.frame = CGRect(x:40, y: 65, width: 305, height: 160)
        self.pickerFilter.backgroundColor = Cnstnt.Color.blue
        self.pickerFilter.layer.cornerRadius = 5
        self.pickerFilter.layer.borderWidth = 2
        self.pickerFilter.layer.borderColor = UIColor.white.cgColor
        self.view.addSubview(pickerFilter)
        
        self.pickerPagination.isHidden = true
        self.pickerPagination.dataSource = self
        self.pickerPagination.delegate = self
        self.pickerPagination.frame = CGRect(x:40, y: 65, width: 305, height: 160)
        self.pickerPagination.backgroundColor = Cnstnt.Color.blue
        self.pickerPagination.layer.cornerRadius = 5
        self.pickerPagination.layer.borderWidth = 2
        self.pickerPagination.layer.borderColor = UIColor.white.cgColor
        
        self.view.addSubview(pickerPagination)
        
        for keys in backupDictionary![0]{
            filters.append(keys.key)
        }
        
        self.buttonPag.backgroundColor = .clear
        self.buttonPag.layer.cornerRadius = 5.0
        self.buttonPag.layer.borderWidth = 1.0
        self.buttonPag.layer.borderColor = Cnstnt.Color.blue.cgColor
        
        self.backButton.setImage(UIImage(named: "ic_back_blue", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismisspicker (_:)))
        self.containerView.addGestureRecognizer(tapGesture)
        self.tblView.addGestureRecognizer(tapGesture)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func dismisspicker (_ sender: UITapGestureRecognizer) {
        self.pickerPagination.isHidden = true
        self.pickerFilter.isHidden = true
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.srchbar.resignFirstResponder()
    }
    
    func convertToDictionary(text: String) -> [[(key: String, value: Any)]]? {
        
        let items = text.components(separatedBy: "},")
        var arrayDict = [[(key: String, value: Any)]]()
        
        for dict in items{
            let cleanDict = dict.replacingOccurrences(of: "[{", with: "").replacingOccurrences(of: "}]", with: "").replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").replacingOccurrences(of: "\"", with: "").split(separator: ",")
            var dictOrdered = [(key: String, value: Any)]()
            cleanDict.forEach{
                dictOrdered.append((key: $0.components(separatedBy: ":").first!, value: $0.components(separatedBy: ":").last!))
            }
            arrayDict.append(dictOrdered)
        }
        if arrayDict.count > 0{
            return arrayDict
        }else{
            return nil
        }
    }
    
    
}

extension ResultadosConsultasViewController: UITableViewDelegate, UITableViewDataSource{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionary?.count ?? 0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ResultadosConsultasDataCell
        
        cell!.innerVw.layer.masksToBounds = true
        cell!.innerVw.layer.borderColor = UIColor.lightGray.cgColor
        cell!.innerVw.layer.borderWidth = 1.2
        cell!.innerVw.layer.cornerRadius = 10.0
        
        var top = cell!.innerVw.topAnchor
        
        cell!.innerVw.subviews.forEach({ if $0.isKind(of: UILabel.self){ $0.removeFromSuperview() } })
        
        let dictNew = dictionary![indexPath.row]
        for (index, dd) in dictNew.enumerated(){
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.numberOfLines = 0
            if index % 2 == 0{ lbl.backgroundColor = odd }else{ lbl.backgroundColor = even }
            lbl.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 13.0)
            lbl.text = "\(dd.key): \(dd.value as? String ?? "")"
            cell!.innerVw.addSubview(lbl)
            
            lbl.leftAnchor.constraint(equalTo: cell!.innerVw.leftAnchor, constant: 10.0).isActive = true
            lbl.topAnchor.constraint(equalTo: top, constant: 0.0).isActive = true
            lbl.rightAnchor.constraint(equalTo: cell!.innerVw.rightAnchor, constant: -10.0).isActive = true
            top = lbl.bottomAnchor
        }
        return cell!
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = dictionary![0].count * 18
        return CGFloat(height)
    }
    
}

// MARK: - Search Bar Delegate
extension ResultadosConsultasViewController: UISearchBarDelegate{
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if btnFiltros.title(for: .normal) == "cnslvw_btn_filter".langlocalized(){
            self.btnActionFiltros(btnFiltros as Any)
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredDictionary = [[(key: String, value: Any)]]()
        isSearching = true
        if globalFilter != ""{
            for dict in backupDictionary!{
                for keys in dict{
                    if keys.key == globalFilter{
                        var str: String = ""
                        if keys.value is String{
                            str = keys.value as! String
                            str = str.lowercased()
                            if str.contains(searchText.lowercased()){
                                filteredDictionary?.append(dict)
                            }
                        }else{
                            if keys.value is NSNumber{
                                let number = keys.value as! NSNumber
                                str = number.stringValue.lowercased()
                                if str.contains(searchText.lowercased()){
                                    filteredDictionary?.append(dict)
                                }
                            }
                        }
                        
                    }
                }
            }
            if searchText == ""{
                dictionary = backupDictionary
                isSearching = false
                self.tblView.reloadData()
            }else{
                dictionary = filteredDictionary
                self.tblView.reloadData()
            }
        }
        
    }
}

extension ResultadosConsultasViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerFilter{
            return filters.count
        }
        if pickerView == self.pickerPagination{
            return paginations.count
        }
        return 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.pickerFilter{
            return filters[row]
        }
        if pickerView == self.pickerPagination{
            return paginations[row]
        }
        return ""
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        pickerView.subviews[0].backgroundColor = UIColor.white
        pickerView.subviews[0].layer.borderWidth = 0.5
        pickerView.subviews[0].layer.borderColor = UIColor.white.cgColor
        pickerView.subviews[1].backgroundColor = UIColor.white
        pickerView.subviews[1].layer.borderWidth = 0.5
        pickerView.subviews[1].layer.borderColor = UIColor.white.cgColor
        
        if pickerView == self.pickerFilter{
            var pickerLabel: UILabel? = (view as? UILabel)
            if pickerLabel == nil {
                pickerLabel = UILabel()
                pickerLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 19.0)
                pickerLabel?.textAlignment = .center
            }
            pickerLabel?.text = filters[row]
            pickerLabel?.textColor = UIColor.white
            return pickerLabel!
        }
        if pickerView == self.pickerPagination{
            var pickerLabel: UILabel? = (view as? UILabel)
            if pickerLabel == nil {
                pickerLabel = UILabel()
                pickerLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 19.0)
                pickerLabel?.textAlignment = .center
            }
            pickerLabel?.text = "\(paginations[row])"
            pickerLabel?.textColor = UIColor.white
            return pickerLabel!
        }
        return view!
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.pickerFilter{
            self.globalFilter = filters[row]
            consulta?.Filtro = globalFilter
            self.pickerFilter.isHidden = true
            self.buttonLabel.text = String(format: "cnslvw_btn_filter_by".langlocalized(), filters[row])
        }
        if pickerView == self.pickerPagination{
            self.consulta?.RegistrosPorPagina = Int(paginations[row])!
            self.pickerPagination.isHidden = true
            btnPaginacion.setTitle(String(format: "cnslvw_btn_pagination_by".langlocalized(), paginations[row]), for: .normal)
        }
        
    }
}

extension ResultadosConsultasViewController: PagingTableViewDelegate {
    
    public func paginate(_ tableView: PagingTableView, to page: Int) {
        if page == 0 || isSearching{return}
        tblView.isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            
            self.consulta?.JsonConsulta = ""
            
            if ConfigurationManager.shared.isConsubanco{
                self.sdkAPI.consultaConsultasPromise(delegate: self, reporte: self.reporte!, consulta: nil)
                    .then { response in
                        
                        ConfigurationManager.shared.consultaSum = response.RegistrosPorPagina
                        ConfigurationManager.shared.consultaHackPage = response.TotalRegistros
                        self.consulta = response
                        let json = response.JsonConsulta
                        let dictionary: [[(key: String, value: Any)]]? = self.convertToDictionary(text: json)
                        self.dictionary = dictionary!
                        
                        self.backupDictionary = self.dictionary
                        self.tblView.isLoading = false
                        self.tblView.reloadData()
                        
                        let currentCount = self.dictionary?.count
                        let finalCount = response.TotalRegistros
                        ConfigurationManager.shared.consultaHackPage = finalCount
                        self.lblCounter.text = String(format: "cnslvw_lbl_counter".langlocalized(), String(currentCount ?? 0), String(finalCount))
                        
                    }.catch { error in
                        self.tblView.isLoading = false
                }
            }else{
               
                self.sdkAPI.consultaConsultasPromise(delegate: self, reporte: nil, consulta: self.consulta!)
                    .then { response in
                        self.consulta = response
                        let json = response.JsonConsulta
                        let dictionary: [[(key: String, value: Any)]]? = self.convertToDictionary(text: json)
                        for dic in dictionary!{
                            self.dictionary?.append(dic)
                        }
                        self.backupDictionary = self.dictionary
                        self.tblView.isLoading = false
                        self.tblView.reloadData()
                        
                        let currentCount = self.dictionary?.count
                        let finalCount = response.TotalRegistros
                        
                        self.lblCounter.text = String(format: "cnslvw_lbl_counter".langlocalized(), String(currentCount ?? 0), String(finalCount))
                        
                    }.catch { error in
                        self.tblView.isLoading = false
                }
                
            }
            
            
            
        }
        
    }
    
}

@objc public protocol PagingTableViewDelegate {
    
    @objc optional func didPaginate(_ tableView: PagingTableView, to page: Int)
    func paginate(_ tableView: PagingTableView, to page: Int)
    
}

public class PagingTableView: UITableView {
    
    private var loadingView: UIView!
    private var indicator: UIActivityIndicatorView!
    internal var page: Int = 0
    internal var previousItemCount: Int = 0
    
    public var currentPage: Int {
        get {
            return page
        }
    }
    
    public weak var pagingDelegate: PagingTableViewDelegate? {
        didSet {
            pagingDelegate?.paginate(self, to: page)
        }
    }
    
    public var isLoading: Bool = false {
        didSet {
            isLoading ? showLoading() : hideLoading()
        }
    }
    
    public func reset() {
        page = 0
        previousItemCount = 0
        pagingDelegate?.paginate(self, to: page)
    }
    
    private func paginate(_ tableView: PagingTableView, forIndexAt indexPath: IndexPath) {
        let itemCount = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: indexPath.section) ?? 0
        guard indexPath.row == itemCount - 1 else { return }
        guard previousItemCount != itemCount else { return }
        page += 1
        previousItemCount = itemCount
        pagingDelegate?.paginate(self, to: page)
    }
    
    private func showLoading() {
        if loadingView == nil {
            createLoadingView()
        }
        tableFooterView = loadingView
    }
    
    private func hideLoading() {
        reloadData()
        pagingDelegate?.didPaginate?(self, to: page)
        tableFooterView = nil
    }
    
    private func createLoadingView() {
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 100))
        indicator = UIActivityIndicatorView()
        indicator.color = UIColor.darkGray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        loadingView.addSubview(indicator)
        centerIndicator()
        tableFooterView = loadingView
    }
    
    private func centerIndicator() {
        let xCenterConstraint = NSLayoutConstraint(
            item: loadingView as Any, attribute: .centerX, relatedBy: .equal,
            toItem: indicator, attribute: .centerX, multiplier: 1, constant: 0
        )
        loadingView.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(
            item: loadingView as Any, attribute: .centerY, relatedBy: .equal,
            toItem: indicator, attribute: .centerY, multiplier: 1, constant: 0
        )
        loadingView.addConstraint(yCenterConstraint)
    }
    
    override public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        paginate(self, forIndexAt: indexPath)
        return super.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
    
}


extension ResultadosConsultasViewController {
    
    func changeIconBack() {
        if ConfigurationManager.shared.isConsubanco {
            backButton.setImage(UIImage(named: "arrowLeft", in: Bundle(identifier: "com.consubanco.econsubanco"), compatibleWith: nil), for: .normal)
        }
    }
    
}
