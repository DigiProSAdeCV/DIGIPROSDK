//
//  AnylineEscanerViewController.swift
//  DIGIPROSDKANL
//
//  Created by Alberto Echeverri Carrillo on 19/04/21.
//

import UIKit
//import GSSDKCore
//import GSSDKScanFlow
/**
 // MARK: Al descomentar el código, asegurarse de descomentar otros elementos
 que utilizen este protocolo delegado, librerias Genious Scan o
 demás clases que usen algún elemento de este controlador.
 */
//public protocol GeniusEscanerViewControllerDelegate {
//    func escanerResult(image: UIImage)
//    func errorEscaner(mensaje: String, error: Error?)
//}

public class GeniusEscanerViewController: UIViewController {
    
//    #warning("Caduca 19 de Octubre")
//    let licenseKey = "533c5006575207060251005839525a0e4a075b035d4640564c5b5b105e546f0154075055000d05065c"
//
//    private var scanFlow: GSKScanFlow?
//    public var delegate: GeniusEscanerViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
       
//        do {
//            try GSK.initWithLicenseKey(licenseKey)
//        } catch {
//            print(error.localizedDescription)
//            self.delegate?.errorEscaner(mensaje: error.localizedDescription, error: nil)
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if self.scanFlow == nil {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                self.starScan()
//            }
//        }
    }

//    private func starScan() {
//
//        let configuration = GSKScanFlowConfiguration()
//        configuration.multiPage = false
//        configuration.jpegQuality = 5
//        configuration.defaultFilter = .photo
//
//        self.scanFlow = GSKScanFlow(configuration: configuration)
//
//        scanFlow?.start(from: self, onSuccess: { result in
//            if result.scans.count > 0 {
//                //Solo la primera imagen, preguntar si quieren guardar todas las imagenes.
//                //Antes no era posible por Anyline pero GeniusScanSDK lo permite con facilidad.
//                let enhancedImage = result.scans[0].enhancedImage()
//                if let image = enhancedImage {
//                    self.delegate?.escanerResult(image: image)
//                    self.dismiss(animated: true, completion: nil)
//                }
//            }
//        }, failure: { error in
//            self.delegate?.errorEscaner(mensaje: error.localizedDescription, error: error)
//            print(error.localizedDescription)
//            self.dismiss(animated: true, completion: nil)
//        })
//    }
   
}
