//
//  VeridasExtension.swift
//  DIGIPROSDKUI
//
//  Created by Carlos Mendez Flores on 28/10/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

// MARK: VERIDAS
#if canImport(VDDocumentCapture)
import VDDocumentCapture

// MARK: VDDocumentCaptureProtocol (captura de INE/IFE)
extension NuevaPlantillaViewController : VDDocumentCaptureProtocol {
    // creo que es aqui para que llene valores de las cell
    public func vdDocumentCaptured(_ imageData: Data!, with captureType: VDCaptureType, andDocument document: [VDDocument]!) {
        let defaults = UserDefaults.standard
        if captureType.rawValue == 0 || captureType.rawValue == 1 {
            defaults.set(imageData, forKey: "ObverseDataToSend")
            let imageIneData = UIImage(data: imageData)
            let path = "\(ConfigurationManager.shared.guid)_Anverso_1_\(ConfigurationManager.shared.utilities.guid()).jpg"
            _ = ConfigurationManager.shared.utilities.saveImageToFolder(imageIneData ?? UIImage(), path)
            let pinAnverso = elemtVDDocument?["pout"]["order_1"]["idelem"].value
            _ = self.resolveValor(pinAnverso ?? "", "asignacion", path)
        } else {
            defaults.set(imageData, forKey: "ReverseDataToSend")
            //guardamos en defaults esa imagen
            let imageIneData = UIImage(data: imageData)
            let path = "\(ConfigurationManager.shared.guid)_Reverso_1_\(ConfigurationManager.shared.utilities.guid()).jpg"
            _ = ConfigurationManager.shared.utilities.saveImageToFolder(imageIneData ?? UIImage(), path)
            let pinReverso = elemtVDDocument?["pout"]["order_2"]["idelem"].value
            _ = self.resolveValor(pinReverso ?? "", "asignacion", path)
        }
    }
    
    public func vdDocumentAllFinished(_ processFinished: Bool) {
        // Todo el proceso a finalizado
    }
    
    public func vdTimeWithoutPhotoTaken(_ seconds: Int32, with capture: VDCaptureType) {}
}

#else
extension NuevaPlantillaViewController { }
#endif

#if canImport(VDPhotoSelfieCapture)
import VDPhotoSelfieCapture

// MARK: VDVideoSelfieCaptureProtocol
extension  NuevaPlantillaViewController: VDVideoSelfieCaptureProtocol {
    
    public func vdVideoSelfieCaptured(_ videoSelfieData: Data!) {
        let path = "\(ConfigurationManager.shared.guid)_SelfieVideo_Veridas_\(ConfigurationManager.shared.utilities.guid()).mp4"
        let pinSelfieVideoAndDocument = elemtVDDocument?["pout"]["order_1"]["idelem"].value
        let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(videoSelfieData as NSData, path)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = self.resolveValor(pinSelfieVideoAndDocument ?? "", "asignacion", path)
        }
    }
    
    public func vdVideoSelfieCaptured(_ videoSelfieData: Data!, withProcessInfo processInfo: Data!) {
        let path = "\(ConfigurationManager.shared.guid)_SelfieVideo_Veridas_\(ConfigurationManager.shared.utilities.guid()).mp4"
        let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(videoSelfieData as NSData, path)
        let pinSelfieVideoAndDocument = elemtVDDocument?["pout"]["order_1"]["idelem"].value
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        _ = self.resolveValor(pinSelfieVideoAndDocument ?? "", "asignacion", path)
        }
    }
    
    public func vdVideoSelfieAllFinished(_ processFinished: Bool) { }

}
#else
extension NuevaPlantillaViewController { }
#endif

#if canImport(VDVideoSelfieCapture)
import VDVideoSelfieCapture
// MARK: VDPhotoSelfieCaptureProtocol
extension NuevaPlantillaViewController: VDPhotoSelfieCaptureProtocol {
    
    public func vdPhotoSelfieCaptured(_ photoSelfieData: Data!, andFace face: Data!) {
        let imageIneData = UIImage(data: face)
        let path = "\(ConfigurationManager.shared.guid)_Cara_Veridas_\(ConfigurationManager.shared.utilities.guid()).jpg"
        _ = ConfigurationManager.shared.utilities.saveImageToFolder(imageIneData ?? UIImage(), path)
        let pinFace = elemtVDDocument?["pout"]["order_1"]["idelem"].value
        _ = self.resolveValor(pinFace ?? "", "asignacion", path)
        elemtVDDocument = nil
    }
    
    public func vdPhotoSelfieCaptured(withLiveDetection photoSelfieData: Data!, andFace face: Data!) {
        
    }
    public func vdPhotoSelfieAllFinished(_ processFinished: Bool) {
        
    }
}
#else
extension NuevaPlantillaViewController { }
#endif
