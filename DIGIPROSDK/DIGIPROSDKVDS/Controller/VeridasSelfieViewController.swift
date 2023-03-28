//
//  VeridasSelfieViewController.swift
//  DIGIPROSDK
//
//  Created by SANDRA SOTO  on 20/07/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import UIKit
import VDPhotoSelfieCapture
import VDLibrary

public protocol BackVeridasSelfieActionDelegate {
    func processSelfieFinished(incomeData: FEOcrVeridas, pathCroppedSelfie: String, pathVideoSelfie: String)
    func successfulSelfieProcess(title: String)
    func failureUploadSelfie(_ message: String)
    func failureSelfieGetValidation(_ message: String)
    func failureUpdateChallenge(_ message: String)
}

class VeridasSelfieViewController: UIViewController, VDPhotoSelfieCaptureProtocol {
    
    private var token: String = ""
    var sdkAPI : APIManager<VeridasSelfieViewController>?
    var delegateSelfieVeridas : BackVeridasSelfieActionDelegate?
    var hud: JGProgressHUD?
    var principalHud: JGProgressHUD?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !VDPhotoSelfieCapture.isStarted() {
            principalHud = JGProgressHUD(style: .dark)
            principalHud?.textLabel.text = "Obteniendo Challenge"
            principalHud?.show(in: self.view, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sdkAPI = APIManager<VeridasSelfieViewController>()
        self.sdkAPI?.delegate = self
    }
    
    init(token: String) {
        super.init(nibName: nil, bundle: .main)
        self.token = token
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if VDPhotoSelfieCapture.isStarted() {
            // Scanner iniciado y no puedo obtener el servicio.
        } else {
            getChallengeSelfie()
        }
        view.backgroundColor = UIColor.clear
        principalHud?.dismiss(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        VDPhotoSelfieCapture.stop()
    }
    
    // MARK: VDPhotoSelfieCaptureProtocol
    func vdPhotoSelfieCaptured(_ photoSelfieData: Data!, andFace face: Data!) {
        let defaults = UserDefaults.standard
        defaults.setValue(photoSelfieData, forKey: "SelfieDataToSend")
        defaults.setValue(face, forKey: "CroppedSelfieDataToSend")
    }
    
    //En caso que se usen live fotos, usar el servicio del challenge
    func vdPhotoSelfieCaptured(withLiveDetection photoSelfieData: Data!, andFace face: Data!) {
        let defaults = UserDefaults.standard
        defaults.set(photoSelfieData, forKey: "SelfieDataToSend")
        defaults.set(face, forKey: "CroppedSelfieDataToSend")
    }
    
    //file es vtt
    func vdPhotoChallengeVideoCaptured(_ videoChallenges: Data!, andFile file: Data!) {
        let defaults = UserDefaults.standard
        defaults.set(videoChallenges, forKey: "VideoSelfieDataToSend")
        defaults.setValue(file, forKey: "VTTSelfieDataToSend")
    }
    
    func vdPhotoSelfieChallengeFinishedWithError() {
        print("Repetir proceso.")
        let dictService: [String : Any] = ["tokenid":self.token]
        sdkAPI?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioVeridas.GetChallengeSelfie", assemblypath: "ServiciosDigipro.dll", data: dictService).then({ response in
            do {
                let dict = try JSONSerializer.toDictionary(response)
                guard let dataDict = dict["data"] as? NSMutableDictionary else { return }
                
                VDPhotoSelfieCapture.setChallenge(dataDict["challenge"] as? String ?? VeridasValidation.challenge)
                
            } catch { }
        }).catch({ error in
            self.hud?.dismiss(animated: true)
            self.dismiss(animated: true) {
                VDPhotoSelfieCapture.stop()
            }
            self.delegateSelfieVeridas?.failureUpdateChallenge("Error al obtener el nuevo challenge \(error.localizedDescription)")
        })
    }
    
    func vdPhotoSelfieAllFinished(_ processFinished: Bool) {
        if processFinished {
            let defaults = UserDefaults.standard
            guard let selfieImage = defaults.data(forKey: "SelfieDataToSend") else { return }
            guard let croppedSelfieImage = defaults.data(forKey: "CroppedSelfieDataToSend") else { return }
            guard let videoSelfie = defaults.data(forKey: "VideoSelfieDataToSend") else { return }
            guard let vttSelfie = defaults.data(forKey: "VTTSelfieDataToSend") else { return }
            
            uploadSelfieWithInformation(selfieBase64: selfieImage.base64EncodedString(), croppedSelfieBase64: croppedSelfieImage.base64EncodedString(), videoBase64: videoSelfie.base64EncodedString(), vttBase64: vttSelfie.base64EncodedString())
            
        } else { // Cuando se presiona la X
            self.dismiss(animated: true) {
                VDPhotoSelfieCapture.stop()
            }
        }
    }
    
    private func stopScannerSelfie() {
        if VDPhotoSelfieCapture.isStarted() {
            VDPhotoSelfieCapture.stop()
        }
    }
    
    public func getChallengeSelfie(){
        let dictService: [String : Any] = ["tokenid":self.token]
        self.sdkAPI?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioVeridas.GetChallengeSelfie", assemblypath: "ServiciosDigipro.dll", data: dictService).then({ response in
            self.hud?.dismiss(animated: true)
            do {
                let dict = try JSONSerializer.toDictionary(response)
                guard let dataDict = dict["data"] as? NSMutableDictionary else {
                    print("No se logro desempaquetar el elemento data.")
                    return
                }
                
                let configurationSelfie: [String : Any] = ["closebutton": "YES","livephoto": "YES", "jws_token": dataDict["challenge"] as? String ?? ""]
                
                if !VDPhotoSelfieCapture.isStarted() {
                    VDPhotoSelfieCapture.start(withDelegate: self, andConfiguration: configurationSelfie)
                }
                
                self.hud?.dismiss(animated: true)
            } catch {
                self.delegateSelfieVeridas?.failureSelfieGetValidation("Hubo un error al obtener el challenge")
                self.hud?.dismiss(animated: true)
                self.dismiss(animated: true) {
                    VDPhotoSelfieCapture.stop()
                }
            }
        }).catch({ error in
            self.hud?.dismiss(animated: true)
            self.dismiss(animated: true) {
                VDPhotoSelfieCapture.stop()
            }
            self.delegateSelfieVeridas?.failureSelfieGetValidation("Error al obtener el challenge \(error.localizedDescription)")
        })
    }
    
    public func uploadSelfieWithInformation( selfieBase64: String, croppedSelfieBase64: String, videoBase64: String, vttBase64: String){
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = "Subiendo Imagenes"
        hud?.show(in: self.view, animated: true)
        let proyID: String = "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)"
        
        let dictServiceSelfie: [String : Any] = ["proyid": proyID, "tokenid": self.token, "selfie": croppedSelfieBase64, "video": videoBase64, "vtt": vttBase64]
        DispatchQueue.main.async {
            self.sdkAPI?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioVeridas.UploadSelfie", assemblypath: "ServiciosDigipro.dll", data: dictServiceSelfie).then({ response in
                do {
                    let dict = try JSONSerializer.toDictionary(response)
                    guard let answer = dict["response"] as? NSMutableDictionary else { return }
                    if answer["success"] as! Bool == true && answer["servicemessage"] as? String ?? "" == "La selfie, video y vtt se envio exitosamente" {
                        
                        self.uploadSelfieValidation(selfieBase64: selfieBase64, croppedSelfieBase64: croppedSelfieBase64, videoBase64: videoBase64, vttBase64: vttBase64)
                        
                    } else {
                        self.hud?.dismiss(animated: true)
                        self.dismiss(animated: true) {
                            VDPhotoSelfieCapture.stop()
                        }
                        self.delegateSelfieVeridas?.failureUploadSelfie("Las imagenes no contienen el formato correcto.")
                    }
                } catch {
                    self.delegateSelfieVeridas?.failureUploadSelfie("Hubo un error al enviar imagenes a Veridas.")
                    self.hud?.dismiss(animated: true)
                    self.dismiss(animated: true) {
                        VDPhotoSelfieCapture.stop()
                    }
                }
            }).catch({ errorDocument in
                self.hud?.dismiss(animated: true)
                self.dismiss(animated: true) {
                    VDPhotoSelfieCapture.stop()
                }
                self.delegateSelfieVeridas?.failureUploadSelfie("Hubo un error al enviar imagenes a Veridas, \(errorDocument.localizedDescription).")
            })
        }
    }
    
    func uploadSelfieValidation(selfieBase64: String, croppedSelfieBase64: String, videoBase64: String, vttBase64: String) {
        let dictServiceDocument: [String : Any] = ["tokenid":self.token]
        DispatchQueue.global(qos: .background).async {
            self.sdkAPI?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioVeridas.Validation", assemblypath: "ServiciosDigipro.dll", data: dictServiceDocument).then({ response in
                self.hud?.dismiss(animated: true)
                do {
                    let dict = try JSONSerializer.toDictionary(response)
                    guard let messages = dict["response"] as? NSMutableDictionary, let serviceDict = dict["data"] as? NSMutableDictionary else {
                        return
                    }
                    let ocrVeridas = FEOcrVeridas(dictionary: serviceDict)
                    print(ocrVeridas)
                    print(messages["servicemessage"] as? String ?? "No hay respuesta del sistema")
                    self.delegateSelfieVeridas?.successfulSelfieProcess(title: "Respuesta exitosa de OCR.")
                    let pathSelfie = "\(ConfigurationManager.shared.guid)_Selfie_\(ConfigurationManager.shared.utilities.guid()).jpg"
                    // recibe un base64, convierte a data y despues a imagen
                    let SelfieData = Data(base64Encoded: selfieBase64)
                    let dataSelfieImage = UIImage(data: SelfieData ?? Data())
                    
                    let resizeImage = dataSelfieImage?.resized(withPercentage: 0.3)
                    let jpgConversion = resizeImage?.jpegData(compressionQuality: 0.6)
                    let jpgImageSelfie = UIImage(data: jpgConversion!)
                    _ = ConfigurationManager.shared.utilities.saveImageToFolder( jpgImageSelfie!, pathSelfie)
                    
                    let CroppedSelfieData = Data(base64Encoded: croppedSelfieBase64)
                    let dataCroppedSelfieImage = UIImage(data: CroppedSelfieData ?? Data())
                    let pathCroppedSelfie = "\(ConfigurationManager.shared.guid)_Selfie_Recortada_\(ConfigurationManager.shared.utilities.guid()).jpg"
                    
                    let resizeImageCroppedSelfie = dataCroppedSelfieImage?.resized(withPercentage: 0.3)
                    let jpgConversionCroppedSelfie = resizeImageCroppedSelfie?.jpegData(compressionQuality: 0.6)
                    let jpgImageCroppedSelfie = UIImage(data: jpgConversionCroppedSelfie!)
                    _ = ConfigurationManager.shared.utilities.saveImageToFolder(
                        jpgImageCroppedSelfie!, pathCroppedSelfie)
                    
                    //Se toman los videos y la ruta
                    let pathVideoSelfie = "\(ConfigurationManager.shared.guid)_Video_Selfie_\(ConfigurationManager.shared.utilities.guid()).mp4"
                    // recibe un base64, convierte a data y despues guarda
                    let videoSelfieData = Data(base64Encoded: videoBase64)
                    _ = ConfigurationManager.shared.utilities.saveVideoToFolder(videoSelfieData!, pathVideoSelfie)
                    
                    //Ruta vtt
                    let pathVttSelfie = "\(ConfigurationManager.shared.guid)_Video_VTT_Selfie_\(ConfigurationManager.shared.utilities.guid()).vtt"
                    let vttSelfieData = Data(base64Encoded: vttBase64)
                    _ = ConfigurationManager.shared.utilities.saveVideoToFolder(vttSelfieData!, pathVttSelfie)
                    
                    self.delegateSelfieVeridas?.processSelfieFinished(incomeData: ocrVeridas, pathCroppedSelfie: pathCroppedSelfie, pathVideoSelfie: pathVideoSelfie)
                    self.hud?.dismiss(animated: true)
                    self.dismiss(animated: true) {
                        VDPhotoSelfieCapture.stop()
                    }
                } catch {
                    self.delegateSelfieVeridas?.failureSelfieGetValidation("No se obtuvo la validacion correspondiente.")
                    self.hud?.dismiss(animated: true)
                    self.dismiss(animated: true) {
                        VDPhotoSelfieCapture.stop()
                    }
                }
            }).catch({ error in
                self.hud?.dismiss(animated: true)
                self.dismiss(animated: true) {
                    VDPhotoSelfieCapture.stop()
                }
                self.delegateSelfieVeridas?.failureSelfieGetValidation("No se obtuvo la validacion correspondiente, \(error.localizedDescription).")
            })
        }
    }
    
}

// MARK:  APIDelegate
extension VeridasSelfieViewController: APIDelegate {
    func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
    func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
    func sendStatusCodeMessage(message: String, error: enumErrorType) {}
    func didSendError(message: String, error: enumErrorType) {}
    func didSendResponse(message: String, error: enumErrorType) {}
    func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
}
