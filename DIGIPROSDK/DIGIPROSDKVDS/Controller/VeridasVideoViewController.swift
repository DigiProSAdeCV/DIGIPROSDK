//
//  VeridasVideoViewController.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 22/07/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import UIKit
import VDVideoSelfieCapture

protocol BackVideoVeridasActionDelegate: AnyObject {
    func successfulProcess(dataOCR incomeData: FEOcrVeridas, path videoPath: String, withToken token: String, message text: String)
    // Possible Mistakes.
    func failureUploadVideo(message text: String)
    func failureGetValidation(message text: String)
}

class VeridasVideoViewController: UIViewController {
    
    private var sdkDelegate: APIManager<VeridasVideoViewController>?
    private var token: String = ""
    private var docType: String = ""
    private var hud: JGProgressHUD?
    public weak var delegateVideoVeridas: BackVideoVeridasActionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sdkDelegate = APIManager<VeridasVideoViewController>()
        sdkDelegate?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = UIColor.clear
        let configuration: [String : String] = ["closebutton": "YES","documentmobileoval": "YES"]
        if !VDVideoSelfieCapture.isStarted() {
            // This document is retrieved, when possible, from VDDocumentCapture
            VDVideoSelfieCapture.setDocumentStringToSearch(self.docType)
            VDVideoSelfieCapture.start(withDelegate: self, andConfiguration: configuration)
        }
    }
    
    // MARK: Init
    init(token: String, docType: String) {
        super.init(nibName: nil, bundle: Cnstnt.Path.framework)
        self.token = token
        self.docType = docType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        VDVideoSelfieCapture.stop()
    }
    
    private func stopVideoSelfieCapture() {
        if VDVideoSelfieCapture.isStarted() {
            VDVideoSelfieCapture.stop()
        }
    }
    
    // MARK: Services.
    private func uploadVideoWithOptions(tokenService: String, videoBase64: String) {
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = "hud_validation".langlocalized()
        hud?.show(in: self.view)
        
        let dictionaryService: [String : Any] = ["proyid": "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)", "tokenid": tokenService, "video": videoBase64]
        DispatchQueue.main.async {
            self.sdkDelegate?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioVeridas.UploadVideo", assemblypath: "ServiciosDigipro.dll", data: dictionaryService).then({ response in
                self.hud?.dismiss(animated: true)
                do {
                    let dictionary = try JSONSerializer.toDictionary(response)
                    guard let myData = dictionary["response"] as? NSMutableDictionary else {
                        return
                    }
                    if myData["servicemessage"] as? String != nil {
                        self.getVideoValidation(tokenString: tokenService, videoBase64: videoBase64)
                        self.hud?.dismiss(animated: true)
                        
                    } else {
                        self.hud?.dismiss(animated: true)
                        self.dismiss(animated: true)
                        self.delegateVideoVeridas?.failureUploadVideo(message: "El video no contiene el formato correcto.")
                    }
                } catch {
                    print("Error al deserializar el servicio.")
                    self.hud?.dismiss(animated: true)
                    self.delegateVideoVeridas?.failureUploadVideo(message: "El video no contiene el formato correcto.")
                    self.dismiss(animated: true)
                }
                
            }).catch({ error in
                self.delegateVideoVeridas?.failureUploadVideo(message: "Error en servicio al subir video \(error.localizedDescription)")
                self.hud?.dismiss(animated: true)
                self.dismiss(animated: true)
            })
        }
        
    }
    
    private func getVideoValidation(tokenString: String, videoBase64: String) {
        let dictServiceDocument: [String : Any] = ["tokenid" : tokenString]
        
        DispatchQueue.global(qos: .background).async {
            self.sdkDelegate?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioVeridas.Validation", assemblypath: "ServiciosDigipro.dll", data: dictServiceDocument).then({ response in
                do {
                    let dict = try JSONSerializer.toDictionary(response)
                    guard let serviceDict = dict["data"] as? NSMutableDictionary else { return }
                    
                    let ocrVeridas = FEOcrVeridas(dictionary: serviceDict)
                    ocrVeridas.fullName = "\(ocrVeridas.PD_Name_Out)"
                    print(ocrVeridas)
                    let path = "\(ConfigurationManager.shared.guid)_SelfieVideo_Veridas_\(ConfigurationManager.shared.utilities.guid()).mp4"
                    // recibe un base64, convierte a data y despues a Video
                    let videoData = Data(base64Encoded: videoBase64) ?? Data()
                    _ = ConfigurationManager.shared.utilities.saveVideoToFolder(videoData, path)
                    
                    self.delegateVideoVeridas?.successfulProcess(dataOCR: ocrVeridas, path: path, withToken: tokenString, message: "Operación Exitosa, Validación de prueba de vida con documentos.")
                    self.dismiss(animated: true)
                    
                } catch {
                    self.delegateVideoVeridas?.failureGetValidation(message: "Error al validar score de la prueba de vida.")
                    self.dismiss(animated: true)
                }
            }).catch({ error in
                self.delegateVideoVeridas?.failureGetValidation(message: "Error en servicio de validación de prueba de vida: \(error.localizedDescription)")
                self.dismiss(animated: true)
            })
        }
    }
}
extension VeridasVideoViewController: VDVideoSelfieCaptureProtocol {
    func vdVideoSelfieCaptured(_ videoSelfieData: Data!) {}
    
    func vdVideoSelfieCaptured(_ videoSelfieData: Data!, withProcessInfo processInfo: Data!) {
        let defaults = UserDefaults.standard
        let path = "\(ConfigurationManager.shared.guid)_SelfieVideo_Veridas_\(ConfigurationManager.shared.utilities.guid()).mp4"
        let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(videoSelfieData as NSData, path)
        defaults.set(videoSelfieData, forKey: "VideoSelfie")
    }
    
    func vdVideoSelfieAllFinished(_ processFinished: Bool) {
        if processFinished {
            let defaults = UserDefaults.standard
            
            guard let video = defaults.data(forKey: "VideoSelfie") else { return }
            let videoBase64: String = video.base64EncodedString()
            
            self.uploadVideoWithOptions(tokenService: self.token, videoBase64: videoBase64)
            
            print("Terminando de cerrar la info del video.")
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK:  APIDelegate
extension VeridasVideoViewController: APIDelegate {
    func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
    func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
    func sendStatusCodeMessage(message: String, error: enumErrorType) {}
    func didSendError(message: String, error: enumErrorType) {}
    func didSendResponse(message: String, error: enumErrorType) {}
    func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
}
