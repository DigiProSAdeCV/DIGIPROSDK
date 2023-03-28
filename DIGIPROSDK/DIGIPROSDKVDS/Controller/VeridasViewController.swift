//
//  VeridasViewController.swift
//  DIGIPROSDKVE
//
//  Created by Carlos Mendez Flores on 27/11/20.
//

import UIKit
import Eureka
import VDDocumentCapture

public protocol BackVeridasActionDelegate {
    func processFinished(incomeData: FEOcrVeridas,pathReverse: String, pathObverse: String, _ token: String, _ docType: String)
    func successfulProcess(title: String)
    func vdOutOfTime(_ message: String, seconds: Int32)
    func failureToken(_ message: String)
    func failureUploadDocuments(_ message: String)
    func failureGetValidation(_ message: String)
}

class VeridasViewController: UIViewController {
    
    var sdkAPI : APIManager<VeridasViewController>?
    var delegateVeridas : BackVeridasActionDelegate?
    var hud: JGProgressHUD?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sdkAPI = APIManager<VeridasViewController>()
        self.sdkAPI?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let configuration : [String : String] = ["closebutton": "YES", "obverseflash": "NO"]
        let documents : [String] = ["MX_IDCard_2008","MX_IDCard_2014", "MX_IDCard_2019"]
        // pais documentos -> "MX2_ID"
        // formas validacion -> "documentos"
        if !VDDocumentCapture.isStarted() {
            VDDocumentCapture.start(withDelegate: self, andDocumentIds: documents, andConfiguration: configuration)
        }
    }
    
    deinit {
        VDDocumentCapture.stop()
    }
    
    // MARK: OBJC Methods
    @objc private func closeWindow() {
        self.dismiss(animated: true)
    }
    
    /// The scanning process ends
    private func stopScannerDocuments() {
        if VDDocumentCapture.isStarted() {
            VDDocumentCapture.stop()
        }
    }
}

// MARK: VDDocumentCaptureProtocol
extension VeridasViewController: VDDocumentCaptureProtocol {
    // pasar el de getValidation su respectivo token para no hacer todo el proceso.
    func vdDocumentCaptured(_ imageData: Data!, with captureType: VDCaptureType, andDocument document: [VDDocument]!) {
        
        let defaults = UserDefaults.standard
        if captureType.rawValue == 0 || captureType.rawValue == 1 {
            // Front of card
            defaults.set(imageData, forKey: "ObverseDataToSend")
        } else { // Back of card
            defaults.set(imageData, forKey: "ReverseDataToSend")
        }
        defaults.setValue(document![0].documentName, forKey: "DocumentName")
    }
    
    func vdDocumentAllFinished(_ processFinished: Bool) {
        if processFinished {
            // Retrieve data from UserDefaults
            let defaults = UserDefaults.standard
            guard let observeImage = defaults.data(forKey: "ObverseDataToSend") else { return }
            guard let reverseImage = defaults.data(forKey: "ReverseDataToSend") else { return }
            guard let mydoctype = defaults.object(forKey: "DocumentName") else { return }
            
            getTokenInformation(doctypeID: mydoctype as? String ?? "", frontalBase64: observeImage.base64EncodedString(), reverseBase64: reverseImage.base64EncodedString())
            
        } else { // Presiona la X que viene dentro del componente
            stopScannerDocuments()
            self.dismiss(animated: true, completion: nil)
        }
    }
    func vdTimeWithoutPhotoTaken(_ seconds: Int32, with capture: VDCaptureType) {
        delegateVeridas?.vdOutOfTime("Se agotó tu tiempo de espera, vuelve a intentarlo.", seconds: seconds)
    }
}

extension VeridasViewController {
    
    public func getTokenInformation(doctypeID: String, frontalBase64: String, reverseBase64: String) {
        let dictService: [String : Any] = [:]
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = "Subiendo Documentos"
        hud?.show(in: self.view, animated: true)
        DispatchQueue.global(qos: .background).async {
            self.sdkAPI?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioVeridas.GetToken", assemblypath: "ServiciosDigipro.dll", data: dictService).then({ response in
                self.hud?.dismiss(animated: true)
                do {
                    let dict = try JSONSerializer.toDictionary(response)
                    guard let dataDict = dict["data"] as? NSMutableDictionary else {
                        return
                    }
                    self.dismiss(animated: true)
                    self.uploadDocuments(withToken: dataDict["tokenid"] as? String ?? "", documentType: doctypeID, frontalImage: frontalBase64, reverseImage: reverseBase64)
                    
                } catch {
                    self.delegateVeridas?.failureToken("Hubo un error al obtener el token")
                    self.hud?.dismiss(animated: true)
                }
            }).catch({ error in
                self.hud?.dismiss(animated: true)
                self.dismiss(animated: true)
                self.delegateVeridas?.failureToken("Error al obtener el token \(error.localizedDescription)")
            })
        }
    }
    
    func uploadDocuments(withToken tokenID: String, documentType: String, frontalImage: String, reverseImage: String) {
        let urlSite: String = "https://test.digipromovil.com:495/VersionGenerica/WCFFileTransfer/"
        let proyID: String = "\(ConfigurationManager.shared.codigoUIAppDelegate.ProyectoID)"
        let dictJsonService: [String : Any] = ["FEVersion": "V2 1.20.052", "OSName": "iOS", "proyectoid": "\(proyID)", "sitio": urlSite, "usuario": "\(ConfigurationManager.shared.usuarioUIAppDelegate.User)", "stats_tenant": "\(urlSite)_\(proyID)"]
        //timestamp o hash
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dictJsonService, options: JSONSerialization.WritingOptions.sortedKeys)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        
        let dictServiceDocument: [String : Any] = ["tokenid":tokenID, "doctype": documentType, "base64anverso": frontalImage, "base64reverso": reverseImage, "proyid": proyID, "jsondata": jsonString]
        self.sdkAPI?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioVeridas.UploadDocuments", assemblypath: "ServiciosDigipro.dll", data: dictServiceDocument).then({ response in
            do {
                let dict = try JSONSerializer.toDictionary(response)
                guard let answer = dict["response"] as? NSMutableDictionary else { return }
                if answer["success"] as! Bool == true && answer["servicemessage"] as? String ?? "" == "Las imagenes se enviaron exitosamente" {
                    
                    self.uploadValidation(myToken: tokenID, observeImageBase64: frontalImage, reverseImageBase64: reverseImage, doctype: documentType)
                    
                } else {
                    self.delegateVeridas?.failureUploadDocuments("Las imagenes no contienen el formato correcto o el servicio está caído. Intentelo más tarde.")
                    self.hud?.dismiss(animated: true)
                }
            } catch {
                self.delegateVeridas?.failureUploadDocuments("Hubo un error al enviar documentos a Veridas.")
                self.hud?.dismiss(animated: true)
            }
        }).catch({ errorDocument in
            self.hud?.dismiss(animated: true)
            self.dismiss(animated: true)
            self.delegateVeridas?.failureUploadDocuments("Hubo un error al enviar documentos a Veridas, \(errorDocument.localizedDescription).")
        })
    }
    
    func uploadValidation(myToken: String, observeImageBase64: String, reverseImageBase64: String, doctype: String) {
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = "hud_downloading".langlocalized()
        hud?.show(in: self.view, animated: true)
        
        let dictServiceDocument: [String : Any] = ["tokenid":myToken]
        DispatchQueue.global(qos: .background).async {
            self.sdkAPI?.DGSDKService(delegate: self, initialmethod: "ServiciosDigipro.ServicioVeridas.Validation", assemblypath: "ServiciosDigipro.dll", data: dictServiceDocument).then({ response in
                UILoader.remove(parent: self.view)
                do {
                    let dict = try JSONSerializer.toDictionary(response)
                    guard let messages = dict["response"] as? NSMutableDictionary, let serviceDict = dict["data"] as? NSMutableDictionary else {
                        return
                    }
                    let ocrVeridas = FEOcrVeridas(dictionary: serviceDict)
                    print(ocrVeridas)
                    print(messages["servicemessage"] as? String ?? "No hay respuesta del sistema")
                    self.delegateVeridas?.successfulProcess(title: "Respuesta exitosa de OCR.")
                    let pathObverse = "\(ConfigurationManager.shared.guid)_Anverso_1_\(ConfigurationManager.shared.utilities.guid()).jpg"
                    // recibe un base64, convierte a data y despues a imagen
                    let ObverseData = Data(base64Encoded: observeImageBase64)
                    let dataObverseImage = UIImage(data: ObverseData ?? Data())
                    
                    let resizeImage = dataObverseImage?.resized(withPercentage: 0.3)
                    let jpgConversion = resizeImage?.jpegData(compressionQuality: 0.6)
                    let jpgImageObverse = UIImage(data: jpgConversion!)
                    _ = ConfigurationManager.shared.utilities.saveImageToFolder( jpgImageObverse!, pathObverse)
                    
                    let ReverseData = Data(base64Encoded: reverseImageBase64)
                    let dataReverseImage = UIImage(data: ReverseData ?? Data())
                    let pathReverse = "\(ConfigurationManager.shared.guid)_Reverso_1_\(ConfigurationManager.shared.utilities.guid()).jpg"
                    
                    let resizeImageReverse = dataReverseImage?.resized(withPercentage: 0.3)
                    let jpgConversionReverse = resizeImageReverse?.jpegData(compressionQuality: 0.6)
                    let jpgImageReverse = UIImage(data: jpgConversionReverse!)
                    _ = ConfigurationManager.shared.utilities.saveImageToFolder(
                        jpgImageReverse!, pathReverse)
                    // Se implementa el protocolo.
                    ocrVeridas.fullName = "\(ocrVeridas.PD_Name_Out)"
                    self.delegateVeridas?.processFinished(incomeData: ocrVeridas, pathReverse: pathReverse, pathObverse: pathObverse, myToken, doctype)
                    
                    self.dismiss(animated: true)
                } catch {
                    self.delegateVeridas?.failureGetValidation("No se obtuvo la validacion correspondiente.")
                    self.hud?.dismiss(animated: true)
                    self.dismiss(animated: true)
                }
            }).catch({ error in
                self.hud?.dismiss(animated: true)
                self.dismiss(animated: true)
                self.delegateVeridas?.failureGetValidation("No se obtuvo la validacion correspondiente, \(error.localizedDescription).")
            })
        }
    }
}

// MARK:  APIDelegate
extension VeridasViewController: APIDelegate {
    func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
    func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
    func sendStatusCodeMessage(message: String, error: enumErrorType) {}
    func didSendError(message: String, error: enumErrorType) {}
    func didSendResponse(message: String, error: enumErrorType) {}
    func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
}
