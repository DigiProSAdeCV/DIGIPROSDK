import Foundation
import UIKit
import UserNotifications
import Lottie

class TagLabel: UILabel {

   @IBInspectable var topInset: CGFloat = 6.0
   @IBInspectable var bottomInset: CGFloat = 6.0
   @IBInspectable var leftInset: CGFloat = 15.0
   @IBInspectable var rightInset: CGFloat = 15.0

   override func drawText(in rect: CGRect) {
      let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
       super.drawText(in: rect.inset(by: insets))
   }

   override var intrinsicContentSize: CGSize {
      get {
         var contentSize = super.intrinsicContentSize
         contentSize.height += topInset + bottomInset
         contentSize.width += leftInset + rightInset
         return contentSize
      }
   }
}

public class LocalDataCellView: UITableViewCell{
    
    @IBOutlet weak var titleTemplate: UILabel!
    @IBOutlet weak var descriptionTemplate: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var txtMoreInfo: UITextView!
    @IBOutlet weak var stackTags: UIStackView!
    @IBOutlet weak var Values: UILabel!
}

public class DataViewController: UIViewController, UNUserNotificationCenterDelegate, popupGenericProtocol{
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var nuevoFEBtn: UIButton!
    @IBOutlet weak var srchBar: UISearchBar!
    // UpperMenu
    @IBOutlet public var btnFlujos: UIButton!
    @IBOutlet weak var lblFlujos: UILabel!
    @IBOutlet weak var btnSubir: UIButton!
    
    let pagesScrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        v.isScrollEnabled = true
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        return v
    }()
    
    var sdkAPI : APIManager<DataViewController>?
    var dataViewAPI : ControllersManager<DataViewController>?
    var formAPI : TemplateManager<DataViewController>?
    
    var filteredSectionData = [FEProcesos]()
    
    var arrayFormatoData = Array<FEFormatoData>()
    var filteredFormatoData = Array<FEFormatoData>()
    var hud: JGProgressHUD?
    var hudAnexos: JGProgressHUD?
    var procesosByFlujos = [FEProcesos]()
    var tagPersis: Int = 0
    
    var emptyTitleTableView = String(format: "datavw_table_title".langlocalized(), ConfigurationManager.shared.usuarioUIAppDelegate.User)
    var emptySubtitleTableView = "datavw_table_subtitle".langlocalized()
    
    var indexCell: Int = 0
    let defaults = UserDefaults.standard
    let device = Device()
    var timer = Timer()
    var numTextResumenV2 = 0
    var tablaIsEmpty: Bool = true
    var tamCell : [Int:CGFloat] = [:]
    
    // MARK: IBAction
    @IBAction func NuevoFE(_ sender: Any) {
        let preview = NuevoFEViewController(nibName: "emLdqYbDHhCnxHu", bundle: Cnstnt.Path.framework)
        preview.dataviewDelegate = self
        preview.view.frame.size.width = (self.view.frame.size.width) - 60
        preview.view.frame.size.height = (self.view.frame.size.height - 120)
        let presenter = Presentr(presentationType: .bottomHalf)
        self.customPresentViewController(presenter, viewController: preview, animated: true, completion: nil)
    }
    
    @IBAction func btnActionFlujos(_ sender: Any) {
        let preview = FlujoViewController(nibName: "EhttsclhmRZRnse", bundle: Cnstnt.Path.framework)
        preview.dataviewDelegate = self
        preview.view.frame.size.width = (self.view.frame.size.width) - 60
        preview.view.frame.size.height = (self.view.frame.size.height - 120)
        let presenter = Presentr(presentationType: .bottomHalf)
        self.customPresentViewController(presenter, viewController: preview, animated: true, completion: nil)
    }
    
    @IBAction func btnActionConsultas(_ sender: Any) {
        let consultas = ConsultasViewController.init(nibName: "pgimMPyRuzVHuFF", bundle: Cnstnt.Path.framework)
        consultas.dataviewDelegate = self
        consultas.view.frame.size.width = (self.view.frame.size.width) - 60
        consultas.view.frame.size.height = (self.view.frame.size.height - 120)
        let presenter = Presentr(presentationType: .bottomHalf)
        self.customPresentViewController(presenter, viewController: consultas, animated: true, completion: nil)
    }
    
    @IBAction func btnActionSubir(_ sender: Any) {
        //self.tap()
        self.updatingToServer()
    }
    
    @IBAction func tapToHideKeyboard(_ sender: UITapGestureRecognizer) {
        self.srchBar.resignFirstResponder()
    }
    
    public func performNuevaPlantilla(_ navigation: UINavigationController){
        self.present(navigation, animated: true, completion: nil)
    }
    
    
    
    // MARK: - ViewDidLoad
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        FormularioUtilities.shared.globalIndexFlujo = 0
        
        // API MANAGER
        sdkAPI = APIManager<DataViewController>()
        sdkAPI?.delegate = self
        dataViewAPI = ControllersManager<DataViewController>()
        dataViewAPI?.delegate = self
        formAPI = TemplateManager<DataViewController>()
        formAPI?.delegate = self
               
        UNUserNotificationCenter.current().delegate = self
        
        self.btnFlujos.setTitle("datavw_btn_flow".langlocalized(), for: .normal)
        self.lblFlujos.text = "datavw_lbl_flow".langlocalized();
        self.tableview.backgroundColor = UIColor.white
        self.tableview.register(UINib(nibName: "LocalDataCellView", bundle: Cnstnt.Path.framework), forCellReuseIdentifier: "Cell")

        // Quita el contorno negro de la search bar
        self.srchBar.backgroundImage = UIImage()
        self.srchBar.searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.srchBar.delegate = self
        self.settingContraints()
        self.configureViewBeforeVisualization()
        
        self.nuevoFEBtn.setImage(UIImage(named: "newTemplate", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        self.btnSubir.setImage(UIImage(named: "uploadTemplates", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tap))  //Tap function will call when user tap on button
        tapGesture.numberOfTapsRequired = 1
        self.btnSubir.addGestureRecognizer(tapGesture)
        
        setupUi()
        constraintsUi()
        
        self.detectPermissionNewFormat()
        
        self.getAllData()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.reloadFormats()
        self.tableview.reloadData()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView){ }
    
    // MARK: - Button actions TAP and LONG PRESS
    // ONE TAP BUTTON
    @objc func tap() {
        DispatchQueue.main.async {
            UILoader.show(parent: self.view)
            // Setting process
            // 1 SyncFormats
            // 2 SendFormats
            // 3 DownloadFormats
            ConfigurationManager.shared.utilities.isConnectedToNetwork()
            .then { response in
                // SyncFormats
                self.sdkAPI?.DGSDKverifyFormats(delegate: self)
                    .then({ response in
                        // SendFormats
                        
                        self.sdkAPI?.DGSDKsendFormatos(delegate: self)
                            .then({ response in
                                // DownloadFormats
                                self.sdkAPI?.DGSDKdownloadFormats(delegate: self)
                                    .then { response in
                                        
                                        UILoader.remove(parent: self.view)
                                        self.reloadFormatsAndPlantillas()
                                        self.getNotification()
                                    }.catch { error in
                                        UILoader.remove(parent: self.view)
                                        self.reloadFormatsAndPlantillas()
                                    }
                            }).catch({ error in
                                UILoader.remove(parent: self.view)
                                self.reloadFormatsAndPlantillas()
                            })
                    }).catch({ error in
                        UILoader.remove(parent: self.view)
                        self.reloadFormatsAndPlantillas()
                    })
            }.catch { error in
                UILoader.remove(parent: self.view)
                self.reloadFormatsAndPlantillas()
            }
        }
        
        self.updatingToServer()
    }
    
    func forcedSync(){
        DispatchQueue.main.async {
            UILoader.show(parent: self.view)
            
            ConfigurationManager.shared.utilities.isConnectedToNetwork()
            .then { response in

                // Check Plantillas
                self.sdkAPI?.DGSDKdownloadTemplates(delegate: self)
                    .then{ response in
                        
                        // Check Variables
                        self.sdkAPI?.DGSDKdownloadVariables(delegate: self)
                            .then { response in
                                
                                // Check Formatos
                                self.sdkAPI?.DGSDKdownloadFormats(delegate: self, initial: true)
                                    .then { response in
                                        UILoader.remove(parent: self.view)
                                        self.reloadFormatsAndPlantillas()
                                        self.getNotification()
                                    }.catch { error in
                                        UILoader.remove(parent: self.view)
                                        self.reloadFormatsAndPlantillas()
                                    }
                                
                            }.catch { error in
                                UILoader.remove(parent: self.view)
                                self.reloadFormatsAndPlantillas()
                            }
                        
                    }.catch{ error in
                        UILoader.remove(parent: self.view)
                        self.reloadFormatsAndPlantillas()
                    }

            }.catch { error in
                UILoader.remove(parent: self.view)
                self.reloadFormatsAndPlantillas()
            }
        }
    }
    
    lazy var emptyAnimation: AnimationView = {
        let animation = Animation.named("empty_lottie",
                                        subdirectory: nil,
                                        animationCache: nil)
        let lottie = AnimationView(animation: animation)
        lottie.translatesAutoresizingMaskIntoConstraints = false
        lottie.play()
        lottie.loopMode = .loop
        lottie.backgroundBehavior = .pauseAndRestore
        lottie.contentMode = .scaleAspectFit
        lottie.isHidden = true
        return lottie
    }()
    
    lazy var lottieLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.text = "No existen resultados"
        label.font = .systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    func setupUi(){
        tableview.addSubview(emptyAnimation)
        tableview.addSubview(lottieLabel)
    }
    
    func constraintsUi(){
        NSLayoutConstraint.activate([
            emptyAnimation.centerXAnchor.constraint(equalTo: tableview.centerXAnchor),
            emptyAnimation.centerYAnchor.constraint(equalTo: tableview.centerYAnchor),
            emptyAnimation.heightAnchor.constraint(equalToConstant: 200),
            emptyAnimation.widthAnchor.constraint(equalToConstant: 200),
            
            lottieLabel.topAnchor.constraint(equalTo: emptyAnimation.bottomAnchor,constant: -10),
            lottieLabel.centerXAnchor.constraint(equalTo: tableview.centerXAnchor),
        ])
    }
    
    func emptyDataAction(){
        if filteredFormatoData.count == 0 {
            emptyAnimation.isHidden = false
            lottieLabel.isHidden = false
        }else {
            emptyAnimation.isHidden = true
            lottieLabel.isHidden = true
        }
    }
    
    @objc func segmentSelected(_ sender:UIButton?) {
        if sender?.tag ?? -1 == -1{ return }
        FormularioUtilities.shared.globalProceso = procesosByFlujos[sender?.tag ?? 0].PIID
        FormularioUtilities.shared.globalIndexProceso = sender?.tag ?? 0
        
        let normal = UIColor(hexFromString: "#3d9970")
        let activo = UIColor(hexFromString: "#3c8dbc")
        self.pagesScrollView.subviews.forEach({
            if $0.isKind(of: UIButton.self){
                $0.backgroundColor = normal
                $0.isUserInteractionEnabled = true
            }
        })
        sender?.isUserInteractionEnabled = false
        sender?.backgroundColor = activo
        
        UILoader.show(parent: self.view)
        self.procesoWasPressed(sender?.tag ?? 0)
    }
    
    func settingTutorialView(){
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        let destination = NewFirstViewController.init(nibName: "upYwerKOFgllyYl", bundle: Cnstnt.Path.framework)
        destination.modalPresentationStyle = .fullScreen
        self.navigationController?.present(destination, animated: true, completion: nil)
    }
    
    func reloadFormatsAndPlantillas(){
        UILoader.show(parent: self.view)
        
        self.sdkAPI?.DGSDKgetFlows(delegate: self)
            .then { response in
                UILoader.remove(parent: self.view)
                if ConfigurationManager.shared.flujosOrdered.count > 0{
                    FormularioUtilities.shared.globalFlujo = ConfigurationManager.shared.flujosOrdered[0].FlujoID
                    DispatchQueue.main.async {
                        self.performDefaultSelection()
                    }
                    if ConfigurationManager.shared.isShortcutItemLaunchActived{
                        self.NuevoFE(self)
                    }
                }
            }.catch { error in UILoader.remove(parent: self.view)  }
        
    }
    
    func reloadFormats(){
        self.sdkAPI?.DGSDKgetFlows(delegate: self)
            .then { response in
                
                if ConfigurationManager.shared.flujosOrdered.count > 0{
                    FormularioUtilities.shared.globalFlujo = ConfigurationManager.shared.flujosOrdered[0].FlujoID
                    self.performDefaultSelection()
                    if ConfigurationManager.shared.isShortcutItemLaunchActived{
                        self.NuevoFE(self)
                    }
                }
            }.catch { error in  }
    }
    
    func performDefaultSelection(){
        self.performFlowSelection(FormularioUtilities.shared.globalIndexFlujo)
    }
    
    func getAllData(_ user: Bool = false){
        UILoader.show(parent: self.view)
        
        DispatchQueue.global(qos: .background).async {
            self.sdkAPI?.DGSDKdownloadData(delegate: self)
                .then({ response in
                    self.reloadFormatsAndPlantillas()
                    //self.getNotification()
                }).catch({ error in
                    UILoader.remove(parent: self.view)
                    self.reloadFormatsAndPlantillas()
                })
        }
        UILoader.remove(parent: self.view)
    }
    func reloadDataFromFlujoAndProceso(_ activeFormato: FEFormatoData? = nil){
        filteredFormatoData = [FEFormatoData]()
        arrayFormatoData = [FEFormatoData]()
        filteredSectionData = [FEProcesos]()
        filteredFormatoData = (sdkAPI?.DGSDKgetFormatos(FormularioUtilities.shared.globalFlujo, FormularioUtilities.shared.globalProceso))!
        if filteredFormatoData.count == 0{
            UILoader.remove(parent: self.view)
            return
        }
        
        for flujo in ConfigurationManager.shared.flujosOrdered{
            if flujo.FlujoID == FormularioUtilities.shared.globalFlujo {
                for proceso in flujo.PProcesos{
                    if proceso.PIID == FormularioUtilities.shared.globalProceso{
                        filteredSectionData = [proceso]
                        break
                    }
                }
            }
        }
        arrayFormatoData = filteredFormatoData
        UILoader.remove(parent: self.view)
    }
    
    func procesoWasPressed(_ index: Int, override: Bool = false){
        self.reloadDataFromFlujoAndProceso(nil)
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
    
    func deleteFormatoFromLocal(formato: FEFormatoData){
        
        let alert = UIAlertController(title: "alrt_warning".langlocalized(), message: "alrt_delete_form".langlocalized(), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "alrt_accept".langlocalized(), style: .default, handler: { action in
            switch action.style{
            case .default:
                self.sdkAPI?.DGSDKformatoDelete(delegate: self, formato: formato)
                .then({ response in
                    self.reloadFormatsAndPlantillas()
                    let leftView = UIImageView(image: UIImage(named: "info_alert", in: Cnstnt.Path.framework, compatibleWith: nil))
                    let bannerNew = NotificationBanner(title: "", subtitle: "not_delete_format".langlocalized(), leftView: leftView, rightView: nil, style: .success, colors: nil)
                    bannerNew.show()
                }).catch({ _ in })
                break
            case .cancel: break; case .destructive: break; @unknown default: break }}))
        alert.addAction(UIAlertAction(title: "alrt_cancel".langlocalized(), style: .destructive, handler: { action in
        switch action.style{ case .default: break; case .cancel: break; case .destructive: break; @unknown default: break; }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Close Console
    @objc func closeConsole(){ ConfigurationManager.shared.viewConsole!.removeFromSuperview() }
    
    // MARK: - UPDATING TO SERVER
    func updatingToServer(){
        // Solamente se van a enviar los documentos locales.
        UILoader.show(parent: self.view)
        
        var exitButton: UIButton = UIButton()
        let superviewLayout = self.view.safeAreaLayoutGuide
        ConfigurationManager.shared.console.initConsole(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        exitButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        let userDefaults_serial = String(self.defaults.string(forKey: Cnstnt.BundlePrf.serial) ?? "")
        if userDefaults_serial.sha512() == "07eeb356a2b2297563b4e7cb245387b19b341afd31e58d0bed678449062aa462fd28d78732c62ffeeb73ccbbf45c077d271f4a8f10803dab48597f477e76eaf2"{
            // Console Log
            self.view.addSubview(ConfigurationManager.shared.viewConsole!)
            
            ConfigurationManager.shared.viewConsole!.translatesAutoresizingMaskIntoConstraints = false
            ConfigurationManager.shared.viewConsole!.leadingAnchor.constraint(equalTo: superviewLayout.leadingAnchor, constant: 0).isActive = true
            ConfigurationManager.shared.viewConsole!.topAnchor.constraint(equalTo: superviewLayout.topAnchor, constant: 0).isActive = true
            ConfigurationManager.shared.viewConsole!.heightAnchor.constraint(equalTo: superviewLayout.heightAnchor, constant: 0).isActive = true
            ConfigurationManager.shared.viewConsole!.widthAnchor.constraint(equalTo: superviewLayout.widthAnchor, constant: 0).isActive = true
            self.view.layoutIfNeeded()
            
            exitButton.addTarget(self, action: #selector(closeConsole), for: UIControl.Event.touchDown)
            exitButton.isUserInteractionEnabled = true
            exitButton.isHidden = false
            //#Btn Fondo/Redondo
            exitButton.backgroundColor = UIColor.red
            exitButton.layer.cornerRadius = exitButton.frame.height / 2
            exitButton.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: UIControl.State.normal)
            ConfigurationManager.shared.viewConsole?.addSubview(exitButton)
            
            exitButton.translatesAutoresizingMaskIntoConstraints = false
            exitButton.trailingAnchor.constraint(equalTo: superviewLayout.trailingAnchor, constant: -5).isActive = true
            exitButton.topAnchor.constraint(equalTo: superviewLayout.topAnchor, constant: 5).isActive = true
            exitButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            exitButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Problemas de memoria en DataViewController.")
    }
}

// MARK: - DZNEMPTYDATA
extension DataViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    public func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = emptyTitleTableView
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    public func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = emptySubtitleTableView
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    public func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? { return nil }
    public func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? { return nil }
}

// MARK: - TABLEVIEW
extension DataViewController: UITableViewDelegate, UITableViewDataSource{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyDataAction()
        return filteredFormatoData.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let object = filteredFormatoData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LocalDataCellView
        cell.tag = indexPath.row
        for view in cell.stackTags.arrangedSubviews {
            if (view as? UILabel) != nil{ view.removeFromSuperview() }
        }
        cell.tag = indexPath.row
        cell.btnMore.setImage(UIImage(named: "more_vert_black_24dp", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        cell.btnMore.tag = cell.tag
        cell.btnMore.addTarget(self, action: #selector(menuPopUp(_:)), for: UIControl.Event.touchDown)
        cell.btnMore.setTitle("", for: .normal)
        
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.topLeft, .bottomLeft, .topRight, .bottomRight], cornerRadii: CGSize(width: 10.0, height: 10.0)).cgPath
         
        let anexosTagLbl = TagLabel()
        anexosTagLbl.translatesAutoresizingMaskIntoConstraints = false
        anexosTagLbl.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 10.0)
        anexosTagLbl.layer.mask = shapeLayer
        anexosTagLbl.text = "\(object.Anexos.count) Anexos"
        anexosTagLbl.layer.masksToBounds = true
        anexosTagLbl.layer.borderColor = UIColor.black.cgColor
        anexosTagLbl.layer.borderWidth = 0.3
        anexosTagLbl.layer.cornerRadius = 10.0
        anexosTagLbl.clipsToBounds = true
        anexosTagLbl.frame = CGRect(x:0,y:0,width:anexosTagLbl.intrinsicContentSize.width,height:anexosTagLbl.intrinsicContentSize.height)

        cell.stackTags.addArrangedSubview(anexosTagLbl)
         
        cell.cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cell.cardView.layer.shadowColor = Cnstnt.Color.whitelight.cgColor
        cell.cardView.layer.shadowOpacity = 0.85
        cell.cardView.layer.shadowRadius = 10
       
        let bookmarkTagLbl = TagLabel()
        bookmarkTagLbl.translatesAutoresizingMaskIntoConstraints = false
        bookmarkTagLbl.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 11.0)
        bookmarkTagLbl.layer.mask = shapeLayer
        bookmarkTagLbl.layer.masksToBounds = true
        bookmarkTagLbl.layer.borderWidth = 0.3
        bookmarkTagLbl.layer.cornerRadius = 10.0
        bookmarkTagLbl.clipsToBounds = true
        cell.stackTags.addArrangedSubview(bookmarkTagLbl)
        
        //bookmarkTagLbl.centerYAnchor.constraint(equalTo: anexosTagLbl.centerYAnchor, constant: -40).isActive = true
        
        if object.EstadoApp == 0{
            bookmarkTagLbl.text = "Respaldado"
            bookmarkTagLbl.layer.borderColor = UIColor(hexFromString: "#6B006D", alpha: 1.0).cgColor
            bookmarkTagLbl.textColor = UIColor(hexFromString: "#6B006D", alpha: 1.0)
        }else if object.EstadoApp == 1{
            bookmarkTagLbl.text = "Guardado"
            bookmarkTagLbl.layer.borderColor = UIColor(hexFromString: "#D1971B", alpha: 1.0).cgColor
            bookmarkTagLbl.textColor = UIColor(hexFromString: "#D1971B", alpha: 1.0)
        }else if object.EstadoApp == 2{
            bookmarkTagLbl.text = "Por publicar"
            bookmarkTagLbl.layer.borderColor = UIColor(hexFromString: "#1B79FE", alpha: 1.0).cgColor
            bookmarkTagLbl.textColor = UIColor(hexFromString: "#1B79FE", alpha: 1.0)
        }else if object.EstadoApp == 3{
            // Nothing to do
        }
        cell.Values.layer.cornerRadius = 3
        cell.Values.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 11.0)
        cell.Values.numberOfLines = 0
        
        var stringToSetNSValues : String = ""
        object.ResumenV2.texto.forEach { resumenText in
            stringToSetNSValues.append("\(resumenText.valor)\n")
        }
        cell.Values.text = stringToSetNSValues
        
        cell.txtMoreInfo.text = ""
        cell.txtMoreInfo.layer.borderColor = UIColor.gray.cgColor
        cell.txtMoreInfo.layer.cornerRadius = 5
        cell.txtMoreInfo.layer.borderWidth = 0
        cell.txtMoreInfo.isScrollEnabled = true
        cell.txtMoreInfo.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingHead

        // MARK: Buscar y pintar el campo dinamico
        var valueCampoDinamico = ""
        
        if object.Estadisticas.count > 0 {
            for propertie in object.Estadisticas {
                if propertie.Campo.contains("ComboDinamico") {
                    valueCampoDinamico = "\(propertie.Resultado)||"
                }
            }
        }
        

            
            if !object.ResumenV2.texto.isEmpty || !object.ResumenV2.imagen.isEmpty || !object.ResumenV2.tabla.isEmpty {
                self.numTextResumenV2 = 0
                tablaIsEmpty = true
                //Flujo para imagenes:
                var images:[UIImage] = []
                for base64Image in object.ResumenV2.imagen {
                    let base64Data = Data(base64Encoded: base64Image.valor, options: .ignoreUnknownCharacters)
                    if let data = base64Data {
                        if let imagenDeResumen: UIImage = UIImage(data: data) {
                            images.append(imagenDeResumen)
                        }
                    }
                }
                    

                
                //Flujo para texto de resumen:
                if !object.ResumenV2.texto.isEmpty && tablaIsEmpty {
                    for texto in object.ResumenV2.texto {
                        let columnTitle = UILabel()
                        columnTitle.translatesAutoresizingMaskIntoConstraints = false
                        columnTitle.lineBreakMode = .byTruncatingTail
                        columnTitle.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 11.0)
                        columnTitle.text = "\(texto.valor)"
                        if "\(texto.valor)" != "" { self.numTextResumenV2 += 1}
//                            cell.scrollViewTable.addSubview(columnTitle)
//                            columnTitle.topAnchor.constraint(equalTo: top, constant: 0.0).isActive = true
//                            columnTitle.leadingAnchor.constraint(equalTo: leading, constant: 5).isActive = true
//                            top = columnTitle.bottomAnchor
                    }
                }
                
            } else if object.Resumen != "" {
//                    cell.scrollViewTable.isHidden = true
                cell.txtMoreInfo.isHidden = false
                cell.txtMoreInfo.isUserInteractionEnabled = true
                cell.txtMoreInfo.text =  valueCampoDinamico.replacingOccurrences(of: "||", with: "\n") + object.Resumen.replacingOccurrences(of: "||", with: "\n")
            } else {
//                    cell.scrollViewTable.isHidden = true
                cell.txtMoreInfo.isHidden = true
                cell.titleTemplate.text = object.NombreExpediente
                cell.descriptionTemplate.text = object.NombreTipoDoc
            }
            
             if ConfigurationManager.shared.flujosOrdered[FormularioUtilities.shared.globalIndexFlujo].MostrarExp{
                 cell.titleTemplate.text = object.NombreExpediente
             }else{ cell.titleTemplate.text = "" }
             
             if ConfigurationManager.shared.flujosOrdered[FormularioUtilities.shared.globalIndexFlujo].MostrarTipoDoc{
                 cell.descriptionTemplate.text = object.NombreTipoDoc
             }else{ cell.descriptionTemplate.text = "" }
            
         return cell
        
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("SELECCION DE CELDA: \(indexPath.row)")
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    
    /// Adds images to scrollView in LocalDataCellView for ResumenV2
    /// - Parameters:
    ///   - scrollView: The LocalDataCellView's scrollView
    ///   - images: an array of `UIImage` to be added to the scrollView.
    private func setImages(for scrollView: UIScrollView, with images:[UIImage]) {
        //Limpiar scrollView para reuso en celda.
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        for i in 0..<images.count {
            frame.origin.x = 55 * CGFloat(i)
            frame.size = scrollView.frame.size
            frame.size.width = 50
            let imageView = UIImageView(frame: frame)
            imageView.contentMode  = .scaleAspectFit
            imageView.image = images[i]
            scrollView.contentSize = CGSize(width: 55 * CGFloat(images.count), height: scrollView.frame.size.height)
            scrollView.addSubview(imageView)
        }
    }
    
    // Action buttons
    
    @objc public func menuPopUp(_ sender: UIButton){
        let manager = PopMenuManager.default
        if ConfigurationManager.shared.usuarioUIAppDelegate.PermisoBorrarFormato{
            let actionDelete = PopMenuDefaultAction(title: "Borrar", image: nil, color: nil, didSelect: { action in
                self.trashAction(self.tagPersis)
            })
            tagPersis = sender.tag
            manager.addAction(actionDelete)
        }
        if ConfigurationManager.shared.usuarioUIAppDelegate.PermisoVisualizarFormato{
            let previewAction = PopMenuDefaultAction(title: "Visualizar", image: nil, color: nil, didSelect: { action in
                self.previewAction(self.tagPersis)
            })
            tagPersis = sender.tag
            manager.addAction(previewAction)
        }
        if ConfigurationManager.shared.usuarioUIAppDelegate.PermisoEditarFormato{
            let actionEdit = PopMenuDefaultAction(title: "Editar", image: nil, color: nil, didSelect: { action in
                self.editAction(self.tagPersis)
            })
            tagPersis = sender.tag
            manager.addAction(actionEdit)
        }
        if self.filteredFormatoData[sender.tag].DocID != 0 {
            let pdfAction = PopMenuDefaultAction(title: "PDF", image: nil, color: nil, didSelect: { action in
                self.pdfAction(self.tagPersis)
            })
            tagPersis = sender.tag
            manager.addAction(pdfAction)
        }
        let userDefaults_serial = String(UserDefaults.standard.string(forKey: Cnstnt.BundlePrf.serial) ?? "")
        if userDefaults_serial.sha512() == "07eeb356a2b2297563b4e7cb245387b19b341afd31e58d0bed678449062aa462fd28d78732c62ffeeb73ccbbf45c077d271f4a8f10803dab48597f477e76eaf2"{
            let helpAction = PopMenuDefaultAction(title: "Ayuda", image: nil, color: nil, didSelect: { action in
                self.helpAction(self.tagPersis)
            })
            tagPersis = sender.tag
            manager.addAction(helpAction)
        }
        manager.present()
        
    }
    
    @objc public func pdfAction(_ tag: NSInteger){
        // Se deberá de mandar un loading
        UILoader.show(parent: self.view)
        
        self.sdkAPI?.DGSDKformatPDF(delegate: self, formato: self.filteredFormatoData[tag])
            .then({ response in
                // Eliminar el loading y cargar el PDF
                WebPDFViewController.show(in: self, pdfString: response)
                UILoader.remove(parent: self.view)
            })
            .catch({ _ in UILoader.remove(parent: self.view) })
    }
    
    @objc public func trashAction(_ tag: NSInteger){
        _ = popupGeneric(parent: self,
                        delegate: self,
                        title: "Borrar",
                        message: "Como quieres borrar el formato.",
                        showOptionalButton: true,
                        optionalButtonTitleText: "Cerrar")

    }
    
    public func notifyAcceptWithTag(tag: Int) {
        self.deleteFormatoFromLocal(formato: self.filteredFormatoData[tagPersis])
    }
    
    @objc public func downloadAction(_ sender: UIButton){
        let object = self.filteredFormatoData[sender.tag]
        if !object.AnexosDescargados{
            if object.Anexos.count > 0{
                self.sdkAPI?.DGSDKverAnexo(formato: object)
                    .then({ response in
                        // Success
                    }).catch({ error in
                        // Error
                    })
            }
        }else{
            let bannerNew = NotificationBanner(title: "", subtitle: "not_attach_downloaded".langlocalized(), leftView: nil, rightView: nil, style: .success, colors: nil)
            bannerNew.show()
        }
    }
    
    @objc public func lockAction(_ sender: UIButton){
        UILoader.remove(parent: self.view)
        UILoader.show(parent: self.view)
        
        self.sdkAPI?.DGSDKformatLockUnlock(delegate: self, self.filteredFormatoData[sender.tag])
            .then{ response in
                self.didFormatoTransited(index: sender.tag, formato: response, isInEdition: false)
                let leftView = UIImageView(image: UIImage(named: "info_alert", in: Cnstnt.Path.framework, compatibleWith: nil))
                let bannerNew = NotificationBanner(title: "", subtitle: "not_form_reserved".langlocalized(), leftView: leftView, rightView: nil, style: .success, colors: nil)
                bannerNew.show()
                
            }.catch{ error in
                
                let rightView = UIImageView(image: UIImage(named: "warning_sign", in: Cnstnt.Path.framework, compatibleWith: nil))
                let bannerNew = NotificationBanner(title: "", subtitle: "not_form_notreserved".langlocalized(), leftView: nil, rightView: rightView, style: .danger, colors: nil)
                bannerNew.show()
                self.tableview.reloadData()
                UILoader.remove(parent: self.view)
        }
    }
    @objc public func unlockAction(_ sender: UIButton){
        UILoader.remove(parent: self.view)
        UILoader.show(parent: self.view)
        self.sdkAPI?.DGSDKformatLockUnlock(delegate: self, self.filteredFormatoData[sender.tag])
            .then{ response in
                self.didFormatoTransited(index: sender.tag, formato: response, isInEdition: false)
                let leftView = UIImageView(image: UIImage(named: "info_alert", in: Cnstnt.Path.framework, compatibleWith: nil))
                let bannerNew = NotificationBanner(title: "", subtitle: "not_form_free".langlocalized(), leftView: leftView, rightView: nil, style: .success, colors: nil)
                bannerNew.show()
                
            }.catch{ error in
                self.tableview.reloadData()
                UILoader.remove(parent: self.view)
        }
    }
    
    public func setCurrentFormIphone(_ index: Int, _ isPreview: Bool = false){
        let presenter = NuevaPlantillaViewController(self, self.filteredFormatoData[index], index, isPreview)
        
        presenter.modalPresentationStyle = .fullScreen
        let navigation = UINavigationController(rootViewController: presenter)
        navigation.modalPresentationStyle = .fullScreen
        navigation.isNavigationBarHidden = true
        self.performNuevaPlantilla(navigation)
    }
    
    public func setCurrentFormIphone(_ formato: FEFormatoData, _ isPreview: Bool = false){
        let presenter = NuevaPlantillaViewController(self, formato, 0, isPreview)
        
        presenter.modalPresentationStyle = .fullScreen
        let navigation = UINavigationController(rootViewController: presenter)
        navigation.modalPresentationStyle = .fullScreen
        navigation.isNavigationBarHidden = true
        self.performNuevaPlantilla(navigation)
    }
    
    @objc public func previewAction(_ tag: NSInteger){
        self.setCurrentFormIphone(tag, true)
    }
    
    @objc public func editAction(_ tag: NSInteger){
        UILoader.remove(parent: self.view)
        UILoader.show(parent: self.view)
        
        self.sdkAPI?.DGSDKformatEdit(delegate: self, formato: self.filteredFormatoData[tag], true, false)
            .then({ response in
                self.didFormatoTransited(index: tag, formato: self.filteredFormatoData[tag], isInEdition: false)
                self.setCurrentFormIphone(response)
            }).catch({ error in
                UILoader.remove(parent: self.view)
            })
    }
    
    // MARK: - Card Action | Info or Help
    @objc public func helpAction(_ tag: NSInteger){
        let preview = DataViewHelp(formato: self.filteredFormatoData[tag])
        let presenter = Presentr(presentationType: .bottomHalf)
        self.customPresentViewController(presenter, viewController: preview, animated: true, completion: nil)
    }
    
    // MARK: - Card Action | Transit
    @objc public func transitAction(_ sender: UIButton){
        self.sdkAPI?.DGSDKgetFlowTasks(formato: self.filteredFormatoData[sender.tag])
            .then({ response in
                
                let actionAlert = UIAlertController(title: "Tareas", message: "", preferredStyle: UIAlertController.Style.actionSheet)
                for r in response{
                    let taskAction = UIAlertAction(title: r, style: .default) { (action: UIAlertAction) in
                        
                        UILoader.show(parent: self.view)
                        
                    self.sdkAPI?.DGSDKsetFlowTask(delegate: self, formato: self.filteredFormatoData[sender.tag], nombreTarea: r, needsReserved: true)
                        .then({ response in
                            self.sdkAPI?.DGSDKsendFormatos(delegate: self)
                            .then({ response in
                                // DownloadFormats
                                self.sdkAPI?.DGSDKdownloadFormats(delegate: self)
                                    .then { response in
                                        UILoader.remove(parent: self.view)
                                        self.reloadFormatsAndPlantillas()
                                    }.catch { error in
                                        UILoader.remove(parent: self.view)
                                        self.reloadFormatsAndPlantillas()
                                    }
                            }).catch({ error in
                                UILoader.remove(parent: self.view)
                            })
                            
                        }).catch({ error in
                            UILoader.remove(parent: self.view)
                            let e = error as NSError
                            let rightView = UIImageView(image: UIImage(named: "warning_sign", in: Cnstnt.Path.framework, compatibleWith: nil))
                            let bannerNew = NotificationBanner(title: "", subtitle: e.userInfo["message"] as? String, leftView: nil, rightView: rightView, style: .danger, colors: nil)
                            bannerNew.show()
                        })
                        
                    }
                    actionAlert.addAction(taskAction)
                }
                let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                actionAlert.addAction(cancel)
                self.present(actionAlert, animated: true, completion: nil)
                
            }).catch({ error in
                let rightView = UIImageView(image: UIImage(named: "warning_sign", in: Cnstnt.Path.framework, compatibleWith: nil))
                let bannerNew = NotificationBanner(title: "", subtitle: "apimng_log_notaskfound".langlocalized(), leftView: nil, rightView: rightView, style: .danger, colors: nil)
                bannerNew.show()
            })
    }
}



// MARK: - Search Bar Delegate
extension DataViewController: UISearchBarDelegate{
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filteredFormatoData = searchBar.text!.isEmpty ? arrayFormatoData : arrayFormatoData.filter { (item: FEFormatoData) -> Bool in
            // If dataItem matches the searchText, return true to include it
            if item.Resumen != ""{
                return item.Resumen.range(of: searchBar.text!, options: .caseInsensitive, range: nil, locale: nil) != nil
            }else {
                return item.NombreExpediente.range(of: searchBar.text!, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        
        // Reloading table if there is nothing to show
        if filteredFormatoData.count == 0{
            self.emptyTitleTableView = "datavw_table_title_s".langlocalized()
            self.emptySubtitleTableView = String(format: "datavw_table_subtitle_s".langlocalized(), searchBar.text ?? "")
        }else{
            self.emptyTitleTableView = "datavw_table_title".langlocalized()
            self.emptySubtitleTableView = "datavw_table_subtitle".langlocalized()
        }
        
        self.tableview.reloadData()
    }
}

// MARK: - TemplateDelegate
extension DataViewController: TemplateDelegate{
    public func didFormatViewFinish(error: NSError?, success: [String : Any]?) {
        self.getNotification()
        self.detectIfHasNewFormat()
        self.detectPermissionNewFormat()
        self.detectPermissionVisualizeMap()
    }
}

// MARK: - APIDelegate
extension DataViewController: APIDelegate{
    public func didFormatoTransited(index: NSInteger, formato: FEFormatoData, isInEdition: Bool){
        self.reloadDataFromFlujoAndProceso(formato)
        let indexpath = IndexPath(row: index, section: 0)
        tableview.reloadData()
        UILoader.remove(parent: self.view)
    }
    public func didSendToServerFormatos() { }
    
    public func didSendToServerAnexos(){ }
    
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }

    public func errorPDFResponse(message: String) {
        let str = message
        let index = str.firstIndex(of: ":")!
        let substr = str.prefix(upTo: index)
        DispatchQueue.main.async {
                self.alert(message: String(substr))
        }
    }
    
    public func errorDescargaResponse(message: String){
        let str = message
        if str.contains(":"){
            let index = str.firstIndex(of: ":")!
            let substr = str.prefix(upTo: index)
            self.alert(message: String(substr))
        }else{
            self.alert(message: String(format: "alrt_file_device".langlocalized(), message))
        }
    }
        
    public func didSendError(message: String, error: enumErrorType) {
        ConfigurationManager.shared.utilities.incrementHUD(hud!, self.view, progress: 100, message)
        switch error.rawValue {
        case 2:
            let rightView = UIImageView(image: UIImage(named: "warning_alert", in: Cnstnt.Path.framework, compatibleWith: nil))
            let bannerNew = NotificationBanner(title: "alrt_warning".langlocalized(), subtitle: message, leftView: nil, rightView: rightView, style: .warning, colors: nil)
            bannerNew.show()
            break
        case 3:
            let rightView = UIImageView(image: UIImage(named: "warning_sign", in: Cnstnt.Path.framework, compatibleWith: nil))
            let bannerNew = NotificationBanner(title: "alrt_error".langlocalized(), subtitle: message, leftView: nil, rightView: rightView, style: .danger, colors: nil)
            bannerNew.show()
            break
        case 0:
            let leftView = UIImageView(image: UIImage(named: "info_alert", in: Cnstnt.Path.framework, compatibleWith: nil))
            let bannerNew = NotificationBanner(title: "alrt_info".langlocalized(), subtitle: message, leftView: leftView, rightView: nil, style: .info, colors: nil)
            bannerNew.show()
            break
        default:
            let banner = NotificationBanner(title: "", subtitle: message, style: .none)
            banner.show()
            break
        }
        UILoader.remove(parent: self.view)
        if hud != nil{
            hud?.dismiss()
        }
    }
    
    public func didSendResponse(message: String, error: enumErrorType) { }
    
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {
        DispatchQueue.main.async {
            ConfigurationManager.shared.utilities.incrementHUD(self.hud!, self.view, progress: porcentage, message)
        }
    }
    
    public func didSendResponseStatus(title: String, subtitle: String, porcentage: Float){ }
}

// MARK: - ControllerDelegate
extension DataViewController: ControllerDelegate{
    public func performConsultaViewController(_ index: Int) {
        let form = ConsultasFormViewController.init(nibName: "RIqpwNzWIdapSSS", bundle: Cnstnt.Path.framework)
        form.reporte = ConfigurationManager.shared.consultasUIAppDelegate[index]
        self.navigationController?.pushViewController(form, animated: true)
    }
    public func performNuevoFeViewController(_ plantilla: FEPlantillaData, _ index: Int){
        let destination = NuevaPlantillaViewController(self, plantilla, index, false)
        self.navigationController?.pushViewController(destination, animated: true)
    }
    public func performFlowSelection(_ index: Int){
        print("Flujo pressed: \(ConfigurationManager.shared.flujosOrdered[index].FlujoID)")
        FormularioUtilities.shared.globalFlujo = ConfigurationManager.shared.flujosOrdered[index].FlujoID
        FormularioUtilities.shared.globalIndexFlujo = index
        
        self.lblFlujos.text = ConfigurationManager.shared.flujosOrdered[index].NombreFlujo
        procesosByFlujos = [FEProcesos]()
        
        var firstVisibility: UIButton? = nil
        
        for view in pagesScrollView.subviews{ view.removeFromSuperview() }

        var leading = pagesScrollView.leadingAnchor
        var totalWidth: CGFloat = 0.0

        for (i, proceso) in ConfigurationManager.shared.flujosOrdered[index].PProcesos.enumerated(){
            
            let label = UIButton()
            label.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            label.tag = i
            label.translatesAutoresizingMaskIntoConstraints = false
            label.addTarget(self, action: #selector(segmentSelected(_:)), for: .touchUpInside)
            
            let files = FCFileManager.listFilesInDirectory(atPath: "\(Cnstnt.Tree.usuarios)/\(ConfigurationManager.shared.codigoUIAppDelegate.Codigo)_\(ConfigurationManager.shared.usuarioUIAppDelegate.User)/\(Cnstnt.Tree.formatos)/\(proceso.FlujoID)/\(proceso.PIID)/")
            var counter = 0
            for file in files!{
                let fileBor = file as! String
                if fileBor.contains(".bor"){
                    counter += 1
                }
            }
            proceso.CounterFormats = counter
            
            let normal = UIColor(hexFromString: "#3d9970")
            label.backgroundColor = normal
            pagesScrollView.addSubview(label)
            label.setTitle("\(proceso.NombreProceso) (\(counter))", for: .normal)
            label.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
            label.leadingAnchor.constraint(equalTo: leading, constant: 0).isActive = true
            label.topAnchor.constraint(equalTo: pagesScrollView.topAnchor, constant: 0).isActive = true
            label.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            if (files?.count)! > 0{
                if firstVisibility == nil{ firstVisibility = label }
                label.isHidden = false
                label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width + 20).isActive = true
                leading = label.trailingAnchor
                totalWidth += label.intrinsicContentSize.width + 20.0
            }else{
                label.widthAnchor.constraint(equalToConstant: 0).isActive = true
                leading = label.trailingAnchor
                label.isHidden = true
            }

            procesosByFlujos.append(proceso)
            
        }
        pagesScrollView.contentSize = CGSize(width: totalWidth, height: 40)
        if firstVisibility != nil{ self.segmentSelected(firstVisibility!) }else{ self.filteredFormatoData = [FEFormatoData](); self.tableview.reloadData() }

    }
    public func updatePlantillas() {
        UILoader.show(parent: self.view)
        
        // Step 2 Check "PLANTILLAS"
        self.sdkAPI?.DGSDKdownloadTemplates(delegate: self)
            .then{ response in
                
                // Step 3 Check "Variable"
                self.sdkAPI?.DGSDKdownloadVariables(delegate: self)
                    .then { response in
                        UILoader.remove(parent: self.view)
                    }
                    .catch { error in
                        // No se ha podido descargar ninguna variable
                        UILoader.remove(parent: self.view)
                        self.reloadFormatsAndPlantillas()
                }
                
            }
            .catch{ error in
                // No se ha podido descargar ninguna plantilla
                UILoader.remove(parent: self.view)
                self.reloadFormatsAndPlantillas()
        }
    }
}

extension DataViewController {
    @objc func textFieldDidChange(_ searchBar: UISearchBar) {
        // -------------------------------------------------------------------------
        
        if searchBar.text == ""  {
            filteredFormatoData = arrayFormatoData
        }else {
            var resultado : Bool = false
            filteredFormatoData = arrayFormatoData.filter({ arrayFormatoData in
                    //Filtrado por nombre de expediente
                resultado = arrayFormatoData.NombreExpediente.lowercased().contains(searchBar.text!.lowercased())
                if resultado == true {
                    return resultado
                }
                
                    for (ind ,elemen) in arrayFormatoData.ResumenV2.texto.enumerated(){
                    let result : FETextoResumen = arrayFormatoData.ResumenV2.texto[ind]
                        resultado = result.valor.lowercased().contains(searchBar.text!.lowercased())
                        print(result.valor)
                        if resultado == true {
                            return resultado
                        }
                }
                return resultado
            })
        }
        tableview.reloadData()
    }
    
}
