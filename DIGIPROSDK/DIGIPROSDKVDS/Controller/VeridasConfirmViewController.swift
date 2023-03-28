//
//  VeridasConfirmViewController.swift
//  DIGIPROSDK
//
//  Created by SANDRA SOTO  on 27/07/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//
import UIKit

public protocol BackVeridasConfirmActionDelegate {
    func processConfirmFinished(
        _ message: String)
    func failureConfirmation(_ message: String)
}

class VeridasConfirmViewController: UIViewController {

    private var token: String = ""
    var sdkAPI : APIManager<VeridasConfirmViewController>?
    var delegateConfirmVeridas : BackVeridasConfirmActionDelegate?
    
    init(token: String) {
        super.init(nibName: nil, bundle: .main)
        self.token = token
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sdkAPI = APIManager<VeridasConfirmViewController>()
        self.sdkAPI?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getConfirmation()
    }
    /// Metodo que llama al servicio de confirmar del proceso con Veridas
    public func getConfirmation() {
        UILoader.show(parent: self.view)
        let dictService: [String : Any] = ["tokenid":self.token]
        DispatchQueue.global(qos: .background).async {
            self.sdkAPI?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioVeridas.ConfirmValidation", assemblypath: "ServiciosDigipro.dll", data: dictService).then({ response in
                UILoader.remove(parent: self.view)
                do {
                    let dict = try JSONSerializer.toDictionary(response)
                    guard let answer = dict["response"] as? NSMutableDictionary else { return }
                    if answer["success"] as! Bool == true && answer["servicemessage"] as? String ?? "" == "Expediente confirmado" {
                        self.delegateConfirmVeridas?.processConfirmFinished("Se confirmó el expediente correctamente")
                        VeridasValidation.token = ""
                        VeridasValidation.challenge = ""
                        self.dismiss(animated: true)
                    }
                    else{
                        UILoader.remove(parent: self.view)
                        self.dismiss(animated: true)
                        self.delegateConfirmVeridas?.failureConfirmation("Hubo un error al confirmar datos")
                    }
                } catch {
                    UILoader.remove(parent: self.view)
                    print("No fue posible serializar reponse")
                    self.dismiss(animated: true)
                    self.delegateConfirmVeridas?.failureConfirmation("Hubo un error al confirmar datos")
                }
            }).catch({ error in
                UILoader.remove(parent: self.view)
                self.dismiss(animated: true)
                self.delegateConfirmVeridas?.failureConfirmation("Error al intentar confirmar \(error.localizedDescription)")
            })
        }
    }
}

// MARK:  APIDelegate
extension VeridasConfirmViewController: APIDelegate {
    func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
    func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
    func sendStatusCodeMessage(message: String, error: enumErrorType) {}
    func didSendError(message: String, error: enumErrorType) {}
    func didSendResponse(message: String, error: enumErrorType) {}
    func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
}
