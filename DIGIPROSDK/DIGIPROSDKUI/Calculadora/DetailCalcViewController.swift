//
//  DetailCalcViewController.swift
//  DIGIPROSDKUI
//
//  Created by Alejandro López Arroyo on 24/03/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import UIKit


class DetailCalcViewController: UIViewController, APIDelegate, UINavigationControllerDelegate, TemplateDelegate {
    func didFormatViewFinish(error: NSError?, success: [String : Any]?) {
        if ConfigurationManager.shared.isConsubanco
        {   let homeController = self.tabBarController?.viewControllers?[0]
            homeController?.view.isHidden = false
            self.tabBarController?.selectedIndex = 0
        }
    }    
    
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendToServerFormatos() { }
    public func isVisibleHUD() { }
    public func didSendError(message: String, error: enumErrorType) {
        print("MESSAGE: \(message)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(850)) {
            let bannerNew = StatusBarNotificationBanner(title: "\(message)", style: .warning)
            bannerNew.show(bannerPosition: .bottom)
        }

    }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var agreementLabel: UILabel!
    @IBOutlet weak var enterpriseLabel: UILabel!
    @IBOutlet weak var creditTypeLabel: UILabel!
    @IBOutlet weak var quoteView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var labelCovenant: UILabel!
    @IBOutlet weak var labelCompany: UILabel!
    @IBOutlet weak var labelCreditType: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelDiscount: UILabel!
    @IBOutlet weak var labelRates: UILabel!
    @IBOutlet weak var labelCat: UILabel!
    @IBOutlet weak var labelMonths: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var labelDescX: UILabel!
    
    fileprivate var completion: (() -> ())? = nil
    fileprivate static var animationDuration = 0.4
    
    var formatoData: FEFormatoData = FEFormatoData()
    public var dataviewDelegate: ControllerDelegate?
    var plantillaData = FEPlantillaData()
    var sdkAPI : APIManager<DetailCalcViewController>?
    var ElementosArray = NSMutableDictionary()
    var amount: String = ""
    var cat: String = ""
    var tasaAnual: String = ""
    var producto: String = ""
    var productName: String = ""
    var empresa: String = ""
    var convenio: String = ""
    var plazo: String = ""
    var periodicidadd: String = ""
    var montoTotal: String = ""
    var convenioId: String = ""
    var productId: String = ""
    var cncaFlag: Bool = false
    var sameDiscountFlag: Bool = false
    var productCategory: String = ""
    var openingCommissionAmount: String = ""
    var discount: String = ""
    var discountX: String = ""
    var priceGroupId: String = ""
    var formatoResponse = FEFormatoData()
    var aop: Bool = false
    var branchName: String = ""
    var enterpriseName: String = ""
    var biometricsException: String = ""
    
    init() { super.init(nibName: "DetailCalcViewController", bundle: Cnstnt.Path.framework) }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        sdkAPI = APIManager<DetailCalcViewController>()
        sdkAPI?.delegate = self
        self.containerView.layer.cornerRadius = 5.0
        self.quoteView.layer.cornerRadius = 21.0
        self.quoteView.layer.borderWidth = 2.5
        self.titleView.layer.cornerRadius = 4.0
        self.navigationController?.delegate = self
        let opacity:CGFloat = 0.6
        self.quoteView.layer.borderColor = UIColor(hexFromString: "4877B6").withAlphaComponent(opacity).cgColor
        self.requestButton.layer.cornerRadius = 18.0
        self.getStoredPlantillas()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
         self.getStoredPlantillas()
    }

    @IBAction func requestAction(_ sender: UIButton) {
        UIView.animate(withDuration: DetailCalcViewController.animationDuration, animations: { [weak self] in
            self?.view.alpha = 0.0
        }) { [weak self] (_) in
            //self?.callForm()
            if self!.aop{
                self?.quotePrefill()
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(850)) {
                    let bannerNew = StatusBarNotificationBanner(title: "Convenio no habilitado para solicitud e-csb.", style: .danger)
                    bannerNew.show(bannerPosition: .bottom)
                }
            }
            
//            self?.view.removeFromSuperview()
//            self?.removeFromParent()
//            self?.completion?()
            
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        UIView.animate(withDuration: DetailCalcViewController.animationDuration, animations: { [weak self] in
            self?.view.alpha = 0.0
        }) { [weak self] (_) in
            self?.view.removeFromSuperview()
            self?.removeFromParent()
            self?.completion?()
        }
    }
    
    func quotePrefill(){
        UILoader.show(parent: self.view)
        
        self.amount = self.amount.replacingOccurrences(of: "$", with: "")
        self.amount = self.amount.replacingOccurrences(of: ",", with: "")
        self.discount = self.discount.replacingOccurrences(of: "$", with: "")
        self.discount = self.discount.replacingOccurrences(of: ",", with: "")
        self.montoTotal = self.montoTotal.replacingOccurrences(of: "$", with: "")
        self.montoTotal = self.montoTotal.replacingOccurrences(of: ",", with: "")
        self.discountX = self.discountX.replacingOccurrences(of: "$", with: "")
        self.tasaAnual = self.tasaAnual.replacingOccurrences(of: "%", with: "")
        self.cat = self.cat.replacingOccurrences(of: "%", with: "")
        let montoEq = 1.00
        let dictService = ["initialmethod":"ServiciosConsubanco.ServicioCalculadora.PrellenadoCotizacion", "assemblypath": "ServiciosConsubanco.dll", "data": ["user": ConfigurationManager.shared.usuarioUIAppDelegate.User, "proyid": "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)", "prellenado_monto":"\(self.amount)", "prellenado_plazo":"\(self.plazo)", "prellenado_montoequivalente": "\(montoEq)","prellenado_openingCommissionPercentage":"1.00", "prellenado_cat":"\(self.cat)", "prellenado_tasaanual":"\(self.tasaAnual)", "prellenado_empresa":"\(self.empresa)", "prellenado_convenio":"\(self.convenio)", "prellenado_producto":"\(self.productName)", "prellenado_periodicidad":"\(self.periodicidadd)", "prellenado_montototal":"\(self.montoTotal)", "prellenado_convenioid":"\(self.convenioId)","convenioid":"\(self.convenioId)", "prellenado_productoid": "\(self.productId)","prellenado_cnca":self.cncaFlag, "prellenado_mismodescuento":self.sameDiscountFlag, "prellenado_productcategory":"\(self.productCategory)", "prellenado_openingCommissionAmount":"\(self.openingCommissionAmount)", "prellenado_descuento":"\(self.discount)", "prellenado_descuentoxmil":"\(self.discountX)", "prellenado_priceGroupId":"\(self.priceGroupId)", "prellenado_enterpriseName":"\(self.enterpriseName)", "prellenado_branchName":"\(self.branchName)", "biometricsExceptionProtocol": "\(self.biometricsException)"]] as [String : Any]
        ConfigurationManager.shared.assemblypath = "ServiciosConsubanco.dll"
        ConfigurationManager.shared.initialmethod = "ServiciosConsubanco.ServicioCalculadora.PrellenadoCotizacion"
        let jsonData = try! JSONSerialization.data(withJSONObject: dictService, options: JSONSerialization.WritingOptions.sortedKeys)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        print("JSON STRING: \(jsonString)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(850)) {
            self.sdkAPI?.serviceQuotePrefill(delegate: self, jsonService: jsonString)
                .then{ response in
                    print("RESPONSE FEFORMATO: \(response)")
                    self.formatoResponse = response
                    self.callForm()
                    UILoader.remove(parent: self.view)
                }.catch{ error in UILoader.remove(parent: self.view); print("ERROR: \(error)") }
            
        }
    }
    
    func callForm(){
        
        ConfigurationManager.shared.isInEditionMode = false
        ConfigurationManager.shared.isDismissable = true
        let destination = NuevaPlantillaViewController(self, plantillaData, 0, false)
        
        let completionHandler: ((NuevaPlantillaViewController), [String : Any]?, NSError?)->Void = { childVC, status, error in
            childVC.resignFirstResponder()
            childVC.removeFromParent()
            guard let e = error else{
                guard let s = status else{
                    print("An un expected error occurred")
                    return
                }
                print("The format throws status: \(s)")
                self.didFormatViewFinish(error: error, success: status)
                return
            }
            print("You canceled the format: \(e)")
            self.didFormatViewFinish(error: error, success: status)
        }
        destination.completionHandler = completionHandler
        destination.modalTransitionStyle = .coverVertical
        destination.modalPresentationStyle = .overFullScreen
        
        destination.index = 0
        destination.flujo = self.formatoResponse.FlujoID
        destination.proceso = 0
        destination.flagCalculadora = true
        self.formatoResponse.FlujoID = 5

        destination.arrayPlantillaData = plantillaData
        let navigation = UINavigationController(rootViewController: destination)
        navigation.modalPresentationStyle = .fullScreen
        navigation.isNavigationBarHidden = true
        
        FormularioUtilities.shared.currentFormato = self.formatoResponse
        self.present(navigation, animated: true, completion: nil)
    }
    
    func callLoadingRightAfter(){
        if ConfigurationManager.shared.isConsubanco
        {   let homeController = self.tabBarController?.viewControllers?[0]
            homeController?.view.isHidden = false
            self.tabBarController?.selectedIndex = 0
        }
        
//        let homeController = ((self.tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] as? CalculadoraViewController)
//
//        homeController?.hud = JGProgressHUD(style: .dark)
//        homeController?.hud?.textLabel.text = "LoadingRightAfter"
//        homeController?.hud?.show(in: (homeController?.view)!)
//
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        view.backgroundColor = UIColor.red
//        homeController?.view.addSubview(view)
//        homeController?.view.bringSubviewToFront(view)
//
//        homeController?.view.layoutIfNeeded()
    }
    
    public func generateJson() -> String{

        self.ElementosArray = NSMutableDictionary()
        let arrayIds = [
            (id: "formElec_element7", valor: "Empresa", valorm: "Empresa"),
            (id: "formElec_element8", valor: "Convenio", valorm: "Convenio"),
            (id: "formElec_element9", valor: "Producto", valorm: "Producto"),
            (id: "formElec_element10", valor: "12345", valorm: "12345"),
            (id: "formElec_element11", valor: "Plazo", valorm: "Plazo"),
            (id: "formElec_element12", valor: "Tipo de trámite", valorm: "Tipo de trámite"),
            (id: "formElec_element13", valor: "Parcial", valorm: "Parcial"),
            (id: "formElec_element14", valor: "Destino de crédito", valorm: "Destino de crédito"),
        ]
        for i in arrayIds{
            let prod: NSMutableDictionary = NSMutableDictionary();
            prod.setValue(i.valor, forKey: "valor");
            prod.setValue(i.valorm, forKey: "valormetadato");
            self.ElementosArray.setValue(prod, forKey: i.id)
        }
        
        if let theJsonDataArray = try? JSONSerialization.data(withJSONObject: ElementosArray, options: .sortedKeys){
            let theJsonText = String(data: theJsonDataArray, encoding: String.Encoding.utf8)!
            //txtView.text = theJsonText
            return theJsonText
        }
        return ""
    }
    
    public func getStoredPlantillas(){
        let plantillas = (self.sdkAPI?.DGSDKgetTemplates("\(self.formatoResponse.FlujoID)"))!
        for group in plantillas{
            for plantilla in group.1{

                if plantilla.NombreTipoDoc == "\(self.formatoResponse.NombreTipoDoc)" && plantilla.NombreExpediente == "\(self.formatoResponse.NombreExpediente)"{
                    plantillaData = plantilla
                }
            }
        }
    }

}
 

extension DetailCalcViewController {
    
    public func show(in viewcontroller: UIViewController, title: String, month: String, amount: String, discount: String, rate: String, cat: String, covenant: String, company: String, creditType: String,total: String,descX: String, plazo: String, periodicidad: String, convenioId: String, productId: String, cnca: Bool, sameDiscount: Bool, productCategory: String, openingCommissionAmount: String, aop: Bool, priceGroupId: String, productN: String, branchN: String, biometricsException: String, completion: (() -> ())? = nil) {
        let alert = DetailCalcViewController()
        alert.view.frame = viewcontroller.view.bounds
        alert.labelTitle.text = title
        alert.producto = title
        alert.labelMonths.text = month
        alert.labelAmount.text = amount
        alert.amount = amount
        alert.labelDiscount.text = discount
        alert.labelRates.text = rate
        alert.tasaAnual = rate
        alert.labelCat.text = cat
        alert.cat = cat
        alert.labelCovenant.text = "Convenio: \(covenant)"
        alert.convenio = covenant
        alert.labelCompany.text = "Empresa: \(company)"
        alert.enterpriseName = company
        alert.empresa = company
        alert.labelCreditType.text = "Tipo de Credito: \(creditType)"
        alert.labelTotal.text = total
        alert.montoTotal = total
        alert.labelDescX.text = descX
        alert.discount = discount
        alert.discountX = descX
        alert.plazo = plazo
        alert.periodicidadd = periodicidad
        alert.convenioId = convenioId
        alert.productId = productId
        alert.cncaFlag = cnca
        alert.aop = aop
        alert.priceGroupId = priceGroupId
        alert.sameDiscountFlag = sameDiscount
        alert.productCategory = productCategory
        alert.openingCommissionAmount = openingCommissionAmount
        alert.productName = productN
        alert.branchName = branchN
        alert.biometricsException = biometricsException
        alert.view.alpha = 0.0
        alert.completion = completion
        alert.navigationController?.delegate = self
        viewcontroller.addChild(alert)
        alert.didMove(toParent: viewcontroller)
        viewcontroller.view.addSubview(alert.view)
        UIView.animate(withDuration: DetailCalcViewController.animationDuration) {
            alert.view.alpha = 1.0
        }
    }
    
}
