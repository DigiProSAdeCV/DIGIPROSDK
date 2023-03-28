//
//  HomeViewController.swift
//  DIGIPROSDK
//
//  Created by Jorge Alfredo Cruz Acuña on 24/01/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import UIKit

open class HomeMain {
    
   public static func create()->UIViewController{
        let viewVC : HomeViewController? = HomeViewController()
        if let view = viewVC{
            return view
        }
        return UIViewController()
    }
}

enum HomeFEState: Int{
    case Respaldado
  //  case Guardado
    case PorPublicar
 //   case Otros
    
    func getTitle()->String{
        switch self{
        case .Respaldado:
            return "Recuperación"
        case .PorPublicar:
            return "Por publicar"
        }
    }
    
    func getWidth()->CGFloat{
        switch self{
        case .Respaldado:
            return 200
        case .PorPublicar:
            return 150
        }
    }
    
    func getTag()->Int{
        switch self{
        case .Respaldado:
            return 0
        case .PorPublicar:
            return 2
        }
    }
}

class HomeViewController: UIViewController {
    
    lazy var navigationBar: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var multiProcesing: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        [HomeFEState.PorPublicar, HomeFEState.Respaldado].forEach { ele in
            let button = UIButton(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = ele.getTag()
            if ele.getTag() == 2{
                button.backgroundColor = UIColor(hexFromString: "#50B9EE")
            }else{
                button.backgroundColor = UIColor(hexFromString: "#53B64D")
            }
            button.setTitle(ele.getTitle(), for: .normal)
            button.addTarget(self, action: #selector(self.onStateSelectedAction(_:)), for: .touchUpInside)
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: ele.getWidth())
            ])
            stack.addArrangedSubview(button)
        }
        return stack
    }()
    lazy var topContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var bodyContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var profileButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(hexFromString: "#50B9EE")
        btn.layer.cornerRadius = 23
        let image = UIImage(named: "ic_user_login", in: Cnstnt.Path.framework, with: nil)?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor(hexFromString: "#ffffff")
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(self.onShowMenuAction(_:)), for: .touchUpInside)
        btn.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    lazy var tableEletronicFormat: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(HomeViewCell.self, forCellReuseIdentifier:"HomeViewCell")
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        table.delegate = self
        table.dataSource = self
        table.keyboardDismissMode = .onDrag
        return table
    }()
    lazy var filterBox: UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.searchBarStyle = .minimal
        search.placeholder = "Buscar expediente"
        search.backgroundImage = nil
        search.backgroundColor = UIColor(hexFromString: "#f5f7f8")
        search.tintColor = UIColor(hexFromString: "#50B9EE")
        search.updateHeight(height: 45)
        search.delegate = self
        return search
    }()
    lazy var btnAddElectronicFormat: UIButton = {
        let btn = UIButton()
        let image = UIImage(named: "baseline_add_black_48pt", in: Cnstnt.Path.framework, with: nil)?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.backgroundColor = UIColor(hexFromString: "#53B64D")
        btn.tintColor = UIColor(hexFromString: "#ffffff")
        btn.layer.cornerRadius = 30
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 7
        btn.layer.shadowOpacity = 1
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(self.newAction(_:)), for: .touchUpInside)
        return btn
    }()
    var cellSelected: Int = 0
    var tablaIsEmpty: Bool = true
    var numTextResumenV2 = 0
    var sdkAPI : APIManager<HomeViewController>?
    var templateVC : TemplateManager<HomeViewController>?
    var procesosByFlujos = [FEProcesos]()
    var flowsList = [FEPlantillaMerge]()
    var flowSelected : FEPlantillaMerge?
    var formatStateSelected: HomeFEState = .PorPublicar
    var formatListByFlow = [FEFormatoData]()
    var hud: JGProgressHUD = JGProgressHUD(style: .dark)
    var formatFilterListByFlow = [FEFormatoData](){
        didSet{
            DispatchQueue.main.async {
                self.tableEletronicFormat.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
        onLoadUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        reloadDataFromFlujoAndProceso(flowID: flowSelected?.FlujoID ?? 0)
    }
    
    private func setupUI(){
        view.backgroundColor = UIColor(hexFromString: "#f5f7f8")
        view.addSubview(navigationBar)
        view.addSubview(topContainer)
        navigationBar.addSubview(multiProcesing)
        topContainer.addSubview(profileButton)
        topContainer.addSubview(filterBox)
        view.addSubview(bodyContainer)
        bodyContainer.addSubview(tableEletronicFormat)
        bodyContainer.addSubview(btnAddElectronicFormat)
    }
    
    private func setupConstraint(){
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 45),
            
            multiProcesing.topAnchor.constraint(equalTo: navigationBar.topAnchor),
            multiProcesing.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            multiProcesing.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
            multiProcesing.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
            multiProcesing.heightAnchor.constraint(equalToConstant: 45),
            multiProcesing.widthAnchor.constraint(equalToConstant: [HomeFEState.PorPublicar, HomeFEState.Respaldado].reduce(0, { $0 + $1.getWidth() })),
            
            topContainer.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 60),
            
            profileButton.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            profileButton.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 10),
            profileButton.widthAnchor.constraint(equalToConstant: 46),
            profileButton.heightAnchor.constraint(equalToConstant: 46),
            
            filterBox.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            filterBox.leadingAnchor.constraint(equalTo: profileButton.trailingAnchor, constant: 10),
            filterBox.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -10),
            
            bodyContainer.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            bodyContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bodyContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bodyContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableEletronicFormat.topAnchor.constraint(equalTo: bodyContainer.topAnchor),
            tableEletronicFormat.leadingAnchor.constraint(equalTo: bodyContainer.leadingAnchor),
            tableEletronicFormat.trailingAnchor.constraint(equalTo: bodyContainer.trailingAnchor),
            tableEletronicFormat.bottomAnchor.constraint(equalTo: bodyContainer.bottomAnchor),
            
            btnAddElectronicFormat.heightAnchor.constraint(equalToConstant: 60),
            btnAddElectronicFormat.widthAnchor.constraint(equalToConstant: 60),
            btnAddElectronicFormat.trailingAnchor.constraint(equalTo: bodyContainer.trailingAnchor, constant: -10),
            btnAddElectronicFormat.bottomAnchor.constraint(equalTo: bodyContainer.bottomAnchor, constant: -30)
        ])
    }
    
    private func onLoadUI(){
        sdkAPI = APIManager<HomeViewController>()
        templateVC = TemplateManager<HomeViewController>()
        sdkAPI?.delegate = self
        templateVC?.delegate = self
        displayListenersOnTabs()
        detectPermissionNewFormat()
        getAllData()
    }
    
    private func displayListenersOnTabs(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFlowsDisplayAction), name: NSNotification.Name("NotificationOnFlowsHomeDisplayAction"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatingToServerAction), name: NSNotification.Name("NotificationOnUploadHomeDisplayAction"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.consultAction), name: NSNotification.Name("NotificationOnConsultHomeDisplayAction"), object: nil)
    }
    
    private func detectPermissionNewFormat(){
        if ConfigurationManager.shared.usuarioUIAppDelegate.PermisoNuevoFormato{
            btnAddElectronicFormat.isEnabled = true
        }else{
            let userDefaults_serial = String(UserDefaults.standard.string(forKey: Cnstnt.BundlePrf.serial) ?? "")
            if userDefaults_serial.sha512() == "07eeb356a2b2297563b4e7cb245387b19b341afd31e58d0bed678449062aa462fd28d78732c62ffeeb73ccbbf45c077d271f4a8f10803dab48597f477e76eaf2"{
                btnAddElectronicFormat.isEnabled = true
            }else{
                btnAddElectronicFormat.isEnabled = false
            }
        }
    }
    private func getAllData(_ user: Bool = false){
        self.showLoader()
        self.sdkAPI?.DGSDKdownloadData(delegate: self)
            .then({ response in
                print("Aqui me puedo atorar final")
                self.reloadFormatsAndPlantillas()
            }).catch({ error in
                print("Aqui me puedo atorar final error")
                self.reloadFormatsAndPlantillas()
            })
    }
    
    private func showLoader(){
        DispatchQueue.main.async {
            guard let view = UIApplication.shared.windows.first?.rootViewController?.view else{return}
            self.hud = JGProgressHUD(style: .dark)
            self.hud.show(in: self.view)
        }
    }
    private func dissmisLoader(){
        DispatchQueue.main.async {
            guard let view = UIApplication.shared.windows.first?.rootViewController?.view else{return}
            self.hud.dismiss(animated: true)
        }
    }
    
    private func reloadFormatsAndPlantillas(){
        self.sdkAPI?.DGSDKgetFlows(delegate: self)
            .then { response in
                self.dissmisLoader()
                DispatchQueue.main.async {
                    self.flowsList = response
                    self.flowSelected = response.first
                    if self.flowSelected?.FlujoID != 0{
                        self.reloadDataFromFlujoAndProceso(flowID: self.flowSelected?.FlujoID ?? 0)
                    }
                }
            }.catch { error in
                self.dissmisLoader()
            }
    }
    private func reloadDataFromFlujoAndProceso(flowID: Int){
        formatListByFlow = (sdkAPI?.DGSDKgetAllFormatos(flowID))!.sorted(by: { fefdold, fefdnew in
            let formatter = DateFormatter()
            formatter.calendar = .current
            formatter.locale = .current
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            let firstDate = formatter.date(from: fefdold.FechaFormato) ?? Date()
            let secondDate = formatter.date(from: fefdnew.FechaFormato) ?? Date()
            return firstDate > secondDate
        })
        filterBox.text = ""
        filterAll()
        refreshTitleState()
    }
    
    
    private func filterAll(){
        guard let searchString = filterBox.text?.lowercased(), searchString != "" else{
            let temporalFlowFilter = formatListByFlow.filter { fe in
                return fe.EstadoApp == formatStateSelected.getTag()
            }
            formatFilterListByFlow = temporalFlowFilter
            return
        }
        let temporalFilter = formatListByFlow.filter { fEFormatoData in
            return  fEFormatoData.NombreExpediente.lowercased().contains(searchString) ||
                    fEFormatoData.ResumenV2.texto.contains(where: { fETextoResumen in
                        return fETextoResumen.valor.lowercased().contains(searchString)
                    })
                    
        }
        
        let temporalFlowFilter = temporalFilter.filter { fe in
            return fe.EstadoApp == formatStateSelected.getTag()
        }
        formatFilterListByFlow = temporalFilter
    }
    
    private func refreshTitleState(){
        let menu =  [HomeFEState.PorPublicar,HomeFEState.Respaldado]
        for (n,x) in multiProcesing.arrangedSubviews.enumerated(){
            let temporalFlowFilter = formatListByFlow.filter { fe in
                return fe.EstadoApp == menu[n].getTag()
            }
            (x as? UIButton)?.setTitle("\(menu[n].getTitle()) (\(temporalFlowFilter.count))", for: .normal)
        }
    }
    private func setCurrentFormIphone(_ index: Int, _ isPreview: Bool = false){
        let presenter = NuevaPlantillaViewController(self, self.formatFilterListByFlow[index], index, isPreview)
         self.navigationController?.pushViewController(presenter, animated: true)
    }
    private func setCurrentFormIphone(_ formato: FEFormatoData, _ isPreview: Bool = false){
        let presenter = NuevaPlantillaViewController(self, formato, 0, isPreview)
        self.navigationController?.pushViewController(presenter, animated: true)
    }
    private func deleteFormatoFromLocal(formato: FEFormatoData){
        
        let alert = UIAlertController(title: "alrt_warning".langlocalized(), message: "alrt_delete_form".langlocalized(), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "alrt_accept".langlocalized(), style: .default, handler: { action in
            switch action.style{
            case .default:
                self.sdkAPI?.DGSDKformatoDelete(delegate: self, formato: formato)
                .then({ response in
                    self.reloadDataFromFlujoAndProceso(flowID: self.flowSelected?.FlujoID ?? 0)
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
    
    @objc private func onShowMenuAction(_ sender: UIButton){
        NotificationCenter.default.post(name: NSNotification.Name("OpenMenu"), object: nil)
        
    }
    @objc private func onStateSelectedAction(_ sender: UIButton){
        for e in multiProcesing.arrangedSubviews{
            (e as? UIButton)?.backgroundColor = (e as? UIButton)?.tag == sender.tag ? UIColor(hexFromString: "#50B9EE") : UIColor(hexFromString: "#53B64D")
        }
        formatStateSelected = HomeFEState.init(rawValue: sender.tag) ?? .PorPublicar
        filterBox.text = ""
        filterAll()
    }
    @objc private func onFlowsDisplayAction(){
        let flowlist = FlujoMain.create(flowsList: flowsList, delegate: self)
        flowlist.modalPresentationStyle = .overFullScreen
        self.present(flowlist, animated: true)
    }
    @objc private func newAction(_ sender: UIButton){
        FormularioUtilities.shared.globalFlujo = flowSelected?.FlujoID ?? 0
        let preview = NuevoFEViewController(nibName: "emLdqYbDHhCnxHu", bundle: Cnstnt.Path.framework)
        preview.dataviewDelegate = self
        preview.view.frame.size.width = (self.view.frame.size.width) - 60
        preview.view.frame.size.height = (self.view.frame.size.height - 120)
        let presenter = Presentr(presentationType: .bottomHalf)
        self.customPresentViewController(presenter, viewController: preview, animated: true, completion: nil)
    }
    @objc private func editAction(_ tag: NSInteger){
        self.sdkAPI?.DGSDKformatEdit(delegate: self, formato: self.formatFilterListByFlow[tag], true, false)
            .then({ response in
                self.setCurrentFormIphone(response)
            }).catch({ error in
                UILoader.remove(parent: self.view)
            })
    }
    @objc private func trashAction(_ tag: NSInteger){
        _ = popupGeneric(parent: self,
                        delegate: self,
                        title: "Borrar",
                        message: "Como quieres borrar el formato.",
                        showOptionalButton: true,
                        optionalButtonTitleText: "Cerrar")

    }
    @objc private func previewAction(_ tag: NSInteger){
        self.setCurrentFormIphone(tag, true)
    }
    @objc private func pdfAction(_ tag: NSInteger){
        showLoader()
        self.sdkAPI?.DGSDKformatPDF(delegate: self, formato: self.formatFilterListByFlow[tag])
            .then({ response in
                self.dissmisLoader()
                WebPDFViewController.show(in: self, pdfString: response)
            })
            .catch({ _ in
                self.dissmisLoader()
                let alert = UIAlertController(title: "Aviso", message: "Documento no encontrado", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Aceptar", style: .default))
                self.present(alert, animated: true)
               
            })
    }
    @objc private func consultAction(){
        let consultas = ConsultasViewController(nibName: "pgimMPyRuzVHuFF", bundle: Cnstnt.Path.framework)
        present(consultas, animated: true)
    }
    @objc private func updatingToServerAction(){
        showLoader()
        // Setting process
        // 1 SyncFormats
        // 2 SendFormats
        // 3 DownloadFormats
        DispatchQueue.global(qos: .background).async {
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
                                        self.dissmisLoader()
                                        self.reloadDataFromFlujoAndProceso(flowID: self.flowSelected?.FlujoID ?? 0)
                                      //  self.getNotification()
                                    }.catch { error in
                                        self.dissmisLoader()
                                        self.reloadDataFromFlujoAndProceso(flowID: self.flowSelected?.FlujoID ?? 0)
                                    }
                            }).catch({ error in
                                self.dissmisLoader()
                                self.reloadDataFromFlujoAndProceso(flowID: self.flowSelected?.FlujoID ?? 0)
                            })
                    }).catch({ error in
                        self.dissmisLoader()
                        self.reloadDataFromFlujoAndProceso(flowID: self.flowSelected?.FlujoID ?? 0)
                    })
            }.catch { error in
                self.dissmisLoader()
                self.reloadDataFromFlujoAndProceso(flowID: self.flowSelected?.FlujoID ?? 0)
            }
        }
        
    }
    @objc private func searchAction(){
        filterAll()
    }
    
    private func showAlertMessage(message: String){
        let alert = UIAlertController(title: "Alerta", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default, handler: { _ in }))
       DispatchQueue.main.async {
           self.present(alert, animated: true, completion: nil)
       }
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formatFilterListByFlow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = formatFilterListByFlow[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeViewCell", for: indexPath) as? HomeViewCell{
            cell.selectionStyle = .none
            var stringToSetNSValues : String = ""
            object.ResumenV2.texto.forEach { resumenText in
                stringToSetNSValues.append("\(resumenText.valor)\n")
            }
            
            cell.deleteBtn.isHidden = object.EstadoApp == 2 ? false : true
            cell.pdfBtn.isHidden = object.EstadoApp == 2 ? true : false
            cell.moreDescription.text = stringToSetNSValues
            cell.tag = indexPath.row
            cell.delegate = self
            if let flowNoNIL = flowSelected?.MostrarExp, flowNoNIL == true{
                cell.titleTemplate.text = object.NombreExpediente
            }else{
                cell.titleTemplate.text = ""
                
            }
            if let flowNoNIL = flowSelected?.MostrarTipoDoc, flowNoNIL == true{
                cell.descriptionTemplate.text = object.NombreTipoDoc
            }else{
                cell.descriptionTemplate.text = ""
                
            }
            return cell
        }
        return UITableViewCell()
    }
}

extension HomeViewController: HomeViewCellProtocol{
    func notifyOptionSelected(option: HomeViewCellOptions, tag: Int) {
        switch option{
        case .Edit:
            if ConfigurationManager.shared.usuarioUIAppDelegate.PermisoEditarFormato{
                cellSelected = tag
                editAction(cellSelected)
            }else{
                showAlertMessage(message: "No cuentas con permisos para realizar esta acción, contacta a tu administrador")
            }
            break
        case .Delete:
            if ConfigurationManager.shared.usuarioUIAppDelegate.PermisoBorrarFormato{
                cellSelected = tag
                trashAction(cellSelected)
            }else{
                showAlertMessage(message: "No cuentas con permisos para realizar esta acción, contacta a tu administrador")
            }
            break
        case .Look:
            if ConfigurationManager.shared.usuarioUIAppDelegate.PermisoVisualizarFormato{
                cellSelected = tag
                previewAction(cellSelected)
            }else{
                showAlertMessage(message: "No cuentas con permisos para realizar esta acción, contacta a tu administrador")
            }
            break
        case .PDF:
            cellSelected = tag
            pdfAction(tag)
            break
        }
    }
    
    func notifyShow(tag: Int) {
        formatFilterListByFlow[tag].isSelected = !formatFilterListByFlow[tag].isSelected
        tableEletronicFormat.reloadData()
    }
}

extension HomeViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchAction), object: nil)
        self.perform(#selector(self.searchAction), with: nil, afterDelay: 0.5)
    }
}

extension HomeViewController: FlujoVCDelegate{
    func onFlowSelected(flowSelected: FEPlantillaMerge?) {
        self.flowSelected = flowSelected
        if self.flowSelected?.FlujoID != 0{
            reloadDataFromFlujoAndProceso(flowID: flowSelected?.FlujoID ?? 0)
        }
    }
}

extension HomeViewController: popupGenericProtocol{
    public func notifyAcceptWithTag(tag: Int) {
        self.deleteFormatoFromLocal(formato: formatFilterListByFlow[cellSelected])
    }
}

extension HomeViewController : ControllerDelegate{
    func performConsultaViewController(_ index: Int) {}
    
    func performNuevoFeViewController(_ plantilla: FEPlantillaData, _ index: Int) {
        let destination = NuevaPlantillaViewController(self, plantilla, index, false)
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func performFlowSelection(_ index: Int) {}
    
    func updatePlantillas() {}
    
}

extension HomeViewController: APIDelegate{}
extension HomeViewController: TemplateDelegate{
    func didFormatViewFinish(error: NSError?, success: [String : Any]?) {}
}
