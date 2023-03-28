import UIKit

import Eureka
public class CalculadoraManager{
    public static let shared = CalculadoraManager()
    var colors: Array<UIColor> =
    [UIColor(red: 132.0/255.0, green: 76.0/255.0, blue: 167.0/255.0, alpha: 1.0) ,
     UIColor(red: 75.0/255.0, green: 157.0/255.0, blue: 134.0/255.0, alpha: 1.0) ,
     UIColor(red: 62.0/255.0, green: 128.0/255.0, blue: 180.0/255.0, alpha: 1.0) ,
     UIColor(red: 47.0/255.0, green: 62.0/255.0, blue: 79.0/255.0, alpha: 1.0) ,
     UIColor(red: 233.0/255.0, green: 158.0/255.0, blue: 60.0/255.0, alpha: 1.0) ,
     UIColor(red: 179.0/255.0, green: 68.0/255.0, blue: 52.0/255.0, alpha: 1.0) ,
     UIColor(red: 62.0/255.0, green: 127.0/255.0, blue: 81.0/255.0, alpha: 1.0) ,
     UIColor(red: 76.0/255.0, green: 180.0/255.0, blue: 248.0/255.0, alpha: 1.0)]
    var currentPage = 0
    let identifier = "colCell"
    var dict = NSDictionary()
    var arrayDict = Array<NSDictionary>()
}

class DismissSegue: UIStoryboardSegue{ override func perform() { let sourceViewController = source; sourceViewController.presentingViewController?.dismiss(animated: true) } }

class CalculadoraCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cardHolder: UIView!
    @IBOutlet weak var imageHolder: UIView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
}

public class CalculadoraViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var currentDiscount = FEDiscount()
    
    @IBOutlet weak var prductBtn: UIButton!
    @IBOutlet weak public var newCollectionView: UICollectionView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageSelector: UIImageView!
    @IBOutlet weak var labelCNCA: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelCurrency: UILabel!
    @IBOutlet weak var textFieldAmount: UITextField!
    @IBOutlet weak var quoteBtn: UIButton!
    @IBOutlet weak var cleanBtn: UIButton!
    @IBOutlet weak public var tableView: UITableView!
    @IBOutlet weak var cncaButton: UIButton!
    
    @IBOutlet weak var lblErrorAmount: UILabel!
    @IBOutlet weak var imageRefresh: UIImageView!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var convenioGroupButton: UIButton!
    @IBOutlet weak var imageSameDiscount: UIImageView!
    @IBOutlet weak var labelSameDiscount: UILabel!
    @IBOutlet weak var btnSameDiscount: UIButton!
    
    let gradientLayer = CAGradientLayer()
    let manager = CalculadoraManager.shared
    var grupoConvenio = [FEGruposConvenio]()
    var convenio: Array<FEConvenioCalculadora> = Array<FEConvenioCalculadora>()
    var convenios = [[FEConvenioCalculadora]]()
    var products = [FEProductsCalculadora]()
    var product = [FEProductCalculadora]()
    public var pickerProduct: UIPickerView = UIPickerView()
    public var pickerConvenioGroup: UIPickerView = UIPickerView()
    var arrayCalc = ["CSP LCOM", "OPC TRADICIONAL", "CSP LCOM", "OPC TRADICIONAL", "CSP LCOM", "OPC TRADICIONAL"]
    var arrayImage = [UIImage(named: "ic_1", in: Cnstnt.Path.framework, compatibleWith: nil), UIImage(named: "ic_2", in: Cnstnt.Path.framework, compatibleWith: nil), UIImage(named: "ic_3", in: Cnstnt.Path.framework, compatibleWith: nil), UIImage(named: "ic_4", in: Cnstnt.Path.framework, compatibleWith: nil), UIImage(named: "ic_5", in: Cnstnt.Path.framework, compatibleWith: nil), UIImage(named: "ic_6", in: Cnstnt.Path.framework, compatibleWith: nil), UIImage(named: "ic_7", in: Cnstnt.Path.framework, compatibleWith: nil), UIImage(named: "ic_8", in: Cnstnt.Path.framework, compatibleWith: nil), UIImage(named: "ic_9", in: Cnstnt.Path.framework, compatibleWith: nil)]
    var indexCollection = 0
    var sdkAPI = APIManager<CalculadoraViewController>()
    var quotesArray: [[FECotizaciones]] = [[FECotizaciones]]()
    var responseQuotes: [FEQuotations] = [FEQuotations]()
    var typeQuote: String = ""
    var productId: String = ""
    var frecuencia: String = ""
    var indexPickerView: Int = 0
    var indexTableView: Int = -1
    var convenioId: String = ""
    let device: Device = Device()
    var check = true
    var checkSameDiscount = true
    var actionDelegate: FormViewController?
    var cncaFlag: Bool = false
    var sameDiscountFlag: Bool = false
    var branchName: String = ""
    var biometricsException: String = ""
    public var formDelegate: FormularioDelegate?
    
   
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.layer.insertSublayer(gradientLayer, at:0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.sdkAPI.delegate = self
        self.tableView.register(UINib(nibName: "RatesTableViewCell", bundle: Cnstnt.Path.framework), forCellReuseIdentifier: "CELL")
        dataFromJson()
        //settingData(index: 0)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.settingData(index: 0)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    @IBAction func Btn_RightAction(_ sender: Any)
    {
        let visibleItems: NSArray = self.newCollectionView.indexPathsForVisibleItems as NSArray
        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        let nextItem: IndexPath = IndexPath(item: currentItem.item + 1, section: 0)
               if nextItem.row < self.grupoConvenio.count {
                self.newCollectionView.scrollToItem(at: nextItem, at: .left, animated: true)
//                let cellNew = newCollectionView.cellForItem(at: currentItem) as! CalculadoraCollectionCell
//                UIView.animate(withDuration: 0.25) {
//                    self.settingData(index: nextItem.row)
//                    cellNew.backgroundColor = self.manager.colors[nextItem.row]
//                }
        }
    }
    
    @IBAction func Btn_LeftAction(_ sender: Any)
    {
        let visibleItems: NSArray = self.newCollectionView.indexPathsForVisibleItems as NSArray
        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        let nextItem: IndexPath = IndexPath(item: currentItem.item - 1, section: 0)
        if nextItem.row < self.grupoConvenio.count && nextItem.row >= 0{
            self.newCollectionView.scrollToItem(at: nextItem, at: .right, animated: true)
        }
    }
    
    @IBAction func convenioGroupAction(_ sender: UIButton) {
        self.pickerConvenioGroup.isHidden = false
    }
    
    @IBAction func productAction(_ sender: UIButton) {
        self.pickerProduct.isHidden = false
    }
    @IBAction func cncaAction(_ sender: UIButton) {
        check = !check

         if check == true {
            self.imageSelector.image = UIImage(named: "ic_check_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
            self.cncaFlag = true
         } else {
            self.imageSelector.image = UIImage(named: "ic_uncheck_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
            self.cncaFlag = false
         }
    }
    
    @IBAction func sameDiscountAction(_ sender: UIButton) {
        self.checkSameDiscount = !self.checkSameDiscount
        if checkSameDiscount == true{
            self.imageSameDiscount.image = UIImage(named: "ic_check_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
            self.sameDiscountFlag = true
            self.imageSelector.image = UIImage(named: "ic_check_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
            self.cncaFlag = true
            self.cncaButton.isUserInteractionEnabled = false
            self.cncaButton.isEnabled = false
        }else{
            self.imageSameDiscount.image = UIImage(named: "ic_uncheck_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
            self.sameDiscountFlag = false
            self.imageSelector.image = UIImage(named: "ic_uncheck_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
            self.cncaFlag = false
            self.cncaButton.isUserInteractionEnabled = true
            self.cncaButton.isEnabled = true
        }
    }
    
    
    @IBAction func refreshAction(_ sender: UIButton) {
        UILoader.show(parent: self.view)
        
        let dictService = ["initialmethod":"ServiciosConsubanco.ServicioCalculadora.ConfiguracionCalculadora", "assemblypath": "ServiciosConsubanco.dll", "data": ["bpid": "\(ConfigurationManager.shared.usuarioUIAppDelegate.User)", "proyid": "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)"]] as [String : Any]
        ConfigurationManager.shared.assemblypath = "ServiciosConsubanco.dll"
        ConfigurationManager.shared.initialmethod = "ServiciosConsubanco.ServicioCalculadora.ConfiguracionCalculadora"
        let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        print("JSONSTRING: \(jsonString)")
        self.sdkAPI.serviceConfigurationCalc(delegate: self, jsonService: jsonString)
            .then{response in
                //print(response)
                UILoader.remove(parent: self.view)
                //ConfigurationManager.shared.variablesDataUIAppDelegate.JsonCalculadora = [response]
                let jsonCalc = [response]
                for data in jsonCalc{
                    self.biometricsException = data.biometricsExceptionProtocol
                    self.grupoConvenio = data.GruposConvenio
                }
                for conv in self.grupoConvenio{ self.convenios.append(conv.convenios) }
                self.newCollectionView.reloadData()
                self.pickerProduct.reloadAllComponents()
                self.pickerConvenioGroup.reloadAllComponents()
            }
            .catch{error in
                UILoader.remove(parent: self.view)
            }
    }
    
    public func refreshActionComponents() {
        if self.tableView != nil { self.cleanAllData() }
        UILoader.show(parent: self.view)
               
               let dictService = ["initialmethod":"ServiciosConsubanco.ServicioCalculadora.ConfiguracionCalculadora", "assemblypath": "ServiciosConsubanco.dll", "data": ["bpid": "\(ConfigurationManager.shared.usuarioUIAppDelegate.User)", "proyid": "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)"]] as [String : Any]
                ConfigurationManager.shared.assemblypath = "ServiciosConsubanco.dll"
                ConfigurationManager.shared.initialmethod = "ServiciosConsubanco.ServicioCalculadora.ConfiguracionCalculadora"
               let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
               let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
               print("JSONSTRING: \(jsonString)")
               self.sdkAPI.serviceConfigurationCalc(delegate: self, jsonService: jsonString)
                   .then{response in
                       //print(response)
                       UILoader.remove(parent: self.view)
                       //ConfigurationManager.shared.variablesDataUIAppDelegate.JsonCalculadora = [response]
                       let jsonCalc = [response]
                       for data in jsonCalc{
                         self.biometricsException = data.biometricsExceptionProtocol
                         self.grupoConvenio = data.GruposConvenio
                       }
                       for conv in self.grupoConvenio{ self.convenios.append(conv.convenios) }
                       self.newCollectionView.reloadData()
                       self.pickerProduct.reloadAllComponents()
                       self.pickerConvenioGroup.reloadAllComponents()
                   }
                   .catch{error in
                       UILoader.remove(parent: self.view)
                   }
    }
    
    @IBAction func quoteAction(_ sender: UIButton) {
        self.quoteBtn.isSelected = !self.quoteBtn.isSelected

              if (self.quoteBtn.isSelected){
                  self.quoteBtn.backgroundColor = UIColor(hexFromString: "18206F")
                  self.cleanBtn.backgroundColor = UIColor(hexFromString: "BECAD8")
                  self.cleanBtn.isSelected = false
              }else{self.quoteBtn.backgroundColor = UIColor(hexFromString: "BECAD8")}
        self.textFieldAmount.resignFirstResponder()
        if !self.grupoConvenio.isEmpty {
                    if indexPickerView == -1{
                        let bannerNew = StatusBarNotificationBanner(title: "Favor de seleccionar un convenio.", style: .danger)
                        bannerNew.show(bannerPosition: .bottom)
                        return
                    }
                    self.lblErrorAmount.isHidden = true
                    self.lblErrorAmount.text = ""
                    guard let quote = self.textFieldAmount.text, quote.isEmpty == false else {
                        self.textFieldAmount.shake()
                        self.textFieldAmount.tintColor = UIColor(hexFromString: "#D93829", alpha: 1.0)
                        let bannerNew = StatusBarNotificationBanner(title: "El campo monto del descuento no puede estar vacio.  Favor de verificar", style: .danger)
                        bannerNew.show(bannerPosition: .bottom)
                        self.textFieldAmount.attributedPlaceholder = NSAttributedString(string: "\(self.convenios[self.indexCollection][self.indexPickerView].montoMinimo) - \(self.convenios[self.indexCollection][self.indexPickerView].montoMaximo)",
                            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexFromString: "#D93829", alpha: 1.0)])
                        return
                    }
                    
                    let minS = self.convenios[self.indexCollection][self.indexPickerView].montoMinimo
                    let maxS = self.convenios[self.indexCollection][self.indexPickerView].montoMaximo
                    if self.segmentedControl.selectedSegmentIndex == 0{
                        UILoader.show(parent: self.view)
                        self.serviceCalcFirst()
                        self.tableView.isHidden = false
                    }else{
                        let text = self.textFieldAmount.text?.replacingOccurrences(of: "$", with: "")
                        let amount = text?.replacingOccurrences(of: ",", with: "")
                        if Double(amount ?? "0") ?? 0.0 < Double(minS){
                            let bannerNew = StatusBarNotificationBanner(title: "El monto no puede ser menor a \(minS), favor de verificar", style: .danger)
                            bannerNew.show(bannerPosition: .bottom)
                        }else if Double(amount ?? "0") ?? 0 > Double(maxS){
                            let bannerNew = StatusBarNotificationBanner(title: "El monto no puede ser mayor a \(maxS), favor de verificar", style: .danger)
                            bannerNew.show(bannerPosition: .bottom)
                        }else{
                            UILoader.show(parent: self.view)
                            self.serviceCalcFirst()
                            self.tableView.isHidden = false
                        }
                    }
        }

    }
    
    @IBAction func cleanAction(_ sender: UIButton) {
        self.cleanBtn.isSelected = !self.cleanBtn.isSelected

        if (self.cleanBtn.isSelected)
        {
            self.cleanBtn.backgroundColor = UIColor(hexFromString: "18206F")
            self.quoteBtn.backgroundColor = UIColor(hexFromString: "BECAD8")
            self.quoteBtn.isSelected = false
        }else{self.cleanBtn.backgroundColor = UIColor(hexFromString: "BECAD8")}
        if !self.grupoConvenio.isEmpty{
            self.cleanAllData()
        }
    }
    
    func cleanAllData(){
        self.product.removeAll()
        if !quotesArray.isEmpty{
            self.quotesArray.removeAll()
        }
        self.tableView.reloadData()
        self.tableView.isHidden = true
        self.textFieldAmount.text = ""
        self.lblErrorAmount.text = ""
        self.lblErrorAmount.isHidden = true
        self.imageSelector.image = UIImage(named: "ic_uncheck_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.imageSameDiscount.image = UIImage(named: "ic_uncheck_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.prductBtn.setTitle("Favor de seleccionar una opción ▾", for: .normal)
        self.indexPickerView = -1
        //self.product = self.convenios[self.indexCollection][self.indexPickerView].Productos.sorted(by: { $0.montoMinimo < $1.montoMaximo })
    }
    
    func cleanData(){
        self.product.removeAll()
        if !quotesArray.isEmpty{
            self.quotesArray.removeAll()
        }
        self.tableView.reloadData()
        self.tableView.isHidden = true
        self.textFieldAmount.text = ""
        self.lblErrorAmount.text = ""
        self.lblErrorAmount.isHidden = true
        self.imageSelector.image = UIImage(named: "ic_uncheck_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.imageSameDiscount.image = UIImage(named: "ic_uncheck_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.prductBtn.setTitle("\(self.convenios[self.indexCollection][self.indexPickerView].convenioNombre) ▾", for: .normal)
        self.product = self.convenios[self.indexCollection][self.indexPickerView].Productos.sorted(by: { $0.montoMinimo < $1.montoMaximo })
    }
    
    @IBAction func typeAction(_ sender: UISegmentedControl) {
        if !grupoConvenio.isEmpty{
            switch sender.selectedSegmentIndex {
            case 0:
                self.typeQuote = "descuento"
                self.labelAmount.text = "Monto del descuento"
                self.btnSameDiscount.isUserInteractionEnabled = true
                self.btnSameDiscount.isEnabled = true
                self.cleanData()
                break
            case 1:
                self.typeQuote = "monto"
                self.labelAmount.text = "Monto del crédito"
                self.sameDiscountFlag = false
                self.imageSameDiscount.image = UIImage(named: "ic_uncheck_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
                self.btnSameDiscount.isUserInteractionEnabled = false
                self.btnSameDiscount.isEnabled = false
                self.cleanData()
                break
            default: break
            }
        }

    }
    
    func settingData(index: Int) {
        self.newCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.pickerProduct = UIPickerView(frame: CGRect(x: 210, y: 275, width: 284 , height: 150))
        self.pickerConvenioGroup = UIPickerView(frame: CGRect(x: 210, y: 275, width: 284 , height: 150))
        if self.device.isPad{
            let layout = self.newCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: self.view.frame.size.width - 99, height: newCollectionView.frame.size.height)
            layout.minimumLineSpacing = 0.0
            layout.minimumInteritemSpacing = 0.0
            self.newCollectionView.backgroundColor = .clear
            self.newCollectionView.setCollectionViewLayout(layout, animated: true)
        }else{
            if device == .iPhone11Pro || device == .iPhone11 || device == .iPhone11ProMax || device == .iPhoneX || device == .iPhoneXS || device == .iPhoneXR || device == .iPhoneXSMax{
                let layout = self.newCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
                layout.itemSize = CGSize(width: self.newCollectionView.frame.size.width, height: newCollectionView.frame.size.height)
                layout.minimumLineSpacing = 0.0
                layout.minimumInteritemSpacing = 0.0
                self.newCollectionView.backgroundColor = .clear
                self.newCollectionView.setCollectionViewLayout(layout, animated: true)
            }else{
                let layout = self.newCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
                layout.itemSize = CGSize(width: self.newCollectionView.frame.size.width - 39, height: newCollectionView.frame.size.height)
                layout.minimumLineSpacing = 0.0
                layout.minimumInteritemSpacing = 0.0
                self.newCollectionView.backgroundColor = .clear
                self.newCollectionView.setCollectionViewLayout(layout, animated: true)
            }

        }
        
        self.pickerProduct.backgroundColor = .white
        self.pickerConvenioGroup.backgroundColor = .white
        self.view.addSubview(self.pickerProduct)
        self.view.addSubview(self.pickerConvenioGroup)
        self.pickerConvenioGroup.translatesAutoresizingMaskIntoConstraints = false
        self.pickerConvenioGroup.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        self.pickerConvenioGroup.leadingAnchor.constraint(equalTo: convenioGroupButton.leadingAnchor).isActive = true
        self.pickerConvenioGroup.trailingAnchor.constraint(equalTo: convenioGroupButton.trailingAnchor).isActive = true
        self.pickerConvenioGroup.topAnchor.constraint(equalTo: convenioGroupButton.bottomAnchor).isActive = true
        self.pickerConvenioGroup.isHidden = true
        self.pickerConvenioGroup.showsSelectionIndicator = true
        self.pickerConvenioGroup.delegate = self
        self.pickerConvenioGroup.dataSource = self
        self.pickerConvenioGroup.layer.cornerRadius = 6.0
        self.pickerConvenioGroup.layer.borderWidth = 0.5
        self.pickerConvenioGroup.layer.borderColor = UIColor.black.cgColor
        self.pickerConvenioGroup.tag = 1
        
        self.pickerProduct.translatesAutoresizingMaskIntoConstraints = false
        self.pickerProduct.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        self.pickerProduct.leadingAnchor.constraint(equalTo: prductBtn.leadingAnchor).isActive = true
        self.pickerProduct.trailingAnchor.constraint(equalTo: prductBtn.trailingAnchor).isActive = true
        self.pickerProduct.topAnchor.constraint(equalTo: prductBtn.bottomAnchor).isActive = true
        self.pickerProduct.isHidden = true
        self.pickerProduct.showsSelectionIndicator = true
        self.pickerProduct.delegate = self
        self.pickerProduct.dataSource = self
        self.pickerProduct.layer.cornerRadius = 6.0
        self.pickerProduct.layer.borderWidth = 0.5
        self.pickerProduct.layer.borderColor = UIColor.black.cgColor
        self.pickerProduct.tag = 2
        self.tableView.isHidden = true
        
        let iconLeft = UIImage(named: "icon_atras", in: Cnstnt.Path.framework, compatibleWith: .none)
        leftButton.setImage(iconLeft, for: .normal)
        leftButton.imageView?.contentMode = .scaleAspectFit
        let iconRight = UIImage(named: "icon_adelante", in: Cnstnt.Path.framework, compatibleWith: .none)
        rightButton.setImage(iconRight, for: .normal)
        rightButton.imageView?.contentMode = .scaleAspectFit
        self.prductBtn.layer.cornerRadius = 12.0
        self.prductBtn.layer.borderWidth = 1.0
        self.prductBtn.layer.borderColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        self.prductBtn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45).cgColor
        self.prductBtn.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        self.prductBtn.layer.shadowOpacity = 1.0
        self.prductBtn.layer.shadowRadius = 10.0
        self.prductBtn.layer.masksToBounds = false
        //self.imageBackground.image = UIImage(named: "ic_franja", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.imageSelector.image = UIImage(named: "ic_uncheck_ec", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.imageSameDiscount.image = UIImage(named: "ic_uncheck_ec", in: Cnstnt.Path.framework, compatibleWith: nil)

        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.layer.cornerRadius = 18
        self.segmentedControl.layer.masksToBounds = true
        self.segmentedControl.clipsToBounds = true

        self.typeQuote = "descuento"
        self.textFieldAmount.delegate = self
        self.textFieldAmount.clipsToBounds = true
        self.textFieldAmount.layer.cornerRadius = 15.0
        self.textFieldAmount.layer.borderWidth = 0.0
        self.textFieldAmount.layer.borderColor = UIColor.clear.cgColor
        self.textFieldAmount.backgroundColor = UIColor.groupTableViewBackground
        self.textFieldAmount.addTarget(self, action: #selector(self.myTextFieldDidChange(_:)), for: .editingChanged)
        self.quoteBtn.layer.cornerRadius = 17.0
        self.quoteBtn.backgroundColor = UIColor(hexFromString: "BECAD8")
        self.cleanBtn.layer.cornerRadius = 17.0
        self.cleanBtn.backgroundColor = UIColor(hexFromString: "BECAD8")
        self.labelAmount.text = "Monto del descuento"
        self.imageRefresh.image = UIImage(named: "ic_refresh", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.imageRefresh.layer.cornerRadius = self.imageRefresh.frame.size.width / 2
        self.imageRefresh.tintColor = UIColor.white
        self.imageBackground.image = UIImage(named: "back_cotizador", in: Cnstnt.Path.framework, compatibleWith: nil)
        actionDelegate = self.formDelegate?.getFormViewControllerDelegate()
        
        let jsonCalc = ConfigurationManager.shared.jsonCalculadora
        for data in jsonCalc{ self.grupoConvenio = data.GruposConvenio }
        if !self.grupoConvenio.isEmpty{
            for conv in self.grupoConvenio{ self.convenios.append(conv.convenios) }
            self.convenioGroupButton.setTitle("\(self.grupoConvenio[0].convenioGoup) ▾", for: .normal)
            self.pickerProduct.reloadAllComponents()
        }

    }
    
    func dataFromJson(){
        let filePath = Cnstnt.Path.framework?.path(forResource: "calculadora", ofType: "json") ?? ""
        do {
            let json = try String(contentsOfFile: filePath)
            self.manager.dict = try JSONSerializer.toDictionary(json)
            self.manager.arrayDict = (self.manager.dict["ListFEProductos"] as! Array<NSDictionary>)
        } catch { }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centerX = self.newCollectionView.center.x
        for cell in self.newCollectionView.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
            let cellCenterX = basePosition.x + self.newCollectionView.frame.size.height / 2.0
            let distance = abs(cellCenterX - centerX)
            let tolerance : CGFloat = 0.02
            var scale = 1.00 + tolerance - (( distance / centerX ) * 0.100)
            if(scale > 1.0){ scale = 1.0 }
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        self.lblErrorAmount.isHidden = true
        self.lblErrorAmount.text = ""
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        if !self.grupoConvenio.isEmpty{
            if self.convenios[self.indexCollection].count == 0{
                textField.text = ""
                let bannerNew = StatusBarNotificationBanner(title: "Seleccione un Convenio", style: .danger)
                bannerNew.show(bannerPosition: .bottom)
                return
            }
            if indexPickerView == -1{
                textField.text = ""
                let bannerNew = StatusBarNotificationBanner(title: "Favor de seleccionar un convenio", style: .danger)
                bannerNew.show(bannerPosition: .bottom)
                return
            }
            let minS = self.convenios[self.indexCollection][self.indexPickerView].montoMinimo
            let maxS = self.convenios[self.indexCollection][self.indexPickerView].montoMaximo
            let min = Double(minS)
            let max = Double(maxS)
            
            if segmentedControl.selectedSegmentIndex == 0{
                //textField.text = textField.text?.convertDoubleToCurrency()
                let text = textField.text?.replacingOccurrences(of: "$", with: "")
                let amount = text?.replacingOccurrences(of: ",", with: "")
                let amountD = Double(amount ?? "0") ?? 0.0
                let amountI = Int(amountD)
                if amountI >= maxS{
                    let bannerNew = StatusBarNotificationBanner(title: "El monto no puede ser mayor a \(maxS), favor de verificar", style: .danger)
                    bannerNew.show(bannerPosition: .bottom)
                    self.quoteBtn.isEnabled = false
                    self.quoteBtn.isUserInteractionEnabled = false
                }else{
                    self.quoteBtn.isEnabled = true
                    self.quoteBtn.isUserInteractionEnabled = true
                }
                    if min != 0 && max != 0{
                    }else{  }
            }else{
                let text = textField.text?.replacingOccurrences(of: "$", with: "")
                let amount = text?.replacingOccurrences(of: ",", with: "")
                let amountD = Double(amount ?? "0") ?? 0.0
                let amountI = Int(amountD)
                
                
                print(amountI)
                if amountI < minS{
                    let bannerNew = StatusBarNotificationBanner(title: "El monto no puede ser menor a \(minS), favor de verificar", style: .danger)
                    bannerNew.show(bannerPosition: .bottom)
                    self.quoteBtn.isUserInteractionEnabled = false
                    self.quoteBtn.isEnabled = false
                }else{
                    self.quoteBtn.isEnabled = true
                    self.quoteBtn.isUserInteractionEnabled = true
                }
                if amountI > maxS{
                    let bannerNew = StatusBarNotificationBanner(title: "El monto no puede ser mayor a \(maxS), favor de verificar", style: .danger)
                    bannerNew.show(bannerPosition: .bottom)
                    self.quoteBtn.isEnabled = false
                    self.quoteBtn.isUserInteractionEnabled = false
                }else{
                    self.quoteBtn.isEnabled = true
                    self.quoteBtn.isUserInteractionEnabled = true
                }
                        //let intOriginal = Int(textField.text ?? "0") ?? 0
                        //textField.text = textField.text?.currencyInputFormatting(min, max)
                        //textField.text = textField.text?.convertDoubleToCurrency()
                        if min != 0 && max != 0{
                //            if intOriginal < minS{
                //                self.lblErrorAmount.isHidden = false
                //                self.lblErrorAmount.text = "El mínimo ha sido seleccionado"
                //            }
                //            if intOriginal > maxS{
                //                self.lblErrorAmount.isHidden = false
                //                self.lblErrorAmount.text = "El máximo ha sido seleccionado"
                //            }
                        }else{
                            //myTextFieldDidChange(textField)
                            
                }
            }
        }
 
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {

        if let amountString = textField.text?.currencyInputFormattingNew() {
            textField.text = amountString
//            var replace = textField.text?.regexReplace(regEx: "[0-9]*\\.?[0-9]*")
//            replace = textField.text?.replacingOccurrences(of: "\(replace ?? "")", with: "")
//            textField.text = replace
        }
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
//        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//        let indexPath = collectionView.indexPathForItem(at: visiblePoint)
//        let i = indexPath?.row ?? 0
        let visibleRectNew = CGRect(origin: newCollectionView.contentOffset, size: newCollectionView.bounds.size)
        let visiblePointNew = CGPoint(x: visibleRectNew.midX, y: visibleRectNew.midY)
        let indexPathNew = newCollectionView.indexPathForItem(at: visiblePointNew)
        _ = indexPathNew?.row ?? 0
//        let cellNew = newCollectionView.cellForItem(at: indexPathNew!) as! CalculadoraCollectionCell
//        UIView.animate(withDuration: 0.25) {
//            self.settingData(index: j)
//            cellNew.backgroundColor = self.manager.colors[j]
//        }
        self.view.layoutIfNeeded()
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return self.grupoConvenio.count }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //self.indexCollection = indexPath.row
        let cellNew = collectionView.dequeueReusableCell(withReuseIdentifier: "CELLCAL", for: indexPath) as! CalculadoraCollectionCell
        let obj = self.grupoConvenio[indexPath.row]
        cellNew.labelText.text = obj.convenioGoup
        
        //self.prductBtn.setTitle("Favor de seleccionar una opción ▾", for: .normal)
        self.pickerProduct.reloadAllComponents()
        return cellNew
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) { self.textFieldAmount.resignFirstResponder() }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 1{
           return 1
        }else{
            return 1
        }
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1{
           return self.grupoConvenio.count
        }else{
            if self.convenios.isEmpty{
                return 0
            }else{
                if self.convenios[self.indexCollection].count == 0{return 0}else{return self.convenios[self.indexCollection].count + 1}
            }

        }
        
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1{
            return self.grupoConvenio[row].convenioGoup
        }else{
            if row == 0{ return "Favor de seleccionar una opción ▾" }else{

                return self.convenios[self.indexCollection][row - 1].convenioNombre
               
            }

        }
        
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 2{
            self.pickerProduct.isHidden = true
            self.indexPickerView = row - 1
            if !convenios.isEmpty{
                if self.convenios[self.indexCollection].count != 0{
                    if row == 0{self.prductBtn.setTitle("Favor de seleccionar una opción ▾", for: .normal)}else{
                        self.prductBtn.setTitle("\(self.convenios[indexCollection][row - 1].convenioNombre) ▾", for: .normal)
                        self.convenioId = self.convenios[indexCollection][row - 1].convenioId
                        self.product = self.convenios[self.indexCollection][row - 1].Productos.sorted(by: { $0.montoMinimo < $1.montoMaximo })
                        let min = String(self.convenios[self.indexCollection][row - 1].montoMinimo).currencyFormatter()
                        let max = String(self.convenios[self.indexCollection][row - 1].montoMaximo).currencyFormatter()
                        self.textFieldAmount.placeholder = "\(min) - \(max)"
                    }
                }
            }

        }else{
            self.pickerConvenioGroup.isHidden = true
            self.indexCollection = row
            self.indexPickerView = -1
            if !grupoConvenio.isEmpty{
                self.convenioGroupButton.setTitle("\(self.grupoConvenio[row].convenioGoup) ▾", for: .normal)
                self.prductBtn.setTitle("Favor de seleccionar una opción ▾", for: .normal)
                self.pickerProduct.reloadAllComponents()
            }
            
        }
        

    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if pickerView.tag == 1{
            
            var label = UILabel()
            if let v = view as? UILabel { label = v }
            label.font = UIFont (name: "Avenir Next Medium", size: 12)
            label.textAlignment = .center
             label.text = self.grupoConvenio[row].convenioGoup
            return label
        }else{
            var label = UILabel()
            if let v = view as? UILabel { label = v }
            label.font = UIFont (name: "Avenir Next Medium", size: 12)
            label.textAlignment = .center
            if row == 0{ label.text = "Favor de seleccionar una opción ▾" }else{ label.text = self.convenios[self.indexCollection][row - 1].convenioNombre }
            return label
            
        }
        

    }
    
    func serviceCalcFirst(){
        //String(format: "%.2f", amount?.removeFormatAmount() ?? 0.0)
        var dictService = [String: Any]()
        var prodDict = Dictionary<String, Any>()
        for prod in self.product{ prodDict[prod.productId] = prod.productFrequency }
        if self.segmentedControl.selectedSegmentIndex == 0{
            let desc = self.textFieldAmount.text
            dictService = ["initialmethod":"ServiciosConsubanco.ServicioCalculadora.CalculadoraPorTipo", "assemblypath": "ServiciosConsubanco.dll", "data": ["cantidad": "\(String(format: "%.2f", desc?.removeFormatAmount() ?? 0.0))", "tipo": "\(self.typeQuote)", "productos":prodDict,"mismodescuento": self.sameDiscountFlag]] as [String : Any]
        }else{
            let amount = self.textFieldAmount.text?.removeFormatAmount()
            let amountI = Int(amount ?? 0.0)
            self.textFieldAmount.text = "\(String(describing: amountI))00".currencyInputFormattingNew()
            dictService = ["initialmethod":"ServiciosConsubanco.ServicioCalculadora.CalculadoraPorTipo", "assemblypath": "ServiciosConsubanco.dll", "data": ["cantidad": "\(amountI)", "tipo": "\(self.typeQuote)", "productos":prodDict]] as [String : Any]
        }
        
        ConfigurationManager.shared.assemblypath = "ServiciosConsubanco.dll"
        ConfigurationManager.shared.initialmethod = "ServiciosConsubanco.ServicioCalculadora.CalculadoraPorTipo"
        let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(850)) {
            self.sdkAPI.serviceQuotesCalc(delegate: self, jsonService: jsonString)
            .then{ response in
                UILoader.remove(parent: self.view)
                self.responseQuotes = response.sorted(by: { $0.Order < $1.Order })
                var cot = [[FECotizaciones]]()
               var arrayFlag = [Bool]()
               
                for quote in response.sorted(by: { $0.Order < $1.Order }){

                    for prod in self.convenios[self.indexCollection][self.indexPickerView].Productos{
                        if prod.productId == quote.ProductId{
                            prod.order = quote.Order
                            if quote.quotations.isEmpty{
                                prod.flagCot = true
                                arrayFlag.append(true)
                            }else{
                                prod.flagCot = false
                                arrayFlag.append(false)
                            }
                            
                            cot.append(quote.quotations)

                            
                        }
                    }
                }

                if !arrayFlag.contains(false){
                    if self.segmentedControl.selectedSegmentIndex == 0{
                        let bannerNew = StatusBarNotificationBanner(title: "\(self.codeQuotations())", style: .warning)
                        bannerNew.show(bannerPosition: .bottom)
                    }else{
                        let bannerNew = StatusBarNotificationBanner(title: "\(self.codeQuotations())", style: .warning)
                        bannerNew.show(bannerPosition: .bottom)
                    }
                }
                self.product = self.convenios[self.indexCollection][self.indexPickerView].Productos.sorted(by: { $0.order < $1.order })

                self.quotesArray = cot
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()

            }.catch{ error in UILoader.remove(parent: self.view); print("ERROR: \(error)") }
        }
    }
    
    func codeQuotations() -> String{
        var code = ""
        var message = ""
        for q in self.responseQuotes{
            code = q.code
        }
        if  code == "200"{
            message = "No existe oferta para esa cantidad."
        }else if code == "500"{
            message = "Ha ocurrido un error en la consulta, favor de reportarlo al Centro de Asistencia Técnica"
        }
        
        return message
    }
    
    func formulaInteres(interes: Double?) -> Double{
        let res = interes! * 100.0
        //let rounded = round(100 * res) / 1000
        return res.roundToDecimal(2)
    }
    func formulaAnual(interes: Double?) -> Double{
        let res = interes! * 12.0
        //let rounded = round(1000 * res) / 1000
        return res.roundToDecimal(2)
    }
    
    // MARK: servicio obtener descuento
    
    /// SERVICIO OBTENER DESCUENTO  REAL YA QUE PUEDO VARIAR UN POCO LA CANTIDAD DE ACUERDO A  LOS FILTROS SELECCIONADOS
    /// - Parameters:
    ///   - cantidadValue: monto requisitado total a pagar
    ///   - fecuenciaValue: la sigla del producto que viene en el xml (Mensual,Semanal,Catorcenal,Quincenal)
    ///   - pagosValue: numero de la frecuencia con que se hara el pago
    ///   - productoValue: id del producto
    /// - Precondition:
    /// - solo aplica para cuando seleccione descuento y no este habilitado mismo descuento en la pantalla de la calculadora
    func serviceObtenerDescuento(_ cantidadValue: String,_ fecuenciaValue: String,_ pagosValue: String,_ productoValue: String )  {
        
        self.view.isUserInteractionEnabled = false
        self.view.superview?.isUserInteractionEnabled = false
        print(self.view.subviews.count)
        print(self.view.superview?.subviews.count ?? 0)
        let dictService = ["initialmethod":"ServiciosConsubanco.ServicioCalculadora.ObtenerDescuento", "assemblypath": "ServiciosConsubanco.dll", "data": ["cantidad": cantidadValue, "frecuencia": fecuenciaValue, "pagos": pagosValue, "producto": productoValue]] as [String : Any]
        ConfigurationManager.shared.assemblypath = "ServiciosConsubanco.dll"
        ConfigurationManager.shared.initialmethod = "ServiciosConsubanco.ServicioCalculadora.ObtenerDescuento"
        let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        print(jsonString)
        self.sdkAPI.servicegetDiscount(delegate: self, jsonService: jsonString)
            .then{response in
                self.currentDiscount = response
                print(response)
        }
        .catch{error in
            print(error.localizedDescription)
        }
    }
    

}


extension CalculadoraViewController: CollectionViewCellDelegate {
    
    func collectionView(collectionviewcell: RatesCollectionViewCell?, index: Int, didTappedInTableViewCell: RatesTableViewCell, tableIndex: Int) {
        var productTitle = ""
        if self.product[tableIndex].productShortname == ""{
            productTitle = self.product[tableIndex].productName
        }else{
            productTitle = self.product[tableIndex].productShortname
        }
        switch self.quotesArray[tableIndex][index].frequencyDescription {
        case "Mensual":
            self.frecuencia = "Meses"; break
        case "Quincenal":
            self.frecuencia = "Quincenas"; break
        case "Catorcenal":
            self.frecuencia = "Catorcenas"; break
        case "Semanal":
            self.frecuencia = "Semanas"
        default:
            break
        }
        
        // MARK: llamar servicio de descuento solo si
        var newDiscount = 0.0
        var newTotalAmount = 0.0
        if self.typeQuote == "descuento" && sameDiscountFlag == false {
            serviceObtenerDescuento("\(self.quotesArray[tableIndex][index].requestedAmount)", String(self.frecuencia.first ?? Character("")), "\(self.quotesArray[tableIndex][index].plazo)", self.product[tableIndex].productId)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(850)) {
                newDiscount = Double(self.currentDiscount.Descuento)
                newTotalAmount = self.currentDiscount.MontoTotal
            }
        }else{
            newDiscount = self.quotesArray[tableIndex][index].discountAmount
            newTotalAmount = self.quotesArray[tableIndex][index].totalAmount
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(990)) {
            self.view.isUserInteractionEnabled = true
            self.view.superview?.isUserInteractionEnabled = true
            //String(format: "%.2f", self.quotesArray[tableIndex][index].cat)
            _ = Double(String(format: "%.2f", self.formulaInteres(interes: self.quotesArray[tableIndex][index].interestRate)))
            let interesA = String(format: "%.2f", self.quotesArray[tableIndex][index].tasaanual )
            let detail = DetailCalcViewController()
            detail.show(in: self, title: productTitle, month: "\(self.quotesArray[tableIndex][index].plazo) \(self.frecuencia)", amount: "\(self.quotesArray[tableIndex][index].requestedAmount)".convertDoubleToCurrency(), discount: "\(newDiscount)".convertDoubleToCurrency(), rate: "\(interesA)%", cat: "\(String(format: "%.2f", self.quotesArray[tableIndex][index].cat))%", covenant: "\(self.convenios[self.indexCollection][self.indexPickerView].convenioName)", company: "\(self.convenios[self.indexCollection][self.indexPickerView].enterpriseName)", creditType: self.product[tableIndex].productCategory, total: "\(newTotalAmount)".convertDoubleToCurrency(), descX: "\(self.quotesArray[tableIndex][index].descx)".convertDoubleToCurrency(), plazo: "\(self.quotesArray[tableIndex][index].plazo)", periodicidad: "\(self.quotesArray[tableIndex][index].frequencyDescription)", convenioId: "\(self.convenioId)", productId: self.product[tableIndex].productId, cnca: self.cncaFlag, sameDiscount: self.sameDiscountFlag, productCategory: self.product[tableIndex].productCategory, openingCommissionAmount: self.product[tableIndex].openingCommissionAmount, aop: self.convenios[self.indexCollection][self.indexPickerView].aplicaOriginacionPaperless, priceGroupId: "\(self.quotesArray[tableIndex][index].priceGroupId)", productN: self.product[tableIndex].productName, branchN: "\(self.convenios[self.indexCollection][self.indexPickerView].branchName)", biometricsException: self.biometricsException)
        }
        
    }
}

extension CalculadoraViewController: UITableViewDelegate, UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return self.product.count }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath) as! RatesTableViewCell
        self.indexTableView = indexPath.row
       
        if self.convenios[self.indexCollection].count != 0{

            if self.product[indexPath.row].productShortname == ""{
                cell.labelTitle.text = self.product[indexPath.row].productName
            }else{
                cell.labelTitle.text = self.product[indexPath.row].productShortname
            }
            
            if self.quotesArray[indexPath.row].count == 0{
                cell.labelMessage.isHidden = false
                cell.labelMessage.text = "No se encontro ningun resultado con los valores ingresados"

            }else{
                let rowArray = self.quotesArray[indexPath.row]
                cell.updateCellWith(row: rowArray, index: indexPath.row)
                cell.labelMessage.isHidden = true
            }
        }
        //cell.collectionViewTable.reloadData()
        cell.cellDelegate = self
        
        return cell
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.quotesArray[indexPath.row].count == 0{
            return 0.5
        }else{
            return 145.0
        }
        //cell.collectionViewTable.reloadData()#JAT
        //cell.cellDelegate = self
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return "COTIZACIONES" }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(hexFromString: "FFAC44")
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.textAlignment = .center
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
}

extension CalculadoraViewController: APIDelegate{
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {
        
    }
    
    public func sendStatusCodeMessage(message: String, error: enumErrorType) {
        
    }
    
    public func didSendError(message: String, error: enumErrorType) {
        print("MESSAGE: \(message)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(850)) {
            let bannerNew = StatusBarNotificationBanner(title: "\(message)", style: .warning)
            bannerNew.show(bannerPosition: .bottom)
        }

    }
    
    public func didSendResponse(message: String, error: enumErrorType) {
        
    }
    
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {
        
    }
    
    func sendStatus(message: String, error: String, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    func sendStatusCodeMessage(message: String, error: String) { }
    func didSendError(message: String, error: String) {
        print("MESSAGE: \(message)")
    }
    func didSendResponse(message: String, error: String) { }
    func didSendResponseHUD(message: String, error: String, porcentage: Int) { }
}

class DetailCalculadoraViewController: UIViewController{
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblProducto: UILabel!
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var cardImg: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var viewMonto: UIView!
    @IBOutlet weak var lblMonto: UILabel!
    @IBOutlet weak var lblMinMonto: UILabel!
    @IBOutlet weak var sliderMonto: UISlider!
    @IBOutlet weak var lblMaxMonto: UILabel!
    
    @IBOutlet weak var viewPlazo: UIView!
    @IBOutlet weak var lblPlazo: UILabel!
    @IBOutlet weak var lblMinPlazo: UILabel!
    @IBOutlet weak var sliderPlazo: UISlider!
    @IBOutlet weak var lblMaxPlazo: UILabel!
    
    @IBOutlet weak var viewMensualidad: UIView!
    @IBOutlet weak var lblMensualidad: UILabel!
    @IBOutlet weak var lblMinMensualidad: UILabel!
    @IBOutlet weak var sliderMensualidad: UISlider!
    @IBOutlet weak var lblMaxMensualidad: UILabel!
    
    let gradientLayer = CAGradientLayer()
    let manager = CalculadoraManager.shared
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sliderMonto.tag = 1
        self.sliderPlazo.tag = 2
        self.sliderMensualidad.tag = 3
        
        self.view.layer.insertSublayer(gradientLayer, at:0)
        
        self.sliderMonto.minimumValue = 0
        self.sliderMonto.maximumValue = 100000
        self.sliderMonto.value = 0
        self.sliderMonto.setValue(0.0, animated: true)
        
        self.sliderPlazo.minimumValue = 0
        self.sliderPlazo.maximumValue = 120
        self.sliderPlazo.value = 0
        self.sliderPlazo.setValue(0.0, animated: true)
        
        self.sliderMensualidad.minimumValue = 0
        self.sliderMensualidad.maximumValue = 10000
        self.sliderMensualidad.value = 0
        self.sliderMensualidad.setValue(0.0, animated: true)
        
        self.lblMinMonto.text = "\(0)"
        self.lblMaxMonto.text = "\(100000)"
        self.lblMinPlazo.text = "\(0)"
        self.lblMaxPlazo.text = "\(120)"
        self.lblMinMensualidad.text = "\(0)"
        self.lblMaxMensualidad.text = "\(10000)"
        
        self.btnClose.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        settingData(index: self.manager.currentPage)
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedAction(self.segmentedControl)
    }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.sliderMonto.value = self.sliderMensualidad.value * self.sliderPlazo.value
        }else if segmentedControl.selectedSegmentIndex == 1{
            self.sliderPlazo.value = self.sliderMonto.value / self.sliderMensualidad.value
        }else if segmentedControl.selectedSegmentIndex == 2{
            self.sliderMensualidad.value = self.sliderMonto.value / self.sliderPlazo.value
        }
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        if segmentedControl.selectedSegmentIndex == 0{
            self.sliderMonto.value = self.sliderMensualidad.value * self.sliderPlazo.value
        }else if segmentedControl.selectedSegmentIndex == 1{
            self.sliderPlazo.value = self.sliderMonto.value / self.sliderMensualidad.value
        }else if segmentedControl.selectedSegmentIndex == 2{
            self.sliderMensualidad.value = self.sliderMonto.value / self.sliderPlazo.value
        }
    }
    
    func settingData(index: Int) {
        let colorTop = self.manager.colors[index].cgColor
        let colorBottom = UIColor(red: 32.0/255.0, green: 32.0/255.0, blue: 32.0/255.0, alpha: 1.0).cgColor
        
        self.lblProducto.textColor = .white
        self.lblProducto.layer.shadowColor = UIColor.black.cgColor
        self.lblProducto.layer.shadowRadius = 2.0
        self.lblProducto.layer.shadowOpacity = 1.0
        self.lblProducto.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.lblProducto.layer.masksToBounds = false
        
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        let obj = self.manager.arrayDict[index]
        self.lblProducto.text = (obj["NombreProducto"] as? String ?? "").uppercased()
        self.cardImg.image = UIImage(named: obj["Icono"] as? String ?? "", in: Cnstnt.Path.framework, compatibleWith: nil)
    }
    
}

extension Dictionary where Value: Equatable {
  func containsValue(value : Value) -> Bool {
    return self.contains { $0.1 == value }
  }
}
